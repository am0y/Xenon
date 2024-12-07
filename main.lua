--// Cache

local select = select
local pcall, getgenv, next, Vector2, mathclamp, type, mousemoverel = select(1, pcall, getgenv, next, Vector2.new, math.clamp, type, mousemoverel or (Input and Input.MouseMove))

--// Preventing Multiple Processes

pcall(function()
	getgenv().Aimbot.Functions:Exit()
end)

--// Environment

getgenv().Aimbot = {}
local Environment = getgenv().Aimbot

--// Services

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--// Variables

local RequiredDistance, Typing, Running, Animation, ServiceConnections = 2000, false, false, nil, {}

--// Script Settings

Environment.Settings = {
	Enabled = true,
	TeamCheck = false,
	AliveCheck = true,
	WallCheck = false,
	Sensitivity = 0,
	ThirdPerson = false,
	ThirdPersonSensitivity = 3,
	TriggerKey = "MouseButton2",
	Toggle = false,
	LockPart = "Head",
	Prediction = false,
	PredictionAmount = 0.165,
    StickyAim = false,
    LegitMode = false,
    HumanAim = {
        enabled = false,
        overAimChance = 0.4,      -- Chance to slightly overaim
        underAimChance = 0.3,     -- Chance to slightly underaim
        microAdjustSpeed = 0.12,  -- Speed of micro-adjustments
        maxOvershoot = 0.3,       -- Maximum overshoot amount
        correctionDelay = 0.08,   -- Delay before correcting aim
        shakiness = 0.06,         -- Natural hand shakiness
        flickSpeed = 0.25,        -- Speed of initial flick
        targetSwitchDelay = 0.18  -- Delay when switching targets
    }
}

Environment.FOVSettings = {
	Enabled = true,
	Visible = true,
	Amount = 90,
	Color = Color3.fromRGB(255, 255, 255),
	LockedColor = Color3.fromRGB(255, 70, 70),
	Transparency = 0.5,
	Sides = 60,
	Thickness = 1,
	Filled = false
}

Environment.FOVCircle = Drawing.new("Circle")

--// Functions

local function isVisible(p, target)
    if not Environment.Settings.WallCheck then
        return true
    end
    
    return #Camera:GetPartsObscuringTarget({p}, {Camera, LocalPlayer.Character, target}) == 0
end

local function CancelLock()
	Environment.Locked = nil
	if Animation then Animation:Cancel() end
	Environment.FOVCircle.Color = Environment.FOVSettings.Color
end

