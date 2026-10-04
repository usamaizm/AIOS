from __future__ import annotations

import argparse
import json

from .runtime import Runtime


def main() -> None:
    parser = argparse.ArgumentParser(description="AIOS runtime")
    parser.add_argument("event", nargs="?", help="event type to emit")
    parser.add_argument("--data", default="{}", help="JSON event data")
    args = parser.parse_args()

    if not args.event:
        parser.print_help()
        return

    data = json.loads(args.data)
    if not isinstance(data, dict):
        parser.error("--data must be a JSON object")

    runtime = Runtime()
    event = runtime.emit(args.event, **data)
    print(json.dumps({"id": event.id, "type": event.type, "data": event.data}))
