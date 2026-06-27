# Device detection (`EzUI.Device`)

`EzUI.Device` reports the player's device class and active input so you can adapt your UI.

## Form factor

```lua
EzUI.Device.GetType()   -- "Mobile" | "Tablet" | "Desktop" | "Console"
EzUI.Device.IsMobile()  EzUI.Device.IsTablet()
EzUI.Device.IsDesktop() EzUI.Device.IsConsole()
EzUI.Device.IsTouch()   -- true when the device has a touchscreen
```

Console (ten-foot interface) and Desktop are detected reliably. **Mobile vs Tablet is a
best-effort heuristic** based on the viewport aspect ratio — Roblox exposes no physical
screen size or DPI. Tune it with `Configure`:

```lua
EzUI.Device.Configure({ TabletMaxAspect = 1.55, TabletMinDiagonal = math.huge })
```

## Active input modality

```lua
EzUI.Device.GetInput()  -- "Touch" | "KeyboardMouse" | "Gamepad" (the most recent input)
```

## Reacting to changes

```lua
EzUI.Device.Changed:Connect(function(info)
  -- info = { Type = "...", Input = "...", Viewport = Vector2 }
  print("device is now", info.Type, "via", info.Input)
end)
```
