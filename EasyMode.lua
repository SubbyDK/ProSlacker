-- ############################################################
-- ######################### Settings #########################
-- ############ -- DO NOT CHANGE ANYTHING HERE. -- ############
-- ############################################################

-- ######################### General. #########################

local AddonName = "EasyMode"
local Debug = false
local ErrorMessageFilter = false
local LogInTime = GetTime()

-- ########################## Druid. ##########################

-- ########################## Hunter ##########################

-- ########################### Mage ###########################

-- ######################### Paladin. #########################

-- ########################## Priest ##########################

-- ########################## Rogue. ##########################

local lastMessageTime_mainHandExpiration = 0
local lastMessageTime_mainHandCharges = 0
local lastMessageTime_hasMainHandEnchant = 0
local lastMessageTime_offHandExpiration = 0
local lastMessageTime_offHandCharges = 0
local lastMessageTime_hasOffHandEnchant = 0
local lastMessageTime_WindfuryTotem = 0
local LastSeenWindfuryTime = 0
local PrintTime = nil

-- ########################## Shaman ##########################

-- ######################### Warlock. #########################

-- ######################### Warrior. #########################


-- ############################################################
-- ######################### Settings #########################
-- ############# Here you can change all you want #############
-- ############################################################

-- ######################### General. #########################

-- ########################## Druid. ##########################

-- ########################## Hunter ##########################

-- ########################### Mage ###########################

-- ######################### Paladin. #########################

-- ########################## Priest ##########################

-- ########################## Rogue. ##########################

local intPoisonCharges = 10                     -- Warn when there is less then this amount of poison left.
local intPoisonTimeLeft = 180                   -- Warn when there is this amount of time left on poison.
local intPoisonRemainder = 30                   -- How often we want the warning. (in sec)
local intWindfuryWaitTime = 180                 -- How many sec do we want to wait on the Windfury buff.
local strPoisonLowColor = "ff8633"              -- Color for the low count or time on poison.
local strPoisonMissingColor = "ff3333"          -- Color for the missing poison.
local strPoisonApplyingColor = "00FF00"         -- Color for applying poison to weapon. 06c51b

-- ########################## Shaman ##########################

-- ######################### Warlock. #########################

-- ######################### Warrior. #########################


-- ############################################################
-- ####################### Error Filter #######################
-- ############################################################

-- More info here:
-- https://wowpedia.fandom.com/wiki/UI_ERROR_MESSAGE
-- Other good stuff there can be used here:
-- https://wowwiki-archive.fandom.com/wiki/Talk:WoW_constants

local BlackListErrors = {
  [ERR_ABILITY_COOLDOWN] = true,                -- Ability is not ready yet.
  [ERR_ITEM_COOLDOWN] = true,                   -- Item is not ready yet.
  [ERR_BADATTACKPOS] = true,                    -- You are too far away!
  [ERR_OUT_OF_ENERGY] = true,                   -- Not enough energy.
  [ERR_OUT_OF_RANGE] = true,                    -- Out of range.
  [ERR_OUT_OF_RAGE] = true,                     -- Not enough rage.
  [ERR_OUT_OF_FOCUS] = true,                    -- Not enough focus
  [ERR_NO_ATTACK_TARGET] = true,                -- There is nothing to attack.
  [SPELL_FAILED_MOVING] = true,                 -- 
  [SPELL_FAILED_AFFECTING_COMBAT] = true,       -- 
  [ERR_NOT_IN_COMBAT] = true,                   -- You can't do that while in combat
  [SPELL_FAILED_UNIT_NOT_INFRONT] = true,       -- 
  [ERR_BADATTACKFACING] = true,                 -- You are facing the wrong way!
  [SPELL_FAILED_TOO_CLOSE] = true,              -- 
  [ERR_INVALID_ATTACK_TARGET] = true,           -- You cannot attack that target.
  [ERR_SPELL_COOLDOWN] = true,                  -- Spell is not ready yet.
  [SPELL_FAILED_NO_COMBO_POINTS] = true,        -- That ability requires combo points.
  [SPELL_FAILED_TARGETS_DEAD] = true,           -- Your target is dead.
  [SPELL_FAILED_SPELL_IN_PROGRESS] = true,      -- Another action is in progress.
  [SPELL_FAILED_TARGET_AURASTATE] = true,       -- You can't do that yet.
  [SPELL_FAILED_CASTER_AURASTATE] = true,       -- You can't do that yet.
  [SPELL_FAILED_NO_ENDURANCE] = true,           -- Not enough endurance
  [SPELL_FAILED_BAD_TARGETS] = true,            -- Invalid target
  [SPELL_FAILED_NOT_MOUNTED] = true,            -- You are mounted
  [SPELL_FAILED_NOT_ON_TAXI] = true,            -- You are in flight
}

