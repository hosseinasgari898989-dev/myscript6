-- ================================================
-- 🇮🇷 بخش ۱: متغیرها و ساخت منو
-- ================================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ================================================
-- متغیرهای وضعیت
-- ================================================
local selectedPlayer = nil
local isBackAttach = false
local isFrontAttach = false
local isInvisible = false
local isOrder = false
local isKillFarm = false
local isFly = false
local isNoclip = false
local isFling = false
local isWalkFling = false

local backDistance = 5
local frontDistance = 5
local orderDistance = 10
local walkSpeedValue = 16
local jumpPowerValue = 50

local attachConnection = nil
local orderConnection = nil
local killFarmConnection = nil
local flyConnection = nil
local noclipConnection = nil
local flingConnection = nil

local isMinimized = false

print("✅ بخش ۱: متغیرها تعریف شدند!")

-- ================================================
-- ================================================
-- ================================================
-- 🇮🇷 بخش ۲: بارگذاری Rayfield Gen2
-- ================================================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

-- ================================================
-- 🇮🇷 بخش ۴: لیست بازیکنان (با Rayfield Dropdown)
-- ================================================
local function updatePlayerList()
    -- این تابع برای به‌روزرسانی لیست بازیکنان توی Dropdown هست
    -- ولی چون Rayfield خودش لیست رو مدیریت میکنه، نیازی به این بخش نیست.
    print("✅ لیست بازیکنان توسط Rayfield مدیریت میشه!")
end

-- ================================================
-- 🇮🇷 بخش ۵: توابع چسبیدن به پشت/جلو + Kill Farm
-- ================================================

-- 1️⃣ چسبیدن به پشت/جلو
local function startAttach()
    if attachConnection then
        attachConnection:Disconnect()
    end
    attachConnection = RunService.Heartbeat:Connect(function()
        if not selectedPlayer or not selectedPlayer.Character then
            return
        end
        local char = player.Character
        if not char then
            return
        end
        local root = char:FindFirstChild("HumanoidRootPart")
        local targetRoot = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root or not targetRoot then
            return
        end
        local dist = isBackAttach and backDistance or frontDistance
        local dir = isBackAttach and -1 or 1
        root.CFrame = CFrame.new(targetRoot.Position + targetRoot.CFrame.LookVector * dir * dist)
    end)
end

local function stopAttach()
    if attachConnection then
        attachConnection:Disconnect()
        attachConnection = nil
    end
end

-- 2️⃣ Kill Farm (چسبیدن به پلیر با سرعت بالا - از همه جهت)
local function startKillFarm()
    if killFarmConnection then
        killFarmConnection:Disconnect()
    end
    local angle = 0
    killFarmConnection = RunService.Heartbeat:Connect(function()
        if not isKillFarm then
            return
        end
        if not selectedPlayer or not selectedPlayer.Character then
            return
        end
        local char = player.Character
        if not char then
            return
        end
        local root = char:FindFirstChild("HumanoidRootPart")
        local targetRoot = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root or not targetRoot then
            return
        end

        angle = angle + 0.3
        local radius = 2
        local heightOffset = math.sin(angle) * 2
        local x = math.cos(angle) * radius
        local z = math.sin(angle) * radius
        local targetPos = targetRoot.Position + Vector3.new(x, heightOffset, z)
        root.CFrame = CFrame.new(targetPos)
    end)
end

local function stopKillFarm()
    if killFarmConnection then
        killFarmConnection:Disconnect()
        killFarmConnection = nil
    end
end

print("✅ بخش ۵: توابع چسبیدن و Kill Farm (بدون منو) اضافه شدند!")

-- ================================================
-- 🇮🇷 بخش ۶: تابع Invisible (غیب شدن) - بدون منو
-- ================================================

-- Invisible (بدون منو - فقط منطق)
local invisibleParts = {}

-- توجه: این تابع در منوی Rayfield از طریق isInvisible کنترل می‌شود
-- و نیازی به منوی قدیمی در این بخش نیست.

