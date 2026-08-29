--[[
    BLOX FRUITS ULTRA v3
    ====================
    - Advanced Aimbot (smooth + prediction)
    - Silent Aim (prediction + X/Y offset)
    - Speed / Jump / FOV control
    - Slide (ice glide)
    - Radar (detects players)
    - Code Redeemer
    - X / Y aim offset (max 20 each)
    Keys:
        R = Aimbot      T = Silent Aim      K = Hide/Show GUI
]]

getgenv().BFUltra = getgenv().BFUltra or {}
if getgenv().BFUltra.Loaded then
    warn("[BFUltra] Already loaded. Restart Roblox to reload.")
    return
end
getgenv().BFUltra.Loaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    Aimbot     = false,
    SilentAim  = false,
    TeamCheck  = true,
    FOV        = 180,
    LockPart   = "Head",
    Prediction = 0.12,
    Smoothness = 0.35,
    XOffset    = 0,
    YOffset    = 0,
    MaxOffset  = 20,
    Speed      = 100,
    JumpPower  = 100,
    Slide      = false,
    SlideSpeed = 150,
    Radar      = true,
    RadarRange = 350,
    FPSBoost   = false,
    AimbotKey  = Enum.KeyCode.R,
    SilentKey  = Enum.KeyCode.T,
    HideKey    = Enum.KeyCode.K,
}

-- ================= HELPERS =================
local function getChar()   return LocalPlayer.Character end

local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function applyStats()
    local hum = getHumanoid()
    if not hum then return end
    hum.WalkSpeed = Settings.Speed
    hum.JumpPower = Settings.JumpPower
end

local function IsEnemy(plr)
    if plr == LocalPlayer then return false end
    if Settings.TeamCheck and plr.Team == LocalPlayer.Team then return false end
    return true
end

local function GetPredictedPos(part)
    if not part then return nil end
    local hrp = getHRP()
    if not hrp then return part.Position end
    local vel = part.Velocity or Vector3.new()
    return part.Position + vel * Settings.Prediction
end

local function GetAimPos(part)
    local p = GetPredictedPos(part)
    if not p then return nil end
    local camCF = Camera.CFrame
    return p + camCF.RightVector * Settings.XOffset + camCF.UpVector * Settings.YOffset
end

local function getClosestEnemy()
    local hrp = getHRP()
    if not hrp then return nil end
    local best, bestDist = nil, Settings.FOV
    for _, plr in ipairs(Players:GetPlayers()) do
        if not IsEnemy(plr) then continue end
        local c = plr.Character
        if not c then continue end
        local part = c:FindFirstChild(Settings.LockPart) or c:FindFirstChild("HumanoidRootPart")
        if not part then continue end
        local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        local dist = (Vector2.new(sp.X, sp.Y) - Camera.ViewportSize / 2).Magnitude
        if dist < bestDist then
            bestDist = dist
            best = part
        end
    end
    return best
end

-- ================= GUI =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BFUltraGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local GUI_W = 280
local GUI_H = 634

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(GUI_W, GUI_H)
Main.Position = UDim2.fromOffset(15, 150)
Main.BackgroundColor3 = Color3.fromRGB(16, 16, 26)
Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.fromRGB(255, 255, 255)
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 32)
TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 70)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "BLOX FRUITS ULTRA v3"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
Title.Parent = TitleBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.fromOffset(32, 32)
MinimizeBtn.Position = UDim2.new(1, -32, 0, 0)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 95)
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextScaled = true
MinimizeBtn.Parent = TitleBar

local function MakeSquareToggle(x, y, label)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(40, 40)
    btn.Position = UDim2.fromOffset(x, y)
    btn.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    btn.BorderSizePixel = 2
    btn.BorderColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = ""
    btn.Parent = Main

    local inner = Instance.new("Frame")
    inner.Size = UDim2.fromOffset(24, 24)
    inner.Position = UDim2.new(0.5, -12, 0.5, -12)
    inner.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    inner.BackgroundTransparency = 1
    inner.BorderSizePixel = 2
    inner.BorderColor3 = Color3.fromRGB(255, 255, 255)
    inner.Parent = btn

    local lab = Instance.new("TextLabel")
    lab.Size = UDim2.fromOffset(200, 40)
    lab.Position = UDim2.fromOffset(x + 48, y)
    lab.BackgroundTransparency = 1
    lab.Text = label .. " : OFF"
    lab.TextXAlignment = Enum.TextXAlignment.Left
    lab.TextColor3 = Color3.fromRGB(255, 255, 255)
    lab.Font = Enum.Font.GothamBold
    lab.TextScaled = true
    lab.Parent = Main

    return btn, inner, lab
end

local function SetSquare(inner, on)
    inner.BackgroundTransparency = on and 0 or 1
end

