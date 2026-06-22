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
local id = window:Notify({ Title = "Loading…", Duration = math.huge })
-- later:
window:DismissNotification(id)
```

To clear all active notifications at once:

```lua
window:ClearNotifications()
```

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

### Button Descriptor

| Key | Type | Notes |
|---|---|---|
| `Text` | `string` | Button label |
| `Variant` | `string` | `"default"`, `"secondary"`, `"outline"`, `"ghost"`, `"destructive"` |
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
