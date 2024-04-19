| [![Find Extensions](https://github.com/BlueprintFramework/docker/assets/59907407/27f14617-64d1-4e50-80d8-3ed2848b8223)](https://blueprint.zip/browse) | [![Discord](https://github.com/BlueprintFramework/docker/assets/59907407/96b1213b-94d8-47e4-b1d8-56f2b76c5e17)](https://discord.gg/CUwHwv6xRe) |

# Not yet usable unless you build the image yourself (haven't finished automating the build on Github yet)
# Blueprint in Docker
- Drag .blueprint files into the **extensions** folder
- Interact with blueprint through `docker compose exec panel blueprint (command)`
- Example using [recolor](https://github.com/sp11rum/recolor):
  1. Download recolor's .zip file
  2. Extract the recolor.blueprint file
  3. Drag the recolon.blueprint file into the extensions folder, i.e. by default `/srv/pterodactyl/extensions`.
  4. Install recolor: `docker compose exec panel blueprint -install recolor`
