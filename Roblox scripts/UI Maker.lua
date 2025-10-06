-- XETER UI MAKER v2 (Executor-friendly, Mobile)
-- Features: Instances / Create / Properties / Select-from-canvas / Gizmo X-Y drag / Move-Resize modes / Lock / DeleteAll(confirm) / Export to clipboard
-- All preview GUI objects parented under PreviewRoot so click-through is blocked.
-- Default BackgroundTransparency = 0.4 (ImageTransparency for images)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- cleanup existing
local old = playerGui:FindFirstChild("XeterUI_MakerGui_v2")
if old then old:Destroy() end

-- root GUI
local gui = Instance.new("ScreenGui")
gui.Name = "XeterUI_MakerGui_v2"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- preview root covers whole screen to block click-through & host preview items
local previewRoot = Instance.new("Frame")
previewRoot.Name = "PreviewRoot"
previewRoot.Size = UDim2.new(1,0,1,0)
previewRoot.Position = UDim2.new(0,0,0,0)
previewRoot.BackgroundTransparency = 1
previewRoot.Parent = gui
previewRoot.ZIndex = 2

-- constants
local PANEL_W = 320
local PANEL_PADDING = 12
local THEME_BG = Color3.fromRGB(24,24,24)
local THEME_PANEL = Color3.fromRGB(34,34,34)
local THEME_ACCENT = Color3.fromRGB(60,60,60)
local DEFAULT_TRANSPARENCY = 0.4

-- editor panel
local panel = Instance.new("Frame")
panel.Name = "EditorPanel"
panel.Size = UDim2.new(0, PANEL_W, 1, 0)
panel.Position = UDim2.new(1, PANEL_W, 0, 0) -- offscreen
panel.BackgroundColor3 = THEME_BG
panel.BorderSizePixel = 0
panel.Parent = gui
panel.ZIndex = 50
Instance.new("UICorner", panel).CornerRadius = UDim.new(0,8)
local panelStroke = Instance.new("UIStroke", panel); panelStroke.Color = Color3.fromRGB(60,60,60); panelStroke.Thickness = 1

-- toggle button
local toggle = Instance.new("TextButton")
toggle.Name = "ToggleBtn"
toggle.Size = UDim2.new(0,48,0,48)
toggle.Position = UDim2.new(1, -56, 0.5, -24)
toggle.BackgroundColor3 = THEME_ACCENT
toggle.Text = "☰"
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 24
toggle.TextColor3 = Color3.fromRGB(245,245,245)
toggle.Parent = gui
toggle.ZIndex = 60
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,8)

-- header (FIXED)
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 56)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundTransparency = 1
header.Parent = panel

local title = Instance.new("TextLabel")
-- beri ruang di kanan agar tombol-top (trash/lock) tidak menimpa teks
-- gunakan PANEL_PADDING untuk konsistensi; ukuran dikurangi secara offset
title.Size = UDim2.new(1, - (PANEL_PADDING * 4 + 110), 1, 0)
title.Position = UDim2.new(0, PANEL_PADDING, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Xeter UI Maker"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(230,230,230)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- top buttons (Trash, Lock)
local trashBtn = Instance.new("TextButton", header)
trashBtn.Size = UDim2.new(0,44,0,32)
trashBtn.Position = UDim2.new(1, -PANEL_PADDING - 44, 0, 12)
trashBtn.Text = "🗑"
trashBtn.Font = Enum.Font.Gotham
trashBtn.TextColor3 = Color3.fromRGB(255,255,255)
trashBtn.BackgroundColor3 = Color3.fromRGB(140,40,40)
Instance.new("UICorner", trashBtn).CornerRadius = UDim.new(0,6)

local lockBtn = Instance.new("TextButton", header)
lockBtn.Size = UDim2.new(0,44,0,32)
lockBtn.Position = UDim2.new(1, -PANEL_PADDING - 44 - 54, 0, 12)
lockBtn.Text = "🔒"
lockBtn.Font = Enum.Font.Gotham
lockBtn.TextColor3 = Color3.fromRGB(255,255,255)
lockBtn.BackgroundColor3 = Color3.fromRGB(55,55,55)
Instance.new("UICorner", lockBtn).CornerRadius = UDim.new(0,6)

-- Instances label & list
local instancesLabel = Instance.new("TextLabel", panel)
instancesLabel.Size = UDim2.new(1, -PANEL_PADDING*2, 0, 20)
instancesLabel.Position = UDim2.new(0, PANEL_PADDING, 0, 64)
instancesLabel.BackgroundTransparency = 1
instancesLabel.Text = "Instances"
instancesLabel.Font = Enum.Font.Gotham
instancesLabel.TextColor3 = Color3.fromRGB(200,200,200)
instancesLabel.TextSize = 14
instancesLabel.TextXAlignment = Enum.TextXAlignment.Left

local instancesFrame = Instance.new("ScrollingFrame", panel)
instancesFrame.Name = "InstancesList"
instancesFrame.Size = UDim2.new(1, -PANEL_PADDING*2, 0, 160)
instancesFrame.Position = UDim2.new(0, PANEL_PADDING, 0, 90)
instancesFrame.CanvasSize = UDim2.new(0,0,0,0)
instancesFrame.ScrollBarThickness = 6
instancesFrame.BackgroundTransparency = 1
local instancesLayout = Instance.new("UIListLayout", instancesFrame)
instancesLayout.SortOrder = Enum.SortOrder.LayoutOrder
instancesLayout.Padding = UDim.new(0,6)
local instancesPadding = Instance.new("UIPadding", instancesFrame)
instancesPadding.PaddingLeft = UDim.new(0,6)
instancesPadding.PaddingRight = UDim.new(0,6)
instancesPadding.PaddingTop = UDim.new(0,6)

-- Create area (dropdown)
local createLabel = Instance.new("TextLabel", panel)
createLabel.Size = UDim2.new(1, -PANEL_PADDING*2, 0, 20)
createLabel.Position = UDim2.new(0, PANEL_PADDING, 0, 262)
createLabel.BackgroundTransparency = 1
createLabel.Text = "Create"
createLabel.Font = Enum.Font.Gotham
createLabel.TextColor3 = Color3.fromRGB(200,200,200)
createLabel.TextSize = 14
createLabel.TextXAlignment = Enum.TextXAlignment.Left

local createBtn = Instance.new("TextButton", panel)
createBtn.Size = UDim2.new(1, -PANEL_PADDING*2, 0, 40)
createBtn.Position = UDim2.new(0, PANEL_PADDING, 0, 292)
createBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
createBtn.Text = "➕ Create UI Element"
createBtn.Font = Enum.Font.GothamBold
createBtn.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", createBtn).CornerRadius = UDim.new(0,6)

local dropdown = Instance.new("Frame", panel)
dropdown.Size = UDim2.new(1, -PANEL_PADDING*2, 0, 220)
dropdown.Position = UDim2.new(0, PANEL_PADDING, 0, 344)
dropdown.BackgroundColor3 = Color3.fromRGB(40,40,40)
dropdown.Visible = false
Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0,6)
local dropdownLayout = Instance.new("UIListLayout", dropdown)
dropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
dropdownLayout.Padding = UDim.new(0,6)
local dropdownPadding = Instance.new("UIPadding", dropdown)
dropdownPadding.PaddingTop = UDim.new(0,8)
dropdownPadding.PaddingLeft = UDim.new(0,8)
dropdownPadding.PaddingRight = UDim.new(0,8)

