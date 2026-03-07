local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local mainScreenGui = nil
local menuElements = nil
local miniBar = nil

--=============================
-- DRAG SYSTEM
--=============================

local function MakeDraggable(frame)

    local dragging = false
    local dragInput
    local dragStart
    local startPos

    frame.InputBegan:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseButton1 
        or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)

        end
    end)

    frame.InputChanged:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end

    end)

    UserInputService.InputChanged:Connect(function(input)

        if input == dragInput and dragging then

            local delta = input.Position - dragStart

            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )

        end

    end)

end

--=============================
-- CREATE MAIN MENU
--=============================

local function createMainMenu()

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ScriptLoaderMenu"
    ScreenGui.Parent = PlayerGui
    ScreenGui.ResetOnSpawn = false
    mainScreenGui = ScreenGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0,400,0,230)
    MainFrame.Position = UDim2.new(0.5,-200,0.5,-115)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1,0,0,35)
    TitleBar.BackgroundColor3 = Color3.fromRGB(40,40,40)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1,-100,1,0)
    TitleLabel.Position = UDim2.new(0,10,0,0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "📁 Script Loader"
    TitleLabel.TextColor3 = Color3.new(1,1,1)
    TitleLabel.TextScaled = true
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar

    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Size = UDim2.new(0,30,0,30)
    MinimizeButton.Position = UDim2.new(1,-70,0,2)
    MinimizeButton.Text = "–"
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(80,80,80)
    MinimizeButton.TextColor3 = Color3.new(1,1,1)
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.Parent = TitleBar

    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0,30,0,30)
    CloseButton.Position = UDim2.new(1,-35,0,2)
    CloseButton.Text = "X"
    CloseButton.BackgroundColor3 = Color3.fromRGB(200,60,60)
    CloseButton.TextColor3 = Color3.new(1,1,1)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = TitleBar

    local ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Size = UDim2.new(1,-20,1,-55)
    ContentFrame.Position = UDim2.new(0,10,0,45)
    ContentFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    ContentFrame.BorderSizePixel = 0
    ContentFrame.CanvasSize = UDim2.new(0,0,0,0)
    ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ContentFrame.ScrollBarThickness = 8
    ContentFrame.Parent = MainFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,8)
    layout.Parent = ContentFrame

    MakeDraggable(MainFrame)

    return {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        ContentFrame = ContentFrame,
        MinimizeButton = MinimizeButton,
        CloseButton = CloseButton
    }

end

--=============================
-- MINI BAR
--=============================

local function createMiniBar()

    if miniBar then miniBar:Destroy() end

    miniBar = Instance.new("Frame")
    miniBar.Size = UDim2.new(0,120,0,40)
    miniBar.Position = UDim2.new(0.5,-60,0.4,0)
    miniBar.BackgroundColor3 = Color3.fromRGB(30,30,40)
    miniBar.Parent = mainScreenGui

    local expand = Instance.new("TextButton")
    expand.Size = UDim2.new(0,30,0,30)
    expand.Position = UDim2.new(0,5,0.5,-15)
    expand.Text = "☰"
    expand.BackgroundColor3 = Color3.fromRGB(80,180,100)
    expand.TextColor3 = Color3.new(1,1,1)
    expand.Parent = miniBar

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0,30,0,30)
    close.Position = UDim2.new(1,-35,0.5,-15)
    close.Text = "X"
    close.BackgroundColor3 = Color3.fromRGB(200,60,60)
    close.TextColor3 = Color3.new(1,1,1)
    close.Parent = miniBar

    expand.MouseButton1Click:Connect(function()
        menuElements.MainFrame.Visible = true
        miniBar:Destroy()
    end)

    close.MouseButton1Click:Connect(function()
        mainScreenGui:Destroy()
    end)

    MakeDraggable(miniBar)

end

--=============================
-- SCRIPTS LIST
--=============================

local Scripts = {

{
Name="1 - 99 night in the forest",
Run=function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Rx1m/CpsHub/refs/heads/main/Hub"))()
end
},

{
Name="2 - Jump & Teleport",
Run=function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Vaffuncolo/SPEED/main/TPnJump.lua"))()
end
},

{
Name="3 - Escape Tsunami",
Run=function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Ratkinator/RatX/refs/heads/main/Loader.lua"))()
end
},

{
Name="4 - Brainrot Farming",
Run=function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/ywxoofc/LoaderNew/refs/heads/main/loader.lua"))()
end
},

{
Name="5 - JinHub Brainrot",
Run=function()
loadstring(game:HttpGet("https://jinhub.my.id/scripts/BrainrotEvolution.lua"))()
end
},

{
Name="6 - Speed Hack",
Run=function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Vaffuncolo/SPEED/main/Speed.lua"))()
end
},

{
Name="7 - NoClip",
Run=function()

local RunService=game:GetService("RunService")
local char=LocalPlayer.Character

RunService.Stepped:Connect(function()
if char then
for _,v in pairs(char:GetDescendants()) do
if v:IsA("BasePart") then
v.CanCollide=false
end
end
end
end)

end
},

{
Name="8 - Anti AFK",
Run=function()

local VirtualUser=game:GetService("VirtualUser")

LocalPlayer.Idled:Connect(function()
VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
task.wait(1)
VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

print("Anti AFK Enabled")

end
},

{
Name="9 - BrainrotEvolution teleport",
Run=function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/gumanba/Scripts/main/BrainrotEvolution"))()
end
},

{
Name="10 - BreakyouBones",
Run=function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/gumanba/Scripts/main/BreakyourBones"))()
end
}

}

--=============================
-- INITIALIZE MENU
--=============================

menuElements=createMainMenu()

for _,scriptData in ipairs(Scripts) do

local button=Instance.new("TextButton")
button.Size=UDim2.new(0,360,0,50)
button.BackgroundColor3=Color3.fromRGB(50,50,50)
button.BorderSizePixel=0
button.Text=scriptData.Name
button.TextColor3=Color3.new(1,1,1)
button.Font=Enum.Font.GothamSemibold
button.TextSize=16
button.Parent=menuElements.ContentFrame

button.MouseButton1Click:Connect(scriptData.Run)

end

menuElements.MinimizeButton.MouseButton1Click:Connect(function()

menuElements.MainFrame.Visible=false
createMiniBar()

end)

menuElements.CloseButton.MouseButton1Click:Connect(function()

if miniBar then miniBar:Destroy() end
if mainScreenGui then mainScreenGui:Destroy() end

end)
