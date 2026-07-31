local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local Config = {
    PurchaseIdleWindow = 3,     -- seconds with no new purchases before buy phase is considered done
    NoPurchaseTimeout = 10,     -- if nothing is bought at all, hop anyway
    CompletionTimeout = 60,     -- fallback in case a pet gets stuck
    CheckInterval = 0.25
}

local trackedPets = {}
local trackedSet = {}
local purchaseCount = 0
local lastPurchaseTime = tick()
local firstSeenTime = tick()

local function addTrackedPet(model)
    if not model or trackedSet[model] then return end
    trackedSet[model] = true
    table.insert(trackedPets, model)
    purchaseCount = purchaseCount + 1
    lastPurchaseTime = tick()
end

local function getPetModelFromPrompt(prompt)
    if not prompt then return nil end
    local model = prompt:FindFirstAncestorOfClass("Model")
    if model then return model end
    local parent = prompt.Parent
    if parent and parent:IsA("Model") then return parent end
    return nil
end

local promptConnection
promptConnection = ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
    if player == LocalPlayer then
        local petModel = getPetModelFromPrompt(prompt)
        if petModel then
            addTrackedPet(petModel)
        end
    end
end)

local function allTrackedPetsFinished()
    for _, pet in ipairs(trackedPets) do
        -- If the pet model is still in the Workspace, it's still walking
        if pet and pet:IsDescendantOf(Workspace) then
            return false
        end
    end
    return true
end

task.spawn(function()
    -- 1. Wait to see if we buy anything
    repeat
        task.wait(Config.CheckInterval)
    until purchaseCount > 0 or (tick() - firstSeenTime) >= Config.NoPurchaseTimeout

    -- 2. If dead server, shut down early (completely skips dropping)
    if purchaseCount == 0 then
        if promptConnection then promptConnection:Disconnect() end
        game:Shutdown()
        return
    end

    -- 3. Wait until SpeedhubX stops buying things (3 seconds of silence)
    repeat
        task.wait(Config.CheckInterval)
    until (tick() - lastPurchaseTime) >= Config.PurchaseIdleWindow

    if promptConnection then
        promptConnection:Disconnect()
    end

    -- 4. DROP THE PETS IMMEDIATELY! 
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/jakebonds110/PetGuildEvent/refs/heads/main/AutoDropPet.lua", true))()
    end)
    
    task.wait(3)

    -- 5. Now we watch them walk! As soon as they leave Workspace, we shut down.
    local completionStart = tick()
    repeat
        task.wait(0.5)
    until allTrackedPetsFinished() or (tick() - completionStart) >= Config.CompletionTimeout

    -- CREATE THE SIGNAL FILE FOR PYTHON
    pcall(function()
        local signalFileName = LocalPlayer.Name .. "_done.txt"
        writefile(signalFileName, "HOP NOW")
    end)
    
    -- We can still try to shutdown just to be safe
    game:Shutdown()
end)