-- ############################################################
-- ############# Create frame and register events #############
-- ############################################################

local f = CreateFrame("Frame")
f:RegisterEvent("UI_ERROR_MESSAGE");

-- ############################################################
-- ###################### Event handler. ######################
-- ############################################################

-- f:SetScript("OnEvent", function(self, event, arg1, arg2, arg3)
f:SetScript("OnEvent", function()
    if (event == "ADDON_LOADED") and (arg1 == AddonName) then
        
        f:UnregisterEvent("ADDON_LOADED");
    -- Fire when we get a red error message on the screen.
    elseif (event == "UI_ERROR_MESSAGE") then
        local errorName = arg1
        -- Check to see if the error was that the target have no pockets.
        if (arg1 == SPELL_FAILED_TARGET_NO_POCKETS) then
            -- Is the table created ?
            if type(MobHasNoPocket) == "table" then
                DEFAULT_CHAT_FRAME:AddMessage("Tabel lavet.");
            else
                DEFAULT_CHAT_FRAME:AddMessage("Ingen tabel.");
                MobHasNoPocket = {}
            end
            -- Insert to table that the mob don't have pockets.
            -- MobHasNoPocket[ERR_INVALID_TARGET] = true
        end
        if (not BlackListErrors[errorName]) then
            UIErrorsFrame:AddMessage(errorName, 1, .1, .1)
        end
    end
end)

-- ############################################################
-- ################# OnUpdate on every frame. #################
-- ############################################################

f:SetScript("OnUpdate",function()

    if ((LogInTime + 3) < GetTime()) and (ErrorMessageFilter == false) then
        UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE");
        DEFAULT_CHAT_FRAME:AddMessage("|cff3333ff" .. AddonName .. " by " .. "|r" .. "|cFF06c51b" .. "Subby" .. "|r" .. "|cff3333ff" .. " is loaded." .. "|r");
        ErrorMessageFilter = true
    end

end)

-- ############################################################
-- ##################### Hunter Auto Shot #####################
-- ############################################################

function HunterAutoAttack()

-- ########## The macro ##########
-- /run -- CastSpellByName("Auto Shoot")
-- /script HunterAutoAttack()

    -- Do we cast fishing and don't fight ?
    if (FishingPoleEquipped() == true) then
        CastSpellByName("Fishing");
        return;
    end

    -- Find a new enermy we can attack.
    if (TargetNewEnemy() == false) then
        return;
    end

    if (CheckInteractDistance("target", 3)) then
        if (not PlayerFrame.inCombat) then
            AttackTarget()
        end
        CastSpellByName("Mongoose Bite")
        CastSpellByName("Raptor Strike")
    else
        if (not IsAutoRepeatAction(4)) then
            CastSpellByName("Auto Shot")
        end
        CastSpellByName("Arcane Shot")
    end
    PetAttack(target)

end

-- ############################################################
-- ######################### Hunter Pet #######################
-- ############################################################

function HunterPet()

-- ########## The macro ##########
-- /run -- CastSpellByName("Feed Pet")
-- /script HunterPet()

    if UnitExists("pet") then
        if UnitHealth("pet") == 0 then
            CastSpellByName("Revive Pet")
        elseif (GetPetHappiness() ~= nil) and (GetPetHappiness() ~= 3) and (not UnitAffectingCombat("pet")) then
            CastSpellByName("Feed Pet") PickupContainerItem(0, 1)
        elseif UnitAffectingCombat("pet") then
            CastSpellByName("Mend Pet")
        else
            CastSpellByName("Dismiss Pet")
        end
    else
        CastSpellByName("Call Pet")
    end

end

-- ############################################################
-- #################### Target new enermy. ####################
-- ############################################################

function TargetNewEnemy()
    -- Do we have a target or maybe a dead target ?
    if (GetUnitName("target") == nil) or (UnitIsDeadOrGhost("target")) then
        -- Target enermy
        TargetNearestEnemy();
        -- Check to see if we have a target now.
        if (GetUnitName("target") ~= nil) then
            -- Find our faction
            local MyFaction = UnitFactionGroup("player"); -- UnitFactionGroup returns either "Alliance", "Horde", "Neutral" or nil. Also works for player pets.
            local TargetFaction = UnitFactionGroup("target");
            -- Check if it's a opposite faction.
            if ((MyFaction == "Horde") and (TargetFaction == "Alliance")) or ((MyFaction == "Alliance") and (TargetFaction == "Horde")) then
                -- Do we both have PVP enabled ? If so, then we attack, else we clear target.
                if (UnitIsPVP("target")) and (UnitIsPVP("player")) then
                    return true
                else
                    ClearTarget();
                    return false
                end
            end
            return true
        end
        return false
    end
end

-- ############################################################
-- ###################### Rogue Rotation ######################
-- ############################################################

function RogueAttack()

-- ########## The macro ##########
-- /run -- CastSpellByName("Sinister Strike")
-- /script RogueAttack()

    -- Do we cast fishing and don't fight ?
    if (FishingPoleEquipped() == true) then
        CastSpellByName("Fishing");
        return;
    end

    -- Find a new enermy we can attack.
    if (TargetNewEnemy() == false) then
        return;
    end

    -- 
    local icon, name, StealthActive, castable = GetShapeshiftFormInfo(1);
    if (StealthActive == 1) then
        -- 1 = Compare Achievements, 28 yards - 2 = Trade, 8 yards - 3 = Duel, 7 yards - 4 = Follow, 28 yards - 5 = Pet-battle Duel, 7 yards
        if (CheckInteractDistance("target", 3)) and (strPickPocketDone ~= true) and (GetUnitName("target") ~= nil) then
            CastSpellByName("Pick Pocket");
            strPickPocketDone = true
        else
            if (CheckIfSpellIsKnown("Cheap Shot", 0) == true) then
                CastSpellByName("Cheap Shot");
            else
                CastSpellByName("Sinister Strike");
            end
            strPickPocketDone = false
        end
    else
        -- Set it to false so we are sure we pick pocket next time.
        strPickPocketDone = false
    end

    SnD = false
    for i = 1, 64, 1 do
        db = UnitBuff("player",i)
        if ((db ~= nil) and (string.find(db,"Interface\\Icons\\Ability_Rogue_SliceDice"))) then
            SnD = true
        end
    end
    if (GetComboPoints("target") == 5) then
        CastSpellByName("Eviscerate");
    elseif (SnD == true) then
        CastSpellByName("Surprise Attack");
        CastSpellByName("Riposte");
        CastSpellByName("Sinister Strike");
    elseif (GetComboPoints("target") == 0) then
        CastSpellByName("Riposte");
        CastSpellByName("Sinister Strike");
    else
        -- Have we learned Slice and Dice yet ?
        if (CheckIfSpellIsKnown("Slice and Dice", 0) == true) then
            CastSpellByName("Slice and Dice");
        else
            CastSpellByName("Sinister Strike");
        end
    end

    -- Start auto attack if we are not stealth.
    if (StealthActive ~= 1) then
        -- Make sure we start auto attack, even if we don't have enough energy, but only if we are not stealth.
        if (not PlayerFrame.inCombat) then 
            AttackTarget()
        end
    end

    -- Do we even know poison yet ? No reason to spam that we need it, if we can't make it yet.
    if (CheckIfSpellIsKnown("Poisons", 0) ~= true) then
        if (Debug == true) then
            DEFAULT_CHAT_FRAME:AddMessage("We don't know Poisons.");
        end
        return
    end

    -- Do we have poison on our weapons ?
    hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration, offHandCharges = GetWeaponEnchantInfo();

    -- If we don't have a Shaman buffing with Windfury ?
    if (WindfuryFromShaman() == false) then
        -- Check main-hand enchant status
        if hasMainHandEnchant then
            -- Is it running out on time ?
            if mainHandExpiration / 1000 <= intPoisonTimeLeft then
                if GetTime() - lastMessageTime_mainHandExpiration >= intPoisonRemainder then
                    lastMessageTime_mainHandExpiration = GetTime()
                    DEFAULT_CHAT_FRAME:AddMessage("|cff" .. strPoisonLowColor .. "Main-hand poison is expiring. - Reapply soon." .. "|r")
                end
            end
            -- Is it running out due to amount of charges ?
            if mainHandCharges < intPoisonCharges then
                if GetTime() - lastMessageTime_mainHandCharges >= intPoisonRemainder then
                    lastMessageTime_mainHandCharges = GetTime()
                    DEFAULT_CHAT_FRAME:AddMessage("|cff" .. strPoisonLowColor .. "Main-hand poison is low on charges. - Reapply soon." .. "|r")
                end
            end
        -- We are missing poison on Main-hand.
        else
            if GetTime() - lastMessageTime_hasMainHandEnchant >= intPoisonRemainder then
                lastMessageTime_hasMainHandEnchant = GetTime()
                DEFAULT_CHAT_FRAME:AddMessage("|cff" .. strPoisonMissingColor .. ">> MISSING POISON - MAIN-HAND <<" .. "|r")
            end
        end
    end

    -- Check off-hand enchant status
    if hasOffHandEnchant then
        -- Is it running out on time ?
        if offHandExpiration / 1000 <= intPoisonTimeLeft then
            if GetTime() - lastMessageTime_offHandExpiration >= intPoisonRemainder then
                lastMessageTime_offHandExpiration = GetTime()
                DEFAULT_CHAT_FRAME:AddMessage("|cff" .. strPoisonLowColor .. "Off-hand poison is expiring. - Reapply soon." .. "|r")
            end
        end
        -- Is it running out due to amount of charges ?
        if offHandCharges < intPoisonCharges then
            if GetTime() - lastMessageTime_offHandCharges >= intPoisonRemainder then
                lastMessageTime_offHandCharges = GetTime()
                DEFAULT_CHAT_FRAME:AddMessage("|cff" .. strPoisonLowColor .. "Off-hand poison is low on charges. - Reapply soon." .. "|r")
            end
        end
    -- We are missing poison on Off-hand.
    else
        if ((GetTime() - lastMessageTime_hasOffHandEnchant) >= intPoisonRemainder) then
            lastMessageTime_hasOffHandEnchant = GetTime()
            DEFAULT_CHAT_FRAME:AddMessage("|cff" .. strPoisonMissingColor .. ">> MISSING POISON - OFF-HAND <<" .. "|r")
        end
    end

end

-- ############################################################
-- #### Is someone in the group there is buffing Windfury? ####
-- ############################################################

function WindfuryFromShaman()
    -- Set some locals
    local partyMembers = GetNumPartyMembers()   -- Get group numbers
    local strShamanFound = false

    -- Are we even in a group ?
    if (partyMembers > 0) then
        -- Do we have a Shaman in our group ? No need to check whole raid as Windfury is only for party.
        for i = 1, 4 do
            local unitName, unitClass = UnitName("party" .. i), UnitClass("party" .. i)
            -- Check if we have a name and it's a Shaman.
            if (unitName) and (string.lower(unitClass) == "shaman") then
                if (Debug == true) then
                    DEFAULT_CHAT_FRAME:AddMessage("We have a Shaman in our party.")
                end
                strShamanFound = true
            end
            i = i + 1
        end

        -- Did we have a Shaman in our group ?
        if (strShamanFound == true) then
            -- Is the Shaman buffing with Windfury ?
            for i = 1, 64 do
                -- Get the icon name of the buff
                local name = UnitBuff("player", i)
                -- Debug.
                if (Debug == true) then
                    if (name) then
                        DEFAULT_CHAT_FRAME:AddMessage("The icon we found: " .. name)
                    end
                end
                -- Is it the icon for Windfury ?
                if (name) and (string.find(name, "Interface\\Icons\\spell_nature_windfury")) then
                    if (Debug == true) then
                        DEFAULT_CHAT_FRAME:AddMessage("We found the \"Windfury Totem Effect\" buff.")
                    end
                    DEFAULT_CHAT_FRAME:AddMessage("We found the \"Windfury Totem Effect\" buff.")
                    LastSeenWindfuryTime = GetTime()
                    return true
                end
                i = i + 1
            end
            -- We don't have the Windfury buff, maybe the Shaman just need some time to get the totem down.
            if (LastSeenWindfuryTime > 0) then
                if ((GetTime() - LastSeenWindfuryTime) > intWindfuryWaitTime) then
                    -- Set a delay on the message so we don't spam the chat.
                    if GetTime() - lastMessageTime_WindfuryTotem >= intPoisonRemainder then
                        -- 
                        local elapsedTime = (GetTime() - LastSeenWindfuryTime)
                        -- 
                        local hour = math.floor((elapsedTime / 3600))
                        -- 
                        local minutes = math.floor((elapsedTime / 60) - (hour * 3600))
                        -- 
                        local seconds = math.floor(elapsedTime - (minutes * 60))
                        -- 
                        if (hour > 0) and ((minutes >= 0) and (minutes <= 9)) then
                            minutes = "0" .. minutes
                        end
                        -- 
                        if (seconds >= 0) and (seconds <= 9) then
                            seconds = "0" .. seconds
                        end
                        -- 
                        if (hour == 0) and (tonumber(minutes) == 0) then
                            DEFAULT_CHAT_FRAME:AddMessage("1")
                            PrintTime = seconds .. "sec"
                        elseif (hour == 0) then
                            DEFAULT_CHAT_FRAME:AddMessage("2")
                            PrintTime = minutes .. "min " .. seconds .. "sec"
                        else
                            DEFAULT_CHAT_FRAME:AddMessage("3")
                            PrintTime = hour .. "hour " .. minutes .. "min " .. seconds .. "sec"
                        end
                        -- Print a message that we are missing Windfury,
                        DEFAULT_CHAT_FRAME:AddMessage("|cff" .. strPoisonMissingColor .. "Windfury missing for " .. PrintTime .. ", consider using poison." .. "|r")
                        -- 
                        lastMessageTime_WindfuryTotem = GetTime()
                    end
                    -- DEFAULT_CHAT_FRAME:AddMessage("Totem should be down now, GET IT DOWN...")
                    return false
                -- Totem is not down, let's give the person some time to get it down.
                else
                    return true
                end
            -- No timer for last totem set yet, so we set it.
            else
                LastSeenWindfuryTime = GetTime()
                return true
            end
        -- We don't have a Shaman in our group.
        else
            if (Debug == true) then
                DEFAULT_CHAT_FRAME:AddMessage("We don't have a Shaman in our party.")
            end
        end
        return false
    -- We are not in a group.
    else
        if (Debug == true) then
            DEFAULT_CHAT_FRAME:AddMessage("We are not in a group.")
        end
        return false
    end
end

-- ############################################################
-- ################### Do we know the spell ###################
-- ############################################################

function CheckIfSpellIsKnown(spellName, rank)
    local i = 1
    local SearchSpell = string.gsub(spellName, "%s+", "")
    local SearchRank = rank

    -- Did we get anything ?
    if (not SearchSpell) then
        if (Debug == true) then
            DEFAULT_CHAT_FRAME:AddMessage("Spell is missing, check your function call.")
        end
        return
    end
    if (not SearchRank) then
        if (Debug == true) then
            DEFAULT_CHAT_FRAME:AddMessage("Rank is missing, check your function call.")
        end
        return
    end

    -- Loop through our spell book to find the spell and rank we are looking for.
    while true do
        local currentSpellName, currentSpellRank = GetSpellName(i, "spell");
        if (not currentSpellName) then
            if (Debug == true) then
                DEFAULT_CHAT_FRAME:AddMessage("No more found in the spell book.")
            end
            break
        end

        -- Remove stuff we are not looking for.
        currentSpellName = string.gsub(currentSpellName, "%s+", "")
        currentSpellRank = string.gsub(currentSpellRank, "Rank%s+", "")

        if string.find(currentSpellName, SearchSpell) then
            if (Debug == true) then
                DEFAULT_CHAT_FRAME:AddMessage("We found " .. currentSpellName .. " and it was the one we was looking for.")
            end
            -- Did we get the currentSpellRank there was not nil ?
            if (currentSpellRank ~= nil) then
                if (Debug == true) then
                    DEFAULT_CHAT_FRAME:AddMessage("currentSpellRank was not nil, it was: " .. currentSpellRank)
                end
                -- Some spells don't have a rank, if that is the case here, then we change it to 0
                if (currentSpellRank == nil) or (currentSpellRank == "") then
                    currentSpellRank = 0
                end
                -- The reason we use <= and not == here is that if we know rank 4 we also know rank 2.
                -- For Rogues for example, when you learn a new rank, the old rank is "removed" from the spellbook.
                if (tonumber(SearchRank) <= tonumber(currentSpellRank)) then
                    if (Debug == true) then
                        DEFAULT_CHAT_FRAME:AddMessage("Rank found for " .. currentSpellName .. " so we return true for " .. currentSpellName .. " (Rank " .. currentSpellRank .. ")")
                    end
                    return true
                -- Rank we was looking for is to high, so we return false.
                else
                    if (Debug == true) then
                        DEFAULT_CHAT_FRAME:AddMessage("Rank we was looking is higher then what we found. We was looking for " .. SearchRank .. " but only got " .. currentSpellRank)
                    end
                    return false
                end
                
            elseif (currentSpellRank == nil) or (currentSpellRank == "") then
                if (Debug == true) then
                    DEFAULT_CHAT_FRAME:AddMessage("Rank for " .. currentSpellName .. " is nil or empty, so we just return true as it have no rank.")
                end
                return true
            else
                if (Debug == true) then
                    DEFAULT_CHAT_FRAME:AddMessage("Something with the rank went wrong for the spell " .. currentSpellName .. ".")
                    DEFAULT_CHAT_FRAME:AddMessage("We was looking for \"" .. SearchRank .. "\" and we got \"" .. currentSpellRank .. "\".")
                end
            end
        end
        i = i + 1
        if (Debug == true) then
            DEFAULT_CHAT_FRAME:AddMessage(currentSpellName .. " (" .. currentSpellRank .. ")")
        end
    end
    if (Debug == true) then
        DEFAULT_CHAT_FRAME:AddMessage(SearchSpell .. " (" .. SearchRank .. ") was not found in the spellbook.")
    end
    return false
end

-- ############################################################
-- ###################### Slash commands ######################
-- ############################################################

SLASH_EASYMODE1, SLASH_EASYMODE2 = "/easymode", "/em"
function SlashCmdList.EASYMODE(msg)
    if (msg == nil) or (msg == "") then
        DEFAULT_CHAT_FRAME:AddMessage("Du skrev ikke noget.")
    else
        DEFAULT_CHAT_FRAME:AddMessage("Du skrev: " .. msg)
    end
end

-- ############################################################
-- ####################### Rogue Poison #######################
-- ############################################################


function RoguePoison()

-- ########## The macro ##########
-- /run -- use Instant Poison IV
-- /script RoguePoison()

    -- Function to apply a specific poison to a given weapon slot
    local function ApplyPoison(slot, poisonName)
        local poisonCount = 0
        for bag = 4, 0, -1 do
            for slotNum = GetContainerNumSlots(bag), 1, -1 do
                local itemLink = GetContainerItemLink(bag, slotNum)
                if itemLink and string.find(itemLink, poisonName) then
                    local _, count = GetContainerItemInfo(bag, slotNum)
                    poisonCount = poisonCount + count
                    UseContainerItem(bag, slotNum)
                end
            end
        end

        -- If we found the poison, apply it to the specified weapon slot
        if poisonCount > 0 then
            PickupInventoryItem(slot)
            ReplaceEnchant()
            ClearCursor()
            local weaponSlotName = slot == 16 and "Main-hand" or "Off-hand"
            DEFAULT_CHAT_FRAME:AddMessage("|cff" .. strPoisonApplyingColor .. "Applying " .. poisonName .. " to " .. weaponSlotName .. ". - " .. (poisonCount - 1) .. " remaining." .. "|r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("You have no " .. poisonName .. ". Create some more!")
        end
    end

    -- Get current weapon enchant information
    local hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration, offHandCharges = GetWeaponEnchantInfo()

    -- Check for key presses
    local isCtrlDown = IsControlKeyDown()
    local isShiftDown = IsShiftKeyDown()
    local isAltDown = IsAltKeyDown()

    -- Apply poison based on key combinations
    if isCtrlDown or isShiftDown and not isAltDown then
        ApplyPoison(isCtrlDown and 16 or 17, "Deadly Poison")
    elseif isAltDown and (isCtrlDown or isShiftDown) then
        ApplyPoison(isCtrlDown and 16 or 17, "Instant Poison")
    else
        -- Apply Instant Poison if needed
        if hasOffHandEnchant and (offHandExpiration / 1000 <= intPoisonTimeLeft or offHandCharges < intPoisonCharges) then
            ApplyPoison(17, "Instant Poison")
        elseif not hasOffHandEnchant then
            ApplyPoison(17, "Instant Poison")
        elseif hasMainHandEnchant and (mainHandExpiration / 1000 <= intPoisonTimeLeft or mainHandCharges < intPoisonCharges) then
            ApplyPoison(16, "Instant Poison")
        elseif not hasMainHandEnchant then
            ApplyPoison(16, "Instant Poison")
        end
    end
end

-- ############################################################
-- ##################### Rogue Pickpocket #####################
-- ############################################################

function PickpocketTarget()

-- ########## The macro ##########
-- /run -- CastSpellByName("Pick Pocket")
-- /script PickpocketTarget()

    -- Target a new enemy
    TargetNearestEnemy();

    -- Check if the target is valid and within range
    if UnitExists("target") and CheckInteractDistance("target", 3) then
        -- Pickpocket the target
        CastSpellByName("Pick Pocket");
        -- Clear the target
        ClearTarget();
    end
end

-- ############################################################
-- ################# Is Fishing Pole Equipped #################
-- ############################################################

function FishingPoleEquipped()
    local Pole = GetInventoryItemTexture("player", GetInventorySlotInfo("MainHandSlot"));
    if (Pole and string.find(Pole, "INV_Fishingpole")) then
        return true
    end
end

-- ############################################################
-- ###################### Priest healing ######################
-- ###################### NOT TESTED YET ######################
-- ############################################################

-- =Inner Focus + Flash Heal + Heal=-
function PriestHeal()

-- ########## The macro ##########
-- /run -- CastSpellByName("Healing Wave")
-- /script PriestHeal()

    local UL, UM, NS, UT, AH = UnitLevel, UnitMana, "Healing Wave";
    local function GotSpell(spell,rank)
        local ix, spellName, spellRank;
        if not spell then
            spell = "Inner Focus";
            rank = "";
        end;
        for ix = 1, 200 do
            spellName, spellRank = GetSpellName(ix,"spell")
            if spellName == nil then
                return;
            else
                if spellName == spell and spellRank == rank then
                    if GetSpellCooldown(ix, "spell") == 0 then
                        return true;
                    else
                        return;
                    end;
                end;
            end;
        end;
    end;
    local function BIF()
        return buffed("Inner Focus") == "buff"
    end;
    if UL("target") == 0 or UnitCanAttack("player","target") then
        UT = "player";
    else
        UT = "target";
    end;
    AH = UnitHealthMax(UT)-UnitHealth(UT);
    if not IsAltKeyDown() or BIF() or not GotSpell() then
        if UnitHealth(UT)>(UnitHealthMax(UT)*0.25) then
            if UL("player")>59 and ((UM("player")>709) or BIF()) and AH>1966 and GotSpell("Greater Heal","Rank 5") then
                CastSpellByName("Greater Heal(Rank 5)");
            else
                if UL("player")>57 and ((UM("player")>654) or BIF()) and AH>1798 and GotSpell("Greater Heal","Rank 4") then
                    CastSpellByName("Greater Heal(Rank 4)");
                else
                    if UL("player")>51 and ((UM("player")>544) or BIF()) and AH>1437 and GotSpell("Greater Heal","Rank 3") then
                        CastSpellByName("Greater Heal(Rank 3)");
                    else
                        if UL("player")>45 and ((UM("player")>454) or BIF()) and AH>1149 and GotSpell("Greater Heal","Rank 2") then
                            CastSpellByName("Greater Heal(Rank 2)");
                        else
                            if UL("player")>39 and ((UM("player")>369) or BIF()) and AH>899 and GotSpell("Greater Heal","Rank 1") then
                                CastSpellByName("Greater Heal(Rank 1)");
                            else
                                if UL("player")>33 and ((UM("player")>304) or BIF()) and AH>712 and GotSpell("Heal","Rank 4") then
                                    CastSpellByName("Heal(Rank 4)");
                                else
                                    if UL("player")>27 and ((UM("player")>254) or BIF()) and AH>566 and GotSpell("Heal","Rank 3") then
                                        CastSpellByName("Heal(Rank 3)");
                                    else
                                        if UL("player")>21 and ((UM("player")>204) or BIF()) and AH>429 and GotSpell("Heal","Rank 2") then
                                            CastSpellByName("Heal(Rank 2)");
                                        else
                                            if UL("player")>15 and ((UM("player")>154) or BIF()) and AH>295 and GotSpell("Heal","Rank 1") then
                                                CastSpellByName("Heal(Rank 1)");
                                            else
                                                if UL("player")>9 and ((UM("player")>74) or BIF()) and AH>135 and GotSpell("Lesser Heal","Rank 3") then
                                                    CastSpellByName("Lesser Heal(Rank 3)");
                                                else
                                                    if UL("player")>3 and ((UM("player")>44) or BIF()) and AH>71 and GotSpell("Lesser Heal","Rank 2") then
                                                        CastSpellByName("Lesser Heal(Rank 2)");
                                                    else
                                                        if UL("player")>0 and ((UM("player")>29) or BIF()) and AH>46 and GotSpell("Lesser Heal","Rank 1") then
                                                            CastSpellByName("Lesser Heal(Rank 1)");
                                                        else
                                                            CastSpellByName("Lesser Heal(Rank 1)");
                                                        end;
                                                    end;
                                                end;
                                            end;
                                        end;
                                    end;
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        else
            if UL("player")>55 and ((UM("player")>379) or BIF()) and AH>812 and GotSpell("Flash Heal","Rank 7") then
                CastSpellByName("Flash Heal(Rank 7)");
            else
                if UL("player")>49 and ((UM("player")>314) or BIF()) and AH>644 and GotSpell("Flash Heal","Rank 6") then
                    CastSpellByName("Flash Heal(Rank 6)");
                else
                    if UL("player")>44 and ((UM("player")>264) or BIF()) and AH>518 and GotSpell("Flash Heal","Rank 5") then
                        CastSpellByName("Flash Heal(Rank 5)");
                    else
                        if UL("player")>37 and ((UM("player")>214) or BIF()) and AH>400 and GotSpell("Flash Heal","Rank 4") then
                            CastSpellByName("Flash Heal(Rank 4)");
                        else
                            if UL("player")>31 and ((UM("player")>157) or BIF()) and AH>327 and GotSpell("Flash Heal","Rank 3") then
                                CastSpellByName("Flash Heal(Rank 3)");
                            else
                                if UL("player")>25 and ((UM("player")>154) or BIF()) and AH>258 and GotSpell("Flash Heal","Rank 2") then
                                    CastSpellByName("Flash Heal(Rank 2)");
                                else
                                    if UL("player")>19 and ((UM("player")>124) or BIF()) and AH>193 and GotSpell("Flash Heal","Rank 1") then
                                        CastSpellByName("Flash Heal(Rank 1)");
                                    else
                                        CastSpellByName("Lesser Heal(Rank 1)");
                                    end;
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    else
        CastSpellByName("Inner Focus");
    end;
end

-- ############################################################
-- ######### Get a name on what is what button number #########
-- ############################################################

function reportActionButtons()
	local lActionSlot = 0;
	for lActionSlot = 1, 120 do
		local lActionText = GetActionText(lActionSlot);
		local lActionTexture = GetActionTexture(lActionSlot);
		if lActionTexture then
			local lMessage = "Slot " .. lActionSlot .. ": [" .. lActionTexture .. "]";
			if lActionText then
				lMessage = lMessage .. " \"" .. lActionText .. "\"";
			end
			DEFAULT_CHAT_FRAME:AddMessage(lMessage);
        end
	end
end

-- ############################################################
-- ###################### Warrior attack ######################
-- ############################################################

function WarriorAttack()

-- ########## The macro ##########
-- /run -- CastSpellByName("Heroic Strike")
-- /script WarriorAttack()

    -- Har vi et target som er dødt ?
    if UnitExists("target") and UnitIsDead("target") then
        -- Fjern target
        ClearTarget();
    end
    -- Er target navn = nil ? (Er kun nil hvis der ikke er et target)
    if GetUnitName("target") == nil then
        -- Target nærmeste fjende.
        TargetNearestEnemy()
    end
    -- Er vi i combat ?
    if (not PlayerFrame.inCombat) then
        -- Start attact
        AttackTarget()
    end
    -- Charge fjenden
    CastSpellByName("Charge");
    -- locals
    local i, x = 1, 0
    -- Loop gennem alle debuff på target.
    while UnitDebuff("target",i) do
        -- Hvis debuff icon er samme som icon som Rend
        if UnitDebuff("target",i) == "Interface\\Icons\\Ability_Gouge" then
            -- X = 1 så vi ved vi fandt det debuff på target.
            x = 1
        end
        -- Bare en tæller så vi når gennem alle debuff på target.
        i = i + 1
    end
    -- Locals
    local IsShiftDown = IsShiftKeyDown()
    -- Er x = 0 (Ingen Rend på target) og er targets liv over 50%
    if (x == 0) and (UnitHealth("target")/UnitHealthMax("target") > 0.5) then
        -- Var shift nede ?
        if (not IsShiftDown) then
            -- Cast Rend
            CastSpellByName("Rend")
        end
    end
    -- Locals
    local hasBuff = false
    -- Loop gennem egene buff
    for i = 1, 64 do
        -- Led efter Battle Shout
        if UnitBuff("player",i) and strfind(UnitBuff("player",i),"Warrior_BattleShout") then
            -- Vi fandt Battle Shout
            hasBuff = true
            -- Stop loop
            break
        end
    end
    -- Vi fandt ikke Battle Shout
    if not hasBuff then
        -- Cast Battle Shout
        CastSpellByName("Battle Shout");
    end
    -- Cast Bloodthirst
    CastSpellByName("Bloodthirst");
    -- Cast Bloodrage
    CastSpellByName("Bloodrage");
    -- Cast Overpower
    CastSpellByName("Overpower");

end


































