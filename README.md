<!-- Header -->
![Blueprint Docker](https://github.com/BlueprintFramework/docker/assets/103201875/f1c39e6e-afb0-4e24-abd3-508ec883d66b)
<p align="center"><a href="https://github.com/BlueprintFramework/main"><b>Blueprint</b></a>'s extension ecosystem you know and love, in Docker.</p>

<!-- Information -->
<br/><h2 align="center">🐳 Blueprint in Docker</h2>

**Uploading extensions**\
Extensions must be placed/dragged into the `extensions` folder, instead of the Pterodactyl directory Blueprint normally pulls extensions from.

**Interacting with Blueprint**\
Instead of running the `blueprint` command to manage Blueprint and it's extensions, the Docker version uses the following command scheme:
```bash
docker compose exec panel blueprint (arguments)
```

**Example of installing an extension**\
Here's a quick example showcasing how you would go about installing extensions on the Docker version of Blueprint. Note that your experience can differ for every extension.
  1. [Find an extension](https://blueprint.zip/browse) you would like to install and look for a file with the `.blueprint` file extension.
  2. Drag/upload the `example.blueprint` file over/onto to your extensions folder, i.e. by default `/srv/pterodactyl/extensions`.
  3. Install the extension through the Blueprint command line tool:
     ```bash
     docker compose exec panel blueprint -install example
     ```
