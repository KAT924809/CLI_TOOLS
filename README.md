![Version](https://img.shields.io/badge/version-0.1-blue)
![Bash](https://img.shields.io/badge/Bash-5%2B-green)
![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20WSL-orange)
![License](https://img.shields.io/badge/license-MIT-lightgrey)
![Status](https://img.shields.io/badge/status-active-success)

A modular **Terminal UI (TUI) utility suite** built entirely in **Bash**.

This project provides powerful document, image, and file manipulation tools in a clean arrow-key driven terminal interface — no GUI, no cloud APIs, fully offline. 
Meant for people with high privacy focus

---
This Project Runs Natively on Linux. 
On WINDOWS, you must use **WSL (WINDOWS SUBSYSTEM FOR LINUX)**

###
STEP 1 — Install WSL
Open PowerShell as Administrator:
```powershell
wsl --install
```
STEP 2 - Open Ubuntu (WSL)
```wsl
sudo apt update && sudo apt upgrade -y
```
STEP 3 - Install Required Dependencies
```wsl
sudo apt install \
    imagemagick \
    ghostscript \
    libreoffice \
    qpdf \
    poppler-utils -y
``` 
STEP 4 - Clone the Repository 
```wsl
git clone https://github.com/KAT924809/CLI_TOOLS.git
cd CLI_TOOLS
chmod +x img-tui.sh
```

STEP 5 - Run It 
```wsl
./img-tui.sh
```
