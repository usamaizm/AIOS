# AIOS

Artificial Intelligence Operating System project.

AIOS is a deliberately small runtime foundation for AI systems. The core provides
an event contract and deterministic in-process dispatch without requiring a model
provider, cloud service, database, or agent framework.

## Quick start

```bash
python -m pip install -e .
aios task.created --data '{"task_id":"demo"}'
```

## Design boundary

AIOS owns runtime coordination primitives. Persistent memory/data belongs in AIDB;
economic accounting belongs in TokenCoin. Integrations should remain adapters rather
than hard dependencies.

## Development

```bash
python -m pytest
```

Licensed under Apache-2.0.
