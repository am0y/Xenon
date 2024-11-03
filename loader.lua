--// Cache

local loadstring, game, getgenv, setclipboard = loadstring, game, getgenv, setclipboard

--// Loaded check

if getgenv().Xenon then return end

--// Load Aimbot V2 (Raw)

loadstring(game:HttpGet("https://raw.githubusercontent.com/am0y/Xenon/main/main.lua"))()
o
--// Variables

local Xenon = getgenv().Xenon
local Settings, FOVSettings, Functions = Xenon.Settings, Xenon.FOVSettings, Xenon.Functions

local Library = loadstring(game:GetObjects("rbxassetid://7657867786")[1].Source)() -- Pepsi's UI Library

local Parts = {"Head", "HumanoidRootPart", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "LeftHand", "RightHand", "LeftLowerArm", "RightLowerArm", "LeftUpperArm", "RightUpperArm", "LeftFoot", "LeftLowerLeg", "UpperTorso", "LeftUpperLeg", "RightFoot", "RightLowerLeg", "LowerTorso", "RightUpperLeg"}

--// Frame

Library.UnloadCallback = Functions.Exit

local MainFrame = Library:CreateWindow({
	Name = "Xenon",
	Theme = [[{"__Designer.Colors.section":"1A0F0F","__Designer.Colors.topGradient":"0A0404","__Designer.Settings.ShowHideKey":"Enum.KeyCode.RightShift","__Designer.Colors.otherElementText":"4D2929","__Designer.Colors.hoveredOptionBottom":"7D2626","__Designer.Colors.unhoveredOptionTop":"952424","__Designer.Colors.innerBorder":"681C1C","__Designer.Colors.unselectedOption":"A02E2E","__Designer.Colors.main":"FF2323","__Designer.Colors.outerBorder":"430F0F","__Designer.Colors.tabText":"F1C9C9","__Designer.Colors.elementBorder":"260F0F","__Designer.Colors.sectionBackground":"1C0E0E","__Designer.Colors.selectedOption":"C25555","__Designer.Colors.background":"2A1111","__Designer.Colors.bottomGradient":"421515","__Designer.Colors.hoveredOptionTop":"A04848","__Designer.Colors.elementText":"B87676","__Designer.Colors.unhoveredOptionBottom":"C45454"}]]
})

--// Tabs

local AimbotTab = MainFrame:CreateTab({
	Name = "Aimbot"
})

local FOVTab = MainFrame:CreateTab({
	Name = "FOV"
})

--// Settings - Sections

local Values = SettingsTab:CreateSection({
	Name = "Values"
})

local Checks = SettingsTab:CreateSection({
	Name = "Checks"
})

local ThirdPerson = SettingsTab:CreateSection({
	Name = "Third Person"
})

--// FOV Settings - Sections

local FOV_Values = FOVSettingsTab:CreateSection({
	Name = "Values"
})

local FOV_Appearance = FOVSettingsTab:CreateSection({
	Name = "Appearance"
})

--// Settings / Values

Values:AddToggle({
	Name = "Enabled",
	Value = Settings.Enabled,
	Callback = function(New, Old)
		Settings.Enabled = New
	end
}).Default = Settings.Enabled

Values:AddToggle({
	Name = "Toggle",
	Value = Settings.Toggle,
	Callback = function(New, Old)
		Settings.Toggle = New
	end
}).Default = Settings.Toggle

Settings.LockPart = Parts[1]; Values:AddDropdown({
	Name = "Lock Part",
	Value = Parts[1],
	Callback = function(New, Old)
		Settings.LockPart = New
	end,
	List = Parts,
	Nothing = "Head"
}).Default = Parts[1]

Values:AddTextbox({ -- Using a Textbox instead of a Keybind because the UI Library doesn't support Mouse inputs like Left Click / Right Click...
	Name = "Hotkey",
	Value = Settings.TriggerKey,
	Callback = function(New, Old)
		Settings.TriggerKey = New
	end
}).Default = Settings.TriggerKey

Values:AddToggle({
	Name = "Prediction",
	Value = Settings.Prediction,
	Callback = function(New, Old)
		Settings.Prediction = New
	end
}).Default = Settings.Prediction