local function MakeLabel(x, y, text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.fromOffset(60, 40)
    l.Position = UDim2.fromOffset(x, y)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextColor3 = Color3.fromRGB(200, 200, 255)
    l.Font = Enum.Font.GothamBold
    l.TextScaled = true
    l.Parent = Main
    return l
end

local function MakeMinus(x, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(40, 40)
    b.Position = UDim2.fromOffset(x, y)
    b.BackgroundColor3 = Color3.fromRGB(85, 45, 45)
    b.BorderSizePixel = 2
    b.BorderColor3 = Color3.fromRGB(255, 255, 255)
    b.Text = "-"
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold
    b.TextScaled = true
    b.Parent = Main
    return b
end

local function MakePlus(x, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(40, 40)
    b.Position = UDim2.fromOffset(x, y)
    b.BackgroundColor3 = Color3.fromRGB(45, 85, 45)
    b.BorderSizePixel = 2
    b.BorderColor3 = Color3.fromRGB(255, 255, 255)
    b.Text = "+"
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold
    b.TextScaled = true
    b.Parent = Main
    return b
end

local function MakeValue(x, y, text, w)
    local v = Instance.new("TextLabel")
    v.Size = UDim2.fromOffset(w or 50, 40)
    v.Position = UDim2.fromOffset(x, y)
    v.BackgroundTransparency = 1
    v.Text = text
    v.TextColor3 = Color3.fromRGB(120, 255, 120)
    v.Font = Enum.Font.GothamBold
    v.TextScaled = true
    v.Parent = Main
    return v
end

-- ============ ROWS ============
local AimBtn, AimInner, AimLabel         = MakeSquareToggle(10, 38,  "AIM LOCK")
local SilentBtn, SilentInner, SilentLabel = MakeSquareToggle(10, 84,  "SILENT AIM")

MakeLabel(10, 130, "X OFF")
local XMinus = MakeMinus(75, 130)
local XVal   = MakeValue(120, 130, "0")
local XPlus  = MakePlus(185, 130)

MakeLabel(10, 176, "Y OFF")
local YMinus = MakeMinus(75, 176)
local YVal   = MakeValue(120, 176, "0")
local YPlus  = MakePlus(185, 176)

MakeLabel(10, 222, "SPEED")
local SpeedMinus = MakeMinus(75, 222)
local SpeedVal   = MakeValue(120, 222, tostring(Settings.Speed))
local SpeedPlus  = MakePlus(185, 222)

MakeLabel(10, 268, "JUMP")
local JumpMinus = MakeMinus(75, 268)
local JumpVal   = MakeValue(120, 268, tostring(Settings.JumpPower))
local JumpPlus  = MakePlus(185, 268)

MakeLabel(10, 314, "FOV")
local FOVMinus = MakeMinus(75, 314)
local FOVVal   = MakeValue(120, 314, tostring(Settings.FOV))
local FOVPlus  = MakePlus(185, 314)

local PartBtn, PartInner, PartLabel = MakeSquareToggle(10, 360, "LOCK PART")
PartLabel.Text = "LOCK PART : HEAD"

local SlideBtn, SlideInner, SlideLabel = MakeSquareToggle(10, 406, "SLIDE")

local RadarBtn, RadarInner, RadarLabel = MakeSquareToggle(10, 452, "RADAR")
SetSquare(RadarInner, true)
RadarLabel.Text = "RADAR : ON"

local FPSBtn, FPSInner, FPSLabel = MakeSquareToggle(10, 498, "FPS BOOST")

-- ============ CODES ============
local defaultCodes = {
    "SUBSCRIBED", "ENZOS", "TYPHOON", "KITT", "DRAGONABUSE",
    "ADMIN", "3BVISITS", "UPD24", "STRAWMEN", "fudd10_v2"
}

local CodeBox = Instance.new("TextBox")
CodeBox.Size = UDim2.fromOffset(140, 30)
CodeBox.Position = UDim2.fromOffset(10, 544)
CodeBox.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
CodeBox.BorderSizePixel = 2
CodeBox.BorderColor3 = Color3.fromRGB(255, 255, 255)
CodeBox.Text = table.concat(defaultCodes, ", ")
CodeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
CodeBox.Font = Enum.Font.Code
CodeBox.TextSize = 12
CodeBox.Parent = Main

local RedeemBtn = Instance.new("TextButton")
RedeemBtn.Size = UDim2.fromOffset(110, 30)
RedeemBtn.Position = UDim2.fromOffset(158, 544)
RedeemBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 160)
RedeemBtn.BorderSizePixel = 2
RedeemBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
RedeemBtn.Text = "REDEEM"
RedeemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RedeemBtn.Font = Enum.Font.GothamBold
RedeemBtn.TextScaled = true
RedeemBtn.Parent = Main

local CodeStatus = Instance.new("TextLabel")
CodeStatus.Size = UDim2.new(1, -20, 0, 18)
CodeStatus.Position = UDim2.fromOffset(10, 578)
CodeStatus.BackgroundTransparency = 1
CodeStatus.Text = "Paste codes (comma separated) then REDEEM."
CodeStatus.TextColor3 = Color3.fromRGB(255, 200, 120)
CodeStatus.Font = Enum.Font.Gotham
CodeStatus.TextScaled = true
CodeStatus.Parent = Main

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(1, -20, 0, 30)
CloseBtn.Position = UDim2.fromOffset(10, 598)
CloseBtn.BackgroundColor3 = Color3.fromRGB(85, 40, 40)
CloseBtn.BorderSizePixel = 2
CloseBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Text = "HIDE GUI  [K]"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextScaled = true
CloseBtn.Parent = Main

-- ============ MARKER ============
local Marker = Instance.new("Frame")
Marker.Size = UDim2.fromOffset(14, 14)
Marker.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Marker.BackgroundTransparency = 0
Marker.BorderSizePixel = 2
Marker.BorderColor3 = Color3.fromRGB(0, 0, 0)
Marker.Visible = false
Marker.ZIndex = 10
Marker.Parent = ScreenGui

-- ============ FOV CIRCLE ============
local FOVCircle = nil
pcall(function()
    local d = Drawing.new("Circle")
    d.Thickness = 1
    d.Color = Color3.fromRGB(255, 60, 60)
    d.Transparency = 1
    d.NumSides = 64
    d.Visible = false
    FOVCircle = d
end)

-- ============ RADAR ============
local RadarFrame = Instance.new("Frame")
RadarFrame.Size = UDim2.fromOffset(170, 170)
RadarFrame.Position = UDim2.new(1, -185, 1, -195)
RadarFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
RadarFrame.BackgroundTransparency = 0.3
RadarFrame.BorderSizePixel = 2
RadarFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
RadarFrame.Parent = ScreenGui

local RadarTitle = Instance.new("TextLabel")
RadarTitle.Size = UDim2.new(1, 0, 0, 20)
RadarTitle.BackgroundTransparency = 1
RadarTitle.Text = "RADAR"
RadarTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
RadarTitle.Font = Enum.Font.GothamBold
RadarTitle.TextScaled = true
RadarTitle.Parent = RadarFrame

local MeDot = Instance.new("Frame")
MeDot.Size = UDim2.fromOffset(6, 6)
MeDot.Position = UDim2.new(0.5, -3, 0.5, -3)
MeDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MeDot.BorderSizePixel = 0
MeDot.Parent = RadarFrame

local RadarDots = {}

local function UpdateRadar()
    local hrp = getHRP()
    if not hrp then return end
    local myPos = hrp.Position
    local look = hrp.CFrame.LookVector
    local angle = math.atan2(-look.X, -look.Z)
    local cx = RadarFrame.AbsoluteSize.X / 2
    local cz = RadarFrame.AbsoluteSize.Y / 2
    local scale = (cx - 10) / Settings.RadarRange

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local c = plr.Character
        local tHRP = c and c:FindFirstChild("HumanoidRootPart")
        local dot = RadarDots[plr]

        if not tHRP then
            if dot then dot.Visible = false end
            continue
        end

        if not dot then
            dot = Instance.new("Frame")
            dot.Size = UDim2.fromOffset(8, 8)
            dot.BackgroundColor3 = (plr.Team == LocalPlayer.Team) and Color3.fromRGB(80, 200, 255) or Color3.fromRGB(255, 80, 80)
            dot.BorderSizePixel = 0
            dot.ZIndex = 5
            dot.Parent = RadarFrame
            RadarDots[plr] = dot
        end

        local rel = tHRP.Position - myPos
        local dist = rel.Magnitude
        if dist <= Settings.RadarRange then
            local rx = rel.X * math.cos(angle) - rel.Z * math.sin(angle)
            local rz = rel.X * math.sin(angle) + rel.Z * math.cos(angle)
            dot.Visible = true
            dot.Position = UDim2.fromOffset(cx + rx * scale - 4, cz + rz * scale - 4)
        else
            dot.Visible = false
        end
    end
end

Players.PlayerRemoving:Connect(function(plr)
    local dot = RadarDots[plr]
    if dot then
        dot:Destroy()
        RadarDots[plr] = nil
    end
end)

-- ============ TOGGLES ============
local function ToggleAimbot()
    Settings.Aimbot = not Settings.Aimbot
    SetSquare(AimInner, Settings.Aimbot)
    AimLabel.Text = "AIM LOCK : " .. (Settings.Aimbot and "ON" or "OFF")
    local hum = getHumanoid()
    if hum then hum.AutoRotate = not Settings.Aimbot end
end

local function ToggleSilent()
    Settings.SilentAim = not Settings.SilentAim
    SetSquare(SilentInner, Settings.SilentAim)
    SilentLabel.Text = "SILENT AIM : " .. (Settings.SilentAim and "ON" or "OFF")
end

local function ToggleSlide()
    Settings.Slide = not Settings.Slide
    SetSquare(SlideInner, Settings.Slide)
    SlideLabel.Text = "SLIDE : " .. (Settings.Slide and "ON" or "OFF")
    if not Settings.Slide then
        if SlideVel then SlideVel:Destroy() end
        SlideVel = nil
    end
end

local function ToggleRadar()
    Settings.Radar = not Settings.Radar
    SetSquare(RadarInner, Settings.Radar)
    RadarLabel.Text = "RADAR : " .. (Settings.Radar and "ON" or "OFF")
end

local function TogglePart()
    Settings.LockPart = Settings.LockPart == "Head" and "HumanoidRootPart" or "Head"
    PartLabel.Text = "LOCK PART : " .. Settings.LockPart
    SetSquare(PartInner, Settings.LockPart == "HumanoidRootPart")
end

local savedGFX = { QualityLevel = nil, Shadows = nil }
local function ToggleFPS()
    Settings.FPSBoost = not Settings.FPSBoost
    SetSquare(FPSInner, Settings.FPSBoost)
    FPSLabel.Text = "FPS BOOST : " .. (Settings.FPSBoost and "ON" or "OFF")
    pcall(function()
        if Settings.FPSBoost then
            if savedGFX.QualityLevel == nil then
                savedGFX.QualityLevel = settings().Rendering.QualityLevel
                savedGFX.Shadows = Lighting.GlobalShadows
            end
            settings().Rendering.QualityLevel = 1
            Lighting.GlobalShadows = false
        else
            if savedGFX.QualityLevel then
                settings().Rendering.QualityLevel = savedGFX.QualityLevel
                Lighting.GlobalShadows = savedGFX.Shadows
                savedGFX.QualityLevel = nil
            end
        end
    end)
end

AimBtn.MouseButton1Click:Connect(ToggleAimbot)
SilentBtn.MouseButton1Click:Connect(ToggleSilent)
SlideBtn.MouseButton1Click:Connect(ToggleSlide)
RadarBtn.MouseButton1Click:Connect(ToggleRadar)
PartBtn.MouseButton1Click:Connect(TogglePart)
FPSBtn.MouseButton1Click:Connect(ToggleFPS)

local function BindValueRow(minusBtn, plusBtn, valueLabel, varName, step, minV, maxV)
    minusBtn.MouseButton1Click:Connect(function()
        Settings[varName] = math.max(minV, Settings[varName] - step)
        valueLabel.Text = tostring(Settings[varName])
        applyStats()
    end)
    plusBtn.MouseButton1Click:Connect(function()
        Settings[varName] = math.min(maxV, Settings[varName] + step)
        valueLabel.Text = tostring(Settings[varName])
        applyStats()
    end)
end

BindValueRow(XMinus, XPlus, XVal, "XOffset", 1, -Settings.MaxOffset, Settings.MaxOffset)
BindValueRow(YMinus, YPlus, YVal, "YOffset", 1, -Settings.MaxOffset, Settings.MaxOffset)
BindValueRow(SpeedMinus, SpeedPlus, SpeedVal, "Speed", 10, 0, 500)
BindValueRow(JumpMinus, JumpPlus, JumpVal, "JumpPower", 10, 0, 500)
BindValueRow(FOVMinus, FOVPlus, FOVVal, "FOV", 10, 20, 360)

local Minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    local h = Minimized and 32 or GUI_H
    Main.Size = UDim2.fromOffset(GUI_W, h)
    for _, child in ipairs(Main:GetChildren()) do
        if child ~= TitleBar then
            child.Visible = not Minimized
        end
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
end)

RedeemBtn.MouseButton1Click:Connect(function()
    local list = {}
    for code in CodeBox.Text:gmatch("[^,%s]+") do
        table.insert(list, code)
    end
    if #list == 0 then
        for _, c in ipairs(defaultCodes) do table.insert(list, c) end
    end
    CodeStatus.Text = "[+] Redeeming " .. #list .. " codes..."
    task.spawn(function()
        for _, code in ipairs(list) do
            pcall(function()
                local Remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                if Remotes then
                    local submit = Remotes:FindFirstChild("CodeSubmit") or Remotes:FindFirstChild("Code")
                    if submit then submit:FireServer(code) end
                end
            end)
            task.wait(0.4)
        end
        CodeStatus.Text = "[OK] Finished. Check chat for results."
    end)
end)

local SlideVel = nil

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    if input.KeyCode == Settings.AimbotKey then
        ToggleAimbot()
    elseif input.KeyCode == Settings.SilentKey then
        ToggleSilent()
    elseif input.KeyCode == Settings.HideKey then
        Main.Visible = not Main.Visible
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 and Settings.SilentAim then
        local target = getClosestEnemy()
        local hrp = getHRP()
        if target and hrp then
            local saved = hrp.CFrame
            hrp.CFrame = CFrame.lookAt(hrp.Position, GetAimPos(target))
            task.wait(0.06)
            TweenService:Create(hrp, TweenInfo.new(0.1), { CFrame = saved }):Play()
        end
    end
end)

