local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Num = Instance.new("TextBox")
local Plus = Instance.new("TextButton")
local Minus = Instance.new("TextButton")
local CloseButton = Instance.new("TextButton") -- Nouveau bouton de fermeture
 
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
 
-- Hauteur réduite de 50% (100 -> 50)
Frame.Size = UDim2.new(0, 200, 0, 50) -- Changé: hauteur 100 -> 50
Frame.Position = UDim2.new(0.5, -100, 0.5, -25) -- Ajusté pour centrer avec nouvelle hauteur
Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Frame.Parent = ScreenGui
Frame.Active = true
Frame.Draggable = true
 
Num.Size = UDim2.new(0.6, 0, 0.6, 0)
Num.Position = UDim2.new(0.2, 0, 0.2, 0) -- Ajusté pour nouvelle hauteur
Num.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Num.TextColor3 = Color3.new(1, 1, 1)
Num.TextScaled = true
Num.Font = Enum.Font.SourceSans
Num.ClearTextOnFocus = true
Num.Parent = Frame
 
Plus.Size = UDim2.new(0.2, 0, 0.6, 0)
Plus.Position = UDim2.new(0.8, 0, 0.2, 0) -- Ajusté pour nouvelle hauteur
Plus.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
Plus.TextColor3 = Color3.new(1, 1, 1)
Plus.TextScaled = true
Plus.Font = Enum.Font.SourceSans
Plus.Text = "+"
Plus.Parent = Frame
 
Minus.Size = UDim2.new(0.2, 0, 0.6, 0)
Minus.Position = UDim2.new(0, 0, 0.2, 0) -- Ajusté pour nouvelle hauteur
Minus.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
Minus.TextColor3 = Color3.new(1, 1, 1)
Minus.TextScaled = true
Minus.Font = Enum.Font.SourceSans
Minus.Text = "-"
Minus.Parent = Frame
 
-- Configuration du bouton de fermeture
CloseButton.Size = UDim2.new(0, 20, 0, 20) -- Petit bouton
CloseButton.Position = UDim2.new(1, -20, 0, 0) -- En haut à droite
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Rouge
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.TextScaled = true
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.Text = "X"
CloseButton.Parent = Frame
 
local player = game.Players.LocalPlayer
local number
local humanoid
local EditingNum = false
local originalSpeed = 16 -- Vitesse par défaut de Roblox
 
local function UpdateNum()
    Num.Text = tostring(number)
    if humanoid then
        humanoid.WalkSpeed = number
    end
end
 
local function onCharacterAdded(character)
    humanoid = character:WaitForChild("Humanoid")
    number = humanoid.WalkSpeed
    originalSpeed = number -- Sauvegarde la vitesse originale
    humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if humanoid.WalkSpeed ~= number then
            humanoid.WalkSpeed = number
        end
    end)
    UpdateNum()
end
 
-- Fonction pour fermer le script et restaurer la vitesse
local function CloseScript()
    -- Restaurer la vitesse originale
    if humanoid then
        humanoid.WalkSpeed = originalSpeed
    end
    
    -- Détruire l'interface
    ScreenGui:Destroy()
    
    -- Nettoyer les connexions
    Plus.MouseButton1Click:Disconnect()
    Minus.MouseButton1Click:Disconnect()
    CloseButton.MouseButton1Click:Disconnect()
    Num.Focused:Disconnect()
    Num.FocusLost:Disconnect()
    player.CharacterAdded:Disconnect()
    
    -- Notification de fermeture
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "[Bypass] WalkSpeed Gui",
        Text = "Script fermé - Vitesse restaurée",
        Duration = 3
    })
end
 
player.CharacterAdded:Connect(onCharacterAdded)
 
if player.Character then
    onCharacterAdded(player.Character)
end
 
Plus.MouseButton1Click:Connect(function()
    number = number + 1
    UpdateNum()
end)
 
Minus.MouseButton1Click:Connect(function()
    if number > 0 then
        number = number - 1
        UpdateNum()
    end
end)
 
-- Connexion du bouton de fermeture
CloseButton.MouseButton1Click:Connect(CloseScript)
 
Num.Focused:Connect(function()
    EditingNum = true
end)
 
Num.FocusLost:Connect(function(enterPressed)
    EditingNum = false
    if enterPressed then
        local Value = tonumber(Num.Text)
        if Value and Value > 0 then
            number = Value
            UpdateNum()
        else
            UpdateNum()
        end
    end
end)
 
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "WalkSpeed Gui",
    Text = "Made By YANIS682018",
    Duration = 6
})
 
UpdateNum()