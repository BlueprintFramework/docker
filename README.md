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
     docker compose exec panel blueprint -i example
     ```
     Alternatively, if you have applied the alias we suggested above:
     ```bash
     blueprint -i example
     ```

#### So, you installed your first extension. Congratulations! Blueprint is now keeping persistent data inside the `pterodactyl_app` volume, so you'll want to start backing that volume up regularly.

### First, we'll install Restic to handle backups
Why Restic? Compression, de-duplication, and incremental backups. Save on space compared to simply archiving the directory each time.
The package name is usually `restic`, i.e.
| Operating System                 | Command                                                         |
|----------------------------------|-----------------------------------------------------------------|
| Ubuntu / Debian / Linux Mint     | `sudo apt -y install restic`                                    |
| Fedora                           | `sudo dnf -y install restic`                                    |
| Rocky Linux / AlmaLinux / CentOS | `sudo dnf -y install epel-release && sudo dnf -y install restic`|
| Arch Linux                       | `sudo pacman -S --noconfirm restic`                             |
| openSUSE                         | `sudo zypper install -n restic`                                 |
| Gentoo                           | `sudo emerge --ask=n app-backup/restic`                         |

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
## Option 1: Only update Blueprint
- If you have set the alias we suggested earlier
  ```bash
  blueprint -upgrade
  ```
- If you have not
  ```bash
  docker compose -f /srv/pterodactyl/docker-compose.yml exec panel blueprint -upgrade
  ```

## Option 2: Update both Blueprint and Pterodactyl Panel
- This guide operates under the assumption that individual extension/theme authors have chosen to store any persistent data such as settings in the database. If they have not done this... there isn't any specific place extension data is meant to be stored, so the data could be anywhere. You'll need to ask them if there is any persistent data stored anywhere that you have to back up before updating.
- Go to the directory of your docker-compose.yml file
- ```bash
    docker compose down -v
  ```
- The -v tells it to delete any named volumes, i.e. the app volume we use. It will not delete data from bind-mounts. This way the new image's app volume can take place.
- Change the tag in your panel's image (i.e. to upgrade from **v1.11.5** to **v1.11.7**, you would change ``ghcr.io/blueprintframework/blueprint:v1.11.5`` to ``ghcr.io/blueprintframework/blueprint:v1.11.7``.
- ```bash
    docker compose pull
  ```
- ```bash
    docker compose up -d
  ```
- Lastly, install your extensions again. Refer to [the examples](<https://github.com/BlueprintFramework/docker?tab=readme-ov-file#example-of-installing-an-extension>).
- Blueprint will support installing multiple extensions at once in the future, making updates significantly easier. The syntax showcased was ``blueprint -i extension1 extension2 extension3``. Documentation here will be updated when that comes out, but for now you'll have to install each extension again every update. Feel free to automate this with a simple bash script:
  - Create the script
    - ```bash
      cd /srv/pterodactyl && echo -e '#!/bin/bash\n\nfor extension in "$@"\ndo\n    docker compose exec panel blueprint -i "$extension"\ndone' > bulk-install.sh && chmod +x bulk-install.sh
      ```
  - The script will be located in the assumed root folder for your compose stack, ``/srv/pterodactyl``. You can use it while in that folder with as many extensions as you want with:
    - ```bash
        ./bulk-install.sh extension1 extension2 extension3``
      ```
<!-- copyright footer -->
<br/><br/>
<p align="center">
  $\color{#4b4950}{\textsf{© 2024 Ivy (prpl.wtf) and Loki}}$
  <br/><br/><img src="https://github.com/BlueprintFramework/docker/assets/103201875/68a6038e-4922-4e1a-b1d4-f58a4c5db397"/>
</p>
