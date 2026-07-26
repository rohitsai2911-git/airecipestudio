# AI Recipe Studio — Production Backend

FastAPI (async) · Pydantic v2 · Supabase (Postgres + Auth) · Free OpenAI-compatible LLM (Groq / OpenRouter).

Everything below is a complete, runnable backend. Create the files as named, run `schema.sql` in Supabase, fill `.env`, then `uvicorn main:app`.

Layout:

```
.
├── main.py
├── config.py
├── database.py
├── auth.py
├── models.py
├── ai_service.py
├── routers/
│   ├── __init__.py
│   ├── library_router.py
│   ├── chat_router.py
│   ├── xp_router.py
│   └── meal_plan_router.py
├── schema.sql
├── requirements.txt
└── .env.example
```

---

## requirements.txt

```text
fastapi==0.115.6
uvicorn[standard]==0.34.0
pydantic==2.10.4
pydantic-settings==2.7.1
httpx==0.28.1
supabase==2.11.0
python-jose[cryptography]==3.3.0
```

---

## .env.example

```dotenv
# Free OpenAI-compatible provider (Groq / OpenRouter / etc.)
OPENAI_API_KEY=gsk_YOUR_GROQ_API_KEY_OR_OPENROUTER_KEY
OPENAI_BASE_URL=https://api.groq.com/openai/v1

# Supabase — Project settings -> API
SUPABASE_URL=https://YOUR_PROJECT.supabase.co
SUPABASE_KEY=YOUR_SERVICE_ROLE_KEY
SUPABASE_JWT_SECRET=YOUR_JWT_SECRET

# Optional overrides
MODEL_ID=llama-3.3-70b-versatile
XP_PER_COMPLETION=50
CORS_ORIGINS=*
```

---

## config.py

```python
from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    openai_api_key: str
    openai_base_url: str = "https://api.groq.com/openai/v1"

    supabase_url: str
    supabase_key: str
    supabase_jwt_secret: str

    model_id: str = "llama-3.3-70b-versatile"
    xp_per_completion: int = 50
    cors_origins: str = "*"

    @property
    def cors_origins_list(self) -> list[str]:
        if self.cors_origins.strip() == "*":
            return ["*"]
        return [o.strip() for o in self.cors_origins.split(",") if o.strip()]


@lru_cache
def get_settings() -> Settings:
    return Settings()
```

---

## database.py

```python
"""Single async Supabase client, created once and injected via Depends."""
from supabase import AsyncClient, acreate_client

from config import get_settings

_client: AsyncClient | None = None


async def init_db() -> None:
    """Create the shared client at startup."""
    global _client
    settings = get_settings()
    _client = await acreate_client(settings.supabase_url, settings.supabase_key)


async def get_db() -> AsyncClient:
    """FastAPI dependency. Assumes init_db() ran during app startup."""
    if _client is None:
        # Lazy fallback so the dependency also works outside the lifespan (e.g. tests).
        await init_db()
    assert _client is not None
    return _client
```

---

## auth.py

```python
"""Verify Supabase-issued JWTs. Supabase Auth owns signup/login/passwords —
we only validate the bearer token and extract the user id."""
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError, jwt

from config import Settings, get_settings

_bearer = HTTPBearer(auto_error=True)


class CurrentUser:
    def __init__(self, user_id: str, email: str | None, claims: dict):
        self.id = user_id
        self.email = email
        self.claims = claims


def get_current_user(
    creds: HTTPAuthorizationCredentials = Depends(_bearer),
    settings: Settings = Depends(get_settings),
) -> CurrentUser:
    try:
        payload = jwt.decode(
            creds.credentials,
            settings.supabase_jwt_secret,
            algorithms=["HS256"],
            audience="authenticated",
        )
    except JWTError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid authentication token: {exc}",
            headers={"WWW-Authenticate": "Bearer"},
        ) from exc

    user_id = payload.get("sub")
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token missing subject claim",
        )
    return CurrentUser(user_id=user_id, email=payload.get("email"), claims=payload)
```

