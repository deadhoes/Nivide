local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local NotificationLib = {}
NotificationLib.__index = NotificationLib

NotificationLib.Styles = {
    Modern = {
        Duration = 4,
        Size = UDim2.new(0, 360, 0, 90),
        Position = UDim2.new(1, -20, 0, 20),
        BackgroundColor = Color3.fromRGB(25, 25, 30),
        BackgroundTransparency = 0.1,
        TextColor = Color3.fromRGB(240, 240, 240),
        AccentColor = Color3.fromRGB(0, 162, 255),
        Font = Enum.Font.GothamSemibold,
        TitleSize = 18,
        DescriptionSize = 14,
        CornerRadius = 8,
        BorderSize = 1,
        BorderColor = Color3.fromRGB(60, 60, 70),
        IconSize = 24,
        IconColor = Color3.fromRGB(240, 240, 240),
        IconTransparency = 0,
        StackSpacing = 10
    }
}

function NotificationLib.Init()
    local self = setmetatable({}, NotificationLib)
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "ModernNotificationGui"
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = game:GetService("CoreGui")
    self.ActiveNotifications = {}
    return self
end

function NotificationLib:AddNotification(options)
    local config = table.clone(NotificationLib.Styles.Modern)
    for k,v in pairs(options) do
        if k ~= "Style" then
            config[k] = v
        end
    end

    local notification = Instance.new("Frame")
    notification.Size = config.Size
    notification.Position = UDim2.new(1, 20, 0, config.Position.Y.Offset)
    notification.AnchorPoint = Vector2.new(1, 0)
    notification.BackgroundColor3 = config.BackgroundColor
    notification.BackgroundTransparency = config.BackgroundTransparency
    notification.BorderSizePixel = 0
    notification.Parent = self.ScreenGui

    local uICorner = Instance.new("UICorner")
    uICorner.CornerRadius = UDim.new(0, config.CornerRadius)
    uICorner.Parent = notification

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 4, 1, 0)
    accentBar.BackgroundColor3 = config.AccentColor
    accentBar.BorderSizePixel = 0
    accentBar.Parent = notification

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, config.IconSize, 0, config.IconSize)
    icon.Position = UDim2.new(0, 15, 0.5, 0)
    icon.AnchorPoint = Vector2.new(0, 0.5)
    icon.BackgroundTransparency = 1
    icon.ImageColor3 = config.IconColor
    icon.ImageTransparency = 1
    icon.Parent = notification

    if config.Icon then
        icon.Image = "rbxassetid://"..config.Icon
    end

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -(config.IconSize + 30), 1, 0)
    content.Position = UDim2.new(0, config.IconSize + 25, 0, 0)
    content.BackgroundTransparency = 1
    content.Parent = notification

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Font = config.Font
    title.TextSize = config.TitleSize
    title.TextColor3 = config.TextColor
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = config.Title
    title.TextTransparency = 1
    title.Parent = content

    local description = Instance.new("TextLabel")
    description.Size = UDim2.new(1, 0, 1, -40)
    description.Position = UDim2.new(0, 0, 0, 35)
    description.BackgroundTransparency = 1
    description.Font = config.Font
    description.TextSize = config.DescriptionSize
    description.TextColor3 = config.TextColor
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.TextYAlignment = Enum.TextYAlignment.Top
    description.Text = config.Description
    description.TextWrapped = true
    description.TextTransparency = 1
    description.Parent = content

    -- Stack notifications
    local totalHeight = 0
    for _, notif in ipairs(self.ActiveNotifications) do
        totalHeight += notif.Size.Y.Offset + config.StackSpacing
    end
    notification.Position = UDim2.new(1, 20, 0, config.Position.Y.Offset + totalHeight)
    table.insert(self.ActiveNotifications, notification)

    local function animate()
        local enterTween = TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Position = UDim2.new(1, -20, 0, config.Position.Y.Offset + totalHeight)
        })
        enterTween:Play()
        
        task.wait(0.2)
        
        TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        TweenService:Create(description, TweenInfo.new(0.3), {TextTransparency = 0.2}):Play()
        if config.Icon then
            TweenService:Create(icon, TweenInfo.new(0.3), {ImageTransparency = config.IconTransparency}):Play()
        end
        
        task.wait(config.Duration)
        
        local exitTween = TweenService:Create(notification, TweenInfo.new(0.3), {
            Position = UDim2.new(1, 20, 0, config.Position.Y.Offset + totalHeight)
        })
        exitTween:Play()
        exitTween.Completed:Wait()
        
        for i, notif in ipairs(self.ActiveNotifications) do
            if notif == notification then
                table.remove(self.ActiveNotifications, i)
                break
            end
        end
        
        notification:Destroy()
    end
    
    task.spawn(animate)
end

return NotificationLib
