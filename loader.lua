--// Cache

local loadstring, game, getgenv, setclipboard = loadstring, game, getgenv, setclipboard

--// Loaded check

if getgenv().Aimbot then return end

--// Load Xenon (Raw)

loadstring(game:HttpGet("https://raw.githubusercontent.com/am0y/Xenon/main/main.lua"))()

--// Variables

local Aimbot = getgenv().Aimbot
local Settings, FOVSettings = Aimbot.Settings, Aimbot.FOVSettings

local Library = loadstring(game:GetObjects("rbxassetid://7657867786")[1].Source)() -- Pepsi's UI Library

local Parts = {"Head", "HumanoidRootPart", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "LeftHand", "RightHand", "LeftLowerArm", "RightLowerArm", "LeftUpperArm", "RightUpperArm", "LeftFoot", "LeftLowerLeg", "UpperTorso", "LeftUpperLeg", "RightFoot", "RightLowerLeg", "LowerTorso", "RightUpperLeg"}

--// Frame

Library.UnloadCallback = Aimbot.Functions.Exit

local MainFrame = Library:CreateWindow({
	Name = "Xenon",
	Themeable = {
		Image = "7059346386",
		Info = "Made by Naj",
		Credit = false
	},
	Background = "",
	Theme = [[{"__Designer.Colors.section":"FFAAAA","__Designer.Colors.topGradient":"4D0000","__Designer.Settings.ShowHideKey":"Enum.KeyCode.RightShift","__Designer.Colors.otherElementText":"FFBBBB","__Designer.Colors.hoveredOptionBottom":"FF4444","__Designer.Background.ImageAssetID":"","__Designer.Colors.unhoveredOptionTop":"FF5555","__Designer.Colors.innerBorder":"800000","__Designer.Colors.unselectedOption":"FF6666","__Designer.Background.UseBackgroundImage":true,"__Designer.Files.WorkspaceFile":"Xenon","__Designer.Colors.main":"FF2222","__Designer.Colors.outerBorder":"330000","__Designer.Background.ImageColor":"FFEEEE","__Designer.Colors.tabText":"FFDDDD","__Designer.Colors.elementBorder":"440000","__Designer.Colors.sectionBackground":"330000","__Designer.Colors.selectedOption":"FF7777","__Designer.Colors.background":"220000","__Designer.Colors.bottomGradient":"550000","__Designer.Background.ImageTransparency":95,"__Designer.Colors.hoveredOptionTop":"FF8888","__Designer.Colors.elementText":"FFCCCC","__Designer.Colors.unhoveredOptionBottom":"FF9999"}]]
})

--// Tabs

local AimbotTab = MainFrame:CreateTab({
	Name = "Aimbot"
})

local FOVTab = MainFrame:CreateTab({
	Name = "FOV"
})

--// Aimbot - Sections

local Values = AimbotTab:CreateSection({
	Name = "Values"
})

local Checks = AimbotTab:CreateSection({
	Name = "Checks"
})

local ThirdPerson = AimbotTab:CreateSection({
	Name = "Third Person"
})

--// FOV - Sections

local FOV_Values = FOVTab:CreateSection({
	Name = "Values"
})

local FOV_Appearance = FOVTab:CreateSection({
	Name = "Appearance"
})

--// Aimbot / Values

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

Values:AddToggle({
	Name = "Sticky",
	Value = Settings.StickyAim,
	Callback = function(New, Old)
		Settings.StickyAim = New
	end
}).Default = Settings.StickyAim

Settings.LockPart = Parts[1]; Values:AddDropdown({
	Name = "Lock Part",
	Value = Parts[1],
	Callback = function(New, Old)
		Settings.LockPart = New
	end,
	List = Parts,
	Nothing = "Head"
}).Default = Parts[1]

Values:AddTextbox({
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
	Name = "Smoothness",
	Value = Settings.Sensitivity,
	Callback = function(New, Old)
		Settings.Sensitivity = New
	end,
	Min = 0,
	Max = 1,
	Decimals = 2
}).Default = Settings.Sensitivity

Values:AddToggle({
	Name = "Legit",
	Value = Settings.LegitMode,
	Callback = function(New, Old)
		Settings.LegitMode = New
        Settings.HumanAim.enabled = New
        if New then
            Settings.ThirdPerson = false
            Settings.Sensitivity = 0
        end
	end
}).Default = Settings.LegitMode

--// Aimbot / Checks

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

--// Aimbot / ThirdPerson

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

--// FOV / Values

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

--// FOV / Appearance

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