# Most Wanted Mobile — working title

An original 3D open-world street-racing game for Android, inspired by the atmosphere and broad gameplay ideas of early-2000s arcade racers. This is a fan-made, independent project; it is not affiliated with or endorsed by Electronic Arts.

## Project goals
- Third-person arcade driving with touch controls
- Original fictional city, cars, characters, and progression
- Police pursuit gameplay and race events
- Android-first performance and scalable graphics

## Legal / assets
Do not add files ripped from commercial games, copyrighted music, logos, or other assets unless you have permission to use them. Use original or properly licensed assets. The project name is a working title.

## Getting started
1. Install Unity Hub and a Unity Editor version with **Android Build Support**, including Android SDK & NDK Tools and OpenJDK.
2. Create a new **3D (URP)** Unity project.
3. Copy the `Assets/` folder from this repository into the new project.
4. Open the project in Unity, create a scene, add a vehicle with a Rigidbody and WheelColliders, then attach `ArcadeCarController`.
5. Add a Canvas with UI buttons and connect their Pointer Down / Pointer Up events to the public input methods on `MobileInputBridge`. Assign the bridge to the car controller.
6. Switch the build target to Android and build an APK for device testing.

## Current prototype code
- `Assets/Scripts/Vehicle/ArcadeCarController.cs` — basic WheelCollider arcade vehicle controller.
- `Assets/Scripts/Input/MobileInputBridge.cs` — touch-button input bridge.

This repository currently contains starter scripts, not a finished game or a ready-to-install APK. Models, scenes, audio, UI, and gameplay systems will be added iteratively.
