from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any, Callable


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


@dataclass
class Event:
    type: str
    data: dict[str, Any] = field(default_factory=dict)
    id: int | None = None
    created_at: str = field(default_factory=utc_now)


class Runtime:
    """Deterministic in-process event runtime.

    AIOS deliberately does not require a model provider, network, or database.
    Adapters can build on the small event/handler contract.
    """

    def __init__(self) -> None:
        self._handlers: dict[str, list[Callable[[Event], Any]]] = {}
        self._events: list[Event] = []
        self._next_id = 1

    def on(self, event_type: str, handler: Callable[[Event], Any]) -> Callable[[Event], Any]:
        self._handlers.setdefault(event_type, []).append(handler)
        return handler

    def emit(self, event_type: str, **data: Any) -> Event:
        event = Event(event_type, data, self._next_id)
        self._next_id += 1
        self._events.append(event)
        for handler in tuple(self._handlers.get(event_type, ())):
            handler(event)
        return event

    def events(self, *, event_type: str | None = None, after_id: int = 0) -> list[Event]:
        return [
            e for e in self._events
            if e.id is not None and e.id > after_id
            and (event_type is None or e.type == event_type)
        ]
