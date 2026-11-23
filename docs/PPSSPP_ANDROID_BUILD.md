# PPSSPP Android build

This repository can build the official PPSSPP Android emulator from its upstream source.

## Build

Open GitHub Actions and run **Build PPSSPP Android APK**, or push a change to the workflow file. The workflow checks out the upstream `hrydgard/ppsspp` source (including submodules), builds the `normalOptimized` Android variant, verifies the APK, and uploads it as the `PPSSPP-Android-ARM-and-MultiABI` artifact.

## Using your own game image

The APK contains the emulator only. It does not include commercial game files. On Android, open PPSSPP, grant access to the folder containing your legally obtained `.iso` or `.cso` image, and select the game. PPSSPP stores its game list and settings for later launches.

## License

PPSSPP is a separate open-source project distributed under GPL-2.0-or-later. See https://github.com/hrydgard/ppsspp for its source and license. This build workflow does not bundle game images or PSP firmware.
