import base64
import json

import httpx
from fastapi import HTTPException, status
from pydantic import ValidationError

from config import get_settings
from models import ChatMessage, RecipeRequest, RecipeResponse

POCO_PERSONA = (
    "You are Poco, a warm and encouraging red panda chef who wears a tiny chef's hat. "
    "You help home cooks mid-recipe with substitutions and adjustments when they're missing "
    "ingredients or want changes. Keep replies friendly, concise, and practical. Give exact "
    "swap amounts. Never break character, but never let personality get in the way of a clear answer."
)

RECIPE_JSON_SCHEMA = RecipeResponse.model_json_schema()


def _build_recipe_prompt(req: RecipeRequest) -> str:
    cuisine = "any cuisine" if req.cuisine.lower() in ("any", "global", "") else req.cuisine
    time_line = (
        f"Total cooking time must not exceed {req.time_limit_minutes} minutes."
        if req.time_limit_minutes
        else "No strict time limit, but keep it reasonable for a home cook."
    )
    ingredients_line = (
        f"Ingredients available: {', '.join(req.ingredients)}."
        if req.ingredients
        else "No typed ingredients — identify every usable ingredient visible in the attached photo first."
    )
    schema_str = json.dumps(RECIPE_JSON_SCHEMA, indent=2)
    return (
        f"Create at least 2 distinct dish options a home cook could make.\n"
        f"{ingredients_line}\n"
        f"Cuisine preference: {cuisine}.\n"
        f"Scale every ingredient quantity for exactly {req.serving_size} serving(s); "
        f"give exact, beginner-friendly measurements (no vague 'to taste' for main quantities).\n"
        f"{time_line}\n"
        f"Each dish needs a title, cuisine, cook time in minutes, the serving count, a full "
        f"ingredient list with scaled quantities, numbered step-by-step instructions, and an "
        f"image_prompt_key describing the finished plated dish.\n\n"
        f"Respond ONLY with a valid JSON object conforming to this schema:\n{schema_str}"
    )


async def _call_openai_chat(
    *,
    model: str,
    base_url: str,
    api_key: str,
    messages: list[dict],
    system: str | None = None,
    max_tokens: int,
    response_format: dict | None = None,
) -> dict:
    body: dict = {
        "model": model,
        "max_tokens": max_tokens,
        "messages": messages,
    }
    if system:
        body["messages"].insert(0, {"role": "system", "content": system})
    if response_format:
        body["response_format"] = response_format

    async with httpx.AsyncClient(timeout=120) as client:
        resp = await client.post(
            f"{base_url.rstrip('/')}/chat/completions",
            headers={
                "Authorization": f"Bearer {api_key}",
                "Content-Type": "application/json",
                "HTTP-Referer": "https://ai-recipe-studio.app",
            },
            json=body,
        )

    if resp.status_code == 429:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="AI rate limit hit. Try again shortly.",
        )
    if not resp.is_success:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=f"AI provider error ({resp.status_code}).",
        )

    data = resp.json()
    choice = data["choices"][0]
    finish = choice.get("finish_reason", "")

    if finish == "refusal" or finish == "content_filter":
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Request declined by content policy.",
        )

    return choice["message"]


async def _try_models(
    *,
    models: list[str],
    base_url: str,
    api_key: str,
    messages: list[dict],
    system: str | None = None,
    max_tokens: int = 4096,
    response_format: dict | None = None,
    require_json: bool = False,
) -> dict:
    last_error: Exception | None = None
    for model in models:
        try:
            message = await _call_openai_chat(
                model=model,
                base_url=base_url,
                api_key=api_key,
                messages=messages,
                system=system,
                max_tokens=max_tokens,
                response_format=response_format,
            )
            if require_json:
                content = message.get("content", "")
                if not content:
                    raise ValueError("Empty response")
                json.loads(content)
            return message
        except HTTPException as e:
            if e.status_code in (status.HTTP_429_TOO_MANY_REQUESTS, status.HTTP_502_BAD_GATEWAY):
                last_error = e
                continue
            raise
        except (json.JSONDecodeError, ValidationError, ValueError) as e:
            last_error = e
            continue

    if last_error:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=f"All models failed. Last error: {last_error}",
        )
    raise HTTPException(
        status_code=status.HTTP_502_BAD_GATEWAY,
        detail="All models failed with unknown error.",
    )