Values:AddSlider({
	Name = "Prediction Amount",
	Value = Settings.PredictionAmount,
	Callback = function(New, Old)
		Settings.PredictionAmount = New
	end,
	Min = 0,
	Max = 1,
	Decimals = 2
}).Default = Settings.PredictionAmount

Values:AddSlider({
	Name = "Sensitivity",
	Value = Settings.Sensitivity,
	Callback = function(New, Old)
		Settings.Sensitivity = New
	end,
	Min = 0,
	Max = 1,
	Decimals = 2
}).Default = Settings.Sensitivity

--// Settings / Checks

Checks:AddToggle({
	Name = "Team Check",
	Value = Settings.TeamCheck,
	Callback = function(New, Old)
		Settings.TeamCheck = New
	end
}).Default = Settings.TeamCheck

Checks:AddToggle({
	Name = "Wall Check",
	Value = Settings.WallCheck,
	Callback = function(New, Old)
		Settings.WallCheck = New
	end
}).Default = Settings.WallCheck

Checks:AddToggle({
	Name = "Alive Check",
	Value = Settings.AliveCheck,
	Callback = function(New, Old)
		Settings.AliveCheck = New
	end
}).Default = Settings.AliveCheck

--// Settings / ThirdPerson

ThirdPerson:AddToggle({
	Name = "Enable Third Person",
	Value = Settings.ThirdPerson,
	Callback = function(New, Old)
		Settings.ThirdPerson = New
	end
}).Default = Settings.ThirdPerson

ThirdPerson:AddSlider({
	Name = "Sensitivity",
	Value = Settings.ThirdPersonSensitivity,
	Callback = function(New, Old)
		Settings.ThirdPersonSensitivity = New
	end,
	Min = 0.1,
	Max = 5,
	Decimals = 1
}).Default = Settings.ThirdPersonSensitivity

--// FOV Settings / Values

FOV_Values:AddToggle({
	Name = "Enabled",
	Value = FOVSettings.Enabled,
	Callback = function(New, Old)
		FOVSettings.Enabled = New
	end
}).Default = FOVSettings.Enabled

FOV_Values:AddToggle({
	Name = "Visible",
	Value = FOVSettings.Visible,
	Callback = function(New, Old)
		FOVSettings.Visible = New
	end
}).Default = FOVSettings.Visible

FOV_Values:AddSlider({
	Name = "Amount",
	Value = FOVSettings.Amount,
	Callback = function(New, Old)
		FOVSettings.Amount = New
	end,
	Min = 10,
	Max = 300
}).Default = FOVSettings.Amount

--// FOV Settings / Appearance

FOV_Appearance:AddToggle({
	Name = "Filled",
	Value = FOVSettings.Filled,
	Callback = function(New, Old)
		FOVSettings.Filled = New
	end
}).Default = FOVSettings.Filled

FOV_Appearance:AddSlider({
	Name = "Transparency",
	Value = FOVSettings.Transparency,
	Callback = function(New, Old)
		FOVSettings.Transparency = New
	end,
	Min = 0,
	Max = 1,
	Decimal = 1
}).Default = FOVSettings.Transparency

FOV_Appearance:AddSlider({
	Name = "Sides",
	Value = FOVSettings.Sides,
	Callback = function(New, Old)
		FOVSettings.Sides = New
	end,
	Min = 3,
	Max = 60
}).Default = FOVSettings.Sides

FOV_Appearance:AddSlider({
	Name = "Thickness",
	Value = FOVSettings.Thickness,
	Callback = function(New, Old)
		FOVSettings.Thickness = New
	end,
	Min = 1,
	Max = 50
}).Default = FOVSettings.Thickness

FOV_Appearance:AddColorpicker({
	Name = "Color",
	Value = FOVSettings.Color,
	Callback = function(New, Old)
		FOVSettings.Color = New
	end
}).Default = FOVSettings.Color

FOV_Appearance:AddColorpicker({
	Name = "Locked Color",
	Value = FOVSettings.LockedColor,
	Callback = function(New, Old)
		FOVSettings.LockedColor = New
	end
}).Default = FOVSettings.LockedColor

