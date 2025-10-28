# K3s Quick Manager

A script to install or uninstall **k3s** (Lightweight Kubernetes).

---

## ⚡ Quick Start

1.  **Save the script** (e.g., as `k3s_manager.sh`).
2.  **Make it executable**:
    ```bash
    chmod +x k3s_manager.sh
    ```
3.  **Run it**:
    ```bash
    ./k3s_manager.sh
    ```

---

## Instructions

### Install (`install`)

1.  Downloads and installs k3s via the official script.
2.  **Automatically configures `kubectl`** for the user:
    * Copies the config file to `~/.kube/config`.
    * Sets correct permissions so user **don't need `sudo`** for `kubectl`.
    * Adds `export KUBECONFIG=...` to the `~/.bashrc`.

> **Post-Install:** Run `source ~/.bashrc` in the current terminal to make `kubectl` work immediately.

### 🔴 Uninstall (`uninstall`)

* Executes the official k3s uninstall script (`/usr/local/bin/k3s-uninstall.sh`).