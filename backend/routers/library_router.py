"""Recipe generation + library/history CRUD. All rows scoped to the caller."""
from fastapi import APIRouter, Depends, HTTPException, status
from supabase import AsyncClient

import base64

from fastapi.responses import Response

import ai_service
from auth import CurrentUser, get_current_user
from config import get_settings
from database import get_db
from models import (
    BookmarkRequest,
    Dish,
    ImageGenRequest,
    ImageGenResponse,
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
    await _get_owned(recipe_id, user, db)
    res = await (
        db.table("recipes")
        .update({"bookmarked": req.bookmarked})
        .eq("id", recipe_id)
        .eq("user_id", user.id)
        .execute()
    )
    return SavedRecipe(**res.data[0])


@router.post("/{recipe_id}/image", response_model=ImageGenResponse)
async def generate_recipe_image(
    recipe_id: str,
    req: ImageGenRequest,
    user: CurrentUser = Depends(get_current_user),
    db: AsyncClient = Depends(get_db),
) -> ImageGenResponse:
    await _get_owned(recipe_id, user, db)
    image_bytes = await ai_service.generate_image(prompt=req.prompt, model=req.model)
    return ImageGenResponse(image_base64=base64.b64encode(image_bytes).decode())


@router.post("/{recipe_id}/speak")
async def speak_recipe(
    recipe_id: str,
    user: CurrentUser = Depends(get_current_user),
    db: AsyncClient = Depends(get_db),
) -> Response:
    recipe = await _get_owned(recipe_id, user, db)
    steps = recipe["dish"]["steps"]
    title = recipe["dish"]["title"]
    lines = [f"Recipe: {title}"]
    for s in steps:
        lines.append(f"Step {s['number']}: {s['instruction']}")
    if len(lines) == 1:
        raise HTTPException(status_code=400, detail="Recipe has no steps")
    settings = get_settings()
    audio = await ai_service.generate_speech("\n".join(lines), settings.tts_voice)
    return Response(content=audio, media_type="audio/mpeg")


@router.delete("/{recipe_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_recipe(
    recipe_id: str,
    user: CurrentUser = Depends(get_current_user),
    db: AsyncClient = Depends(get_db),
) -> None:
    await _get_owned(recipe_id, user, db)
    await db.table("recipes").delete().eq("id", recipe_id).eq("user_id", user.id).execute()
