-- NivideNotifications v1.2 (Nvidia Theme)
-- Original Nvidia-style notification system for Roblox

local NivideNotifications = {}

-- Services
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- Nvidia-style default configuration
local CONFIG = {
    Duration = 5,
    Position = UDim2.new(1, -20, 0, 20),  -- Top right position
    Size = UDim2.new(0, 350, 0, 80),
    BackgroundColor = Color3.fromRGB(0, 0, 0),  -- Pure black background (more Nvidia-like)
    TextColor = Color3.fromRGB(255, 255, 255),  -- White text
    AccentColor = Color3.fromRGB(118, 185, 0),  -- Classic Nvidia green
    Font = Enum.Font.GothamBold,  -- Clean, modern font like Nvidia uses
    TextSize = 16,
    CornerRadius = UDim.new(0, 4),  -- Slightly sharper corners (Nvidia style)
    BorderSizePixel = 1,
    BorderColor3 = Color3.fromRGB(50, 50, 50),  -- Subtle border
    Icon = "rbxassetid://1234567890",  -- Replace with Nvidia logo asset ID
    IconSize = UDim2.new(0, 24, 0, 24),
    IconColor = Color3.fromRGB(118, 185, 0),  -- Green icon
    ParticleConfig = {
        Enabled = true,
        Count = 50,  -- More particles for Nvidia effect
        MinSize = 1,
        MaxSize = 3,
        MinSpeed = 5,  -- Faster particles
        MaxSpeed = 10,
        FadeTime = 0.8,  -- Slightly quicker fade
        ParticleColor = Color3.fromRGB(118, 185, 0),  -- Nvidia green particles
        SpreadAngle = 45,  -- Wider spread
        Gravity = Vector2.new(0, 50)  -- Particles fall downward
    },
    Animation = {
        SlideInDuration = 0.3,  -- Smooth slide-in
        SlideOutDuration = 0.3,  -- Smooth slide-out
        BounceEffect = false  -- Nvidia notifications don't typically bounce
    }
}

-- Create the main GUI container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NivideNotificationGui"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

-- Helper function to create Nvidia-style glow
local function createNvidiaGlow(parent, color, size, transparency)
    local glow = Instance.new("ImageLabel")
    glow.Name = "NvidiaGlow"
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://7131988516"
    glow.ImageColor3 = color
    glow.ImageTransparency = transparency or 0.85
    glow.Size = size or UDim2.new(1.2, 0, 1.5, 0)
    glow.SizeConstraint = Enum.SizeConstraint.RelativeXX
    glow.Position = UDim2.new(0.5, 0, 0.5, 0)
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.ZIndex = parent.ZIndex - 1
    glow.Parent = parent
    return glow
end

-- Nvidia-style particle system
local function createNvidiaParticle(container, config)
    local particle = Instance.new("Frame")
    particle.BackgroundColor3 = config.ParticleConfig.ParticleColor
    particle.BorderSizePixel = 0
    
    local size = math.random(config.ParticleConfig.MinSize, config.ParticleConfig.MaxSize)
    particle.Size = UDim2.new(0, size, 0, size)
    particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
    
    local glow = createNvidiaGlow(particle, config.ParticleConfig.ParticleColor, UDim2.new(2, 0, 2, 0), 0.8)
    Instance.new("UICorner", particle).CornerRadius = UDim.new(1, 0)
    particle.ZIndex = container.ZIndex
    particle.Parent = container
    
    local lifetime = 0
    local maxLifetime = math.random(5, 15)
    
    local connection
    connection = RunService.Heartbeat:Connect(function(delta)
        if not particle.Parent then
            connection:Disconnect()
            return
        end
        
        lifetime = lifetime + delta
        if lifetime > maxLifetime then
            particle:Destroy()
            connection:Disconnect()
            return
        end
        
        local progress = lifetime / maxLifetime
        local xPos = particle.Position.X.Scale + (math.sin(lifetime * 2) * 0.01)
        local yPos = particle.Position.Y.Scale + (math.cos(lifetime * 1.5) * 0.01)
        
        particle.Position = UDim2.new(
            math.clamp(xPos, 0, 1),
            0,
            math.clamp(yPos, 0, 1),
            0
        )
        
        particle.BackgroundTransparency = 0.5 + (progress * 0.5)
        glow.ImageTransparency = 0.8 + (progress * 0.2)
    end)
end

