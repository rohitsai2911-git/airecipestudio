"""Single async Supabase client, created once and injected via Depends."""
from supabase import AsyncClient, acreate_client

from config import get_settings

_client: AsyncClient | None = None


async def init_db() -> None:
    global _client
    settings = get_settings()
    _client = await acreate_client(settings.supabase_url, settings.supabase_key)


async def get_db() -> AsyncClient:
    if _client is None:
        await init_db()
    assert _client is not None
    return _client
