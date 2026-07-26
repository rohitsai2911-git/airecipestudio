from contextlib import asynccontextmanager

import httpx
from fastapi import FastAPI, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from config import get_settings
from database import init_db
from routers import chat_router, library_router, meal_plan_router, xp_router, profile_router, shopping_list_router, pantry_router


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
app.include_router(profile_router.router)
app.include_router(shopping_list_router.router)
app.include_router(pantry_router.router)


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