local createOptions = {"Frame","TextLabel","TextButton","ImageLabel","ImageButton","UICorner","UIStroke","Cancel"}
local optionButtons = {}
for i, opt in ipairs(createOptions) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,0,36)
    b.BackgroundColor3 = Color3.fromRGB(60,60,60)
    b.Text = opt
    b.Font = Enum.Font.Gotham
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.TextSize = 15
    b.Parent = dropdown
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    optionButtons[opt] = b
end

-- Properties label & frame
local propLabel = Instance.new("TextLabel", panel)
propLabel.Size = UDim2.new(1, -PANEL_PADDING*2, 0, 20)
propLabel.Position = UDim2.new(0, PANEL_PADDING, 0, 576)
propLabel.BackgroundTransparency = 1
propLabel.Text = "Properties"
propLabel.Font = Enum.Font.Gotham
propLabel.TextColor3 = Color3.fromRGB(200,200,200)
propLabel.TextSize = 14
propLabel.TextXAlignment = Enum.TextXAlignment.Left

local propsFrame = Instance.new("ScrollingFrame", panel)
propsFrame.Size = UDim2.new(1, -PANEL_PADDING*2, 0, 240)
propsFrame.Position = UDim2.new(0, PANEL_PADDING, 0, 604)
propsFrame.CanvasSize = UDim2.new(0,0,0,0)
propsFrame.ScrollBarThickness = 6
propsFrame.BackgroundTransparency = 1
local propsLayout = Instance.new("UIListLayout", propsFrame)
propsLayout.SortOrder = Enum.SortOrder.LayoutOrder
propsLayout.Padding = UDim.new(0,8)
local propsPadding = Instance.new("UIPadding", propsFrame)
propsPadding.PaddingLeft = UDim.new(0,8)
propsPadding.PaddingTop = UDim.new(0,8)

-- bottom center Move/Resize & gizmo area
local bottomBar = Instance.new("Frame", gui)
bottomBar.Size = UDim2.new(0, 340, 0, 72)
bottomBar.Position = UDim2.new(0.5, -170, 1, -100)
bottomBar.AnchorPoint = Vector2.new(0.5,0)
bottomBar.BackgroundTransparency = 1
bottomBar.ZIndex = 61

local modeMove = Instance.new("TextButton", bottomBar)
modeMove.Size = UDim2.new(0,150,0,48)
modeMove.Position = UDim2.new(0, 10, 0, 12)
modeMove.Text = "Move"
modeMove.Font = Enum.Font.GothamBold
modeMove.TextSize = 16
modeMove.BackgroundColor3 = Color3.fromRGB(50,50,50)
modeMove.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", modeMove).CornerRadius = UDim.new(0,10)

local modeResize = Instance.new("TextButton", bottomBar)
modeResize.Size = UDim2.new(0,150,0,48)
modeResize.Position = UDim2.new(1, -160, 0, 12)
modeResize.AnchorPoint = Vector2.new(1,0)
modeResize.Text = "Resize"
modeResize.Font = Enum.Font.GothamBold
modeResize.TextSize = 16
modeResize.BackgroundColor3 = Color3.fromRGB(45,45,45)
modeResize.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", modeResize).CornerRadius = UDim.new(0,10)

-- nudge arrows (small) - kept for fine adjustments
local nudgeFrame = Instance.new("Frame", bottomBar)
nudgeFrame.Size = UDim2.new(0,120,0,48)
nudgeFrame.Position = UDim2.new(0.5, -60, 0, 12)
nudgeFrame.BackgroundTransparency = 1