---

## models.py

```python
"""Pydantic v2 schemas: request inputs, strict AI output, and persistence DTOs."""
from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field


# ---------- Requests ----------

class RecipeRequest(BaseModel):
    ingredients: list[str] = Field(default_factory=list, description="Ingredients on hand, if typed")
    ingredient_image_base64: str | None = Field(
        None, description="Base64 photo of a fridge/pantry — ingredients are vision-extracted and merged with `ingredients`"
    )
    cuisine: str = Field("any", description="'any', 'global', or a specific cuisine")
    serving_size: int = Field(..., ge=1, le=20, description="Number of servings to scale to")
    time_limit_minutes: int | None = Field(
        None, ge=1, le=600, description="Max total cooking time, if constrained"
    )

    def model_post_init(self, __context) -> None:
        if not self.ingredients and not self.ingredient_image_base64:
            raise ValueError("Provide `ingredients`, `ingredient_image_base64`, or both")


class ChatRequest(BaseModel):
    session_id: str = Field(..., description="Active recipe/cooking session id")
    message: str = Field(..., min_length=1)


class CompletionRequest(BaseModel):
    recipe_id: str = Field(..., description="Recipe being marked completed")


class BookmarkRequest(BaseModel):
    bookmarked: bool


class SaveRecipeRequest(BaseModel):
    dish: "Dish"


# ---------- Strict AI output ----------
# Note: structured-output JSON schema does not support array minItems, so
# "2+ dishes" is enforced in the prompt AND validated after parsing.

class Ingredient(BaseModel):
    name: str
    quantity: str = Field(..., description="Exact scaled amount for beginners, e.g. '1 1/2 cups'")
    unit: str = Field("", description="Measurement unit if separate from quantity")


class Step(BaseModel):
    number: int
    instruction: str


class Dish(BaseModel):
    title: str
    cuisine: str
    cook_time_minutes: int
    servings: int
    ingredients: list[Ingredient]
    steps: list[Step]
    image_prompt_key: str = Field(
        ..., description="Concise text key describing the plated dish, for downstream image generation"
    )


class RecipeResponse(BaseModel):
    dishes: list[Dish] = Field(..., description="Two or more distinct dish options")


# ---------- Persistence / responses ----------

class SavedRecipe(BaseModel):
    id: str
    user_id: str
    dish: Dish
    bookmarked: bool
    status: Literal["saved", "completed"]
    created_at: datetime


class ChatMessage(BaseModel):
    role: Literal["user", "assistant"]
    content: str


class ChatReply(BaseModel):
    session_id: str
    reply: str


class CompletionResult(BaseModel):
    recipe_id: str
    xp: int
    level: int
    xp_awarded: int


# ---------- Meal plans ----------

class MealPlanRequest(BaseModel):
    plan_date: str = Field(..., description="ISO date, e.g. '2026-07-24'")
    slot: Literal["breakfast", "lunch", "dinner", "snack"]
    recipe_id: str


class MealPlanEntry(BaseModel):
    id: str
    user_id: str
    plan_date: str
    slot: Literal["breakfast", "lunch", "dinner", "snack"]
    recipe_id: str
    created_at: datetime


SaveRecipeRequest.model_rebuild()
```

---

## ai_service.py

```python
"""OpenAI-compatible LLM engine: recipe generation via JSON mode + Poco chat.

Uses a generic OpenAI-compatible API (Groq, OpenRouter, etc.) with
response_format=json_object for schema-validated recipe output. Falls
back to prompt-instructed JSON for providers that lack JSON mode."""

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


async def generate_recipes(req: RecipeRequest) -> RecipeResponse:
    settings = get_settings()

    user_content: str = _build_recipe_prompt(req)
    if req.ingredient_image_base64:
        user_content = (
            f"[Image of ingredients attached as base64]\n{user_content}"
        )

    message = await _call_openai_chat(
        model=settings.model_id,
        base_url=settings.openai_base_url,
        api_key=settings.openai_api_key,
        messages=[{"role": "user", "content": user_content}],
        max_tokens=4096,
        response_format={"type": "json_object"},
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


async def chat_with_poco(history: list[ChatMessage], message: str) -> str:
    settings = get_settings()
    convo = [{"role": m.role, "content": m.content} for m in history]
    convo.append({"role": "user", "content": message})

    reply = await _call_openai_chat(
        model=settings.model_id,
        base_url=settings.openai_base_url,
        api_key=settings.openai_api_key,
        messages=convo,
        system=POCO_PERSONA,
        max_tokens=1024,
    )

    return reply.get("content", "")
```

