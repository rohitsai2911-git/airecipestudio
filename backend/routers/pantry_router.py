"""Pantry-items CRUD — each row scoped to the caller."""
from fastapi import APIRouter, Depends, HTTPException, status
from supabase import AsyncClient

from auth import CurrentUser, get_current_user
from database import get_db
from models import PantryItemCreate, PantryItemResponse, PantryItemUpdate

router = APIRouter(prefix="/pantry", tags=["pantry"])


@router.get("", response_model=list[PantryItemResponse])
async def list_items(
    user: CurrentUser = Depends(get_current_user),
    db: AsyncClient = Depends(get_db),
) -> list[PantryItemResponse]:
    res = await db.table("pantry_items").select("*").eq("user_id", user.id).order("name").execute()
    return [PantryItemResponse(**row) for row in res.data]


@router.post("", response_model=PantryItemResponse, status_code=status.HTTP_201_CREATED)
async def create_item(
    req: PantryItemCreate,
    user: CurrentUser = Depends(get_current_user),
    db: AsyncClient = Depends(get_db),
) -> PantryItemResponse:
    res = await db.table("pantry_items").insert({
        "user_id": user.id, "name": req.name,
        "quantity": req.quantity, "unit": req.unit,
    }).execute()
    return PantryItemResponse(**res.data[0])


@router.patch("/{item_id}", response_model=PantryItemResponse)
async def update_item(
    item_id: str,
    req: PantryItemUpdate,
    user: CurrentUser = Depends(get_current_user),
    db: AsyncClient = Depends(get_db),
) -> PantryItemResponse:
    updates = req.model_dump(exclude_none=True)
    if not updates:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No fields to update")
    res = await db.table("pantry_items").update(updates).eq("id", item_id).eq("user_id", user.id).execute()
    if not res.data:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Item not found")
    return PantryItemResponse(**res.data[0])


@router.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_item(
    item_id: str,
    user: CurrentUser = Depends(get_current_user),
    db: AsyncClient = Depends(get_db),
) -> None:
    res = await db.table("pantry_items").delete().eq("id", item_id).eq("user_id", user.id).execute()
    if not res.data:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Item not found")
