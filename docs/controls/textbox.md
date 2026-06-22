# TextBox

A single-line text input with a rich set of addons. The input box can carry a leading icon, text prefix/suffix, inline action buttons, a password reveal toggle, a clear button, a copy button, a loading spinner, and live validation. When `FullWidth` is set, the label stacks above the input instead of sitting beside it, giving the addons more horizontal room.

## Basic usage

```lua
local tb = tab:AddTextBox({
  Text        = "Name",
  Placeholder = "Type your name…",
})
print(tb.GetText())
```

## Options

| Key | Type | Default | Notes |
|---|---|---|---|
| `Text` | `string` | — | Row label. Omit for a label-less input that spans the full width. |
| `Default` | `string` | `""` | Initial text value. |
| `Placeholder` | `string` | `""` | Ghost text shown when the input is empty. |
| `Description` | `string` | — | Muted secondary line rendered below the label. |
| `MaxLength` | `number` | — | Silently truncates input beyond this character count. |
| `Copyable` | `boolean` | `false` | Makes the field read-only and adds a copy icon button. |
| `LeadingIcon` | `string` | — | Lucide icon name rendered at the left edge of the input box (e.g. `"search"`, `"lock"`). |
| `Prefix` | `string` | — | Non-editable text rendered immediately before the caret (e.g. `"$"`, `"https://"`). |
| `Suffix` | `string` | — | Non-editable text rendered immediately after the editable area (e.g. `"USD"`, `".com"`). |
| `TrailingIcon` | `string` | — | Lucide icon name rendered at the trailing (right) edge of the input box, after any `Suffix`. Behaves like `LeadingIcon` on the opposite side. No dedicated built-in example; usage mirrors `LeadingIcon`. |
| `Loading` | `boolean` | `false` | When `true`, the field starts in the loading/spinner state at construction — identical to calling `SetLoading(true)` immediately after creation. |
| `FullWidth` | `boolean` | `false` | Stacks the label above the input box instead of placing them side-by-side. Recommended when `Prefix`/`Suffix`/`Buttons` need room. |
| `Password` | `boolean` | `false` | Masks the value with `•` characters and adds an eye/eye-off reveal button. `GetText()` always returns the real value. |
| `Clearable` | `boolean` | `false` | Shows an `×` icon button when the field is non-empty; clicking it clears the value. |
| `Disabled` | `boolean` | `false` | Makes the field non-editable and dims the text. |
| `Buttons` | `{ { Icon?\|Text?, Tooltip?, Variant?, Callback? } }` | — | List of compact action buttons appended at the right of the input. Each entry is either an icon button (`Icon`) or a text button (`Text`). `Callback(text, ctl)` receives the current text and the control API. |
| `Validate` | `function(text) -> (ok, message)` | — | Called on focus-loss. When it returns `false` the border turns red and `message` is shown beneath the box; returning `true` clears any error state. |
| `Flag` | `string` | — | Config key used to persist the value across sessions. |
| `Callback` | `function(text, ctl)` | — | Called on focus-loss with the current text and the control API. |

## API

| Method | Returns | Notes |
|---|---|---|
| `GetText()` | `string` | Returns the current text value (unmasked even in password mode). |
| `SetText(s)` | `nil` | Sets the text, re-runs `Validate`, and fires `Callback`. |
| `Focus()` | `nil` | Programmatically focuses the input. |
| `Clear()` | `nil` | Clears the text without firing `Callback`. |
| `SetLoading(b)` | `nil` | Shows/hides the spinning loader icon at the right of the input. |
| `SetValid()` | `nil` | Clears any invalid state (removes the red border and message). |
| `SetInvalid(msg)` | `nil` | Marks the input as invalid: red border + message beneath the box. |
| `SetDisabled(b)` | `nil` | Toggles the disabled (read-only + dimmed) state at runtime. |
| `Destroy()` | `nil` | Removes the control from the UI. |

## Examples

```lua
-- Basic inputs
tab:AddTextBox({ Text = "Name", Placeholder = "Type your name…" })

tab:AddTextBox({
  Text        = "With description",
  Description = "Helper text under the label.",
  Placeholder = "…",
})

-- Read-only with a built-in copy button
tab:AddTextBox({ Text = "Key", Default = "EZUI-DEMO", Copyable = true })

-- Input group: leading icon + prefix/suffix (FullWidth for more room)
tab:AddTextBox({
  Text        = "Website",
  FullWidth   = true,
  LeadingIcon = "link",
  Prefix      = "https://",
  Suffix      = ".com",
  Placeholder = "your-site",
})

tab:AddTextBox({ Text = "Price", Prefix = "$", Suffix = "USD", Placeholder = "0.00" })

-- Clearable + custom icon button
tab:AddTextBox({
  Text      = "Token",
  Default   = "sk-demo-123",
  Clearable = true,
  Buttons   = {
    {
      Icon     = "copy",
      Tooltip  = "Copy",
      Callback = function(text)
        if setclipboard then pcall(setclipboard, text) end
        window:ShowSuccess({ Title = "Copied", Message = text })
      end,
    },
  },
})

-- Text button that clears the field after use
tab:AddTextBox({
  Text        = "Message",
  FullWidth   = true,
  LeadingIcon = "mail",
  Placeholder = "Say something…",
  Buttons     = {
    {
      Text     = "Send",
      Variant  = "default",
      Callback = function(text, ctl)
        window:ShowSuccess({ Title = "Sent", Message = text ~= "" and text or "(empty)" })
        ctl.Clear()
      end,
    },
  },
})

-- Password field with reveal toggle
tab:AddTextBox({
  Text        = "Password",
  LeadingIcon = "lock",
  Password    = true,
  Placeholder = "••••••••",
})

-- Live validation on focus-loss
tab:AddTextBox({
  Text        = "Email",
  FullWidth   = true,
  LeadingIcon = "mail",
  Placeholder = "you@example.com",
  Validate    = function(t)
    return t:match("^[^@%s]+@[^@%s]+%.[^@%s]+$") ~= nil, "Enter a valid email address"
  end,
})

-- Async availability check driven from a button
tab:AddTextBox({
  Text        = "Username",
  LeadingIcon = "user",
  Placeholder = "pick a handle",
  Buttons     = {
    {
      Icon    = "check",
      Tooltip = "Check availability",
      Callback = function(text, ctl)
        ctl.SetLoading(true)
        task.delay(0.8, function()
          ctl.SetLoading(false)
          if #text > 2 then ctl.SetValid() else ctl.SetInvalid("Too short") end
        end)
      end,
    },
  },
})

-- Disabled (read-only + dimmed)
tab:AddTextBox({ Text = "Locked", Default = "read-only", Disabled = true })

-- Flag-bound — value persists across sessions
tab:AddTextBox({ Text = "Saved note", Flag = "ex_textbox", Default = "hello" })
```
