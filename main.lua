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
    
    -- Ultra-realistic settings
    Legit = false,
    LegitRandomization = 0.3,
    LegitSpeed = 0.2,
    
    -- Human behavior simulation
    MicroAdjustments = true, -- Simulates small mouse movements
    OverflickChance = 0.3, -- Chance to slightly overflick (0-1)
    UnderflickChance = 0.2, -- Chance to slightly underflick (0-1)
    ReactionTimeMin = 0.1, -- Minimum reaction time in seconds
    ReactionTimeMax = 0.2, -- Maximum reaction time in seconds
    AimCurve = "Exponential", -- Linear, Exponential, Logarithmic
    ShakeAmount = 0.1, -- Natural hand shake simulation (0-1)
    AccuracyVariation = 0.15, -- Varies accuracy based on movement (0-1)
    FatigueFactor = 0.1, -- Gradually decreases accuracy over time (0-1)
    RecoveryTime = 1.5, -- Time to recover full accuracy
    MouseAcceleration = true, -- Simulates mouse acceleration
    AccelAmount = 0.2, -- Amount of acceleration (0-1)
    
    -- Advanced targeting
    TargetSwitchDelay = 0.15, -- Delay when switching targets
    PreAimOffset = 0.3, -- Slight offset for pre-aiming
    TrackingLag = 0.05, -- Simulates human tracking lag
    MicroPauses = true, -- Tiny pauses in aim movement
    AimNoisePattern = "Natural", -- Natural, Robotic, Jittery
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

-- Realistic aim behavior utilities
local AimState = {
    lastAimTime = 0,
    fatigue = 0,
    microAdjustTimer = 0,
    lastPosition = Vector3.new(),
    velocityBuffer = {},
    reactionDelay = 0,
    isRecovering = false,
    lastMouseDelta = Vector2.new()
}

local function calculateHumanError()
    local error = Vector3.new()
    
    -- Base shake
    if Environment.Settings.ShakeAmount > 0 then
        error = error + Vector3.new(
            math.sin(tick() * 10) * Environment.Settings.ShakeAmount,
            math.cos(tick() * 8) * Environment.Settings.ShakeAmount,
            math.sin(tick() * 12) * Environment.Settings.ShakeAmount
        )
    end
    
    -- Fatigue effect
    if AimState.fatigue > 0 then
        local fatigueMult = 1 + (AimState.fatigue * Environment.Settings.FatigueFactor)
        error = error * fatigueMult
    end
    
    -- Movement-based inaccuracy
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local velocity = LocalPlayer.Character.HumanoidRootPart.Velocity
        local speedFactor = velocity.Magnitude / 50
        error = error + (Vector3.new(math.random(), math.random(), math.random()) * speedFactor * Environment.Settings.AccuracyVariation)
    end
    
    return error
end

local function applyAimAcceleration(delta)
    if not Environment.Settings.MouseAcceleration then return delta end
    
    local accelFactor = math.min((tick() - AimState.lastAimTime) * Environment.Settings.AccelAmount, 1)
    AimState.lastMouseDelta = AimState.lastMouseDelta:Lerp(delta, accelFactor)
    return AimState.lastMouseDelta
end

