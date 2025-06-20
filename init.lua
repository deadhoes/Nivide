local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local NotificationLib = {}
NotificationLib.__index = NotificationLib

NotificationLib.Styles = {
    Pixel = {
        DefaultDuration = 4,
        Size = UDim2.new(0, 320, 0, 80),
        Position = UDim2.new(1, -10, 0, 10),
        BackgroundColor = Color3.fromRGB(40, 40, 45),
        BackgroundTransparency = 0,
        TextColor = Color3.fromRGB(255, 255, 255),
        AccentColor = Color3.fromRGB(100, 200, 100),
        Font = Enum.Font.SciFi,
        TitleSize = 16,
        DescriptionSize = 14,
        CornerRadius = 0,
        BorderSize = 2,
        BorderColor = Color3.fromRGB(80, 80, 80),
        IconSize = 20,
        IconColor = Color3.fromRGB(255, 255, 255),
        StackSpacing = 8,
        PixelEffect = true
    },
    Classic = {
        DefaultDuration = 5,
        Size = UDim2.new(0, 350, 0, 90),
        Position = UDim2.new(1, -20, 0, 20),
        BackgroundColor = Color3.fromRGB(60, 60, 70),
        BackgroundTransparency = 0.1,
        TextColor = Color3.fromRGB(240, 240, 240),
        AccentColor = Color3.fromRGB(0, 120, 215),
        Font = Enum.Font.SourceSansBold,
        TitleSize = 18,
        DescriptionSize = 14,
        CornerRadius = 4,
        BorderSize = 1,
        BorderColor = Color3.fromRGB(100, 100, 110),
        IconSize = 24,
        StackSpacing = 10
    },
    Nvidia = {
        DefaultDuration = 4,
        Size = UDim2.new(0, 380, 0, 100),
        Position = UDim2.new(1, -25, 0, 25),
        BackgroundColor = Color3.fromRGB(20, 20, 25),
        BackgroundTransparency = 0.15,
        TextColor = Color3.fromRGB(230, 230, 230),
        AccentColor = Color3.fromRGB(118, 185, 0),
        Font = Enum.Font.GothamBold,
        TitleSize = 18,
        DescriptionSize = 15,
        CornerRadius = 8,
        BorderSize = 1,
        BorderColor = Color3.fromRGB(60, 60, 70),
        IconSize = 28,
        IconColor = Color3.fromRGB(118, 185, 0),
        StackSpacing = 12,
        GlowEffect = true,
        ParticleEffect = true
    }
}

function NotificationLib.Init()
    local self = setmetatable({}, NotificationLib)
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "NotificationSystem"
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = game:GetService("CoreGui")
    self.ActiveNotifications = {}
    return self
end

local function createPixelEffect(frame)
    local pixelGrid = Instance.new("Frame")
    pixelGrid.Size = UDim2.new(1, 0, 1, 0)
    pixelGrid.BackgroundTransparency = 1
    pixelGrid.Parent = frame
    
    for i = 0, 15 do
        for j = 0, 9 do
            local pixel = Instance.new("Frame")
            pixel.Size = UDim2.new(0, 20, 0, 8)
            pixel.Position = UDim2.new(0, i * 20, 0, j * 8)
            pixel.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            pixel.BorderSizePixel = 0
            pixel.Parent = pixelGrid
        end
    end
end

local function createGlowEffect(frame, color)
    local glow = Instance.new("ImageLabel")
    glow.Name = "GlowEffect"
    glow.Size = UDim2.new(1.5, 0, 1.5, 0)
    glow.Position = UDim2.new(0.5, 0, 0.5, 0)
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://7131988516"
    glow.ImageColor3 = color
    glow.ImageTransparency = 0.8
    glow.ZIndex = -1
    glow.Parent = frame
    return glow
end

function NotificationLib:AddNotification(options)
    local style = options.Style or "Classic"
    local config = table.clone(NotificationLib.Styles[style] or NotificationLib.Styles.Classic)
    
    -- Apply custom duration or use style default
    config.Duration = options.Duration or config.DefaultDuration
    
    for k,v in pairs(options) do
        if k ~= "Style" and k ~= "Duration" then
            config[k] = v
        end
    end

    local notification = Instance.new("Frame")
    notification.Size = config.Size
    notification.Position = UDim2.new(1, 20, 0, config.Position.Y.Offset)
    notification.AnchorPoint = Vector2.new(1, 0)
    notification.BackgroundColor3 = config.BackgroundColor
    notification.BackgroundTransparency = config.BackgroundTransparency
    notification.BorderSizePixel = config.BorderSize
    notification.BorderColor3 = config.BorderColor
    notification.Parent = self.ScreenGui

    if config.CornerRadius > 0 then
        local uICorner = Instance.new("UICorner")
        uICorner.CornerRadius = UDim.new(0, config.CornerRadius)
        uICorner.Parent = notification
    end

    if config.PixelEffect then
        createPixelEffect(notification)
    end

    if config.GlowEffect then
        createGlowEffect(notification, config.AccentColor)
    end

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 4, 1, 0)
    accentBar.BackgroundColor3 = config.AccentColor
    accentBar.BorderSizePixel = 0
    accentBar.Parent = notification

    if config.Icon then
        local icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(0, config.IconSize, 0, config.IconSize)
        icon.Position = UDim2.new(0, 15, 0.5, 0)
        icon.AnchorPoint = Vector2.new(0, 0.5)
        icon.BackgroundTransparency = 1
        icon.Image = "rbxassetid://"..config.Icon
        icon.ImageColor3 = config.IconColor or config.TextColor
        icon.Parent = notification
    end

    local content = Instance.new("Frame")
    content.Size = config.Icon and UDim2.new(1, -(config.IconSize + 30), 1, 0) or UDim2.new(1, -20, 1, 0)
    content.Position = config.Icon and UDim2.new(0, config.IconSize + 25, 0, 0) or UDim2.new(0, 15, 0, 0)
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
    title.Text = options.Title or "Notification"
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
    description.Text = options.Description or ""
    description.TextWrapped = true
    description.TextTransparency = 1
    description.Parent = content

    local totalHeight = 0
    for _, notif in ipairs(self.ActiveNotifications) do
        totalHeight += notif.Size.Y.Offset + config.StackSpacing
    end
    table.insert(self.ActiveNotifications, notification)

    local function animate()
        local enterTween = TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Position = UDim2.new(1, -config.Position.X.Offset, 0, config.Position.Y.Offset + totalHeight)
        })
        enterTween:Play()
        
        task.wait(0.2)
        
        TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        TweenService:Create(description, TweenInfo.new(0.3), {TextTransparency = style == "Pixel" and 0 or 0.2}):Play()
        
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
