--// Cache

local loadstring, game, getgenv, writefile, readfile, delfile, isfolder, makefolder, delfolder = loadstring, game, getgenv, writefile, readfile, delfile, isfolder, makefolder, delfolder

--// Loaded check

if getgenv().Aimbot then return end

--// Load Aimbot V2 (Raw)

loadstring(game:HttpGet("https://raw.githubusercontent.com/am0y/Xenon/main/main.lua"))()

--// Variables

local Aimbot = getgenv().Aimbot
local Settings, FOVSettings, Functions = Aimbot.Settings, Aimbot.FOVSettings, Aimbot.Functions
local HttpService = game:GetService("HttpService")
local Library = loadstring(game:GetObjects("rbxassetid://7657867786")[1].Source)()

local Parts = {"Head", "HumanoidRootPart", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "LeftHand", "RightHand", "LeftLowerArm", "RightLowerArm", "LeftUpperArm", "RightUpperArm", "LeftFoot", "LeftLowerLeg", "UpperTorso", "LeftUpperLeg", "RightFoot", "RightLowerLeg", "LowerTorso", "RightUpperLeg"}

--// Config System

local ConfigSystem = {
    FolderName = "XenonConfigs",
    ConfigExtension = ".xenon",
    
    Init = function()
        if not isfolder(ConfigSystem.FolderName) then
            makefolder(ConfigSystem.FolderName)
        end
    end,
    
    SaveConfig = function(name)
        local config = {
            Settings = Settings,
            FOVSettings = FOVSettings
        }
        writefile(ConfigSystem.FolderName .. "/" .. name .. ConfigSystem.ConfigExtension, HttpService:JSONEncode(config))
    end,
    
    LoadConfig = function(name)
        local path = ConfigSystem.FolderName .. "/" .. name .. ConfigSystem.ConfigExtension
        if not isfile(path) then return false end
        
        local config = HttpService:JSONDecode(readfile(path))
        for i,v in pairs(config.Settings) do
            Settings[i] = v
        end
        for i,v in pairs(config.FOVSettings) do
            FOVSettings[i] = v 
        end
    end,
    
    DeleteConfig = function(name)
        delfile(ConfigSystem.FolderName .. "/" .. name .. ConfigSystem.ConfigExtension)
    end
}

ConfigSystem.Init()

--// Frame

Library.UnloadCallback = Functions.Exit

local MainFrame = Library:CreateWindow({
    Name = "Xenon",
    Themeable = false,
    Theme = [[{"__Designer.Colors.topGradient":"782020","__Designer.Colors.section":"451111","__Designer.Colors.hoveredOptionTop":"451111","__Designer.Colors.hoveredOptionBottom":"2D0B0B","__Designer.Colors.selectedOption":"4B1313","__Designer.Colors.unselectedOption":"391010","__Designer.Colors.unhoveredOptionTop":"391010","__Designer.Colors.unhoveredOptionBottom":"2D0B0B","__Designer.Colors.box":"2D0B0B","__Designer.Colors.bottomGradient":"2D0B0B"}]]
})

--// Tabs

local AimbotTab = MainFrame:CreateTab({
    Name = "Aimbot"
})

local FOVTab = MainFrame:CreateTab({
    Name = "FOV"
})

--// Aimbot Tab

local MainSection = AimbotTab:CreateSection({
    Name = "Main"
})

local ConfigSection = AimbotTab:CreateSection({
    Name = "Config"
})

--// FOV Tab

local FOVMainSection = FOVTab:CreateSection({
    Name = "Main"
})

local FOVAppearanceSection = FOVTab:CreateSection({
    Name = "Appearance"
})

--// Main Section

MainSection:AddToggle({
    Name = "Enabled",
    Value = Settings.Enabled,
    Callback = function(New)
        Settings.Enabled = New
    end
}).Default = Settings.Enabled

MainSection:AddToggle({
    Name = "Toggle",
    Value = Settings.Toggle,
    Callback = function(New)
        Settings.Toggle = New
    end
}).Default = Settings.Toggle

MainSection:AddToggle({
    Name = "Sticky Aim",
    Value = Settings.StickyAim,
    Callback = function(New)
        Settings.StickyAim = New
    end
}).Default = Settings.StickyAim

Settings.LockPart = Parts[1]
MainSection:AddDropdown({
    Name = "Lock Part",
    Value = Parts[1],
    Callback = function(New)
        Settings.LockPart = New
    end,
    List = Parts,
    Nothing = "Head"
}).Default = Parts[1]