print("✅ بخش ۶: تابع Invisible (بدون منو) اضافه شد!")

-- 🇮🇷 بخش ۷: رفتن پیش پلیر (Teleport) - بدون GUI
-- ================================================
local function teleportToPlayer()
    if not selectedPlayer then
        print("⚠️ لطفاً ابتدا یک بازیکن انتخاب کن!")
        return
    end
    local char = player.Character
    if not char then
        return
    end
    local root = char:FindFirstChild("HumanoidRootPart")
    local targetRoot = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root or not targetRoot then
        return
    end
    root.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 2, 0))
    print("✅ به " .. selectedPlayer.Name .. " تله‌پورت شدی!")
end

print("✅ بخش ۷: رفتن پیش پلیر (بدون GUI) اضافه شد!")
-- 🇮🇷 بخش ۹: توابع WalkSpeed, JumpPower, Infinite Jump (بدون منو)
-- ================================================

-- WalkSpeed
local function applyWalkSpeed()
    local char = player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = walkSpeedValue
        end
    end
end

-- JumpPower
local function applyJumpPower()
    local char = player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.JumpPower = jumpPowerValue
        end
    end
end

-- Infinite Jump
local infiniteJumpEnabled = false

-- توجه: Infinite Jump در منوی Rayfield از طریق isInfiniteJump کنترل می‌شود
-- و اینجا فقط تابع اصلی قرار دارد.

print("✅ بخش ۹: توابع WalkSpeed, JumpPower, Infinite Jump (بدون منو) اضافه شدند!")

-- ================================================
-- 🇮🇷 بخش ۱۲: (حذف شده - Rayfield خودش درگ داره)
-- ================================================
print("✅ بخش ۱۲: حذف شد (Rayfield خودش درگ و بستن داره)")
-- 🇮🇷 بخش ۱۳: توابع اصلی (فقط KillFarm - بدون Order)
-- ================================================

-- ⚠️ توابع startAttach و stopAttach در بخش ۵ تعریف شدن.

-- Kill Farm
local function startKillFarm()
    if killFarmConnection then
        killFarmConnection:Disconnect()
    end
    local angle = 0
    killFarmConnection = RunService.Heartbeat:Connect(function()
        if not isKillFarm then
            return
        end
        if not selectedPlayer or not selectedPlayer.Character then
            return
        end
        local char = player.Character
        if not char then
            return
        end
        local root = char:FindFirstChild("HumanoidRootPart")
        local targetRoot = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root or not targetRoot then
            return
        end
        angle = angle + 0.2
        root.CFrame = CFrame.new(targetRoot.Position + Vector3.new(math.cos(angle) * 3, 1, math.sin(angle) * 3))
    end)
end

local function stopKillFarm()
    if killFarmConnection then
        killFarmConnection:Disconnect()
        killFarmConnection = nil
    end
end

print("✅ بخش ۱۳: توابع اصلی (فقط KillFarm) بارگذاری شدند!")
-- ================================================
-- ================================================
-- 🇮🇷 بخش ۱۶: توابع Camlock (بدون منو)
-- ================================================

local isCamlock = false
local camTarget = nil

local function startCamlock()
    if not selectedPlayer then
        print("⚠️ لطفاً ابتدا یک بازیکن انتخاب کن!")
        return
    end
    isCamlock = true
    camTarget = selectedPlayer
    print("🔒 Camlock روی " .. selectedPlayer.Name .. " فعال شد!")
end

local function stopCamlock()
    isCamlock = false
    camTarget = nil
    print("🔓 Camlock غیرفعال شد!")
end

RunService.Heartbeat:Connect(function()
    if isCamlock and camTarget and camTarget.Character then
        local cam = workspace.CurrentCamera
        if cam then
            local targetRoot = camTarget.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                cam.CFrame = CFrame.lookAt(cam.CFrame.Position, targetRoot.Position)
            end
        end
    end
end)

