"""Shopping-list CRUD — each row scoped to the caller."""
from fastapi import APIRouter, Depends, HTTPException, status
from supabase import AsyncClient

from auth import CurrentUser, get_current_user
from database import get_db
from models import ShoppingItemCreate, ShoppingItemResponse, ShoppingItemUpdate

router = APIRouter(prefix="/shopping-list", tags=["shopping-list"])


@router.get("", response_model=list[ShoppingItemResponse])
async def list_items(
    user: CurrentUser = Depends(get_current_user),
    db: AsyncClient = Depends(get_db),
) -> list[ShoppingItemResponse]:
    res = await db.table("shopping_list").select("*").eq("user_id", user.id).order("created_at").execute()
    return [ShoppingItemResponse(**row) for row in res.data]


@router.post("", response_model=ShoppingItemResponse, status_code=status.HTTP_201_CREATED)
async def create_item(
    req: ShoppingItemCreate,
    user: CurrentUser = Depends(get_current_user),
    db: AsyncClient = Depends(get_db),
) -> ShoppingItemResponse:
    res = await db.table("shopping_list").insert({
        "user_id": user.id, "name": req.name,
        "quantity": req.quantity, "category": req.category,
    }).execute()
    return ShoppingItemResponse(**res.data[0])


@router.patch("/{item_id}", response_model=ShoppingItemResponse)
async def update_item(
    item_id: str,
    req: ShoppingItemUpdate,
    user: CurrentUser = Depends(get_current_user),
    db: AsyncClient = Depends(get_db),
) -> ShoppingItemResponse:
    updates = req.model_dump(exclude_none=True)
    if not updates:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No fields to update")
    res = await db.table("shopping_list").update(updates).eq("id", item_id).eq("user_id", user.id).execute()
    if not res.data:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Item not found")
    return ShoppingItemResponse(**res.data[0])


@router.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_item(
    item_id: str,
    user: CurrentUser = Depends(get_current_user),
    db: AsyncClient = Depends(get_db),
) -> None:
    res = await db.table("shopping_list").delete().eq("id", item_id).eq("user_id", user.id).execute()
    if not res.data:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Item not found")