local function simulateHumanAiming(current, target)
    local delta = target - current
    local distance = delta.Magnitude
    
    -- Apply aim curve
    local curveAmount
    if Environment.Settings.AimCurve == "Exponential" then
        curveAmount = math.exp(-distance / 100)
    elseif Environment.Settings.AimCurve == "Logarithmic" then
        curveAmount = math.log(distance + 1) / 5
    else
        curveAmount = 1
    end
    
    -- Overflick/Underflick simulation
    if math.random() < Environment.Settings.OverflickChance then
        delta = delta * (1 + math.random() * 0.2)
    elseif math.random() < Environment.Settings.UnderflickChance then
        delta = delta * (0.8 + math.random() * 0.15)
    end
    
    -- Apply human error
    delta = delta + calculateHumanError()
    
    -- Micro adjustments
    if Environment.Settings.MicroAdjustments then
        local microAdjust = Vector3.new(
            math.sin(tick() * 15) * 0.02,
            math.cos(tick() * 12) * 0.02,
            math.sin(tick() * 18) * 0.02
        )
        delta = delta + microAdjust
    end
    
    return delta * curveAmount
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
				if Environment.Settings.ThirdPerson then
					Environment.Settings.ThirdPersonSensitivity = mathclamp(Environment.Settings.ThirdPersonSensitivity, 0.1, 5)

					local Vector = Camera:WorldToViewportPoint(Environment.Locked.Character[Environment.Settings.LockPart].Position)
					mousemoverel((Vector.X - UserInputService:GetMouseLocation().X) * Environment.Settings.ThirdPersonSensitivity, (Vector.Y - UserInputService:GetMouseLocation().Y) * Environment.Settings.ThirdPersonSensitivity)
				else
					if Environment.Settings.Prediction then
						local Position = Environment.Locked.Character[Environment.Settings.LockPart].Position
						local Velocity = Environment.Locked.Character[Environment.Settings.LockPart].Velocity
						local PredictedPosition = Position + (Velocity * Environment.Settings.PredictionAmount)
						
						if Environment.Settings.Legit then
                            -- Apply reaction delay
                            if Environment.Locked ~= AimState.lastTarget then
                                AimState.reactionDelay = math.random(
                                    Environment.Settings.ReactionTimeMin * 1000,
                                    Environment.Settings.ReactionTimeMax * 1000
                                ) / 1000
                                AimState.lastTarget = Environment.Locked
                            end
                            
                            if AimState.reactionDelay > 0 then
                                AimState.reactionDelay = AimState.reactionDelay - RunService.RenderStepped:Wait()
                                return
                            end
                            
                            -- Calculate target position with human behavior
                            local currentPos = Camera.CFrame.Position
                            local targetPos = PredictedPosition
                            
                            -- Apply pre-aim offset
                            if Environment.Settings.PreAimOffset > 0 then
                                local preAimDir = (targetPos - currentPos).Unit
                                targetPos = targetPos + (preAimDir * Environment.Settings.PreAimOffset)
                            end
                            
                            -- Simulate human aiming behavior
                            local aimDelta = simulateHumanAiming(currentPos, targetPos)
                            
                            -- Apply mouse acceleration
                            aimDelta = applyAimAcceleration(aimDelta)
                            
                            -- Update fatigue
                            AimState.fatigue = math.min(AimState.fatigue + 0.01, 1)
                            
                            -- Recovery
                            if AimState.fatigue > 0.5 and not AimState.isRecovering then
                                AimState.isRecovering = true
                                delay(Environment.Settings.RecoveryTime, function()
                                    AimState.fatigue = math.max(0, AimState.fatigue - 0.3)
                                    AimState.isRecovering = false
                                end)
                            end
                            
                            -- Apply final movement
                            local finalPos = currentPos + aimDelta
                            if Environment.Settings.MicroPauses and math.random() < 0.1 then
                                wait(math.random(1, 3) / 100) -- Tiny random pauses
                            end
                            
                            Animation = TweenService:Create(Camera, TweenInfo.new(
                                Environment.Settings.LegitSpeed * (1 + math.random(-0.2, 0.2)),
                                Enum.EasingStyle.Sine,
                                Enum.EasingDirection.Out
                            ), {CFrame = CFrame.new(Camera.CFrame.Position, finalPos)})
                            Animation:Play()
                        else
                            if Environment.Settings.Sensitivity > 0 then
                                Animation = TweenService:Create(Camera, TweenInfo.new(Environment.Settings.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(Camera.CFrame.Position, PredictedPosition)})
                                Animation:Play()
                            else
                                Camera.CFrame = CFrame.new(Camera.CFrame.Position, PredictedPosition)
                            end
                        end
					else
						if Environment.Settings.Sensitivity > 0 then
							Animation = TweenService:Create(Camera, TweenInfo.new(Environment.Settings.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(Camera.CFrame.Position, Environment.Locked.Character[Environment.Settings.LockPart].Position)})
							Animation:Play()
						else
							Camera.CFrame = CFrame.new(Camera.CFrame.Position, Environment.Locked.Character[Environment.Settings.LockPart].Position)
						end
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
