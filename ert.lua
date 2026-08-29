--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.9) ~  Much Love, Ferib 

]]--

bit32 = {};
local N = 32;
local P = 2 ^ N;
bit32.bnot = function(x)
	x = x % P;
	return (P - 1) - x;
end;
bit32.band = function(x, y)
	if (y == 255) then
		return x % 256;
	end
	if (y == 65535) then
		return x % 65536;
	end
	if (y == 4294967295) then
		return x % 4294967296;
	end
	x, y = x % P, y % P;
	local r = 0;
	local p = 1;
	for i = 1, N do
		local a, b = x % 2, y % 2;
		x, y = math.floor(x / 2), math.floor(y / 2);
		if ((a + b) == 2) then
			r = r + p;
		end
		p = 2 * p;
	end
	return r;
end;
bit32.bor = function(x, y)
	if (y == 255) then
		return (x - (x % 256)) + 255;
	end
	if (y == 65535) then
		return (x - (x % 65536)) + 65535;
	end
	if (y == 4294967295) then
		return 4294967295;
	end
	x, y = x % P, y % P;
	local r = 0;
	local p = 1;
	for i = 1, N do
		local a, b = x % 2, y % 2;
		x, y = math.floor(x / 2), math.floor(y / 2);
		if ((a + b) >= 1) then
			r = r + p;
		end
		p = 2 * p;
	end
	return r;
end;
bit32.bxor = function(x, y)
	x, y = x % P, y % P;
	local r = 0;
	local p = 1;
	for i = 1, N do
		local a, b = x % 2, y % 2;
		x, y = math.floor(x / 2), math.floor(y / 2);
		if ((a + b) == 1) then
			r = r + p;
		end
		p = 2 * p;
	end
	return r;
end;
bit32.lshift = function(x, s_amount)
	if (math.abs(s_amount) >= N) then
		return 0;
	end
	x = x % P;
	if (s_amount < 0) then
		return math.floor(x * (2 ^ s_amount));
	else
		return (x * (2 ^ s_amount)) % P;
	end
end;
bit32.rshift = function(x, s_amount)
	if (math.abs(s_amount) >= N) then
		return 0;
	end
	x = x % P;
	if (s_amount > 0) then
		return math.floor(x * (2 ^ -s_amount));
	else
		return (x * (2 ^ -s_amount)) % P;
	end
end;
bit32.arshift = function(x, s_amount)
	if (math.abs(s_amount) >= N) then
		return 0;
	end
	x = x % P;
	if (s_amount > 0) then
		local add = 0;
		if (x >= (P / 2)) then
			add = P - (2 ^ (N - s_amount));
		end
		return math.floor(x * (2 ^ -s_amount)) + add;
	else
		return (x * (2 ^ -s_amount)) % P;
	end