RunService.RenderStepped:Connect(function()
    applyStats()
    local hrp = getHRP()

    if Settings.Aimbot then
        local target = getClosestEnemy()
        if target and hrp then
            local aimPos = GetAimPos(target)
            hrp.CFrame = hrp.CFrame:Lerp(CFrame.lookAt(hrp.Position, aimPos), Settings.Smoothness)
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, aimPos), 0.35)
        end
    end

    if Settings.Slide and hrp then
        if not SlideVel or not SlideVel.Parent then
            SlideVel = Instance.new("BodyVelocity")
            SlideVel.MaxForce = Vector3.new(100000, 0, 100000)
            SlideVel.Parent = hrp
        end
        local hum = getHumanoid()
        local md = hum and hum.MoveDirection or Vector3.new()
        if md.Magnitude > 0.1 then
            SlideVel.Velocity = md * Settings.SlideSpeed
        else
            SlideVel.Velocity = Vector3.new(SlideVel.Velocity.X * 0.92, 0, SlideVel.Velocity.Z * 0.92)
        end
    elseif SlideVel then
        SlideVel:Destroy()
        SlideVel = nil
    end

    if Settings.SilentAim then
        local target = getClosestEnemy()
        if target then
            local sp, onScreen = Camera:WorldToViewportPoint(GetAimPos(target))
            if onScreen and sp.Z > 0 then
                Marker.Visible = true
                Marker.Position = UDim2.fromOffset(sp.X - 7, sp.Y - 7)
            else
                Marker.Visible = false
            end
        else
            Marker.Visible = false
        end
    else
        Marker.Visible = false
    end

    if FOVCircle then
        FOVCircle.Position = Camera.ViewportSize / 2
        FOVCircle.Radius = Settings.FOV
        FOVCircle.Visible = Settings.Aimbot or Settings.SilentAim
    end

    if Settings.Radar then
        RadarFrame.Visible = true
        UpdateRadar()
    else
        RadarFrame.Visible = false
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    applyStats()
end)

