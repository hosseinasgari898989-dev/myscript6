-- ================================================
-- 🇮🇷 منوی ایرانی نهایی (نسخه کامل و بدون نقص)
-- ================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ================================================
-- متغیرهای وضعیت (فقط موارد استفاده‌شده)
-- ================================================
local selectedPlayer = nil
local isBackAttach = false
local isFrontAttach = false
local isKillFarm = false
local isNoclip = false
local wallWalkEnabled = false
local isCamlock = false
local camTarget = nil
local espEnabled = false
local espHighlights = {}
local espTargetPlayer = nil
local lagEnabled = false
local lagConnection = nil
local hitboxEnabled = false
local hitboxParts = {}
local antiFlingEnabled = false
local invisibleEnabled = false
local fullBrightEnabled = false
local headSitEnabled = false
local headSitConnection = nil
local backpackEnabled = false
local backpackConnection = nil
local infiniteJumpEnabled = false

local backDistance = 5
local frontDistance = 5
local walkSpeedValue = 16
local jumpPowerValue = 50

local attachConnection = nil
local killFarmConnection = nil
local noclipConnection = nil
local wallWalkConnection = nil
local originalBrightness = Lighting.Brightness
local originalAmbient = Lighting.Ambient

-- ================================================
-- توابع اصلی
-- ================================================

-- چسبیدن به پشت/جلو
local function startAttach()
    if attachConnection then attachConnection:Disconnect() end
    attachConnection = RunService.Heartbeat:Connect(function()
        if not selectedPlayer or not selectedPlayer.Character then return end
        local char = player.Character if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local targetRoot = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root or not targetRoot then return end
        local dist = isBackAttach and backDistance or frontDistance
        local dir = isBackAttach and -1 or 1
        root.CFrame = CFrame.new(targetRoot.Position + targetRoot.CFrame.LookVector * dir * dist)
    end)
end

local function stopAttach()
    if attachConnection then attachConnection:Disconnect(); attachConnection = nil end
end

-- Kill Farm
local function startKillFarm()
    if killFarmConnection then killFarmConnection:Disconnect() end
    local angle = 0
    killFarmConnection = RunService.Heartbeat:Connect(function()
        if not isKillFarm then return end
        if not selectedPlayer or not selectedPlayer.Character then return end
        local char = player.Character if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local targetRoot = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root or not targetRoot then return end
        angle = angle + 0.3
        local radius = 2
        local heightOffset = math.sin(angle) * 2
        local x = math.cos(angle) * radius
        local z = math.sin(angle) * radius
        root.CFrame = CFrame.new(targetRoot.Position + Vector3.new(x, heightOffset, z))
    end)
end

local function stopKillFarm()
    if killFarmConnection then killFarmConnection:Disconnect(); killFarmConnection = nil end
end

-- رفتن پیش پلیر
local function teleportToPlayer()
    if not selectedPlayer then print("⚠️ لطفاً ابتدا یک بازیکن انتخاب کن!") return end
    local char = player.Character if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local targetRoot = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root or not targetRoot then return end
    root.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 2, 0))
    print("✅ به " .. selectedPlayer.Name .. " تله‌پورت شدی!")
end

-- Noclip
local function startNoclip()
    if noclipConnection then noclipConnection:Disconnect() end
    isNoclip = true
    noclipConnection = RunService.Stepped:Connect(function()
        if not isNoclip then stopNoclip() return end
        local character = player.Character
        if not character then return end
        for _, object in ipairs(character:GetDescendants()) do
            if object:IsA("BasePart") then
                object.CanCollide = false
            end
        end
    end)
end

local function stopNoclip()
    isNoclip = false
    if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
    local character = player.Character
    if character then
        for _, object in ipairs(character:GetDescendants()) do
            if object:IsA("BasePart") then
                object.CanCollide = true
            end
        end
    end
end

-- WalkSpeed / JumpPower
local function applyWalkSpeed()
    local char = player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = walkSpeedValue end
    end
end

local function applyJumpPower()
    local char = player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.JumpPower = jumpPowerValue end
    end
end

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        local char = player.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)

