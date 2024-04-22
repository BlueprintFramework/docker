<!-- Header -->
![Blueprint Docker](https://github.com/BlueprintFramework/docker/assets/103201875/f1c39e6e-afb0-4e24-abd3-508ec883d66b)
<p align="center"><a href="https://github.com/BlueprintFramework/main"><b>Blueprint</b></a>'s extension ecosystem you know and love, in Docker.</p>

<!-- Information -->
<br/><h2 align="center">🐳 Blueprint in Docker</h2>

## Uploading extensions\
Extensions must be placed/dragged into the `extensions` folder.

## Interacting with Blueprint\
By default, you can only interact with Blueprint by going through the Docker command line, i.e.
```bash
docker compose exec panel blueprint (arguments)
```

### We recommend setting an alias so you can interact with Blueprint the same way you would in the non-Docker version (If you have your compose file in a different place, adjust accordingly:
```bash
# Set alias for current session
alias blueprint="docker compose -f /srv/pterodactyl/docker-compose.yml exec panel blueprint"
# Append to the end of your .bashrc file to make it persistent
echo 'alias blueprint="docker compose -f /srv/pterodactyl/docker-compose.yml exec panel blueprint"' >> ~/.bashrc
```

### Example of installing an extension\
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

## So, you installed your first extension. Congratulations! Blueprint is now keeping persistent data inside the pterodactyl_app volume, so you'll want to start backing that volume up regularly.
### Make a directory and script for backups
```bash
mkdir /srv/backups
cat <<'EOF' > /srv/backups/backup.sh
#!/bin/bash

docker compose -f /srv/pterodactyl/docker-compose.yml down
tar czvf /srv/backups/pterodactyl_app_$(date +%m-%d-%Y).tar.gz -C /var/lib/docker/volumes/pterodactyl_app/_data .
docker compose -f /srv/pterodactyl/docker-compose.yml up -d
EOF
chmod +x /srv/backups/backup.sh
```

### Set a crontab to back up your panel (choose a time when it will be least likely to be being used)
```bash
(crontab -l 2>/dev/null; echo "59 23 * * * /srv/backups/backup.sh") | crontab -
```