print("[BFUltra v3] Loaded. R = Aimbot | T = Silent Aim | K = Hide/Show GUI")--[[
    BLOX FRUITS ULTRA v3
    ====================
    - Advanced Aimbot (smooth + prediction)
    - Silent Aim (prediction + X/Y offset)
    - Speed / Jump / FOV control
    - Slide (ice glide)
    - Radar (detects players)
    - Code Redeemer
    - X / Y aim offset (max 20 each)
    Keys:
        R = Aimbot      T = Silent Aim      K = Hide/Show GUI
]]

getgenv().BFUltra = getgenv().BFUltra or {}
if getgenv().BFUltra.Loaded then
    warn("[BFUltra] Already loaded. Restart Roblox to reload.")
    return
end
getgenv().BFUltra.Loaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    Aimbot     = false,
    SilentAim  = false,
    TeamCheck  = true,
    FOV        = 180,
    LockPart   = "Head",
    Prediction = 0.12,
    Smoothness = 0.35,
    XOffset    = 0,
    YOffset    = 0,
    MaxOffset  = 20,
    Speed      = 100,
    JumpPower  = 100,
    Slide      = false,
    SlideSpeed = 150,
    Radar      = true,
    RadarRange = 350,
    FPSBoost   = false,
    AimbotKey  = Enum.KeyCode.R,
    SilentKey  = Enum.KeyCode.T,
    HideKey    = Enum.KeyCode.K,
}