local upBtn = Instance.new("TextButton", nudgeFrame); upBtn.Size = UDim2.new(0,36,0,36); upBtn.Position = UDim2.new(0.5,-18,0,0); upBtn.Text = "↑"; upBtn.Font = Enum.Font.Gotham
local leftBtn = Instance.new("TextButton", nudgeFrame); leftBtn.Size = UDim2.new(0,36,0,36); leftBtn.Position = UDim2.new(0, -40, 0, 4); leftBtn.Text = "←"; leftBtn.Font = Enum.Font.Gotham
local rightBtn = Instance.new("TextButton", nudgeFrame); rightBtn.Size = UDim2.new(0,36,0,36); rightBtn.Position = UDim2.new(1,4,0,4); rightBtn.AnchorPoint = Vector2.new(1,0); rightBtn.Text = "→"; rightBtn.Font = Enum.Font.Gotham
local downBtn = Instance.new("TextButton", nudgeFrame); downBtn.Size = UDim2.new(0,36,0,36); downBtn.Position = UDim2.new(0.5,-18,0,4); downBtn.Text = "↓"; downBtn.Font = Enum.Font.Gotham

for _,b in pairs({upBtn,leftBtn,rightBtn,downBtn}) do
    b.BackgroundColor3 = Color3.fromRGB(60,60,60); b.TextColor3 = Color3.fromRGB(255,255,255); b.TextSize = 18
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
end

-- export button
local exportBtn = Instance.new("TextButton", panel)
exportBtn.Size = UDim2.new(1, -PANEL_PADDING*2, 0, 44)
exportBtn.Position = UDim2.new(0, PANEL_PADDING, 1, -20)
exportBtn.AnchorPoint = Vector2.new(0,1)
exportBtn.Text = "📤 Export to Lua"
exportBtn.Font = Enum.Font.GothamBold
exportBtn.TextColor3 = Color3.fromRGB(255,255,255)
exportBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
Instance.new("UICorner", exportBtn).CornerRadius = UDim.new(0,8)

-- state
local panelVisible = false
local locked = false
local selected = nil
local created = {} -- array of created GUI objects and UI instances (in previewRoot or as children)
local elementCounter = 0
local currentMode = "Move" -- or "Resize"

-- helper: refresh Instances list (shows root ScreenGui and created children as flat list with simple indent)
local function refreshInstancesList()
    -- clear old entries
    for _,c in ipairs(instancesFrame:GetChildren()) do
        if c:IsA("GuiObject") then c:Destroy() end
    end
    -- root entry (ScreenGui)
    local headerBtn = Instance.new("TextButton", instancesFrame)
    headerBtn.Size = UDim2.new(1,0,0,28)
    headerBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    headerBtn.TextColor3 = Color3.fromRGB(255,255,255)
    headerBtn.Font = Enum.Font.Gotham
    headerBtn.TextSize = 14
    headerBtn.Text = "ScreenGui"
    headerBtn.AutoButtonColor = true
    Instance.new("UICorner", headerBtn).CornerRadius = UDim.new(0,6)
    headerBtn.MouseButton1Click:Connect(function()
        selected = nil
        refreshInstancesList()
        refreshProperties()
    end)

    -- list created items with simple hierarchy: show parent name in small prefix if parent not previewRoot
    for i, obj in ipairs(created) do
        if obj and obj.Parent then
            local btn = Instance.new("TextButton", instancesFrame)
            btn.Size = UDim2.new(1,0,0,28)
            btn.BackgroundColor3 = (selected == obj) and Color3.fromRGB(80,80,80) or Color3.fromRGB(45,45,45)
            btn.TextColor3 = Color3.fromRGB(255,255,255)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            local displayName = obj.Name ~= "" and obj.Name or (obj.ClassName .. "_" .. i)
            -- show minimal parent hint
            if obj.Parent and obj.Parent ~= previewRoot then
                displayName = ("→ %s (%s)"):format(displayName, tostring(obj.Parent.Name or obj.Parent.ClassName))
            end
            btn.Text = displayName
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
            btn.MouseButton1Click:Connect(function()
                if obj and obj.Parent then
                    selected = obj
                    refreshInstancesList()
                    refreshProperties()
                end
            end)
        end
    end
    -- auto canvas size
    local count = #instancesFrame:GetChildren()
    local total = 8 + count * 34
    instancesFrame.CanvasSize = UDim2.new(0,0,0, total)
end

-- helper: set defaults for created gui objects
local function setDefaults(obj)
    if obj:IsA("GuiObject") then
        if not obj.Size then obj.Size = UDim2.new(0,160,0,40) end
        -- default safe position center-ish if zero
        pcall(function()
            if obj.Position and obj.Position.X.Offset == 0 and obj.Position.Y.Offset == 0 then
                obj.Position = UDim2.new(0,100 + (elementCounter*6) % 200, 0, 100 + (elementCounter*4) % 120)
            end
        end)
        obj.BackgroundTransparency = DEFAULT_TRANSPARENCY
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            obj.Text = obj.Text ~= "" and obj.Text or obj.ClassName
            obj.TextColor3 = Color3.fromRGB(255,255,255)
            obj.TextScaled = false
        end
        if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            obj.Image = obj.Image or ""
            obj.ImageTransparency = DEFAULT_TRANSPARENCY
        end
    end
end

