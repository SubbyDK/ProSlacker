-- ====================================================================================================
-- =                                             Settings                                             =
-- =                                -- DO NOT CHANGE ANYTHING HERE. --                                =
-- ====================================================================================================

-- ============================================= General. =============================================

local AddonName = "ProSlacker"                  -- The name of the addon, just so it's easy to reuse code.
local ErrorMessageFilter = false                -- Turns true when filter are turned on.
local LogInTime = GetTime()                     -- 
local RecruitTime = GetTime()                   -- 
local StopGuildRecruit = false                  -- For stopping recruitment if we are AFK or DND
local strDND = false                            -- To check if we are DND or not.
local TrackTime = GetTime()                     -- Used for the timer for herb and mining tracker.
local intAutoAttack = false                     -- Used to find the AutoAttack number button.
-- ============================================== Druid. ==============================================

-- ============================================== Hunter ==============================================

-- =============================================== Mage ===============================================

-- ============================================= Paladin. =============================================

-- ============================================== Priest ==============================================

-- ============================================== Rogue. ==============================================

local lastMessageTime_mainHandExpiration = 0    -- 
local lastMessageTime_mainHandCharges = 0       -- 
local lastMessageTime_hasMainHandEnchant = 0    -- 
local lastMessageTime_offHandExpiration = 0     -- 
local lastMessageTime_offHandCharges = 0        -- 
local lastMessageTime_hasOffHandEnchant = 0     -- 
local lastMessageTime_WindfuryTotem = 0         -- 
local LastSeenWindfuryTime = 0                  -- 
local PrintTime = nil                           -- 

-- ============================================== Shaman ==============================================

-- ============================================= Warlock. =============================================

-- ============================================= Warrior. =============================================


-- ====================================================================================================
-- =                                             Settings                                             =
-- =                                 Here you can change all you want                                 =
-- ====================================================================================================

-- ============================================= General. =============================================

local RunRecruit = false                        -- Du we want to run the recruitment ?
local RecruitmentRunTimer = 1200                -- How often we want to run the recruitment. (in seconds)
local Debug = false                             -- Run debug for the addon, can also be done ingame /ps debug

-- ============================================== Druid. ==============================================

-- ============================================== Hunter ==============================================

-- =============================================== Mage ===============================================

-- ============================================= Paladin. =============================================

-- ============================================== Priest ==============================================

-- ============================================== Rogue. ==============================================

local intPoisonCharges = 10                     -- Warn when there is less then this amount of poison left.
local intPoisonTimeLeft = 180                   -- Warn when there is this amount of time (in sec) left on poison.
local intPoisonRemainder = 30                   -- How often we want the warning. (in sec)
local intWindfuryWaitTime = 180                 -- How many sec do we want to wait on the Windfury buff.
local strPoisonLowColor = "ff8633"              -- Color for the low count or time on poison.
local strPoisonMissingColor = "ff3333"          -- Color for the missing poison.
local strPoisonApplyingColor = "00FF00"         -- Color for applying poison to weapon.
local UseConsumables = true                     -- Do we want to use Juju Power when in party / raid

-- ============================================== Shaman ==============================================

-- ============================================= Warlock. =============================================

-- ============================================= Warrior. =============================================

-- ====================================================================================================
-- =                                          Slash commands                                          =
-- ====================================================================================================

-- Make it easy to reload the game by using /rl or /reload
SLASH_RELOAD1, SLASH_RELOAD2 = '/rl', '/reload'
function SlashCmdList.RELOAD()
  ReloadUI()
end

-- ====================================================================================================

SLASH_PROSLACKER1, SLASH_PROSLACKER2 = '/ps', '/proslacker'
function SlashCmdList.PROSLACKER(msg)

-- ====================================================================================================

    -- Was it a empty slash command ?
    if (msg == nil) or (msg == "") then
        DEFAULT_CHAT_FRAME:AddMessage("Missing commands.")
        DEFAULT_CHAT_FRAME:AddMessage("/ProSlacker Help for more info.")

-- ====================================================================================================

    -- Add what we want to auto buy to ShoppingDB.
    elseif (string.sub(string.upper(msg), 1, 3) == "BUY") then

        -- Do we have a shopping table, if not then we create it.
        if (not ShoppingDB) or (not type(ShoppingDB) == "table") then
            ShoppingDB = {}
        end

        -- Some locals
        local FirstSpaceIndex = nil
        local NumberSpaceIndex = nil
        local OutputString = nil
        local itemName = nil
        local intQuantity = nil

        -- Remove any [ and ] in the string so we can add by shift clicking.
        msg = string.gsub(msg, "[[]", "");
        msg = string.gsub(msg, "[]]", "");

        -- Remove buy from the input.
        FirstSpaceIndex = string.find(msg, " ");
        -- Did we find a space ?
        if (FirstSpaceIndex) then
            -- Make a new string with out the "buy"
            OutputString = string.sub(msg, FirstSpaceIndex + 1);
        end

        -- Find the amount we need to put in, just before first space.
        NumberSpaceIndex = string.find(OutputString, " ");
        -- Did we find a space ?
        if (NumberSpaceIndex) then
            -- Cut the number out of the string.
            intQuantity = string.sub(OutputString, 1, (NumberSpaceIndex) - 1);
            -- Was is a number we ended up with ?
            if (tonumber(intQuantity)) then
                -- Make a new string with no number.
                OutputString = string.sub(OutputString, (NumberSpaceIndex + 1));
            -- It was not a number.
            else
                intQuantity = nil
            end
        end

        -- Did we find anything left in the string ?
        if (OutputString) then
            -- Is it a link people have been using to get the name ?
            -- To find out we look for color codes as they are always in links
            if (string.find(OutputString, "|cff")) then
                -- 
                local start, finish = string.find(OutputString, "|h");
                if start and finish then
                    start = finish + 1
                    finish = string.find(OutputString, "|h", start);
                    if finish then
                        itemName = string.sub(OutputString, start, finish - 1);
                    end
                end
            -- We did not find any color code, so must be text and not a link.
            else
                itemName = OutputString
            end
        end
        -- Do we have a amount and a item name ?
        if (intQuantity) and (itemName) then
            -- Add to ShoppingDB.
            ShoppingDB[string.lower(itemName)] = tonumber(intQuantity);
            -- Inform that we added.
            DEFAULT_CHAT_FRAME:AddMessage("|cff3333ff" .. "Added " .. "|r" .. "|cFF06c51b" .. intQuantity .. " x " .. itemName .. "|r" .. "|cff3333ff" .. " to the auto shopping list." .. "|r");
        else
            DEFAULT_CHAT_FRAME:AddMessage("Invalid input. Please use the format: /ps <quantity> <item name>");
        end

-- ====================================================================================================

    elseif (string.sub(string.upper(msg), 1, 7) == "STOPBUY") then

        -- Do we have a shopping table, if not then we create it.
        if (not ShoppingDB) or (not type(ShoppingDB) == "table") then
            ShoppingDB = {}
        end

        -- Some locals
        local FirstSpaceIndex = nil
        local OutputString = nil
        local itemName = nil

        -- Remove any [ and ] in the string so we can remove by shift clicking.
        msg = string.gsub(msg, "[[]", "");
        msg = string.gsub(msg, "[]]", "");

        -- Remove "stopbuy" from the input.
        FirstSpaceIndex = string.find(msg, " ");
        -- Did we find a space ?
        if (FirstSpaceIndex) then
            -- Make a new string with out the "stopbuy"
            OutputString = string.sub(msg, FirstSpaceIndex + 1);
        end

        -- Find the name of what we want to remove.
        if (OutputString) then
            -- Is it a link people have been using to get the name ?
            -- Too find out we look for color codes as they are always in links
            if (string.find(OutputString, "|cff")) then
                -- 
                local start, finish = string.find(OutputString, "|h");
                if start and finish then
                    start = finish + 1
                    finish = string.find(OutputString, "|h", start);
                    if finish then
                        itemName = string.sub(OutputString, start, finish - 1);
                    end
                end
            -- We did not find any color code, so must be text and not a link.
            else
                itemName = OutputString
            end
        end

        -- Did we get a name ?
        if (itemName) then
            -- Is the item already in the ShoppingDB ?
            if (ShoppingDB[string.lower(itemName)]) then
                ShoppingDB[string.lower(itemName)] = nil
                DEFAULT_CHAT_FRAME:AddMessage("|cff3333ff" .. "Removed " .. "|r" .. "|cFF06c51b" .. itemName .. "|r" .. "|cff3333ff" .. " from the shopping list." .. "|r");
            else
                DEFAULT_CHAT_FRAME:AddMessage("|cff3333ff" .. "The item " .. "|r" .. "|cFF06c51b" .. itemName .. "|r" .. "|cff3333ff" .. " was not in the shopping list." .. "|r");
            end
        else
            DEFAULT_CHAT_FRAME:AddMessage("Invalid input. Please use the format: /ps stopbuy <item name>");
        end

-- ====================================================================================================

    -- List all there have been added to ShoppingDB.
    elseif (string.sub(string.upper(msg), 1, 7) == "LISTBUY") then

        -- Do we have a shopping table, if not then we create it.
        if (not ShoppingDB) or (not type(ShoppingDB) == "table") then
            ShoppingDB = {}
        end

        -- Print the list.
        if next(ShoppingDB) == nil then 
            DEFAULT_CHAT_FRAME:AddMessage("You have nothing on your list.");
        else
            DEFAULT_CHAT_FRAME:AddMessage("Here is your shopping list:");
            for item, count in pairs(ShoppingDB) do
                DEFAULT_CHAT_FRAME:AddMessage("|cffff0000" .. "- " .. "|r" .. count .. " x " .. item);
            end
        end

-- ====================================================================================================

    elseif (string.sub(string.upper(msg), 1, 4) == "INFO") then
        -- Get some info from the TOC file
        local intVersion = GetAddOnMetadata(AddonName, "Version");
        local strAuthor = GetAddOnMetadata(AddonName, "Author");
        -- Write the info about the addon.
        DEFAULT_CHAT_FRAME:AddMessage("|cff3333ff" .. "-- ADDON INFORMATION --" .. "|r");
        DEFAULT_CHAT_FRAME:AddMessage("|cFF06c51b" .. AddonName .. " - Version " .. intVersion .. "|r");
        DEFAULT_CHAT_FRAME:AddMessage("|cFF06c51b" .. "Author: " .. strAuthor .. "|r");
        DEFAULT_CHAT_FRAME:AddMessage("|cFF06c51b" .. "Server: Nordanaar (Turtle WoW)" .. "|r");