-- WallWalk (از Infinite Yield)
local function startWallWalk()
    if wallWalkConnection then wallWalkConnection:Disconnect() end
    wallWalkEnabled = true
    wallWalkConnection = RunService.Heartbeat:Connect(function()
        if not wallWalkEnabled then return end
        local char = player.Character if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart") if not root then return end
        local hum = char:FindFirstChild("Humanoid") if not hum then return end
        
        local directions = {
            root.CFrame.LookVector * 3,
            -root.CFrame.LookVector * 3,
            root.CFrame.RightVector * 3,
            -root.CFrame.RightVector * 3
        }
        
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = {char}
        
        local wallHit = nil
        for _, dir in ipairs(directions) do
            local result = workspace:Raycast(root.Position, dir, rayParams)
            if result and result.Instance then
                wallHit = result
                break
            end
        end
        
        if wallHit then
            hum.AutoRotate = false
            local normal = wallHit.Normal
            local forward = root.CFrame.LookVector
            local wallDirection = forward - normal * forward:Dot(normal)
            if wallDirection.Magnitude > 0.05 then
                wallDirection = wallDirection.Unit
                root.CFrame = CFrame.lookAt(root.Position, root.Position + wallDirection, Vector3.new(0, 1, 0))
            end
        else
            hum.AutoRotate = true
        end
    end)
end

local function stopWallWalk()
    wallWalkEnabled = false
    if wallWalkConnection then wallWalkConnection:Disconnect(); wallWalkConnection = nil end
    local char = player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.AutoRotate = true end
    end
end

-- ESP
local function createESP(target)
    if not target or not target.Character then return end
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
    if not espEnabled then return end
    if espTargetPlayer then
        createESP(espTargetPlayer)
    else
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then createESP(plr) end
        end
    end
end

Players.PlayerAdded:Connect(updateESP)
Players.PlayerRemoving:Connect(updateESP)

-- Camlock
local function startCamlock()
    if not selectedPlayer then print("⚠️ لطفاً ابتدا یک بازیکن انتخاب کن!") return end
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

