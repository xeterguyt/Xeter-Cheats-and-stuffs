-- Universal Intro
return function(SCRIPT_URL)
	local TweenService = game:GetService("TweenService")
	local player = game.Players.LocalPlayer
	local gui = Instance.new("ScreenGui")
	gui.Name = "UniversalIntro"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = player:WaitForChild("PlayerGui")

	-- Panel utama
	local panel = Instance.new("Frame")
	panel.Size = UDim2.new(0, 300, 0, 160)
	panel.Position = UDim2.new(0.5, 0, -1, 0)
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
	panel.BorderSizePixel = 0
	panel.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = panel

	local outline = Instance.new("UIStroke")
	outline.Thickness = 2
	outline.Color = Color3.fromRGB(255, 80, 80)
	outline.Parent = panel

	-- Logo
	local logo = Instance.new("ImageLabel")
	logo.Size = UDim2.new(0, 90, 0, 90)
	logo.AnchorPoint = Vector2.new(0.5, 0)
	logo.Position = UDim2.new(0.5, 0, 0, 8)
	logo.BackgroundTransparency = 1
	logo.Image = "rbxassetid://108691300199501"
	logo.ImageColor3 = Color3.fromRGB(255, 80, 80)
	logo.Parent = panel

	-- Tulisan by xeter
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 40)
	title.Position = UDim2.new(0, 0, 0, 95)
	title.BackgroundTransparency = 1
	title.Text = "by xeter"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextScaled = true
	title.Parent = panel

	-- Powered by AI
	local sub = Instance.new("TextLabel")
	sub.Size = UDim2.new(1, 0, 0, 25)
	sub.Position = UDim2.new(0, 0, 0, 125)
	sub.BackgroundTransparency = 1
	sub.Text = "powered by AI tools"
	sub.TextColor3 = Color3.fromRGB(230, 200, 200)
	sub.Font = Enum.Font.Gotham
	sub.TextScaled = true
	sub.Parent = panel

	-- Enjoy!
	local enjoy = Instance.new("TextLabel")
	enjoy.Size = UDim2.new(1, 0, 0, 30)
	enjoy.Position = UDim2.new(0, 0, 1, 5)
	enjoy.AnchorPoint = Vector2.new(0, 1)
	enjoy.BackgroundTransparency = 1
	enjoy.Text = "Enjoy!"
	enjoy.TextColor3 = Color3.fromRGB(200, 80, 80)
	enjoy.Font = Enum.Font.GothamBold
	enjoy.TextScaled = true
	enjoy.Parent = panel

	-- Tween sequence
	local tweenIn = TweenService:Create(panel, TweenInfo.new(3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0.5, 0)
	})
	local tweenOut = TweenService:Create(panel, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		BackgroundTransparency = 1
	})

	tweenIn:Play()
	tweenIn.Completed:Wait()
	task.wait(2)
	tweenOut:Play()
	for _, child in ipairs(panel:GetDescendants()) do
		if child:IsA("TextLabel") or child:IsA("ImageLabel") then
			TweenService:Create(child, TweenInfo.new(1), {TextTransparency = 1, ImageTransparency = 1}):Play()
		end
	end
	tweenOut.Completed:Wait()
	gui:Destroy()

	-- Jalankan script utama setelah intro
	if SCRIPT_URL then
		loadstring(game:HttpGet(SCRIPT_URL))()
	end
end
