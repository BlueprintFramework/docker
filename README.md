<div style="display: flex; align-items: center;">
  <div style="flex: 1;">
    ![Blueprint](https://github.com/BlueprintFramework/docker/assets/59907407/4eb6a70b-7f30-476e-81a4-c4f317186db6)
  </div>
  <div style="margin-left: 20px;">
    [![Join our Discord](https://discordapp.com/api/guilds/123456789012345678/widget.png?style=banner2)](https://discord.gg/CUwHwv6xRe)
  </div>
  <div style="margin-left: 20px;">
    [![Download Blueprint](https://yourwebsite.com/path/to/blueprint/download/image.png)](https://blueprint.zip/)
  </div>
</div>

# Not yet usable unless you build the image yourself (haven't finished automating the build on Github yet)
# Blueprint in Docker
- Drag .blueprint files into the **extensions** folder
- Interact with blueprint through ``docker compose exec panel blueprint (command)``
- Example using [recolor](<https://github.com/sp11rum/recolor>):
  1. Dowload recolor's .zip file
  2. Extract the recolor.blueprint file
  3. Drag the recolon.blueprint file into the extensions folder, i.e. by default ``/srv/pterodactyl/extensions``.
  4. Install recolor: ``docker compose exec panel blueprint -install recolor``
