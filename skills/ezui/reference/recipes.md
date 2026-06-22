# EzUI Recipes

Complete, copy-pasteable end-to-end patterns. Each begins from `EzUI:CreateWindow` and uses only documented API.

---

## 1. Minimal hub (window + 2 tabs + a few controls)

```lua
local EzUI = loadstring(game:HttpGet(
    "https://github.com/alfin-efendy/ez-rbx-ui/releases/latest/download/ez-rbx-ui.lua"
))()

local Window = EzUI:CreateWindow({
    Title    = "My Hub",
    Subtitle = "v1.0",
    Ratio    = 16 / 10,
    ToggleKey = Enum.KeyCode.RightControl,
    FloatingToggle = { Type = "simple", AutoHide = true },
})

-- Home tab
local home = Window:AddTab({ Name = "Home", Icon = "home" })

home:AddSection("Welcome")
home:AddParagraph("Enable the toggles below, then hit Run.")

home:AddToggle({ Text = "Auto Farm", Default = false,
    Callback = function(on) print("Auto Farm:", on) end })

home:AddSlider({ Text = "Walk Speed", Min = 16, Max = 200, Default = 16, Step = 2,
    Callback = function(v)
        local char = game.Players.LocalPlayer.Character
        local hum  = char and char:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = v end
    end })

home:AddButton({ Text = "Run", Variant = "default", Icon = "play",
    Callback = function()
        Window:ShowSuccess({ Title = "Done", Message = "Script ran." })
    end })

-- Info tab
local info = Window:AddTab({ Name = "Info", Icon = "info" })

info:AddLabel("Hub status")
info:AddSeparator()
info:AddParagraph("All systems nominal.")
```

---

## 2. Settings tab with Flags + Reset button

Flags require `Config = { Enabled = true, ... }` at window creation AND executor file functions (`writefile`, `readfile`, etc.).

```lua
local EzUI = loadstring(game:HttpGet(
    "https://github.com/alfin-efendy/ez-rbx-ui/releases/latest/download/ez-rbx-ui.lua"
))()

local Window = EzUI:CreateWindow({
    Title    = "My Hub",
    Subtitle = "v1.0",
    Ratio    = 16 / 10,
    ToggleKey = Enum.KeyCode.RightControl,
    FloatingToggle = { Type = "simple", AutoHide = true },
    Config = { Enabled = true, FileName = "MyHub", AutoSave = true, AutoLoad = true },
})

local settings = Window:AddTab({ Name = "Settings", Icon = "settings-2" })

settings:AddSection("Gameplay")

settings:AddToggle({ Text = "Auto Farm", Flag = "autofarm", Default = false,
    Description = "Automatically farms resources.",
    Callback = function(on) print("Auto Farm:", on) end })

settings:AddSlider({ Text = "Walk Speed", Min = 16, Max = 200, Default = 16,
    Flag = "walkspeed", Step = 2,
    Callback = function(v) print("Walk Speed:", v) end })

settings:AddToggle({ Text = "Infinite Jump", Flag = "infjump", Default = false,
    Callback = function(on) print("Infinite Jump:", on) end })

settings:AddSection("Danger Zone")

-- Option A: built-in shortcut — no callback needed
settings:AddButton({
    Text    = "Reset Settings",
    Variant = "destructive",
    Icon    = "rotate-ccw",
    Action  = "ResetConfig",   -- triggers Window:ResetConfiguration() automatically
})

-- Option B: call directly (shows confirm dialog, then restores all flags to defaults)
-- settings:AddButton({ Text = "Reset Settings", Variant = "destructive",
--     Callback = function() Window:ResetConfiguration({ Confirm = true }) end })
```

---

## 3. Searchable multi-select SelectBox with OnOpen refresh

`OnOpen(api)` is called each time the dropdown opens, letting you refresh the option list (e.g. from a server call). `api.SetOptions(list)` updates the list in place.