-- create element (safely)
local function createElement(className)
    elementCounter = elementCounter + 1
    if className == "UICorner" or className == "UIStroke" then
        -- attach to selected parent or first created or previewRoot
        local parentCandidate = selected or created[1] or previewRoot
        local ins = Instance.new(className)
        if className == "UICorner" then ins.CornerRadius = UDim.new(0,8) end
        if className == "UIStroke" then ins.Thickness = 1.2; ins.Color = Color3.fromRGB(0,0,0) end
        ins.Parent = parentCandidate
        table.insert(created, ins)
        refreshInstancesList()
        return ins
    else
        local ins = Instance.new(className)
        ins.Name = className .. "_" .. elementCounter
        ins.Parent = previewRoot
        setDefaults(ins)
        table.insert(created, ins)
        refreshInstancesList()
        return ins
    end
end

-- properties UI builder helpers
local function clearProps()
    for _,c in ipairs(propsFrame:GetChildren()) do if c:IsA("GuiObject") then c:Destroy() end end
    propsFrame.CanvasSize = UDim2.new(0,0,0,0)
end

local function refreshProperties()
    clearProps()
    if not selected or not selected.Parent then
        local n = Instance.new("TextLabel", propsFrame)
        n.Size = UDim2.new(1, -8, 0, 28)
        n.Position = UDim2.new(0, 4, 0, 8)
        n.BackgroundTransparency = 1
        n.Text = "No selection"
        n.Font = Enum.Font.Gotham
        n.TextColor3 = Color3.fromRGB(200,200,200)
        n.TextSize = 14
        propsFrame.CanvasSize = UDim2.new(0,0,0,44)
        return
    end

    local y = 8
    -- Class
    local classLbl = Instance.new("TextLabel", propsFrame)
    classLbl.Size = UDim2.new(1, -8, 0, 22)
    classLbl.Position = UDim2.new(0, 4, 0, y)
    classLbl.BackgroundTransparency = 1
    classLbl.Text = "Class: " .. selected.ClassName
    classLbl.Font = Enum.Font.GothamBold
    classLbl.TextColor3 = Color3.fromRGB(200,200,200)
    classLbl.TextSize = 14
    y = y + 28

    -- Name
    local nameLbl = Instance.new("TextLabel", propsFrame)
    nameLbl.Size = UDim2.new(1, -8, 0, 18); nameLbl.Position = UDim2.new(0,4,0,y); nameLbl.BackgroundTransparency = 1
    nameLbl.Text = "Name"; nameLbl.Font = Enum.Font.Gotham; nameLbl.TextColor3 = Color3.fromRGB(200,200,200); nameLbl.TextSize = 13
    y = y + 20
    local nameBox = Instance.new("TextBox", propsFrame)
    nameBox.Size = UDim2.new(1, -8, 0, 28); nameBox.Position = UDim2.new(0,4,0,y); nameBox.ClearTextOnFocus = false; nameBox.Text = tostring(selected.Name or "")
    nameBox.Font = Enum.Font.Gotham; nameBox.TextSize = 14; nameBox.TextColor3 = Color3.fromRGB(240,240,240)
    y = y + 34
    nameBox.FocusLost:Connect(function()
        selected.Name = nameBox.Text
        refreshInstancesList()
    end)

    -- Position (px)
    local posLbl = Instance.new("TextLabel", propsFrame)
    posLbl.Size = UDim2.new(1,-8,0,18); posLbl.Position = UDim2.new(0,4,0,y); posLbl.BackgroundTransparency = 1
    posLbl.Text = "Position (X px, Y px)"; posLbl.Font = Enum.Font.Gotham; posLbl.TextColor3 = Color3.fromRGB(200,200,200); posLbl.TextSize = 13
    y = y + 20
    local posBox = Instance.new("TextBox", propsFrame)
    posBox.Size = UDim2.new(1, -8, 0, 28); posBox.Position = UDim2.new(0,4,0,y); posBox.ClearTextOnFocus = false
    local ap = selected.AbsolutePosition
    posBox.Text = tostring(math.floor(ap.X)) .. "," .. tostring(math.floor(ap.Y))
    posBox.Font = Enum.Font.Gotham; posBox.TextSize = 14; posBox.TextColor3 = Color3.fromRGB(240,240,240)
    y = y + 34
    posBox.FocusLost:Connect(function()
        local xs, ys = posBox.Text:match("(-?%d+),(-?%d+)")
        if xs and ys then
            local nx, ny = tonumber(xs), tonumber(ys)
            if nx and ny then selected.Position = UDim2.new(0, nx, 0, ny); refreshProperties() end
        end
    end)

    -- Size (px)
    local sizeLbl = Instance.new("TextLabel", propsFrame)
    sizeLbl.Size = UDim2.new(1,-8,0,18); sizeLbl.Position = UDim2.new(0,4,0,y); sizeLbl.BackgroundTransparency = 1
    sizeLbl.Text = "Size (W px, H px)"; sizeLbl.Font = Enum.Font.Gotham; sizeLbl.TextColor3 = Color3.fromRGB(200,200,200); sizeLbl.TextSize = 13
    y = y + 20
    local sizeBox = Instance.new("TextBox", propsFrame)
    sizeBox.Size = UDim2.new(1,-8,0,28); sizeBox.Position = UDim2.new(0,4,0,y); sizeBox.ClearTextOnFocus = false
    local asz = selected.AbsoluteSize
    sizeBox.Text = tostring(math.floor(asz.X)) .. "," .. tostring(math.floor(asz.Y))
    sizeBox.Font = Enum.Font.Gotham; sizeBox.TextSize = 14; sizeBox.TextColor3 = Color3.fromRGB(240,240,240)
    y = y + 34
    sizeBox.FocusLost:Connect(function()
        local w,h = sizeBox.Text:match("(-?%d+),(-?%d+)")
        if w and h then local wx, hy = tonumber(w), tonumber(h) if wx and hy then selected.Size = UDim2.new(0, wx, 0, hy); refreshProperties() end end
    end)

    -- Background Transparency
    local tLbl = Instance.new("TextLabel", propsFrame)
    tLbl.Size = UDim2.new(1,-8,0,18); tLbl.Position = UDim2.new(0,4,0,y); tLbl.BackgroundTransparency = 1
    tLbl.Text = "Background Transparency (0-1)"; tLbl.Font = Enum.Font.Gotham; tLbl.TextColor3 = Color3.fromRGB(200,200,200); tLbl.TextSize = 13
    y = y + 20
    local tBox = Instance.new("TextBox", propsFrame)
    tBox.Size = UDim2.new(1,-8,0,28); tBox.Position = UDim2.new(0,4,0,y); tBox.ClearTextOnFocus = false
    local currTrans = selected.BackgroundTransparency or 0
    tBox.Text = tostring(currTrans)
    tBox.Font = Enum.Font.Gotham; tBox.TextSize = 14; tBox.TextColor3 = Color3.fromRGB(240,240,240)
    y = y + 34
    tBox.FocusLost:Connect(function()
        local v = tonumber(tBox.Text)
        if v then
            if selected:IsA("ImageLabel") or selected:IsA("ImageButton") then selected.ImageTransparency = v end
            selected.BackgroundTransparency = v
            refreshProperties()
        end
    end)

    -- Text for TextLabel/TextButton
    if selected:IsA("TextLabel") or selected:IsA("TextButton") then
        local txLbl = Instance.new("TextLabel", propsFrame)
        txLbl.Size = UDim2.new(1,-8,0,18); txLbl.Position = UDim2.new(0,4,0,y); txLbl.BackgroundTransparency = 1
        txLbl.Text = "Text"; txLbl.Font = Enum.Font.Gotham; txLbl.TextColor3 = Color3.fromRGB(200,200,200); txLbl.TextSize = 13
        y = y + 20
        local txtBox = Instance.new("TextBox", propsFrame)
        txtBox.Size = UDim2.new(1,-8,0,28); txtBox.Position = UDim2.new(0,4,0,y); txtBox.ClearTextOnFocus = false
        txtBox.Text = tostring(selected.Text or ""); txtBox.Font = Enum.Font.Gotham; txtBox.TextSize = 14; txtBox.TextColor3 = Color3.fromRGB(240,240,240)
        y = y + 34
        txtBox.FocusLost:Connect(function() selected.Text = txtBox.Text; refreshProperties() end)
    end

    -- Image field for images
    if selected:IsA("ImageLabel") or selected:IsA("ImageButton") then
        local ilLbl = Instance.new("TextLabel", propsFrame)
        ilLbl.Size = UDim2.new(1,-8,0,18); ilLbl.Position = UDim2.new(0,4,0,y); ilLbl.BackgroundTransparency = 1
        ilLbl.Text = "Image (rbxassetid://...)" ; ilLbl.Font = Enum.Font.Gotham; ilLbl.TextColor3 = Color3.fromRGB(200,200,200); ilLbl.TextSize = 13
        y = y + 20
        local ibox = Instance.new("TextBox", propsFrame)
        ibox.Size = UDim2.new(1,-8,0,28); ibox.Position = UDim2.new(0,4,0,y); ibox.ClearTextOnFocus = false
        ibox.Text = tostring(selected.Image or ""); ibox.Font = Enum.Font.Gotham; ibox.TextSize = 14; ibox.TextColor3 = Color3.fromRGB(240,240,240)
        y = y + 34
        ibox.FocusLost:Connect(function() selected.Image = ibox.Text; refreshProperties() end)
    end

    propsFrame.CanvasSize = UDim2.new(0,0,0,y + 12)
