-- ServerScriptService > CombatServer (Script)
-- Server-authoritative single-target prototype for a game you own.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponConfig = require(ReplicatedStorage:WaitForChild("WeaponConfig"))

local remotes = ReplicatedStorage:FindFirstChild("CombatRemotes")
if not remotes then
    remotes = Instance.new("Folder")
    remotes.Name = "CombatRemotes"
    remotes.Parent = ReplicatedStorage
end

local fireWeapon = remotes:FindFirstChild("FireWeapon")
if not fireWeapon then
    fireWeapon = Instance.new("RemoteEvent")
    fireWeapon.Name = "FireWeapon"
    fireWeapon.Parent = remotes
end

local weaponFeedback = remotes:FindFirstChild("WeaponFeedback")
if not weaponFeedback then
    weaponFeedback = Instance.new("RemoteEvent")
    weaponFeedback.Name = "WeaponFeedback"
    weaponFeedback.Parent = remotes
end

local lastShotAt = {}

local function getEquippedWeapon(player, tool)
    local character = player.Character
    if not character or not tool or tool.Parent ~= character then
        return nil
    end

    if tool:GetAttribute("WeaponClass") ~= "TwinRevolvers" then
        return nil
    end

    return WeaponConfig.TwinRevolvers
end

local function findMythFromHit(hitInstance)
    local mythsFolder = workspace:FindFirstChild("Myths")
    if not mythsFolder or not hitInstance then
        return nil
    end

    local current = hitInstance
    while current and current ~= mythsFolder do
        if current:IsA("Model") and current.Parent == mythsFolder then
            local humanoid = current:FindFirstChildOfClass("Humanoid")
            if humanoid then
                return current, humanoid
            end
        end
        current = current.Parent
    end

    return nil
end

fireWeapon.OnServerEvent:Connect(function(player, tool, aimDirection)
    local config = getEquippedWeapon(player, tool)
    if not config then
        return
    end

    if typeof(aimDirection) ~= "Vector3" then
        return
    end

    local magnitude = aimDirection.Magnitude
    if magnitude < 0.9 or magnitude > 1.1 then
        return
    end

    local now = os.clock()
    local previous = lastShotAt[player] or 0
    if now - previous < config.FireInterval then
        return
    end
    lastShotAt[player] = now

    local character = player.Character
    local head = character and character:FindFirstChild("Head")
    if not head then
        return
    end

    local direction = aimDirection.Unit
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { character }
    params.IgnoreWater = true

    local result = workspace:Raycast(head.Position, direction * config.Range, params)
    local hitPosition = head.Position + direction * config.Range
    local didHit = false
    local wasHeadshot = false

    if result then
        hitPosition = result.Position
        local _, humanoid = findMythFromHit(result.Instance)
        if humanoid and humanoid.Health > 0 then
            wasHeadshot = result.Instance.Name == "Head"
            humanoid:TakeDamage(wasHeadshot and config.HeadDamage or config.BodyDamage)
            didHit = true
        end
    end

    weaponFeedback:FireClient(player, {
        Hit = didHit,
        Headshot = wasHeadshot,
        Position = hitPosition,
    })
end)

Players.PlayerRemoving:Connect(function(player)
    lastShotAt[player] = nil
end)
