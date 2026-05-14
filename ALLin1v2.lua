local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local mainScreenGui = nil
local menuElements = nil
local miniBar = nil

-- حالات الأدوات
local noclipEnabled = false
local fullbrightEnabled = false
local espEnabled = false
local infiniteJumpEnabled = false
local godModeEnabled = false

--=============================
-- إشعارات
--=============================
local function Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3
        })
    end)
end

--=============================
-- أنيميشن سلس
--=============================
local function SmoothAppear(obj, targetTransparency, duration)
    local tween = TweenService:Create(obj, TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        BackgroundTransparency = targetTransparency
    })
    tween:Play()
    return tween
end

local function SmoothSize(obj, targetSize, duration)
    local tween = TweenService:Create(obj, TweenInfo.new(duration or 0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = targetSize
    })
    tween:Play()
    return tween
end

local function SmoothPosition(obj, targetPos, duration)
    local tween = TweenService:Create(obj, TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = targetPos
    })
    tween:Play()
    return tween
end

local function SmoothColor(obj, targetColor, duration)
    local tween = TweenService:Create(obj, TweenInfo.new(duration or 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        BackgroundColor3 = targetColor
    })
    tween:Play()
    return tween
end

--=============================
-- نظام السحب
--=============================
local function MakeDraggable(frame)
    local dragging = false
    local dragInput, dragStart, startPos

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
            local targetPos = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
            SmoothPosition(frame, targetPos, 0.08)
        end
    end)
end

--=============================
-- إنشاء حواف دائرية
--=============================
local function AddCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 10)
    corner.Parent = parent
    return corner
end

--=============================
-- إنشاء ظل
--=============================
local function AddShadow(parent)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 4)
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.Parent = parent
    return shadow
end

--=============================
-- إنشاء تدرج لوني
--=============================
local function AddGradient(parent, color1, color2, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, color1),
        ColorSequenceKeypoint.new(1, color2)
    }
    gradient.Rotation = rotation or 45
    gradient.Parent = parent
    return gradient
end

--=============================
-- إنشاء خط فاصل
--=============================
local function AddSeparator(parent)
    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(0.9, 0, 0, 1)
    sep.AnchorPoint = Vector2.new(0.5, 0)
    sep.Position = UDim2.new(0.5, 0, 0, 0)
    sep.BackgroundColor3 = Color3.fromRGB(60, 65, 80)
    sep.BackgroundTransparency = 0.5
    sep.BorderSizePixel = 0
    sep.Parent = parent
    return sep
end

