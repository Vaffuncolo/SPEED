--// Services
local Players = game:GetService("Players")
local UserInput = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

--// Settings
local MAX_LOCATIONS = 3

--// State
local savedPos = {}
local locButtons = {}
local infiniteJump = true
local noclip = false
local wallhack = false
local persist = false
local lastTeleportPos

local char, humanoid, root

--// Character
local function bindChar(c)
	char = c
	humanoid = c:WaitForChild("Humanoid")
	root = c:WaitForChild("HumanoidRootPart")
end
if player.Character then bindChar(player.Character) end
player.CharacterAdded:Connect(bindChar)

--// GUI ROOT
local sg = Instance.new("ScreenGui")
sg.ResetOnSpawn = false
sg.Parent = PlayerGui

--================ MAIN FRAME =================
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0,380,0,86)
main.Position = UDim2.new(0.5,-190,0.08,0)
main.BackgroundColor3 = Color3.fromRGB(30,30,38)
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0,14)

--================ DRAG ======================
local dragging, dragStart, startPos
main.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1
	or i.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = i.Position
		startPos = main.Position
	end
end)
main.InputEnded:Connect(function() dragging = false end)
UserInput.InputChanged:Connect(function(i)
	if dragging then
		local d = i.Position - dragStart
		main.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + d.X,
			startPos.Y.Scale, startPos.Y.Offset + d.Y
		)
	end
end)

--================ HEADER ====================
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1,0,0,26)
header.BackgroundTransparency = 1

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0,18,0,18)
closeBtn.Position = UDim2.new(0,6,0,4)
closeBtn.Text = "x"
closeBtn.BackgroundTransparency = 1
closeBtn.TextColor3 = Color3.fromRGB(220,80,80)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14

local miniBtn = Instance.new("TextButton", header)
miniBtn.Size = UDim2.new(0,18,0,18)
miniBtn.Position = UDim2.new(0,28,0,4)
miniBtn.Text = "–"
miniBtn.BackgroundTransparency = 1
miniBtn.TextColor3 = Color3.fromRGB(200,200,200)
miniBtn.Font = Enum.Font.GothamBold
miniBtn.TextSize = 16

--================ ICON (MINIMIZED) ==========
local icon = Instance.new("TextButton", sg)
icon.Size = UDim2.new(0,42,0,42)
icon.Position = UDim2.new(0.05,0,0.5,0)
icon.Text = "🕸️"
icon.TextSize = 26
icon.Font = Enum.Font.GothamBold
icon.BackgroundColor3 = Color3.fromRGB(45,45,60)
icon.TextColor3 = Color3.new(1,1,1)
icon.Visible = false
Instance.new("UICorner", icon).CornerRadius = UDim.new(1,0)

-- Drag icon
icon.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1
	or i.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = i.Position
		startPos = icon.Position
	end
end)
icon.InputEnded:Connect(function() dragging = false end)
UserInput.InputChanged:Connect(function(i)
	if dragging and icon.Visible then
		local d = i.Position - dragStart
		icon.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + d.X,
			startPos.Y.Scale, startPos.Y.Offset + d.Y
		)
	end
end)

miniBtn.MouseButton1Click:Connect(function()
	main.Visible = false
	icon.Visible = true
end)
icon.MouseButton1Click:Connect(function()
	icon.Visible = false
	main.Visible = true
end)
closeBtn.MouseButton1Click:Connect(function()
	sg:Destroy()
end)

--================ CONTENT ===================
local content = Instance.new("Frame", main)
content.Position = UDim2.new(0,0,0,26)
content.Size = UDim2.new(1,0,1,-26)
content.BackgroundTransparency = 1

local holder = Instance.new("Frame", content)
holder.Size = UDim2.new(1,-10,1,0)
holder.Position = UDim2.new(0,5,0,0)
holder.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", holder)
layout.FillDirection = Enum.FillDirection.Horizontal
layout.Padding = UDim.new(0,6)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center

--================ BUTTON FACTORY ============
local function makeBtn(txt, color, w)
	local b = Instance.new("TextButton", holder)
	b.Size = UDim2.new(0,w or 42,0,42)
	b.Text = txt
	b.Font = Enum.Font.GothamBold
	b.TextSize = 15
	b.BackgroundColor3 = color
	b.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
	return b
