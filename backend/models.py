"""Pydantic v2 schemas: request inputs, strict AI output, and persistence DTOs."""
from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field


class RecipeRequest(BaseModel):
    ingredients: list[str] = Field(default_factory=list, description="Ingredients on hand, if typed")
    ingredient_image_base64: str | None = Field(
        None, description="Base64 photo of a fridge/pantry"
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


# ---------- Image generation ----------

class ImageGenRequest(BaseModel):
    prompt: str = Field(..., description="Text prompt for image generation")
    model: str = Field("@cf/black-forest-labs/flux-1-schnell", description="Cloudflare Workers AI model ID")


class ImageGenResponse(BaseModel):
    image_base64: str = Field(..., description="Base64-encoded PNG image")


# ---------- Profile ----------


class ProfileUpdate(BaseModel):
    name: str | None = None
    dietary_pref: bool | None = None
    meal_planning_pref: bool | None = None
    notifications_pref: bool | None = None
    dark_mode: bool | None = None


class ProfileResponse(BaseModel):
    id: str
    user_id: str
    name: str
    dietary_pref: bool
    meal_planning_pref: bool
    notifications_pref: bool
    dark_mode: bool
    xp: int
    level: int
    created_at: datetime


# ---------- Shopping list ----------


class ShoppingItemCreate(BaseModel):
    name: str
    quantity: str = ""
    category: str = ""


class ShoppingItemUpdate(BaseModel):
    name: str | None = None
    quantity: str | None = None
    category: str | None = None
    checked: bool | None = None


class ShoppingItemResponse(BaseModel):
    id: str
    user_id: str
    name: str
    quantity: str
    category: str
    checked: bool
    created_at: datetime


# ---------- Pantry ----------


class PantryItemCreate(BaseModel):
    name: str
    quantity: str = ""
    unit: str = ""


class PantryItemUpdate(BaseModel):
    quantity: str | None = None
    unit: str | None = None


class PantryItemResponse(BaseModel):
    id: str
    user_id: str
    name: str
    quantity: str
    unit: str
    created_at: datetime


SaveRecipeRequest.model_rebuild()