end

-- highlight frame for selection (visual)
local selHighlight = Instance.new("Frame")
selHighlight.Size = UDim2.new(1,0,1,0)
selHighlight.BackgroundTransparency = 1
selHighlight.BorderSizePixel = 0
selHighlight.Parent = previewRoot
local selStroke = Instance.new("UIStroke")
selStroke.Parent = selHighlight
selStroke.Thickness = 2
selStroke.Color = Color3.fromRGB(255,200,60)
selStroke.Transparency = 0.5

-- gizmo arrows (X red, Y green) - small draggable handles anchored to selected
local gizmoRoot = Instance.new("Folder", gui)
gizmoRoot.Name = "GizmoRoot"

local gizmoX = Instance.new("ImageButton")
gizmoX.Size = UDim2.new(0,24,0,24)
gizmoX.AnchorPoint = Vector2.new(0.5,0.5)
gizmoX.BackgroundTransparency = 0
gizmoX.BackgroundColor3 = Color3.fromRGB(200,80,80)
gizmoX.Visible = false
gizmoX.AutoButtonColor = false
gizmoX.Parent = gui
Instance.new("UICorner", gizmoX).CornerRadius = UDim.new(0,6)

local gizmoY = Instance.new("ImageButton")
gizmoY.Size = UDim2.new(0,24,0,24)
gizmoY.AnchorPoint = Vector2.new(0.5,0.5)
gizmoY.BackgroundTransparency = 0
gizmoY.BackgroundColor3 = Color3.fromRGB(80,200,120)
gizmoY.Visible = false
gizmoY.AutoButtonColor = false
gizmoY.Parent = gui
Instance.new("UICorner", gizmoY).CornerRadius = UDim.new(0,6)

