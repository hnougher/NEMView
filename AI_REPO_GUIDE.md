# AI Repo Guide

## Purpose
This repository contains PHP-based visualization code plus SQL definition exports for a PostgreSQL database (including TimescaleDB continuous aggregates/hypertables).

This guide tells an AI assistant how to correctly understand the repository layout and how to format generated SQL exports in `sql_defs/`.

## Privacy rule (no local WAN/local hostnames)
Do not mention or embed local/private hostnames or local WAN IPs in any file that will be committed to git.

It is acceptable to reference internal IPs and the public domain `nemview.hgn.id.au`.

## Repository layout (what to look at)
- `conf/`: Configuration files for the site.
- `gather/`: Shell scripts and crontab entries used to collect/process data.
- `html/`: Web UI entrypoints and visualization code.
- `logs/`: Runtime logs.
- `sql_defs/`: Exported SQL DDL used to define database objects.
  - `sql_defs/tables/`: `CREATE TABLE ...` exports for tables.
  - `sql_defs/functions/`: `CREATE OR REPLACE FUNCTION ...` exports for public SQL/plpgsql functions.
  - `sql_defs/triggers/`: `CREATE OR REPLACE FUNCTION ...` exports for trigger functions (i.e., functions with return type `trigger`).
  - `sql_defs/extensions/`: `CREATE EXTENSION ...` exports for required database extensions.
  - `sql_defs/views/`: `CREATE OR REPLACE VIEW ... AS ...` exports for normal views in schema `public`.
  - `sql_defs/materialized_views/`: `CREATE MATERIALIZED VIEW ... WITH (timescaledb.continuous) AS ...` exports for continuous aggregates.
  - `sql_defs/*` (other files): supporting SQL definitions.

## SQL export rules for `sql_defs/`
### File naming
- One SQL export per object.
- File name matches the object name, e.g.:
  - `sql_defs/tables/dispatch_regionsum.sql`  -> table `public.dispatch_regionsum`
  - `sql_defs/views/graph_dispatch_regionsum_simple.sql` -> view `public.graph_dispatch_regionsum_simple`
  - `sql_defs/materialized_views/dispatch_scada_summary.sql` -> materialized view `dispatch_scada_summary`
  - `sql_defs/functions/hn_duid_energy_source.sql` -> function `public.hn_duid_energy_source`
  - `sql_defs/triggers/hn_constraints_process.sql` -> trigger function `public.hn_constraints_process`
  - `sql_defs/extensions/timescaledb.sql` -> extension `timescaledb`

### Statement header
- Tables: `CREATE TABLE public.<table_name> ( ... );`
- Functions: `CREATE OR REPLACE FUNCTION public.<function_name>(...) ... ;`
- Trigger functions: same DDL form as functions, but the file should live under `sql_defs/triggers/`.
- Views: `CREATE OR REPLACE VIEW public.<view_name> AS ...;`
- Continuous aggregates: `CREATE MATERIALIZED VIEW <name> WITH (timescaledb.continuous) AS SELECT ...;`

### Formatting (pg_dump-like readability)
When editing or generating SQL, keep formatting stable and consistent:
- Use indentation inside `CREATE TABLE ... ( ... )` so every column/constraint line is aligned and readable.
- Keep `SELECT` columns in views split across multiple lines with one expression per line.
- Keep `UNION ALL` branches separated and clearly indented.
- Preserve quoting of identifiers exactly as they appear in the database (e.g. columns like "battery storage").
- End each top-level DDL statement with `;`.
- Prefer the same style already present in neighboring files within the same directory.

### TimescaleDB notes (materialized views)
For continuous aggregates, the export typically includes:
- The `CREATE MATERIALIZED VIEW ... WITH (timescaledb.continuous) AS SELECT ...` statement.
- Any follow-up configuration calls/selects/ALTER statements (chunk size, retention policy, continuous aggregate policy, refresh call).

## How to generate correct `views` exports (normal views)
To export normal views in schema `public`, an AI assistant should:
1. Query Postgres for all `relkind = 'v'` objects in `public`.
2. For each view, get its definition using `pg_get_viewdef(<oid>, true)`.
3. Write a file under `sql_defs/views/<view_name>.sql` with:
   - `CREATE OR REPLACE VIEW public.<view_name> AS <definition>;`
4. Ensure the output is non-empty and syntactically valid SQL.

## How to generate correct `tables` exports
To export tables under `sql_defs/tables/`, an AI assistant should:
- Ensure the export includes full column definitions (types and nullability) and any primary keys/constraints/defaults/indexes in whatever format the repository uses.
- Keep column/constraint indentation stable (pg_dump-like).

## How to validate
A quick validation checklist before considering exports “done”:
- The expected object names exist in the target schema (`public`).
- The generated SQL files are non-empty.
- Quoted identifiers remain quoted.
- `CREATE TABLE/VIEW/...` statements include the expected schema prefix (`public`) where appropriate.

## Scope
This guide is limited to helping with repository navigation and SQL export formatting. It does not define the business logic in `html/` or the data collection logic in `gather/`.
