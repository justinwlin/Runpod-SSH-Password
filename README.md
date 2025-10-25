# RunPod SSH Password Setup & File Transfer Tools

Simple tools for transferring files between RunPod instances using rsync when you need to migrate data (e.g., when your pod gets stuck with zero GPUs).

## Prerequisites

Before using these tools, make sure:

1. **You can run terminal commands** on your RunPod instances:
   - Use the **Web Terminal** in RunPod's interface, OR
   - Use a **terminal in Jupyter Notebook/Lab**
   - **These tools will NOT work** if you can only access a graphical interface

2. **TCP Port 22 is exposed** on your destination pod:
   - Go to your pod settings: **Pod > Edit > TCP Ports**
   - Add port **22** to the list if it's not already there
   - This allows SSH connections from other pods

3. **Linux-based RunPod template**: These tools work on Ubuntu/Debian-based images that support `apt-get` (most RunPod templates)

4. **Network connectivity**: Your pods must be able to reach each other over the internet

---

## SSH Password Setup

Sets up password-based SSH access on your RunPod instance for the current user.

### Usage
```bash
wget https://raw.githubusercontent.com/justinwlin/Runpod-SSH-Password/main/passwordrunpod.sh && chmod +x passwordrunpod.sh && ./passwordrunpod.sh
```

### What it does
1. Installs SSH server if not present
2. Detects current user (supports both root and non-root users)
3. Checks if password already exists and prompts to keep or replace
4. Enables password authentication for SSH
5. Creates connection scripts with rsync examples in `/workspace/`

**Features:**
- **User detection**: Automatically works with current user (no root assumption)
- **Password preservation**: Won't overwrite existing passwords unless you choose to
- **rsync examples**: Connection scripts include rsync commands for efficient transfers

**Example Output:**
```
Detected user: root
Password already exists for user root
Do you want to:
  1) Keep existing password (just enable SSH)
  2) Set a new password (will replace existing)
Enter choice (1/2): 1

Setup Completed Successfully!
Connect using: ssh root@69.30.85.203 -p 22119
User: root
Password: <existing password>
```

---

## File Transfer Tool

Interactive tool for copying files/folders between RunPod instances using **rsync** when you need to migrate data (e.g., when your pod gets stuck with zero GPUs or you need to move to a different instance).

**Why rsync?**
- **Faster**: Compression during transfer
- **Resume capable**: Can resume interrupted transfers
- **Progress tracking**: Real-time transfer statistics
- **Efficient**: Only transfers differences for repeated transfers

## Complete Migration Workflow

### Step 1: Setup Destination Pod
On your **new pod** (where you want files to go):
```bash
wget https://raw.githubusercontent.com/justinwlin/Runpod-SSH-Password/main/passwordrunpod.sh && chmod +x passwordrunpod.sh && ./passwordrunpod.sh
```

Copy the SSH connection details it gives you:
```
You can now connect using: ssh root@213.173.105.86 -p 17958
Password: hello
```

### Step 2: Transfer from Source Pod
On your **old pod** (where your files are):
```bash
wget https://raw.githubusercontent.com/justinwlin/Runpod-SSH-Password/refs/heads/main/SCPMigration -O scp_migration.py && python3 scp_migration.py && rm scp_migration.py
```

### Step 3: Navigate and Transfer

#### Navigation Mode (Browse files)
```
Current directory: /workspace

Navigate by entering a number:
 1. models/
 2. data/
 3. ComfyUI/
 4. config.json

Ready to transfer something?
  s - Switch to SELECTION MODE

Navigate to: 1    (goes into models folder)
Navigate to: s    (switches to selection mode)
```

#### Selection Mode (Choose what to transfer)
```
Select a file or folder to transfer:
 1. stable-diffusion/ [Select entire folder]
 2. model.safetensors [Select file]

Commands:
  n - Switch back to NAVIGATION MODE

Select item: 1    (selects the stable-diffusion folder)
```

#### Enter Connection Details
```
Enter SSH command: ssh root@213.173.105.86 -p 17958
Enter password: hello
```

#### Transfer Happens
```
Directory detected - using rsync with compression
Starting rsync transfer with compression...
Progress will be displayed below:
============================================================
sending incremental file list
models/
models/model1.safetensors
    1.23G 100%   45.67MB/s    0:00:26 (xfr#1, to-chk=2/4)
models/model2.safetensors
    2.45G 100%   48.23MB/s    0:00:52 (xfr#2, to-chk=1/4)

Number of files: 4
Total file size: 3.68G bytes
Total transferred: 3.68G bytes
============================================================
Transfer completed successfully!
```

---

## How It Works

- **rsync with compression**: All transfers use rsync with automatic compression (-z flag)
- **Progress display**: Real-time progress bars and transfer statistics
- **Resume capability**: Interrupted transfers can be resumed
- **Navigation**: Browse with numbers, press `s` to switch to selection mode
- **Selection**: Choose items to transfer, press `n` to go back to browsing
- **Automatic installation**: rsync is automatically installed if not present

## Use Case

You have a RunPod instance with important data (models, datasets, code) but it's stuck with zero GPUs or having issues. You need to migrate everything to a new pod quickly and reliably.

1. Spin up new pod
2. Run SSH setup script on new pod
3. Run file transfer tool on old pod
4. Navigate to your important folders
5. Select and transfer them
6. Continue work on new pod

Simple as that.
