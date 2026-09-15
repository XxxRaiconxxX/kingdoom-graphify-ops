# Kingdoom Agent Protocol - kingdoom-graphify-ops

Este documento define las reglas para cualquier agente de IA que trabaje en este repositorio.

## 0. Alcance de este repo

Dominio operaciones Graphify: scripts, templates, reglas y workflows compartidos para instalar y mantener Graphify en los repos Kingdoom.

REGLA DE CARRIL: trabajar exclusivamente en `kingdoom-graphify-ops` salvo pedido explicito. No modificar los repos gestionados (`Kingdoom`, `kingdoom-bot`, `kingdoom-fichas`, `kingdoom-library`) desde aqui sin una orden concreta.

Repos gestionados:
- `Kingdoom` / `Kingdoom-sync`: portal web SPA, economia y panel admin.
- `kingdoom-bot`: bot WhatsApp, minijuegos y economia.
- `kingdoom-fichas`: gestion de fichas RPG.
- `kingdoom-library`: codice digital, lore y distribucion de APKs.

## 1. Protocolo Operativo Kingdoom Compartido

- Session Bootstrap Silencioso: leer `AGENTS.md` y contexto necesario en silencio; ejecutar directo sin saludos vacios ni "contexto cargado".
- GraphRAG-First: si existe `graphify-out/graph.json`, usar `graphify query`, `graphify path`, `graphify explain` o `graphify affected` antes de inspecciones masivas o cambios en modulos compartidos.
- Push & Deploy Honesty: no reportar push, deploy o release como exitoso sin ejecutar el comando real, leer la salida completa y confirmar codigo de salida 0.
- Report Discipline: responder con un unico reporte cerrado de la tarea actual, sin acumular reportes previos.
- Seguridad: no hardcodear secretos ni credenciales; no loguear PII; no modificar `.env` reales salvo instruccion explicita.
- Dependencias y artefactos: no modificar ni commitear `package-lock.json`, `graphify-out/`, `.codex/hooks.json` u otros artefactos locales/ignorados salvo pedido explicito.
- Calidad verificable: antes de declarar una tarea completa, ejecutar las validaciones reales del repo y reportar comandos y resultados.
- Diagnostico Forense y Validacion DDL: prohibido adivinar; ante errores de produccion consultar logs reales (Postgres via get_logs) y auditar CHECK constraints, rangos y tipos en Supabase; realizar pruebas de limites (min y max) antes de considerar resuelta la tarea.

## 1.1 Entorno Windows, Supabase y Git

- PowerShell Windows: en Windows PowerShell 5.1, `&&` puede fallar; usar `;` o `if ($?) { ... }` para encadenar comandos.
- Encoding: antes de leer/escribir texto sensible a acentos, forzar UTF-8 con `$OutputEncoding = [Console]::OutputEncoding = [Text.Encoding]::UTF8`.
- Rutas Windows: envolver rutas con espacios o variables entre comillas dobles, por ejemplo `"C:\Ruta Con Espacios\..."`.
- Scripts `.ps1`: si la politica de ejecucion bloquea un script, usar `-ExecutionPolicy Bypass` solo para el comando necesario.
- Supabase historico: `character_sheets` usa `playerId`; `player_inventory` usa `player_id`; `players` usa `id` UUID y `phone` como JID de WhatsApp.
- Items financiados: las compras a cuotas entran a `player_inventory` con `is_locked = true` y se desbloquean solo al saldar la ultima cuota en `payment_plans`.
- Git estricto: cero `git add .` a ciegas; stagear solo archivos especificos de la tarea mas trazabilidad (`AI_CHANGELOG.md`/memoria) cuando aplique.
- Remotos: verificar siempre `git remote -v` antes de push; `kingdoom-bot` puede tener `origin` y `space`.
- Node ESM en `kingdoom-bot`: usar `import`/`export`, nunca `require`; todo import relativo debe incluir extension `.js`.
- Memoria entre agentes: para relevos de Antigravity/Jules en Kingdoom-sync, revisar `ai-memory/kingdoom-memory.jsonl` o usar MCP `project_brief` / `latest_memory` si esta disponible.

## 2. Reglas Graphify Ops

- `graphify-out/` permanece local en cada repo gestionado y no se versiona desde este repo.
- `.codex/hooks.json` es local por repo y no debe convertirse en contrato publico.
- Los templates y scripts de este repo pueden propagarse con `scripts/apply-to-repo.ps1` o `scripts/apply-kingdoom-suite.ps1`, pero solo tras revisar el diff generado.
- Antes de cambiar templates compartidos, verificar impacto en todos los perfiles afectados (`bot`, `sync`, `fichas`, `library`).
- Si un comando de propagacion modifica repos gestionados, reportar cada archivo tocado por repo.

## 3. Validacion

- Para cambios en scripts PowerShell, ejecutar el script con parametros seguros o modo dry-run si existe.
- Para cambios de templates, comparar salida antes/despues en al menos un repo objetivo.
- Ejecutar `git status -s` antes y despues de la tarea.
