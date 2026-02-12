--// Services
local Players = game:GetService("Players")
local UserInput = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

--// Settings
local MAX_LOCATIONS = 3
local GUI_NAME = "MobileTPnJump"

--// Variables
local savedPos = {}
local buttons = {}
local infiniteJump = true
local humanoid, root

--// Character handler
local function bindCharacter(char)
    humanoid = char:WaitForChild("Humanoid")
    root = char:WaitForChild("HumanoidRootPart")
end

if player.Character then bindCharacter(player.Character) end
player.CharacterAdded:Connect(bindCharacter)

--// Create GUI
local sg = Instance.new("ScreenGui")
sg.Name = GUI_NAME
sg.ResetOnSpawn = false
sg.DisplayOrder = 15
sg.Parent = PlayerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 295, 0, 48)
main.Position = UDim2.new(0.5, -132, 0.08, 0)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = sg

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local gradient = Instance.new("UIGradient", main)
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(45,45,55)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25,25,33))
}
gradient.Rotation = 90

--// Button Holder
local btnHolder = Instance.new("Frame", main)
btnHolder.Size = UDim2.new(1,0,1,0)
btnHolder.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", btnHolder)
layout.FillDirection = Enum.FillDirection.Horizontal
layout.Padding = UDim.new(0,8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center

--// Button Factory
local function makeButton(text, color, size)
    local b = Instance.new("TextButton")
    b.Size = size or UDim2.new(0,42,0,42)
    b.Text = text
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 18
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
    b.Parent = btnHolder
    return b
end

local close = makeButton("❌", Color3.fromRGB(190,60,60))
local jumpToggle = makeButton("Jump\nON", Color3.fromRGB(60,140,80))
jumpToggle.TextSize = 14
local addLoc = makeButton("+", Color3.fromRGB(70,170,100))
addLoc.TextSize = 26

--// Locations Frame
local locFrame = Instance.new("Frame", btnHolder)
locFrame.Size = UDim2.new(1, -(42*3 + 8*4 + 10), 1, 0)
locFrame.BackgroundTransparency = 1

local locLayout = Instance.new("UIListLayout", locFrame)
locLayout.FillDirection = Enum.FillDirection.Horizontal
locLayout.Padding = UDim.new(0,6)

--// Tween effect
local function tweenColor(obj, color)
    TweenService:Create(obj, TweenInfo.new(0.15), {BackgroundColor3 = color}):Play()
end

--// Teleport
local function teleportTo(pos)
    if root then
        root.CFrame = CFrame.new(pos + Vector3.new(0,3,0))
    end
end

--// Refresh buttons
local function refreshLocationButtons()
    for _, b in ipairs(buttons) do
        b:Destroy()
    end
    table.clear(buttons)

    for i, pos in ipairs(savedPos) do
        createLocationButton(i, pos)
    end

    if #savedPos < MAX_LOCATIONS then
        addLoc.Text = "+"
        addLoc.BackgroundColor3 = Color3.fromRGB(70,170,100)
        addLoc.AutoButtonColor = true
    end
end

--// Create Location Button
function createLocationButton(index, pos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,38,0,38)
    btn.BackgroundColor3 = Color3.fromRGB(55,55,70)
    btn.Text = tostring(index)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 17
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    btn.Parent = locFrame

    -- Teleport
    btn.MouseButton1Click:Connect(function()
        teleportTo(pos)
        tweenColor(btn, Color3.fromRGB(120,220,120))
        task.wait(0.2)
        tweenColor(btn, Color3.fromRGB(55,55,70))
    end)

    -- Hold delete
    local holdStart
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            holdStart = tick()
        end
    end)

    btn.InputEnded:Connect(function()
        if holdStart and tick() - holdStart > 0.6 then
            table.remove(savedPos, index)
            refreshLocationButtons()
        end
    end)

    table.insert(buttons, btn)
end

--// Add Position
local function addNewPosition()
    if #savedPos >= MAX_LOCATIONS or not root then return end

    local pos = root.Position
    table.insert(savedPos, pos)

    createLocationButton(#savedPos, pos)

    if #savedPos >= MAX_LOCATIONS then
        addLoc.Text = "FULL"
        addLoc.BackgroundColor3 = Color3.fromRGB(120,120,120)
        addLoc.AutoButtonColor = false
    end
end

--// Buttons Logic
close.MouseButton1Click:Connect(function()
    sg:Destroy()
end)

addLoc.MouseButton1Click:Connect(addNewPosition)

jumpToggle.MouseButton1Click:Connect(function()
    infiniteJump = not infiniteJump
    jumpToggle.Text = "Jump\n" .. (infiniteJump and "ON" or "OFF")
    tweenColor(jumpToggle, infiniteJump and Color3.fromRGB(60,140,80) or Color3.fromRGB(140,60,60))
end)

--// Infinite Jump
UserInput.JumpRequest:Connect(function()
    if infiniteJump and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

--// Dragging GUI
local dragging, dragStart, startPos

main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        tweenColor(main, Color3.fromRGB(40,40,50))
    end
end)

main.InputEnded:Connect(function()
    dragging = false
    tweenColor(main, Color3.fromRGB(30,30,38))
end)

UserInput.InputChanged:Connect(function(input)
    if dragging then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

print("Mobile TP + Infinite Jump Loaded ✓")