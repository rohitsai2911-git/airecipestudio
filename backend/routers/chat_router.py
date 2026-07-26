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
