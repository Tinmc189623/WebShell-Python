# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [v0.1.0] – 2026-08-29

### Added

- **Interactive Shell** – Full-featured terminal via WebSocket (xterm.js), supports `vim`, `top`, `cd`, and all interactive commands.
- **File Browser** – Browse server filesystem with directory navigation.
- **Log Viewer** – Load any text log file by path, view content in a monospace panel.
- **System Dashboard** – Real‑time CPU, memory, disk usage, and uptime display.
- **Process List** – Show all running processes with PID, name, and CPU%.
- **Modular architecture** – Flask blueprint‑based routing, split into separate Python modules (`routes/`).
- **Template inheritance** – Base layout (`base.html`) with extendable card components.
- **One‑click deployment** – `start.sh` script that installs `uv`, generates files, installs dependencies, and starts the service in background.
- **Dependency management** – Uses `uv` for fast, isolated Python environment.
- **Dark‑theme UI** – Styled with Bootstrap 5 and FontAwesome for modern look.

### Security

- No authentication built‑in – intended for internal network use only.
- Added warning in README about exposing to public internet.

---

## [Unreleased]

### Planned

- **Authentication** – Basic username/password or token‑based login.
- **File upload/download** – Upload files via drag‑and‑drop, download selected files.
- **Real‑time log tailing** – Stream log updates via WebSocket.
- **Search in logs** – Filter lines by keyword.
- **Process kill** – Terminate processes from the UI.
- **Docker deployment** – Provide a Dockerfile for containerized usage.
- **HTTPS support** – Generate self‑signed certificate or Let's Encrypt integration.

---

## Legend

- `Added` – New features.
- `Changed` – Changes in existing functionality.
- `Deprecated` – Soon‑to‑be removed features.
- `Removed` – Removed features.
- `Fixed` – Bug fixes.
- `Security` – Security improvements.

---

[v0.1.0]: https://github.com/Tinmc189623/WebShell-Python
[Unreleased]: https://github.com/Tinmc189623/WebShell-Python
