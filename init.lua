-- NivideNotifications v1.1
-- By: YourName
-- Description: A customizable notification system for Roblox games

local NivideNotifications = {}

-- Services
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- Default configuration
local CONFIG = {
    Duration = 5,
    Position = UDim2.new(1, -20, 0, 20),
    Size = UDim2.new(0, 350, 0, 70),
    BackgroundColor = Color3.fromRGB(40, 40, 40),
    TextColor = Color3.fromRGB(255, 255, 255),
    AccentColor = Color3.fromRGB(0, 162, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    CornerRadius = UDim.new(0, 8),
    ParticleConfig = {
        Enabled = true,
        Count = 50,
        MinSize = 1,
        MaxSize = 2,
        MinSpeed = 4,
        MaxSpeed = 7,
        FadeTime = 1
    }
}

-- Create the main GUI container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NivideNotificationGui"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

-- Helper function to create glow effect
local function createGlow(parent, color, size, transparency)
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://7131988516"
    glow.ImageColor3 = color
    glow.ImageTransparency = transparency or 0.7
    glow.Size = size or UDim2.new(1.5, 0, 1.5, 0)
    glow.SizeConstraint = Enum.SizeConstraint.RelativeXX
    glow.Position = UDim2.new(0.5, 0, 0.5, 0)
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.ZIndex = parent.ZIndex - 1
    glow.Parent = parent
    return glow
end

-- Particle system for background
local function createParticle(container, config)
    local particle = Instance.new("Frame")
    particle.BackgroundTransparency = 0.5
    particle.BackgroundColor3 = config.AccentColor
    particle.BorderSizePixel = 0
    
    local size = math.random(config.ParticleConfig.MinSize, config.ParticleConfig.MaxSize)
    particle.Size = UDim2.new(0, size, 0, size)
    particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
    
    local glow = createGlow(particle, config.AccentColor, UDim2.new(2, 0, 2, 0), 0.8)
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

-- Create animated background
local function createAnimatedBackground(parent, config)
    if not config.ParticleConfig.Enabled then return end
    
    local backgroundContainer = Instance.new("Frame")
    backgroundContainer.Name = "AnimatedBackground"
    backgroundContainer.Size = UDim2.new(1, 0, 1, 0)
    backgroundContainer.BackgroundTransparency = 1
    backgroundContainer.ZIndex = parent.ZIndex - 1
    backgroundContainer.Parent = parent
    
    for _ = 1, config.ParticleConfig.Count do
        createParticle(backgroundContainer, config)
    end
    
    -- Continuous particle generation
    spawn(function()
        while backgroundContainer.Parent do
            task.wait(0.2)
            if #backgroundContainer:GetChildren() < config.ParticleConfig.Count * 1.5 then
                createParticle(backgroundContainer, config)
            end
        end
    end)
end

-- Main notification function
function NivideNotifications.CreateNotification(title, message, customConfig)
    -- Merge custom config with defaults
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
    
    -- Create notification frame
    local notification = Instance.new("Frame")
    notification.Name = "Notification_"..HttpService:GenerateGUID(false)
    notification.Size = config.Size
    notification.Position = UDim2.new(1, 20, 0, config.Position.Y.Offset)
    notification.AnchorPoint = Vector2.new(1, 0)
    notification.BackgroundColor3 = config.BackgroundColor
    notification.BackgroundTransparency = 0.2
    notification.BorderSizePixel = 0
    notification.ClipsDescendants = true
    notification.ZIndex = 100
    notification.Parent = ScreenGui
    
    -- Add rounded corners
    local corner = Instance.new("UICorner", notification)
    corner.CornerRadius = config.CornerRadius
    
    -- Create shadow effect
    local shadow = Instance.new("ImageLabel", notification)
    shadow.Name = "Shadow"
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.ZIndex = notification.ZIndex - 1
    shadow.BackgroundTransparency = 1
    
    -- Create animated background
    createAnimatedBackground(notification, config)
    
    -- Create accent bar
    local accentBar = Instance.new("Frame")
    accentBar.Name = "AccentBar"
    accentBar.Size = UDim2.new(1, 0, 1, 0)
    accentBar.Position = UDim2.new(0, 0, 0, 0)
    accentBar.BackgroundTransparency = 0.7
    accentBar.BackgroundColor3 = config.AccentColor
    accentBar.BorderSizePixel = 0
    accentBar.ZIndex = notification.ZIndex + 1
    accentBar.Parent = notification
    
    -- Create content container
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -20, 1, -20)
    contentContainer.Position = UDim2.new(0, 10, 0, 10)
    contentContainer.BackgroundTransparency = 1
    contentContainer.ZIndex = notification.ZIndex + 2
    contentContainer.Parent = notification
    
    -- Create title label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0, 20)
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
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, 0, 1, -25)
    messageLabel.Position = UDim2.new(0, 0, 0, 25)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Font = config.Font
    messageLabel.TextSize = config.TextSize - 2
    messageLabel.TextColor3 = config.TextColor
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.Text = message or ""
    messageLabel.TextTransparency = 1
    messageLabel.ZIndex = contentContainer.ZIndex
    messageLabel.Parent = contentContainer
    
    -- Create fixed accent bar (for after animation)
    local fixedAccentBar = Instance.new("Frame")
    fixedAccentBar.Name = "FixedAccentBar"
    fixedAccentBar.Size = UDim2.new(0, 4, 1, 0)
    fixedAccentBar.Position = UDim2.new(0, 0, 0, 0)
    fixedAccentBar.BackgroundColor3 = config.AccentColor
    fixedAccentBar.BorderSizePixel = 0
    fixedAccentBar.Visible = false
    fixedAccentBar.ZIndex = notification.ZIndex + 1
    fixedAccentBar.Parent = notification
    
    -- Animation sequence
    local function animate()
        -- Slide in animation
        local enterTween = TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -20, 0, config.Position.Y.Offset)
        })
        enterTween:Play()
        enterTween.Completed:Wait()
        
        task.wait(0.2)
        
        -- Convert full-width accent bar to thin bar
        fixedAccentBar.Visible = true
        local accentTween = TweenService:Create(accentBar, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
            Size = UDim2.new(0, 4, 1, 0),
            BackgroundTransparency = 0
        })
        accentTween:Play()
        
        task.wait(0.2)
        
        -- Fade in text
        local textTween1 = TweenService:Create(titleLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            TextTransparency = 0
        })   
        local textTween2 = TweenService:Create(messageLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            TextTransparency = 0.2
        })
        textTween1:Play()
        textTween2:Play()
        
        accentTween.Completed:Wait()
        accentBar:Destroy()
        
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

-- Add queue system for multiple notifications
function NivideNotifications.CreateQueuedNotification(title, message, customConfig)
    -- Implementation for queued notifications
    -- (Would track positions and auto-adjust for multiple notifications)
end

return NivideNotifications
