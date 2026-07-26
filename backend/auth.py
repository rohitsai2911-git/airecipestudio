"""Verify Supabase-issued JWTs via the Auth REST API."""
import httpx
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from config import get_settings

_bearer = HTTPBearer(auto_error=True)


class CurrentUser:
    def __init__(self, user_id: str, email: str | None, claims: dict):
        self.id = user_id
        self.email = email
        self.claims = claims


async def get_current_user(
    creds: HTTPAuthorizationCredentials = Depends(_bearer),
    settings = Depends(get_settings),
) -> CurrentUser:
    async with httpx.AsyncClient() as client:
        resp = await client.get(
            f"{settings.supabase_url}/auth/v1/user",
            headers={
                "apikey": settings.supabase_key,
                "Authorization": f"Bearer {creds.credentials}",
            },
        )
    if resp.status_code != 200:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    data = resp.json()
    return CurrentUser(
        user_id=data["id"],
        email=data.get("email"),
        claims=data,
    )
