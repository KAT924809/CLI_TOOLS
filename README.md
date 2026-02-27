![Version](https://img.shields.io/badge/version-0.1-blue)
![Bash](https://img.shields.io/badge/Bash-5%2B-green)
![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20WSL-orange)
![License](https://img.shields.io/badge/license-MIT-lightgrey)
![Status](https://img.shields.io/badge/status-active-success)
# CLI Tools

**A modular Terminal UI (TUI) utility suite built entirely in Bash.**
While each tool in this suite could be executed manually via individual CLI commands, this project consolidates them into a unified, discoverable interface. It eliminates the need to memorize flags, reduces command errors, and provides a consistent workflow for document and image operations.

Fully offline. Fully modular. Built for terminal-first users.
---

## Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [Installation — Linux (Native)](#installation--linux-native)
- [Installation — Windows via WSL](#installation--windows-via-wsl)
- [Accessing Windows Files from WSL](#accessing-windows-files-from-wsl)
- [Running the Tool](#running-the-tool)
- [Performance Tips](#performance-tips)
- [Known Limitations](#known-limitations)
- [Troubleshooting](#troubleshooting)

---

## Overview

CLI Tools is a self-contained Bash application that runs entirely in the terminal. It is built for users who need reliable, offline document and image processing without relying on external services or graphical applications.

**Key characteristics:**

- Arrow-key driven terminal interface (no mouse required)
- Entirely offline — no network access needed
- Modular design — tools are independent and composable
- Requires a real Linux environment (native or WSL2 on Windows)

---

## Requirements

| Dependency       | Purpose                          |
|-----------------|----------------------------------|
| `imagemagick`    | Image conversion and manipulation |
| `ghostscript`    | PostScript and PDF rendering      |
| `libreoffice`    | Document format conversion        |
| `qpdf`           | PDF transformation and repair     |
| `poppler-utils`  | PDF text extraction and utilities |
| `bash 5+`        | Shell runtime                     |

---

## Installation — Linux (Native)

**Step 1 — Install dependencies**

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install imagemagick ghostscript libreoffice qpdf poppler-utils -y
```

**Step 2 — Clone the repository**

```bash
git clone https://github.com/KAT924809/CLI_TOOLS.git
cd CLI_TOOLS
chmod +x img-tui.sh
```

**Step 3 — Run the tool**

```bash
./img-tui.sh
```

---

## Installation — Windows via WSL

This project requires a real Linux environment. On Windows, use **WSL2 (Windows Subsystem for Linux)**.

**Step 1 — Install WSL**

Open PowerShell as Administrator and run:

```powershell
wsl --install
```

Restart your machine when prompted.

**Step 2 — Open Ubuntu and update packages**

```bash
sudo apt update && sudo apt upgrade -y
```

**Step 3 — Install required dependencies**

```bash
sudo apt install imagemagick ghostscript libreoffice qpdf poppler-utils -y
```

**Step 4 — Clone the repository**

It is strongly recommended to clone inside the WSL home directory for best performance:

```bash
cd ~
git clone https://github.com/KAT924809/CLI_TOOLS.git
cd CLI_TOOLS
chmod +x img-tui.sh
```

**Step 5 — Run the tool**

```bash
./img-tui.sh
```

---

## Accessing Windows Files from WSL

Windows drives are mounted inside WSL under `/mnt`. Use Linux-style paths when referencing files within the tool.

| Windows Path                              | WSL Equivalent Path                        |
|-------------------------------------------|--------------------------------------------|
| `C:\Users\YourName\Documents`             | `/mnt/c/Users/YourName/Documents`          |
| `C:\Users\YourName\Desktop\file.pdf`      | `/mnt/c/Users/YourName/Desktop/file.pdf`   |

---

## Running the Tool

```bash
./img-tui.sh
```

Navigate the interface using the arrow keys. No additional arguments are required to launch.

---

## Performance Tips

- Clone and run the tool from inside the WSL home directory (`~/`) rather than from a Windows-mounted path such as `/mnt/c/...`. File I/O across the WSL boundary is significantly slower.
- Use WSL2, not WSL1. WSL2 provides a full Linux kernel and substantially better performance.

**To check your WSL version**, open PowerShell and run:

```powershell
wsl -l -v
```

**To upgrade from WSL1 to WSL2:**

```powershell
wsl --set-version Ubuntu 2
```

---

## Known Limitations

The following environments are **not supported**:

- Windows Command Prompt (CMD)
- PowerShell (without WSL)
- Git Bash

The tool requires a full Linux environment. Native Linux and WSL2 are the only supported runtimes.

> **Note:** The first time LibreOffice performs a conversion, it may take longer than expected due to initial user profile setup. Subsequent operations will be faster.

---

## Troubleshooting

**LibreOffice conversion is very slow on first run**
This is expected. LibreOffice initializes a user profile on its first execution. Subsequent conversions will complete at normal speed.

**Command not found errors**
Verify that all dependencies are installed:

```bash
for cmd in convert gs libreoffice qpdf pdfinfo; do
  command -v "$cmd" && echo "$cmd: OK" || echo "$cmd: NOT FOUND"
done
```

**Permission denied when running the script**
Ensure the script has execute permissions:

```bash
chmod +x img-tui.sh
```

**WSL version is 1 and performance is poor**
Upgrade to WSL2 using the instructions in the [Performance Tips](#performance-tips) section.

---

## License

This project is licensed under the [MIT License](LICENSE).
