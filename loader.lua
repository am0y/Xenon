--// Cache

local loadstring, game, getgenv, writefile, readfile, delfile, isfolder, makefolder, delfolder = loadstring, game, getgenv, writefile, readfile, delfile, isfolder, makefolder, delfolder

--// Loaded check

if getgenv().Aimbot then return end

--// Load Aimbot V2 (Raw)

loadstring(game:HttpGet("https://raw.githubusercontent.com/am0y/Xenon/main/main.lua"))()

--// Variables

local Aimbot = getgenv().Aimbot
local Settings, FOVSettings = Aimbot.Settings, Aimbot.FOVSettings

local HttpService = game:GetService("HttpService")
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()

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
        local data = readfile(ConfigSystem.FolderName .. "/" .. name .. ConfigSystem.ConfigExtension)
        local config = HttpService:JSONDecode(data)
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

--// Window

local Window = Library:CreateWindow({
    Title = "Xenon",
    Center = true,
    AutoShow = true
})

--// Tabs

local Tabs = {
    Main = Window:AddTab("Aimbot"),
    FOV = Window:AddTab("FOV")
}

--// Main Tab

local MainBox = Tabs.Main:AddLeftGroupbox("Main")
local ConfigBox = Tabs.Main:AddRightGroupbox("Config")

MainBox:AddToggle('Enabled', {
    Text = 'Enabled',
    Default = Settings.Enabled,
    Callback = function(Value)
        Settings.Enabled = Value
    end
})

MainBox:AddToggle('Toggle', {
    Text = 'Toggle',
    Default = Settings.Toggle,
    Callback = function(Value)
        Settings.Toggle = Value
    end
})

MainBox:AddToggle('StickyAim', {
    Text = 'Sticky Aim',
    Default = Settings.StickyAim,
    Callback = function(Value)
        Settings.StickyAim = Value
    end
})

MainBox:AddDropdown('LockPart', {
    Values = Parts,
    Default = 1,
    Text = 'Lock Part',
    Callback = function(Value)
        Settings.LockPart = Value
    end
})

MainBox:AddInput('Hotkey', {
    Default = Settings.TriggerKey,
    Text = 'Hotkey',
    Callback = function(Value)
        Settings.TriggerKey = Value
    end
})

MainBox:AddSlider('Sensitivity', {
    Text = 'Sensitivity',
    Default = Settings.Sensitivity,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        Settings.Sensitivity = Value
    end
})

MainBox:AddToggle('Prediction', {
    Text = 'Prediction',
    Default = Settings.Prediction,
    Callback = function(Value)
        Settings.Prediction = Value
    end
})

MainBox:AddSlider('PredictionAmount', {
    Text = 'Prediction Amount',
    Default = Settings.PredictionAmount,
    Min = 0,
    Max = 1,
    Rounding = 3,
    Callback = function(Value)
        Settings.PredictionAmount = Value
    end
})

MainBox:AddToggle('TeamCheck', {
    Text = 'Team Check',
    Default = Settings.TeamCheck,
    Callback = function(Value)
        Settings.TeamCheck = Value
    end
})

MainBox:AddToggle('WallCheck', {
    Text = 'Wall Check',
    Default = Settings.WallCheck,
    Callback = function(Value)
        Settings.WallCheck = Value
    end
})

MainBox:AddToggle('AliveCheck', {
    Text = 'Alive Check', 
    Default = Settings.AliveCheck,
    Callback = function(Value)
        Settings.AliveCheck = Value
    end
})

--// Config Section

local configName = ""

ConfigBox:AddInput('ConfigName', {
    Default = '',
    Text = 'Config Name',
    Callback = function(Value)
        configName = Value
    end
})

ConfigBox:AddButton('Save Config', function()
    if configName ~= "" then
        ConfigSystem.SaveConfig(configName)
    end
end)

ConfigBox:AddButton('Load Config', function()
    if configName ~= "" then
        ConfigSystem.LoadConfig(configName)
    end
end)

ConfigBox:AddButton('Delete Config', function()
    if configName ~= "" then
        ConfigSystem.DeleteConfig(configName)
    end
end)

--// FOV Tab

local FOVMainBox = Tabs.FOV:AddLeftGroupbox('Main')
local FOVAppearanceBox = Tabs.FOV:AddRightGroupbox('Appearance')

FOVMainBox:AddToggle('FOVEnabled', {
    Text = 'Enabled',
    Default = FOVSettings.Enabled,
    Callback = function(Value)
        FOVSettings.Enabled = Value
    end
})

FOVMainBox:AddToggle('FOVVisible', {
    Text = 'Visible',
    Default = FOVSettings.Visible,
    Callback = function(Value)
        FOVSettings.Visible = Value
    end
})

FOVMainBox:AddSlider('FOVAmount', {
    Text = 'Amount',
    Default = FOVSettings.Amount,
    Min = 10,
    Max = 300,
    Rounding = 0,
    Callback = function(Value)
        FOVSettings.Amount = Value
    end
})

FOVAppearanceBox:AddToggle('FOVFilled', {
    Text = 'Filled',
    Default = FOVSettings.Filled,
    Callback = function(Value)
        FOVSettings.Filled = Value
    end
})

FOVAppearanceBox:AddSlider('FOVTransparency', {
    Text = 'Transparency',
    Default = FOVSettings.Transparency,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Callback = function(Value)
        FOVSettings.Transparency = Value
    end
})

FOVAppearanceBox:AddSlider('FOVSides', {
    Text = 'Sides',
    Default = FOVSettings.Sides,
    Min = 3,
    Max = 60,
    Rounding = 0,
    Callback = function(Value)
        FOVSettings.Sides = Value
    end
})

FOVAppearanceBox:AddSlider('FOVThickness', {
    Text = 'Thickness',
    Default = FOVSettings.Thickness,
    Min = 1,
    Max = 50,
    Rounding = 0,
    Callback = function(Value)
        FOVSettings.Thickness = Value
    end
})

FOVAppearanceBox:AddColorPicker('FOVColor', {
    Default = FOVSettings.Color,
    Title = 'Color',
    Callback = function(Value)
        FOVSettings.Color = Value
    end
})

FOVAppearanceBox:AddColorPicker('FOVLockedColor', {
    Default = FOVSettings.LockedColor,
    Title = 'Locked Color',
    Callback = function(Value)
        FOVSettings.LockedColor = Value
    end
})

Library:OnUnload(function()
    Library.Unloaded = true
end)

-- Init
Library:Init()