-- helper: topmost created object under position (manual hit-test), returns object or nil
local function getTopCreatedAt(x,y)
    for i = #created, 1, -1 do
        local g = created[i]
        if g and g.Parent and g:IsA("GuiObject") then
            local pos = g.AbsolutePosition
            local size = g.AbsoluteSize
            -- check visibility chain
            local ancestor = g
            local visible = true
            while ancestor and ancestor.Parent do
                if ancestor:IsA("GuiObject") and ancestor.Visible == false then visible = false; break end
                ancestor = ancestor.Parent
            end
            if visible and x >= pos.X and x <= pos.X + size.X and y >= pos.Y and y <= pos.Y + size.Y then
                return g
            end
        end
    end
    return nil
end

-- drag / resize state
local dragging = false
local resizing = false
local gizmoDragging = false
local dragStart = nil
local origPos = nil
local origSize = nil
local gizmoMode = nil -- "X" or "Y"

-- selection helpers
local function attachHighlightTo(obj)
    if not obj or not obj:IsA("GuiObject") then
        selHighlight.Parent = previewRoot
        selHighlight.Visible = false
        return
    end
    selHighlight.Size = UDim2.new(0, obj.AbsoluteSize.X, 0, obj.AbsoluteSize.Y)
    selHighlight.Position = UDim2.new(0, obj.AbsolutePosition.X, 0, obj.AbsolutePosition.Y)
    selHighlight.Visible = true
    selHighlight.Parent = previewRoot
    -- bring stroke above
    selHighlight.ZIndex = obj.ZIndex + 1
    selStroke.Parent = selHighlight
end

local function updateGizmosFor(obj)
    if not obj or not obj:IsA("GuiObject") or locked then
        gizmoX.Visible = false; gizmoY.Visible = false
        return
    end
    local pos = obj.AbsolutePosition
    local size = obj.AbsoluteSize
    -- place gizmos at center of left/right/top/bottom
    -- X gizmo on right center
    gizmoX.Position = UDim2.new(0, pos.X + size.X + 18, 0, pos.Y + size.Y/2)
    gizmoX.Visible = true
    gizmoX.ZIndex = obj.ZIndex + 5
    -- Y gizmo on top center
    gizmoY.Position = UDim2.new(0, pos.X + size.X/2, 0, pos.Y - 18)
    gizmoY.Visible = true
    gizmoY.ZIndex = obj.ZIndex + 5
end

-- input handling
local function startDrag(point)
    if not selected or locked then return end
    dragging = true
    dragStart = point
    origPos = selected.AbsolutePosition
end
local function startResize(point)
    if not selected or locked then return end
    resizing = true
    dragStart = point
    origSize = selected.AbsoluteSize
end
local function startGizmo(mode, point)
    if not selected or locked then return end
    gizmoDragging = true
    gizmoMode = mode
    dragStart = point
    origPos = selected.AbsolutePosition
    origSize = selected.AbsoluteSize
end

local function updateDrag(point)
    if dragging and selected then
        local dx = point.X - dragStart.X
        local dy = point.Y - dragStart.Y
        selected.Position = UDim2.new(0, math.floor(origPos.X + dx), 0, math.floor(origPos.Y + dy))
        attachHighlightTo(selected)
        updateGizmosFor(selected)
        refreshProperties()
    end
end

local function updateResize(point)
    if resizing and selected then
        local dx = point.X - dragStart.X
        local dy = point.Y - dragStart.Y
        local newW = math.max(2, math.floor(origSize.X + dx))
        local newH = math.max(2, math.floor(origSize.Y + dy))
        selected.Size = UDim2.new(0, newW, 0, newH)
        attachHighlightTo(selected)
        updateGizmosFor(selected)
        refreshProperties()
    end
end

local function updateGizmoDrag(point)
    if gizmoDragging and selected then
        local dx = point.X - dragStart.X
        local dy = point.Y - dragStart.Y
        if gizmoMode == "X" then
            -- move along X only
            selected.Position = UDim2.new(0, math.floor(origPos.X + dx), 0, origPos.Y)
        elseif gizmoMode == "Y" then
            selected.Position = UDim2.new(0, origPos.X, 0, math.floor(origPos.Y + dy))
        end
        attachHighlightTo(selected)
        updateGizmosFor(selected)
        refreshProperties()
    end
end

local function endAllDrag()
    dragging = false; resizing = false; gizmoDragging = false; dragStart = nil; origPos = nil; origSize = nil; gizmoMode = nil
end

