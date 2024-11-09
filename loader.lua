--// loader.lua
--// Cache
local loadstring, game, getgenv, setclipboard = loadstring, game, getgenv, setclipboard

--// Loaded check
if getgenv().Xenon then return end

--// Load Xenon
loadstring(game:HttpGet("https://raw.githubusercontent.com/am0y/Xenon/main/main.lua"))()

--// Variables
local Xenon = getgenv().Xenon
local Settings = Xenon.Settings

local Library = loadstring(game:GetObjects("rbxassetid://7657867786")[1].Source)() -- Pepsi's UI Library

local Parts = {"Head", "HumanoidRootPart", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "LeftHand", "RightHand", "LeftLowerArm", "RightLowerArm", "LeftUpperArm", "RightUpperArm", "LeftFoot", "LeftLowerLeg", "UpperTorso", "LeftUpperLeg", "RightFoot", "RightLowerLeg", "LowerTorso", "RightUpperLeg"}

--// Frame
local MainFrame = Library:CreateWindow({
    Name = "Xenon",
    Themeable = false,
    Theme = {
        ["__Designer.Colors.topGradient"] = Color3.fromRGB(220,20,60),
        ["__Designer.Colors.section"] = Color3.fromRGB(220,20,60),
        ["__Designer.Colors.bottomGradient"] = Color3.fromRGB(180,20,40),
        ["__Designer.Colors.otherElementText"] = Color3.fromRGB(220,20,60),
        ["__Designer.Colors.elementText"] = Color3.fromRGB(220,20,60),
        ["__Designer.Colors.background"] = Color3.fromRGB(30,30,30),
        ["__Designer.Colors.sectionBackground"] = Color3.fromRGB(20,20,20),
        ["__Designer.Colors.tabText"] = Color3.fromRGB(220,20,60)
    }
})

--// Tabs
local AimbotTab = MainFrame:CreateTab({
    Name = "Aimbot"
})

local FOVTab = MainFrame:CreateTab({
    Name = "FOV"
})

--// Sections
local AimbotMain = AimbotTab:CreateSection({
    Name = "Main"
})

local AimbotConfig = AimbotTab:CreateSection({
    Name = "Config" 
})

local FOVMain = FOVTab:CreateSection({
    Name = "Main"
})

--// Aimbot Settings
AimbotMain:AddToggle({
    Name = "Enabled",
    Value = Settings.Enabled,
    Callback = function(New)
        Settings.Enabled = New
    end
}).Default = Settings.Enabled

AimbotMain:AddToggle({
    Name = "Team Check",
    Value = Settings.TeamCheck,
    Callback = function(New)
        Settings.TeamCheck = New
    end
}).Default = Settings.TeamCheck

AimbotMain:AddToggle({
    Name = "Alive Check",
    Value = Settings.AliveCheck, 
    Callback = function(New)
        Settings.AliveCheck = New
    end
}).Default = Settings.AliveCheck

AimbotMain:AddToggle({
    Name = "Wall Check",
    Value = Settings.WallCheck,
    Callback = function(New)
        Settings.WallCheck = New
    end
}).Default = Settings.WallCheck

AimbotMain:AddToggle({
    Name = "Toggle",
    Value = Settings.Toggle,
    Callback = function(New)
        Settings.Toggle = New
    end
}).Default = Settings.Toggle

AimbotMain:AddToggle({
    Name = "Prediction",
    Value = Settings.Prediction,
    Callback = function(New)
        Settings.Prediction = New
    end
}).Default = Settings.Prediction

AimbotMain:AddSlider({
    Name = "Prediction Amount",
    Value = Settings.PredictionAmount,
    Callback = function(New)
        Settings.PredictionAmount = New
    end,
    Min = 0,
    Max = 1, 
    Decimals = 3
}).Default = Settings.PredictionAmount

AimbotMain:AddSlider({
    Name = "Sensitivity",
    Value = Settings.Sensitivity,
    Callback = function(New)
        Settings.Sensitivity = New
    end,
    Min = 0,
    Max = 1,
    Decimals = 2
}).Default = Settings.Sensitivity

Settings.LockPart = Parts[1]
AimbotMain:AddDropdown({
    Name = "Lock Part",
    Value = Parts[1],
    Callback = function(New)
        Settings.LockPart = New
    end,
    List = Parts,
    Nothing = "Head"
}).Default = Parts[1]

AimbotMain:AddTextbox({
    Name = "Trigger Key",
    Value = Settings.TriggerKey,
    Callback = function(New)
        Settings.TriggerKey = New
    end
}).Default = Settings.TriggerKey

--// FOV Settings
FOVMain:AddToggle({
    Name = "Enabled",
    Value = Settings.FOVSettings.Enabled,
    Callback = function(New)
        Settings.FOVSettings.Enabled = New
    end
}).Default = Settings.FOVSettings.Enabled

FOVMain:AddToggle({
    Name = "Visible",
    Value = Settings.FOVSettings.Visible,
    Callback = function(New)
        Settings.FOVSettings.Visible = New
    end
}).Default = Settings.FOVSettings.Visible

FOVMain:AddSlider({
    Name = "Amount",
    Value = Settings.FOVSettings.Amount,
    Callback = function(New)
        Settings.FOVSettings.Amount = New
    end,
    Min = 10,
    Max = 300
}).Default = Settings.FOVSettings.Amount

FOVMain:AddToggle({
    Name = "Filled",
    Value = Settings.FOVSettings.Filled,
    Callback = function(New)
        Settings.FOVSettings.Filled = New
    end
}).Default = Settings.FOVSettings.Filled

FOVMain:AddSlider({
    Name = "Transparency",
    Value = Settings.FOVSettings.Transparency,
    Callback = function(New)
        Settings.FOVSettings.Transparency = New
    end,
    Min = 0,
    Max = 1,
    Decimals = 1
}).Default = Settings.FOVSettings.Transparency

FOVMain:AddSlider({
    Name = "Sides",
    Value = Settings.FOVSettings.Sides,
    Callback = function(New)
        Settings.FOVSettings.Sides = New
    end,
    Min = 3,
    Max = 60
}).Default = Settings.FOVSettings.Sides

FOVMain:AddSlider({
    Name = "Thickness",
    Value = Settings.FOVSettings.Thickness,
    Callback = function(New)
        Settings.FOVSettings.Thickness = New
    end,
    Min = 1,
    Max = 50
}).Default = Settings.FOVSettings.Thickness

--// Config Section
AimbotConfig:AddButton({
    Name = "Save Config",
    Callback = function()
        writefile("XenonConfig.json", game:GetService("HttpService"):JSONEncode({
            Settings = Settings,
            FOVSettings = Settings.FOVSettings
        }))
    end
})

AimbotConfig:AddButton({
    Name = "Load Config",
    Callback = function() 
        if isfile("XenonConfig.json") then
            local Config = game:GetService("HttpService"):JSONDecode(readfile("XenonConfig.json"))
            Settings = Config.Settings
            Settings.FOVSettings = Config.FOVSettings
        end
    end
})

AimbotConfig:AddButton({
    Name = "Delete Config",
    Callback = function()
        if isfile("XenonConfig.json") then
            delfile("XenonConfig.json")
        end
    end
})
