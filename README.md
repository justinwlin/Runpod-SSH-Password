# RunPod SSH Password Setup

Bash script for setting up SSH access with password authentication on RunPod instances.

## Usage


```bash
chmod +x passwordrunpod.sh
bash passwordrunpod.sh
```

## What it does

1. Installs SSH server if not present
2. Enables root login with password
3. Sets custom root password
4. Creates connection scripts in `/workspace/`

After running the script it will tell you the command you can run to connect from a different pod or machine:
Example:
```
Password confirmed successfully.
Setting custom password for root...
Root password set and saved in /workspace/root_password.txt
Checking environment variables...
Environment variables are set.
Creating connection script for Windows...
Windows connection script created in /workspace.
Creating connection script for Linux/Mac...
Linux/Mac connection script created in /workspace.
Setup Completed Successfully!
You can now connect using: ssh root@69.30.85.203 -p 22119
Password: helloworld
```