
-- ====================================================================================================
-- =                                          Tank rotation.                                          =
-- ====================================================================================================

-- ########## The macro ##########
-- /run -- CastSpellByName("Attack")
-- /script PalaTank("Righteousness", "Wisdom")
-- Use: Righteousness - Wisdom - Light - 
-- First one is what seal you want to have on your self, 2nd is what you want on target.

function PalaTank(SelfSeal, SealOnMob)

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
    local HasRighteousnessSeal = false
    local HasWisdomSeal = false
    local HasLightSeal = false
    local HasMightBuff = false
    local HasWisdomBuff = false
    -- Loop through our own buffs.
    for i = 1, 64 do
        if UnitBuff("player",i) then
            -- DEFAULT_CHAT_FRAME:AddMessage(UnitBuff("player",i)) -- Keep this line here for when we have to change check for buff.
        end
        --Do we have Blessing of Might up ?
        if UnitBuff("player",i) and string.find(UnitBuff("player",i),"Interface\\Icons\\Spell_Holy_FistOfJustice") then
            -- We found Blessing of Might
            HasMightBuff = true
        end
        -- Do we have Blessing of Wisdom up ?
        if UnitBuff("player",i) and string.find(UnitBuff("player",i),"Interface\\Icons\\Spell_Holy_SealOfWisdom") then
            HasWisdomBuff = true
        end

        -- Do we have Seal of Wisdom up ?
        if UnitBuff("player",i) and string.find(UnitBuff("player",i),"Interface\\Icons\\Spell_Holy_RighteousnessAura") then
            HasWisdomSeal = true
        end
        --Do we have Seal of Righteousness up ?
        if UnitBuff("player",i) and string.find(UnitBuff("player",i),"Interface\\Icons\\Ability_ThunderBolt") then
            -- We found Seal of Righteousness.
            HasRighteousnessSeal = true
        end
        --Do we have Seal of Light up ?
        if UnitBuff("player",i) and string.find(UnitBuff("player",i),"") then
            -- We found Seal of Light.
            HasLightSeal = true
        end
    end

    -- locals
    local i = 1
    local TargetHasWisdomSeal = false

    -- Loop through all debuffs on target.
    for i = 1, 64 do
        local TargetDebuff = UnitDebuff("target",i);
        if (TargetDebuff) then
            -- DEFAULT_CHAT_FRAME:AddMessage(TargetDebuff) -- Keep this line here for when we have to change check for buff.
        end
        if (TargetDebuff) and (string.find(TargetDebuff,"Interface\\Icons\\Spell_Holy_RighteousnessAura")) then
            TargetHasWisdomSeal = true
        end
    end

-- Find the spell id from our spell book.
function FindSpellId(FindSpellName)
    -- Loop through all spells we have in the spell book.
    for i = 1, 300 do
        -- Get the name of the spell.
        local SpellName = GetSpellName(i, "bookType")
        -- Is it the name of the spell we are looking for ?
        if (SpellName == FindSpellName) then
            -- Return the number of the spell in the spell book.
            return i
        end
    end
end





    -- Have we learned "Holy Shield" ?
    if (CheckIfSpellIsKnown("Holy Shield", 0) == true) then
        -- Get the cooldown on the spell from the spell book.
        local SpellCoolDown = GetSpellCooldown(FindSpellId("Holy Shield"), "bookType");
        -- If it's off cooldown, then cast it.
        if (SpellCoolDown == 0) then
            CastSpellByName("Holy Shield");
        end
    end
        
    -- Check to see if we have to Judge the target to get Wisdome on it.
    if (SealOnMob == "Wisdom") and (TargetHasWisdomSeal == false) and (HasWisdomSeal) then
        CastSpellByName("Judgement");
    -- 
    elseif (SealOnMob == "Wisdom") and (TargetHasWisdomSeal == false) and (not HasWisdomSeal) then
        CastSpellByName("Seal of " .. SealOnMob);
    -- 
    elseif (SealOnMob == "Wisdom") and (TargetHasWisdomSeal == true) and (not HasWisdomSeal) then
        CastSpellByName("Seal of " .. SelfSeal);
    -- 
    elseif (SealOnMob == "Wisdom") and (TargetHasWisdomSeal == true) and (HasRighteousnessSeal) then
        CastSpellByName("Judgement");
    end

    -- 
    if (CheckIfSpellIsKnown("Holy Strike", 0) == true) then
        CastSpellByName("Holy Strike");
    end

end


-- ====================================================================================================
-- =                                           DPS rotation                                           =
-- ====================================================================================================



-- ====================================================================================================
-- =                                             Healing.                                             =
-- ====================================================================================================



-- ====================================================================================================
-- =                                             Buffing.                                             =
-- ====================================================================================================



-- ====================================================================================================
-- =                                             Ress                                             =
-- ====================================================================================================

