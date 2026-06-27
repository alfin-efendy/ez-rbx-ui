# Notifications & Dialog

EzUI provides toast notifications and a modal dialog — both are methods on the window object.

## Notifications

### Shorthand Methods

Use the typed helpers for common notification states:

```lua
window:ShowSuccess({ Title = "Saved", Message = "All good." })
window:ShowWarning({ Title = "Careful" })
window:ShowError({ Title = "Failed" })
window:ShowInfo({ Title = "Heads up" })
```

### `Notify(opts)`

For full control, use `Notify` directly:

```lua
window:Notify({
    Title = "Item deleted",
    Type = "warning",
    Duration = 5000,
    Action = {
        Text = "Undo",
        Callback = function()
            window:ShowSuccess({ Title = "Restored" })
        end
    },
    OnDismiss = function()
        print("notification dismissed")
    end
})
```

### Notification Options

| Key | Type | Default | Description |
|---|---|---|---|
| `Title` | `string` | required | Notification heading |
| `Message` | `string` | `nil` | Optional body text |
| `Type` | `string` | `"default"` | One of `"success"`, `"warning"`, `"error"`, `"info"` |
| `Duration` | `number` | `4000` | Auto-dismiss delay in milliseconds |
| `Action` | `{ Text, Callback }` | `nil` | Optional action button shown in the toast |
| `OnDismiss` | `function` | `nil` | Called when the toast is dismissed |

Toasts have a countdown indicator that pauses while the cursor is hovering over them.

### Dismissing Notifications

`Notify` returns an id. Use it to dismiss a specific notification programmatically:

```lua
local id = window:ShowLoading({ Title = "Loading…" })
-- later, when the work is done:
window:DismissNotification(id)
```

To clear all active notifications at once:

```lua
window:ClearNotifications()
```

### Loading & Promise Toasts

`ShowLoading` shows a persistent toast with a spinner and **no countdown** — it stays until you dismiss it. It returns an id for `DismissNotification`:

```lua
local id = window:ShowLoading({ Title = "Saving…" })
-- later, when your work finishes:
window:DismissNotification(id)
```

For async work, `Promise` does this for you: it shows a loading toast, runs a function that may **yield** (HTTP, datastore, `task.wait`), then morphs the toast into success or error when the function returns or errors.

```lua
window:Promise(function()
    local res = game:HttpGet(url)            -- yields
    return game:GetService("HttpService"):JSONDecode(res)
end, {
    Loading = "Loading data…",
    Success = function(data) return "Loaded " .. #data .. " items" end,
    Error   = function(err) return "Failed: " .. tostring(err) end,
    Finally = function() print("done") end,   -- optional, runs either way
})
```

`Success` and `Error` may each be a plain string or a function that receives the resolved value / error and returns the message. `Promise` returns the toast id.

#### Promise Options

| Key | Type | Default | Description |
|---|---|---|---|
| `Loading` | `string` | `"Loading…"` | Title shown while the function runs |
| `Success` | `string` \| `function(result)` | `"Success"` | Title after the function returns; a function receives the returned value |
| `Error` | `string` \| `function(err)` | `"Error"` | Title after the function errors; a function receives the error |
| `Finally` | `function` | `nil` | Called after the promise settles, on success or error |
| `Duration` | `number` | `4000` | Auto-dismiss delay (ms) for the success/error state |
| `Message` | `string` | `nil` | Optional body text on the loading toast |

### Notification Position

Toasts stack in the bottom-right corner by default. Change the corner globally with `SetNotificationPosition`, or set it once at creation with the `NotificationPosition` config key:

```lua
-- at creation
local window = EzUI:CreateWindow({ NotificationPosition = "top-right" })

-- or live at runtime
window:SetNotificationPosition("Top Center")
```

`pos` is one of `"top-left"`, `"top-center"`, `"top-right"`, `"bottom-left"`, `"bottom-center"`, `"bottom-right"` — case- and space-insensitive, so `"Top Center"` also works. Top positions stack downward, bottom positions stack upward; the default is `"bottom-right"`.

### Demo from the Example

```lua
-- From example/menu/components/notification.lua
local tab = window:AddTab({ Name = "Notification", Icon = "bell" })
tab:AddSection("Toasts")
tab:AddButton({ Text = "Success", Callback = function()
    window:ShowSuccess({ Title = "Saved", Message = "All good." })
end })
tab:AddButton({ Text = "Warning", Variant = "secondary", Callback = function()
    window:ShowWarning({ Title = "Careful" })
end })
tab:AddButton({ Text = "Error", Variant = "destructive", Callback = function()
    window:ShowError({ Title = "Failed" })
end })
tab:AddButton({ Text = "Info", Variant = "outline", Callback = function()
    window:ShowInfo({ Title = "Heads up" })
end })
tab:AddButton({ Text = "With action", Variant = "ghost", Callback = function()
    window:Notify({
        Title = "Item deleted",
        Type = "warning",
        Action = { Text = "Undo", Callback = function()
            window:ShowSuccess({ Title = "Restored" })
        end }
    })
end })
tab:AddButton({ Text = "Promise", Callback = function()
    window:Promise(function() task.wait(1.5); return true end,
        { Loading = "Saving…", Success = "Saved!", Error = "Failed to save" })
end })
```

---

## Dialog

`window:Dialog(opts)` opens a dimmed modal overlay with a title, optional message, and one or more buttons.

```lua
window:Dialog({
    Title = "Delete item?",
    Message = "This cannot be undone.",
    Buttons = {
        { Text = "Cancel", Variant = "secondary" },
        { Text = "Delete", Variant = "destructive", Callback = function()
            window:ShowSuccess({ Title = "Deleted" })
        end }
    }
})
```

### Dialog Options

| Key | Type | Default | Description |
|---|---|---|---|
| `Title` | `string` | required | Dialog heading |
| `Message` | `string` | `nil` | Optional body text |
| `Buttons` | `array` | required | One or more button descriptors |
| `Modal` | `bool` | `true` | Dim the background while the dialog is open |
| `Icon` | `string` | `nil` | Optional Lucide icon in the header |
| `IconColor` | `Color3` | title color | Override the header-icon tint |
| `IconBadge` | `bool` | `false` | `true` renders the icon in a tinted badge above a centered header; `false` shows it inline before the title |
| `Width` | `number` | `320` | Card width in px, clamped to the viewport/window minus margins |

The footer right-aligns its buttons on desktop and stacks them full-width (primary action on top) on touch devices.

### Button Descriptor

| Key | Type | Notes |
|---|---|---|
| `Text` | `string` | Button label |
| `Variant` | `string` | `"default"`, `"secondary"`, `"outline"`, `"ghost"`, `"destructive"` |
| `Icon` | `string` | Optional Lucide icon shown on the button |
| `Callback` | `function` | Called when the button is clicked; the dialog closes automatically |

### Demo from the Example

```lua
-- From example/menu/components/dialog.lua
local tab = window:AddTab({ Name = "Dialog", Icon = "message-square" })
tab:AddSection("Modal dialog")
tab:AddButton({ Text = "Open dialog", Callback = function()
    window:Dialog({
        Title = "Delete item?",
        Message = "This cannot be undone.",
        Buttons = {
            { Text = "Cancel", Variant = "secondary" },
            { Text = "Delete", Variant = "destructive", Callback = function()
                window:ShowSuccess({ Title = "Deleted" })
            end }
        }
    })
end })
```