-- ====================================================================================================

    -- Disable or enable debigging.
    elseif (string.sub(string.upper(msg), 1, 5) == "DEBUG") then
        if (Debug == true) then
            Debug = false
            DEFAULT_CHAT_FRAME:AddMessage("Debugging: |cFFFF0000disabled|r.");
        elseif (Debug == false) then
            Debug = true
            DEFAULT_CHAT_FRAME:AddMessage("Debugging: |cFF00FF00enabled|r.");
        end

-- ====================================================================================================

    -- Give some help with the slash sommands.
    elseif (string.sub(string.upper(msg), 1, 4) == "HELP") then
        DEFAULT_CHAT_FRAME:AddMessage("Available commands:");
        DEFAULT_CHAT_FRAME:AddMessage("Both /proslacker or /ps can be used.");
        DEFAULT_CHAT_FRAME:AddMessage("/ps buy - Add items to the auto shopping list.");
        DEFAULT_CHAT_FRAME:AddMessage("/ps stopbuy - Remove items from the auto shopping list.");
        DEFAULT_CHAT_FRAME:AddMessage("/ps listbuy - Show what is on the auto shopping list.");
        DEFAULT_CHAT_FRAME:AddMessage("/ps info - Display addon information.");
        DEFAULT_CHAT_FRAME:AddMessage("/ps debug - Enable or disable debugging.");
        DEFAULT_CHAT_FRAME:AddMessage("/ps help - Show this help message.");
    else
        DEFAULT_CHAT_FRAME:AddMessage("Wrong slash command, use /ProSlacker Help for more help.");
    end
end

-- ====================================================================================================
-- =                                           Error Filter                                           =
-- ====================================================================================================

-- More info here:
-- https://wowpedia.fandom.com/wiki/UI_ERROR_MESSAGE
-- Other good stuff there can be used here:
-- https://wowwiki-archive.fandom.com/wiki/Talk:WoW_constants

local BlackListErrors = {
  [ERR_OUT_OF_MANA] = true,                     -- Not enough mana.
  [ERR_OUT_OF_ENERGY] = true,                   -- Not enough energy.
  [ERR_OUT_OF_RAGE] = true,                     -- Not enough rage.
  [ERR_OUT_OF_FOCUS] = true,                    -- Not enough focus.
  [ERR_ABILITY_COOLDOWN] = true,                -- Ability is not ready yet.
  [ERR_ITEM_COOLDOWN] = true,                   -- Item is not ready yet.
  [ERR_BADATTACKPOS] = true,                    -- You are too far away!
  [ERR_OUT_OF_RANGE] = true,                    -- Out of range.
  [ERR_NO_ATTACK_TARGET] = true,                -- There is nothing to attack.
  [SPELL_FAILED_MOVING] = true,                 -- Can't do that while moving.
  [SPELL_FAILED_AFFECTING_COMBAT] = true,       -- You are in combat.
  [ERR_NOT_IN_COMBAT] = true,                   -- You can't do that while in combat
  [SPELL_FAILED_UNIT_NOT_INFRONT] = true,       -- Target needs to be in front of you.
  [ERR_BADATTACKFACING] = true,                 -- You are facing the wrong way!
  [SPELL_FAILED_TOO_CLOSE] = true,              -- Target too close.
  [ERR_INVALID_ATTACK_TARGET] = true,           -- You cannot attack that target.
  [ERR_SPELL_COOLDOWN] = true,                  -- Spell is not ready yet.
  [SPELL_FAILED_NO_COMBO_POINTS] = true,        -- That ability requires combo points.
  [SPELL_FAILED_TARGETS_DEAD] = true,           -- Your target is dead.
  [SPELL_FAILED_SPELL_IN_PROGRESS] = true,      -- Another action is in progress.
  [SPELL_FAILED_TARGET_AURASTATE] = true,       -- You can't do that yet.
  [SPELL_FAILED_CASTER_AURASTATE] = true,       -- You can't do that yet.
  [SPELL_FAILED_NO_ENDURANCE] = true,           -- Not enough endurance.
  [SPELL_FAILED_BAD_TARGETS] = true,            -- Invalid target.
  [SPELL_FAILED_NOT_MOUNTED] = true,            -- You are mounted.
  [SPELL_FAILED_NOT_ON_TAXI] = true,            -- You are in flight.
  [ERR_UNIT_NOT_FOUND] = true,                  -- Unknown Unit.
  [INTERRUPTED] = true,                         -- Interrupted.
}

-- ====================================================================================================
-- =                                 Create frame and register events                                 =
-- ====================================================================================================

local f = CreateFrame("Frame")
    f:RegisterEvent("UI_ERROR_MESSAGE");
    f:RegisterEvent("MERCHANT_SHOW");
    f:RegisterEvent("MERCHANT_CLOSED");
    f:RegisterEvent("ZONE_CHANGED_NEW_AREA");
    f:RegisterEvent("CHAT_MSG_SYSTEM");

-- ====================================================================================================
-- =                                          Event handler.                                          =
-- ====================================================================================================

