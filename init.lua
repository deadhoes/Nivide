local NotificationLib = {}

-- Default settings
NotificationLib.defaultSettings = {
    duration = 5, -- seconds
    titleColor = Color3.fromRGB(40, 40, 40),
    descColor = Color3.fromRGB(120, 120, 120),
    bgColor = Color3.fromRGB(255, 255, 255),
    timerColor = Color3.fromRGB(110, 158, 246),
    position = UDim2.new(0.248, 0, 0.25, 0),
    size = UDim2.new(0, 222, 0, 102),
    titleFont = Enum.Font.Unknown,
    descFont = Enum.Font.Unknown,
    titleSize = 16,
    descSize = 14
}

-- Create a new notification
function NotificationLib.new(settings)
    -- Merge custom settings with defaults
    local config = table.clone(NotificationLib.defaultSettings)
    for k, v in pairs(settings or {}) do
        config[k] = v
    end
    
    -- Create GUI elements
    local screenGui = Instance.new("ScreenGui")
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.BackgroundColor3 = config.bgColor
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = config.position
    mainFrame.Size = config.size
    mainFrame.Parent = screenGui
    
    local contentFrame = Instance.new("Frame")
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.Position = UDim2.new(0, 15, 0, 0)
    contentFrame.Size = UDim2.new(1, -25, 1, 0)
    contentFrame.ZIndex = 2
    contentFrame.Parent = mainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Parent = contentFrame
    
    local padding = Instance.new("UIPadding")
    padding.PaddingBottom = UDim.new(0, 16)
    padding.PaddingTop = UDim.new(0, 16)
    padding.Parent = contentFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.AnchorPoint = Vector2.new(0.5, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, 0, 0, 10)
    titleLabel.ZIndex = 2
    titleLabel.Font = config.titleFont
    titleLabel.Text = config.title or "Title"
    titleLabel.TextColor3 = config.titleColor
    titleLabel.TextSize = config.titleSize
    titleLabel.TextWrapped = true
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = contentFrame
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "Description"
    descLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    descLabel.BackgroundTransparency = 1
    descLabel.Size = UDim2.new(1, 0, 0, 5)
    descLabel.ZIndex = 2
    descLabel.Font = config.descFont
    descLabel.Text = config.description or "Description"
    descLabel.TextColor3 = config.descColor
    descLabel.TextSize = config.descSize
    descLabel.TextTransparency = 0.15
    descLabel.TextWrapped = true
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    descLabel.Parent = contentFrame
    
    local timerBar = Instance.new("Frame")
    timerBar.Name = "Timer"
    timerBar.BackgroundColor3 = config.timerColor
    timerBar.BorderSizePixel = 0
    timerBar.Position = UDim2.new(0, 0, 1, -2)
    timerBar.Size = UDim2.new(1, 0, 0, 2)
    timerBar.ZIndex = 2
    timerBar.Parent = mainFrame
    
    local interactButton = Instance.new("TextButton")
    interactButton.Name = "Interact"
    interactButton.AnchorPoint = Vector2.new(0.5, 0.5)
    interactButton.BackgroundTransparency = 1
    interactButton.BorderSizePixel = 0
    interactButton.Size = UDim2.new(1, 0, 1, 0)
    interactButton.ZIndex = 5
    interactButton.Font = Enum.Font.SourceSans
    interactButton.Text = ""
    interactButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    interactButton.TextSize = 14
    interactButton.Parent = mainFrame
    
    -- Animation for timer
    if config.duration and config.duration > 0 then
        spawn(function()
            local startTime = tick()
            local endTime = startTime + config.duration
            
            while tick() < endTime do
                local elapsed = tick() - startTime
                local progress = elapsed / config.duration
                timerBar.Size = UDim2.new(1 - progress, 0, 0, 2)
                wait()
            end
            
            -- Fade out animation
            for i = 1, 10 do
                mainFrame.BackgroundTransparency = i/10
                wait(0.05)
            end
            
            screenGui:Destroy()
        end)
    end
    
    -- Return methods to interact with the notification
    return {
        -- Destroy the notification immediately
        destroy = function()
            screenGui:Destroy()
        end,
        
        -- Set a callback for when the notification is clicked
        setCallback = function(callback)
            interactButton.MouseButton1Click:Connect(callback)
        end,
        
        -- Update the notification text
        update = function(newTitle, newDesc)
            if newTitle then titleLabel.Text = newTitle end
            if newDesc then descLabel.Text = newDesc end
        end,
        
        -- Get the GUI instance (for advanced modifications)
        getGui = function()
            return screenGui
        end
    }
end

return NotificationLib
