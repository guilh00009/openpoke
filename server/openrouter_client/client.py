from __future__ import annotations

import json
from typing import Any, Dict, List, Optional

import httpx

from ..config import get_settings


class OpenAIError(RuntimeError):
    """Raised when the API returns an error response."""


def _headers(*, api_key: Optional[str] = None) -> Dict[str, str]:
    settings = get_settings()
    key = (api_key or settings.api_key or "").strip()
    if not key:
        raise OpenAIError("Missing API key")

    headers = {
        "Authorization": f"Bearer {key}",
        "Content-Type": "application/json",
    }

    return headers


def _build_messages(messages: List[Dict[str, str]], system: Optional[str]) -> List[Dict[str, str]]:
    if system:
        return [{"role": "system", "content": system}, *messages]
    return messages


def _handle_response_error(exc: httpx.HTTPStatusError) -> None:
    response = exc.response
    detail: str
    try:
        payload = response.json()
        # Handle OpenAI API error format
        if "error" in payload:
            error_info = payload["error"]
            if isinstance(error_info, dict):
                detail = error_info.get("message", str(error_info))
            else:
                detail = str(error_info)
        else:
            detail = payload.get("message") or json.dumps(payload)
    except Exception:
        detail = response.text
    raise OpenAIError(f"API request failed ({response.status_code}): {detail}") from exc


async def request_chat_completion(
    *,
    model: str,
    messages: List[Dict[str, str]],
    system: Optional[str] = None,
    api_key: Optional[str] = None,
    tools: Optional[List[Dict[str, Any]]] = None,
    base_url: Optional[str] = None,
) -> Dict[str, Any]:
    """Request a chat completion and return the raw JSON payload."""

    settings = get_settings()
    base_url = base_url or settings.api_base_url

    payload: Dict[str, object] = {
        "model": model,
        "messages": _build_messages(messages, system),
        "stream": False,
    }
    if tools:
        payload["tools"] = tools

    url = f"{base_url.rstrip('/')}/chat/completions"

    async with httpx.AsyncClient() as client:
        try:
            response = await client.post(
                url,
                headers=_headers(api_key=api_key),
                json=payload,
                timeout=60.0,  # Set reasonable timeout instead of None
            )
            try:
                response.raise_for_status()
            except httpx.HTTPStatusError as exc:
                _handle_response_error(exc)
            return response.json()
        except httpx.HTTPStatusError as exc:  # pragma: no cover - handled above
            _handle_response_error(exc)
        except httpx.HTTPError as exc:
            raise OpenAIError(f"API request failed: {exc}") from exc

    raise OpenAIError("API request failed: unknown error")


__all__ = ["OpenAIError", "request_chat_completion"]
