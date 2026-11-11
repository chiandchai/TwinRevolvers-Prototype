-- StarterPlayer > StarterPlayerScripts > CombatClient (LocalScript)
-- Hold left mouse while TwinRevolvers is equipped to fire.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local remotes = ReplicatedStorage:WaitForChild("CombatRemotes")
local fireWeapon = remotes:WaitForChild("FireWeapon")
local weaponFeedback = remotes:WaitForChild("WeaponFeedback")

local FIRE_INTERVAL = 0.24
local RANGE = 160

local holding = false
local firing = false
local hand = 0
local equippedTool = nil

local function getEquippedTool()
    local character = player.Character
    if not character then
        return nil
    end

    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Tool") and child:GetAttribute("WeaponClass") == "TwinRevolvers" then
            return child
        end
    end

    return nil
end

local function makeTracer(startPosition, endPosition, color)
    local distance = (endPosition - startPosition).Magnitude
    if distance <= 0 then
        return
    end

    local tracer = Instance.new("Part")
    tracer.Name = "LocalBulletTracer"
    tracer.Anchored = true
    tracer.CanCollide = false
    tracer.CanQuery = false
    tracer.CanTouch = false
    tracer.Material = Enum.Material.Neon
    tracer.Color = color
    tracer.Size = Vector3.new(0.045, 0.045, distance)
    tracer.CFrame = CFrame.lookAt(startPosition, endPosition) * CFrame.new(0, 0, -distance / 2)
    tracer.Parent = workspace
    Debris:AddItem(tracer, 0.055)
end

local function fireOnce()
    local tool = getEquippedTool()
    if not tool then
        return
    end

    local character = player.Character
    local head = character and character:FindFirstChild("Head")
    if not head then
        return
    end

    local targetPosition = mouse.Hit.Position
    local direction = targetPosition - head.Position
    if direction.Magnitude < 0.01 then
        return
    end
    direction = direction.Unit

    hand = 1 - hand
    local color = hand == 0 and Color3.fromRGB(255, 220, 120) or Color3.fromRGB(255, 245, 210)
    local visualEnd = head.Position + direction * RANGE
    makeTracer(head.Position, visualEnd, color)

    fireWeapon:FireServer(tool, direction)
end

local function startFiring()
    if firing then
        return
    end
    firing = true

    task.spawn(function()
        while holding do
            fireOnce()
            task.wait(FIRE_INTERVAL)
        end
        firing = false
    end)
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then
        return
    end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        holding = true
        startFiring()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        holding = false
    end
end)

weaponFeedback.OnClientEvent:Connect(function(data)
    if typeof(data) ~= "table" or typeof(data.Position) ~= "Vector3" then
        return
    end

    -- Small local impact marker. Damage is already handled by the server.
    local marker = Instance.new("Part")
    marker.Name = "LocalImpactMarker"
    marker.Shape = Enum.PartType.Ball
    marker.Size = Vector3.new(0.18, 0.18, 0.18)
    marker.Anchored = true
    marker.CanCollide = false
    marker.CanQuery = false
    marker.CanTouch = false
    marker.Material = Enum.Material.Neon
    marker.Color = data.Headshot and Color3.fromRGB(255, 70, 70)
        or (data.Hit and Color3.fromRGB(255, 220, 90) or Color3.fromRGB(180, 180, 180))
    marker.Position = data.Position
    marker.Parent = workspace
    Debris:AddItem(marker, 0.12)
end)

player.CharacterAdded:Connect(function()
    holding = false
    firing = false
end)