--=============================
-- إنشاء القائمة الرئيسية
--=============================
local function createMainMenu()

    -- حذف أي قائمة سابقة
    local old = PlayerGui:FindFirstChild("NexusLoaderPro")
    if old then old:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NexusLoaderPro"
    ScreenGui.Parent = PlayerGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    mainScreenGui = ScreenGui

    -- الإطار الرئيسي
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    AddCorner(MainFrame, 14)
    AddShadow(MainFrame)

    -- أنيميشن الظهور
    task.delay(0.05, function()
        SmoothSize(MainFrame, UDim2.new(0, 440, 0, 420), 0.5)
    end)

    -- شريط العنوان
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 48)
    TitleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    AddCorner(TitleBar, 14)

    -- إصلاح الحواف السفلية لشريط العنوان
    local TitleBarFix = Instance.new("Frame")
    TitleBarFix.Size = UDim2.new(1, 0, 0, 16)
    TitleBarFix.Position = UDim2.new(0, 0, 1, -16)
    TitleBarFix.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
    TitleBarFix.BorderSizePixel = 0
    TitleBarFix.Parent = TitleBar

    AddGradient(TitleBar, Color3.fromRGB(30, 30, 55), Color3.fromRGB(22, 22, 35), 90)

    -- أيقونة ونص العنوان
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -120, 1, 0)
    TitleLabel.Position = UDim2.new(0, 16, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "⚡ Nexus Loader Pro"
    TitleLabel.TextColor3 = Color3.fromRGB(130, 170, 255)
    TitleLabel.TextSize = 18
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar

    -- أزرار التحكم (تصغير / إغلاق)
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Size = UDim2.new(0, 32, 0, 32)
    MinimizeButton.Position = UDim2.new(1, -76, 0, 8)
    MinimizeButton.Text = "—"
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 55, 75)
    MinimizeButton.TextColor3 = Color3.fromRGB(200, 200, 220)
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.TextSize = 16
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.AutoButtonColor = false
    MinimizeButton.Parent = TitleBar
    AddCorner(MinimizeButton, 8)

    MinimizeButton.MouseEnter:Connect(function()
        SmoothColor(MinimizeButton, Color3.fromRGB(70, 75, 100), 0.2)
    end)
    MinimizeButton.MouseLeave:Connect(function()
        SmoothColor(MinimizeButton, Color3.fromRGB(50, 55, 75), 0.2)
    end)

    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 32, 0, 32)
    CloseButton.Position = UDim2.new(1, -40, 0, 8)
    CloseButton.Text = "✕"
    CloseButton.BackgroundColor3 = Color3.fromRGB(180, 50, 60)
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 14
    CloseButton.BorderSizePixel = 0
    CloseButton.AutoButtonColor = false
    CloseButton.Parent = TitleBar
    AddCorner(CloseButton, 8)

    CloseButton.MouseEnter:Connect(function()
        SmoothColor(CloseButton, Color3.fromRGB(220, 60, 70), 0.2)
    end)
    CloseButton.MouseLeave:Connect(function()
        SmoothColor(CloseButton, Color3.fromRGB(180, 50, 60), 0.2)
    end)

    -- شريط البحث
    local SearchBar = Instance.new("Frame")
    SearchBar.Size = UDim2.new(1, -24, 0, 34)
    SearchBar.Position = UDim2.new(0, 12, 0, 54)
    SearchBar.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
    SearchBar.BorderSizePixel = 0
    SearchBar.Parent = MainFrame
    AddCorner(SearchBar, 8)

    local SearchIcon = Instance.new("TextLabel")
    SearchIcon.Size = UDim2.new(0, 30, 1, 0)
    SearchIcon.Position = UDim2.new(0, 6, 0, 0)
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Text = "🔍"
    SearchIcon.TextSize = 14
    SearchIcon.Parent = SearchBar

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(1, -44, 1, 0)
    SearchBox.Position = UDim2.new(0, 38, 0, 0)
    SearchBox.BackgroundTransparency = 1
    SearchBox.PlaceholderText = "ابحث عن سكريبت..."
    SearchBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 130)
    SearchBox.Text = ""
    SearchBox.TextColor3 = Color3.new(1, 1, 1)
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 14
    SearchBox.TextXAlignment = Enum.TextXAlignment.Left
    SearchBox.ClearTextOnFocus = false
    SearchBox.Parent = SearchBar

    -- شريط التبويبات
    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1, -24, 0, 32)
    TabBar.Position = UDim2.new(0, 12, 0, 94)
    TabBar.BackgroundTransparency = 1
    TabBar.Parent = MainFrame

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.Padding = UDim.new(0, 6)
    TabLayout.Parent = TabBar

    -- المحتوى الرئيسي - السكريبتات
    local ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Size = UDim2.new(1, -24, 1, -140)
    ContentFrame.Position = UDim2.new(0, 12, 0, 132)
    ContentFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 34)
    ContentFrame.BackgroundTransparency = 0.3
    ContentFrame.BorderSizePixel = 0
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ContentFrame.ScrollBarThickness = 4
    ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 130, 255)
    ContentFrame.ClipsDescendants = true
    ContentFrame.Parent = MainFrame
    AddCorner(ContentFrame, 10)

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 6)
    contentLayout.Parent = ContentFrame

    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 6)
    contentPadding.PaddingBottom = UDim.new(0, 6)
    contentPadding.PaddingLeft = UDim.new(0, 6)
    contentPadding.PaddingRight = UDim.new(0, 6)
    contentPadding.Parent = ContentFrame

    -- المحتوى - الأدوات
    local ToolsFrame = Instance.new("ScrollingFrame")
    ToolsFrame.Size = UDim2.new(1, -24, 1, -140)
    ToolsFrame.Position = UDim2.new(0, 12, 0, 132)
    ToolsFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 34)
    ToolsFrame.BackgroundTransparency = 0.3
    ToolsFrame.BorderSizePixel = 0
    ToolsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ToolsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ToolsFrame.ScrollBarThickness = 4
    ToolsFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 130, 255)
    ToolsFrame.ClipsDescendants = true
    ToolsFrame.Visible = false
    ToolsFrame.Parent = MainFrame
    AddCorner(ToolsFrame, 10)

    local toolsLayout = Instance.new("UIListLayout")
    toolsLayout.Padding = UDim.new(0, 6)
    toolsLayout.Parent = ToolsFrame

    local toolsPadding = Instance.new("UIPadding")
    toolsPadding.PaddingTop = UDim.new(0, 6)
    toolsPadding.PaddingBottom = UDim.new(0, 6)
    toolsPadding.PaddingLeft = UDim.new(0, 6)
    toolsPadding.PaddingRight = UDim.new(0, 6)
    toolsPadding.Parent = ToolsFrame

    -- المحتوى - الإعدادات
    local SettingsFrame = Instance.new("ScrollingFrame")
    SettingsFrame.Size = UDim2.new(1, -24, 1, -140)
    SettingsFrame.Position = UDim2.new(0, 12, 0, 132)
    SettingsFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 34)
    SettingsFrame.BackgroundTransparency = 0.3
    SettingsFrame.BorderSizePixel = 0
    SettingsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    SettingsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    SettingsFrame.ScrollBarThickness = 4
    SettingsFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 130, 255)
    SettingsFrame.ClipsDescendants = true
    SettingsFrame.Visible = false
    SettingsFrame.Parent = MainFrame
    AddCorner(SettingsFrame, 10)

    local settingsLayout = Instance.new("UIListLayout")
    settingsLayout.Padding = UDim.new(0, 6)
    settingsLayout.Parent = SettingsFrame

    local settingsPadding = Instance.new("UIPadding")
    settingsPadding.PaddingTop = UDim.new(0, 6)
    settingsPadding.PaddingBottom = UDim.new(0, 6)
    settingsPadding.PaddingLeft = UDim.new(0, 6)
    settingsPadding.PaddingRight = UDim.new(0, 6)
    settingsPadding.Parent = SettingsFrame

    -- إنشاء التبويبات
    local tabs = {}
    local frames = {
        ["📜 Scripts"] = ContentFrame,
        ["🔧 Tools"] = ToolsFrame,
        ["⚙ Settings"] = SettingsFrame
    }
    local tabOrder = {"📜 Scripts", "🔧 Tools", "⚙ Settings"}
    local activeTab = nil

    local function switchTab(tabName)
        for name, frame in pairs(frames) do
            frame.Visible = (name == tabName)
        end
        for name, btn in pairs(tabs) do
            if name == tabName then
                SmoothColor(btn, Color3.fromRGB(80, 100, 200), 0.2)
                btn.TextColor3 = Color3.new(1, 1, 1)
            else
                SmoothColor(btn, Color3.fromRGB(35, 35, 52), 0.2)
                btn.TextColor3 = Color3.fromRGB(150, 150, 170)
            end
        end
        activeTab = tabName
    end

    for _, name in ipairs(tabOrder) do
        local tab = Instance.new("TextButton")
        tab.Size = UDim2.new(0, 105, 0, 28)
        tab.BackgroundColor3 = Color3.fromRGB(35, 35, 52)
        tab.Text = name
        tab.TextColor3 = Color3.fromRGB(150, 150, 170)
        tab.Font = Enum.Font.GothamSemibold
        tab.TextSize = 12
        tab.BorderSizePixel = 0
        tab.AutoButtonColor = false
        tab.Parent = TabBar
        AddCorner(tab, 7)

        tabs[name] = tab

        tab.MouseButton1Click:Connect(function()
            switchTab(name)
        end)
    end

    switchTab("📜 Scripts")

    MakeDraggable(MainFrame)

    -- البحث
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(SearchBox.Text)
        for _, child in pairs(ContentFrame:GetChildren()) do
            if child:IsA("TextButton") then
                if query == "" then
                    child.Visible = true
                else
                    child.Visible = string.find(string.lower(child.Text), query) ~= nil
                end
            end
        end
    end)

    return {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        ContentFrame = ContentFrame,
        ToolsFrame = ToolsFrame,
        SettingsFrame = SettingsFrame,
        MinimizeButton = MinimizeButton,
        CloseButton = CloseButton
    }
