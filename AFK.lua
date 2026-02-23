-- Anti-AFK Script مع Random Time ±5s (Brainrot Evolution Optimized - 2026)
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer

-- ──── إعداداتك هنا ────
local BASE_TIME = 120  -- القيمة الأساسية بالثواني (مثال: 120 = 2 دقيقة)
local VARIATION = 5    -- ± كم ثانية random (افتراضي 5)

-- ربط للـ Idled event (مع random صغير)
player.Idled:Connect(function()
    local randomDelay = math.random(0.3, 1.2)  -- random 0.3-1.2 ثانية
    task.wait(randomDelay)
    
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(0.1 + math.random() * 0.4)  -- random click duration
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    
    print("Anti-AFK: Mouse click (random delay: " .. math.floor(randomDelay * 100)/100 .. "s)")
end)

-- الـ Loop الرئيسي مع random time كل مرة
task.spawn(function()
    while true do
        local waitTime = BASE_TIME + math.random(-VARIATION, VARIATION)
        waitTime = math.max(10, waitTime)  -- حد أدنى 10s للأمان
        
        -- ضغط Space (مع random بسيط)
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.1 + math.random() * 0.3)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
        
        print("Anti-AFK: Space press → Next in " .. math.floor(waitTime) .. "s (random: " .. (waitTime - BASE_TIME) .. "s)")
        
        task.wait(waitTime)
    end
end)

print("✅ Anti-AFK Random Loaded! Base: " .. BASE_TIME .. "s ±" .. VARIATION .. "s | Brainrot Evolution Ready")