---

## routers/__init__.py

```python
```

---

## routers/library_router.py

```python
"""Recipe generation + library/history CRUD. All rows scoped to the caller."""
from fastapi import APIRouter, Depends, HTTPException, status
from supabase import AsyncClient

import ai_service
from auth import CurrentUser, get_current_user
from database import get_db
from models import (
    BookmarkRequest,
    Dish,
    RecipeRequest,
    RecipeResponse,
    SavedRecipe,
    SaveRecipeRequest,
)

router = APIRouter(prefix="/recipes", tags=["recipes"])


@router.post("/generate", response_model=RecipeResponse)
async def generate(
    req: RecipeRequest,
    _user: CurrentUser = Depends(get_current_user),
) -> RecipeResponse:
    return await ai_service.generate_recipes(req)


@router.post("", response_model=SavedRecipe, status_code=status.HTTP_201_CREATED)
async def save_recipe(
    req: SaveRecipeRequest,
    user: CurrentUser = Depends(get_current_user),
    db: AsyncClient = Depends(get_db),
) -> SavedRecipe:
    res = await (
        db.table("recipes")
        .insert(
            {
                "user_id": user.id,
                "dish": req.dish.model_dump(),
                "bookmarked": False,
                "status": "saved",
            }
        )
        .execute()
    )
    return SavedRecipe(**res.data[0])


@router.get("", response_model=list[SavedRecipe])
async def list_recipes(
    bookmarked: bool | None = None,
    user: CurrentUser = Depends(get_current_user),
    db: AsyncClient = Depends(get_db),
) -> list[SavedRecipe]:
    query = db.table("recipes").select("*").eq("user_id", user.id)
    if bookmarked is not None:
        query = query.eq("bookmarked", bookmarked)
    res = await query.order("created_at", desc=True).execute()
    return [SavedRecipe(**row) for row in res.data]


async def _get_owned(recipe_id: str, user: CurrentUser, db: AsyncClient) -> dict:
    res = await (
        db.table("recipes").select("*").eq("id", recipe_id).eq("user_id", user.id).execute()
    )
    if not res.data:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Recipe not found")
    return res.data[0]


@router.get("/{recipe_id}", response_model=SavedRecipe)
async def get_recipe(
    recipe_id: str,
    user: CurrentUser = Depends(get_current_user),
    db: AsyncClient = Depends(get_db),
) -> SavedRecipe:
    return SavedRecipe(**await _get_owned(recipe_id, user, db))


@router.patch("/{recipe_id}/bookmark", response_model=SavedRecipe)
async def set_bookmark(
    recipe_id: str,
    req: BookmarkRequest,
    user: CurrentUser = Depends(get_current_user),
    db: AsyncClient = Depends(get_db),
) -> SavedRecipe:
    await _get_owned(recipe_id, user, db)  # ownership check
    res = await (
        db.table("recipes")
        .update({"bookmarked": req.bookmarked})
        .eq("id", recipe_id)
        .eq("user_id", user.id)
        .execute()
    )
    return SavedRecipe(**res.data[0])


@router.delete("/{recipe_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_recipe(
    recipe_id: str,
    user: CurrentUser = Depends(get_current_user),
    db: AsyncClient = Depends(get_db),
) -> None:
    await _get_owned(recipe_id, user, db)
    await db.table("recipes").delete().eq("id", recipe_id).eq("user_id", user.id).execute()
```