end

--=============================
-- شريط التصغير
--=============================
local function createMiniBar()
    if miniBar then miniBar:Destroy() end

    miniBar = Instance.new("Frame")
    miniBar.Size = UDim2.new(0, 50, 0, 50)
    miniBar.Position = UDim2.new(0, 10, 0.5, -25)
    miniBar.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
    miniBar.BorderSizePixel = 0
    miniBar.Parent = mainScreenGui
    AddCorner(miniBar, 25)
    AddShadow(miniBar)

    local expandBtn = Instance.new("TextButton")
    expandBtn.Size = UDim2.new(1, 0, 1, 0)
    expandBtn.BackgroundTransparency = 1
    expandBtn.Text = "⚡"
    expandBtn.TextSize = 22
    expandBtn.TextColor3 = Color3.fromRGB(130, 170, 255)
    expandBtn.Font = Enum.Font.GothamBold
    expandBtn.Parent = miniBar

    expandBtn.MouseButton1Click:Connect(function()
        menuElements.MainFrame.Visible = true
        menuElements.MainFrame.Size = UDim2.new(0, 0, 0, 0)
        SmoothSize(menuElements.MainFrame, UDim2.new(0, 440, 0, 420), 0.4)
        miniBar:Destroy()
    end)

    -- تأثير نبضة
    task.spawn(function()
        while miniBar and miniBar.Parent do
            local t1 = TweenService:Create(miniBar, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Size = UDim2.new(0, 54, 0, 54)
            })
            t1:Play(); t1.Completed:Wait()
            local t2 = TweenService:Create(miniBar, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Size = UDim2.new(0, 50, 0, 50)
            })
            t2:Play(); t2.Completed:Wait()
        end
    end)

    MakeDraggable(miniBar)
