function AddCommaToNum(amount)
    local formatted = amount
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k==0) then break end
    end
    return formatted
end

function BonusRollCompleted()
    local quests = { 52834, 52838, 52837, 52840, 52835, 52839 }
    local count  = 0
    
    for _, i in pairs(quests) do
        if IsQuestFlaggedCompleted(i) then count = count + 1 end        
    end
    
    return count
end

function ChatMessageLootInfo(msg)
    if not msg then return end
    
    local unit = msg:match("^[a-zA-Z-]+") == "You" and UnitName("player") or msg:match("^[a-zA-Z-]+")
    local itemLink  = msg:match("%|c.*%[.*%]%|h%|r")
    local itemName  = itemLink:match("%[.*%]"):gsub("[%[%]]", "")
    local itemID    = itemLink:match("%|Hitem%:[0-9]+%:"):match("%d+")
    local itemCount = (msg:match("x%d+%.") or "1"):match("%d+")
    
    return unit, itemID, itemName, itemLink, itemCount
end

function CheckBagForItem(itemID)
    if not itemID then return end
    for bag=0, NUM_BAG_SLOTS do
        for slot=1, GetContainerNumSlots(bag) do
            if GetContainerItemID(bag, slot) == itemID then return bag, slot end
        end
    end
end

function GetItemLink(itemID)
    if not itemID then return "nil"
    else return select(2,GetItemInfo(itemID)) end
end

function GroupType(isChat)
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then return "instance_chat"
    elseif UnitInRaid("player") then return "raid"
    elseif UnitInParty("player") then return "party"
    elseif isChat then return "say"
    else return "none" end
end

function IsAzeriteEquipped()
    local isEquipped = C_AzeriteItem.HasActiveAzeriteItem()
    local slot       = C_AzeriteItem.FindActiveAzeriteItem()
    
    if isEquipped and slot.equipmentSlotIndex == 2 then return true
    else return false end
end

function IsUnitInGuild(unit)
    if not unit then return false end
    local t  = GetNumGuildMembers() or 0
    for i=1, t do
        if unit == GetGuildRosterInfo(i) then return true end
    end
    return false
end

function UnitInGroup(unit)
    if not unit then unit = UnitName("player") end
    if UnitInRaid(unit) or UnitInParty(unit) then return true
    else return false end
end