-- f:SetScript("OnEvent", function(self, event, arg1, arg2, arg3)
f:SetScript("OnEvent", function()
    if (event == "ADDON_LOADED") and (arg1 == AddonName) then
        
        f:UnregisterEvent("ADDON_LOADED");
-- ====================================================================================================
    -- Fire when we get a red error message on the screen.
    elseif (event == "UI_ERROR_MESSAGE") then
        local errorName = arg1
        -- Check to see if the error was that the target have no pockets.
        if (arg1 == SPELL_FAILED_TARGET_NO_POCKETS) then
            -- Is the table created ?
            if (not MobHasNoPocketDB) or (not type(MobHasNoPocketDB) == "table") then
                MobHasNoPocketDB = {}
            end
            -- Insert to table that the mob don't have pockets.
            local MobInfo = GetMobInfo()
            -- Did we get the mob info ?
            if (MobInfo ~= false) then
                -- Check if we already have the mob in the DB.
                if (not MobHasNoPocketDB[MobInfo]) then
                    -- Mob was not there, so insert.
                    MobHasNoPocketDB[MobInfo] = true
                end
            end
        end
-- ====================================================================================================
        -- If the error message is not in the black list, then we forward it.
        if (not BlackListErrors[errorName]) then
            UIErrorsFrame:AddMessage(errorName, 1, .1, .1)
        end
-- ====================================================================================================
    -- Did we open a vendor window ?
    elseif (event == "MERCHANT_SHOW") then
        BuyItemFromVendor()
-- ====================================================================================================
    -- Did we close a vendor window ?
    elseif (event == "MERCHANT_CLOSED") then
        
-- ====================================================================================================
    -- Did the zone change
    elseif (event == "ZONE_CHANGED_NEW_AREA") then
        RegisterZone()
-- ====================================================================================================
    -- 
    elseif (event == "CHAT_MSG_SYSTEM") then
        -- Check the chat if we are AFK or DND
        if (string.find(arg1, string.sub(MARKED_DND, 1, string.len(MARKED_DND) -3))) then
            StopGuildRecruit = true
            strDND = true
        elseif (string.find(arg1, string.sub(MARKED_AFK, 1, string.len(MARKED_AFK) -2))) then
            StopGuildRecruit = true
        -- Check the that if we are no longer AFK or DND
        elseif arg1 == CLEARED_DND then
            StopGuildRecruit = false
            strDND = false
        elseif (arg1 == CLEARED_AFK) and (strDND == false) then
            StopGuildRecruit = false
        end
    end
end)

-- ====================================================================================================
-- =                                     OnUpdate on every frame.                                     =
-- ====================================================================================================

f:SetScript("OnUpdate", function()

    if ((LogInTime + 3) < GetTime()) and (ErrorMessageFilter == false) then
        UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE");
        DEFAULT_CHAT_FRAME:AddMessage("|cff3333ff" .. AddonName .. " by " .. "|r" .. "|cFF06c51b" .. "Subby" .. "|r" .. "|cff3333ff" .. " is loaded." .. "|r");
        ErrorMessageFilter = true
    end

    -- Run guild recruitment
    if (RecruitTime + RecruitmentRunTimer < GetTime()) and (RunRecruit == true) then
        GuildRecruitment()
    end

    -- 
    if ((TrackTime + 10) < GetTime()) then
        HerbAndMining()
        TrackTime = GetTime()
    end

end)

-- ====================================================================================================
-- =                                        Start auto attack.                                        =
-- ====================================================================================================

function AutoAttackStart()

    -- Find the english player class.
    _, EnglishClass = UnitClass("player");

    -- Loop through all the action buttons.
    for i = 1, 172 do
        -- Get the texture of the button.
        local Texture = GetActionTexture(i)
        -- Is the slot an attack action and should flash red during combat.
        if (IsAttackAction(i)) and (EnglishClass ~= "HUNTER") then
            -- Is the slot active ? (IsCurrentAction() are for melee and IsAutoRepeatAction() are for shoot (Hunter or wand))
            if (not IsCurrentAction(i)) then
                -- If not in action, then activate it.
                CastSpellByName("Attack");
            end
        end
        -- Hunter acting a bit different as we have range and melee attack, so that we take here.
        if (EnglishClass == "HUNTER") and (IsAttackAction(i)) and (CheckInteractDistance("target", 3)) and (not IsCurrentAction(i)) then
            CastSpellByName("Attack");
        elseif (Texture) and (EnglishClass == "HUNTER") and (not IsAutoRepeatAction(i)) and (string.find(Texture, "Weapon")) then
            CastSpellByName("Auto Shot");
        end
    end

end

-- ====================================================================================================
-- =                                     Herb and mining switcher                                     =
-- ====================================================================================================

function HerbAndMining()

    -- Are we dead ? If so we do nothing.
    if (UnitIsDeadOrGhost("player")) then
        return;
    end

    local KnowMining = false
    local KnowHerbalism = false
    local MiningOn = false
    local HerbalismOn = false

    -- Do we know Mining ?
    if (CheckIfSpellIsKnown("Find Minerals", 0) == true) then
        KnowMining = true
    end

    -- Do we know herbalism ?
    if (CheckIfSpellIsKnown("Find Herbs", 0) == true) then
        KnowHerbalism = true
    end

    -- Stop if we don't know any of the spells.
    if (KnowMining == false) and (KnowHerbalism == false) then
        return;
    end

    -- Are we already tracking mines ?
    if (GetTrackingTexture() == "Interface\\Icons\\Spell_Nature_Earthquake") then
        MiningOn = true
    end

    -- Are we already tracking herbs ?
    if (GetTrackingTexture() == "Interface\\Icons\\INV_Misc_Flower_02") then
        HerbalismOn = true
    else
        --DEFAULT_CHAT_FRAME:AddMessage(GetTrackingTexture())
    end

    -- Check if it's something else we are tracking.

    -- Inform that we are not tracking anything.
    if (KnowMining == true) and (KnowHerbalism == true) then
        if (MiningOn == false) and (HerbalismOn == false) then
            DEFAULT_CHAT_FRAME:AddMessage("|cffff0000" .. "Find Minerals or Find Herbs are not enabled." .. "|r")
        end
    elseif (KnowMining == true) and (KnowHerbalism == false) then
        if (MiningOn == false) then
            DEFAULT_CHAT_FRAME:AddMessage("|cffff0000" .. "Find Minerals are not enabled." .. "|r")
        end
    elseif (KnowMining == false) and (KnowHerbalism == true) then
        if (HerbalismOn == false) then
            DEFAULT_CHAT_FRAME:AddMessage("|cffff0000" .. "Find Herbs are not enabled." .. "|r")
        end
    end

end

-- ====================================================================================================
-- =                                      Auto shop from vendor.                                      =
-- ====================================================================================================

function BuyItemFromVendor()
    -- Do we have a shopping table ?
    if (not ShoppingDB) or (not type(ShoppingDB) == "table") then
        ShoppingDB = {}
    end

    for itemName, desiredQuantity in pairs(ShoppingDB) do
        local ItemCount = 0
        -- Check if you have enough of the item in your inventory.
        for bag = 0, 4 do
            for slotNum = 1, GetContainerNumSlots(bag) do
                local itemLink = GetContainerItemLink(bag, slotNum)
                if (itemLink) and (string.find(string.lower(itemLink), string.lower(itemName))) then
                    local _, count = GetContainerItemInfo(bag, slotNum)
                    ItemCount = ItemCount + count
                end
            end
        end
        -- Debug
        if (Debug == true) then
            DEFAULT_CHAT_FRAME:AddMessage("We found " .. ItemCount .. " x " .. itemName .. " in our bags.");
        end
        -- Is what we have in the bags less then what we want to have ?
        if (ItemCount < desiredQuantity) then
            local quantityToBuy = (desiredQuantity - ItemCount)
            -- Debug
            if (Debug == true) then
                DEFAULT_CHAT_FRAME:AddMessage("We need to buy " .. quantityToBuy .. " x " .. itemName);
            end
            for i = 1, GetMerchantNumItems() do
                local itemLink = GetMerchantItemLink(i)
                if (itemLink) and (string.find(string.lower(itemLink), string.lower(itemName))) then
                    local vendorItemName, IconTexture, BatchPrice, BatchQuantity, vendorItemCount, isUsable, extendedCost = GetMerchantItemInfo(i)
                    -- Debug
                    if (Debug == true) then
                        DEFAULT_CHAT_FRAME:AddMessage("Vendor have " .. itemName);
                        DEFAULT_CHAT_FRAME:AddMessage("There is " .. BatchQuantity .. " in a batch");
                    end
                    -- Make sure we don't buy for example 3 x 5 of something if we only want 3
                    -- If the stack is bigger then what we want, then we round down.
                    if (BatchQuantity > 1) then
                        quantityToBuy = math.floor((quantityToBuy / BatchQuantity))
                    end
                    -- Debug
                    if (Debug == true) then
                        DEFAULT_CHAT_FRAME:AddMessage("After calculation we need to buy " .. quantityToBuy .. " x " .. itemName);
                    end
                    -- After the canculation, do we still need to buy any ?
                    if (quantityToBuy > 0) then
                        -- Do we have enough money to buy it ?
                        local playerMoney = GetMoney()
                        if (playerMoney > (BatchPrice * quantityToBuy)) then
                            -- Check that the vendor have the amount we want.
                            if (tonumber(vendorItemCount) >= tonumber(quantityToBuy)) or (tonumber(vendorItemCount) == -1) then
                                -- Buy the required quantity
                                for j = 1, quantityToBuy do
                                    BuyMerchantItem(i)
                                end
                            -- Vendor don't have the amount we want, so we buy what vendor have.
                            else
                                -- Buy what we can get.
                                for j = 1, vendorItemCount do
                                    BuyMerchantItem(i)
                                end
                            end
                            -- Adjust the number we buy just for the text
                            if (BatchQuantity > 1) then
                                quantityToBuy = (quantityToBuy * BatchQuantity)
                            end
                            -- 
                            DEFAULT_CHAT_FRAME:AddMessage("|cff3333ff" .. AddonName .. ": " .. "|r" .. "|cFF06c51b" .. "Buying " .. quantityToBuy .. " x " .. itemName .. "." .. "|r")
                        end
                    end
                end
            end
        end
    end

end

-- ====================================================================================================
-- =                                         Get the mob "ID"                                         =
-- ====================================================================================================

function GetMobInfo()
    -- As it's not possible to get the ID of a mob in 1.12 we need to do it in another way.
    -- We take name and level of the mob, and the zone we are in, that is as close as we can get to not mix mobs up.
    local name = UnitName("target")
    local level = UnitLevel("target")
    local zoneName = GetRealZoneText()
    -- Did we find anything ?
    if (name) and (level) and (zoneName) then
        return name .. ":" .. level .. ":" .. zoneName
    else
        if (Debug == true) then
            if (not name) then
                DEFAULT_CHAT_FRAME:AddMessage("Missing name of the mob.");
            end
            if (not level) then
                DEFAULT_CHAT_FRAME:AddMessage("Missing level of the mob.");
            end
            if (not zoneName) then
                DEFAULT_CHAT_FRAME:AddMessage("Missing the zone we are in.");
            end
        end
        return false
    end
end

-- ====================================================================================================
-- =                                        Target new enermy.                                        =
-- ====================================================================================================

function TargetNewEnemy()
    -- Do we have a target or maybe a dead target ?
    if (GetUnitName("target") == nil) or (UnitIsDeadOrGhost("target")) then
        -- Target enermy
        TargetNearestEnemy();
        -- Check if it a NPC or a Player, no need to check the rest if it's a NPC
        if (UnitIsPlayer("target") == true) then
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
        else
            return true
        end
    end
end

-- ====================================================================================================
-- =                                         Hunter Auto Shot                                         =
-- ====================================================================================================

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

    -- Start auto attack.
    AutoAttackStart()

    if (CheckInteractDistance("target", 3)) then
        CastSpellByName("Mongoose Bite")
        CastSpellByName("Raptor Strike")
    else
        CastSpellByName("Arcane Shot")
    end
    PetAttack(target)

end

-- ====================================================================================================
-- =                                            Hunter Pet                                            =
-- ====================================================================================================

function HunterPet()

-- ########## The macro ##########
-- /run -- CastSpellByName("Feed Pet")
-- /script HunterPet()

    if UnitExists("pet") then
        if UnitHealth("pet") == 0 then
            CastSpellByName("Revive Pet")
        elseif (GetPetHappiness() ~= nil) and (GetPetHappiness() ~= 3) and (not UnitAffectingCombat("pet")) then
            CastSpellByName("Feed Pet") PickupContainerItem(0, 2)
        elseif UnitAffectingCombat("pet") then
            CastSpellByName("Mend Pet")
        else
            CastSpellByName("Dismiss Pet")
        end
    else
        CastSpellByName("Call Pet")
    end

end

-- ====================================================================================================
-- =                                          Reiskar Rotation                                          =
-- ====================================================================================================

function ReiskarAttack(ChosenAttack, ChosenOpener)

-- ########## The macro ##########
-- /run -- CastSpellByName("Backstab")
-- /script ReiskarAttack("Backstab", "Cheap Shot")

    -- Find a new enermy we can attack.
    if (TargetNewEnemy() == false) then
        return;
    end

    local icon, name, StealthActive, castable = GetShapeshiftFormInfo(1);
    if (StealthActive == 1) then
        CastSpellByName("Pick Pocket");
        CastSpellByName(ChosenOpener);
    -- We are not stealth
    else

        local SnD = false
        local db
        -- Loop through all our buffs and look for the Slice and Dice icon.
        for i = 1, 64, 1 do
            db = UnitBuff("player",i) 
            -- Is it Slice and Dice we found ?
            if ((db ~= nil) and (string.find(db,"Interface\\Icons\\Ability_Rogue_SliceDice"))) then
                SnD = true
            end
        end
        -- Do we have Slice and Dice buff ?
        if (SnD == true) then
            CastSpellByName(ChosenAttack);
        -- 
        elseif (GetComboPoints("target") == 0) and (SnD == false) then
            CastSpellByName(ChosenAttack);
        else
            CastSpellByName("Slice and Dice");
        end

        -- Check for poison.
        CheckForPoison()

        -- Check for Windfury.
        WindfuryFromShaman()

    end

end

-- ====================================================================================================
-- =                                          Rogue Rotation                                          =
-- ====================================================================================================

function RogueAttack(ChosenAttack, ChosenOpener)

-- ########## The macro ##########
-- /run -- CastSpellByName("Sinister Strike")
-- /script RogueAttack("Sinister Strike", "Cheap Shot")

    -- Do we cast fishing and don't fight ?
    if (FishingPoleEquipped() == true) then
        CastSpellByName("Fishing");
        return;
    end

    -- Find a new enermy we can attack.
    if (TargetNewEnemy() == false) then
        return;
    end

    -- Set some locals
    local partyMembers = GetNumPartyMembers() -- Get group numbers

    -- Do we use Juju Power ?
    if (UseConsumables == true) and ((partyMembers > 3) or (GetNumRaidMembers() > 3)) then
        -- Set locals
        local Juju = false
        local GroundScorpokAssay = false
        local Mongoose = false
        local Firewater = false
        -- Loop through all our buffs and look for the buff icon that we want running.
        for i = 1, 64, 1 do
            local JujuBuff = UnitBuff("player",i);
            local GroundScorpokAssayBuff = UnitBuff("player",i);
            local MongooseBuff = UnitBuff("player",i);
            local FirewaterBuff = UnitBuff("player",i);
            -- Is it "Juju Power" we found ?
            if ((JujuBuff ~= nil) and (string.find(JujuBuff,"Interface\\Icons\\INV_Misc_MonsterScales_11"))) then
                Juju = true
            end
            -- Is it "Ground Scorpok Assay" we found ?
            if ((GroundScorpokAssayBuff ~= nil) and (string.find(GroundScorpokAssayBuff,"Interface\\Icons\\Spell_Nature_ForceOfNature"))) then
                GroundScorpokAssay = true
            end
            -- Is it "Elixir of the Mongoose" we found ?
            if ((MongooseBuff ~= nil) and (string.find(MongooseBuff,"Interface\\Icons\\INV_Potion_32"))) then
                Mongoose = true
            end
            -- Is it "Winterfall Firewater" we found ?
            if ((FirewaterBuff ~= nil) and (string.find(FirewaterBuff,"Interface\\Icons\\INV_Potion_92"))) then
                Firewater = true
            end
        end
        -- Do we need to use "Juju Power" ? (30 Strength)
        if (Juju == false) then
            -- Do we have any "Juju Power" in our bags ?
            for bag = 0, 4 do
                for slotNum = 1, GetContainerNumSlots(bag) do
                -- for slotNum = GetContainerNumSlots(bag), 1, -1 do
                    local itemLink = GetContainerItemLink(bag, slotNum)
                    if itemLink and string.find(string.lower(itemLink), "juju power") then
                        -- We found one, so we use it.
                        UseContainerItem(bag, slotNum)
                    end
                end
            end
        end
        -- Do we need to use "Ground Scorpok Assay" ? (25 Agility)
        if (GroundScorpokAssay == false) and (GetNumRaidMembers() > 20) then
            -- Do we have any "Ground Scorpok Assay" in our bags ?
            for bag = 0, 4 do
                for slotNum = 1, GetContainerNumSlots(bag) do
                -- for slotNum = GetContainerNumSlots(bag), 1, -1 do
                    local itemLink = GetContainerItemLink(bag, slotNum)
                    if itemLink and string.find(string.lower(itemLink), "ground scorpok assay") then
                        -- We found one, so we use it.
                        UseContainerItem(bag, slotNum)
                    end
                end
            end
        end
        -- Do we need to use "Elixir of the Mongoose" ? (25 Agility & 2% crit)
        if (Mongoose == false) and (GetNumRaidMembers() > 20) then
            -- Do we have any "Elixir of the Mongoose" in our bags ?
            for bag = 0, 4 do
                for slotNum = 1, GetContainerNumSlots(bag) do
                -- for slotNum = GetContainerNumSlots(bag), 1, -1 do
                    local itemLink = GetContainerItemLink(bag, slotNum)
                    if itemLink and string.find(string.lower(itemLink), "elixir of the mongoose") then
                        -- We found one, so we use it.
                        UseContainerItem(bag, slotNum)
                    end
                end
            end
        end
        -- Do we need to use "Winterfall Firewater" ? (35 Attack Power)
        if (Firewater == false) and (GetNumRaidMembers() > 20) then
            -- Do we have any "Winterfall Firewater" in our bags ?
            for bag = 0, 4 do
                for slotNum = 1, GetContainerNumSlots(bag) do
                -- for slotNum = GetContainerNumSlots(bag), 1, -1 do
                    local itemLink = GetContainerItemLink(bag, slotNum)
                    if itemLink and string.find(string.lower(itemLink), "winterfall firewater") then
                        -- We found one, so we use it.
                        UseContainerItem(bag, slotNum)
                    end
                end
            end
        end
    end

    -- 
    local icon, name, StealthActive, castable = GetShapeshiftFormInfo(1);
    if (StealthActive == 1) then
        -- Get the mob info.
        local MobInfo = GetMobInfo()

        if (CheckInteractDistance("target", 3)) and (GetUnitName("target") ~= nil) then
            -- Check that the table is made, if not, then create it.
            if (not MobHasNoPocketDB) or (not type(MobHasNoPocketDB) == "table") then
                MobHasNoPocketDB = {}
            end
            -- Check that mob has pockets to pick.
            if (MobHasNoPocketDB[MobInfo]) then
                if (CheckIfSpellIsKnown(ChosenOpener, 0) == true) then
                    CastSpellByName(ChosenOpener);
                else
                    CastSpellByName(ChosenAttack);
                end
            -- Mob has pockets.
            else
                if (CheckIfSpellIsKnown("Pick Pocket", 0) == true) then
                    CastSpellByName("Pick Pocket");
                end
                if (CheckIfSpellIsKnown(ChosenOpener, 0) == true) then
                    CastSpellByName(ChosenOpener);
                else
                    CastSpellByName(ChosenAttack);
                end
            end
        end
        -- Stop so we don't do anything else then the stealth things.
        return;
    end


--[[ Turtle WoW have removed the global cooldown on Pick Pocket, so we change to a easy on but save this for other privat servers.

        -- 1 = Compare Achievements, 28 yards - 2 = Trade, 8 yards - 3 = Duel, 7 yards - 4 = Follow, 28 yards - 5 = Pet-battle Duel, 7 yards
        if (CheckInteractDistance("target", 3)) and (strPickPocketDone ~= true) and (GetUnitName("target") ~= nil) and (not MobHasNoPocketDB[MobInfo]) then
            CastSpellByName("Pick Pocket");
            strPickPocketDone = true
        else
            if (CheckIfSpellIsKnown(ChosenOpener, 0) == true) then
                CastSpellByName(ChosenOpener);
            else
                CastSpellByName(ChosenAttack);
            end
            strPickPocketDone = false
        end
        return;
    else
        -- Set it to false so we are sure we pick pocket next time.
        strPickPocketDone = false
    end
--]]


    local SnD = false
    local TfB = false
    local db
    -- Loop through all our buffs and look for the "Slice and Dice" and "Taste for Blood" icon.
    for i = 1, 64, 1 do
        -- Keep this so we easy can look for new buffs.
        if UnitBuff("player",i) then
            -- DEFAULT_CHAT_FRAME:AddMessage(UnitBuff("player",i)) -- Keep this line here for when we have to change check for buff.
        end
        db = UnitBuff("player",i) 
        -- Is it "Slice and Dice" we found ?
        if ((db ~= nil) and (string.find(db,"Interface\\Icons\\Ability_Rogue_SliceDice"))) then
            SnD = true
        end
        -- Is it "Taste for Blood" we found ?
        if ((db ~= nil) and (string.find(db,"Interface\\Icons\\INV_Misc_Bone_09"))) then
            -- Is there more then 8 sec left ?
            --if (GetPlayerBuffTimeLeft(i) >= 8) then
                DEFAULT_CHAT_FRAME:AddMessage(GetPlayerBuffTexture(i-1));
                DEFAULT_CHAT_FRAME:AddMessage(UnitBuff("player",i))
                DEFAULT_CHAT_FRAME:AddMessage("Taste of Blood: " .. GetPlayerBuffTimeLeft(i-1));
                TfB = true
            --end
        end
    end
    -- Do our target have 5 combo points ?
    if (GetComboPoints("target") == 5) then
        -- Do we have "Taste of Blood" running ?
        if (TfB == true) then
            CastSpellByName("Eviscerate");
        else
            -- Have we learned "Rupture" yet ?
            if (CheckIfSpellIsKnown("Rupture", 0) == true) then
                CastSpellByName("Rupture");
            else
                CastSpellByName("Eviscerate");
            end
        end
    -- Eviscerate if 3 combo points and target HP is below 3000 and we are max level.
    elseif ((GetComboPoints("target") >= 3) and (UnitHealth("target") < 3000) and (UnitLevel("player") == 60)) then
        CastSpellByName("Eviscerate");
    -- Do we have 3 or more combo points and do target have 20% or less health left ? 
    elseif ((GetComboPoints("target") >= 3) and ((UnitHealth("target") / UnitHealthMax("target")) < 0.2) and (UnitLevel("player") < 60)) then
        CastSpellByName("Eviscerate");
    -- Do we have Slice and Dice buff ?
    elseif (SnD == true) then
        CastSpellByName("Surprise Attack");
        CastSpellByName("Riposte");
        CastSpellByName(ChosenAttack);
    -- Is there 0 combo point on target ?
    elseif (GetComboPoints("target") == 0) then
        CastSpellByName("Riposte");
        CastSpellByName(ChosenAttack);
    else
        -- Have we learned "Slice and Dice" yet ?
        if (CheckIfSpellIsKnown("Slice and Dice", 0) == true) then
            CastSpellByName("Slice and Dice");
        else
            CastSpellByName(ChosenAttack);
        end
    end

    -- Start auto attack if we are not stealth.
    if (StealthActive ~= 1) then
        -- Make sure we start auto attack, even if we don't have enough energy, but only if we are not stealth.
        AutoAttackStart()
    end

    -- Check for poison.
    CheckForPoison()

    -- Check for Windfury.
    WindfuryFromShaman()

end

-- ====================================================================================================
-- =                                           Poison check                                           =
-- ====================================================================================================

function CheckForPoison()

    -- Do we even know poison yet ? No reason to spam that we need it, if we can't make it yet.
    if (CheckIfSpellIsKnown("Poisons", 0) ~= true) then
        if (Debug == true) then
            DEFAULT_CHAT_FRAME:AddMessage("We don't know Poisons.");
        end
        return
    end

    -- Do we have poison on our weapons ?
    hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration, offHandCharges = GetWeaponEnchantInfo();

    -- Check main-hand enchant status
    if hasMainHandEnchant then
        -- Is it running out on time ?
        if mainHandExpiration / 1000 <= intPoisonTimeLeft then
            if GetTime() - lastMessageTime_mainHandExpiration >= intPoisonRemainder then
                lastMessageTime_mainHandExpiration = GetTime()
                DEFAULT_CHAT_FRAME:AddMessage("|cff" .. strPoisonLowColor .. "Main-hand poison is expiring. - Reapply soon." .. "|r")
                PlaySoundFile("Interface\\AddOns\\ProSlacker\\Sounds\\Poison_Is_Running_Out.mp3");
            end
        end
        -- Is it running out due to amount of charges ?
        if mainHandCharges < intPoisonCharges then
            if GetTime() - lastMessageTime_mainHandCharges >= intPoisonRemainder then
                lastMessageTime_mainHandCharges = GetTime()
                DEFAULT_CHAT_FRAME:AddMessage("|cff" .. strPoisonLowColor .. "Main-hand poison is low on charges. - Reapply soon." .. "|r")
                PlaySoundFile("Interface\\AddOns\\ProSlacker\\Sounds\\Poison_Is_Running_Low.mp3");
            end
        end
    -- We are missing poison on Main-hand.
    else
        if GetTime() - lastMessageTime_hasMainHandEnchant >= intPoisonRemainder then
            lastMessageTime_hasMainHandEnchant = GetTime()
            DEFAULT_CHAT_FRAME:AddMessage("|cff" .. strPoisonMissingColor .. ">> MISSING POISON - MAIN-HAND <<" .. "|r")
            PlaySoundFile("Interface\\AddOns\\ProSlacker\\Sounds\\Missing_Poison.mp3");
        end
    end

    -- Check off-hand enchant status
    if hasOffHandEnchant then
        -- Is it running out on time ?
        if offHandExpiration / 1000 <= intPoisonTimeLeft then
            if GetTime() - lastMessageTime_offHandExpiration >= intPoisonRemainder then
                lastMessageTime_offHandExpiration = GetTime()
                DEFAULT_CHAT_FRAME:AddMessage("|cff" .. strPoisonLowColor .. "Off-hand poison is expiring. - Reapply soon." .. "|r")
                PlaySoundFile("Interface\\AddOns\\ProSlacker\\Sounds\\Poison_Is_Running_Out.mp3");
            end
        end
        -- Is it running out due to amount of charges ?
        if offHandCharges < intPoisonCharges then
            if GetTime() - lastMessageTime_offHandCharges >= intPoisonRemainder then
                lastMessageTime_offHandCharges = GetTime()
                DEFAULT_CHAT_FRAME:AddMessage("|cff" .. strPoisonLowColor .. "Off-hand poison is low on charges. - Reapply soon." .. "|r")
                PlaySoundFile("Interface\\AddOns\\ProSlacker\\Sounds\\Poison_Is_Running_Low.mp3");
            end
        end
    -- We are missing poison on Off-hand.
    else
        if ((GetTime() - lastMessageTime_hasOffHandEnchant) >= intPoisonRemainder) then
            lastMessageTime_hasOffHandEnchant = GetTime()
            DEFAULT_CHAT_FRAME:AddMessage("|cff" .. strPoisonMissingColor .. ">> MISSING POISON - OFF-HAND <<" .. "|r")
            PlaySoundFile("Interface\\AddOns\\ProSlacker\\Sounds\\Missing_Poison.mp3");
        end
    end

end

-- ====================================================================================================
-- =                        Is someone in the group there is buffing Windfury?                        =
-- ====================================================================================================

function WindfuryFromShaman()
    -- Set some locals
    local partyMembers = GetNumPartyMembers()   -- Get group numbers
    local strShamanFound = false

    -- Are we even in a group ?
    if (partyMembers > 0) then
        -- Do we have a Shaman in our group ? No need to check whole raid as Windfury is only for party.
        for i = 1, partyMembers do
            local unitName, unitClass , unitLevel = UnitName("party" .. i), UnitClass("party" .. i), UnitLevel("party" .. i)
            -- Check if we have a name and it's a Shaman and it's level 32 or above.
            if (unitName) and (string.lower(unitClass) == "shaman") and (unitLevel >= 32) then
                if (Debug == true) then
                    DEFAULT_CHAT_FRAME:AddMessage("We have a Shaman in our party.")
                end
                strShamanFound = true
            end
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
                        DEFAULT_CHAT_FRAME:AddMessage("The icon we found was: " .. name)
                    end
                end
                -- Is it the icon for Windfury ?
                if (name) and (string.find(name, "Interface\\Icons\\Spell_Nature_Windfury")) then
                    if (Debug == true) then
                        DEFAULT_CHAT_FRAME:AddMessage("We found the \"Windfury Totem Effect\" buff.")
                    end
                    LastSeenWindfuryTime = GetTime()
                    return true
                end
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
                            PrintTime = seconds .. "sec"
                        elseif (hour == 0) then
                            PrintTime = minutes .. "min " .. seconds .. "sec"
                        else
                            PrintTime = hour .. "hour " .. minutes .. "min " .. seconds .. "sec"
                        end
                        -- Print a message that we are missing Windfury.
                        DEFAULT_CHAT_FRAME:AddMessage("|cff" .. strPoisonMissingColor .. "Windfury missing for " .. PrintTime .. "." .. "|r")
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

-- ====================================================================================================
-- =                                      Do we know the spell ?                                      =
-- ====================================================================================================

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
                if (currentSpellRank == nil) or (currentSpellRank == "") or (currentSpellRank == "Shapeshift") then
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

-- ====================================================================================================
-- =                                           Rogue Poison                                           =
-- ====================================================================================================

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

-- ====================================================================================================
-- =                                         Rogue Pickpocket                                         =
-- ====================================================================================================

function PickpocketTarget()

-- ########## The macro ##########
-- /run -- CastSpellByName("Pick Pocket")
-- /script PickpocketTarget()

    -- Target a new enemy, no need to check anything as we want a new target everytime we activate function.
    TargetNearestEnemy();

    -- Check if the target is valid and within range
    if (GetUnitName("target") ~= nil) and CheckInteractDistance("target", 3) then
        -- Pickpocket the target
        CastSpellByName("Pick Pocket");
    end

end

-- ====================================================================================================
-- =                                          Paladin attack                                          =
-- ====================================================================================================

function PaladinAttack()

-- ########## The macro ##########
-- /run -- CastSpellByName("Attack")
-- /script PaladinAttack()


--[[
if (not PlayerFrame.inCombat) and UnitExists("target") then
    CastSpellByName("Attack")
end

if not buffed("Holy Might", "player") then
    CastSpellByName("Holy Strike")
end

CastSpellByName("Crusader Strike")

if buffed("Seal of the Crusader", "player") then
    CastSpellByName("Judgement")
end
if buffed("Seal of Command", "player") then
    CastSpellByName("Judgement")
end
if buffed("Seal of Wisdom", "player") then
    CastSpellByName("Judgement")
end

if not buffed("Seal of Wisdom", "player") and not buffed("Judgement of Wisdom","target") then
    CastSpellByName("Seal of Wisdom")
end

if not buffed("Seal of Command", "player") and buffed("Judgement of Wisdom","target") then
    CastSpellByName("Seal of Command")
    return
end
--]]




    -- Do we cast fishing and don't fight ?
    if (FishingPoleEquipped() == true) then
        CastSpellByName("Fishing");
        return;
    end

    -- Find a new enermy we can attack.
    if (TargetNewEnemy() == false) then
        return;
    end

    -- Start auto attack.
    AutoAttackStart()

    -- Locals
    local HasSealBuff = false
    local HasMightBuff = false
    -- Loop through own buff.
    for i = 1, 64 do
        if UnitBuff("player",i) then
            -- DEFAULT_CHAT_FRAME:AddMessage(UnitBuff("player",i)) -- Keep this line here for when we have to change check for buff.
        end
        --Do we have Seal of Righteousness up ?
        if UnitBuff("player",i) and string.find(UnitBuff("player",i),"Interface\\Icons\\Ability_ThunderBolt") then
            -- Vi fandt Battle Shout.
            HasSealBuff = true
        end
        --Do we have Blessing of Might up ?
        if UnitBuff("player",i) and string.find(UnitBuff("player",i),"Interface\\Icons\\Spell_Holy_FistOfJustice") then
            -- Vi fandt Blessing of Might
            HasMightBuff = true
        end
    end
    -- We did not find Seal of Righteousness.
    if (not HasSealBuff) then
        -- Cast Seal of Righteousness
        CastSpellByName("Seal of Righteousness");
    end
    -- We did not find Blessing of Might.
    if (not HasMightBuff) then
        -- Cast Seal of Righteousness
        CastSpellByName("Blessing of Might");
    end

    -- 
    CastSpellByName("Judgement");
    CastSpellByName("Holy Strike");

end

-- ====================================================================================================
-- =                                    Is Fishing Pole Equipped ?                                    =
-- ====================================================================================================

function FishingPoleEquipped()
    local Pole = GetInventoryItemTexture("player", GetInventorySlotInfo("MainHandSlot"));
    if (Pole and string.find(Pole, "INV_Fishingpole")) then
        return true
    end
end

-- ====================================================================================================
-- =                                          Priest healing                                          =
-- =                                          NOT TESTED YET                                          =
-- ====================================================================================================

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

-- ====================================================================================================
-- =                                         Priest Smite DPS                                         =
-- ====================================================================================================

function PriestDPS()

-- ########## The macro ##########
-- /run -- CastSpellByName("Smite")
-- /script PriestDPS()

    -- Do we cast fishing and don't fight ?
    if (FishingPoleEquipped() == true) then
        CastSpellByName("Fishing");
        return;
    end

    -- Find a new enermy we can attack.
    if (TargetNewEnemy() == false) then
        return;
    end

    -- Start auto attack.
    AutoAttackStart()

    -- Locals
    local HasInnerFireBuff = false
    local HasMightBuff = false
    -- Loop through own buff.
    for i = 1, 64 do
        if UnitBuff("player",i) then
            -- DEFAULT_CHAT_FRAME:AddMessage(UnitBuff("player",i)) -- Keep this line here for when we have to change check for buff.
        end
        --Do we have Seal of Righteousness up ?
        if UnitBuff("player",i) and string.find(UnitBuff("player",i),"Interface\\Icons\\Spell_Holy_InnerFire") then
            -- Vi fandt Battle Shout.
            HasInnerFireBuff = true
        end
    end
    -- We did not find Inner Fire.
    if (not HasInnerFireBuff) then
        -- Do we know Inner Fire ?
        if (CheckIfSpellIsKnown("Inner Fire", 0) == true) then
            -- Cast Inner Fire.
            CastSpellByName("Inner Fire");
        end
    end

    -- 
    if (CheckIfSpellIsKnown("Smite", 0) == true) then
        CastSpellByName("Smite");
    end


end

-- ====================================================================================================
-- =                             Get a name on what is what button number                             =
-- ====================================================================================================

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

-- ====================================================================================================
-- =                                        Taunt when tanking                                        =
-- ====================================================================================================

function TauntTarget()

-- ########## The macro ##########
-- /run -- CastSpellByName("Taunt") -- Use Growl if your a Druid.
-- /script TauntTarget()

    -- Get name of target of target, player name and player class.
    local target = UnitName("target");
    local targetOfTarget = UnitName("targettarget");
    local myName = UnitName("player");
    local playerClass = UnitClass("player");

    -- Are we a Druid there need to change form ?
    if (playerClass == "Druid") then
        -- Are we in bear form ?
        local Bear = false
        -- Loop gennem egene buff
        for i = 1, 64 do
            if (UnitBuff("player",i)) then
                -- DEFAULT_CHAT_FRAME:AddMessage(UnitBuff("player",i));
            end
            -- Is it Mark of the Wild we found ?
            if UnitBuff("player",i) and string.find(UnitBuff("player", i), "Interface\\Icons\\Ability_Racial_BearForm") then
                Bear = true
            end
        end
        -- We did not find Mark of the Wild, so we cast it.
        if (not Bear) and (CheckIfSpellIsKnown("Bear Form", 0) == true) then
            CastSpellByName("Bear Form");
        end
    end

    -- If the name of target of target is not my name, then taunt the target.
    if (targetOfTarget) and (targetOfTarget ~= myName) then
        -- Are we Warrior or Druid ?
        if (playerClass == "Warrior") then
            CastSpellByName("Taunt");
            DEFAULT_CHAT_FRAME:AddMessage("Taunt used.");
        elseif (playerClass == "Druid") then
            CastSpellByName("Growl");
        -- elseif (playerClass == "Paladin") then
            
        -- elseif (playerClass == "SHAMAN") then
            
        else
            DEFAULT_CHAT_FRAME:AddMessage("You are not playing a class there can taunt.");
        end
    end
end

-- ====================================================================================================
-- =                                          Warrior attack                                          =
-- ====================================================================================================

function WarriorDPS(at1, at2, at3, at4, at5, at6, at7, at8, at9)

-- ########## The macro ##########
-- /run -- CastSpellByName("Heroic Strike")
-- /script WarriorDPS("Rend", "Charge", "Bloodthirst", "Bloodrage", "Overpower") -- Rend ALWAYS have to be number one, if we want to use it.

    -- Do we cast fishing and don't fight ?
    if (FishingPoleEquipped() == true) then
        CastSpellByName("Fishing");
        return;
    end

    -- Find a new enermy we can attack.
    if (TargetNewEnemy() == false) then
        return;
    end

    -- Start auto attack.
    AutoAttackStart()

    -- Locals
    local hasBuff = false
    -- Loop gennem egene buff
    for i = 1, 64 do
        -- Is it Battle Shout we found ?
        if UnitBuff("player",i) and string.find(UnitBuff("player", i), "Interface\\Icons\\Ability_Warrior_BattleShout") then
            -- We found Battle Shout
            hasBuff = true
        end
    end
    -- We did not find Battle Shout, so we cast it.
    if (not hasBuff) then
        -- Cast Battle Shout
        CastSpellByName("Battle Shout");
    end

    -- Check if the attack we want to make is rend, we only do that if target don't already have it on.
    -- We also check if is shitf down ? We need to check, else the loop can stop here if target is immune.
    -- If it's immune, then we can use Shift to not cast Rend.
    if (at1 == "Rend") and (not IsShiftKeyDown()) then
        -- locals
        local i, x = 1, 0
        -- Loop through all debuffs on target to look for Rend icon.
        while (UnitDebuff("target",i)) do
            -- Is the icon the same as the one Rend is using ?
            if (UnitDebuff("target",i) == "Interface\\Icons\\Ability_Gouge") then
                -- We found Rend.
                x = 1
            end
            -- Count up.
            i = i + 1
        end
        -- Locals
        local IsShiftDown = IsShiftKeyDown()
        -- Do we need to cast Rend and is life of target over 30%
        if (x == 0) and (UnitHealth("target") / UnitHealthMax("target") > 0.3) then
            -- Cast Rend
            CastSpellByName("Rend")
        end
    -- at1 was not Rend, so we run what is in at1
    elseif (at1) and (not IsShiftKeyDown()) then
        CastSpellByName(at1);
    end

    -- Check if there is something else we need to do.
    if (at2) then
        CastSpellByName(at2);
    end
    if (at3) then
        CastSpellByName(at3);
    end
    if (at4) then
        CastSpellByName(at4);
    end
    if (at5) then
        CastSpellByName(at5);
    end
    if (at6) then
        CastSpellByName(at6);
    end
    if (at7) then
        CastSpellByName(at7);
    end
    if (at8) then
        CastSpellByName(at8);
    end
    if (at9) then
        CastSpellByName(at9);
    end

end

-- ====================================================================================================
-- =                                           Druid attack                                           =
-- ====================================================================================================

function DruidDPS()

-- ########## The macro ##########
-- /run -- CastSpellByName("Attack")
-- /script DruidDPS()

    -- Do we cast fishing and don't fight ?
    if (FishingPoleEquipped() == true) then
        CastSpellByName("Fishing");
        return;
    end

    -- Find a new enermy we can attack.
    if (TargetNewEnemy() == false) then
        return;
    end

    -- Start auto attack.
    AutoAttackStart()

    -- Locals
    local MotW = false
    local Thorns = false
    -- Loop gennem egene buff
    for i = 1, 64 do
        if (UnitBuff("player",i)) then
            -- DEFAULT_CHAT_FRAME:AddMessage(UnitBuff("player",i));
        end
        -- Is it Mark of the Wild we found ?
        if UnitBuff("player",i) and string.find(UnitBuff("player", i), "Interface\\Icons\\Spell_Nature_Regeneration") then
            MotW = true
        end
        -- Is it Thorns we found ?
        if UnitBuff("player",i) and string.find(UnitBuff("player", i), "Interface\\Icons\\Spell_Nature_Thorns") then
            Thorns = true
        end
    end
    -- We did not find Mark of the Wild, so we cast it.
    if (not MotW) and (CheckIfSpellIsKnown("Mark of the Wild", 0) == true) then
        CastSpellByName("Mark of the Wild");
    end
    -- We did not find Thorns, so we cast it.
    if (not Thorns) and (CheckIfSpellIsKnown("Thorns", 0) == true) then
        CastSpellByName("Thorns");
    end

    CastSpellByName("Wrath");

end

-- ====================================================================================================
-- =                                       Druid bear rotation.                                       =
-- ====================================================================================================

function DruidTank()

-- ########## The macro ##########
-- /run -- CastSpellByName("Maul")
-- /script DruidTank()


    -- Find a new enermy we can attack.
    if (TargetNewEnemy() == false) then
        return;
    end

    -- Start auto attack.
    AutoAttackStart()

    -- Locals
    local MotW = false
    local Thorns = false
    -- Loop gennem egene buff
    for i = 1, 64 do
        if (UnitBuff("player",i)) then
            -- DEFAULT_CHAT_FRAME:AddMessage(UnitBuff("player",i));
        end
        -- Is it Mark of the Wild we found ?
        if UnitBuff("player",i) and string.find(UnitBuff("player", i), "Interface\\Icons\\Spell_Nature_Regeneration") then
            MotW = true
        end
        -- Is it Thorns we found ?
        if UnitBuff("player",i) and string.find(UnitBuff("player", i), "Interface\\Icons\\Spell_Nature_Thorns") then
            Thorns = true
        end
    end
    -- We did not find Mark of the Wild, so we cast it.
    if (not MotW) and (CheckIfSpellIsKnown("Mark of the Wild", 0) == true) then
        --CastSpellByName("Mark of the Wild");
    end
    -- We did not find Thorns, so we cast it.
    if (not Thorns) and (CheckIfSpellIsKnown("Thorns", 0) == true) then
        --CastSpellByName("Thorns");
    end

    CastSpellByName("Maul");

end

-- ====================================================================================================
-- =                                        Druid cat rotation                                        =
-- ====================================================================================================

function DruidCat()

-- ########## The macro ##########
-- /run -- CastSpellByName("Claw")
-- /script DruidCat()

    -- Find a new enermy we can attack.
    if (TargetNewEnemy() == false) then
        return;
    end

    -- Set some locals
    local partyMembers = GetNumPartyMembers()   -- Get group numbers
    local StealthActive = false

    -- Do we use Juju Power ?
    if (UseConsumables == true) and (partyMembers > 0) then
        -- Set locals
        local Juju = false
        -- Loop through all our buffs and look for the Juju Power icon.
        for i = 1, 64 do
            local JujuBuff = UnitBuff("player",i);
            -- Is it Juju Power we found ?
            if ((JujuBuff ~= nil) and (string.find(JujuBuff,"Interface\\Icons\\INV_Misc_MonsterScales_11"))) then
                Juju = true
            end
            -- See if we are in stealth.
            if ((JujuBuff ~= nil) and (string.find(JujuBuff,"Interface\\Icons\\Ability_Ambush"))) then
                StealthActive = true
            end
        end
        -- Do we need to use Juju Power ?
        if (Juju == false) then
            -- Do we have any Juju Power in our bags ?
            for bag = 0, 4 do
                for slotNum = 1, GetContainerNumSlots(bag) do
                -- for slotNum = GetContainerNumSlots(bag), 1, -1 do
                    local itemLink = GetContainerItemLink(bag, slotNum)
                    if itemLink and string.find(string.lower(itemLink), "juju power") then
                        -- We found one, so we use it.
                        UseContainerItem(bag, slotNum)
                    end
                end
            end
        end
    end

    for i = 1, 6 do
        local icon, name, active = GetShapeshiftFormInfo(i);
        if (name == "Cat Form") then
            
        end
    end

    -- Loop through all buff to see if we are in stealth.
    for i = 1, 64 do
        local StealthBuff = UnitBuff("player",i);
        -- Is it Prowl we found ?
        if (StealthBuff) and (string.find(StealthBuff, "Interface\\Icons\\Ability_Ambush")) then
            StealthActive = true
        end
    end

    -- 
    if (StealthActive == true) then
        -- 
        if (CheckIfSpellIsKnown("Cheap Shot", 0) == true) then
            CastSpellByName("Cheap Shot");
        else
            CastSpellByName("Claw");
        end
    end

    -- Do our target have 5 combo points ?
    if (GetComboPoints("target") == 5) then
        if (CheckIfSpellIsKnown("Ferocious Bite", 0) == true) then
            CastSpellByName("Ferocious Bite");
        else
            CastSpellByName("Rip");
        end
    -- Do we have 3 or more combo points and do target have 20% or less health left ? 
    elseif ((GetComboPoints("target") >= 3) and (UnitHealth("target") / UnitHealthMax("target") < 0.2)) then
        if (CheckIfSpellIsKnown("Ferocious Bite", 0) == true) then
            CastSpellByName("Ferocious Bite");
        else
            CastSpellByName("Claw");
        end
    -- Is there 0 combo point on target ?
    elseif (GetComboPoints("target") == 0) then
        CastSpellByName("Claw");
    else
        CastSpellByName("Claw");
    end

    -- Start auto attack if we are not stealth.
    if (StealthActive == false) then
        AutoAttackStart()
    end

end

-- ====================================================================================================
-- =                                 Shoot what ever you have equiped                                 =
-- ====================================================================================================

function Shoot()
    local _, _, i = strfind(GetInventoryItemLink("player",18), "\124Hitem:(%d+)")
    local _, _, _, _, _, p = GetItemInfo(i)
    local t = {} t.Bows = "Bow" t.Guns = "Gun" t.Crossbows = "Crossbow" t.Thrown = "Throw"
    CastSpellByName((string.gsub(t[p], "[^T]","Shoot %1")))
end

-- ====================================================================================================
-- =                                         Warlock rotation                                         =
-- ====================================================================================================

function WarlockRotation()

-- ########## The macro ##########
-- /run -- CastSpellByName("Shadow Bolt")
-- /script WarlockRotation()

    -- Do we cast fishing and don't fight ?
    if (FishingPoleEquipped() == true) then
        CastSpellByName("Fishing");
        return;
    end

    -- Find a new enermy we can attack.
    if (TargetNewEnemy() == false) then
        return;
    end

    -- Start auto attack.
    AutoAttackStart()

    -- Locals
    local DemonArmor = false
    -- Loop through own buff.
    for i = 1, 64 do
        -- Did we find a buff and it it the one we are looking for ?
        if (UnitBuff("player",i)) and (string.find(UnitBuff("player", i), "Interface\\Icons\\Spell_Shadow_RagingScream")) then
            -- Set to true.
            DemonArmor = true
        end
    end

    -- Buff if we don't have it already.
    if DemonArmor ~= true then
        CastSpellByName("Demon Armor")
    end


    if (UnitHealth("player") / UnitHealthMax("player") > 0.9) and (UnitMana("player") / UnitManaMax("player") < 0.8) then
        if (CheckIfSpellIsKnown("Life Tap", 0) == true) then
            CastSpellByName("Life Tap");
        else
            CastSpellByName("Shadow Bolt");
        end
    else
        CastSpellByName("Shadow Bolt");
    end

    -- Pet attack
    PetAttack(target)

    -- Delete Soul Shards so we don't drown in them.
    SoulShardDelete(84)
end

-- ====================================================================================================
-- =                                 Auto delete Warlock Soul Shards.                                 =
-- ====================================================================================================

function SoulShardDelete(int)

    -- Count how many Soul Shards we have.
    local ShardCount = 0
    for bag = 4, 0, -1 do
        for slotNum = GetContainerNumSlots(bag), 1, -1 do
            local itemLink = GetContainerItemLink(bag, slotNum)
            if itemLink and string.find(itemLink, "Soul Shard") then
                local _, count = GetContainerItemInfo(bag, slotNum)
                ShardCount = ShardCount + count
                -- Do we have more shards then we want to have ?
                if (ShardCount > int) then
                    PickupContainerItem(bag, slotNum)
                    DeleteCursorItem()
                end
            end
        end
    end

end

-- ====================================================================================================
-- =                                          Mage rotation.                                          =
-- ====================================================================================================

function MageRotation(spec)

-- ########## The macro ##########
-- /run -- CastSpellByName("Frostbolt")
-- /script MageRotation("Frost")
-- or
-- /run -- CastSpellByName("Fire")
-- /script MageRotation("Fireball")
-- or
-- /run -- CastSpellByName("Arcane Missiles")
-- /script MageRotation("Frost")

    -- Do we cast fishing and don't fight ?
    if (FishingPoleEquipped() == true) then
        CastSpellByName("Fishing");
        return;
    end

    -- Find a new enermy we can attack.
    if (TargetNewEnemy() == false) then
        return;
    end

    -- Start auto attack.
    AutoAttackStart()

    -- Locals
    local Armor = false
    local Intellect = false
    -- Loop through own buff.
    for i = 1, 64 do
        -- DEFAULT_CHAT_FRAME:AddMessage(UnitBuff("player", i));
        -- Did we find a buff and it it the one we are looking for ?
        if (UnitBuff("player",i)) and (string.find(UnitBuff("player", i), "Interface\\Icons\\Spell_Frost_FrostArmor02")) then
            -- Set to true.
            Armor = true
        elseif ((UnitBuff("player",i)) and (string.find(UnitBuff("player", i), "Interface\\Icons\\Spell_Holy_MagicalSentry"))) then
            -- Set to true.
            Intellect = true
        end
    end

    -- Buff if we don't have it already.
    if (Armor ~= true) then
        CastSpellByName("Frost Armor")
    end
    -- Buff intellect if we don't have it already.
    if (Intellect ~= true) then
        CastSpellByName("Arcane Intellect")
    end

    CastSpellByName("Frostbolt");

end

-- ====================================================================================================
-- =                                      Register unknown zone.                                      =
-- ====================================================================================================

function RegisterZone()

    local CurrentNewZone = GetRealZoneText()

    -- Make sure our tables is created.
    if (not NewZones) or (not type(NewZones) == "table") then
        NewZones = {}
    end

    -- 
    if (CurrentNewZone ~= nil) and (not NewZones[CurrentNewZone]) then
        NewZones[CurrentNewZone] = "Unknown"
    end

end

-- ====================================================================================================
-- =                                        Guild Recruitment.                                        =
-- ====================================================================================================

function GuildRecruitment()

    -- Stop recruitment if we are AFK or DND, no need to recruit if people can't write to us.
    if (StopGuildRecruit == true) then
        -- Add 1 min to the timer so we don't just spam trying to run it.
        RecruitTime = (GetTime() + 60)
        return;
    end

    -- The recruitment messages.
    local RecruitmentMessages = {

        "<Group Therapy> EU: Seeking Healers for Naxxramas progression. Raid days: Thu/Sun 19:30 - 22:30 CET. MC, BWL and AQ40 clear every week. SR+ loot system. We're a friendly, active guild, come join us!",
        "<Group Therapy> EU: Seeking Healers for Naxx progression. Raid days: Thu/Sun 19:30-22:30 CET. All previous content on farm. SR+ loot. Friendly, active guild!",
        "<Group Therapy> EU: Healers for Naxx progression! Raid days Thu/Sun 19:30-22:30 CET. All previous content on farm. SR+ for transparent loot. Friendly guild, good vibes.",
        "<Group Therapy> EU: Seeking strong Healers for Naxxramas progression. Raid schedule: Thu/Sun 19:30-22:30 CET. Full clear of previous content. SR+ loot system. Apply now!",
        "<Group Therapy> EU: Naxx progression requires more Healers! Raid days Thu/Sun 19:30-22:30 CET. MC, BWL, AQ40 on weekly farm. SR+ loot. Join our active guild!",
        "<Group Therapy> EU: Recruiting Healers for Naxx progression! Raid days Thu/Sun 19:30-22:30 CET. Consistent clears of MC, BWL, AQ40. SR+ loot. Be part of our success!",
        "<Group Therapy> EU: Recruiting more Healers for Naxx progression. Raid days Thu/Sun 19:30-22:30 CET. All previous content cleared. SR+ loot. Be part of our Naxx journey!",
        -- "<Group Therapy> EU: New guild forming! Join our friendly and mature community. We're building a strong core group with raiding plans coming soon. Expect plenty of laughs along the way.",
        -- "<Group Therapy> EU: Tired of the same old guild drama? <Group Therapy> EU is a new guild forming with a focus on fun, friendship, and (occasionally) serious raiding.",
        -- "<Group Therapy> EU: Looking for a mature and friendly guild with a focus on casual raiding? Join <Group Therapy> EU! We're a new guild forming with plenty of laughs and in-jokes planned.",
        -- "<Group Therapy> EU: New guild forming! <Group Therapy> EU is recruiting friendly and mature players for casual raiding. We're building a community where you can be yourself and have fun.",
        -- "<Group Therapy> EU: Join <Group Therapy> EU, a new guild forming for mature players who enjoy raiding and appreciate a good laugh. We're building a strong community together.",
        -- "<Group Therapy> EU is a new guild forming for mature players who enjoy raiding and appreciate a good laugh. Join us as we build a strong community together.",

        -- "<Group Therapy> EU is recruiting! We're a new guild forming with a focus on friendly raiding and mature humor. Expect occasional chaos and definitely some wipes.",
        -- "<Group Therapy> EU: New guild forming! We're a friendly and mature guild with raid plans in the works. Expect plenty of laughs and maybe a few accidental wipes.",
        -- "<Group Therapy> EU: Looking for a new guild? <Group Therapy> EU is forming! We're a friendly and mature guild with a focus on casual raiding and a healthy dose of sarcasm.",
        -- "<Group Therapy> EU: Looking for a new guild? <Group Therapy> EU is forming! We're a friendly and mature guild with raid plans in the works. Expect plenty of laughs and occasional chaos.",
        -- "<Group Therapy> EU: Looking for a new guild? <Group Therapy> EU is forming! We're a friendly and mature guild with raid plans in the works. Join us for fun, laughter, and maybe a few epic fails.",
        -- "<Group Therapy> EU: New guild forming! Join our community and experience raiding with a friendly and mature group. We're planning raids and looking for fun-loving players.",
        -- "<Group Therapy> EU: New guild forming! Join our community of mature and friendly raiders. We're building a relaxed raiding environment with a focus on fun and friendship.",
        -- "<Group Therapy> EU: New guild forming! Join our community of mature and friendly raiders. We're planning raids and looking for players with a good sense of humor.",
        -- "<Group Therapy> EU: New guild forming! Join our friendly and mature community. We're planning raids and looking for fun-loving players who don't take themselves too seriously.",
        -- "<Group Therapy> EU: New guild forming! Join our friendly and mature community. We're building a fun raiding environment with a touch of sarcasm. Raid plans coming soon!",
        -- "<Group Therapy> EU: New guild forming! Join our community of mature and friendly raiders. We're building a relaxed environment with raid plans on the horizon.",
        -- "<Group Therapy> EU: New guild forming! Join our friendly and mature community. We're building a relaxed raiding environment with a focus on fun and friendship.",
        -- "<Group Therapy> EU: Tired of the usual guild drama? <Group Therapy> EU is forming! We're a friendly and mature guild with raid plans in the works. Come join the fun!",
        -- "<Group Therapy> EU: Tired of the usual guild drama? Join <Group Therapy> EU! We're a new guild forming with a focus on friendly raiding and mature humor.",
        -- "<Group Therapy> EU: Tired of the usual guild drama? <Group Therapy> EU is forming! We're a friendly and mature guild with raid plans in the works. Expect plenty of laughs along the way.",

        -- "<Group Therapy> is forming! Join our new EU guild for a relaxed and friendly atmosphere. No drama, no stress. Just good old-fashioned fun! All classes and specs welcome.",
        -- "<Group Therapy> EU is recruiting! Join our new guild and make friends while we build a community. Raiding plans in the works! No experience required.",
        -- "Looking for a new home? <Group Therapy> EU is recruiting for all roles. Let's grow together and experience WoW's adventures. Raids coming soon!",
        -- "<Group Therapy> EU is forming! Join our friendly guild and be part of something new. We're building a fun and supportive community. Raiding plans in the works!",
        -- "Need a new guild? <Group Therapy> EU is here for you! Join our friendly bunch and let's have some fun. Raiding plans in the works.",
        -- "Join <Group Therapy> EU, a new guild looking for friendly faces! We're building a community focused on fun and camaraderie. Raiding plans are in the works for those interested.",
        -- "Don't miss out! <Group Therapy> EU is forming now. Be one of the founding members of our new guild and help shape our future.",

        -- "<Group Therapy> EU is recruiting for a new raiding guild. Join our friendly community and help us clear content. All classes and roles welcome.",
        -- "Looking to progress in WoW? <Group Therapy> EU is recruiting! We're a new guild focused on building a strong raid team. All classes and roles welcome.",
        -- "<Group Therapy> EU is a supportive guild that welcomes players of all skill levels. We're here to help you grow as a player.",
        -- "<Group Therapy> EU: Tired of being told you're not good enough? Join us, where we'll tell you you're exactly good enough to wipe the floor with our guildmates.",
        -- "<Group Therapy> EU: Tired of guilds that take themselves too seriously? Join us! We're a casual raiding guild where we laugh at our mistakes (and yours).",
        -- "<Group Therapy> EU: Tired of toxic guilds? Experience a breath of fresh air with <Group Therapy> EU. We're a casual raiding guild that prioritizes fun, friendship, and a relaxed atmosphere.",
        -- "<Group Therapy> EU: Looking for a guild that balances serious raiding with plenty of laughs? Look no further! <Group Therapy> EU offers a supportive community and a fun raiding environment.",
        -- "<Group Therapy> EU: Tired of toxic guilds? Join <Group Therapy> EU and experience a guild where everyone is welcome and valued.",
        -- "<Group Therapy> EU: We're a guild that believes in having fun while progressing. If you're looking for a balance of both, look no further.",

    }

    -- All the zones in the game.
    local Zones = {
        -- Original zones from WoW Vanilla.
        ["Dun Morogh"] = true,
        ["Durotar"] = true,
        ["Elwynn Forest"] = true,
        ["Mulgore"] = true,
        ["Teldrassil"] = true,
        ["Tirisfal Glades"] = true,
        ["Darkshore"] = true,
        ["Loch Modan"] = true,
        ["Silverpine Forest"] = true,
        ["Westfall"] = true,
        ["The Barrens"] = true,
        ["Redridge Mountains"] = true,
        ["Stonetalon Mountains"] = true,
        ["Ashenvale"] = true,
        ["Duskwood"] = true,
        ["Hillsbrad Foothills"] = true,
        ["Wetlands"] = true,
        ["Thousand Needles"] = true,
        ["Alterac Mountains"] = true,
        ["Arathi Highlands"] = true,
        ["Desolace"] = true,
        ["Stranglethorn Vale"] = true,
        ["Dustwallow Marsh"] = true,
        ["Badlands"] = true,
        ["Swamp of Sorrows"] = true,
        ["Feralas"] = true,
        ["The Hinterlands"] = true,
        ["Tanaris"] = true,
        ["Searing Gorge"] = true,
        ["Azshara"] = true,
        ["Blasted Lands"] = true,
        ["Un'Goro Crater"] = true,
        ["Felwood"] = true,
        ["Burning Steppes"] = true,
        ["Western Plaguelands"] = true,
        ["Eastern Plaguelands"] = true,
        ["Blackrock Mountain"] = true,
        ["Winterspring"] = true,
        ["Deadwind Pass"] = true,
        ["Moonglade"] = true,
        ["Silithus"] = true,
        ["Gates of Ahn'Qiraj"] = true,
        ["The Great Sea"] = true,
        ["Scarlet Monastery"] = true,
        ["Deeprun Tram"] = true,

        -- Citys.
        ["Undercity"] = true,
        ["Orgrimmar"] = true,
        ["Thunder Bluff"] = true,
        ["Stormwind City"] = true,
        ["Ironforge"] = true,
        ["Darnassus"] = true,

        -- Dungeons and raids where we don't want to recruit.
        ["Ragefire Chasm"] = "Nope",
        ["Wailing Caverns"] = "Nope",
        -- The Deadmines
        ["Shadowfang Keep"] = "Nope",
        --The Stockade
        ["Blackfathom Deeps"] = "Nope",
        ["Gnomeregan"] = "Nope",
        ["Razorfen Kraul"] = "Nope",
        ["Scarlet Monastery Graveyard"] = "Nope",
        ["Scarlet Monastery Library"] = "Nope",
        -- Scarlet Monastery Armory
        ["Scarlet Monastery Cathedral"] = "Nope",
        ["Razorfen Downs"] = "Nope",
        ["Uldaman"] = "Nope",
        -- Zul'Farrak
        ["Maraudon"] = "Nope",
        ["The Temple of Atal'Hakkar"] = "Nope",
        ["Blackrock Depths"] = "Nope",
        ["Blackrock Spire"] = "Nope",
        ["Scholomance"] = "Nope",
        ["Stratholme"] = "Nope",
        ["Dire Maul"] = "Nope",
        -- Raids
        ["Zul'Gurub"] = "Nope",
        ["Molten Core"] = "Nope",
        ["Onyxia's Lair"] = "Nope",
        ["Ruins of Ahn'Qiraj"] = "Nope",
        ["Blackwing Lair"] = "Nope",
        -- AQ40
        ["Naxxramas"] = "Nope",

        -- Battlegrounds where we don't want to recruit.
        ["Warsong Gulch"] = "Nope",

        -- New zones in Turtle WoW.
        ["Gilneas"] = true,
        ["Tel'Abim"] = true,
        ["Gillijim's Isle"] = true,
        ["Hyjal"] = true,
        ["Winter Veil Vale"] = true,
        ["Blackstone Island"] = true,
        ["Amani'Alor"] = true,
        ["Scarlet Enclave"] = true,
        ["Caverns of Time"] = true,
        ["Thalassian Highlands"] = true,
        ["Lapidis Isle"] = true,

        --  New citys in Turtle WoW.
        ["Alah'Thalas"] = true,

        -- New dungeons and raids in Turtle WoW where we don't want to recruit.
        ["Stormwind Vault"] = "Nope",
        ["Tower of Karazhan"] = "Nope",
        ["Crescent Grove"] = "Nope",
        ["The Black Morass"] = "Nope",
        ["Gilneas City"] = "Nope",
        ["Emerald Sanctum"] = "Nope",

        -- New battlegrounds in Turtle WoW where we don't want to recruit.
        

    }

    -- Get our current zone.
    local Zone = GetRealZoneText()

    -- Check that we are in a guild.
    if (IsInGuild()) then

        -- Get the info from the guild that we need.
        local GuildName, GuildRank, GuildRankIndex = GetGuildInfo("player")

        -- Check that we are in a guild and that guild is Group Therapy and that we have a guild rank of 3 or lower. (0 = Guild Master)
        if (GuildName) and (GuildName == "Group Therapy") and (GuildRankIndex <= 3) then
            -- Check that we are in a zone where we want to recruit.
            if (Zones[Zone] == true) then
                -- Find the numbers of recruitment lines.
                local count = 0
                for _ in pairs(RecruitmentMessages) do
                    count = count + 1
                end
                -- 
                local RandomIndex = math.random(1, count)
                -- Get the number of general channel
                local ChannelId, ChannelName
                for i = 1, 20 do
                    -- Get the number and the name of the channel.
                    ChannelId, ChannelName = GetChannelName(i);
                    -- Did we get a name and are there general in the name.
                    if (ChannelName) and (string.find(string.lower(ChannelName), "general")) then
                        -- Send our message.
                        SendChatMessage(RecruitmentMessages[RandomIndex], "CHANNEL", nil, ChannelId)
                        -- Reset timer.
                        RecruitTime = GetTime()
                    end
                end
                -- Check all the zones that we have found also is in the zones we want to recruit in.
                for zoneName, _ in pairs(NewZones) do
                    if (not Zones[zoneName]) then
                        NewZones[zoneName] = "Unknow zone, so if your the one updating this addon, then you need to make a dession about this zone. :)"
                    else
                        NewZones[zoneName] = "Found."
                    end
                end
            end
        end
    end

end

-- ====================================================================================================
-- =                         Auto invite Hardcore players back after they die                         =
-- ====================================================================================================

function HardcoreInvite()

    --GuildInvite(playername)

end


-- ====================================================================================================
-- =                                            TEST AREA.                                            =
-- =                              DON'T EXPECT ANYTHING TO WORK HERE. :)                              =
-- ====================================================================================================

function Test()

    

end