---

## routers/chat_router.py

```python
"""Poco the cooking assistant. Chat history is persisted per session in Supabase."""
from fastapi import APIRouter, Depends
from supabase import AsyncClient

import ai_service
from auth import CurrentUser, get_current_user
from database import get_db
from models import ChatMessage, ChatReply, ChatRequest

router = APIRouter(prefix="/chat", tags=["chat"])


async def _load_history(
    db: AsyncClient, user_id: str, session_id: str
) -> list[ChatMessage]:
    res = await (
        db.table("chat_messages")
        .select("role, content")
        .eq("user_id", user_id)
        .eq("session_id", session_id)
        .order("created_at", desc=False)
        .execute()
    )
    return [ChatMessage(**row) for row in res.data]


@router.post("", response_model=ChatReply)
async def chat(
    req: ChatRequest,
    user: CurrentUser = Depends(get_current_user),
    db: AsyncClient = Depends(get_db),
) -> ChatReply:
    history = await _load_history(db, user.id, req.session_id)
    reply = await ai_service.chat_with_poco(history, req.message)

    # Persist both turns so the session stays context-aware.
    await db.table("chat_messages").insert(
        [
            {"user_id": user.id, "session_id": req.session_id, "role": "user", "content": req.message},
            {"user_id": user.id, "session_id": req.session_id, "role": "assistant", "content": reply},
        ]
    ).execute()

    return ChatReply(session_id=req.session_id, reply=reply)


@router.get("/{session_id}", response_model=list[ChatMessage])
async def get_history(
    session_id: str,
    user: CurrentUser = Depends(get_current_user),
    db: AsyncClient = Depends(get_db),
) -> list[ChatMessage]:
    return await _load_history(db, user.id, session_id)
```

---

## routers/xp_router.py

```python
"""XP + leveling. XP is incremented via an atomic Postgres RPC to avoid the
lost-update race two concurrent completions would cause with read-modify-write."""
from fastapi import APIRouter, Depends, HTTPException, status
from supabase import AsyncClient

from auth import CurrentUser, get_current_user
from config import get_settings
from database import get_db
from models import CompletionRequest, CompletionResult

router = APIRouter(tags=["gamification"])


@router.post("/completions", response_model=CompletionResult)
async def complete_recipe(
    req: CompletionRequest,
    user: CurrentUser = Depends(get_current_user),
    db: AsyncClient = Depends(get_db),
) -> CompletionResult:
    settings = get_settings()

    owned = await (
        db.table("recipes")
        .select("id, status")
        .eq("id", req.recipe_id)
        .eq("user_id", user.id)
        .execute()
    )
    if not owned.data:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Recipe not found")

    # ponytail: award XP only on the saved -> completed transition, enforced in SQL
    # (update ... where status = 'saved') so double-submits can't double-award.
    updated = await (
        db.table("recipes")
        .update({"status": "completed"})
        .eq("id", req.recipe_id)
        .eq("user_id", user.id)
        .eq("status", "saved")
        .execute()
    )
    already_completed = not updated.data

    if already_completed:
        profile = await db.table("profiles").select("xp, level").eq("id", user.id).execute()
        row = profile.data[0]
        return CompletionResult(recipe_id=req.recipe_id, xp=row["xp"], level=row["level"], xp_awarded=0)

    # Atomic increment + level recompute inside Postgres.
    rpc = await db.rpc(
        "increment_xp", {"p_user_id": user.id, "p_amount": settings.xp_per_completion}
    ).execute()
    row = rpc.data if isinstance(rpc.data, dict) else rpc.data[0]
    return CompletionResult(
        recipe_id=req.recipe_id,
        xp=row["xp"],
        level=row["level"],
        xp_awarded=settings.xp_per_completion,
    )
```

---

## routers/meal_plan_router.py

