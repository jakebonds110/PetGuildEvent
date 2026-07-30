local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer

-- ==========================================
-- 1. CONFIGURATION (Edit this before running)
-- ==========================================
local Config = {
    DropAmountLimit = 10,   
    
    DropAnyPet = false,     
    PetsToDrop = {
        ["Bunny"] = true,
        ["Deer"] = true,
        ["Frog"] = true,
        ["Owl"] = true,
    },
    
    Rarity = "None",        
    Size = "None"           
}
-- ==========================================

-- ==========================================
-- 2. AUTO-DROP LOGIC (Runs once immediately)
-- ==========================================
local function DropPets()
    local character = player.Character
    local backpack = player:FindFirstChild("Backpack")
    
    if not character or not backpack then 
        return 
    end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then 
        return 
    end

    local droppedCount = 0
    local items = backpack:GetChildren()

    for index, item in ipairs(items) do
        if humanoid.Health <= 0 then break end
        
        if item:IsA("Tool") then
            -- FILTER CHECKS
            local isPetInList = Config.PetsToDrop[item.Name] == true
            local nameMatch = Config.DropAnyPet or isPetInList
            
            local itemRarity = item:FindFirstChild("Rarity") and item.Rarity.Value or "None"
            local rarityMatch = (Config.Rarity == "None" or itemRarity == Config.Rarity)
            
            local itemSize = item:FindFirstChild("Size") and item.Size.Value or "None"
            local sizeMatch = (Config.Size == "None" or itemSize == Config.Size)
            
            -- IF ALL CONDITIONS MET -> DROP
            if nameMatch and rarityMatch and sizeMatch then
                
                humanoid:EquipTool(item)
                task.wait(0.4) 
                
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Backspace, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Backspace, false, game)
                
                task.wait(0.4) 
                
                droppedCount = droppedCount + 1
                
                if Config.DropAmountLimit > 0 and droppedCount >= Config.DropAmountLimit then
                    break
                end
            end
        end
        
        if index % 20 == 0 then
            task.wait() 
        end
    end
end

DropPets()