-- input events
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        local p = input.Position
        -- priority: gizmo clicks first
        local gxPos = gizmoX.AbsolutePosition; local gxSize = gizmoX.AbsoluteSize
        local gyPos = gizmoY.AbsolutePosition; local gySize = gizmoY.AbsoluteSize
        if gizmoX.Visible and p.X >= gxPos.X and p.X <= gxPos.X + gxSize.X and p.Y >= gxPos.Y and p.Y <= gxPos.Y + gxSize.Y then
            startGizmo("X", p); return
        end
        if gizmoY.Visible and p.X >= gyPos.X and p.X <= gyPos.X + gySize.X and p.Y >= gyPos.Y and p.Y <= gyPos.Y + gySize.Y then
            startGizmo("Y", p); return
        end

        -- if tapping on a created GUI element:
        local hit = getTopCreatedAt(p.X, p.Y)
        if hit and not locked then
            selected = hit
            attachHighlightTo(selected)
            updateGizmosFor(selected)
            refreshInstancesList()
            refreshProperties()
            if currentMode == "Move" then startDrag(p) else startResize(p) end
            return
        else
            -- tapped empty - deselect
            selected = nil
            attachHighlightTo(nil)
            gizmoX.Visible = false; gizmoY.Visible = false
            refreshInstancesList()
            refreshProperties()
            return
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        local p = input.Position
        if dragging then updateDrag(p) end
        if resizing then updateResize(p) end
        if gizmoDragging then updateGizmoDrag(p) end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        endAllDrag()
    end
end)

-- toggle panel function (and move toggle button so it remains visible)
toggle.MouseButton1Click:Connect(function()
    panelVisible = not panelVisible
    local target = panelVisible and UDim2.new(1, -PANEL_W, 0, 0) or UDim2.new(1, PANEL_W, 0, 0)
    TweenService:Create(panel, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = target}):Play()
    local toggleTarget = panelVisible and UDim2.new(1, -PANEL_W - 56, 0.5, -24) or UDim2.new(1, -56, 0.5, -24)
    TweenService:Create(toggle, TweenInfo.new(0.35), {Position = toggleTarget}):Play()
end)

-- create dropdown
createBtn.MouseButton1Click:Connect(function()
    dropdown.Visible = not dropdown.Visible
end)

-- option button events (create)
for name, btn in pairs(optionButtons) do
    btn.MouseButton1Click:Connect(function()
        if name == "Cancel" then dropdown.Visible = false; return end
        local newObj = createElement(name)
        -- ensure transparency default
        if newObj and newObj:IsA("GuiObject") then
            newObj.BackgroundTransparency = DEFAULT_TRANSPARENCY
            if newObj:IsA("ImageLabel") or newObj:IsA("ImageButton") then newObj.ImageTransparency = DEFAULT_TRANSPARENCY end
        end
        selected = newObj
        attachHighlightTo(selected)
        updateGizmosFor(selected)
        dropdown.Visible = false
        refreshInstancesList()
        refreshProperties()
    end)
end

-- lock toggle
lockBtn.MouseButton1Click:Connect(function()
    locked = not locked
    lockBtn.Text = locked and "🔓" or "🔒" -- inverted icon so it shows action available
    if locked then endAllDrag() end
    -- hide gizmos if locked
    if locked then gizmoX.Visible = false; gizmoY.Visible = false end
end)

-- trash (delete all) with confirm
trashBtn.MouseButton1Click:Connect(function()
    local confirm = Instance.new("Frame", gui)
    confirm.Size = UDim2.new(0, 380, 0, 150)
    confirm.Position = UDim2.new(0.5, -190, 0.5, -75)
    confirm.AnchorPoint = Vector2.new(0.5,0.5)
    confirm.BackgroundColor3 = Color3.fromRGB(36,36,36)
    confirm.ZIndex = 300
    Instance.new("UICorner", confirm).CornerRadius = UDim.new(0,8)
    local txt = Instance.new("TextLabel", confirm)
    txt.Size = UDim2.new(1, -24, 0, 72); txt.Position = UDim2.new(0,12,0,12); txt.BackgroundTransparency = 1
    txt.Text = "Are you sure you want to delete ALL created elements?"
    txt.Font = Enum.Font.Gotham; txt.TextSize = 15; txt.TextColor3 = Color3.fromRGB(230,230,230); txt.TextWrapped = true

    local yes = Instance.new("TextButton", confirm)
    yes.Size = UDim2.new(0,140,0,36); yes.Position = UDim2.new(0,12,1,-48); yes.Text="Yes"; yes.BackgroundColor3 = Color3.fromRGB(160,40,40)
    local cancel = Instance.new("TextButton", confirm)
    cancel.Size = UDim2.new(0,140,0,36); cancel.Position = UDim2.new(1,-152,1,-48); cancel.Text="Cancel"; cancel.BackgroundColor3 = Color3.fromRGB(70,70,70)
    Instance.new("UICorner", yes).CornerRadius = UDim.new(0,6); Instance.new("UICorner", cancel).CornerRadius = UDim.new(0,6)
    yes.Font = Enum.Font.Gotham; cancel.Font = Enum.Font.Gotham

    yes.MouseButton1Click:Connect(function()
        for i=#created,1,-1 do
            local o = created[i]
            pcall(function() if o then o:Destroy() end end)
            table.remove(created, i)
        end
        selected = nil
        attachHighlightTo(nil)
        gizmoX.Visible = false; gizmoY.Visible = false
        refreshInstancesList()
        refreshProperties()
        confirm:Destroy()
    end)
    cancel.MouseButton1Click:Connect(function() confirm:Destroy() end)
end)

-- nudge buttons (fine adjust)
local function nudge(dx,dy)
    if not selected then return end
    if currentMode == "Move" then
        selected.Position = UDim2.new(0, selected.AbsolutePosition.X + dx, 0, selected.AbsolutePosition.Y + dy)
    else
        selected.Size = UDim2.new(0, math.max(2, selected.AbsoluteSize.X + dx), 0, math.max(2, selected.AbsoluteSize.Y + dy))
    end
    refreshProperties()
