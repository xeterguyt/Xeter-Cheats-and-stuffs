print("hi")
return function()
    local TweenService = game:GetService("TweenService")
    local Players = game:GetService("Players")
    local SoundService = game:GetService("SoundService")
    local player = Players.LocalPlayer
    local parentGui = player:WaitForChild("PlayerGui")

    -- create GUI root
    local gui = Instance.new("ScreenGui")
    gui.Name = "Xeter_UniversalIntro"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = parentGui

    -- panel
    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, 360, 0, 200)
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.Position = UDim2.new(0.5, 0, -0.5, 0)
    panel.BackgroundColor3 = Color3.fromRGB(140, 18, 18)
    panel.BorderSizePixel = 0
    panel.ZIndex = 99999
    panel.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = panel

    -- outline panel (hitam)
    local outline = Instance.new("UIStroke")
    outline.Thickness = 3
    outline.Color = Color3.fromRGB(0, 0, 0)
    outline.Parent = panel

    -- logo wrapper (circle outline) + image centered inside
    local logoWrapper = Instance.new("Frame")
    logoWrapper.Size = UDim2.new(0, 96, 0, 96)            -- sedikit lebih besar dari image untuk outline gap
    logoWrapper.AnchorPoint = Vector2.new(0.5, 0)         -- align like before
    logoWrapper.Position = UDim2.new(0.5, 0, 0, 16)
    logoWrapper.BackgroundTransparency = 1
    logoWrapper.Parent = panel                             -- set parent FIRST
    logoWrapper.ZIndex = panel.ZIndex + 1

    local logoCorner = Instance.new("UICorner")
    logoCorner.CornerRadius = UDim.new(1, 0)               -- full circle
    logoCorner.Parent = logoWrapper

    local logoOutline = Instance.new("UIStroke")
    logoOutline.Thickness = 3                              -- sama tebal seperti outline panel
    logoOutline.Color = Color3.fromRGB(0, 0, 0)            -- hitam
    logoOutline.Parent = logoWrapper

    local logo = Instance.new("ImageLabel")
    logo.Size = UDim2.new(0, 88, 0, 88)                   -- image slightly smaller than wrapper
    logo.AnchorPoint = Vector2.new(0.5, 0)
    logo.Position = UDim2.new(0.5, 0, 0, 4)               -- fine-tune vertical offset inside wrapper
    logo.Image = "rbxassetid://133865385818233"
    logo.BackgroundTransparency = 1
    logo.Parent = logoWrapper
    logo.ZIndex = logoWrapper.ZIndex + 1
    -- title ("by xeter", hitam)
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 40)
    title.Position = UDim2.new(0, 10, 0, 110)
    title.BackgroundTransparency = 1
    title.Text = "by xeter"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 32
    title.TextColor3 = Color3.fromRGB(0, 0, 0)
    title.TextStrokeTransparency = 0.6
    title.Parent = panel
    title.ZIndex = title.Parent.ZIndex + 1

    -- subtitle ("helped by AI tools", merah gelap tapi redup)
    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -20, 0, 24)
    sub.Position = UDim2.new(0, 10, 0, 148)
    sub.BackgroundTransparency = 1
    sub.Text = "helped by AI tools"
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 18
    sub.TextColor3 = Color3.fromRGB(100, 10, 10) -- lebih gelap dari panel
    sub.Parent = panel
    sub.ZIndex = sub.Parent.ZIndex + 1

    -- enjoy
    local enjoy = Instance.new("TextLabel")
    enjoy.Size = UDim2.new(1, -20, 0, 20)
    enjoy.Position = UDim2.new(0, 10, 0, 170)
    enjoy.BackgroundTransparency = 1
    enjoy.Text = "Enjoy!"
    enjoy.Font = Enum.Font.GothamSemibold
    enjoy.TextSize = 18
    enjoy.TextColor3 = Color3.fromRGB(170, 60, 60)
    enjoy.Parent = panel
    enjoy.ZIndex = enjoy.Parent.ZIndex + 1

    -- whoosh sound
    spawn(function()
        pcall(function()
            local s = Instance.new("Sound")
            s.SoundId = "rbxassetid://112485797063762"
            s.Volume = 1.6
            s.Parent = SoundService
            s:Play()
            task.delay(2, function() pcall(function() s:Destroy() end) end)
        end)
    end)

    -- Tween in
    local tweenIn = TweenService:Create(panel, TweenInfo.new(3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0.5, 0)
    })
    tweenIn:Play()
    tweenIn.Completed:Wait()

    -- Hold
    task.wait(5)

    -- Fade out
    local tweenOut = TweenService:Create(panel, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
        BackgroundTransparency = 1
    })
    tweenOut:Play()
    for _, child in ipairs(panel:GetDescendants()) do
        if child:IsA("TextLabel") then
            TweenService:Create(child, TweenInfo.new(1), {TextTransparency = 1}):Play()
        elseif child:IsA("ImageLabel") then
            TweenService:Create(child, TweenInfo.new(1), {ImageTransparency = 1}):Play()
        elseif child:IsA("UIStroke") then
            TweenService:Create(child, TweenInfo.new(1), {Transparency = 1}):Play()
        end
    end
    tweenOut.Completed:Wait()

    gui:Destroy()
    return
end