MainSection:AddTextbox({
    Name = "Hotkey",
    Value = Settings.TriggerKey,
    Callback = function(New)
        Settings.TriggerKey = New
    end
}).Default = Settings.TriggerKey

MainSection:AddSlider({
    Name = "Sensitivity",
    Value = Settings.Sensitivity,
    Callback = function(New)
        Settings.Sensitivity = New
    end,
    Min = 0,
    Max = 1,
    Decimals = 2
}).Default = Settings.Sensitivity

MainSection:AddToggle({
    Name = "Prediction",
    Value = Settings.Prediction,
    Callback = function(New)
        Settings.Prediction = New
    end
}).Default = Settings.Prediction

MainSection:AddSlider({
    Name = "Prediction Amount",
    Value = Settings.PredictionAmount,
    Callback = function(New)
        Settings.PredictionAmount = New
    end,
    Min = 0,
    Max = 1,
    Decimals = 2
}).Default = Settings.PredictionAmount

MainSection:AddToggle({
    Name = "Team Check",
    Value = Settings.TeamCheck,
    Callback = function(New)
        Settings.TeamCheck = New
    end
}).Default = Settings.TeamCheck

MainSection:AddToggle({
    Name = "Wall Check",
    Value = Settings.WallCheck,
    Callback = function(New)
        Settings.WallCheck = New
    end
}).Default = Settings.WallCheck

MainSection:AddToggle({
    Name = "Alive Check",
    Value = Settings.AliveCheck,
    Callback = function(New)
        Settings.AliveCheck = New
    end
}).Default = Settings.AliveCheck

--// Config Section

local configName = ""

ConfigSection:AddTextbox({
    Name = "Config Name",
    Value = "",
    Callback = function(New)
        configName = New
    end
})

ConfigSection:AddButton({
    Name = "Save Config",
    Callback = function()
        if configName ~= "" then
            ConfigSystem.SaveConfig(configName)
        end
    end
})

ConfigSection:AddButton({
    Name = "Load Config",
    Callback = function()
        if configName ~= "" then
            ConfigSystem.LoadConfig(configName)
        end
    end
})

ConfigSection:AddButton({
    Name = "Delete Config",
    Callback = function()
        if configName ~= "" then
            ConfigSystem.DeleteConfig(configName)
        end
    end
})

--// FOV Main Section

FOVMainSection:AddToggle({
    Name = "Enabled",
    Value = FOVSettings.Enabled,
    Callback = function(New)
        FOVSettings.Enabled = New
    end
}).Default = FOVSettings.Enabled

FOVMainSection:AddToggle({
    Name = "Visible",
    Value = FOVSettings.Visible,
    Callback = function(New)
        FOVSettings.Visible = New
    end
}).Default = FOVSettings.Visible

FOVMainSection:AddSlider({
    Name = "Amount",
    Value = FOVSettings.Amount,
    Callback = function(New)
        FOVSettings.Amount = New
    end,
    Min = 10,
    Max = 300
}).Default = FOVSettings.Amount

--// FOV Appearance Section

FOVAppearanceSection:AddToggle({
    Name = "Filled",
    Value = FOVSettings.Filled,
    Callback = function(New)
        FOVSettings.Filled = New
    end
}).Default = FOVSettings.Filled

FOVAppearanceSection:AddSlider({
    Name = "Transparency",
    Value = FOVSettings.Transparency,
    Callback = function(New)
        FOVSettings.Transparency = New
    end,
    Min = 0,
    Max = 1,
    Decimal = 1
}).Default = FOVSettings.Transparency

FOVAppearanceSection:AddSlider({
    Name = "Sides",
    Value = FOVSettings.Sides,
    Callback = function(New)
        FOVSettings.Sides = New
    end,
    Min = 3,
    Max = 60
}).Default = FOVSettings.Sides

FOVAppearanceSection:AddSlider({
    Name = "Thickness",
    Value = FOVSettings.Thickness,
    Callback = function(New)
        FOVSettings.Thickness = New
    end,
    Min = 1,
    Max = 50
}).Default = FOVSettings.Thickness

FOVAppearanceSection:AddColorpicker({
    Name = "Color",
    Value = FOVSettings.Color,
    Callback = function(New)
        FOVSettings.Color = New
    end
}).Default = FOVSettings.Color

FOVAppearanceSection:AddColorpicker({
    Name = "Locked Color",
    Value = FOVSettings.LockedColor,
    Callback = function(New)
        FOVSettings.LockedColor = New
    end
}).Default = FOVSettings.LockedColor
