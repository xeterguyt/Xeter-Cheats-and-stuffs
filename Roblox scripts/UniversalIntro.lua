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
    panel.Position = UDim2.new(0.5, 0, -0.5, 0) -- start above screen
    panel.BackgroundColor3 = Color3.fromRGB(140, 18, 18) -- stylish deep red
    panel.BorderSizePixel = 0
    panel.ZIndex = 99999
    panel.Parent = gui

    -- rounded corner + outline
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = panel

    local outline = Instance.new("UIStroke")
    outline.Thickness = 3
    outline.Color = Color3.fromRGB(255, 220, 220)
    outline.Parent = panel

    -- logo (centered, above text)
    local logo = Instance.new("ImageLabel")
    logo.Size = UDim2.new(0, 88, 0, 88)
    logo.AnchorPoint = Vector2.new(0.5, 0)
    logo.Position = UDim2.new(0.5, 0, 0, 16)
    logo.Texture = "http://www.roblox.com/asset/?id=108691300199501"
    logo.BackgroundTransparency = 1
    logo.Parent = panel
    logo.ZIndex = logo.Parent.ZIndex+1


    -- title ("by xeter")
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 40)
    title.Position = UDim2.new(0, 10, 0, 110)
    title.BackgroundTransparency = 1
    title.Text = "by xeter"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 32
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.TextScaled = false
    title.TextStrokeTransparency = 0.6
    title.TextWrapped = true
    title.Parent = panel
    title.ZIndex = title.Parent.ZIndex+1


    -- sub ("powered by AI tools")
    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -20, 0, 24)
    sub.Position = UDim2.new(0, 10, 0, 148)
    sub.BackgroundTransparency = 1
    sub.Text = "powered by AI tools"
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 18
    sub.TextColor3 = Color3.fromRGB(235,230,230)
    sub.TextScaled = false
    sub.Parent = panel
    sub.ZIndex = sub.Parent.ZIndex+1


    -- enjoy (slightly darker)
    local enjoy = Instance.new("TextLabel")
    enjoy.Size = UDim2.new(1, -20, 0, 20)
    enjoy.Position = UDim2.new(0, 10, 0, 170)
    enjoy.BackgroundTransparency = 1
    enjoy.Text = "Enjoy!"
    enjoy.Font = Enum.Font.GothamSemibold
    enjoy.TextSize = 18
    enjoy.TextColor3 = Color3.fromRGB(170,60,60)
    enjoy.Parent = panel
    enjoy.ZIndex = enjoy.Parent.ZIndex+1


    -- optional whoosh sound (fire-and-forget)
    spawn(function()
        pcall(function()
            local s = Instance.new("Sound")
            s.SoundId = "rbxassetid://112485797063762" -- contoh whoosh
            s.Volume = 1.6
            s.Parent = SoundService
            s:Play()
            task.delay(2, function() pcall(function() s:Destroy() end) end)
        end)
    end)

    -- Tween in: 3s from top to center
    local tweenIn = TweenService:Create(panel, TweenInfo.new(3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0.5, 0)
    })
    tweenIn:Play()
    tweenIn.Completed:Wait()

    -- hold 2s
    task.wait(2)

    -- fade out 1s (panel + children)
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

    -- cleanup
    gui:Destroy()

    -- function returns after finished
    return
end