-- Create Nvidia-style animated background
local function createNvidiaBackground(parent, config)
    if not config.ParticleConfig.Enabled then return end
    
    local backgroundContainer = Instance.new("Frame")
    backgroundContainer.Name = "NvidiaBackground"
    backgroundContainer.Size = UDim2.new(1, 0, 1, 0)
    backgroundContainer.BackgroundTransparency = 1
    backgroundContainer.ZIndex = parent.ZIndex - 1
    backgroundContainer.Parent = parent
    
    for _ = 1, config.ParticleConfig.Count do
        createNvidiaParticle(backgroundContainer, config)
    end
    
    -- Continuous Nvidia-style particle generation
    spawn(function()
        while backgroundContainer.Parent do
            task.wait(0.25)
            if #backgroundContainer:GetChildren() < config.ParticleConfig.Count * 1.5 then
                createNvidiaParticle(backgroundContainer, config)
            end
        end
    end)
end

-- Main notification function with Nvidia style
function NivideNotifications.CreateNotification(title, message, customConfig)
    -- Merge custom config with Nvidia defaults
    local config = table.clone(CONFIG)
    if customConfig then
        for k, v in pairs(customConfig) do
            if k == "ParticleConfig" and type(v) == "table" then
                for pk, pv in pairs(v) do
                    config.ParticleConfig[pk] = pv
                end
            else
                config[k] = v
            end
        end
    end
    
    -- Create notification frame with Nvidia styling
    local notification = Instance.new("Frame")
    notification.Name = "NvidiaNotification_"..HttpService:GenerateGUID(false)
    notification.Size = config.Size
    notification.Position = UDim2.new(1, 20, 0, config.Position.Y.Offset)
    notification.AnchorPoint = Vector2.new(1, 0)
    notification.BackgroundColor3 = config.BackgroundColor
    notification.BackgroundTransparency = 0.15
    notification.BorderSizePixel = 0
    notification.ClipsDescendants = true
    notification.ZIndex = 100
    notification.Parent = ScreenGui
    
    -- Nvidia-style rounded corners
    local corner = Instance.new("UICorner", notification)
    corner.CornerRadius = config.CornerRadius
    
    -- Nvidia-style subtle shadow
    local shadow = Instance.new("ImageLabel", notification)
    shadow.Name = "NvidiaShadow"
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.9
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.ZIndex = notification.ZIndex - 1
    shadow.BackgroundTransparency = 1
    
    -- Create Nvidia-style animated background
    createNvidiaBackground(notification, config)
    
    -- Nvidia-style accent bar (full width initially)
    local accentBar = Instance.new("Frame")
    accentBar.Name = "NvidiaAccentBar"
    accentBar.Size = UDim2.new(1, 0, 0, 3)  -- Nvidia-style thin bar
    accentBar.Position = UDim2.new(0, 0, 0, 0)
    accentBar.BackgroundColor3 = config.AccentColor
    accentBar.BorderSizePixel = 0
    accentBar.ZIndex = notification.ZIndex + 1
    accentBar.Parent = notification
    
    -- Create content container
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "NvidiaContent"
    contentContainer.Size = UDim2.new(1, -20, 1, -20)
    contentContainer.Position = UDim2.new(0, 10, 0, 10)
    contentContainer.BackgroundTransparency = 1
    contentContainer.ZIndex = notification.ZIndex + 2
    contentContainer.Parent = notification
    
    -- Create title label with Nvidia-style text
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "NvidiaTitle"
    titleLabel.Size = UDim2.new(1, 0, 0, 24)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = config.Font
    titleLabel.TextSize = config.TextSize
    titleLabel.TextColor3 = config.TextColor
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = title or "Notification"
    titleLabel.TextTransparency = 1
    titleLabel.ZIndex = contentContainer.ZIndex
    titleLabel.Parent = contentContainer
    
    -- Create message label
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "NvidiaMessage"
    messageLabel.Size = UDim2.new(1, 0, 1, -30)
    messageLabel.Position = UDim2.new(0, 0, 0, 30)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Font = Enum.Font.Gotham  -- Slightly different font for message
    messageLabel.TextSize = config.TextSize - 2
    messageLabel.TextColor3 = config.TextColor
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.Text = message or ""
    messageLabel.TextTransparency = 1
    messageLabel.ZIndex = contentContainer.ZIndex
    messageLabel.Parent = contentContainer
    
    -- Nvidia-style animation sequence
    local function animate()
        -- Slide in animation
        local enterTween = TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -20, 0, config.Position.Y.Offset)
        })
        enterTween:Play()
        enterTween.Completed:Wait()
        
        -- Fade in text (Nvidia-style quick fade)
        local textTween1 = TweenService:Create(titleLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextTransparency = 0
        })   
        local textTween2 = TweenService:Create(messageLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextTransparency = 0.2
        })
        textTween1:Play()
        textTween2:Play()
        
        -- Wait for duration
        task.wait(config.Duration)
        
        -- Slide out animation
        local exitTween = TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 20, 0, config.Position.Y.Offset)
        })
        exitTween:Play()
        exitTween.Completed:Wait()
        
        notification:Destroy()
    end
    
    -- Start animation
    task.spawn(animate)
end

return NivideNotifications
