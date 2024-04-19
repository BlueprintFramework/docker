<!-- Header -->
<br/><p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/BlueprintFramework/main/assets/103201875/c0072c61-0135-4931-b5fa-ce4ee7d79f4a">
    <source media="(prefers-color-scheme: light)" srcset="https://github.com/BlueprintFramework/main/assets/103201875/a652a6e7-b53f-4dcd-ae4e-2051f5c9c7b9">
    <img alt="Blueprint" src="https://github.com/BlueprintFramework/main/assets/103201875/c0072c61-0135-4931-b5fa-ce4ee7d79f4a" height="30">
  </picture>
  <br/>
  Open-source modding framework for the Pterodactyl panel.
  <br/><br/>
  <a href="https://blueprint.zip">Website</a> <b>·</b>
  <a href="https://discord.gg/CUwHwv6xRe">Community</a> <b>·</b>
  <a href="https://blueprint.zip/docs">Documentation</a>
</p>

# Not yet usable unless you build the image yourself (haven't finished automating the build on Github yet)
# Blueprint in Docker
- Drag .blueprint files into the **extensions** folder
- Interact with blueprint through
  - ```bash
    docker compose exec panel blueprint (command)
    ```
- Example using [recolor](https://github.com/sp11rum/recolor):
  1. Download recolor's .zip file
  2. Extract the recolor.blueprint file
  3. Drag the recolor.blueprint file into the extensions folder, i.e. by default `/srv/pterodactyl/extensions`.
  5. Install recolor:
     ```bash
     docker compose exec panel blueprint -install recolor
     ```
