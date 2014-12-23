yolo-meritahti
==============

ComputerCraft AI project. Goal of the project: Conquer the minecraft world with Turtles!

Modpack: FTB Ressurection

Improvements to the modpack
---------------------------

1. Download FTB Ressurection with ftb-launcher
2. Edit the modpack from ftb-launcher, add [FastCraft](http://forum.industrial-craft.net/index.php?page=Thread&threadID=10820) (the .jar file)
3. You can add [java optimization parameters](http://pastebin.com/aL8zwnK2) from launcher settings
4. There might be a critical bug in Forge that causes lag spikes, fix with updating forge in the modpack.
  1. [Download latest version of forge](http://files.minecraftforge.net/maven/net/minecraftforge/forge/1.7.10-10.13.2.1272/forge-1.7.10-10.13.2.1272-installer.jar)
  2. Select Extract... and extract it to `<ftbfolder>/library/net/minecraftforge/forge/1.7.10-10.13.2.1272` (create this folder)
  3. Edit text-file `<ftbfolder>/FTBRessurrection/minecraft/pack.json`, edit (line 6?) which has minecraftforge version to: `"name": "net.minecraftforge:forge:1.7.10-10.13.2.1272:universal",`
