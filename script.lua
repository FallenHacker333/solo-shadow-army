local soldiers = {}

-- توليد جندي من تحت الأرض
local function summonSoldier(position)
    local soldier = Instance.new("Model")
    soldier.Name = "ShadowSoldier"

    local body = Instance.new("Part")
    body.Name = "Body"
    body.Size = Vector3.new(2, 3, 1)
    body.Position = position - Vector3.new(0, 5, 0)
    body.Anchored = false
    body.BrickColor = BrickColor.new("Really black")
    body.Material = Enum.Material.SmoothPlastic
    body.CanCollide = true
    body.Parent = soldier

    local humanoid = Instance.new("Humanoid")
    humanoid.Parent = soldier

    soldier.PrimaryPart = body
    soldier.Parent = workspace

    for i = 1, 10 do
        body.Position = body.Position + Vector3.new(0, 0.5, 0)
        wait(0.05)
    end

    return soldier
end

-- استدعاء الجنود
for i = 1, 5 do
    local pos = Vector3.new(math.random(-30, 30), 1, math.random(-30, 30))
    table.insert(soldiers, summonSoldier(pos))
end

-- أوامر ذكاء اصطناعي
local function commandFollow(player)
    for _, soldier in pairs(soldiers) do
        spawn(function()
            while true do
                wait(0.5)
                if soldier and soldier.PrimaryPart and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local targetPos = player.Character.HumanoidRootPart.Position
                    soldier.PrimaryPart.CFrame = soldier.PrimaryPart.CFrame:Lerp(CFrame.new(targetPos), 0.1)
                end
            end
        end)
    end
end

local function commandAttackTarget(targetName)
    local target = game.Players:FindFirstChild(targetName)
    if not target or not target.Character then return end
    for _, soldier in pairs(soldiers) do
        spawn(function()
            while target.Character and target.Character:FindFirstChild("HumanoidRootPart") do
                wait(0.3)
                local targetPos = target.Character.HumanoidRootPart.Position
                soldier.PrimaryPart.CFrame = soldier.PrimaryPart.CFrame:Lerp(CFrame.new(targetPos), 0.15)
                if (soldier.PrimaryPart.Position - targetPos).Magnitude < 4 then
                    target.Character:FindFirstChild("Humanoid").Health = 0
                    break
                end
            end
        end)
    end
end

local function commandGather()
    local center = Vector3.new(0, 1, 0)
    for i, soldier in pairs(soldiers) do
        soldier.PrimaryPart.CFrame = CFrame.new(center + Vector3.new(i*3, 0, 0))
    end
end

-- التقاط الشات
game.Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(msg)
        msg = msg:lower()
        if msg == "اتبعني" then
            commandFollow(player)
        elseif msg == "تجمع" then
            commandGather()
        elseif msg:match("^اقتل ") then
            local target = msg:sub(7)
            commandAttackTarget(target)
        elseif msg == "اهجم" then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= player then
                    commandAttackTarget(p.Name)
                end
            end
        end
    end)
end)