end;
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local VirtualInputManager = game:GetService("VirtualInputManager");
local UserInputService = game:GetService("UserInputService");
local TweenService = game:GetService("TweenService");
local Players = game:GetService("Players");
local LocalPlayer = Players.LocalPlayer;
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui");
local EffectFolder = ReplicatedStorage:FindFirstChild("Effect");
local Bindable = EffectFolder and EffectFolder:FindFirstChild("Bindable");
local Soru = EffectFolder and EffectFolder:FindFirstChild("Container") and EffectFolder.Container:FindFirstChild("Shared") and EffectFolder.Container.Shared:FindFirstChild("Soru");
local SkillsList = {"Z","X","C"};
local CurrentSkillIndex = 1;
local SelectedSkill = Enum.KeyCode[SkillsList[CurrentSkillIndex]];
local SkillEnabled = true;
local isExecuting = false;
local ScreenGui = Instance.new("ScreenGui");
ScreenGui.Name = "UltraSoruGUI";
ScreenGui.ResetOnSpawn = false;
ScreenGui.Parent = PlayerGui;
local MainFrame = Instance.new("Frame");
MainFrame.Size = UDim2.new(0, 230, 0, 190);
MainFrame.Position = UDim2.new(0.5, -115, 0.4, -95);
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20);
MainFrame.BorderColor3 = Color3.fromRGB(60, 60, 80);
MainFrame.BorderSizePixel = 1;
MainFrame.Active = true;
MainFrame.Draggable = true;
MainFrame.Parent = ScreenGui;
local UICornerMain = Instance.new("UICorner");
UICornerMain.CornerRadius = UDim.new(0, 12);
UICornerMain.Parent = MainFrame;
local Title = Instance.new("TextLabel");
Title.Size = UDim2.new(1, 0, 0, 34);
Title.BackgroundColor3 = Color3.fromRGB(22, 22, 30);
Title.BorderSizePixel = 0;
Title.Text = "⚡ [ ERT // (L) HIDE ] ⚡";
Title.TextColor3 = Color3.fromRGB(255, 204, 0);
Title.TextSize = 11;
Title.Font = Enum.Font.Code;
Title.Parent = MainFrame;
local UICornerTitle = Instance.new("UICorner");
UICornerTitle.CornerRadius = UDim.new(0, 12);
UICornerTitle.Parent = Title;
local SwitchBtn = Instance.new("TextButton");
SwitchBtn.Size = UDim2.new(1, -24, 0, 36);
SwitchBtn.Position = UDim2.new(0, 12, 0, 46);
SwitchBtn.BackgroundColor3 = Color3.fromRGB(0, 168, 84);
SwitchBtn.BorderSizePixel = 0;
SwitchBtn.Text = "AUTO SKILL: [ON] (P)";
SwitchBtn.TextColor3 = Color3.fromRGB(255, 255, 255);
SwitchBtn.TextSize = 12;
SwitchBtn.Font = Enum.Font.Code;
SwitchBtn.Parent = MainFrame;
local UICornerBtn = Instance.new("UICorner");
UICornerBtn.CornerRadius = UDim.new(0, 8);
UICornerBtn.Parent = SwitchBtn;
local updateSwitchButton;
function v57()
	if SkillEnabled then
		SwitchBtn.Text = "AUTO SKILL: [ON] (P)";
		SwitchBtn.BackgroundColor3 = Color3.fromRGB(0, 168, 84);
	else
		SwitchBtn.Text = "AUTO SKILL: [OFF] (P)";
		SwitchBtn.BackgroundColor3 = Color3.fromRGB(180, 45, 45);
	end
end
SwitchBtn.MouseButton1Click:Connect(function()
	SkillEnabled = not SkillEnabled;
	updateSwitchButton();
end);
local Label = Instance.new("TextLabel");
Label.Size = UDim2.new(1, 0, 0, 20);
Label.Position = UDim2.new(0, 0, 0, 88);
Label.BackgroundTransparency = 1;
Label.Text = "ERT - ACTIVE SKILL:";
Label.TextColor3 = Color3.fromRGB(140, 140, 165);
Label.TextSize = 10;
Label.Font = Enum.Font.Code;
Label.Parent = MainFrame;
local ButtonsContainer = Instance.new("Frame");
ButtonsContainer.Size = UDim2.new(0, 180, 0, 36);
ButtonsContainer.Position = UDim2.new(0.5, -90, 0, 110);
ButtonsContainer.BackgroundTransparency = 1;
ButtonsContainer.Parent = MainFrame;
local UIGridLayout = Instance.new("UIGridLayout");
UIGridLayout.CellSize = UDim2.new(0, 52, 0, 34);
UIGridLayout.CellPadding = UDim2.new(0, 12, 0, 0);
UIGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center;
UIGridLayout.Parent = ButtonsContainer;
local skillButtons = {};
local SkillNotifyLabel = Instance.new("TextLabel");
SkillNotifyLabel.Size = UDim2.new(0, 54, 0, 28);
SkillNotifyLabel.BackgroundColor3 = Color3.fromRGB(18, 18, 25);
SkillNotifyLabel.BorderColor3 = Color3.fromRGB(80, 80, 110);
SkillNotifyLabel.BorderSizePixel = 1;
SkillNotifyLabel.TextColor3 = Color3.fromRGB(0, 255, 170);
SkillNotifyLabel.TextSize = 13;
SkillNotifyLabel.Font = Enum.Font.Code;
SkillNotifyLabel.Visible = false;
SkillNotifyLabel.Parent = ScreenGui;
local skillNotifyTween = nil;
local showSkillNotificationAtMouse;
function v90(skillName)
	local mousePos = UserInputService:GetMouseLocation();
	SkillNotifyLabel.Position = UDim2.new(0, mousePos.X + 15, 0, mousePos.Y - 10);
	SkillNotifyLabel.Text = "ERT: [" .. skillName .. "]";
	if skillNotifyTween then
		skillNotifyTween:Cancel();
	end
	SkillNotifyLabel.Visible = true;
	SkillNotifyLabel.TextTransparency = 0;
	SkillNotifyLabel.BackgroundTransparency = 0.2;
	skillNotifyTween = TweenService:Create(SkillNotifyLabel, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency=1,BackgroundTransparency=1});
	task.delay(0.9, function()
		if (SkillNotifyLabel.TextTransparency == 0) then
			skillNotifyTween:Play();
			skillNotifyTween.Completed:Connect(function()
				if (SkillNotifyLabel.TextTransparency >= 1) then
					SkillNotifyLabel.Visible = false;
				end
			end);
		end
	end);
