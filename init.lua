local TweenService = game:GetService("TweenService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NotificationGui"
ScreenGui.Parent = game.CoreGui

local CONFIG = {
    Duration = 10,
    Position = UDim2.new(1, -20, 0, 20),
    Size = UDim2.new(0, 350, 0, 70),
    BackgroundColor = Color3.fromRGB(0, 0, 0),
    TextColor = Color3.fromRGB(255, 255, 255),
    AccentColor = Color3.fromRGB(118, 185, 0),
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    ParticleConfig = {
        Count = 100,
        MinSize = 1,
        MaxSize = 2,
        MinSpeed = 4,
        MaxSpeed = 7,
        FadeTime = 1000
    }
}

local function createGlow(parent, color, size, transparency)
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://7131988516"
    glow.ImageColor3 = color
    glow.ImageTransparency = transparency
    glow.Size = UDim2.new(1.5, 0, 1.5, 0)
    glow.SizeConstraint = Enum.SizeConstraint.RelativeXX
    glow.Position = UDim2.new(0.5, 0, 0.5, 0)
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.ZIndex = parent.ZIndex - 1
    glow.Parent = parent
    return glow
end

local function createParticle(container)
    local particle = Instance.new("Frame")
    particle.BackgroundColor3 = CONFIG.AccentColor
    particle.BorderSizePixel = 0
    
    local size = math.random(CONFIG.ParticleConfig.MinSize, CONFIG.ParticleConfig.MaxSize)
    particle.Size = UDim2.new(0, size, 0, size)
    particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
    
    local glow = createGlow(particle, CONFIG.AccentColor, size * 1.5, 0.7)
    Instance.new("UICorner", particle).CornerRadius = UDim.new(1, 0)
    particle.Parent = container
    
    local function animateParticle()
        while particle.Parent do
            local duration = math.random(CONFIG.ParticleConfig.MinSpeed, CONFIG.ParticleConfig.MaxSpeed)
            local targetX = math.random()
            local targetY = math.random()
            
            local tween = TweenService:Create(particle, 
                TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), 
                {Position = UDim2.new(targetX, 0, targetY, 0)}
            )
            
            local transparencyTween = TweenService:Create(particle,
                TweenInfo.new(CONFIG.ParticleConfig.FadeTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
                {BackgroundTransparency = 0.7}
            )
            
            local glowTween = TweenService:Create(glow,
                TweenInfo.new(CONFIG.ParticleConfig.FadeTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
                {ImageTransparency = 0.9}
            )
            
            tween:Play()
            transparencyTween:Play()
            glowTween:Play()
            
            wait(duration)
        end
    end
    
    coroutine.wrap(animateParticle)()
end

local function createAnimatedBackground(parent)
    local backgroundContainer = Instance.new("Frame")
    backgroundContainer.Name = "AnimatedBackground"
    backgroundContainer.Size = UDim2.new(1, 0, 1, 0)
    backgroundContainer.BackgroundTransparency = 1
    backgroundContainer.ZIndex = 0
    backgroundContainer.Parent = parent
    
    for _ = 1, CONFIG.ParticleConfig.Count do
        createParticle(backgroundContainer)
    end
end

local function CreateNotification()
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = CONFIG.Size
    notification.Position = UDim2.new(1, 20, 0, CONFIG.Position.Y.Offset)
    notification.AnchorPoint = Vector2.new(1, 0)
    notification.BackgroundColor3 = CONFIG.BackgroundColor
    notification.BorderSizePixel = 0
    notification.BackgroundTransparency = 0.1
    notification.ClipsDescendants = true
    notification.Parent = ScreenGui
    
    createAnimatedBackground(notification)
    
    local accentBar = Instance.new("Frame")
    accentBar.Name = "AccentBar"
    accentBar.Size = UDim2.new(1, 0, 1, 0)
    accentBar.Position = UDim2.new(0, 0, 0, 0)
    accentBar.BackgroundColor3 = CONFIG.AccentColor
    accentBar.BorderSizePixel = 0
    accentBar.Parent = notification
    
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, 0, 1, 0)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = notification
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(0, 200, 0, 20)
    titleLabel.Position = UDim2.new(0, 20, 0, 15)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = CONFIG.Font
    titleLabel.TextSize = CONFIG.TextSize
    titleLabel.TextColor3 = CONFIG.TextColor
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = "Notification"
    titleLabel.TextTransparency = 1
    titleLabel.Parent = contentContainer
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(0, 200, 0, 20)
    messageLabel.Position = UDim2.new(0, 20, 0, 35)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Font = CONFIG.Font
    messageLabel.TextSize = CONFIG.TextSize - 2
    messageLabel.TextColor3 = CONFIG.TextColor
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.Text = "My dick entered in your ass"
    messageLabel.TextTransparency = 1
    messageLabel.Parent = contentContainer
    
    local fixedAccentBar = Instance.new("Frame")
    fixedAccentBar.Name = "FixedAccentBar"
    fixedAccentBar.Size = UDim2.new(0, 4, 1, 0)
    fixedAccentBar.Position = UDim2.new(0, 0, 0, 0)
    fixedAccentBar.BackgroundColor3 = CONFIG.AccentColor
    fixedAccentBar.BorderSizePixel = 0
    fixedAccentBar.Visible = false
    fixedAccentBar.Parent = notification
    
    local function animate()
        local enterTween = TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = CONFIG.Position
        })
        enterTween:Play()
        enterTween.Completed:Wait()
        
        task.wait(0.2)
        
        fixedAccentBar.Visible = true
        
        local accentTween = TweenService:Create(accentBar, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
            Size = UDim2.new(0, 4, 1, 0)
        })
        accentTween:Play()
        
        task.wait(0.2)
        
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
        task.wait(CONFIG.Duration)
        local exitTween = TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 20, notification.Position.Y.Scale, notification.Position.Y.Offset)
        })
        exitTween:Play()
        exitTween.Completed:Wait()
        notification:Destroy()
    end
    task.spawn(animate)
end
CreateNotification()
