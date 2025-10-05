--[[
🎃 Halloween ESP System v3.4
Intro!
--]]

-- panggil intro dan tunggu selesaiiii
local INTRO_RAW = "https://raw.githubusercontent.com/xeterguyt/Xeter-Cheats-and-stuffs/refs/heads/main/Roblox%20scripts/UniversalIntro.lua"
local intro = loadstring(game:HttpGet(INTRO_RAW))()  -- loadstring returns the function
intro() -- plays intro and yields until done

-- lanjutkan ke kode ESP-mu di bawah ini...

local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Settings
local MAX_TEXT_DISTANCE = 300
local DOT_ONLY_DISTANCE = 200
local UPDATE_INTERVAL = 0.05

-- Main container
local gui = Instance.new("ScreenGui")
gui.Name = "HalloweenESP"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

-- UI Control buttons
local frame = Instance.new("Frame")
frame.Parent = gui
frame.AnchorPoint = Vector2.new(0.5, 0)
frame.Position = UDim2.new(0.5, 0, 0, 55)
frame.Size = UDim2.new(0, 200, 0, 20)
frame.BackgroundTransparency = 0.3
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.ZIndex = 10

local toggleBtn = Instance.new("TextButton")
toggleBtn.Parent = frame
toggleBtn.Size = UDim2.new(0.7, -5, 1, 0)
toggleBtn.Position = UDim2.new(0, 0, 0, 0)
toggleBtn.Text = "ESP: ON"
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.TextScaled = true
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
toggleBtn.BorderSizePixel = 0

local closeBtn = Instance.new("TextButton")
closeBtn.Parent = frame
closeBtn.Size = UDim2.new(0.3, 0, 1, 0)
closeBtn.Position = UDim2.new(0.7, 5, 0, 0)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.TextScaled = true
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.BorderSizePixel = 0

-- Ping indicator
local pingLabel = Instance.new("TextLabel")
pingLabel.Parent = gui
pingLabel.AnchorPoint = Vector2.new(0.5, 0)
pingLabel.Position = UDim2.new(0.5, 0, 0, 80) -- di bawah tombol utama
pingLabel.Size = UDim2.new(0, 200, 0, 15)
pingLabel.BackgroundTransparency = 0.5
pingLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
pingLabel.TextColor3 = Color3.new(1, 1, 1)
pingLabel.Text = "Ping: 0 ms"
pingLabel.TextScaled = true
pingLabel.Font = Enum.Font.SourceSansBold
pingLabel.BorderSizePixel = 0
pingLabel.ZIndex = 9

-- Update ping
task.spawn(function()
	local stats = game:GetService("Stats")
	while gui.Parent do
		task.wait(1)
		local netStats = stats.Network.ServerStatsItem["Data Ping"]
		if netStats then
			local ping = math.floor(netStats:GetValue())
			pingLabel.Text = "Ping: " .. ping .. " ms"
			if ping < 100 then
				pingLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
			elseif ping < 200 then
				pingLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
			else
				pingLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
			end
		end
	end
end)

-- ESP state
local espEnabled = true
local activeESP = {}

-- Shape builder
local function createDotShape(shapeType, color)
	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Visible = false

	if shapeType == "Triangle" then
		local img = Instance.new("ImageLabel")
		img.BackgroundTransparency = 1
		img.Image = "rbxassetid://6023426923"
		img.ImageColor3 = color
		img.Size = UDim2.new(1, 0, 1, 0)
		img.Parent = frame
	else
		frame.BackgroundTransparency = 0
		frame.BackgroundColor3 = color
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = frame
	end

	return frame
end

-- ESP logic
local function createESP(model)
	local shapeType = model.Name == "HalloweenDoor" and "Triangle" or "Circle"
	local color = shapeType == "Triangle" and Color3.fromRGB(255, 100, 255) or Color3.fromRGB(255, 150, 0)

	local label = Instance.new("TextLabel")
	label.Parent = gui
	label.BackgroundTransparency = 1
	label.TextColor3 = color
	label.Font = Enum.Font.SourceSansBold
	label.TextStrokeTransparency = 0.5
	label.TextSize = 14
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Visible = true

	local dot = createDotShape(shapeType, color)
	dot.Size = UDim2.new(0, 12, 0, 12)
	dot.Parent = gui

	activeESP[#activeESP + 1] = {model, label, dot}

	task.spawn(function()
		while model and model.Parent do
			task.wait(UPDATE_INTERVAL)
			if not espEnabled then
				label.Visible = false
				dot.Visible = false
				continue
			end

			local root = model:FindFirstChildWhichIsA("BasePart")
			if not root then continue end

			local pos, onScreen = camera:WorldToViewportPoint(root.Position)
			local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			local dist = hrp and (hrp.Position - root.Position).Magnitude or 0

			if onScreen and dist < MAX_TEXT_DISTANCE then
				if dist < DOT_ONLY_DISTANCE then
					label.Visible = true
					dot.Visible = false
					label.Position = UDim2.new(0, pos.X, 0, pos.Y)
					label.Text = string.format("%s : %dm", model.Name, dist)
					label.TextSize = math.clamp(22 - (dist / MAX_TEXT_DISTANCE) * 14, 10, 22)
				else
					label.Visible = false
					dot.Visible = true
					dot.Position = UDim2.new(0, pos.X, 0, pos.Y)
					local size = math.clamp(12 - (dist / MAX_TEXT_DISTANCE) * 4, 4, 12)
					dot.Size = UDim2.new(0, size, 0, size)
				end
			else
				label.Visible = false
				dot.Visible = false
			end
		end
		label:Destroy()
		dot:Destroy()
	end)
end

-- Scan Terrain
local terrain = workspace:WaitForChild("Terrain")
for _, v in ipairs(terrain:GetDescendants()) do
	if v:IsA("Model") and (v.Name == "HalloweenDoor" or v.Name == "Pumpkin") then
		createESP(v)
	end
end

terrain.DescendantAdded:Connect(function(v)
	if v:IsA("Model") and (v.Name == "HalloweenDoor" or v.Name == "Pumpkin") then
		createESP(v)
	end
end)

-- Toggle ESP
toggleBtn.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	if espEnabled then
		toggleBtn.Text = "ESP: ON"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
	else
		toggleBtn.Text = "ESP: OFF"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	end
end)

-- Close script
closeBtn.MouseButton1Click:Connect(function()
	gui:Destroy()
	for _, esp in ipairs(activeESP) do
		for i = 2, #esp do
			if esp[i] and esp[i].Destroy then
				esp[i]:Destroy()
			end
		end
	end
	script:Destroy()
end)