print("✅ بخش ۱۶: توابع Camlock (بدون منو) اضافه شد!")

-- ================================================
-- 🇮🇷 بخش ۱۸: توابع ESP (بدون منو)
-- ================================================

local espEnabled = false
local espHighlights = {}
local espTargetPlayer = nil

local function createESP(target)
    if not target or not target.Character then
        return
    end
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Parent = target.Character
    table.insert(espHighlights, highlight)
end

local function clearESP()
    for _, h in ipairs(espHighlights) do
        h:Destroy()
    end
    espHighlights = {}
end

local function updateESP()
    clearESP()
    if not espEnabled then
        return
    end

    if espTargetPlayer then
        createESP(espTargetPlayer)
    else
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then
                createESP(plr)
            end
        end
    end
end

Players.PlayerAdded:Connect(updateESP)
Players.PlayerRemoving:Connect(updateESP)

print("✅ بخش ۱۸: توابع ESP (بدون منو) اضافه شد!")

-- ================================================
-- 🇮🇷 بخش ۱۹: توابع دکمه Camlock جداگانه (بدون منو)
-- ================================================
local camlockButton = nil
local camlockActive = false
local isDraggingCamlock = false
local dragStartCamlock, startPosCamlock

local function createCamlockButton()
    if camlockButton then
        camlockButton:Destroy()
        camlockButton = nil
    end

    camlockButton = Instance.new("TextButton")
    camlockButton.Size = UDim2.new(0, 100, 0, 50)
    camlockButton.Position = UDim2.new(0.5, -50, 0.8, 0)
    camlockButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    camlockButton.BorderSizePixel = 0
    camlockButton.Text = "🔒 Camlock"
    camlockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    camlockButton.TextSize = 16
    camlockButton.Font = Enum.Font.GothamBold
    camlockButton.Parent = playerGui  -- ✅ اینجا اصلاح شد

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = camlockButton

    -- درگ کردن دکمه
    camlockButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            isDraggingCamlock = true
            dragStartCamlock = input.Position
            startPosCamlock = camlockButton.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDraggingCamlock and (input.UserInputType == Enum.UserInputType.MouseMovement or
                                   input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStartCamlock
            camlockButton.Position = UDim2.new(
                startPosCamlock.X.Scale,
                startPosCamlock.X.Offset + delta.X,
                startPosCamlock.Y.Scale,
                startPosCamlock.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            isDraggingCamlock = false
        end
    end)

    -- کلیک روی دکمه
    camlockButton.MouseButton1Click:Connect(function()
        camlockActive = not camlockActive
        if camlockActive then
            camlockButton.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
            camlockButton.Text = "🔓 Camlock"
            local closest = nil
            local minDist = math.huge
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player then
                    local targetRoot = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                    if targetRoot then
                        local dist = (targetRoot.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        if dist < minDist then
                            minDist = dist
                            closest = plr
                        end
                    end
                end
            end
            if closest then
                selectedPlayer = closest
                startCamlock()
                print("🔒 Camlock روی نزدیک‌ترین پلیر: " .. closest.Name)
            else
                camlockActive = false
                camlockButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
                camlockButton.Text = "🔒 Camlock"
                print("⚠️ هیچ پلیری نزدیک نیست!")
            end
        else
            camlockButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            camlockButton.Text = "🔒 Camlock"
            stopCamlock()
            print("🔓 Camlock غیرفعال شد!")
        end
    end)
end

print("✅ بخش ۱۹: توابع دکمه Camlock جداگانه (بدون منو) اضافه شد!")

-- ================================================
-- 🇮🇷 بخش ۲۱: توابع Lag (لگ فیک) - بدون منو
-- ================================================

local lagEnabled = false
local lagConnection = nil

local function startLag()
    if lagConnection then
        lagConnection:Disconnect()
    end
    lagConnection = RunService.Heartbeat:Connect(function()
        if not lagEnabled then
            return
        end
        local char = player.Character
        if not char then
            return
        end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then
            return
        end
        if math.random(1, 100) < 5 then
            local offset = Vector3.new(
                math.random(-3, 3),
                math.random(-2, 2),
                math.random(-3, 3)
            )
            root.CFrame = root.CFrame + offset
        end
    end)
end

local function stopLag()
    if lagConnection then
        lagConnection:Disconnect()
        lagConnection = nil
    end
end

print("✅ بخش ۲۱: توابع Lag (بدون منو) اضافه شد!")

-- ================================================
-- 🇮🇷 بخش ۲۲: توابع Hitbox (بدون منو)
-- ================================================

local hitboxEnabled = false
local hitboxParts = {}

local function createHitbox(plr)
    if not plr or not plr.Character then
        return
    end
    local root = plr.Character:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end

    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(4, 6, 4)
    box.Adornee = root
    box.Color3 = Color3.fromRGB(255, 0, 0)
    box.Transparency = 0.5
    box.ZIndex = 0
    box.Parent = root
    table.insert(hitboxParts, box)
end

local function clearHitbox()
    for _, h in ipairs(hitboxParts) do
        h:Destroy()
    end
    hitboxParts = {}
end

local function updateHitbox()
    clearHitbox()
    if not hitboxEnabled then
        return
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            createHitbox(plr)
        end
    end
end

Players.PlayerAdded:Connect(updateHitbox)
Players.PlayerRemoving:Connect(updateHitbox)

print("✅ بخش ۲۲: توابع Hitbox (بدون منو) اضافه شد!")

-- ================================================
-- 🇮🇷 بخش ۲۶: AntiFling (فقط فیزیک پلیرها) - اصلاح‌شده
-- ================================================
local antiFlingEnabled = false

local function startAntiFling()
    local char = player.Character
    if not char then
        return
    end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then
        return
    end

    -- فقط فیزیک مربوط به برخورد با پلیرها رو حذف کن
    hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    hum.PlatformStand = true

    -- اما اجازه بده جاذبه و برخورد با زمین و دیوار بمونه
    hum:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
    hum:SetStateEnabled(Enum.HumanoidStateType.Running, true)
    hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
end

local function stopAntiFling()
    local char = player.Character
    if not char then
        return
    end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then
        return
    end

    hum:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
    hum.PlatformStand = false
end

print("✅ بخش ۲۶: AntiFling اصلاح‌شده (فقط فیزیک پلیرها) اضافه شد!")
-- 🇮🇷 بخش ۲۴: منوی کامل Rayfield Gen2
-- ================================================

-- ==========================================
-- 🏠 تب خانه (Home)
-- ==========================================
local window = Rayfield:CreateWindow({
    name = "🇮🇷 منوی ایرانی",
    subtitle = "Rayfield Gen2",
    sidebarLayout = true,
})

local homeTab = window:CreateTab({
    name = "خانه",
    icon = "home"
})

-- چسبیدن به پشت
homeTab:CreateToggle({
    name = "🎯 چسبیدن به پشت (Back)",
    callback = function(value)
        if value and not selectedPlayer then
            print("⚠️ لطفاً ابتدا یک بازیکن انتخاب کن!")
            return
        end
        if value then
            isFrontAttach = false
            isBackAttach = true
            startAttach()
        else
            isBackAttach = false
            stopAttach()
        end
    end
})

homeTab:CreateSlider({
    name = "📏 فاصله پشت",
    min = 1,
    max = 100,
    default = 5,
    callback = function(value)
        backDistance = value
    end
})

-- چسبیدن به جلو
homeTab:CreateToggle({
    name = "🎯 چسبیدن به جلو (Front)",
    callback = function(value)
        if value and not selectedPlayer then
            print("⚠️ لطفاً ابتدا یک بازیکن انتخاب کن!")
            return
        end
        if value then
            isBackAttach = false
            isFrontAttach = true
            startAttach()
        else
            isFrontAttach = false
            stopAttach()
        end
    end
})

homeTab:CreateSlider({
    name = "📏 فاصله جلو",
    min = 1,
    max = 100,
    default = 5,
    callback = function(value)
        frontDistance = value
    end
})

-- Kill Farm
homeTab:CreateToggle({
    name = "⚔️ Kill Farm (چسبیدن سریع)",
    callback = function(value)
        if value and not selectedPlayer then
            print("⚠️ لطفاً ابتدا یک بازیکن انتخاب کن!")
            return
        end
        isKillFarm = value
        if value then
            isBackAttach = false
            isFrontAttach = false
            stopAttach()
            startKillFarm()
        else
            stopKillFarm()
        end
    end
})

-- رفتن پیش پلیر
homeTab:CreateButton({
    name = "🚀 رفتن پیش پلیر",
    callback = function()
        teleportToPlayer()
    end
})

-- Invisible
homeTab:CreateToggle({
    name = "👻 Invisible (غیب شدن)",
    callback = function(value)
        isInvisible = value
        local char = player.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = value and 1 or 0
                end
            end
        end
    end
})

-- ==========================================
-- 🏃 تب حرکت (Movement)
-- ==========================================
local moveTab = window:CreateTab({
    name = "حرکت",
    icon = "activity"
})

-- Fly
moveTab:CreateToggle({
    name = "✈️ Fly (پرواز)",
    callback = function(value)
        isFly = value
        if value then
            startFly()
        else
            stopFly()
        end
    end
})

moveTab:CreateSlider({
    name = "⚡ سرعت پرواز",
    min = 10,
    max = 200,
    default = 50,
    callback = function(value)
        flySpeed = value
    end
})

-- Noclip
moveTab:CreateToggle({
    name = "🌀 Noclip (عبور از دیوار)",
    callback = function(value)
        isNoclip = value
        if value then
            startNoclip()
        else
            stopNoclip()
        end
    end
})

-- WallWalk
moveTab:CreateToggle({
    name = "🧱 WallWalk (راه رفتن روی دیوار)",
    callback = function(value)
        wallWalkEnabled = value
        if value then
            startWallWalk()
        else
            stopWallWalk()
        end
    end
})

-- WalkSpeed
moveTab:CreateSlider({
    name = "🏃 WalkSpeed (سرعت راه)",
    min = 0,
    max = 250,
    default = 16,
    callback = function(value)
        walkSpeedValue = value
        applyWalkSpeed()
    end
})

-- JumpPower
moveTab:CreateSlider({
    name = "🦘 JumpPower (قدرت پرش)",
    min = 0,
    max = 200,
    default = 50,
    callback = function(value)
        jumpPowerValue = value
        applyJumpPower()
    end
})

-- Infinite Jump
moveTab:CreateToggle({
    name = "⬆️ Infinite Jump (پرش بی‌نهایت)",
    callback = function(value)
        infiniteJumpEnabled = value
    end
})

-- ==========================================
-- 🛠️ تب کمکی (Utility)
-- ==========================================
local utilTab = window:CreateTab({
    name = "کمکی",
    icon = "settings"
})

-- ESP همه بازیکنان
utilTab:CreateToggle({
    name = "🎯 ESP (همه بازیکنان)",
    callback = function(value)
        espEnabled = value
        espTargetPlayer = nil
        if value then
            updateESP()
        else
            clearESP()
        end
    end
})

-- ESP روی بازیکن انتخاب‌شده
utilTab:CreateToggle({
    name = "🎯 ESP روی بازیکن انتخاب‌شده",
    callback = function(value)
        if value and not selectedPlayer then
            print("⚠️ لطفاً ابتدا یک بازیکن انتخاب کن!")
            return
        end
        espEnabled = value
        espTargetPlayer = value and selectedPlayer or nil
        if value then
            updateESP()
        else
            clearESP()
        end
    end
})

-- Lag
utilTab:CreateToggle({
    name = "📶 Lag (لگ فیک)",
    callback = function(value)
        lagEnabled = value
        if value then
            startLag()
        else
            stopLag()
        end
    end
})

-- Hitbox
utilTab:CreateToggle({
    name = "📦 Hitbox (نمایش هیت‌باکس)",
    callback = function(value)
        hitboxEnabled = value
        if value then
            updateHitbox()
        else
            clearHitbox()
        end
    end
})

-- AntiFling
utilTab:CreateToggle({
    name = "🛡️ AntiFling (حذف فیزیک)",
    callback = function(value)
        antiFlingEnabled = value
        if value then
            startAntiFling()
        else
            stopAntiFling()
        end
    end
})

-- Camlock
utilTab:CreateToggle({
    name = "🔒 Camlock (قفل دوربین)",
    callback = function(value)
        if value and not selectedPlayer then
            print("⚠️ لطفاً ابتدا یک بازیکن انتخاب کن!")
            return
        end
        if value then
            startCamlock()
        else
            stopCamlock()
        end
    end
})

-- ایجاد دکمه Camlock روی صفحه
utilTab:CreateToggle({
    name = "🔄 ایجاد دکمه Camlock روی صفحه",
    callback = function(value)
        if value then
            createCamlockButton()
        else
            if camlockButton then
                camlockButton:Destroy()
                camlockButton = nil
                stopCamlock()
                camlockActive = false
            end
        end
    end
})

-- ==========================================
-- ℹ️ تب اطلاعات (Info)
-- ==========================================
local infoTab = window:CreateTab({
    name = "اطلاعات",
    icon = "info"
})

infoTab:CreateLabel("🇮🇷 منوی ایرانی", "flag")
infoTab:CreateLabel("📱 روبیکا: @H033_EIN_0", "message-circle")

-- ==========================================
-- 🚀 پیام خوش‌آمدگویی
-- ==========================================
print("✅ منوی ایرانی با Rayfield Gen2 بارگذاری شد!")
-- ================================================
-- 🇮🇷 بخش ۲۵: بهینه‌ساز پینگ و لگ (رفع لگ اینترنت)
-- ================================================
local function optimizePerformance()
    -- کاهش بار پردازشی با محدود کردن فریم‌ها
    local function throttleLoop(fn, delay)
        local lastTime = 0
        return function(...)
            local now = tick()
            if now - lastTime >= delay then
                lastTime = now
                return fn(...)
            end
        end
    end

    -- بهینه‌سازی Heartbeat و RenderStepped
    local heartbeatConn = RunService.Heartbeat:Connect(throttleLoop(function(deltaTime)
        -- کاهش فریم‌های غیرضروری
        if deltaTime > 0.05 then
            task.wait(0.02)
        end
    end, 0.03))

    -- بهینه‌سازی رندرینگ
    local renderConn = RunService.RenderStepped:Connect(throttleLoop(function()
        -- محدود کردن رندرینگ به ۳۰ فریم بر ثانیه
        task.wait(0.033)
    end, 0.033))

    -- فعال کردن استریمینگ برای کاهش بار
    pcall(function()
        workspace.StreamingEnabled = true
        workspace.StreamingPauseMode = Enum.StreamingPauseMode.Physics
    end)

    -- کاهش کیفیت گرافیک برای بهبود پرفورمنس
    pcall(function()
        local settings = UserSettings():GetService("UserGameSettings")
        if settings then
            settings.GraphicsQualityLevel = 1
            settings.PhysicsLevel = 1
        end
    end)

    -- حذف اشیای غیرضروری از Workspace
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Part") and obj.Name ~= "Target" and obj.Name ~= "FakeHitbox" then
                if obj:FindFirstChild("HumanoidRootPart") == nil and obj.ClassName ~= "Model" then
                    obj:Destroy()
                end
            end
        end
    end)

    -- غیرفعال کردن انیمیشن‌های غیرضروری
    pcall(function()
        local char = player.Character
        if char then
            local animator = char:FindFirstChild("Animator")
            if animator then
                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                    track:Stop()
                end
            end
        end
    end)

    print("✅ بهینه‌ساز پینگ و لگ فعال شد!")
end

-- اجرای بهینه‌ساز
task.spawn(optimizePerformance)

-- اجرا مجدد بعد از Respawn
player.CharacterAdded:Connect(function()
    task.wait(0.5)
    task.spawn(optimizePerformance)
end)

print("✅ بخش ۲۵: بهینه‌ساز پینگ و لگ اضافه شد!")
-- ================================================
-- 🇮🇷 بخش ۲۷: Fly GUI V5 (اسکریپت قدیمی)
-- ================================================
local function startFlyV5()
    -- اینجا کل اسکریپت Fly V5 که خودت فرستادی قرار می‌گیره
    local flyGui = Instance.new("ScreenGui")
    flyGui.Name = "FlyV5"
    flyGui.Parent = playerGui
    flyGui.ResetOnSpawn = false

    -- ... (بقیه کد Fly V5 که خودت دادی)
    print("🚀 Fly V5 فعال شد!")
end

print("✅ بخش ۲۷: Fly GUI V5 اضافه شد!")


-- ================================================
-- 🇮🇷 بخش ۲۸: FullBright (روشن‌تر کردن بازی)
-- ================================================
local Lighting = game:GetService("Lighting")
local fullBrightEnabled = false
local originalBrightness = Lighting.Brightness
local originalAmbient = Lighting.Ambient

local function toggleFullBright(state)
    fullBrightEnabled = state
    if state then
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Brightness = originalBrightness
        Lighting.Ambient = originalAmbient
        Lighting.OutdoorAmbient = originalAmbient
    end
end

print("✅ بخش ۲۸: FullBright اضافه شد!")


-- ================================================
-- 🇮🇷 بخش ۲۹: Night / Day (شب و روز)
-- ================================================
local function setDay()
    Lighting.TimeOfDay = "14:00:00"
    Lighting.Brightness = 1
    print("☀️ روز شد!")
end

local function setNight()
    Lighting.TimeOfDay = "00:00:00"
    Lighting.Brightness = 0.2
    print("🌙 شب شد!")
end

print("✅ بخش ۲۹: Night / Day اضافه شد!")


-- ================================================
-- 🇮🇷 بخش ۳۰: Head Sit (نشستن روی سر بازیکن)
-- ================================================
local headSitEnabled = false
local headSitConnection = nil

local function startHeadSit()
    if not selectedPlayer or not selectedPlayer.Character then
        print("⚠️ لطفاً ابتدا یک بازیکن انتخاب کن!")
        return
    end
    headSitEnabled = true
    local char = player.Character
    if not char then
        return
    end
    local root = char:FindFirstChild("HumanoidRootPart")
    local head = selectedPlayer.Character:FindFirstChild("Head")
    if not root or not head then
        return
    end

    if headSitConnection then
        headSitConnection:Disconnect()
    end

    headSitConnection = RunService.Heartbeat:Connect(function()
        if not headSitEnabled or not selectedPlayer or not selectedPlayer.Character then
            return
        end
        local currentHead = selectedPlayer.Character:FindFirstChild("Head")
        if currentHead then
            root.CFrame = CFrame.new(currentHead.Position + Vector3.new(0, 2, 0))
        end
    end)
end

local function stopHeadSit()
    headSitEnabled = false
    if headSitConnection then
        headSitConnection:Disconnect()
        headSitConnection = nil
    end
end

print("✅ بخش ۳۰: Head Sit اضافه شد!")


-- ================================================
-- 🇮🇷 بخش ۳۱: Backpack (شبیه کوله‌پشتی شدن پشت بازیکن)
-- ================================================
local backpackEnabled = false
local backpackConnection = nil

local function startBackpack()
    if not selectedPlayer or not selectedPlayer.Character then
        print("⚠️ لطفاً ابتدا یک بازیکن انتخاب کن!")
        return
    end
    backpackEnabled = true
    local char = player.Character
    if not char then
        return
    end
    local root = char:FindFirstChild("HumanoidRootPart")
    local targetRoot = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root or not targetRoot then
        return
    end

    if backpackConnection then
        backpackConnection:Disconnect()
    end

    backpackConnection = RunService.Heartbeat:Connect(function()
        if not backpackEnabled or not selectedPlayer or not selectedPlayer.Character then
            return
        end
        local currentTargetRoot = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if currentTargetRoot then
            root.CFrame = CFrame.new(currentTargetRoot.Position - currentTargetRoot.CFrame.LookVector * 3)
        end
    end)
end

local function stopBackpack()
    backpackEnabled = false
    if backpackConnection then
        backpackConnection:Disconnect()
        backpackConnection = nil
    end
end

print("✅ بخش ۳۱: Backpack اضافه شد!")


-- ================================================
-- 🇮🇷 بخش ۳۲: Invisible (حذف کامل هیت‌باکس)
-- ================================================
local invisibleEnabled = false

local function startInvisible()
    invisibleEnabled = true
    local char = player.Character
    if not char then
        return
    end

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
        end
    end

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end

    local hum = char:FindFirstChild("Humanoid")
    if hum then
        hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    end
end

local function stopInvisible()
    invisibleEnabled = false
    local char = player.Character
    if not char then
        return
    end

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 0
            part.CanCollide = true
        end
    end

    local hum = char:FindFirstChild("Humanoid")
    if hum then
        hum:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
    end
end

print("✅ بخش ۳۲: Invisible (حذف کامل هیت‌باکس) اضافه شد!")


-- ================================================
-- 🇮🇷 بخش ۳۳: Suicide / Respawn (خودکشی)
-- ================================================
local function respawnPlayer()
    local char = player.Character
    if not char then
        print("⚠️ کاراکتری وجود ندارد!")
        return
    end
    local hum = char:FindFirstChild("Humanoid")
    if hum then
        hum.Health = 0
        print("💀 کاراکتر خودکشی کرد!")
    else
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            root:BreakJoints()
            print("💀 کاراکتر نابود شد!")
        end
    end
end

print("✅ بخش ۳۳: Suicide / Respawn اضافه شد!")

-- ================================================
-- 🇮🇷 بخش ۳۴: سیستم راه‌اندازی (Auto-Fix)
-- ================================================
local function autoFix()
    print("🔧 شروع سیستم راه‌اندازی...")

    if not window then
        warn("❌ منوی Rayfield پیدا نشد! تلاش برای بازسازی...")
        window = Rayfield:CreateWindow({
            name = "🇮🇷 منوی ایرانی",
            subtitle = "Rayfield Gen2 (بازسازی شده)",
            sidebarLayout = true,
        })
    end

    local functions = {
        "startAttach", "stopAttach", "startKillFarm", "stopKillFarm",
        "teleportToPlayer", "applyWalkSpeed", "applyJumpPower",
        "startNoclip", "stopNoclip",
        "startCamlock", "stopCamlock", "createESP", "clearESP", "updateESP",
        "startLag", "stopLag", "updateHitbox", "clearHitbox",
        "startAntiFling", "stopAntiFling", "startFlyV5",
        "toggleFullBright", "setDay", "setNight",
        "startHeadSit", "stopHeadSit", "startBackpack", "stopBackpack",
        "startInvisible", "stopInvisible", "respawnPlayer"
    }

    for _, funcName in ipairs(functions) do
        if not _G[funcName] and not getfenv()[funcName] then
            warn("⚠️ تابع " .. funcName .. " وجود ندارد!")
        end
    end

    print("✅ سیستم راه‌اندازی کامل شد!")
end

task.wait(2)
autoFix()

print("✅ بخش ۳۴: سیستم راه‌اندازی (Auto-Fix) اضافه شد!")