end

--=============================
-- إنشاء زر سكريبت
--=============================
local function createScriptButton(parent, scriptData, index)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -4, 0, 44)
    button.BackgroundColor3 = Color3.fromRGB(32, 32, 50)
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = false
    button.Parent = parent
    AddCorner(button, 8)

    -- شريط جانبي ملون
    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 4, 0.6, 0)
    accent.Position = UDim2.new(0, 0, 0.2, 0)
    accent.BackgroundColor3 = Color3.fromRGB(80, 130, 255)
    accent.BorderSizePixel = 0
    accent.Parent = button
    AddCorner(accent, 2)

    -- رقم
    local numLabel = Instance.new("TextLabel")
    numLabel.Size = UDim2.new(0, 30, 1, 0)
    numLabel.Position = UDim2.new(0, 12, 0, 0)
    numLabel.BackgroundTransparency = 1
    numLabel.Text = tostring(index)
    numLabel.TextColor3 = Color3.fromRGB(80, 130, 255)
    numLabel.Font = Enum.Font.GothamBold
    numLabel.TextSize = 16
    numLabel.Parent = button

    -- اسم السكريبت
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -100, 1, 0)
    nameLabel.Position = UDim2.new(0, 46, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = scriptData.Name
    nameLabel.TextColor3 = Color3.fromRGB(220, 220, 240)
    nameLabel.Font = Enum.Font.GothamSemibold
    nameLabel.TextSize = 13
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Parent = button

    -- زر التشغيل
    local runIcon = Instance.new("TextLabel")
    runIcon.Size = UDim2.new(0, 36, 0, 28)
    runIcon.Position = UDim2.new(1, -46, 0.5, -14)
    runIcon.BackgroundColor3 = Color3.fromRGB(50, 180, 100)
    runIcon.BackgroundTransparency = 0.2
    runIcon.Text = "▶"
    runIcon.TextColor3 = Color3.new(1, 1, 1)
    runIcon.TextSize = 12
    runIcon.Font = Enum.Font.GothamBold
    runIcon.Parent = button
    AddCorner(runIcon, 6)

    -- تأثيرات التمرير
    button.MouseEnter:Connect(function()
        SmoothColor(button, Color3.fromRGB(42, 42, 65), 0.2)
        SmoothColor(accent, Color3.fromRGB(100, 160, 255), 0.2)
    end)
    button.MouseLeave:Connect(function()
        SmoothColor(button, Color3.fromRGB(32, 32, 50), 0.2)
        SmoothColor(accent, Color3.fromRGB(80, 130, 255), 0.2)
    end)

    button.MouseButton1Click:Connect(function()
        -- أنيميشن الضغط
        SmoothColor(button, Color3.fromRGB(50, 180, 100), 0.1)
        nameLabel.Text = "⏳ جاري التحميل..."
        task.delay(0.15, function()
            SmoothColor(button, Color3.fromRGB(32, 32, 50), 0.3)
        end)

        local success, err = pcall(scriptData.Run)
        if success then
            nameLabel.Text = "✅ " .. scriptData.Name
            Notify("✅ نجح", scriptData.Name .. " تم التشغيل!", 3)
        else
            nameLabel.Text = "❌ " .. scriptData.Name
            Notify("❌ خطأ", "فشل تشغيل: " .. scriptData.Name, 4)
        end
        task.delay(2, function()
            if nameLabel and nameLabel.Parent then
                nameLabel.Text = scriptData.Name
            end
        end)
    end)

    return button
end

--=============================
-- إنشاء زر أداة (Toggle)
--=============================
local function createToolToggle(parent, name, description, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -4, 0, 52)
    holder.BackgroundColor3 = Color3.fromRGB(32, 32, 50)
    holder.BorderSizePixel = 0
    holder.Parent = parent
    AddCorner(holder, 8)

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -80, 0, 24)
    nameLabel.Position = UDim2.new(0, 14, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = Color3.fromRGB(220, 220, 240)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 13
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = holder

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -80, 0, 16)
    descLabel.Position = UDim2.new(0, 14, 0, 28)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(120, 120, 150)
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 11
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = holder

    -- Toggle Button
    local toggleBG = Instance.new("Frame")
    toggleBG.Size = UDim2.new(0, 44, 0, 22)
    toggleBG.Position = UDim2.new(1, -56, 0.5, -11)
    toggleBG.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    toggleBG.BorderSizePixel = 0
    toggleBG.Parent = holder
    AddCorner(toggleBG, 11)

    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, 18, 0, 18)
    toggleCircle.Position = UDim2.new(0, 2, 0.5, -9)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(180, 180, 200)
    toggleCircle.BorderSizePixel = 0
    toggleCircle.Parent = toggleBG
    AddCorner(toggleCircle, 9)

    local toggled = false

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, 0, 1, 0)
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.Text = ""
    toggleBtn.Parent = holder

    toggleBtn.MouseButton1Click:Connect(function()
        toggled = not toggled
        if toggled then
            SmoothColor(toggleBG, Color3.fromRGB(70, 170, 110), 0.25)
            SmoothPosition(toggleCircle, UDim2.new(1, -20, 0.5, -9), 0.25)
            SmoothColor(toggleCircle, Color3.new(1, 1, 1), 0.25)
        else
            SmoothColor(toggleBG, Color3.fromRGB(60, 60, 80), 0.25)
            SmoothPosition(toggleCircle, UDim2.new(0, 2, 0.5, -9), 0.25)
            SmoothColor(toggleCircle, Color3.fromRGB(180, 180, 200), 0.25)
        end
        callback(toggled)
    end)

    holder.MouseEnter:Connect(function()
        SmoothColor(holder, Color3.fromRGB(38, 38, 58), 0.2)
    end)
    holder.MouseLeave:Connect(function()
        SmoothColor(holder, Color3.fromRGB(32, 32, 50), 0.2)
    end)

    return holder
