--// Cache

local loadstring, game, getgenv, writefile, readfile, delfile, isfolder, makefolder, delfolder = loadstring, game, getgenv, writefile, readfile, delfile, isfolder, makefolder, delfolder

--// Loaded check

if getgenv().Aimbot then return end

--// Load Aimbot V2 (Raw)

loadstring(game:HttpGet("https://raw.githubusercontent.com/am0y/Xenon/main/main.lua"))()

--// Variables

local Aimbot = getgenv().Aimbot
local Settings, FOVSettings, Functions = Aimbot.Settings, Aimbot.FOVSettings, Aimbot.Functions

local Library = loadstring(game:GetObjects("rbxassetid://7657867786")[1].Source)() -- Pepsi's UI Library

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
        
        local success, encoded = pcall(game.HttpService.JSONEncode, game.HttpService, config)
        if success then
            writefile(ConfigSystem.FolderName .. "/" .. name .. ConfigSystem.ConfigExtension, encoded)
            return true
        end
        return false
    end,
    
    LoadConfig = function(name)
        local path = ConfigSystem.FolderName .. "/" .. name .. ConfigSystem.ConfigExtension
        if not isfile(path) then return false end
        
        local success, decoded = pcall(game.HttpService.JSONDecode, game.HttpService, readfile(path))
        if success then
            for i, v in pairs(decoded.Settings) do
                Settings[i] = v
            end
            for i, v in pairs(decoded.FOVSettings) do
                FOVSettings[i] = v
            end
            return true
        end
        return false
    end,
    
    DeleteConfig = function(name)
        local path = ConfigSystem.FolderName .. "/" .. name .. ConfigSystem.ConfigExtension
        if isfile(path) then
            delfile(path)
            return true
        end
        return false
    end
}

ConfigSystem.Init()

--// Frame

Library.UnloadCallback = Functions.Exit

local MainFrame = Library:CreateWindow({
    Name = "Xenon",
    Theme = [[{"__Designer.Colors.topGradient":"782020","__Designer.Colors.section":"451111","__Designer.Colors.hoveredOptionTop":"451111","__Designer.Colors.hoveredOptionBottom":"2D0B0B","__Designer.Colors.selectedOption":"4B1313","__Designer.Colors.unselectedOption":"391010","__Designer.Background.ImageAssetID":"","__Designer.Colors.unhoveredOptionTop":"391010","__Designer.Colors.unhoveredOptionBottom":"2D0B0B","__Designer.Colors.box":"2D0B0B","__Designer.Colors.bottomGradient":"2D0B0B"}]]
})

--// Tabs

local AimbotTab = MainFrame:CreateTab({
    Name = "Aimbot"
})

local FOVTab = MainFrame:CreateTab({
    Name = "FOV"
})

--// Sections

local MainSection = AimbotTab:CreateSection({
    Name = "Main"
})

local ConfigSection = AimbotTab:CreateSection({
    Name = "Config"
})

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
    Callback = function(New, Old)
        Settings.Enabled = New
    end
}).Default = Settings.Enabled

MainSection:AddToggle({
    Name = "Toggle",
    Value = Settings.Toggle,
    Callback = function(New, Old)
        Settings.Toggle = New
    end
}).Default = Settings.Toggle

MainSection:AddToggle({
    Name = "Sticky Aim",
    Value = Settings.StickyAim,
    Callback = function(New, Old)
        Settings.StickyAim = New
    end
}).Default = Settings.StickyAim

Settings.LockPart = Parts[1]; MainSection:AddDropdown({
    Name = "Lock Part",
    Value = Parts[1],
    Callback = function(New, Old)
        Settings.LockPart = New
    end,
    List = Parts,
    Nothing = "Head"
}).Default = Parts[1]

MainSection:AddTextbox({
    Name = "Hotkey",
    Value = Settings.TriggerKey,
    Callback = function(New, Old)
        Settings.TriggerKey = New
    end
}).Default = Settings.TriggerKey

MainSection:AddSlider({
    Name = "Sensitivity",
    Value = Settings.Sensitivity,
    Callback = function(New, Old)
        Settings.Sensitivity = New
    end,
    Min = 0,
    Max = 1,
    Decimals = 2
}).Default = Settings.Sensitivity

MainSection:AddToggle({
    Name = "Prediction",
    Value = Settings.Prediction,
    Callback = function(New, Old)
        Settings.Prediction = New
    end
}).Default = Settings.Prediction

MainSection:AddSlider({
    Name = "Prediction Amount",
    Value = Settings.PredictionAmount,
    Callback = function(New, Old)
        Settings.PredictionAmount = New
    end,
    Min = 0,
    Max = 1,
    Decimals = 2
}).Default = Settings.PredictionAmount

MainSection:AddToggle({
    Name = "Team Check",
    Value = Settings.TeamCheck,
    Callback = function(New, Old)
        Settings.TeamCheck = New
    end
}).Default = Settings.TeamCheck

MainSection:AddToggle({
    Name = "Wall Check",
    Value = Settings.WallCheck,
    Callback = function(New, Old)
        Settings.WallCheck = New
    end
}).Default = Settings.WallCheck

MainSection:AddToggle({
    Name = "Alive Check",
    Value = Settings.AliveCheck,
    Callback = function(New, Old)
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
    Callback = function(New, Old)
        FOVSettings.Enabled = New
    end
}).Default = FOVSettings.Enabled

FOVMainSection:AddToggle({
    Name = "Visible",
    Value = FOVSettings.Visible,
    Callback = function(New, Old)
        FOVSettings.Visible = New
    end
}).Default = FOVSettings.Visible

FOVMainSection:AddSlider({
    Name = "Amount",
    Value = FOVSettings.Amount,
    Callback = function(New, Old)
        FOVSettings.Amount = New
    end,
    Min = 10,
    Max = 300
}).Default = FOVSettings.Amount

--// FOV Appearance Section

FOVAppearanceSection:AddToggle({
    Name = "Filled",
    Value = FOVSettings.Filled,
    Callback = function(New, Old)
        FOVSettings.Filled = New
    end
}).Default = FOVSettings.Filled

FOVAppearanceSection:AddSlider({
    Name = "Transparency",
    Value = FOVSettings.Transparency,
    Callback = function(New, Old)
        FOVSettings.Transparency = New
    end,
    Min = 0,
    Max = 1,
    Decimal = 1
}).Default = FOVSettings.Transparency

FOVAppearanceSection:AddSlider({
    Name = "Sides",
    Value = FOVSettings.Sides,
    Callback = function(New, Old)
        FOVSettings.Sides = New
    end,
    Min = 3,
    Max = 60
}).Default = FOVSettings.Sides

FOVAppearanceSection:AddSlider({
    Name = "Thickness",
    Value = FOVSettings.Thickness,
    Callback = function(New, Old)
        FOVSettings.Thickness = New
    end,
    Min = 1,
    Max = 50
}).Default = FOVSettings.Thickness

FOVAppearanceSection:AddColorpicker({
    Name = "Color",
    Value = FOVSettings.Color,
    Callback = function(New, Old)
        FOVSettings.Color = New
    end
}).Default = FOVSettings.Color

FOVAppearanceSection:AddColorpicker({
    Name = "Locked Color",
    Value = FOVSettings.LockedColor,
    Callback = function(New, Old)
        FOVSettings.LockedColor = New
    end
}).Default = FOVSettings.LockedColor