async def _try_with_zen_fallback(
    *,
    primary_models: list[str],
    primary_base_url: str,
    primary_api_key: str,
    messages: list[dict],
    system: str | None = None,
    max_tokens: int = 4096,
    response_format: dict | None = None,
    require_json: bool = False,
    zen_models: list[str] | None = None,
    zen_base_url: str | None = None,
    zen_api_key: str | None = None,
) -> dict:
    try:
        return await _try_models(
            models=primary_models,
            base_url=primary_base_url,
            api_key=primary_api_key,
            messages=messages,
            system=system,
            max_tokens=max_tokens,
            response_format=response_format,
            require_json=require_json,
        )
    except HTTPException:
        if not zen_models or not zen_api_key:
            raise
        return await _try_models(
            models=zen_models,
            base_url=zen_base_url or "https://opencode.ai/zen/v1",
            api_key=zen_api_key,
            messages=messages,
            system=system,
            max_tokens=max_tokens,
            response_format=response_format,
            require_json=require_json,
        )


async def generate_recipes(req: RecipeRequest) -> RecipeResponse:
    settings = get_settings()

    models = [settings.model_id] + settings.model_fallback_list

    if req.ingredient_image_base64:
        content = [
            {
                "type": "image_url",
                "image_url": {"url": f"data:image/jpeg;base64,{req.ingredient_image_base64}"},
            },
            {"type": "text", "text": _build_recipe_prompt(req)},
        ]
        vision_models = [settings.vision_model_id] + settings.vision_model_fallback_list
        vision_base = settings.vision_base_url or settings.openai_base_url
        vision_key = settings.vision_api_key or settings.openai_api_key
        message = await _try_with_zen_fallback(
            primary_models=vision_models,
            primary_base_url=vision_base,
            primary_api_key=vision_key,
            messages=[{"role": "user", "content": content}],
            max_tokens=4096,
            require_json=True,
            zen_models=settings.zen_model_list,
            zen_base_url=settings.zen_base_url,
            zen_api_key=settings.zen_api_key,
        )
    else:
        message = await _try_with_zen_fallback(
            primary_models=models,
            primary_base_url=settings.openai_base_url,
            primary_api_key=settings.openai_api_key,
            messages=[{"role": "user", "content": _build_recipe_prompt(req)}],
            max_tokens=4096,
            response_format={"type": "json_object"},
            require_json=True,
            zen_models=settings.zen_model_list,
            zen_base_url=settings.zen_base_url,
            zen_api_key=settings.zen_api_key,
        )

    raw = message.get("content", "")
    if not raw:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Empty response from AI.",
        )

    try:
        parsed = json.loads(raw)
    except json.JSONDecodeError:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="AI returned invalid JSON.",
        )

    try:
        result = RecipeResponse(**parsed)
    except ValidationError as e:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=f"AI response failed schema validation: {e.errors()}",
        )

    if len(result.dishes) < 2:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="AI did not return at least two dishes. Please retry.",
        )

    return result


async def generate_image(prompt: str, model: str = "") -> bytes:
    settings = get_settings()

    if settings.gemini_api_key:
        try:
            return await _generate_image_gemini(prompt, settings)
        except HTTPException as e:
            if e.status_code == 429:
                pass
            elif e.status_code != 502:
                raise

    if settings.cf_account_id and settings.cf_api_token:
        try:
            return await _generate_image_cf(prompt, settings)
        except HTTPException as e:
            if e.status_code == 429:
                pass
            elif e.status_code != 502:
                raise

    if settings.openai_api_key and settings.openai_base_url:
        return await _generate_image_openai_compat(prompt, settings)

    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="No image provider configured. Set GEMINI_API_KEY or CF_ACCOUNT_ID+CF_API_TOKEN or OPENAI_API_KEY.",
    )