-- ================= HELPERS =================
local function getChar()   return LocalPlayer.Character end

local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function applyStats()
    local hum = getHumanoid()
    if not hum then return end
    hum.WalkSpeed = Settings.Speed
    hum.JumpPower = Settings.JumpPower
end

local function IsEnemy(plr)
    if plr == LocalPlayer then return false end
    if Settings.TeamCheck and plr.Team == LocalPlayer.Team then return false end
    return true
end

local function GetPredictedPos(part)
    if not part then return nil end
    local hrp = getHRP()
    if not hrp then return part.Position end
    local vel = part.Velocity or Vector3.new()
    return part.Position + vel * Settings.Prediction
end

local function GetAimPos(part)
    local p = GetPredictedPos(part)
    if not p then return nil end
    local camCF = Camera.CFrame
    return p + camCF.RightVector * Settings.XOffset + camCF.UpVector * Settings.YOffset
end

local function getClosestEnemy()
    local hrp = getHRP()
    if not hrp then return nil end
    local best, bestDist = nil, Settings.FOV
    for _, plr in ipairs(Players:GetPlayers()) do
        if not IsEnemy(plr) then continue end
        local c = plr.Character
        if not c then continue end
        local part = c:FindFirstChild(Settings.LockPart) or c:FindFirstChild("HumanoidRootPart")
        if not part then continue end
        local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        local dist = (Vector2.new(sp.X, sp.Y) - Camera.ViewportSize / 2).Magnitude
        if dist < bestDist then
            bestDist = dist
            best = part
        end
    end
    return best
end

-- ================= GUI =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BFUltraGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local GUI_W = 280
local GUI_H = 634

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(GUI_W, GUI_H)
Main.Position = UDim2.fromOffset(15, 150)
Main.BackgroundColor3 = Color3.fromRGB(16, 16, 26)
Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.fromRGB(255, 255, 255)
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 32)
TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 70)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "BLOX FRUITS ULTRA v3"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
Title.Parent = TitleBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.fromOffset(32, 32)
MinimizeBtn.Position = UDim2.new(1, -32, 0, 0)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 95)
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextScaled = true
MinimizeBtn.Parent = TitleBar

local function MakeSquareToggle(x, y, label)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(40, 40)
    btn.Position = UDim2.fromOffset(x, y)
    btn.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    btn.BorderSizePixel = 2
    btn.BorderColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = ""
    btn.Parent = Main

    local inner = Instance.new("Frame")
    inner.Size = UDim2.fromOffset(24, 24)
    inner.Position = UDim2.new(0.5, -12, 0.5, -12)
    inner.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    inner.BackgroundTransparency = 1
    inner.BorderSizePixel = 2
    inner.BorderColor3 = Color3.fromRGB(255, 255, 255)
    inner.Parent = btn

    local lab = Instance.new("TextLabel")
    lab.Size = UDim2.fromOffset(200, 40)
    lab.Position = UDim2.fromOffset(x + 48, y)
    lab.BackgroundTransparency = 1
    lab.Text = label .. " : OFF"
    lab.TextXAlignment = Enum.TextXAlignment.Left
    lab.TextColor3 = Color3.fromRGB(255, 255, 255)
    lab.Font = Enum.Font.GothamBold
    lab.TextScaled = true
    lab.Parent = Main

    return btn, inner, lab
end

local function SetSquare(inner, on)
    inner.BackgroundTransparency = on and 0 or 1
end

