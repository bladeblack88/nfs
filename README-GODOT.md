# Most Wanted Mobile — Android prototype

This repository now includes a Godot 4.4 mobile-first 3D arcade driving prototype. It is an original project inspired by early-2000s street-racing games; it does not contain PlayStation game data, EA assets, music, cars, maps, or executable code.

## Current prototype
- Third-person chase camera
- Arcade vehicle movement
- Touchscreen steering, throttle, and brake controls
- Speed display
- Procedurally generated test road, barriers, and simple city blocks
- Android ARM64 debug APK export workflow

## Build APK
A GitHub Actions workflow runs on pushes affecting the Godot project and can also be started manually from **Actions → Build Android APK → Run workflow**. Download the artifact named **MostWantedMobile-Android-APK** from the completed run.

The workflow produces a debug APK for testing, not a Play Store release. It requires no local Unity installation. For local export, install Godot 4.4.1 and its Android export templates/SDK, then export using the Android preset.

## Important
This is an early playable prototype, not a finished NFS-scale game. The current car and city are placeholder geometry. More work is needed for proper vehicle suspension, traffic, police AI, races, menus, sound, optimized assets, and device testing.