async def _generate_image_gemini(prompt: str, settings) -> bytes:
    model_id = "gemini-2.5-flash-image"
    url = f"https://generativelanguage.googleapis.com/v1beta/models/{model_id}:generateContent?key={settings.gemini_api_key}"
    body = {
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {"responseModalities": ["IMAGE", "TEXT"]},
    }

    async with httpx.AsyncClient(timeout=60) as client:
        resp = await client.post(url, json=body)

    if not resp.is_success:
        detail = "Gemini image generation failed."
        try:
            detail = resp.json().get("error", {}).get("message", detail)
        except Exception:
            pass
        status_code = status.HTTP_429_TOO_MANY_REQUESTS if resp.status_code == 429 else status.HTTP_502_BAD_GATEWAY
        raise HTTPException(status_code=status_code, detail=detail)

    data = resp.json()
    for part in data["candidates"][0]["content"]["parts"]:
        if "inlineData" in part and part["inlineData"]["mimeType"].startswith("image/"):
            return base64.b64decode(part["inlineData"]["data"])

    raise HTTPException(
        status_code=status.HTTP_502_BAD_GATEWAY,
        detail="Gemini did not return an image.",
    )


async def _generate_image_cf(prompt: str, settings) -> bytes:
    url = f"https://api.cloudflare.com/client/v4/accounts/{settings.cf_account_id}/ai/run/@cf/black-forest-labs/flux-1-schnell"
    async with httpx.AsyncClient(timeout=60) as client:
        resp = await client.post(
            url,
            headers={"Authorization": f"Bearer {settings.cf_api_token}"},
            json={"prompt": prompt},
        )

    if not resp.is_success:
        detail = "Image generation failed."
        try:
            detail = resp.json().get("errors", [{}])[0].get("message", detail)
        except Exception:
            pass
        raise HTTPException(status_code=status.HTTP_502_BAD_GATEWAY, detail=detail)

    return resp.content


async def _generate_image_openai_compat(prompt: str, settings) -> bytes:
    model = "gpt-image-1" if "openai.com" in settings.openai_base_url else "dall-e-3"
    url = f"{settings.openai_base_url.rstrip('/')}/images/generations"
    body = {"model": model, "prompt": prompt, "size": "1024x1024", "response_format": "b64_json"}

    async with httpx.AsyncClient(timeout=60) as client:
        resp = await client.post(
            url,
            headers={
                "Authorization": f"Bearer {settings.openai_api_key}",
                "Content-Type": "application/json",
            },
            json=body,
        )

    if not resp.is_success:
        detail = "Image generation failed."
        try:
            detail = resp.json().get("error", {}).get("message", detail)
        except Exception:
            pass
        raise HTTPException(status_code=status.HTTP_502_BAD_GATEWAY, detail=detail)

    data = resp.json()
    b64_data = data["data"][0]["b64_json"]
    return base64.b64decode(b64_data)


async def generate_speech(text: str, voice: str = "en-US-JennyNeural") -> bytes:
    try:
        import edge_tts
        communicate = edge_tts.Communicate(text, voice)
        chunks = []
        async for chunk in communicate.stream():
            if chunk["type"] == "audio":
                chunks.append(chunk["data"])
        return b"".join(chunks)
    except ImportError:
        raise HTTPException(
            status_code=status.HTTP_501_NOT_IMPLEMENTED,
            detail="TTS not available. Install: pip install edge-tts",
        )


async def chat_with_poco(history: list[ChatMessage], message: str) -> str:
    settings = get_settings()
    convo = [{"role": m.role, "content": m.content} for m in history]
    convo.append({"role": "user", "content": message})

    models = [settings.model_id] + settings.model_fallback_list
    reply = await _try_with_zen_fallback(
        primary_models=models,
        primary_base_url=settings.openai_base_url,
        primary_api_key=settings.openai_api_key,
        messages=convo,
        system=POCO_PERSONA,
        max_tokens=1024,
        zen_models=settings.zen_model_list,
        zen_base_url=settings.zen_base_url,
        zen_api_key=settings.zen_api_key,
    )

    return reply.get("content", "")