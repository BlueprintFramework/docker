<!-- Header -->
![Blueprint Docker](https://github.com/BlueprintFramework/docker/assets/103201875/f1c39e6e-afb0-4e24-abd3-508ec883d66b)
<p align="center"><a href="https://github.com/BlueprintFramework/main"><b>Blueprint</b></a>'s extension ecosystem you know and love, in 🐳 Docker.</p>

<!-- Information -->
<br/><h2 align="center">🐳 Blueprint in Docker</h2>

### Uploading extensions
Extensions must be placed/dragged into the `extensions` folder.

### Interacting with Blueprint
By default, you can only interact with Blueprint by going through the Docker command line, i.e.
```bash
docker compose exec panel blueprint (arguments)
```

#### We recommend setting an alias so you can interact with Blueprint the same way you would in the non-Docker version (If you have your compose file in a different place, adjust accordingly:
```bash
# Set alias for current session
alias blueprint="docker compose -f /srv/pterodactyl/docker-compose.yml exec panel blueprint"
# Append to the end of your .bashrc file to make it persistent
echo 'alias blueprint="docker compose -f /srv/pterodactyl/docker-compose.yml exec panel blueprint"' >> ~/.bashrc
```

### Example of installing an extension
Here's a quick example showcasing how you would go about installing extensions on the Docker version of Blueprint. Note that your experience can differ for every extension.
  1. [Find an extension](https://blueprint.zip/browse) you would like to install and look for a file with the `.blueprint` file extension.
  2. Drag/upload the `example.blueprint` file over/onto to your extensions folder, i.e. by default `/srv/pterodactyl/extensions`.
  3. Install the extension through the Blueprint command line tool:
     ```bash
     docker compose exec panel blueprint -install example
     ```
     Alternatively, if you have applied the alias we suggested above:
     ```bash
     blueprint -install example
     ```

#### So, you installed your first extension. Congratulations! Blueprint is now keeping persistent data inside the `pterodactyl_app` volume, so you'll want to start backing that volume up regularly.

### First, we'll install Restic to handle backups
Why Restic? Compression, de-duplication, and incremental backups. Save on space compared to simply archiving the directory each time.
The package name is usually `restic`, i.e.
`sudo apt install restic` (Ubuntu / Debian / Linux Mint)
`sudo dnf install restic` (Fedora)
`sudo dnf install epel-release && sudo dnf install restic` (Rocky Linux / AlmaLinux / CentOS)
`sudo pacman -S restic` (Arch Linux)
`sudo zypper install restic` (openSUSE)

#### Make a directory and script for backups
```bash
mkdir -p /srv/backups/pterodactyl
restic init --repo /srv/backups/pterodactyl
cat <<'EOF' > /srv/backups/backup.sh
#!/bin/bash

docker compose -f /srv/pterodactyl/docker-compose.yml down
restic backup /var/lib/docker/volumes/pterodactyl_app/_data --repo /srv/backups/pterodactyl
docker compose -f /srv/pterodactyl/docker-compose.yml up -d
EOF
chmod +x /srv/backups/backup.sh
```

#### Set a crontab to back up your panel (choose a time when it will be least likely to be being used)
```bash
(crontab -l 2>/dev/null; echo "59 23 * * * /srv/backups/backup.sh") | crontab -
```

#### Well, great. I have daily backups now, and they're set to keep at most 30 backups at a time. How can I restore from one of them?
You can list snapshots with ``restic snapshots --repo /srv/backups/pterodactyl``
You're looking for a value for **ID** that looks something like ``46adb587``. **Time** will be right next to each ID, so you can see what day your backups are from.

#### Once you've determined which snapshot you want to restore, stop your compose stack, restore your data, and start your stack again
```bash
docker compose -f /srv/pterodactyl/docker-compose.yml down
# Clear the directory so the restoration will be clean
rm -rf /var/lib/docker/volumes/pterodactyl_app/_data
# Remember to replace "46adb587" with your actual ID of the snapshot you want to restore
restic restore 46adb587 --repo /srv/backups/pterodactyl --target /var/lib/docker/volumes/pterodactyl_app/_data
docker compose -f /srv/pterodactyl/docker-compose.yml up -d
```

# Updating Blueprint in Docker
- You can update Pterodactyl Panel, Blueprint, or both independently of each other.
- Newer versions of Blueprint and/or extensions may not function as intended in older versions of Pterodactyl Panel.

## Updating your version of Pterodactyl Panel
- Go to the directory of your docker-compose.yml
- ```bash
    docker compose down
  ```
- Change the tag in your panel's image (i.e. to upgrade from **v1.11.5** to **v1.11.7**, you would change ``ghcr.io/blueprintframework/blueprint:v1.11.5`` to ``ghcr.io/blueprintframework/blueprint:v1.11.7``.
- ```bash
    docker compose pull
  ```
- ```bash
    docker compose up -d
  ```
## Updating your version of Blueprint
- /app is persistent data, so updating your panel image will NOT update blueprint. You _do_ have to manually update it despite pulling a newer image.
- Go to the directory of your docker-compose.yml file
### If you have set the alias as we recommend above
- ```bash
    blueprint -upgrade
  ```
### If you have not set the alias
- ```bash
    docker compose exec panel blueprint -upgrade
  ```

<!-- copyright footer -->
<br/><br/>
<p align="center">
  $\color{#4b4950}{\textsf{© 2024 Ivy (prpl.wtf) and Loki}}$
  <br/><br/><img src="https://github.com/BlueprintFramework/docker/assets/103201875/68a6038e-4922-4e1a-b1d4-f58a4c5db397"/>
</p>
