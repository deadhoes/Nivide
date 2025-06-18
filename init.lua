local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local NotificationLib = {}
NotificationLib.__index = NotificationLib

NotificationLib.DefaultConfig = {
    Duration = 5,
    Position = UDim2.new(1, -20, 0, 20),
    Size = UDim2.new(0, 350, 0, 70),
    BackgroundColor = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0.1,
    TextColor = Color3.fromRGB(255, 255, 255),
    AccentColor = Color3.fromRGB(118, 185, 0),
    Font = Enum.Font.GothamBold,
    TitleSize = 16,
    MessageSize = 14,
    ParticleConfig = {
        Enabled = true,
        Count = 50,
        MinSize = 1,
        MaxSize = 3,
        MinSpeed = 4,
        MaxSpeed = 7,
        FadeTime = 1
    }
}

function NotificationLib.Init(customConfig)
    local self = setmetatable({}, NotificationLib)
    
    self.Config = table.clone(NotificationLib.DefaultConfig)
    if customConfig then
        for k, v in pairs(customConfig) do
            self.Config[k] = v
        end
    end
    
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "NotificationGui"
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    
    self.NotificationQueue = {}
    self.IsShowingNotification = false
    
    return self
end

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

local function createParticle(container, config)
    local particle = Instance.new("Frame")
    particle.BackgroundColor3 = config.AccentColor
    particle.BorderSizePixel = 0
    
    local size = math.random(config.ParticleConfig.MinSize, config.ParticleConfig.MaxSize)
    particle.Size = UDim2.new(0, size, 0, size)
    particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
    
    local glow = createGlow(particle, config.AccentColor, size * 1.5, 0.7)
    Instance.new("UICorner", particle).CornerRadius = UDim.new(1, 0)
    particle.Parent = container
    
    local connection
    connection = RunService.Heartbeat:Connect(function(deltaTime)
        if not particle.Parent then
            connection:Disconnect()
            return
        end
        
        local currentPos = particle.Position
        particle.Position = UDim2.new(
            currentPos.X.Scale, 
            currentPos.X.Offset, 
            currentPos.Y.Scale - deltaTime * 0.1, 
            currentPos.Y.Offset
        )
        
        particle.BackgroundTransparency = particle.BackgroundTransparency + deltaTime * 0.5
        glow.ImageTransparency = glow.ImageTransparency + deltaTime * 0.5
        
        if particle.BackgroundTransparency >= 1 then
            particle:Destroy()
            connection:Disconnect()
        end
    end)
end

local function createAnimatedBackground(parent, config)
    if not config.ParticleConfig.Enabled then return end
    
    local backgroundContainer = Instance.new("Frame")
    backgroundContainer.Name = "AnimatedBackground"
    backgroundContainer.Size = UDim2.new(1, 0, 1, 0)
    backgroundContainer.BackgroundTransparency = 1
    backgroundContainer.ZIndex = 0
    backgroundContainer.Parent = parent
    
    for _ = 1, config.ParticleConfig.Count do
        createParticle(backgroundContainer, config)
    end
end

function NotificationLib:ShowNotification(title, message)
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = self.Config.Size
    notification.Position = UDim2.new(1, 20, 0, self.Config.Position.Y.Offset)
    notification.AnchorPoint = Vector2.new(1, 0)
    notification.BackgroundColor3 = self.Config.BackgroundColor
    notification.BackgroundTransparency = self.Config.BackgroundTransparency
    notification.BorderSizePixel = 0
    notification.ClipsDescendants = true
    notification.Parent = self.ScreenGui
    
    createAnimatedBackground(notification, self.Config)
    
    local accentBar = Instance.new("Frame")
    accentBar.Name = "AccentBar"
    accentBar.Size = UDim2.new(1, 0, 1, 0)
    accentBar.BackgroundColor3 = self.Config.AccentColor
    accentBar.BorderSizePixel = 0
    accentBar.Parent = notification
    
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, 0, 1, 0)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = notification
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -40, 0, 20)
    titleLabel.Position = UDim2.new(0, 20, 0, 15)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = self.Config.Font
    titleLabel.TextSize = self.Config.TitleSize
    titleLabel.TextColor3 = self.Config.TextColor
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = title
    titleLabel.TextTransparency = 1
    titleLabel.Parent = contentContainer
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -40, 1, -50)
    messageLabel.Position = UDim2.new(0, 20, 0, 35)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Font = self.Config.Font
    messageLabel.TextSize = self.Config.MessageSize
    messageLabel.TextColor3 = self.Config.TextColor
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.Text = message
    messageLabel.TextWrapped = true
    messageLabel.TextTransparency = 1
    messageLabel.Parent = contentContainer
    
    local fixedAccentBar = Instance.new("Frame")
    fixedAccentBar.Name = "FixedAccentBar"
    fixedAccentBar.Size = UDim2.new(0, 4, 1, 0)
    fixedAccentBar.BackgroundColor3 = self.Config.AccentColor
    fixedAccentBar.BorderSizePixel = 0
    fixedAccentBar.Visible = false
    fixedAccentBar.Parent = notification
    
    local function animate()
        local enterTween = TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = self.Config.Position
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
        task.wait(self.Config.Duration)
        local exitTween = TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 20, notification.Position.Y.Scale, notification.Position.Y.Offset)
        })
        exitTween:Play()
        exitTween.Completed:Wait()
        notification:Destroy()
    end
    
    task.spawn(animate)
end

return NotificationLib