local function MakeLabel(x, y, text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.fromOffset(60, 40)
    l.Position = UDim2.fromOffset(x, y)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextColor3 = Color3.fromRGB(200, 200, 255)
    l.Font = Enum.Font.GothamBold
    l.TextScaled = true
    l.Parent = Main
    return l
end

local function MakeMinus(x, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(40, 40)
    b.Position = UDim2.fromOffset(x, y)
    b.BackgroundColor3 = Color3.fromRGB(85, 45, 45)
    b.BorderSizePixel = 2
    b.BorderColor3 = Color3.fromRGB(255, 255, 255)
    b.Text = "-"
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold
    b.TextScaled = true
    b.Parent = Main
    return b
end

local function MakePlus(x, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(40, 40)
    b.Position = UDim2.fromOffset(x, y)
    b.BackgroundColor3 = Color3.fromRGB(45, 85, 45)
    b.BorderSizePixel = 2
    b.BorderColor3 = Color3.fromRGB(255, 255, 255)
    b.Text = "+"
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold
    b.TextScaled = true
    b.Parent = Main
    return b
end

local function MakeValue(x, y, text, w)
    local v = Instance.new("TextLabel")
    v.Size = UDim2.fromOffset(w or 50, 40)
    v.Position = UDim2.fromOffset(x, y)
    v.BackgroundTransparency = 1
    v.Text = text
    v.TextColor3 = Color3.fromRGB(120, 255, 120)
    v.Font = Enum.Font.GothamBold
    v.TextScaled = true
    v.Parent = Main
    return v
end

-- ============ ROWS ============
local AimBtn, AimInner, AimLabel         = MakeSquareToggle(10, 38,  "AIM LOCK")
local SilentBtn, SilentInner, SilentLabel = MakeSquareToggle(10, 84,  "SILENT AIM")

MakeLabel(10, 130, "X OFF")
local XMinus = MakeMinus(75, 130)
local XVal   = MakeValue(120, 130, "0")
local XPlus  = MakePlus(185, 130)

MakeLabel(10, 176, "Y OFF")
local YMinus = MakeMinus(75, 176)
local YVal   = MakeValue(120, 176, "0")
local YPlus  = MakePlus(185, 176)

MakeLabel(10, 222, "SPEED")
local SpeedMinus = MakeMinus(75, 222)
local SpeedVal   = MakeValue(120, 222, tostring(Settings.Speed))
local SpeedPlus  = MakePlus(185, 222)

MakeLabel(10, 268, "JUMP")
local JumpMinus = MakeMinus(75, 268)
local JumpVal   = MakeValue(120, 268, tostring(Settings.JumpPower))
local JumpPlus  = MakePlus(185, 268)

MakeLabel(10, 314, "FOV")
local FOVMinus = MakeMinus(75, 314)
local FOVVal   = MakeValue(120, 314, tostring(Settings.FOV))
local FOVPlus  = MakePlus(185, 314)

local PartBtn, PartInner, PartLabel = MakeSquareToggle(10, 360, "LOCK PART")
PartLabel.Text = "LOCK PART : HEAD"

local SlideBtn, SlideInner, SlideLabel = MakeSquareToggle(10, 406, "SLIDE")

local RadarBtn, RadarInner, RadarLabel = MakeSquareToggle(10, 452, "RADAR")
SetSquare(RadarInner, true)
RadarLabel.Text = "RADAR : ON"

local FPSBtn, FPSInner, FPSLabel = MakeSquareToggle(10, 498, "FPS BOOST")

-- ============ CODES ============
local defaultCodes = {
    "SUBSCRIBED", "ENZOS", "TYPHOON", "KITT", "DRAGONABUSE",
    "ADMIN", "3BVISITS", "UPD24", "STRAWMEN", "fudd10_v2"
}

local CodeBox = Instance.new("TextBox")
CodeBox.Size = UDim2.fromOffset(140, 30)
CodeBox.Position = UDim2.fromOffset(10, 544)
CodeBox.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
CodeBox.BorderSizePixel = 2
CodeBox.BorderColor3 = Color3.fromRGB(255, 255, 255)
CodeBox.Text = table.concat(defaultCodes, ", ")
CodeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
CodeBox.Font = Enum.Font.Code
CodeBox.TextSize = 12
CodeBox.Parent = Main

local RedeemBtn = Instance.new("TextButton")
RedeemBtn.Size = UDim2.fromOffset(110, 30)
RedeemBtn.Position = UDim2.fromOffset(158, 544)
RedeemBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 160)
RedeemBtn.BorderSizePixel = 2
RedeemBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
RedeemBtn.Text = "REDEEM"
RedeemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RedeemBtn.Font = Enum.Font.GothamBold
RedeemBtn.TextScaled = true
RedeemBtn.Parent = Main

local CodeStatus = Instance.new("TextLabel")
CodeStatus.Size = UDim2.new(1, -20, 0, 18)
CodeStatus.Position = UDim2.fromOffset(10, 578)
CodeStatus.BackgroundTransparency = 1
CodeStatus.Text = "Paste codes (comma separated) then REDEEM."
CodeStatus.TextColor3 = Color3.fromRGB(255, 200, 120)
CodeStatus.Font = Enum.Font.Gotham
CodeStatus.TextScaled = true
CodeStatus.Parent = Main

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(1, -20, 0, 30)
CloseBtn.Position = UDim2.fromOffset(10, 598)
CloseBtn.BackgroundColor3 = Color3.fromRGB(85, 40, 40)
CloseBtn.BorderSizePixel = 2
CloseBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Text = "HIDE GUI  [K]"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextScaled = true
CloseBtn.Parent = Main

-- ============ MARKER ============
local Marker = Instance.new("Frame")
Marker.Size = UDim2.fromOffset(14, 14)
Marker.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Marker.BackgroundTransparency = 0
Marker.BorderSizePixel = 2
Marker.BorderColor3 = Color3.fromRGB(0, 0, 0)
Marker.Visible = false
Marker.ZIndex = 10
Marker.Parent = ScreenGui

-- ============ FOV CIRCLE ============
local FOVCircle = nil
pcall(function()
    local d = Drawing.new("Circle")
    d.Thickness = 1
    d.Color = Color3.fromRGB(255, 60, 60)
    d.Transparency = 1
    d.NumSides = 64
    d.Visible = false
    FOVCircle = d
end)

-- ============ RADAR ============
local RadarFrame = Instance.new("Frame")
RadarFrame.Size = UDim2.fromOffset(170, 170)
RadarFrame.Position = UDim2.new(1, -185, 1, -195)
RadarFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
RadarFrame.BackgroundTransparency = 0.3
RadarFrame.BorderSizePixel = 2
RadarFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
RadarFrame.Parent = ScreenGui

local RadarTitle = Instance.new("TextLabel")
RadarTitle.Size = UDim2.new(1, 0, 0, 20)
RadarTitle.BackgroundTransparency = 1
RadarTitle.Text = "RADAR"
RadarTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
RadarTitle.Font = Enum.Font.GothamBold
RadarTitle.TextScaled = true
RadarTitle.Parent = RadarFrame

local MeDot = Instance.new("Frame")
MeDot.Size = UDim2.fromOffset(6, 6)
MeDot.Position = UDim2.new(0.5, -3, 0.5, -3)
MeDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MeDot.BorderSizePixel = 0
MeDot.Parent = RadarFrame

local RadarDots = {}

local function UpdateRadar()
    local hrp = getHRP()
    if not hrp then return end
    local myPos = hrp.Position
    local look = hrp.CFrame.LookVector
    local angle = math.atan2(-look.X, -look.Z)
    local cx = RadarFrame.AbsoluteSize.X / 2
    local cz = RadarFrame.AbsoluteSize.Y / 2
    local scale = (cx - 10) / Settings.RadarRange

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local c = plr.Character
        local tHRP = c and c:FindFirstChild("HumanoidRootPart")
        local dot = RadarDots[plr]

        if not tHRP then
            if dot then dot.Visible = false end
            continue
        end

        if not dot then
            dot = Instance.new("Frame")
            dot.Size = UDim2.fromOffset(8, 8)
            dot.BackgroundColor3 = (plr.Team == LocalPlayer.Team) and Color3.fromRGB(80, 200, 255) or Color3.fromRGB(255, 80, 80)
            dot.BorderSizePixel = 0
            dot.ZIndex = 5
            dot.Parent = RadarFrame
            RadarDots[plr] = dot
        end

        local rel = tHRP.Position - myPos
        local dist = rel.Magnitude
        if dist <= Settings.RadarRange then
            local rx = rel.X * math.cos(angle) - rel.Z * math.sin(angle)
            local rz = rel.X * math.sin(angle) + rel.Z * math.cos(angle)
            dot.Visible = true
            dot.Position = UDim2.fromOffset(cx + rx * scale - 4, cz + rz * scale - 4)
        else
            dot.Visible = false
        end
    end
end

Players.PlayerRemoving:Connect(function(plr)
    local dot = RadarDots[plr]
    if dot then
        dot:Destroy()
        RadarDots[plr] = nil
    end
end)

-- ============ TOGGLES ============
local function ToggleAimbot()
    Settings.Aimbot = not Settings.Aimbot
    SetSquare(AimInner, Settings.Aimbot)
    AimLabel.Text = "AIM LOCK : " .. (Settings.Aimbot and "ON" or "OFF")
    local hum = getHumanoid()
    if hum then hum.AutoRotate = not Settings.Aimbot end
end

local function ToggleSilent()
    Settings.SilentAim = not Settings.SilentAim
    SetSquare(SilentInner, Settings.SilentAim)
    SilentLabel.Text = "SILENT AIM : " .. (Settings.SilentAim and "ON" or "OFF")
end

local function ToggleSlide()
    Settings.Slide = not Settings.Slide
    SetSquare(SlideInner, Settings.Slide)
    SlideLabel.Text = "SLIDE : " .. (Settings.Slide and "ON" or "OFF")
    if not Settings.Slide then
        if SlideVel then SlideVel:Destroy() end
        SlideVel = nil
    end
end

local function ToggleRadar()
    Settings.Radar = not Settings.Radar
    SetSquare(RadarInner, Settings.Radar)
    RadarLabel.Text = "RADAR : " .. (Settings.Radar and "ON" or "OFF")
end

local function TogglePart()
    Settings.LockPart = Settings.LockPart == "Head" and "HumanoidRootPart" or "Head"
    PartLabel.Text = "LOCK PART : " .. Settings.LockPart
    SetSquare(PartInner, Settings.LockPart == "HumanoidRootPart")
end

local savedGFX = { QualityLevel = nil, Shadows = nil }
local function ToggleFPS()
    Settings.FPSBoost = not Settings.FPSBoost
    SetSquare(FPSInner, Settings.FPSBoost)
    FPSLabel.Text = "FPS BOOST : " .. (Settings.FPSBoost and "ON" or "OFF")
    pcall(function()
        if Settings.FPSBoost then
            if savedGFX.QualityLevel == nil then
                savedGFX.QualityLevel = settings().Rendering.QualityLevel
                savedGFX.Shadows = Lighting.GlobalShadows
            end
            settings().Rendering.QualityLevel = 1
            Lighting.GlobalShadows = false
        else
            if savedGFX.QualityLevel then
                settings().Rendering.QualityLevel = savedGFX.QualityLevel
                Lighting.GlobalShadows = savedGFX.Shadows
                savedGFX.QualityLevel = nil
            end
        end
    end)
end

AimBtn.MouseButton1Click:Connect(ToggleAimbot)
SilentBtn.MouseButton1Click:Connect(ToggleSilent)
SlideBtn.MouseButton1Click:Connect(ToggleSlide)
RadarBtn.MouseButton1Click:Connect(ToggleRadar)
PartBtn.MouseButton1Click:Connect(TogglePart)
FPSBtn.MouseButton1Click:Connect(ToggleFPS)

local function BindValueRow(minusBtn, plusBtn, valueLabel, varName, step, minV, maxV)
    minusBtn.MouseButton1Click:Connect(function()
        Settings[varName] = math.max(minV, Settings[varName] - step)
        valueLabel.Text = tostring(Settings[varName])
        applyStats()
    end)
    plusBtn.MouseButton1Click:Connect(function()
        Settings[varName] = math.min(maxV, Settings[varName] + step)
        valueLabel.Text = tostring(Settings[varName])
        applyStats()
    end)
end

BindValueRow(XMinus, XPlus, XVal, "XOffset", 1, -Settings.MaxOffset, Settings.MaxOffset)
BindValueRow(YMinus, YPlus, YVal, "YOffset", 1, -Settings.MaxOffset, Settings.MaxOffset)
BindValueRow(SpeedMinus, SpeedPlus, SpeedVal, "Speed", 10, 0, 500)
BindValueRow(JumpMinus, JumpPlus, JumpVal, "JumpPower", 10, 0, 500)
BindValueRow(FOVMinus, FOVPlus, FOVVal, "FOV", 10, 20, 360)

local Minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    local h = Minimized and 32 or GUI_H
    Main.Size = UDim2.fromOffset(GUI_W, h)
    for _, child in ipairs(Main:GetChildren()) do
        if child ~= TitleBar then
            child.Visible = not Minimized
        end
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
end)

RedeemBtn.MouseButton1Click:Connect(function()
    local list = {}
    for code in CodeBox.Text:gmatch("[^,%s]+") do
        table.insert(list, code)
    end
    if #list == 0 then
        for _, c in ipairs(defaultCodes) do table.insert(list, c) end
    end
    CodeStatus.Text = "[+] Redeeming " .. #list .. " codes..."
    task.spawn(function()
        for _, code in ipairs(list) do
            pcall(function()
                local Remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                if Remotes then
                    local submit = Remotes:FindFirstChild("CodeSubmit") or Remotes:FindFirstChild("Code")
                    if submit then submit:FireServer(code) end
                end
            end)
            task.wait(0.4)
        end
        CodeStatus.Text = "[OK] Finished. Check chat for results."
    end)
end)

local SlideVel = nil

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    if input.KeyCode == Settings.AimbotKey then
        ToggleAimbot()
    elseif input.KeyCode == Settings.SilentKey then
        ToggleSilent()
    elseif input.KeyCode == Settings.HideKey then
        Main.Visible = not Main.Visible
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 and Settings.SilentAim then
        local target = getClosestEnemy()
        local hrp = getHRP()
        if target and hrp then
            local saved = hrp.CFrame
            hrp.CFrame = CFrame.lookAt(hrp.Position, GetAimPos(target))
            task.wait(0.06)
            TweenService:Create(hrp, TweenInfo.new(0.1), { CFrame = saved }):Play()
        end
    end
end)

