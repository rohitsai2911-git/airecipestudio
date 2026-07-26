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
