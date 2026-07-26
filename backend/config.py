from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    openai_api_key: str
    openai_base_url: str = "https://api.groq.com/openai/v1"

    vision_api_key: str = ""
    vision_base_url: str = ""

    zen_api_key: str = ""
    zen_base_url: str = "https://opencode.ai/zen/v1"
    zen_models: str = "deepseek-v4-flash-free,north-mini-code-free,nemotron-3-ultra-free,laguna-s-2.1-free"

    supabase_url: str
    supabase_key: str
    supabase_jwt_secret: str

    model_id: str = "llama-3.3-70b-versatile"
    model_fallbacks: str = "llama-3.1-8b-instant,openai/gpt-oss-120b,openai/gpt-oss-20b,groq/compound"

    vision_model_id: str = "google/gemini-2.5-flash-image"
    vision_model_fallbacks: str = "google/gemini-3.1-flash-image,google/gemini-3-pro-image"

    tts_voice: str = "en-US-JennyNeural"

    gemini_api_key: str = ""

    cf_account_id: str = ""
    cf_api_token: str = ""

    xp_per_completion: int = 50
    cors_origins: str = "*"

    @property
    def model_fallback_list(self) -> list[str]:
        return [m.strip() for m in self.model_fallbacks.split(",") if m.strip()]

    @property
    def vision_model_fallback_list(self) -> list[str]:
        return [m.strip() for m in self.vision_model_fallbacks.split(",") if m.strip()]

    @property
    def zen_model_list(self) -> list[str]:
        return [m.strip() for m in self.zen_models.split(",") if m.strip()]

    @property
    def cors_origins_list(self) -> list[str]:
        if self.cors_origins.strip() == "*":
            return ["*"]
        return [o.strip() for o in self.cors_origins.split(",") if o.strip()]


@lru_cache
def get_settings() -> Settings:
    return Settings()