end

--=============================
-- إنشاء زر أداة (عادي)
--=============================
local function createToolButton(parent, name, description, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -4, 0, 52)
    holder.BackgroundColor3 = Color3.fromRGB(32, 32, 50)
    holder.BorderSizePixel = 0
    holder.Parent = parent
    AddCorner(holder, 8)

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -80, 0, 24)
    nameLabel.Position = UDim2.new(0, 14, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = Color3.fromRGB(220, 220, 240)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 13
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = holder

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -80, 0, 16)
    descLabel.Position = UDim2.new(0, 14, 0, 28)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(120, 120, 150)
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 11
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = holder

    local actionBtn = Instance.new("TextButton")
    actionBtn.Size = UDim2.new(0, 50, 0, 26)
    actionBtn.Position = UDim2.new(1, -62, 0.5, -13)
    actionBtn.BackgroundColor3 = Color3.fromRGB(80, 100, 200)
    actionBtn.Text = "تشغيل"
    actionBtn.TextColor3 = Color3.new(1, 1, 1)
    actionBtn.Font = Enum.Font.GothamBold
    actionBtn.TextSize = 11
    actionBtn.BorderSizePixel = 0
    actionBtn.AutoButtonColor = false
    actionBtn.Parent = holder
    AddCorner(actionBtn, 6)

    actionBtn.MouseEnter:Connect(function()
        SmoothColor(actionBtn, Color3.fromRGB(100, 120, 230), 0.2)
    end)
    actionBtn.MouseLeave:Connect(function()
        SmoothColor(actionBtn, Color3.fromRGB(80, 100, 200), 0.2)
    end)

    actionBtn.MouseButton1Click:Connect(function()
        SmoothColor(actionBtn, Color3.fromRGB(50, 180, 100), 0.1)
        task.delay(0.3, function()
            SmoothColor(actionBtn, Color3.fromRGB(80, 100, 200), 0.3)
        end)
        callback()
    end)

    holder.MouseEnter:Connect(function()
        SmoothColor(holder, Color3.fromRGB(38, 38, 58), 0.2)
    end)
    holder.MouseLeave:Connect(function()
        SmoothColor(holder, Color3.fromRGB(32, 32, 50), 0.2)
    end)

    return holder
