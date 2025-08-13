# RunPod SSH Password Setup & File Transfer Tools

Simple tools for transferring files between RunPod instances when you need to migrate data (e.g., when your pod gets stuck with zero GPUs).

## SSH Password Setup

Sets up password-based SSH access on your RunPod instance.

### Usage
```bash
wget https://raw.githubusercontent.com/justinwlin/Runpod-SSH-Password/main/passwordrunpod.sh && chmod +x passwordrunpod.sh && ./passwordrunpod.sh
```

### What it does
1. Installs SSH server if not present
2. Enables root login with password
3. Sets custom root password
4. Creates connection scripts in `/workspace/`

**Example Output:**
```
Setup Completed Successfully!
You can now connect using: ssh root@69.30.85.203 -p 22119
Password: helloworld
```

---

## File Transfer Tool

Interactive tool for copying files/folders between RunPod instances when you need to migrate data (e.g., when your pod gets stuck with zero GPUs or you need to move to a different instance).

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
Directory detected - using ZIP compression for reliable transfer
Compressing directory to ZIP...
Transfer completed successfully!
Archive extracted and cleaned up on remote server!
```

---

## How It Works

- **Files**: Transferred directly via SCP
- **Folders**: Automatically compressed to ZIP, transferred, then extracted on destination
- **Navigation**: Browse with numbers, press `s` to switch to selection mode
- **Selection**: Choose items to transfer, press `n` to go back to browsing

## Use Case

You have a RunPod instance with important data (models, datasets, code) but it's stuck with zero GPUs or having issues. You need to migrate everything to a new pod quickly and reliably.

1. Spin up new pod
2. Run SSH setup script on new pod
3. Run file transfer tool on old pod
4. Navigate to your important folders
5. Select and transfer them
6. Continue work on new pod

Simple as that.