-- Lag
local function startLag()
    if lagConnection then lagConnection:Disconnect() end
    lagConnection = RunService.Heartbeat:Connect(function()
        if not lagEnabled then return end
        local char = player.Character if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart") if not root then return end
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
    if lagConnection then lagConnection:Disconnect(); lagConnection = nil end
end

-- Hitbox
local function createHitbox(plr)
    if not plr or not plr.Character then return end
    local root = plr.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
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
    if not hitboxEnabled then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then createHitbox(plr) end
    end
end

Players.PlayerAdded:Connect(updateHitbox)
Players.PlayerRemoving:Connect(updateHitbox)

-- AntiFling
local function startAntiFling()
    local char = player.Character if not char then return end
    local hum = char:FindFirstChild("Humanoid") if not hum then return end
    hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    hum.PlatformStand = true
    hum:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
    hum:SetStateEnabled(Enum.HumanoidStateType.Running, true)
    hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
end

local function stopAntiFling()
    local char = player.Character if not char then return end
    local hum = char:FindFirstChild("Humanoid") if not hum then return end
    hum:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
    hum.PlatformStand = false
end

-- Invisible (کامل)
local function startInvisible()
    invisibleEnabled = true
    local char = player.Character if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
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
    local char = player.Character if not char then return end
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

-- FullBright
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

-- Night / Day
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

-- Head Sit
local function startHeadSit()
    if not selectedPlayer or not selectedPlayer.Character then
        print("⚠️ لطفاً ابتدا یک بازیکن انتخاب کن!")
        return
    end
    headSitEnabled = true
    local char = player.Character if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local head = selectedPlayer.Character:FindFirstChild("Head")
    if not root or not head then return end
    if headSitConnection then headSitConnection:Disconnect() end
    headSitConnection = RunService.Heartbeat:Connect(function()
        if not headSitEnabled or not selectedPlayer or not selectedPlayer.Character then return end
        local currentHead = selectedPlayer.Character:FindFirstChild("Head")
        if currentHead then
            root.CFrame = CFrame.new(currentHead.Position + Vector3.new(0, 2, 0))
        end
    end)
end

local function stopHeadSit()
    headSitEnabled = false
    if headSitConnection then headSitConnection:Disconnect(); headSitConnection = nil end
end

-- Backpack
local function startBackpack()
    if not selectedPlayer or not selectedPlayer.Character then
        print("⚠️ لطفاً ابتدا یک بازیکن انتخاب کن!")
        return
    end
    backpackEnabled = true
    local char = player.Character if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local targetRoot = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root or not targetRoot then return end
    if backpackConnection then backpackConnection:Disconnect() end
    backpackConnection = RunService.Heartbeat:Connect(function()
        if not backpackEnabled or not selectedPlayer or not selectedPlayer.Character then return end
        local currentTargetRoot = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if currentTargetRoot then
            root.CFrame = CFrame.new(currentTargetRoot.Position - currentTargetRoot.CFrame.LookVector * 3)
        end
    end)
end

local function stopBackpack()
    backpackEnabled = false
    if backpackConnection then backpackConnection:Disconnect(); backpackConnection = nil end
end

-- Suicide / Respawn
local function respawnPlayer()
    local char = player.Character
    if not char then print("⚠️ کاراکتری وجود ندارد!") return end
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

-- ================================================
-- دکمه Camlock جداگانه
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
    camlockButton.Parent = playerGui

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = camlockButton

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

-- ================================================
-- Fly V5 (اسکریپت کامل قدیمی)
-- ================================================
local flyV5Gui = nil
local flyV5Active = false

local function startFlyV5()
    if flyV5Active then return end
    flyV5Active = true

    local gui = Instance.new("ScreenGui")
    gui.Name = "FlyV5"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 190, 0, 57)
    frame.Position = UDim2.new(0.1, 0, 0.38, 0)
    frame.BackgroundColor3 = Color3.fromRGB(163, 255, 137)
    frame.BorderColor3 = Color3.fromRGB(103, 221, 213)
    frame.Active = true
    frame.Draggable = true
    frame.Parent = gui

    local up = Instance.new("TextButton")
    up.Size = UDim2.new(0, 44, 0, 28)
    up.Position = UDim2.new(0, 0, 0, 0)
    up.BackgroundColor3 = Color3.fromRGB(79, 255, 152)
    up.Text = "UP"
    up.TextColor3 = Color3.fromRGB(0, 0, 0)
    up.TextSize = 14
    up.Font = Enum.Font.SourceSans
    up.Parent = frame

    local down = Instance.new("TextButton")
    down.Size = UDim2.new(0, 44, 0, 28)
    down.Position = UDim2.new(0, 0, 0.491, 0)
    down.BackgroundColor3 = Color3.fromRGB(215, 255, 121)
    down.Text = "DOWN"
    down.TextColor3 = Color3.fromRGB(0, 0, 0)
    down.TextSize = 14
    down.Font = Enum.Font.SourceSans
    down.Parent = frame

    local flyBtn = Instance.new("TextButton")
    flyBtn.Size = UDim2.new(0, 56, 0, 28)
    flyBtn.Position = UDim2.new(0.703, 0, 0.491, 0)
    flyBtn.BackgroundColor3 = Color3.fromRGB(255, 249, 74)
    flyBtn.Text = "fly"
    flyBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    flyBtn.TextSize = 14
    flyBtn.Font = Enum.Font.SourceSans
    flyBtn.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 100, 0, 28)
    title.Position = UDim2.new(0.469, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(242, 60, 255)
    title.Text = "FLY GUI V5"
    title.TextColor3 = Color3.fromRGB(0, 0, 0)
    title.TextScaled = true
    title.TextWrapped = true
    title.Font = Enum.Font.SourceSans
    title.Parent = frame

    local plus = Instance.new("TextButton")
    plus.Size = UDim2.new(0, 45, 0, 28)
    plus.Position = UDim2.new(0.232, 0, 0, 0)
    plus.BackgroundColor3 = Color3.fromRGB(133, 145, 255)
    plus.Text = "+"
    plus.TextColor3 = Color3.fromRGB(0, 0, 0)
    plus.TextScaled = true
    plus.TextWrapped = true
    plus.Font = Enum.Font.SourceSans
    plus.Parent = frame

    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(0, 44, 0, 28)
    speedLabel.Position = UDim2.new(0.468, 0, 0.491, 0)
    speedLabel.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
    speedLabel.Text = "1"
    speedLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    speedLabel.TextScaled = true
    speedLabel.TextWrapped = true
    speedLabel.Font = Enum.Font.SourceSans
    speedLabel.Parent = frame

    local mine = Instance.new("TextButton")
    mine.Size = UDim2.new(0, 45, 0, 29)
    mine.Position = UDim2.new(0.232, 0, 0.491, 0)
    mine.BackgroundColor3 = Color3.fromRGB(123, 255, 247)
    mine.Text = "-"
    mine.TextColor3 = Color3.fromRGB(0, 0, 0)
    mine.TextScaled = true
    mine.TextWrapped = true
    mine.Font = Enum.Font.SourceSans
    mine.Parent = frame

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 45, 0, 28)
    close.Position = UDim2.new(0, 0, -1, 27)
    close.BackgroundColor3 = Color3.fromRGB(225, 25, 0)
    close.Text = "X"
    close.TextSize = 30
    close.Font = Enum.Font.SourceSans
    close.Parent = frame

    local mini = Instance.new("TextButton")
    mini.Size = UDim2.new(0, 45, 0, 28)
    mini.Position = UDim2.new(0, 44, -1, 27)
    mini.BackgroundColor3 = Color3.fromRGB(192, 150, 230)
    mini.Text = "-"
    mini.TextSize = 40
    mini.Font = Enum.Font.SourceSans
    mini.Parent = frame

    local mini2 = Instance.new("TextButton")
    mini2.Size = UDim2.new(0, 45, 0, 28)
    mini2.Position = UDim2.new(0, 44, -1, 57)
    mini2.BackgroundColor3 = Color3.fromRGB(192, 150, 230)
    mini2.Text = "+"
    mini2.TextSize = 40
    mini2.Visible = false
    mini2.Font = Enum.Font.SourceSans
    mini2.Parent = frame

    local speeds = 1
    local nowe = false
    local speaker = player
    local tpwalking = false

    flyBtn.MouseButton1Click:Connect(function()
        if nowe == true then
            nowe = false
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
            speaker.Character.Humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
            return
        end

        nowe = true
        for i = 1, speeds do
            spawn(function()
                local hb = RunService.Heartbeat
                tpwalking = true
                local chr = player.Character
                local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
                while tpwalking and hb:Wait() and chr and hum and hum.Parent do
                    if hum.MoveDirection.Magnitude > 0 then
                        chr:TranslateBy(hum.MoveDirection)
                    end
                end
            end)
        end

        if player.Character then
            local anim = player.Character:FindFirstChild("Animate")
            if anim then anim.Disabled = true end
        end

        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
                track:AdjustSpeed(0)
            end
        end

        speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
        speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
        speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
        speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
        speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
        speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
        speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
        speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
        speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
        speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
        speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, false)
        speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
        speaker.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)

        if player.Character and player.Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6 then
            local plr = player
            local torso = plr.Character.Torso
            local ctrl = {f = 0, b = 0, l = 0, r = 0}
            local lastctrl = {f = 0, b = 0, l = 0, r = 0}
            local maxspeed = 55
            local speed = 0
            local bg = Instance.new("BodyGyro", torso)
            bg.P = 9e4
            bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.cframe = torso.CFrame
            local bv = Instance.new("BodyVelocity", torso)
            bv.velocity = Vector3.new(0, 0.1, 0)
            bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
            if nowe == true then
                plr.Character.Humanoid.PlatformStand = true
            end
            while nowe == true or player.Character and player.Character.Humanoid.Health == 0 do
                RunService.RenderStepped:Wait()
                if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
                    speed = speed + 0.5 + (speed / maxspeed)
                    if speed > maxspeed then speed = maxspeed end
                elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
                    speed = speed - 1
                    if speed < 0 then speed = 0 end
                end
                if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
                    bv.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f + ctrl.b)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l + ctrl.r, (ctrl.f + ctrl.b) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * speed
                    lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
                elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
                    bv.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f + lastctrl.b)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l + lastctrl.r, (lastctrl.f + lastctrl.b) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * speed
                else
                    bv.velocity = Vector3.new(0, 0, 0)
                end
                bg.cframe = workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f + ctrl.b) * 50 * speed / maxspeed), 0, 0)
            end
            ctrl = {f = 0, b = 0, l = 0, r = 0}
            lastctrl = {f = 0, b = 0, l = 0, r = 0}
            speed = 0
            bg:Destroy()
            bv:Destroy()
            plr.Character.Humanoid.PlatformStand = false
            if player.Character then
                local anim = player.Character:FindFirstChild("Animate")
                if anim then anim.Disabled = false end
            end
            tpwalking = false
        else
            local plr = player
            local UpperTorso = plr.Character.UpperTorso
            local ctrl = {f = 0, b = 0, l = 0, r = 0}
            local lastctrl = {f = 0, b = 0, l = 0, r = 0}
            local maxspeed = 55
            local speed = 0
            local bg = Instance.new("BodyGyro", UpperTorso)
            bg.P = 9e4
            bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.cframe = UpperTorso.CFrame
            local bv = Instance.new("BodyVelocity", UpperTorso)
            bv.velocity = Vector3.new(0, 0.1, 0)
            bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
            if nowe == true then
                plr.Character.Humanoid.PlatformStand = true
            end
            while nowe == true or player.Character and player.Character.Humanoid.Health == 0 do
                wait()
                if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
                    speed = speed + 0.6 + (speed / maxspeed)
                    if speed > maxspeed then speed = maxspeed end
                elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
                    speed = speed - 1
                    if speed < 0 then speed = 0 end
                end
                if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
                    bv.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f + ctrl.b)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l + ctrl.r, (ctrl.f + ctrl.b) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * speed
                    lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
                elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
                    bv.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f + lastctrl.b)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l + lastctrl.r, (lastctrl.f + lastctrl.b) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * speed
                else
                    bv.velocity = Vector3.new(0, 0, 0)
                end
                bg.cframe = workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f + ctrl.b) * 50 * speed / maxspeed), 0, 0)
            end
            ctrl = {f = 0, b = 0, l = 0, r = 0}
            lastctrl = {f = 0, b = 0, l = 0, r = 0}
            speed = 0
            bg:Destroy()
            bv:Destroy()
            plr.Character.Humanoid.PlatformStand = false
            if player.Character then
                local anim = player.Character:FindFirstChild("Animate")
                if anim then anim.Disabled = false end
            end
            tpwalking = false
        end
    end)

    local tis
    up.MouseButton1Down:Connect(function()
        tis = up.MouseEnter:Connect(function()
            while tis do
                wait()
                local char = player.Character
                if char then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.CFrame = root.CFrame * CFrame.new(0, 1, 0)
                    end
                end
            end
        end)
    end)
    up.MouseLeave:Connect(function()
        if tis then
            tis:Disconnect()
            tis = nil
        end
    end)

    local dis
    down.MouseButton1Down:Connect(function()
        dis = down.MouseEnter:Connect(function()
            while dis do
                wait()
                local char = player.Character
                if char then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.CFrame = root.CFrame * CFrame.new(0, -1, 0)
                    end
                end
            end
        end)
    end)
    down.MouseLeave:Connect(function()
        if dis then
            dis:Disconnect()
            dis = nil
        end
    end)

    plus.MouseButton1Click:Connect(function()
        speeds = speeds + 1
        speedLabel.Text = speeds
        if nowe == true then
            tpwalking = false
            for i = 1, speeds do
                spawn(function()
                    local hb = RunService.Heartbeat
                    tpwalking = true
                    local chr = player.Character
                    local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
                    while tpwalking and hb:Wait() and chr and hum and hum.Parent do
                        if hum.MoveDirection.Magnitude > 0 then
                            chr:TranslateBy(hum.MoveDirection)
                        end
                    end
                end)
            end
        end
    end)

    mine.MouseButton1Click:Connect(function()
        if speeds == 1 then
            speedLabel.Text = 'cannot be less than 1'
            wait(1)
            speedLabel.Text = speeds
        else
            speeds = speeds - 1
            speedLabel.Text = speeds
            if nowe == true then
                tpwalking = false
                for i = 1, speeds do
                    spawn(function()
                        local hb = RunService.Heartbeat
                        tpwalking = true
                        local chr = player.Character
                        local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
                        while tpwalking and hb:Wait() and chr and hum and hum.Parent do
                            if hum.MoveDirection.Magnitude > 0 then
                                chr:TranslateBy(hum.MoveDirection)
                            end
                        end
                    end)
                end
            end
        end
    end)

    close.MouseButton1Click:Connect(function()
        gui:Destroy()
        flyV5Active = false
    end)

    mini.MouseButton1Click:Connect(function()
        up.Visible = false
        down.Visible = false
        flyBtn.Visible = false
        plus.Visible = false
        speedLabel.Visible = false
        mine.Visible = false
        mini.Visible = false
        mini2.Visible = true
        frame.BackgroundTransparency = 1
        close.Position = UDim2.new(0, 0, -1, 57)
    end)

    mini2.MouseButton1Click:Connect(function()
        up.Visible = true
        down.Visible = true
        flyBtn.Visible = true
        plus.Visible = true
        speedLabel.Visible = true
        mine.Visible = true
        mini.Visible = true
        mini2.Visible = false
        frame.BackgroundTransparency = 0
        close.Position = UDim2.new(0, 0, -1, 27)
    end)

    player.CharacterAdded:Connect(function()
        wait(0.7)
        if player.Character then
            player.Character.Humanoid.PlatformStand = false
            local anim = player.Character:FindFirstChild("Animate")
            if anim then anim.Disabled = false end
        end
    end)

    flyV5Gui = gui
    print("🚀 Fly V5 فعال شد!")
