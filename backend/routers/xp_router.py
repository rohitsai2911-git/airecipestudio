"""XP + leveling. XP is incremented via an atomic Postgres RPC."""
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
        profile = await db.table("user_profiles").select("xp, level").eq("user_id", user.id).execute()
        row = profile.data[0]
        return CompletionResult(recipe_id=req.recipe_id, xp=row["xp"], level=row["level"], xp_awarded=0)

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
