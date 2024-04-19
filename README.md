![image](https://github.com/BlueprintFramework/docker/assets/59907407/33c736c6-f40f-4786-86e5-a353191d08f7)
# Not yet usable unless you build the image yourself (haven't finished automating the build on Github yet)
# Blueprint in Docker
- Drag .blueprint files into the **extensions** folder
- Interact with blueprint through ``docker compose exec panel blueprint (command)``
- Example using [recolor](<https://github.com/sp11rum/recolor>):
  1. Dowload recolor's .zip file
  2. Extract the recolor.blueprint file
  3. Drag the recolon.blueprint file into the extensions folder, i.e. by default ``/srv/pterodactyl/extensions``.
  4. Install recolor: ``docker compose exec panel blueprint -install recolor``