end
local updateSkillButtons;
function v91(showPopup)
	local selectedName = SkillsList[CurrentSkillIndex];
	SelectedSkill = Enum.KeyCode[selectedName];
	for name, button in pairs(skillButtons) do
		if (name == selectedName) then
			button.BackgroundColor3 = Color3.fromRGB(0, 200, 100);
		else
			button.BackgroundColor3 = Color3.fromRGB(30, 30, 42);
		end
	end
	if showPopup then
		showSkillNotificationAtMouse(selectedName);
	end
end
for index, skillName in ipairs(SkillsList) do
	local btn = Instance.new("TextButton");
	btn.Text = skillName;
	btn.TextSize = 13;
	btn.Font = Enum.Font.Code;
	btn.TextColor3 = Color3.fromRGB(255, 255, 255);
	btn.BorderSizePixel = 0;
	btn.BackgroundColor3 = ((skillName == "Z") and Color3.fromRGB(0, 200, 100)) or Color3.fromRGB(30, 30, 42);
	btn.Parent = ButtonsContainer;
	local corner = Instance.new("UICorner");
	corner.CornerRadius = UDim.new(0, 8);
	corner.Parent = btn;
	btn.MouseButton1Click:Connect(function()
		CurrentSkillIndex = index;
		updateSkillButtons(true);
	end);
	skillButtons[skillName] = btn;
end
local StatusLabel = Instance.new("TextLabel");
StatusLabel.Size = UDim2.new(1, 0, 0, 20);
StatusLabel.Position = UDim2.new(0, 0, 1, -22);
StatusLabel.BackgroundTransparency = 1;
StatusLabel.Text = "ERT: READY";
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 120);
StatusLabel.TextSize = 11;
StatusLabel.Font = Enum.Font.Code;
StatusLabel.Parent = MainFrame;
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if UserInputService:GetFocusedTextBox() then
		return;
	end
	if (input.KeyCode == Enum.KeyCode.P) then
		SkillEnabled = not SkillEnabled;
		updateSwitchButton();
	end
	if (input.KeyCode == Enum.KeyCode.L) then
		MainFrame.Visible = not MainFrame.Visible;
	end
	if ((input.KeyCode == Enum.KeyCode.LeftAlt) or (input.KeyCode == Enum.KeyCode.RightAlt)) then
		CurrentSkillIndex = CurrentSkillIndex + 1;
		if (CurrentSkillIndex > #SkillsList) then
			CurrentSkillIndex = 1;
		end
		updateSkillButtons(true);
	end
end);
local isMyCharacter;
function v101(obj)
	local char = LocalPlayer.Character;
	if not char then
		return false;
	end
	if (typeof(obj) == "Instance") then
		return (obj == char) or obj:IsDescendantOf(char);
	elseif (type(obj) == "table") then
		for _, v in pairs(obj) do
			if isMyCharacter(v) then
				return true;
			end
		end
	end
	return false;
end
if Bindable then
	Bindable.Event:Connect(function(action, module, data, info)
		if (not SkillEnabled or isExecuting) then
			return;
		end
		if ((action == "spawn") and ((module == Soru) or (tostring(module) == "Soru"))) then
			if (isMyCharacter(data) or isMyCharacter(info)) then
				isExecuting = true;
				StatusLabel.Text = "ERT: EXECUTING [" .. SkillsList[CurrentSkillIndex] .. "]";
				StatusLabel.TextColor3 = Color3.fromRGB(255, 170, 0);
				VirtualInputManager:SendKeyEvent(true, SelectedSkill, false, nil);
				VirtualInputManager:SendKeyEvent(false, SelectedSkill, false, nil);
				task.wait(0.04);
				StatusLabel.Text = "ERT: READY";
				StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 120);
				isExecuting = false;
			end
		end
	end);
end
