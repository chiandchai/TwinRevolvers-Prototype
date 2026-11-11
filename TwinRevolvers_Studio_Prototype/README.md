# Twin Revolvers – Roblox Studio Prototype

This is a **standalone Roblox Studio prototype for a game you own or are authorized to edit**. It recreates the normal Twin Revolvers firing feel from the configuration you supplied:

- 0.24-second firing interval
- 160-stud maximum range
- 37 body damage
- 60 head damage
- Alternating left/right muzzle flash indicator
- Server-side raycast and damage validation
- NPC targets stored under `Workspace > Myths`

It does not connect to, modify, or bypass the combat system of the third-party game you decompiled.

## Studio setup

1. Open a Roblox Studio experience that you own.
2. In `ReplicatedStorage`, create a **ModuleScript** named `WeaponConfig` and paste `WeaponConfig.lua`.
3. In `ServerScriptService`, create a **Script** named `CombatServer` and paste `CombatServer.server.lua`.
4. In `StarterPlayer > StarterPlayerScripts`, create a **LocalScript** named `CombatClient` and paste `CombatClient.client.lua`.
5. Create a `Folder` named `Myths` under `Workspace`.
6. Put your test NPC models inside `Workspace > Myths`. Each NPC needs a `Humanoid` and a `HumanoidRootPart`.
7. Create a `Tool` named `TwinRevolvers` in `StarterPack`. Set its Attribute:
   - Name: `WeaponClass`
   - Type: `String`
   - Value: `TwinRevolvers`
8. Give the Tool a `Handle` part (or set `RequiresHandle` to false).
9. Press **Play**. Equip TwinRevolvers and hold the left mouse button to fire.

## Notes

- Damage is decided on the server, not trusted from the client.
- The client only sends an aim direction. The server checks the equipped tool, firing interval, direction, range, and raycast result.
- Each normal shot damages at most one NPC. This follows the normal single-ray shot model supported by the client code you shared; it does not claim the original game's server behaves identically.
- This is a starter prototype. Add your own animations, sounds, reload/ammo rules, and weapon models as needed.