end

local jumpBtn    = makeBtn("Jump\nON", Color3.fromRGB(60,140,80))
jumpBtn.TextSize = 13
local persistBtn = makeBtn("🧊", Color3.fromRGB(90,90,120))
local noclipBtn  = makeBtn("NC", Color3.fromRGB(140,60,60))
local wallBtn    = makeBtn("WH", Color3.fromRGB(90,90,90))
local addBtn     = makeBtn("+", Color3.fromRGB(70,170,100), 38)
addBtn.TextSize  = 22

--================ LOCATIONS =================
local locFrame = Instance.new("Frame", holder)
locFrame.Size = UDim2.new(1,-(42*5+6*6),1,0)
locFrame.BackgroundTransparency = 1

local locLayout = Instance.new("UIListLayout", locFrame)
locLayout.FillDirection = Enum.FillDirection.Horizontal
locLayout.Padding = UDim.new(0,6)

local function refreshLocs()
	for _,b in ipairs(locButtons) do b:Destroy() end
	table.clear(locButtons)

	for i,p in ipairs(savedPos) do
		local b = Instance.new("TextButton", locFrame)
		b.Size = UDim2.new(0,36,0,36)
		b.Text = tostring(i)
		b.Font = Enum.Font.GothamBold
		b.TextSize = 16
		b.BackgroundColor3 = Color3.fromRGB(55,55,70)
		b.TextColor3 = Color3.new(1,1,1)
		Instance.new("UICorner", b).CornerRadius = UDim.new(0,9)

		b.MouseButton1Click:Connect(function()
			lastTeleportPos = p
			root.CFrame = CFrame.new(p + Vector3.new(0,3,0))
		end)

		local hold
		b.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.Touch
			or i.UserInputType == Enum.UserInputType.MouseButton1 then
				hold = tick()
			end
		end)
		b.InputEnded:Connect(function()
			if hold and tick()-hold > 0.6 then
				table.remove(savedPos, i)
				refreshLocs()
			end
		end)

		table.insert(locButtons, b)
	end
end

addBtn.MouseButton1Click:Connect(function()
	if root and #savedPos < MAX_LOCATIONS then
		table.insert(savedPos, root.Position)
		refreshLocs()
	end
end)

--================ LOGIC =====================
jumpBtn.MouseButton1Click:Connect(function()
	infiniteJump = not infiniteJump
	jumpBtn.Text = "Jump\n"..(infiniteJump and "ON" or "OFF")
	jumpBtn.BackgroundColor3 = infiniteJump and Color3.fromRGB(60,140,80) or Color3.fromRGB(140,60,60)
end)

UserInput.JumpRequest:Connect(function()
	if infiniteJump and humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

persistBtn.MouseButton1Click:Connect(function()
	persist = not persist
	persistBtn.BackgroundColor3 = persist and Color3.fromRGB(80,160,200) or Color3.fromRGB(90,90,120)
end)

RunService.RenderStepped:Connect(function()
	if persist and root and lastTeleportPos then
		root.CFrame = CFrame.new(lastTeleportPos + Vector3.new(0,3,0))
	end
end)

noclipBtn.MouseButton1Click:Connect(function()
	noclip = not noclip
	noclipBtn.BackgroundColor3 = noclip and Color3.fromRGB(60,160,80) or Color3.fromRGB(140,60,60)
end)

RunService.Stepped:Connect(function()
	if noclip and char then
		for _,p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") then
				p.CanCollide = false
			end
		end
	end
end)

wallBtn.MouseButton1Click:Connect(function()
	wallhack = not wallhack
	wallBtn.BackgroundColor3 = wallhack and Color3.fromRGB(90,140,200) or Color3.fromRGB(90,90,90)
end)

RunService.Stepped:Connect(function()
	for _,p in ipairs(workspace:GetDescendants()) do
		if p:IsA("BasePart") and not (char and p:IsDescendantOf(char)) then
			p.LocalTransparencyModifier = wallhack and 0.7 or 0
		end
	end
end)

print("Mobile TP GUI (Header fixed) Loaded ✓")