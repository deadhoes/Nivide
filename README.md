```markdown
# Nivide

**A customizable notification system for Roblox games.**  
📢 Easily display clean, animated notifications with custom appearance and interaction.

---

## 🌐 One-Line Loader

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/deadhoes/Nivide/refs/heads/main/init.lua"))()
```

> ✅ No setup required — just paste and use.

---

## 🚀 Example Usage

```lua
local notif = Nivide.new({
    title = "Welcome!",
    description = "Thanks for playing our game 🎉",
    duration = 6,
    bgColor = Color3.fromRGB(240, 240, 240),
    titleColor = Color3.fromRGB(30, 30, 30),
    descColor = Color3.fromRGB(90, 90, 90),
    timerColor = Color3.fromRGB(255, 100, 100),
    titleFont = Enum.Font.GothamBold,
    descFont = Enum.Font.Gotham,
    titleSize = 18,
    descSize = 14
})

notif.setCallback(function()
    print("Notification clicked!")
end)
```

---

## ✨ Features

- 🔧 **Fully customizable** (text, color, font, layout)
- ⏲️ **Auto-dismiss** after your desired duration
- 🖱️ **Clickable** with `.setCallback()`
- 🔁 **Updateable** at runtime with `.update()`
- 📦 Compact, fast, and zero dependencies
- 🧠 Smart default values

---

## ⚙️ Settings Table

Pass a settings table to `Nivide.new({ ... })`:

| Key           | Type        | Default Value                    | Description                            |
|---------------|-------------|----------------------------------|----------------------------------------|
| `title`       | `string`    | `"Title"`                        | The title text                         |
| `description` | `string`    | `"Description"`                  | The description text                   |
| `duration`    | `number`    | `5`                              | Seconds before it fades out           |
| `bgColor`     | `Color3`    | `Color3.fromRGB(255,255,255)`    | Background color                       |
| `titleColor`  | `Color3`    | `Color3.fromRGB(40,40,40)`       | Title text color                       |
| `descColor`   | `Color3`    | `Color3.fromRGB(120,120,120)`    | Description text color                 |
| `timerColor`  | `Color3`    | `Color3.fromRGB(110,158,246)`    | Timer bar color                        |
| `position`    | `UDim2`     | `UDim2.new(0.248, 0, 0.25, 0)`   | Notification position on screen        |
| `size`        | `UDim2`     | `UDim2.new(0, 222, 0, 102)`      | Frame size                             |
| `titleFont`   | `Enum.Font` | `Enum.Font.Unknown`              | Title font                             |
| `descFont`    | `Enum.Font` | `Enum.Font.Unknown`              | Description font                       |
| `titleSize`   | `number`    | `16`                             | Title text size                        |
| `descSize`    | `number`    | `14`                             | Description text size                  |

---

## 🧩 API Reference

All notification objects return these methods:

| Method                     | Description                                      |
|----------------------------|--------------------------------------------------|
| `:setCallback(function)`   | Runs when notification is clicked                |
| `:update(newTitle, desc)`  | Updates the notification title and description   |
| `:destroy()`               | Immediately removes the notification             |
| `:getGui()`                | Returns the internal `ScreenGui` instance        |

---