local function GetClosestPlayer()
    if not Environment.Locked then
        RequiredDistance = (Environment.FOVSettings.Enabled and Environment.FOVSettings.Amount or 2000)

        for _, v in next, Players:GetPlayers() do
            if v ~= LocalPlayer then
                if v.Character and v.Character:FindFirstChild(Environment.Settings.LockPart) and v.Character:FindFirstChildOfClass("Humanoid") then
                    if Environment.Settings.TeamCheck and v.Team == LocalPlayer.Team then continue end
                    if Environment.Settings.AliveCheck and v.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then continue end
                    if Environment.Settings.WallCheck and not isVisible(v.Character[Environment.Settings.LockPart].Position, v.Character) then continue end

                    local Position = v.Character[Environment.Settings.LockPart].Position
                    
                    if Environment.Settings.Prediction then
                        local Velocity = v.Character[Environment.Settings.LockPart].Velocity
                        Position = Position + (Velocity * Environment.Settings.PredictionAmount)
                    end

                    local Vector, OnScreen = Camera:WorldToViewportPoint(Position)
                    local Distance = (Vector2(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2(Vector.X, Vector.Y)).Magnitude

                    if Distance < RequiredDistance and OnScreen then
                        RequiredDistance = Distance
                        Environment.Locked = v
                    end
                end
            end
        end
    elseif Environment.Locked and Environment.Locked.Character and Environment.Locked.Character:FindFirstChild(Environment.Settings.LockPart) then
        if Environment.Settings.AliveCheck and Environment.Locked.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
            CancelLock()
            return
        end
        if Environment.Settings.TeamCheck and Environment.Locked.Team == LocalPlayer.Team then
            CancelLock()
            return
        end
        
        if not Environment.Settings.StickyAim then
            local Position = Environment.Locked.Character[Environment.Settings.LockPart].Position
            if Environment.Settings.Prediction then
                local Velocity = Environment.Locked.Character[Environment.Settings.LockPart].Velocity
                Position = Position + (Velocity * Environment.Settings.PredictionAmount)
            end
            
            local Vector, OnScreen = Camera:WorldToViewportPoint(Position)
            local Distance = (Vector2(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2(Vector.X, Vector.Y)).Magnitude
            
            if Distance > RequiredDistance or not OnScreen then
                CancelLock()
            end
        end
    else
        CancelLock()
    end
end

--// Typing Check

ServiceConnections.TypingStartedConnection = UserInputService.TextBoxFocused:Connect(function()
	Typing = true
end)

ServiceConnections.TypingEndedConnection = UserInputService.TextBoxFocusReleased:Connect(function()
	Typing = false
end)

--// Main

local function Load()
	ServiceConnections.RenderSteppedConnection = RunService.RenderStepped:Connect(function()
		if Environment.FOVSettings.Enabled and Environment.Settings.Enabled then
			Environment.FOVCircle.Radius = Environment.FOVSettings.Amount
			Environment.FOVCircle.Thickness = Environment.FOVSettings.Thickness
			Environment.FOVCircle.Filled = Environment.FOVSettings.Filled
			Environment.FOVCircle.NumSides = Environment.FOVSettings.Sides
			Environment.FOVCircle.Color = Environment.FOVSettings.Color
			Environment.FOVCircle.Transparency = Environment.FOVSettings.Transparency
			Environment.FOVCircle.Visible = Environment.FOVSettings.Visible
			Environment.FOVCircle.Position = Vector2(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
		else
			Environment.FOVCircle.Visible = false
		end

		if Running and Environment.Settings.Enabled then
			GetClosestPlayer()

			if Environment.Locked then
				local targetPart = Environment.Locked.Character[Environment.Settings.LockPart]
				local targetPos = targetPart.Position

				-- Predict target position
				if Environment.Settings.Prediction then
					local velocity = targetPart.Velocity
					targetPos = targetPos + (velocity * Environment.Settings.PredictionAmount)
				end

				-- Calculate target CFrame and angle difference
				local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
				local _, _, _, x1, y1, z1, x2, y2, z2, x3, y3, z3 = Camera.CFrame:components()
				local currentCFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + Vector3.new(x2, y2, z2))
				local angle = math.acos(currentCFrame.LookVector:Dot((targetCFrame.Position - currentCFrame.Position).Unit))

				if Environment.Settings.LegitMode and Environment.Settings.HumanAim.enabled then
					local currentTime = tick()

					-- Initialize or reset aim state
					if not Environment.AimState or Environment.AimState.lastTarget ~= Environment.Locked then
						Environment.AimState = {
							startTime = currentTime,
							lastUpdate = currentTime,
							lastTarget = Environment.Locked,
							initialAngle = angle,
							overshot = math.random() < Environment.Settings.HumanAim.overAimChance,
							undershot = math.random() < Environment.Settings.HumanAim.underAimChance,
							adjustPhase = 0,
							lastAdjustTime = currentTime,
							flickStarted = false,
							microAdjusting = false
						}
					end

					local aimDelta = currentTime - Environment.AimState.startTime

					-- Calculate natural hand movement
					local handShake = Vector3.new(
						math.sin(currentTime * 10) * Environment.Settings.HumanAim.shakiness,
						math.cos(currentTime * 8) * Environment.Settings.HumanAim.shakiness,
						math.sin(currentTime * 12) * Environment.Settings.HumanAim.shakiness
					)

					-- Initial flick phase
					if not Environment.AimState.flickStarted and aimDelta > Environment.Settings.HumanAim.targetSwitchDelay then
						Environment.AimState.flickStarted = true
						Environment.AimState.flickEndTime = currentTime + Environment.Settings.HumanAim.flickSpeed
					end

					-- Calculate aim position with human characteristics
					if Environment.AimState.flickStarted then
						local flickProgress = math.min((currentTime - Environment.AimState.startTime) / Environment.Settings.HumanAim.flickSpeed, 1)

						-- Add overshooting/undershooting
						if Environment.AimState.overshot then
							local overshootAmount = Vector3.new(
								math.random(-10, 10) / 10 * Environment.Settings.HumanAim.maxOvershoot,
								math.random(-10, 10) / 10 * Environment.Settings.HumanAim.maxOvershoot,
								math.random(-10, 10) / 10 * Environment.Settings.HumanAim.maxOvershoot
							)
							targetPos = targetPos + overshootAmount
						elseif Environment.AimState.undershot then
							local undershootAmount = Vector3.new(
								math.random(-10, 10) / 10 * Environment.Settings.HumanAim.maxOvershoot,
								math.random(-10, 10) / 10 * Environment.Settings.HumanAim.maxOvershoot,
								math.random(-10, 10) / 10 * Environment.Settings.HumanAim.maxOvershoot
							)
							targetPos = targetPos - undershootAmount
						end

						-- Micro-adjustment phase
						if flickProgress >= 1 and currentTime - Environment.AimState.lastAdjustTime > Environment.Settings.HumanAim.correctionDelay then
							Environment.AimState.microAdjusting = true
							local adjustmentProgress = math.sin(Environment.AimState.adjustPhase)
							targetPos = targetPos + (handShake * adjustmentProgress)
							Environment.AimState.adjustPhase = Environment.AimState.adjustPhase + Environment.Settings.HumanAim.microAdjustSpeed
						end
					end
					
					targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)

					-- Apply smoothing
					local t = Environment.Settings.Sensitivity * (Environment.AimState.initialAngle / angle)
					t = math.clamp(t, 0, 1)
					local smoothedCFrame = currentCFrame:Lerp(targetCFrame, t)

					-- Apply final camera movement
					Camera.CFrame = smoothedCFrame
					Environment.AimState.lastUpdate = currentTime

				elseif Environment.Settings.ThirdPerson then
					-- Third-person aiming logic (unchanged)
					Environment.Settings.ThirdPersonSensitivity = math.clamp(Environment.Settings.ThirdPersonSensitivity, 0.1, 5)
					local vector = Camera:WorldToViewportPoint(targetPos)
					mousemoverel((vector.X - UserInputService:GetMouseLocation().X) * Environment.Settings.ThirdPersonSensitivity, (vector.Y - UserInputService:GetMouseLocation().Y) * Environment.Settings.ThirdPersonSensitivity)
				else
					-- First-person aiming with sensitivity
					if Environment.Settings.Sensitivity > 0 then
						local t = Environment.Settings.Sensitivity * (Environment.AimState.initialAngle / angle)
						t = math.clamp(t, 0, 1)
						local smoothedCFrame = currentCFrame:Lerp(targetCFrame, t)
						Camera.CFrame = smoothedCFrame
					else
						Camera.CFrame = targetCFrame
					end
				end

				Environment.FOVCircle.Color = Environment.FOVSettings.LockedColor
			end
		end
	end)

	ServiceConnections.InputBeganConnection = UserInputService.InputBegan:Connect(function(Input)
		if not Typing then
			pcall(function()
				if Input.KeyCode == Enum.KeyCode[Environment.Settings.TriggerKey] then
					if Environment.Settings.Toggle then
						Running = not Running

						if not Running then
							CancelLock()
						end
					else
						Running = true
					end
				end
			end)

			pcall(function()
				if Input.UserInputType == Enum.UserInputType[Environment.Settings.TriggerKey] then
					if Environment.Settings.Toggle then
						Running = not Running

						if not Running then
							CancelLock()
						end
					else
						Running = true
					end
				end
			end)
		end
	end)

	ServiceConnections.InputEndedConnection = UserInputService.InputEnded:Connect(function(Input)
		if not Typing then
			if not Environment.Settings.Toggle then
				pcall(function()
					if Input.KeyCode == Enum.KeyCode[Environment.Settings.TriggerKey] then
						Running = false; CancelLock()
					end
				end)

				pcall(function()
					if Input.UserInputType == Enum.UserInputType[Environment.Settings.TriggerKey] then
						Running = false; CancelLock()
					end
				end)
			end
		end
	end)
end

--// Functions

Environment.Functions = {}

function Environment.Functions:Exit()
	for _, v in next, ServiceConnections do
		v:Disconnect()
	end

	if Environment.FOVCircle.Remove then Environment.FOVCircle:Remove() end

	getgenv().Aimbot.Functions = nil
	getgenv().Aimbot = nil
	
	Load = nil; GetClosestPlayer = nil; CancelLock = nil
end

function Environment.Functions:Restart()
	for _, v in next, ServiceConnections do
		v:Disconnect()
	end

	Load()
end

function Environment.Functions:ResetSettings()
	Environment.Settings = {
		Enabled = true,
		TeamCheck = false,
		AliveCheck = true,
		WallCheck = false,
		Sensitivity = 0,
		ThirdPerson = false,
		ThirdPersonSensitivity = 3,
		TriggerKey = "MouseButton2",
		Toggle = false,
		LockPart = "Head",
		Prediction = false,
		PredictionAmount = 0.165,
        StickyAim = false
	}

	Environment.FOVSettings = {
		Enabled = true,
		Visible = true,
		Amount = 90,
		Color = Color3.fromRGB(255, 255, 255),
		LockedColor = Color3.fromRGB(255, 70, 70),
		Transparency = 0.5,
		Sides = 60,
		Thickness = 1,
		Filled = false
	}
end

--// Load

Load()