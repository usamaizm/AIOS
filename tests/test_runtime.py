from aios.runtime import Runtime


def test_emit_assigns_monotonic_ids_and_stores_events():
    runtime = Runtime()
    first = runtime.emit("task.created", task_id="a")
    second = runtime.emit("task.created", task_id="b")

    assert first.id == 1
    assert second.id == 2
    assert [e.data["task_id"] for e in runtime.events()] == ["a", "b"]


def test_handlers_receive_events():
    runtime = Runtime()
    seen = []
    runtime.on("task.created", seen.append)

    event = runtime.emit("task.created", task_id="a")

    assert seen == [event]


def test_event_filter_and_cursor():
    runtime = Runtime()
    runtime.emit("a")
    runtime.emit("b")
    runtime.emit("a")

    assert [e.id for e in runtime.events(event_type="a")] == [1, 3]
    assert [e.id for e in runtime.events(after_id=1)] == [2, 3]