```lua
local EzUI = loadstring(game:HttpGet(
    "https://github.com/alfin-efendy/ez-rbx-ui/releases/latest/download/ez-rbx-ui.lua"
))()

local Window = EzUI:CreateWindow({
    Title = "Weapon Selector",
    Ratio = 16 / 10,
    ToggleKey = Enum.KeyCode.RightControl,
    FloatingToggle = { Type = "simple", AutoHide = true },
})

local tab = Window:AddTab({ Name = "Loadout", Icon = "sword" })

-- Simulated database — replace with your actual data source
local WEAPON_DB = {
    { Value = "wpn_001", Text = "Bow",    Icon = "target" },
    { Value = "wpn_002", Text = "Shield", Icon = "shield" },
    { Value = "wpn_003", Text = "Sword",  Icon = "sword" },
    { Value = "wpn_004", Text = "Staff",  Icon = "wand-2" },
    { Value = "wpn_005", Text = "Dagger", Icon = "scissors" },
    { Value = "wpn_006", Text = "Axe",    Icon = "axe" },
}

local weaponSelect = tab:AddSelectBox({
    Text       = "Weapons",
    Multi      = true,         -- allow picking more than one
    Searchable = true,         -- search box shown (also auto-shows for lists > 5 items)
    Loading    = true,         -- start in spinner state while we "fetch" data
    Options    = {},           -- empty until OnOpen fires
    OnOpen     = function(api)
        -- Called every time the dropdown opens.
        -- Replace the body with a real async fetch if needed.
        api.SetOptions(WEAPON_DB)
    end,
    Callback = function(values)
        -- values is a table of selected Values (e.g. {"wpn_001","wpn_003"})
        print("Selected:", table.concat(values, ", "))
    end,
})

-- Simulate initial async load
task.delay(1, function()
    weaponSelect.SetOptions(WEAPON_DB)
    weaponSelect.SetLoading(false)
end)

tab:AddButton({ Text = "Equip selected", Icon = "check", Callback = function()
    local selected = weaponSelect.GetValue()
    if not selected or #selected == 0 then
        Window:ShowWarning({ Title = "Nothing selected", Message = "Pick at least one weapon." })
    else
        Window:ShowSuccess({ Title = "Equipped", Message = table.concat(selected, ", ") })
    end
end })
```

---

## 4. Notification + confirmation Dialog flow

```lua
local EzUI = loadstring(game:HttpGet(
    "https://github.com/alfin-efendy/ez-rbx-ui/releases/latest/download/ez-rbx-ui.lua"
))()

local Window = EzUI:CreateWindow({
    Title = "My Hub",
    Ratio = 16 / 10,
    ToggleKey = Enum.KeyCode.RightControl,
    FloatingToggle = { Type = "simple", AutoHide = true },
})

local tab = Window:AddTab({ Name = "Actions", Icon = "zap" })

tab:AddSection("Notifications")

tab:AddButton({ Text = "Show success", Callback = function()
    Window:ShowSuccess({ Title = "Saved", Message = "All settings saved." })
end })

tab:AddButton({ Text = "Show warning", Variant = "secondary", Callback = function()
    Window:ShowWarning({ Title = "Low health!", Message = "HP below 20%." })
end })

tab:AddButton({ Text = "Show error", Variant = "destructive", Callback = function()
    Window:ShowError({ Title = "Script failed", Message = "Check the output." })
end })

tab:AddButton({ Text = "Notify with Undo", Variant = "outline", Callback = function()
    -- Notify returns an id you can use to dismiss it programmatically
    local id = Window:Notify({
        Title    = "Item deleted",
        Message  = "Removed from inventory.",
        Type     = "warning",
        Duration = 6000,
        Action   = { Text = "Undo", Callback = function()
            Window:ShowSuccess({ Title = "Restored", Message = "Item returned." })
        end },
        OnDismiss = function() print("toast dismissed") end,
    })
    -- Dismiss after 3s if you want to cancel early:
    -- task.delay(3, function() Window:DismissNotification(id) end)
end })

tab:AddSection("Dialog")

tab:AddButton({ Text = "Delete item", Variant = "destructive", Icon = "trash-2",
    Callback = function()
        Window:Dialog({
            Title   = "Delete item?",
            Message = "This cannot be undone.",
            Buttons = {
                { Text = "Cancel", Variant = "secondary" },
                { Text = "Delete", Variant = "destructive", Callback = function()
                    Window:ShowSuccess({ Title = "Deleted", Message = "Item removed." })
                end },
            },
        })
    end })

tab:AddButton({ Text = "Confirm action", Variant = "outline", Icon = "check-circle",
    Callback = function()
        Window:Dialog({
            Title   = "Are you sure?",
            Message = "This will start the farm sequence.",
            Buttons = {
                { Text = "Cancel" },
                { Text = "Confirm", Variant = "default", Callback = function()
                    Window:ShowInfo({ Title = "Started", Message = "Farm sequence running." })
                end },
            },
        })
    end })
```

