"""User profile — auto-create on GET, partial update on PATCH."""
from fastapi import APIRouter, Depends, HTTPException, status
from supabase import AsyncClient

from auth import CurrentUser, get_current_user
from database import get_db
from models import ProfileResponse, ProfileUpdate

router = APIRouter(prefix="/profile", tags=["profile"])


async def _get_or_create(user: CurrentUser, db: AsyncClient) -> ProfileResponse:
    res = await db.table("user_profiles").select("*").eq("user_id", user.id).execute()
    if res.data:
        return ProfileResponse(**res.data[0])
    res = await db.table("user_profiles").insert({"user_id": user.id}).execute()
    return ProfileResponse(**res.data[0])


@router.get("", response_model=ProfileResponse)
async def get_profile(
    user: CurrentUser = Depends(get_current_user),
    db: AsyncClient = Depends(get_db),
) -> ProfileResponse:
    return await _get_or_create(user, db)


@router.patch("", response_model=ProfileResponse)
async def update_profile(
    req: ProfileUpdate,
    user: CurrentUser = Depends(get_current_user),
    db: AsyncClient = Depends(get_db),
) -> ProfileResponse:
    await _get_or_create(user, db)
    updates = req.model_dump(exclude_none=True)
    if not updates:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No fields to update")
    res = await db.table("user_profiles").update(updates).eq("user_id", user.id).execute()
    return ProfileResponse(**res.data[0])
