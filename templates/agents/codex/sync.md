## graphify

This project has a knowledge graph at graphify-out/ with god nodes, community structure, and cross-file relationships.

When the user types `/graphify`, use the installed graphify skill or instructions before doing anything else.

Local operational paths:
- `graphify-out/` stays in the project root because Graphify, Codex, and Antigravity all look for `graphify-out/graph.json` there. It is local and ignored by Git.
- `.codex/hooks.json` is local and ignored by Git. Refresh it with `npm run graphify:setup`.

Rules:
- For codebase questions, first run `graphify query "<question>"` when `graphify-out/graph.json` exists. Use `graphify path "<A>" "<B>"` for relationships and `graphify explain "<concept>"` for focused concepts. These return a scoped subgraph, usually much smaller than `GRAPH_REPORT.md` or raw grep output.
- Before modifying shared functions, utils, types, or schema-facing helpers, run `graphify affected "<symbol_or_file>"` to map regressions before editing.
- Use the global graph merge (`graphify global list` / `graphify global path`) to trace contracts that cross the boundary between `Kingdoom-sync`, `kingdoom-bot`, and `kingdoom-fichas`.
- For documenting complex transaction flows or state movement, prefer `graphify export callflow-html` or `graphify tree`.
- Run `npm run graphify:setup` once per clone or when hooks and local Graphify wiring need repair.
- Run `npm run graphify:update` after structural code changes that are still uncommitted, or before asking Graphify-heavy architecture questions during an active edit session.
- Run `npm run graphify:doctor` when another AI agent reports stale graph answers, missing hooks, or missing local Graphify state.
- Dirty `graphify-out/` files are expected after hooks or incremental updates; dirty graph files are not a reason to skip Graphify. Only skip Graphify if the task is about stale or incorrect graph output, or the user explicitly says not to use it.
- If `graphify-out/wiki/index.md` exists, use it for broad navigation instead of raw source browsing.
- Read `graphify-out/GRAPH_REPORT.md` only for broad architecture review or when query/path/explain do not surface enough context.
- After modifying code, prefer `npm run graphify:update` over raw CLI calls so Codex hooks and repo conventions stay aligned.