end
upBtn.MouseButton1Click:Connect(function() nudge(0, -4) end)
downBtn.MouseButton1Click:Connect(function() nudge(0, 4) end)
leftBtn.MouseButton1Click:Connect(function() nudge(-4, 0) end)
rightBtn.MouseButton1Click:Connect(function() nudge(4, 0) end)

-- mode toggles
modeMove.MouseButton1Click:Connect(function()
    currentMode = "Move"
    modeMove.BackgroundColor3 = Color3.fromRGB(50,50,50)
    modeResize.BackgroundColor3 = Color3.fromRGB(45,45,45)
end)
modeResize.MouseButton1Click:Connect(function()
    currentMode = "Resize"
    modeResize.BackgroundColor3 = Color3.fromRGB(50,50,50)
    modeMove.BackgroundColor3 = Color3.fromRGB(45,45,45)
end)

-- export builder (recursive children under previewRoot)
local function colorToRGBString(c)
    return string.format("%d,%d,%d", math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255))
end

local function exportAll()
    local lines = {}
    table.insert(lines, "-- Exported UI (Xeter UI Maker v2)")
    table.insert(lines, "local player = game.Players.LocalPlayer")
    table.insert(lines, "local parent = player:WaitForChild('PlayerGui')")

    local function exportInstance(inst, varName)
        local cls = inst.ClassName
        table.insert(lines, string.format("local %s = Instance.new('%s')", varName, cls))
        -- properties
        if inst:IsA("GuiObject") then
            table.insert(lines, string.format("%s.Size = UDim2.new(%s,%s,%s,%s)", varName,
                tostring(inst.Size.X.Scale), tostring(inst.Size.X.Offset), tostring(inst.Size.Y.Scale), tostring(inst.Size.Y.Offset)))
            table.insert(lines, string.format("%s.Position = UDim2.new(%s,%s,%s,%s)", varName,
                tostring(inst.Position.X.Scale), tostring(inst.Position.X.Offset), tostring(inst.Position.Y.Scale), tostring(inst.Position.Y.Offset)))
            table.insert(lines, string.format("%s.BackgroundColor3 = Color3.fromRGB(%s)", varName, colorToRGBString(inst.BackgroundColor3 or Color3.new(1,1,1))))
            table.insert(lines, string.format("%s.BackgroundTransparency = %s", varName, tostring(inst.BackgroundTransparency or 0)))
        end
        if inst:IsA("TextLabel") or inst:IsA("TextButton") then
            table.insert(lines, string.format("%s.Text = %q", varName, tostring(inst.Text or "")))
            table.insert(lines, string.format("%s.TextColor3 = Color3.fromRGB(%s)", varName, colorToRGBString(inst.TextColor3 or Color3.new(1,1,1))))
        end
        if inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
            table.insert(lines, string.format("%s.Image = %q", varName, tostring(inst.Image or "")))
            table.insert(lines, string.format("%s.ImageTransparency = %s", varName, tostring(inst.ImageTransparency or 0)))
        end
        -- parent assignment handled by caller
    end

    -- export only direct children of previewRoot (flat)
    for i, inst in ipairs(created) do
        if inst and inst.Parent then
            local name = ("obj%d"):format(i)
            exportInstance(inst, name)
            table.insert(lines, string.format("%s.Parent = parent", name))
            table.insert(lines, "")
        end
    end

    local full = table.concat(lines, "\n")
    local ok = pcall(function() setclipboard(full) end)
    if ok then
        local notify = Instance.new("TextLabel", gui)
        notify.Size = UDim2.new(0,220,0,36)
        notify.Position = UDim2.new(0.5, -110, 0, 12)
        notify.BackgroundColor3 = Color3.fromRGB(40,40,40)
        notify.TextColor3 = Color3.fromRGB(170,255,170)
        notify.Text = "Exported to clipboard"
        notify.AnchorPoint = Vector2.new(0.5,0)
        Instance.new("UICorner", notify)
        Debris:AddItem(notify, 1.6)
    else
        -- fallback: show textbox with code to copy
        local out = Instance.new("TextBox", gui)
        out.Size = UDim2.new(0, math.min(1000, math.floor(workspace.CurrentCamera.ViewportSize.X * 0.8)), 0, math.min(600, math.floor(workspace.CurrentCamera.ViewportSize.Y * 0.8)))
        out.Position = UDim2.new(0.5, -out.Size.X.Offset/2, 0.5, -out.Size.Y.Offset/2)
        out.AnchorPoint = Vector2.new(0.5,0.5)
        out.Text = full
        out.MultiLine = true
        out.TextWrapped = true
        out.ClearTextOnFocus = false
        out.TextXAlignment = Enum.TextXAlignment.Left
        out.TextYAlignment = Enum.TextYAlignment.Top
        out.Font = Enum.Font.Code
        out.TextSize = 14
        out.BackgroundColor3 = Color3.fromRGB(18,18,18)
        out.TextColor3 = Color3.fromRGB(220,220,220)
        Instance.new("UICorner", out)
        local close = Instance.new("TextButton", out)
        close.Size = UDim2.new(0,64,0,30)
        close.Position = UDim2.new(1, -74, 0, 8)
        close.Text = "Close"
        Instance.new("UICorner", close)
        close.MouseButton1Click:Connect(function() out:Destroy() end)
    end
end

exportBtn.MouseButton1Click:Connect(exportAll)

-- final initialization
refreshInstancesList()
refreshProperties()
attachHighlightTo(nil)

print("[Xeter UI Maker v2] Ready — toggle with the gear on the right.")
