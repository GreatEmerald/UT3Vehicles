UT3Vehicles
===========

The vehicles portion of the UT3Style mod for Unreal Tournament 2004.

## How to compile

* Clone this git repository into the `UT2004` folder.
* If not already, copy or link the contents of `Animations`, `Sounds`, `StaticMeshes`, `Textures` and `System` to their respective folders in `UT2004`. You also need to have the `UT3Common` package.
* Add to your `UT2004.ini` these lines, after the other `EditPackages` lines:
```ini
EditPackages=RagdollMadness
EditPackages=EONS-Scorpion_BETA3
EditPackages=UT3Common
EditPackages=UT3Vehicles
```
* (Re)move the `UT2004/System/UT3Vehicles.u` file.
* Run `ucc.exe make` from the command prompt, this should create a `UT3Vehicles.u` file in `UT2004/System`.