end

local function stopFlyV5()
    if flyV5Gui then
        flyV5Gui:Destroy()
        flyV5Gui = nil
        flyV5Active = false
        print("🚀 Fly V5 غیرفعال شد!")
    end
end

-- ================================================
-- بارگذاری Rayfield Gen2
-- ================================================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

-- ================================================
-- منوی کامل Rayfield Gen2
-- ================================================
local window = Rayfield:CreateWindow({
    name = "🇮🇷 منوی ایرانی",
    subtitle = "نسخه نهایی",
    sidebarLayout = true,
})

-- ==========================================
-- 🏠 تب خانه (Home)
-- ==========================================
local homeTab = window:CreateTab({
    name = "خانه",
    icon = "home"
})

-- لیست بازیکنان (Dropdown)
local function buildPlayerOptions()
    local options = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            table.insert(options, plr.Name)
        end
    end
    return options
end

homeTab:CreateDropdown({
    name = "👥 انتخاب بازیکن",
    options = buildPlayerOptions(),
    callback = function(option)
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Name == option then
                selectedPlayer = plr
                print("🎯 بازیکن انتخاب شد:", plr.Name)
                break
            end
        end
    end
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

-- Invisible (کامل)
homeTab:CreateToggle({
    name = "👻 Invisible (غیب شدن کامل)",
    callback = function(value)
        if value then
            startInvisible()
        else
            stopInvisible()
        end
    end
})

-- Head Sit
homeTab:CreateToggle({
    name = "🧠 Head Sit (نشستن روی سر)",
    callback = function(value)
        if value then
            startHeadSit()
        else
            stopHeadSit()
        end
    end
})

-- Backpack
homeTab:CreateToggle({
    name = "🎒 Backpack (کوله‌پشتی شدن)",
    callback = function(value)
        if value then
            startBackpack()
        else
            stopBackpack()
        end
    end
})

-- Suicide / Respawn
homeTab:CreateButton({
    name = "💀 Respawn (خودکشی)",
    callback = function()
        respawnPlayer()
    end
})

-- ==========================================
-- 🏃 تب حرکت (Movement)
-- ==========================================
local moveTab = window:CreateTab({
    name = "حرکت",
    icon = "activity"
})

-- Fly V5 (اسکریپت کامل)
moveTab:CreateToggle({
    name = "✈️ Fly V5",
    callback = function(value)
        if value then
            startFlyV5()
        else
            stopFlyV5()
        end
    end
})

-- Noclip
moveTab:CreateToggle({
    name = "🌀 Noclip (عبور از دیوار)",
    callback = function(value)
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
    name = "🛡️ AntiFling (حذف فیزیک پلیرها)",
    callback = function(value)
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

-- FullBright
utilTab:CreateToggle({
    name = "☀️ FullBright (روشن‌تر)",
    callback = function(value)
        toggleFullBright(value)
    end
})

-- Night / Day
utilTab:CreateButton({
    name = "🌙 Night (شب)",
    callback = function()
        setNight()
    end
})

utilTab:CreateButton({
    name = "☀️ Day (روز)",
    callback = function()
        setDay()
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
infoTab:CreateLabel("💻 تلگرام: @fromiran_love", "message-circle")
infoTab:CreateLabel("📱 روبیکا: @H033_EIN_0", "message-circle")

-- دکمه Reset
infoTab:CreateButton({
    name = "🔄 Reset (راه‌اندازی مجدد منو)",
    callback = function()
        window:Destroy()
        window = Rayfield:CreateWindow({
            name = "🇮🇷 منوی ایرانی",
            subtitle = "نسخه نهایی (ریست شده)",
            sidebarLayout = true,
        })
        print("✅ منو با موفقیت ریست شد!")
    end
})

-- ==========================================
-- 🚀 پیام خوش‌آمدگویی
-- ==========================================
print("=========================================")
print("🇮🇷 منوی ایرانی نسخه نهایی بارگذاری شد!")
print("💻 سازنده: @fromiran_love")
print("✅ همه قابلیت‌ها فعال و آماده استفاده")
print("=========================================")

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "🇮🇷 منوی ایرانی",
    Text = "نسخه نهایی با موفقیت اجرا شد!",
    Duration = 3,
})