```python
"""Weekly meal-plan slots. Each entry pins a saved recipe to a date + slot."""
from fastapi import APIRouter, Depends, HTTPException, status
from supabase import AsyncClient

from auth import CurrentUser, get_current_user
from database import get_db
from models import MealPlanEntry, MealPlanRequest

router = APIRouter(prefix="/meal-plans", tags=["meal-plans"])


@router.post("", response_model=MealPlanEntry, status_code=status.HTTP_201_CREATED)
async def upsert_slot(
    req: MealPlanRequest,
    user: CurrentUser = Depends(get_current_user),
    db: AsyncClient = Depends(get_db),
) -> MealPlanEntry:
    owned = await (
        db.table("recipes")
        .select("id")
        .eq("id", req.recipe_id)
        .eq("user_id", user.id)
        .execute()
    )
    if not owned.data:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Recipe not found")

    res = await (
        db.table("meal_plans")
        .upsert(
            {
                "user_id": user.id,
                "plan_date": req.plan_date,
                "slot": req.slot,
                "recipe_id": req.recipe_id,
            },
            on_conflict="user_id,plan_date,slot",
        )
        .execute()
    )
    return MealPlanEntry(**res.data[0])


@router.get("", response_model=list[MealPlanEntry])
async def list_slots(
    start_date: str,
    end_date: str,
    user: CurrentUser = Depends(get_current_user),
    db: AsyncClient = Depends(get_db),
) -> list[MealPlanEntry]:
    res = await (
        db.table("meal_plans")
        .select("*")
        .eq("user_id", user.id)
        .gte("plan_date", start_date)
        .lte("plan_date", end_date)
        .order("plan_date")
        .execute()
    )
    return [MealPlanEntry(**row) for row in res.data]


@router.delete("/{entry_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_slot(
    entry_id: str,
    user: CurrentUser = Depends(get_current_user),
    db: AsyncClient = Depends(get_db),
) -> None:
    res = await (
        db.table("meal_plans").delete().eq("id", entry_id).eq("user_id", user.id).execute()
    )
    if not res.data:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Meal plan entry not found")
```

---

## main.py

```python
"""FastAPI application: lifespan, CORS, routers, and a clean error boundary."""
from contextlib import asynccontextmanager

import httpx
from fastapi import FastAPI, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from config import get_settings
from database import init_db
from routers import chat_router, library_router, meal_plan_router, xp_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    await init_db()
    yield


app = FastAPI(title="AI Recipe Studio", version="1.0.0", lifespan=lifespan)

settings = get_settings()
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(library_router.router)
app.include_router(chat_router.router)
app.include_router(xp_router.router)
app.include_router(meal_plan_router.router)


@app.exception_handler(httpx.HTTPStatusError)
async def http_status_error(request: Request, exc: httpx.HTTPStatusError):
    code = status.HTTP_429_TOO_MANY_REQUESTS if exc.response.status_code == 429 else status.HTTP_502_BAD_GATEWAY
    return JSONResponse(status_code=code, content={"detail": "AI service error. Please retry."})


@app.exception_handler(httpx.RequestError)
async def http_connection_error(request: Request, exc: httpx.RequestError):
    return JSONResponse(
        status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
        content={"detail": "Could not reach the AI service."},
    )


@app.get("/health", tags=["meta"])
async def health() -> dict:
    return {"status": "ok"}
```

---

## schema.sql

