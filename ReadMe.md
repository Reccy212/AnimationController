# AC (Animation Controller)

A small, easy to use animation module for Roblox. Register your animations once by name, then play, stop, and adjust them on any player with one line.

Made by reccy. Add me on Discord: **reccydev**

Anyone can use this. If you find it useful, please star the repo!

---

## Features

- Register animations by name instead of passing IDs around
- Accepts plain numbers or full `rbxassetid://` strings
- Tracks are cached per Animator, so nothing is reloaded on every call
- Safe warnings when you use a name that was never registered
- Works with respawns, since each new character gets a fresh Animator
- Stop everything playing on a player in one call

---

## Installation

1. Create a **ModuleScript** named `AnimationController`.
2. Paste the module code into it.
3. Place it somewhere both your scripts can reach, such as `ReplicatedStorage`.
4. Require it:

```lua
local AC = require(game.ReplicatedStorage.AnimationController)
```

---

## Quick Start

```lua
local Players = game:GetService("Players")
local AC = require(game.ReplicatedStorage.AnimationController)

AC:RegisterM({
	GetJiggy = {AnimationId = 123456789},
	GetLow = {AnimationId = 987654321},
})

AC:PreloadAnims()

local Player = Players.LocalPlayer
AC:Play(Player, "GetJiggy")
```

---

## API Reference

All functions use colon syntax (`AC:Function()`).

### `AC:Register(Name, AnimationId)`

Registers a single animation.

| Parameter | Type | Description |
|---|---|---|
| Name | string | The name you will use to refer to this animation |
| AnimationId | number or string | A number like `123456789` or a string like `"rbxassetid://123456789"` |

```lua
AC:Register("Wave", 123456789)
```

---

### `AC:RegisterM(tbl)`

Registers many animations at once. Each key is the animation name.

```lua
AC:RegisterM({
	GetJiggy = {AnimationId = 123456789},
	GetLow = {AnimationId = 987654321},
})
```

A bare ID is also accepted as the value:

```lua
AC:RegisterM({
	Wave = 123456789,
	Point = 555555555,
})
```

Registering a name that already exists replaces the old entry.

---

### `AC:PreloadAnims()`

Preloads every registered animation using `ContentProvider:PreloadAsync`. Call it after registering and before you start playing, ideally during a loading screen. This function yields until loading finishes.

```lua
AC:PreloadAnims()
```

---

### `AC:Play(Player, Name)`

Plays a registered animation on the player. Returns the `AnimationTrack`, or `nil` if the name is not registered.

```lua
local Track = AC:Play(Player, "GetJiggy")
```

---

### `AC:Stop(Player, Name)`

Stops a registered animation on the player instantly.

```lua
AC:Stop(Player, "GetJiggy")
```

---

### `AC:StopAll(Player)`

Stops every animation currently playing on the player, instantly. This includes animations AC did not start, such as the default Animate script.

```lua
AC:StopAll(Player)
```

---

### `AC:IsPlaying(Player, Name)`

Returns `true` if the animation is currently playing on the player, otherwise `false`.

```lua
if AC:IsPlaying(Player, "GetJiggy") then
	AC:Stop(Player, "GetJiggy")
end
```

---

### `AC:SetSpeed(Player, Name, Speed)`

Changes the playback speed of a registered animation. `1` is normal speed.

```lua
AC:SetSpeed(Player, "GetJiggy", 1.5)
```

---

## Notes and Tips

- **Yielding:** AC waits for the player's character and Humanoid if they do not exist yet. Calling AC on a player with no character will pause your script until one loads.
- **Default Animate script:** `StopAll` can look like it did nothing, because the default Animate script restarts idle and walk almost immediately. Disable or replace that script if you want full control.
- **Unregistered names:** If you use a name that was never registered, AC prints a warning and does nothing. Check your spelling.
- **Caching:** The first `Play` of an animation loads the track. Later calls reuse it. Preloading with `PreloadAnims` avoids a hitch on that first play.
- **Client or server:** Animations played on the client are only seen by that client unless the character is owned by that client, in which case Roblox replicates them. Playing from the server always replicates.

---

## Troubleshooting

| Problem | Likely cause |
|---|---|
| Nothing plays | The animation is not owned by you or the game, or the ID is wrong |
| Warning about a missing name | The name was not registered, or has a typo |
| Animation plays then snaps back | The default Animate script is overriding it, or the animation priority is too low |
| Script hangs | The player has no character yet |

---

## Credits

Made by **reccy**. Discord: **reccydev**

If this helped you, star the repo!
