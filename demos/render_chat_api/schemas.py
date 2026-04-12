"""Pydantic models for OpenAI-shaped chat completions (Flutter-compatible)."""

from __future__ import annotations

from typing import Any, Literal, Optional

from pydantic import BaseModel, Field, field_validator


class ChatMessage(BaseModel):
    role: Literal["system", "user", "assistant"]
    content: str


class ChatCompletionRequest(BaseModel):
    model: str
    messages: list[ChatMessage]
    stream: bool = False

    @field_validator("messages")
    @classmethod
    def cap_messages(cls, v: list[ChatMessage]) -> list[ChatMessage]:
        if len(v) > 32:
            raise ValueError("too_many_messages")
        return v


class ErrorBody(BaseModel):
    code: str
    message: str
    request_id: Optional[str] = None
    retryable: bool = False


class AssistantMessage(BaseModel):
    role: Literal["assistant"] = "assistant"
    content: str


class Choice(BaseModel):
    index: int = 0
    message: AssistantMessage
    finish_reason: str = "stop"


class ChatCompletionSuccess(BaseModel):
    id: str
    object: Literal["chat.completion"] = "chat.completion"
    created: int
    model: str
    choices: list[Choice]

    def model_dump_compat(self) -> dict[str, Any]:
        return self.model_dump()


def stable_openai_response(
    *,
    request_id: str,
    created_ts: int,
    resolved_model: str,
    assistant_text: str,
) -> dict[str, Any]:
    payload = ChatCompletionSuccess(
        id=f"chatcmpl-{request_id[:12]}",
        created=created_ts,
        model=resolved_model,
        choices=[
            Choice(
                message=AssistantMessage(content=assistant_text),
            ),
        ],
    )
    return payload.model_dump()