RunService.RenderStepped:Connect(function()
    applyStats()
    local hrp = getHRP()

    if Settings.Aimbot then
        local target = getClosestEnemy()
        if target and hrp then
            local aimPos = GetAimPos(target)
            hrp.CFrame = hrp.CFrame:Lerp(CFrame.lookAt(hrp.Position, aimPos), Settings.Smoothness)
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, aimPos), 0.35)
        end
    end

    if Settings.Slide and hrp then
        if not SlideVel or not SlideVel.Parent then
            SlideVel = Instance.new("BodyVelocity")
            SlideVel.MaxForce = Vector3.new(100000, 0, 100000)
            SlideVel.Parent = hrp
        end
        local hum = getHumanoid()
        local md = hum and hum.MoveDirection or Vector3.new()
        if md.Magnitude > 0.1 then
            SlideVel.Velocity = md * Settings.SlideSpeed
        else
            SlideVel.Velocity = Vector3.new(SlideVel.Velocity.X * 0.92, 0, SlideVel.Velocity.Z * 0.92)
        end
    elseif SlideVel then
        SlideVel:Destroy()
        SlideVel = nil
    end

    if Settings.SilentAim then
        local target = getClosestEnemy()
        if target then
            local sp, onScreen = Camera:WorldToViewportPoint(GetAimPos(target))
            if onScreen and sp.Z > 0 then
                Marker.Visible = true
                Marker.Position = UDim2.fromOffset(sp.X - 7, sp.Y - 7)
            else
                Marker.Visible = false
            end
        else
            Marker.Visible = false
        end
    else
        Marker.Visible = false
    end

    if FOVCircle then
        FOVCircle.Position = Camera.ViewportSize / 2
        FOVCircle.Radius = Settings.FOV
        FOVCircle.Visible = Settings.Aimbot or Settings.SilentAim
    end

    if Settings.Radar then
        RadarFrame.Visible = true
        UpdateRadar()
    else
        RadarFrame.Visible = false
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    applyStats()
end)

print("[BFUltra v3] Loaded. R = Aimbot | T = Silent Aim | K = Hide/Show GUI")vv