end

--=============================
-- قائمة السكريبتات
--=============================
local Scripts = {
    {
        Name = "99 Nights in the Forest",
        Run = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Rx1m/CpsHub/refs/heads/main/Hub"))()
        end
    },
    {
        Name = "Jump & Teleport",
        Run = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Vaffuncolo/SPEED/main/TPnJump.lua"))()
        end
    },
    {
        Name = "Escape Tsunami",
        Run = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Ratkinator/RatX/refs/heads/main/Loader.lua"))()
        end
    },
    {
        Name = "Brainrot Farming",
        Run = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ywxoofc/LoaderNew/refs/heads/main/loader.lua"))()
        end
    },
    {
        Name = "JinHub Brainrot",
        Run = function()
            loadstring(game:HttpGet("https://jinhub.my.id/scripts/BrainrotEvolution.lua"))()
        end
    },
    {
        Name = "Speed Hack",
        Run = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Vaffuncolo/SPEED/main/Speed.lua"))()
        end
    },
    {
        Name = "NoClip (Walk Through Walls)",
        Run = function()
            local char = LocalPlayer.Character
            RunService.Stepped:Connect(function()
                if char then
                    for _, v in pairs(char:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.CanCollide = false
                        end
                    end
                end
            end)
        end
    },
    {
        Name = "Anti AFK",
        Run = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Vaffuncolo/SPEED/main/AFK.lua"))()
        end
    },
    {
        Name = "Brainrot Evolution Teleport",
        Run = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/gumanba/Scripts/main/BrainrotEvolution"))()
        end
    },
    {
        Name = "Break Your Bones",
        Run = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/gumanba/Scripts/main/BreakyourBones"))()
        end
    },
    {
        Name = "Flying Boot/Wing",
        Run = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/gumanba/Scripts/main/FlyingWings"))()
        end
    },
}

--=============================
-- التشغيل
--=============================

menuElements = createMainMenu()

-- إضافة السكريبتات
for i, scriptData in ipairs(Scripts) do
    createScriptButton(menuElements.ContentFrame, scriptData, i)
end

-- إضافة الأدوات
createToolToggle(menuElements.ToolsFrame, "🚫 NoClip", "المرور عبر الجدران", function(enabled)
    noclipEnabled = enabled
    if enabled then
        task.spawn(function()
            while noclipEnabled do
                local char = LocalPlayer.Character
                if char then
                    for _, v in pairs(char:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.CanCollide = false
                        end
                    end
                end
                RunService.Stepped:Wait()
            end
        end)
        Notify("🚫 NoClip", "تم التفعيل", 2)
    else
        Notify("🚫 NoClip", "تم الإيقاف", 2)
    end
end)

createToolToggle(menuElements.ToolsFrame, "💡 FullBright", "إضاءة كاملة للخريطة", function(enabled)
    fullbrightEnabled = enabled
    if enabled then
        local lighting = game:GetService("Lighting")
        lighting.Brightness = 3
        lighting.ClockTime = 14
        lighting.FogEnd = 100000
        lighting.GlobalShadows = false
        if lighting:FindFirstChildOfClass("Atmosphere") then
            lighting:FindFirstChildOfClass("Atmosphere").Density = 0
        end
        Notify("💡 FullBright", "تم التفعيل", 2)
    else
        local lighting = game:GetService("Lighting")
        lighting.Brightness = 1
        lighting.GlobalShadows = true
        Notify("💡 FullBright", "تم الإيقاف", 2)
    end
end)

createToolToggle(menuElements.ToolsFrame, "🦘 Infinite Jump", "قفز لا نهائي في الهواء", function(enabled)
    infiniteJumpEnabled = enabled
    if enabled then
        Notify("🦘 Infinite Jump", "تم التفعيل - اضغط مسافة", 2)
    else
        Notify("🦘 Infinite Jump", "تم الإيقاف", 2)
    end
end)

-- ربط القفز اللانهائي
UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

createToolButton(menuElements.ToolsFrame, "🔄 Rejoin", "إعادة الانضمام للسيرفر", function()
    Notify("🔄 Rejoin", "جاري إعادة الانضمام...", 2)
    task.delay(1, function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end)
end)

createToolButton(menuElements.ToolsFrame, "💀 Reset Character", "إعادة تعيين الشخصية", function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end
    Notify("💀 Reset", "تم إعادة التعيين", 2)
end)

createToolButton(menuElements.ToolsFrame, "📋 Copy Game ID", "نسخ معرف اللعبة", function()
    if setclipboard then
        setclipboard(tostring(game.PlaceId))
        Notify("📋 Copy", "تم نسخ ID: " .. game.PlaceId, 2)
    else
        Notify("📋 Copy", "غير مدعوم في هذا المنفذ", 2)
    end
end)

createToolButton(menuElements.ToolsFrame, "📸 Screenshot Info", "عرض معلومات السيرفر", function()
    local info = "🎮 Game: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    info = info .. "\n👥 Players: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers
    info = info .. "\n🆔 Place ID: " .. game.PlaceId
    info = info .. "\n🔑 Job ID: " .. string.sub(game.JobId, 1, 12) .. "..."
    Notify("📸 Server Info", info, 6)
end)

-- إضافة الإعدادات
local function createSettingsLabel(parent, text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -4, 0, 30)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(130, 170, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

createSettingsLabel(menuElements.SettingsFrame, "ℹ️ Nexus Loader Pro v2.0")
createSettingsLabel(menuElements.SettingsFrame, "👤 Player: " .. LocalPlayer.Name)
createSettingsLabel(menuElements.SettingsFrame, "🎮 Game ID: " .. tostring(game.PlaceId))

createToolButton(menuElements.SettingsFrame, "🗑️ Destroy Menu", "حذف القائمة نهائياً", function()
    if miniBar then miniBar:Destroy() end
    if mainScreenGui then mainScreenGui:Destroy() end
end)

createToolButton(menuElements.SettingsFrame, "🔃 Reload Menu", "إعادة تحميل القائمة", function()
    if miniBar then miniBar:Destroy() end
    if mainScreenGui then mainScreenGui:Destroy() end
    task.delay(0.5, function()
        menuElements = createMainMenu()
        for i, scriptData in ipairs(Scripts) do
            createScriptButton(menuElements.ContentFrame, scriptData, i)
        end
        Notify("🔃 Reload", "تم إعادة التحميل", 2)
    end)
end)

-- أزرار التحكم الرئيسية
menuElements.MinimizeButton.MouseButton1Click:Connect(function()
    -- أنيميشن اختفاء
    SmoothSize(menuElements.MainFrame, UDim2.new(0, 0, 0, 0), 0.35)
    task.delay(0.35, function()
        menuElements.MainFrame.Visible = false
        createMiniBar()
    end)
end)

menuElements.CloseButton.MouseButton1Click:Connect(function()
    SmoothSize(menuElements.MainFrame, UDim2.new(0, 0, 0, 0), 0.3)
    task.delay(0.3, function()
        if miniBar then miniBar:Destroy() end
        if mainScreenGui then mainScreenGui:Destroy() end
    end)
end)

-- اختصار لوحة المفاتيح لفتح/إغلاق القائمة
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.F6 then
        if menuElements and menuElements.MainFrame then
            if menuElements.MainFrame.Visible then
                menuElements.MinimizeButton.MouseButton1Click:Fire()
            else
                menuElements.MainFrame.Visible = true
                menuElements.MainFrame.Size = UDim2.new(0, 0, 0, 0)
                SmoothSize(menuElements.MainFrame, UDim2.new(0, 440, 0, 420), 0.4)
                if miniBar then miniBar:Destroy() end
            end
        end
    end
end)

Notify("⚡ Nexus Loader Pro", "تم التحميل بنجاح! | RightCtrl أو F6 للفتح/الإغلاق", 5)
