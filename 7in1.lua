-- Main Menu Loader for Roblox Scripts
-- Mini-Bar now preserves position based on MainFrame (no reset to center)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- متغيرات
local mainScreenGui = nil
local menuElements = nil
local miniBar = nil

-- -------------------------------------------------------------------------
-- Create main menu
-- -------------------------------------------------------------------------
local function createMainMenu()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ScriptLoaderMenu"
    ScreenGui.Parent = PlayerGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    mainScreenGui = ScreenGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 400, 0, 230)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -115)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Parent = ScreenGui
    MainFrame.ClipsDescendants = true

    local Shadow = Instance.new("ImageLabel")
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.Position = UDim2.new(0, -15, 0, -15)
    Shadow.Image = "rbxassetid://1316045217"
    Shadow.ImageColor3 = Color3.new(0, 0, 0)
    Shadow.ImageTransparency = 0.6
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    Shadow.BackgroundTransparency = 1
    Shadow.ZIndex = 0
    Shadow.Parent = MainFrame

    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TitleBar.BackgroundTransparency = 0.2
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -100, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "📁 Script Loader"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextScaled = true
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar

    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    MinimizeButton.Position = UDim2.new(1, -70, 0, 2.5)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    MinimizeButton.BackgroundTransparency = 0.3
    MinimizeButton.Text = "−"
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeButton.TextScaled = true
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Parent = TitleBar

    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 2.5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.BackgroundTransparency = 0.2
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextScaled = true
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.BorderSizePixel = 0
    CloseButton.Parent = TitleBar

    local ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, -20, 1, -55)
    ContentFrame.Position = UDim2.new(0, 10, 0, 45)
    ContentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ContentFrame.BackgroundTransparency = 0.2
    ContentFrame.BorderSizePixel = 0
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentFrame.ScrollBarThickness = 8
    ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ContentFrame.Parent = MainFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout.Parent = ContentFrame

    return {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        ContentFrame = ContentFrame,
        MinimizeButton = MinimizeButton,
        CloseButton = CloseButton,
        TitleBar = TitleBar
    }
end

-- -------------------------------------------------------------------------
-- Mini-Bar: 132×44, drag area ~30-35 units center
-- -------------------------------------------------------------------------
local function createMiniBar()
    if miniBar then miniBar:Destroy() end

    -- نأخذ آخر مكان للقائمة الكبيرة ونعدله شوية عشان الـ Mini-Bar ما تتداخلش
    local mainPos = menuElements.MainFrame.Position
    local miniPos = UDim2.new(
        mainPos.X.Scale,
        mainPos.X.Offset + 50,  -- شوية يمين عشان ما تتغطاش
        mainPos.Y.Scale,
        mainPos.Y.Offset - 30   -- شوية فوق عشان تبان
    )

    miniBar = Instance.new("Frame")
    miniBar.Name = "MiniBar"
    miniBar.Size = UDim2.new(0, 132, 0, 44)
    miniBar.Position = miniPos   -- يحتفظ بمكان القائمة الكبيرة (مع تعديل بسيط)
    miniBar.BackgroundColor3 = Color3.fromRGB(28, 28, 44)
    miniBar.BackgroundTransparency = 0.3
    miniBar.BorderSizePixel = 0
    miniBar.Parent = mainScreenGui

    local miniCorner = Instance.new("UICorner")
    miniCorner.CornerRadius = UDim.new(0, 12)
    miniCorner.Parent = miniBar

    -- □ Expand (يسار)
    local expandBtn = Instance.new("TextButton")
    expandBtn.Size = UDim2.new(0, 32, 0, 32)
    expandBtn.Position = UDim2.new(0, 4, 0.5, -16)
    expandBtn.BackgroundColor3 = Color3.fromRGB(80, 180, 100)
    expandBtn.Text = "□"
    expandBtn.TextColor3 = Color3.new(1,1,1)
    expandBtn.Font = Enum.Font.GothamBold
    expandBtn.TextSize = 22
    expandBtn.Parent = miniBar

    local expandCorner = Instance.new("UICorner")
    expandCorner.CornerRadius = UDim.new(0, 10)
    expandCorner.Parent = expandBtn

    -- X Close (يمين)
    local miniClose = Instance.new("TextButton")
    miniClose.Size = UDim2.new(0, 32, 0, 32)
    miniClose.Position = UDim2.new(1, -36, 0.5, -16)
    miniClose.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    miniClose.Text = "X"
    miniClose.TextColor3 = Color3.new(1,1,1)
    miniClose.Font = Enum.Font.GothamBold
    miniClose.TextSize = 20
    miniClose.Parent = miniBar

    local miniCloseCorner = Instance.new("UICorner")
    miniCloseCorner.CornerRadius = UDim.new(0, 10)
    miniCloseCorner.Parent = miniClose

    -- مساحة السحب في الوسط (نفس حجم الأزرار تقريباً)
    local dragArea = Instance.new("Frame")
    dragArea.Size = UDim2.new(0, 32, 1, 0)
    dragArea.Position = UDim2.new(0.5, -16, 0, 0)
    dragArea.BackgroundTransparency = 1
    dragArea.Parent = miniBar

    -- سحب
    local dragging = false
    local dragInput, dragStart, startPos

    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = miniBar.Position
        end
    end)

    dragArea.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            miniBar.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- أحداث الأزرار
    miniClose.MouseButton1Click:Connect(function()
        if miniBar then miniBar:Destroy() end
        if mainScreenGui then mainScreenGui:Destroy() end
    end)

    expandBtn.MouseButton1Click:Connect(function()
        if menuElements and menuElements.MainFrame then
            menuElements.MainFrame.Visible = true
            if miniBar then miniBar:Destroy() end
        end
    end)
