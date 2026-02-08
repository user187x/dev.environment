<div align="center">

# ⚡ dev.environment
**Automated. Safe. Modular.**

[![Language](https://img.shields.io/badge/language-bash-4EAA25?style=for-the-badge&logo=gnu-bash)](https://www.gnu.org/software/bash/)
[![Tmux](https://img.shields.io/badge/Multiplexer-tmux-1BB91F?style=for-the-badge&logo=tmux)](https://github.com/tmux/tmux)
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)

<p align="center">
  <a href="#-features">Features</a> •
  <a href="#-installation">Installation</a> •
  <a href="#-workflow-logic">Workflow</a> •
  <a href="#-safety-mechanisms">Safety</a>
</p>

</div>

---

## 📖 Overview

This repository hosts a robust bootstrapping script designed to initialize a developer environment in seconds. It configures **Bash** (aliases, functions) and **Tmux** (plugins, themes) while ensuring no data is lost during the process.

Unlike standard dotfile installers, this script prioritizes **safety** and **state recovery** via automated backups and dry-run capabilities.

---

## 🌟 Features

| Feature | Description |
| :--- | :--- |
| **🛡️ Safe Execution** | Runs with `set -uo pipefail` to catch errors early. Creates timestamps backups of all replaced files. |
| **🧪 Dry Run Mode** | Simulate the entire installation without touching a single file using `--dry-run`. |
| **🧩 Modular Bash** | Splits configuration into `.bashrc`, `.bashrc_aliases`, and `.bashrc_functions` for maintainability. |
| **🔌 Tmux Auto-Heal** | Automatically installs TPM (Tmux Plugin Manager), fixes permissions, and clears cache issues (Dracula theme). |
| **🔤 Font Mgmt** | Installs patched NerdFonts to `~/.local/share/fonts` and rebuilds the `fc-cache`. |

---

## ⚡ Installation

### Prerequisites
The script checks for the following dependencies before running:
* `git`
* `tmux`
* `tar` (for backups)
* `fc-cache` (fontconfig)

### 1. Standard Install
This will backup your current config, symlink new files, and launch Tmux.

```bash
./run.sh