---

## 5. Themed window (override `primary`)

Pass a partial `Theme` table — it is deep-merged onto defaults. Only what you override changes.

```lua
local EzUI = loadstring(game:HttpGet(
    "https://github.com/alfin-efendy/ez-rbx-ui/releases/latest/download/ez-rbx-ui.lua"
))()

-- Indigo accent, slightly tighter corners, faster motion
local Window = EzUI:CreateWindow({
    Title    = "Themed Hub",
    Subtitle = "Indigo accent",
    Ratio    = 16 / 10,
    ToggleKey = Enum.KeyCode.RightControl,
    FloatingToggle = { Type = "circle", AutoHide = true },
    Theme = {
        Colors = {
            primary            = Color3.fromRGB(99, 102, 241),  -- indigo-500
            primaryForeground  = Color3.fromRGB(255, 255, 255), -- white text on primary
        },
        Radius = {
            lg     = 6,   -- buttons, cards (default 10)
            window = 8,   -- window frame (default 12)
        },
        Motion = {
            fast = 0.08,  -- snappier micro-interactions (default 0.12)
            base = 0.14,  -- standard transitions (default 0.18)
        },
    },
})

local tab = Window:AddTab({ Name = "Home", Icon = "home" })

tab:AddSection("Theme demo")
tab:AddParagraph("Buttons and toggles use the indigo primary. All other tokens stay at zinc-dark defaults.")

tab:AddToggle({ Text = "Auto Farm", Default = false,
    Callback = function(on) print(on) end })

tab:AddButton({ Text = "Primary button", Variant = "default", Icon = "play",
    Callback = function() Window:ShowSuccess({ Title = "Clicked" }) end })

tab:AddButton({ Text = "Secondary", Variant = "secondary",
    Callback = function() Window:ShowInfo({ Title = "Secondary" }) end })

-- Switch to light mode at runtime
tab:AddButton({ Text = "Toggle light / dark", Variant = "outline", Icon = "sun",
    Callback = function()
        local next = Window:GetMode() == "dark" and "light" or "dark"
        Window:SetMode(next)
    end })
```

---

## 6. Mobile floating toggle (`FloatingToggle = { Type = "simple", AutoHide = true }`)

The floating button lets players reopen the window on touch devices. `AutoHide = true` means it only appears while the window is hidden.

```lua
local EzUI = loadstring(game:HttpGet(
    "https://github.com/alfin-efendy/ez-rbx-ui/releases/latest/download/ez-rbx-ui.lua"
))()

local Window = EzUI:CreateWindow({
    Title    = "Mobile Hub",
    Subtitle = "Touch-friendly",
    Ratio    = 4 / 3,  -- taller ratio works better on portrait phones
    ToggleKey = Enum.KeyCode.RightControl,  -- keyboard fallback on PC
    FloatingToggle = {
        Type      = "simple",   -- chevron tab that docks at the screen edge
        AutoHide  = true,       -- appears only while the window is hidden
        Draggable = true,       -- player can drag it to any edge (default true)
        Position  = "MidLeft",  -- default for "simple" type
    },
})

local tab = Window:AddTab({ Name = "Home", Icon = "home" })

tab:AddSection("Floating toggle demo")
tab:AddParagraph("Close the window (X button or RightControl). The tab reappears on the left edge. Drag it up or down to reposition.")

tab:AddButton({ Text = "Hide window", Variant = "secondary", Icon = "x",
    Callback = function()
        -- Minimize shows the floating toggle and hides the window.
        Window:Minimize()
    end })

-- Switch to a circle button at runtime
tab:AddButton({ Text = "Switch to circle FAB", Variant = "outline", Icon = "circle",
    Callback = function()
        Window:SetFloatingToggle({
            Type     = "circle",
            Position = "BottomRight",
            AutoHide = true,
        })
        Window:ShowInfo({ Title = "FAB updated" })
    end })

-- Switch back to simple
tab:AddButton({ Text = "Switch back to simple", Variant = "ghost", Callback = function()
    Window:SetFloatingToggle({ Type = "simple", AutoHide = true })
end })
```