end

-- -------------------------------------------------------------------------
-- Scripts list (نفس الأصلي)
-- -------------------------------------------------------------------------
local Scripts = {
    {Name = "1 - 99 night in the forest", Run = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Rx1m/CpsHub/refs/heads/main/Hub", true))() end},
    {Name = "2 - Jump & Teleport", Run = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Vaffuncolo/MobileTPnJump/main/MobileTPnJump.lua"))() end},
    {Name = "3 - Escape Tsunami For Brainrots", Run = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Ratkinator/RatX/refs/heads/main/Loader.lua", true))() end},
    {Name = "4 - Farming BRAINROT evolution", Run = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ywxoofc/LoaderNew/refs/heads/main/loader.lua"))() end},
    {Name = "5 - JinHub BRAINROT evolution", Run = function() loadstring(game:HttpGet("https://jinhub.my.id/scripts/BrainrotEvolution.lua"))() end},
    {Name = "6 - Speed Hack", Run = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Vaffuncolo/SPEED/main/Speed.lua"))() end},
    {Name = "7 - NoClip (Toggle + Close)", Run = function()
        -- كود NoClip هنا إذا أردت
        print("NoClip would run here")
    end}
}

-- Initialize
menuElements = createMainMenu()

for _, scriptData in ipairs(Scripts) do
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 360, 0, 50)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.BackgroundTransparency = 0.2
    button.BorderSizePixel = 0
    button.Text = scriptData.Name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 16
    button.Font = Enum.Font.GothamSemibold
    button.Parent = menuElements.ContentFrame

    button.MouseEnter:Connect(function() button.BackgroundColor3 = Color3.fromRGB(70, 70, 70) end)
    button.MouseLeave:Connect(function() button.BackgroundColor3 = Color3.fromRGB(50, 50, 50) end)

    button.MouseButton1Click:Connect(scriptData.Run)
end

-- Minimize to Mini-Bar
local function minimizeToMiniBar()
    menuElements.MainFrame.Visible = false
    createMiniBar()
end

menuElements.MinimizeButton.MouseButton1Click:Connect(minimizeToMiniBar)

menuElements.CloseButton.MouseButton1Click:Connect(function()
    if miniBar then miniBar:Destroy() end
    if mainScreenGui then mainScreenGui:Destroy() end
end)

-- Dragging main menu
local dragging, dragInput, dragStart, startPos

menuElements.MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = menuElements.MainFrame.Position
    end
end)

menuElements.MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        menuElements.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
