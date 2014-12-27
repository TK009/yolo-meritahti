yolo-meritahti
==============

ComputerCraft AI project. Goal of the project: Conquer the minecraft world with Turtles!

Project status
--------------

**Environment**
* We have an installer! see /packages /src/lib/help/packages on what is installed where
* Useful core and turtle libraries are in progress


**The AI**
* Planning in progress

Downloading to a computer
-------------------------
On a CraftOS command line:

`pastebin run CEx2cb4n`

Directory Structure
-------------------

* doc/ : Some project specific documentation
* src/ : .lua files for ComputerCraft/Turtle **programs**
* src/lib/ : .lua files for common libraries, utilities and misc files. See below.

On a ComputerCraft computer:

* lib/ : src/lib/ copied as is.
* lib/help/ : help files for programs etc. Can be read with CraftOS help program if installer was used.
* lib/core/ : core libraries and api tweaks that will be loaded at startup. These can be used by any program.
* bin/ : programs are copied here (from src/) without `.lua` extension.
* etc/ : config files for programs



Mods
----

We use modpack FTB Ressurection.
ComputerCraft version: 1.65


**Improvements to the modpack**

1. Download FTB Ressurection with ftb-launcher
2. Edit the modpack from ftb-launcher, add [FastCraft](http://forum.industrial-craft.net/index.php?page=Thread&threadID=10820) (the .jar file)
3. You can add [java optimization parameters](http://pastebin.com/aL8zwnK2) from launcher settings
4. **Important:** Add more memory for minecraft, but no more than 4G
5. There might be a critical bug in Forge that causes lag spikes, fix with updating forge in the modpack.
  1. [Download latest version of forge](http://files.minecraftforge.net/maven/net/minecraftforge/forge/1.7.10-10.13.2.1272/forge-1.7.10-10.13.2.1272-installer.jar)
  2. Select Extract... and extract it to `<ftbfolder>/library/net/minecraftforge/forge/1.7.10-10.13.2.1272` (create this folder)
  3. Edit text-file `<ftbfolder>/FTBRessurrection/minecraft/pack.json`, edit (line 6?) which has minecraftforge version to: `"name": "net.minecraftforge:forge:1.7.10-10.13.2.1272:universal",`
