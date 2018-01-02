UT3Vehicles
===========

The vehicles portion of the UT3Style mod for Unreal Tournament 2004.

## How to compile

* Clone this git repository into the `UT2004` folder.
* Download all the required binary dependencies. This is done by running `FetchBinaries.sh`. This will put binaries into the usual subdirectories one directory above the working directory. You can override the directories by setting environmental variables `TEXTURES_DIR`, `ANIMATIONS_DIR`, `SOUNDS_DIR`, `STATICMESHES_DIR` and `SYSTEM_DIR`. The script is smart and will only update your files when necessary.
  * On Linux, simply run:
```bash
./FetchBinaries.sh
```
  * On Windows, download [wget64.exe](https://eternallybored.org/misc/wget/current/wget64.exe) and place it in `C:\Program Files\Git\mingw64\bin\` as `wget.exe` (renaming is important!), then open Git Bash, go to the directory you have this git repository cloned in and also run `./FetchBinaries.sh` just like on Linux.
* Obtain and install the [`UT3Common` package](https://github.com/GreatEmerald/UT3Common).
* Add to your `UT2004.ini` these lines, after the other `EditPackages` lines:
```ini
EditPackages=RagdollMadness
EditPackages=EONS-Scorpion_BETA3
EditPackages=UT3Common
EditPackages=UT3Vehicles
```
* (Re)move the `UT2004/System/UT3Vehicles.u` file.
* Run `ucc.exe make` from the command prompt, this should create a `UT3Vehicles.u` file in `UT2004/System`.