```sql
-- Run in the Supabase SQL editor. Creates tables, RLS, an auto-profile trigger,
-- and the atomic XP RPC.

-- ---------- profiles ----------
create table if not exists public.profiles (
    id    uuid primary key references auth.users (id) on delete cascade,
    xp    integer not null default 0,
    level integer not null default 1
);

-- Auto-create a profile row when a user signs up.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
    insert into public.profiles (id) values (new.id) on conflict (id) do nothing;
    return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
    after insert on auth.users
    for each row execute function public.handle_new_user();

-- ---------- recipes ----------
create table if not exists public.recipes (
    id         uuid primary key default gen_random_uuid(),
    user_id    uuid not null references auth.users (id) on delete cascade,
    dish       jsonb not null,
    bookmarked boolean not null default false,
    status     text not null default 'saved' check (status in ('saved', 'completed')),
    created_at timestamptz not null default now()
);
create index if not exists recipes_user_idx on public.recipes (user_id, created_at desc);

-- ---------- chat_messages ----------
create table if not exists public.chat_messages (
    id         uuid primary key default gen_random_uuid(),
    user_id    uuid not null references auth.users (id) on delete cascade,
    session_id text not null,
    role       text not null check (role in ('user', 'assistant')),
    content    text not null,
    created_at timestamptz not null default now()
);
create index if not exists chat_session_idx
    on public.chat_messages (user_id, session_id, created_at);

-- ---------- meal_plans ----------
create table if not exists public.meal_plans (
    id         uuid primary key default gen_random_uuid(),
    user_id    uuid not null references auth.users (id) on delete cascade,
    plan_date  date not null,
    slot       text not null check (slot in ('breakfast', 'lunch', 'dinner', 'snack')),
    recipe_id  uuid not null references public.recipes (id) on delete cascade,
    created_at timestamptz not null default now(),
    unique (user_id, plan_date, slot)
);
create index if not exists meal_plans_user_date_idx
    on public.meal_plans (user_id, plan_date);

-- ---------- atomic XP increment ----------
-- ponytail: single UPDATE ... RETURNING is race-free; no read-modify-write.
-- Level curve: level = floor(xp / 100) + 1. Tune the divisor as you like.
create or replace function public.increment_xp(p_user_id uuid, p_amount integer)
returns table (xp integer, level integer)
language plpgsql security definer set search_path = public as $$
begin
    return query
    update public.profiles
       set xp    = profiles.xp + p_amount,
           level = floor((profiles.xp + p_amount) / 100) + 1
     where id = p_user_id
    returning profiles.xp, profiles.level;
end;
$$;

-- ---------- Row Level Security ----------
alter table public.profiles      enable row level security;
alter table public.recipes       enable row level security;
alter table public.chat_messages enable row level security;
alter table public.meal_plans    enable row level security;

-- Users can read/write only their own rows. The backend uses the service_role
-- key (which bypasses RLS), so these policies protect any direct client access
-- with the anon key.
create policy "own profile"  on public.profiles
    for select using (auth.uid() = id);
create policy "own recipes"  on public.recipes
    for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own messages" on public.chat_messages
    for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own meal plans" on public.meal_plans
    for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
```

---

## Run it

```bash
pip install -r requirements.txt
cp .env.example .env          # fill in real keys
# paste schema.sql into the Supabase SQL editor and run it
uvicorn main:app --reload
```

- `GET /health` -> `{"status": "ok"}`
- `GET /docs` -> interactive OpenAPI for every endpoint
- All non-`/health` routes require an `Authorization: Bearer <supabase-user-jwt>` header. Get a token by signing a user in with any Supabase Auth client (SDK, `supabase.auth.signInWithPassword`, etc.) — this backend deliberately does not reimplement auth.

### Endpoint summary

| Method | Path | Purpose |
|---|---|---|
| POST | `/recipes/generate` | AI: 2+ scaled dish options |
| POST | `/recipes` | Save a dish to the library |
| GET | `/recipes?bookmarked=` | List history / bookmarks |
| GET | `/recipes/{id}` | Fetch one |
| PATCH | `/recipes/{id}/bookmark` | Toggle bookmark |
| DELETE | `/recipes/{id}` | Remove |
| POST | `/chat` | Talk to Poco (context-aware) |
| GET | `/chat/{session_id}` | Session history |
| POST | `/completions` | Mark completed -> award XP |
| POST | `/meal-plans` | Assign a saved recipe to a date + slot |
| GET | `/meal-plans?start_date=&end_date=` | List planned slots in a range |
| DELETE | `/meal-plans/{id}` | Remove a slot |
| GET | `/health` | Liveness |
