function onInit()
    Debug.console("manager_action_damage_osric.lua", "init")
    ActionDamage.applyDamage = applyDamageNew
    ActionDamage.modDamage = modDamageNew
end

-- brought this in to later remove critical options
function modDamageNew(rSource, rTarget, rRoll)
    ActionDamage.decodeDamageTypes(rRoll)
    CombatManager2.addRightClickDiceToClauses(rRoll)

    -- Set up
    local aAddDesc = {}
    local aAddDice = {}
    local nAddMod = 0

    -- Build attack type filter
    local aAttackFilter = {}
    if rRoll.range == "R" then
        table.insert(aAttackFilter, "ranged")
    elseif rRoll.range == "M" then
        table.insert(aAttackFilter, "melee")
    elseif rRoll.range == "P" then
        table.insert(aAttackFilter, "psionic")
    end

    -- Track how many damage clauses before effects applied
    local nPreEffectClauses = #(rRoll.clauses)

    -- Determine critical
    rRoll.sCriticalType = ""
    local bCritical =
        ModifierStack.getModifierKey("DMG_CRIT") or Input.isShiftPressed() or ActionAttack.isCrit(rSource, rTarget)

    -- If source actor, then get modifiers
    if rSource then
        local bEffects = false
        local aEffectDice = {}
        local nEffectMod = 0

        -- -- Apply ability modifiers
        -- for _,vClause in ipairs(rRoll.clauses) do
        -- local nBonusStat, nBonusEffects = ActorManagerADND.getAbilityEffectsBonus(rSource, vClause.stat);
        -- if nBonusEffects > 0 then
        -- bEffects = true;
        -- local nMult = vClause.statmult or 1;
        -- if nBonusStat > 0 and nMult ~= 1 then
        -- nBonusStat = math.floor(nMult * nBonusStat);
        -- end
        -- nEffectMod = nEffectMod + nBonusStat;
        -- vClause.modifier = vClause.modifier + nBonusStat;
        -- rRoll.nMod = rRoll.nMod + nBonusStat;
        -- end
        -- end

        -- Apply multiplier damage modifiers from DMGX effect
        local aAddDice_Multiplier, nAddMod_Multiplier, nEffectCount_Multiplier =
            EffectManager5E.getEffectsBonus(rSource, {"DMGX"}, false, aAttackFilter, rTarget)
        if nEffectCount_Multiplier > 0 then
            local nSubTotal = StringManager.evalDice(aAddDice_Multiplier, nAddMod_Multiplier)
            rRoll.nDamageMultiplier = nSubTotal
        end

        -- Apply general damage modifiers
        local aEffects, nEffectCount =
            EffectManager5E.getEffectsBonusByType(rSource, "DMG", true, aAttackFilter, rTarget)
        if nEffectCount > 0 then
            local sEffectBaseType = ""
            if #(rRoll.clauses) > 0 then
                sEffectBaseType = rRoll.clauses[1].dmgtype or ""
            end

            for _, v in pairs(aEffects) do
                local bCritEffect = false
                local aEffectDmgType = {}
                local aEffectSpecialDmgType = {}
                for _, sType in ipairs(v.remainder) do
                    if StringManager.contains(DataCommon.specialdmgtypes, sType) then
                        table.insert(aEffectSpecialDmgType, sType)
                        if sType == "critical" then
                            bCritEffect = true
                        end
                    elseif StringManager.contains(DataCommon.dmgtypes, sType) then
                        table.insert(aEffectDmgType, sType)
                    end
                end

                if not bCritEffect or bCritical then
                    bEffects = true

                    local rClause = {}

                    rClause.dice = {}
                    for _, vDie in ipairs(v.dice) do
                        table.insert(aEffectDice, vDie)
                        table.insert(rClause.dice, vDie)
                        if rClause.reroll then
                            table.insert(rClause.reroll, 0)
                        end
                        if vDie:sub(1, 1) == "-" then
                            table.insert(rRoll.aDice, "-p" .. vDie:sub(3))
                        else
                            table.insert(rRoll.aDice, "p" .. vDie:sub(2))
                        end
                    end

                    nEffectMod = nEffectMod + v.mod
                    rClause.modifier = v.mod
                    rRoll.nMod = rRoll.nMod + v.mod

                    rClause.stat = ""

                    if #aEffectDmgType == 0 then
                        table.insert(aEffectDmgType, sEffectBaseType)
                    end
                    for _, vSpecialDmgType in ipairs(aEffectSpecialDmgType) do
                        table.insert(aEffectDmgType, vSpecialDmgType)
                    end
                    rClause.dmgtype = table.concat(aEffectDmgType, ",")

                    table.insert(rRoll.clauses, rClause)
                end
            end -- for
        end

        -- Apply damage type modifiers
        local aEffects = EffectManager5E.getEffectsByType(rSource, "DMGTYPE", nil, rTarget)
        local aAddTypes = {}
        for _, v in ipairs(aEffects) do
            for _, v2 in ipairs(v.remainder) do
                local aSplitTypes = StringManager.split(v2, ",", true)
                for _, v3 in ipairs(aSplitTypes) do
                    table.insert(aAddTypes, v3)
                end
            end
        end

        -- add DMG table 48 npc hit dice/magic effectiveness damage type here.
        -- do things here
        local sAddedDMGType = getTable48HitDiceVsImmunity(rSource)
        if sAddedDMGType then
            table.insert(aAddTypes, sAddedDMGType)
        end
        --

        if #aAddTypes > 0 then
            for _, vClause in ipairs(rRoll.clauses) do
                local aSplitTypes = StringManager.split(vClause.dmgtype, ",", true)
                for _, v2 in ipairs(aAddTypes) do
                    if not StringManager.contains(aSplitTypes, v2) then
                        if vClause.dmgtype ~= "" then
                            vClause.dmgtype = vClause.dmgtype .. "," .. v2
                        else
                            vClause.dmgtype = v2
                        end
                    end
                end
            end
        end

        -- Apply condition modifiers
        if EffectManager5E.hasEffect(rSource, "Incorporeal") then
            bEffects = true
            table.insert(aAddDesc, "[INCORPOREAL]")
        end

        -- Add note about effects
        if bEffects then
            local sEffects = ""
            nEffectMod = math.floor(nEffectMod + 0.5)
            local sMod = StringManager.convertDiceToString(aEffectDice, nEffectMod, true)
            if sMod ~= "" then
                sEffects = "[" .. Interface.getString("effects_tag") .. " " .. sMod .. "]"
            else
                sEffects = "[" .. Interface.getString("effects_tag") .. "]"
            end
            table.insert(aAddDesc, sEffects)
        end
    end

    -- Handle critical
    local sOptCritType = OptionsManager.getOption("HouseRule_CRIT_TYPE")
    -- no bonus for crit hit
    if bCritical and sOptCritType == "none" then
        -- max damage for crit hit
        -- or x2 damage for crit hit
        rRoll.bCritical = false
        rRoll.sCriticalType = "none"
    elseif bCritical and (sOptCritType == "max" or sOptCritType == "timestwo") then
        -- double damage dice for crit hit
        rRoll.bCritical = true
        rRoll.sCriticalType = sOptCritType
        table.insert(aAddDesc, "[CRITICAL]")
        local aNewClauses = {}
        -- add "critical" to damage type
        for kClause, vClause in ipairs(rRoll.clauses) do
            if (vClause.dmgtype and vClause.dmgtype == "") then
                vClause.dmgtype = "critical"
            else
                vClause.dmgtype = vClause.dmgtype .. ",critical"
            end
            table.insert(aNewClauses, vClause)
        end
        rRoll.clauses = aNewClauses
    elseif bCritical then
        rRoll.bCritical = true
        rRoll.sCriticalType = sOptCritType
        table.insert(aAddDesc, "[CRITICAL]")

        -- Double the dice, and add extra critical dice
        local nOldDieIndex = 1
        local aNewClauses = {}
        local aNewDice = {}
        local nMaxSides = 0
        local nMaxClause = 0
        local nMaxDieIndex = 0
        for kClause, vClause in ipairs(rRoll.clauses) do
            table.insert(aNewClauses, vClause)

            local bApplyCritToClause = true
            local aSplitByDmgType = StringManager.split(vClause.dmgtype, ",", true)
            for _, vDmgType in ipairs(aSplitByDmgType) do
                if vDmgType == "critical" then
                    bApplyCritToClause = false
                    break
                end
            end

            for _, vDie in ipairs(vClause.dice) do
                table.insert(aNewDice, rRoll.aDice[nOldDieIndex])
                nOldDieIndex = nOldDieIndex + 1
            end

            if bApplyCritToClause then
                local bNewMax = false
                local aCritClauseDice = {}
                local aCritClauseReroll = {}
                for kDie, vDie in ipairs(vClause.dice) do
                    if vDie:sub(1, 1) == "-" then
                        table.insert(aNewDice, "-g" .. vDie:sub(3))
                    else
                        table.insert(aNewDice, "g" .. vDie:sub(2))
                    end
                    table.insert(aCritClauseDice, vDie)
                    if vClause.reroll then
                        table.insert(aCritClauseReroll, vClause.reroll[kDie])
                    end

                    if kClause <= nPreEffectClauses and vDie:sub(1, 1) ~= "-" then
                        local nDieSides = tonumber(vDie:sub(2)) or 0
                        if nDieSides > nMaxSides then
                            bNewMax = true
                            nMaxSides = nDieSides
                        end
                    end
                end

                if #aCritClauseDice > 0 then
                    local rNewClause = {dice = {}, reroll = {}, modifier = 0, stat = "", bCritical = true}
                    if vClause.dmgtype == "" then
                        rNewClause.dmgtype = "critical"
                    else
                        rNewClause.dmgtype = vClause.dmgtype .. ",critical"
                    end
                    for kDie, vDie in ipairs(aCritClauseDice) do
                        table.insert(rNewClause.dice, vDie)
                        table.insert(rNewClause.reroll, aCritClauseReroll[kDie])
                    end
                    table.insert(aNewClauses, rNewClause)

                    if bNewMax then
                        nMaxClause = #aNewClauses
                        nMaxDieIndex = #aNewDice + 1
                    end
                end
            end
        end
        if nMaxSides > 0 then
            local nCritDice = 0
            if rRoll.bWeapon and ActorManager.isPC(rSource) then
                local nodePC = ActorManager.getCreatureNode(rSource)
                if rRoll.range == "R" then
                    nCritDice = DB.getValue(nodePC, "weapon.critdicebonus.ranged", 0)
                elseif rRoll.range == "M" then
                    nCritDice = DB.getValue(nodePC, "weapon.critdicebonus.melee", 0)
                elseif rRoll.range == "P" then
                -- no crits on psionics
                --nCritDice = DB.getValue(nodePC, "weapon.critdicebonus.melee", 0);
                end
            end

            if nCritDice > 0 then
                for i = 1, nCritDice do
                    table.insert(aNewDice, nMaxDieIndex, "g" .. nMaxSides)
                    table.insert(aNewClauses[nMaxClause].dice, "d" .. nMaxSides)
                    if aNewClauses[nMaxClause].reroll then
                        table.insert(aNewClauses[nMaxClause].reroll, aNewClauses[nMaxClause].reroll[1])
                    end
                end
            end
        end
        local aFinalClauses = {}
        for _, vClause in ipairs(aNewClauses) do
            table.insert(rRoll.clauses, vClause)
        end
        --rRoll.clauses = aNewClauses;
        rRoll.aDice = aNewDice
    end

    -- Handle fixed damage option
    if not ActorManager.isPC(rSource) and OptionsManager.isOption("NPCD", "fixed") then
        local aFixedClauses = {}
        local aFixedDice = {}
        local nFixedPositiveCount = 0
        local nFixedNegativeCount = 0
        local nFixedMod = 0

        for kClause, vClause in ipairs(rRoll.clauses) do
            if kClause <= nPreEffectClauses then
                local nClauseFixedMod = 0
                for kDie, vDie in ipairs(vClause.dice) do
                    if vDie:sub(1, 1) == "-" then
                        nFixedNegativeCount = nFixedNegativeCount + 1
                        nClauseFixedMod = nClauseFixedMod - math.floor(math.ceil(tonumber(vDie:sub(3)) or 0) / 2)
                        if nFixedNegativeCount % 2 == 0 then
                            nClauseFixedMod = nClauseFixedMod - 1
                        end
                    else
                        nFixedPositiveCount = nFixedPositiveCount + 1
                        nClauseFixedMod = nClauseFixedMod + math.floor(math.ceil(tonumber(vDie:sub(2)) or 0) / 2)
                        if nFixedPositiveCount % 2 == 0 then
                            nClauseFixedMod = nClauseFixedMod + 1
                        end
                    end
                    vClause.modifier = vClause.modifier + nClauseFixedMod
                end
                vClause.dice = {}
                nFixedMod = nFixedMod + nClauseFixedMod
            else
                for _, vDie in ipairs(vClause.dice) do
                    if vClause.bCritical then
                        if vDie:sub(1, 1) == "-" then
                            table.insert(aFixedDice, "-g" .. vDie:sub(3))
                        else
                            table.insert(aFixedDice, "g" .. vDie:sub(2))
                        end
                    else
                        table.insert(aFixedDice, vDie)
                    end
                end
            end
            table.insert(aFixedClauses, vClause)
        end

        rRoll.clauses = aFixedClauses
        rRoll.aDice = aFixedDice
        rRoll.nMod = rRoll.nMod + nFixedMod
    end

    -- if using multiplier, mutiply the modifier
    -- for DMGX
    if rRoll.nDamageMultiplier then
        local nMultiplier = rRoll.nDamageMultiplier
        if nMultiplier < 0 then
            nMultiplier = 1
        end
        rRoll.nMod = math.floor(rRoll.nMod * nMultiplier)
    end

    -- Handle damage modifiers
    local bMax = ModifierStack.getModifierKey("DMG_MAX")
    if bMax then
        table.insert(aAddDesc, "[MAX]")
    end
    local bHalf = ModifierStack.getModifierKey("DMG_HALF")
    if bHalf then
        table.insert(aAddDesc, "[HALF]")
    end

    -- Add notes to roll description
    if #aAddDesc > 0 then
        rRoll.sDesc = rRoll.sDesc .. " " .. table.concat(aAddDesc, " ")
    end

    -- Add damage type info to roll description
    ActionDamage.encodeDamageTypes(rRoll)

    -- Apply desktop modifiers
    ActionsManager2.encodeDesktopMods(rRoll)
end

-- brought this is to handle Death's Door changes, TODO: apply new Death's Door Threshold options
function applyDamageNew(rSource, rTarget, bSecret, sDamage, nTotal, aDice)
    Debug.console("manager_action_damage_osric.lua", "applyDamageNew", "aDice", aDice)
    -- Get health fields
    local sTargetType, nodeTarget = ActorManager.getTypeAndNode(rTarget)

    local nAdjustedDamage = 0
    local nDmgBeyondTotalHp = 0

    local nTotalHP, nTempHP, nWounds, nPrevWounds, nDeathSaveSuccess, nDeathSaveFail, nCurrentHp

    if sTargetType == "pc" then
        nTotalHP = DB.getValue(nodeTarget, "hp.total", 0)
        nTempHP = DB.getValue(nodeTarget, "hp.temporary", 0)
        nWounds = DB.getValue(nodeTarget, "hp.wounds", 0)
        nPrevWounds = nWounds
        nCurrentHp = (nTotalHP + nTempHP) - nWounds
        nDeathSaveSuccess = DB.getValue(nodeTarget, "hp.deathsavesuccess", 0)
        nDeathSaveFail = DB.getValue(nodeTarget, "hp.deathsavefail", 0)
    else
        nTotalHP = DB.getValue(nodeTarget, "hptotal", 0)
        nTempHP = DB.getValue(nodeTarget, "hptemp", 0)
        nWounds = DB.getValue(nodeTarget, "wounds", 0)
        nDeathSaveSuccess = DB.getValue(nodeTarget, "deathsavesuccess", 0)
        nDeathSaveFail = DB.getValue(nodeTarget, "deathsavefail", 0)
    end

    -- Prepare for notifications
    local aNotifications = {}
    local nConcentrationDamage = 0
    local bRemoveTarget = false

    -- Remember current health status
    local _, sOriginalStatus = ActorHealthManager.getWoundPercent(rTarget)

    -- Decode damage/heal description
    local rDamageOutput = ActionDamage.decodeDamageText(nTotal, sDamage)

    -- changing death's door options, since it always exists in 1e
    local nDeathDoorThreshold = 0
    local nDEAD_AT = -10

    local sOptHouseRuleDeathsDoor = OptionsManager.getOption("HouseRule_DeathsDoor")

    if sOptHouseRuleDeathsDoor == "exactlyZero" then
        nDeathDoorThreshold = 0
    elseif sOptHouseRuleDeathsDoor == "zeroToMinusThree" then
        nDeathDoorThreshold = 3
    else
        -- 9 because -10 = dead
        nDeathDoorThreshold = 9
    end

    -- Healing
    if rDamageOutput.sType == "recovery" then
        -- Healing
        local sClassNode = string.match(sDamage, "%[NODE:([^]]+)%]")

        if nWounds <= 0 then
            table.insert(aNotifications, "[NOT WOUNDED]")
        else
            -- Determine whether HD available
            local nClassHD = 0
            local nClassHDMult = 0
            local nClassHDUsed = 0

            if sTargetType == "pc" and sClassNode then
                local nodeClass = DB.findNode(sClassNode)
                nClassHD = DB.getValue(nodeClass, "level", 0)
                nClassHDMult = #(DB.getValue(nodeClass, "hddie", {}))
                nClassHDUsed = DB.getValue(nodeClass, "hdused", 0)
            end

            if (nClassHD * nClassHDMult) <= nClassHDUsed then
                table.insert(aNotifications, "[INSUFFICIENT HIT DICE FOR THIS CLASS]")
            else
                -- Calculate heal amounts
                local nHealAmount = rDamageOutput.nVal

                -- If healing from zero (or negative), then remove Stable effect and reset wounds to match HP
                if (nHealAmount > 0) and (nWounds >= nTotalHP) then
                    EffectManager.removeEffect(ActorManager.getCTNode(rTarget), "Stable")
                    nWounds = nTotalHP
                end

                local nWoundHealAmount = math.min(nHealAmount, nWounds)
                nWounds = nWounds - nWoundHealAmount

                -- Display actual heal amount
                rDamageOutput.nVal = nWoundHealAmount
                rDamageOutput.sVal = string.format("%01d", nWoundHealAmount)

                -- Decrement HD used
                if sTargetType == "pc" and sClassNode then
                    local nodeClass = DB.findNode(sClassNode)
                    DB.setValue(nodeClass, "hdused", "number", nClassHDUsed + 1)
                    rDamageOutput.sVal = rDamageOutput.sVal .. "][HD-1"
                end
            end
        end
    elseif rDamageOutput.sType == "heal" then
        -- Temporary hit points
        if nWounds <= 0 then
            table.insert(aNotifications, "[NOT WOUNDED]")
        else
            -- Calculate heal amounts
            local nHealAmount = rDamageOutput.nVal

            -- remove this, not this way in 1e/osric
            -- If healing from zero (or negative), then remove Stable effect and reset wounds to match HP
            -- if (nHealAmount > 0) and (nWounds >= nTotalHP) then
            --     EffectManager.removeEffect(ActorManager.getCTNode(rTarget), "Stable")
            --     nWounds = nTotalHP
            --     nHealAmount = 1 -- heals only restore 1 hp when below 0.
            -- end

            local nWoundHealAmount = math.min(nHealAmount, nWounds)
            nWounds = nWounds - nWoundHealAmount

            -- Display actual heal amount
            rDamageOutput.nVal = nWoundHealAmount
            rDamageOutput.sVal = string.format("%01d", nWoundHealAmount)
        end
    elseif rDamageOutput.sType == "temphp" then
        -- Damage
        nTempHP = math.max(nTempHP, nTotal)
    else
        -- Apply any targeted damage effects
        -- NOTE: Dice determined randomly, instead of rolled
        if rSource and rTarget and rTarget.nOrder then
            local bCritical = string.match(sDamage, "%[CRITICAL%]")
            local aTargetedDamage =
                EffectManager5E.getEffectsBonusByType(
                rSource,
                {"DMG"},
                true,
                rDamageOutput.aDamageFilter,
                rTarget,
                true
            )

            local nDamageEffectTotal = 0
            local nDamageEffectCount = 0

            for k, v in pairs(aTargetedDamage) do
                local bValid = true
                local aSplitByDmgType = StringManager.split(k, ",", true)

                for _, vDmgType in ipairs(aSplitByDmgType) do
                    if vDmgType == "critical" and not bCritical then
                        bValid = false
                    end
                end

                if bValid then
                    local nSubTotal = StringManager.evalDice(v.dice, v.mod)
                    local sDamageType = rDamageOutput.sFirstDamageType

                    if sDamageType then
                        sDamageType = sDamageType .. "," .. k
                    else
                        sDamageType = k
                    end

                    rDamageOutput.aDamageTypes[sDamageType] = (rDamageOutput.aDamageTypes[sDamageType] or 0) + nSubTotal

                    nDamageEffectTotal = nDamageEffectTotal + nSubTotal
                    nDamageEffectCount = nDamageEffectCount + 1
                end
            end

            nTotal = nTotal + nDamageEffectTotal

            if nDamageEffectCount > 0 then
                if nDamageEffectTotal ~= 0 then
                    local sFormat = "[" .. Interface.getString("effects_tag") .. " %+d]"
                    table.insert(aNotifications, string.format(sFormat, nDamageEffectTotal))
                else
                    table.insert(aNotifications, "[" .. Interface.getString("effects_tag") .. "]")
                end
            end
        end

        -- Handle avoidance/evasion and half damage
        local isAvoided = false
        local isHalf = string.match(sDamage, "%[HALF%]")
        local sAttack = string.match(sDamage, "%[DAMAGE[^]]*%] ([^[]+)")

        if sAttack then
            local sDamageState = ActionDamage.getDamageState(rSource, rTarget, StringManager.trim(sAttack))

            if sDamageState == "none" then
                isAvoided = true
                bRemoveTarget = true
            elseif sDamageState == "half_success" then
                isHalf = true
                bRemoveTarget = true
            elseif sDamageState == "half_failure" then
                isHalf = true
            end
        end

        if isAvoided then
            table.insert(aNotifications, "[EVADED]")

            for kType, nType in pairs(rDamageOutput.aDamageTypes) do
                rDamageOutput.aDamageTypes[kType] = 0
            end

            nTotal = 0
        elseif isHalf then
            table.insert(aNotifications, "[HALF]")
            local bCarry = false

            for kType, nType in pairs(rDamageOutput.aDamageTypes) do
                local nOddCheck = nType % 2
                rDamageOutput.aDamageTypes[kType] = math.floor(nType / 2)

                if nOddCheck == 1 then
                    if bCarry then
                        rDamageOutput.aDamageTypes[kType] = rDamageOutput.aDamageTypes[kType] + 1
                        bCarry = false
                    else
                        bCarry = true
                    end
                end
            end

            nTotal = math.max(math.floor(nTotal / 2), 1)
        end

        -- Apply damage type adjustments
        local nDamageAdjust, bVulnerable, bResist, bAbsorb, nDamageDice =
            ActionDamage.getDamageAdjust(rSource, rTarget, nTotal, rDamageOutput, aDice)
        nAdjustedDamage = nTotal + nDamageAdjust

        if nAdjustedDamage < 0 then
            nAdjustedDamage = 0
        end

        if bResist then
            if nAdjustedDamage <= 0 then
                table.insert(aNotifications, "[RESISTED]")
            else
                table.insert(aNotifications, "[PARTIALLY RESISTED]")
            end
        end

        if bVulnerable then
            table.insert(aNotifications, "[VULNERABLE]")
        end

        if bAbsorb then
            if nAdjustedDamage <= 0 then
                table.insert(aNotifications, "[ABSORBED]")
            else
                table.insert(aNotifications, "[PARTIALLY ABSORBED]")
            end
        end

        if nDamageDice ~= 0 then
            -- reduced damage
            if nDamageDice > 0 and nAdjustedDamage <= 0 then
                table.insert(aNotifications, "[RESISTED]")
            elseif nDamageDice > 0 then
                -- increased damage
                table.insert(aNotifications, "[PARTIALLY RESISTED]")
            elseif nDamageDice < 0 then
                table.insert(aNotifications, "[VULNERABLE]")
            end
        end

        -- Prepare for concentration checks if damaged
        nConcentrationDamage = nAdjustedDamage

        -- Reduce damage by temporary hit points
        if nTempHP > 0 and nAdjustedDamage > 0 then
            if nAdjustedDamage > nTempHP then
                nAdjustedDamage = nAdjustedDamage - nTempHP
                nTempHP = 0
                table.insert(aNotifications, "[PARTIALLY ABSORBED]")
            else
                nTempHP = nTempHP - nAdjustedDamage
                nAdjustedDamage = 0
                table.insert(aNotifications, "[ABSORBED]")
            end
        end

        -- Apply remaining damage
        if nAdjustedDamage > 0 then
            -- done earlier
            --nPrevWounds = nWounds

            -- Apply wounds
            nWounds = math.max(nWounds + nAdjustedDamage, 0)

            -- Calculate wounds above HP
            if nWounds > nTotalHP then
                nDmgBeyondTotalHp = nWounds - nTotalHP
                nWounds = nTotalHP
            end

            -- Prepare for calcs
            local nodeTargetCT = ActorManager.getCTNode(rTarget)

            -- deal with death's door threshold
            -- currently has hp
            if nCurrentHp > 0 then
                -- todo: System Shock
                -- Add check here for nAdjustedDamage > 50 and if so perform system shock check?-- celestian, AD&D
                -- hit after having zero or less hp - dead
                -- new hit causing damage beyond threshold = dead
                if nAdjustedDamage > nCurrentHp + nDeathDoorThreshold then
                    table.insert(aNotifications, "[INSTANT DEATH]")
                    nDeathSaveFail = 3
                elseif (nAdjustedDamage == nCurrentHp) then
                    -- new hit causing hit points to fall within threshold
                    table.insert(aNotifications, "[DAMAGE EQUALS HIT POINTS - AT DEATH'S DOOR]")
                elseif (nAdjustedDamage > nCurrentHp) and (nAdjustedDamage <= nCurrentHp + nDeathDoorThreshold) then
                    table.insert(
                        aNotifications,
                        "[DAMAGE EXCEEDS HIT POINTS BY " .. nDmgBeyondTotalHp .. "  - AT DEATH'S DOOR]"
                    )
                end
                -- todo: see if this stuff is used in the 2e ruleset
                if nPrevWounds >= nTotalHP then
                    if rDamageOutput.bCritical then
                        nDeathSaveFail = nDeathSaveFail + 2
                    else
                        nDeathSaveFail = nDeathSaveFail + 1
                    end
                end
            else
                -- ongoing damage
                if rSource == nil then
                    table.insert(aNotifications, "[BLEEDING]")
                else
                    -- hit after at 0 hp or less - death
                    table.insert(aNotifications, "[INSTANT DEATH]")
                    nDeathSaveFail = 3
                end
            end

            --end

            -- Deal with remainder damage
            -- if nDmgBeyondTotalHp >= (nTotalHP + 10) then
            --     table.insert(aNotifications, "[INSTANT DEATH]")
            --     nDeathSaveFail = 3
            -- elseif nDmgBeyondTotalHp > 0 or nWounds == nTotalHP then
            --     if nDmgBeyondTotalHp > 0 then
            --         table.insert(aNotifications, "[DAMAGE EXCEEDS HIT POINTS BY " .. nDmgBeyondTotalHp .. "]")
            --     else
            --         table.insert(aNotifications, "[DAMAGE EXCEEDS HIT POINTS]")
            --     end

            --     if nPrevWounds >= nTotalHP then
            --         if rDamageOutput.bCritical then
            --             nDeathSaveFail = nDeathSaveFail + 2
            --         else
            --             nDeathSaveFail = nDeathSaveFail + 1
            --         end
            --     end
            -- -- todo: System Shock
            -- -- Add check here for nAdjustedDamage > 50 and if so perform system shock check?-- celestian, AD&D
            -- end

            -- Handle stable situation
            EffectManager.removeEffect(nodeTargetCT, "Stable")

            -- Disable regeneration next round on correct damage type
            if nodeTargetCT then
                -- Calculate which damage types actually did damage
                local aTempDamageTypes = {}
                local aActualDamageTypes = {}

                for k, v in pairs(rDamageOutput.aDamageTypes) do
                    if v > 0 then
                        table.insert(aTempDamageTypes, k)
                    end
                end

                local aActualDamageTypes = StringManager.split(table.concat(aTempDamageTypes, ","), ",", true)

                -- Check target's effects for regeneration effects that match
                --for _,v in pairs(DB.getChildren(nodeTargetCT, "effects")) do
                for _, v in ipairs(EffectManagerADND.getEffectsList(nodeTargetCT)) do
                    local nActive = DB.getValue(v, "isactive", 0)

                    if (nActive == 1) then
                        local bMatch = false
                        local sLabel = DB.getValue(v, "label", "")
                        local aEffectComps = EffectManager.parseEffect(sLabel)

                        for i = 1, #aEffectComps do
                            local rEffectComp = EffectManager5E.parseEffectComp(aEffectComps[i])

                            if rEffectComp.type == "REGEN" then
                                for _, v2 in pairs(rEffectComp.remainder) do
                                    if StringManager.contains(aActualDamageTypes, v2) then
                                        bMatch = true
                                    end
                                end
                            end

                            if bMatch then
                                EffectManager.disableEffect(nodeTargetCT, v)
                            end
                        end
                    end
                end
            end
        end

        -- deprecating, useless in 1e
        -- if optional rule from Fighter's Handbook using Armor Damage (DP) then...
        -- if OptionsManager.getOption("OPTIONAL_ARMORDP") == "on" then
        --     -- armor takes 1 damage each time "damaged"
        --     -- local nodeCT = DB.findNode(ActorManager.getCTNodeName(rTarget));
        --     local nodeCT = ActorManager.getCTNode(rTarget)
        --     local nodeChar = CombatManagerADND.getNodeFromCT(nodeCT)
        --     ActionDamage.damageArmorWorn(nodeChar, 1)
        -- end

        -- Update the damage output variable to reflect adjustments
        rDamageOutput.nVal = nAdjustedDamage
        rDamageOutput.sVal = string.format("%01d", nAdjustedDamage)
    end

    -- Clear death saves if health greater than zero
    nDeathSaveSuccess = 0
    nDeathSaveFail = 0

    if sTargetType == "pc" then
        updatePcCondition(
            rDamageOutput.sType,
            rSource,
            nWounds,
            nPrevWounds,
            nTotalHP,
            nDeathDoorThreshold,
            rTarget,
            nCurrentHp,
            nAdjustedDamage
        )
    end

    updateHealthStatus(sTargetType, nodeTarget, nDeathSaveSuccess, nDeathSaveFail, nTempHP, nWounds, nDmgBeyondTotalHp)

    --
    -- if sTargetType == "pc" then
    -- DB.setValue(nodeTarget, "hp.deathsavesuccess", "number", math.min(nDeathSaveSuccess, 3));
    -- DB.setValue(nodeTarget, "hp.deathsavefail", "number", math.min(nDeathSaveFail, 3));
    -- DB.setValue(nodeTarget, "hp.temporary", "number", nTempHP);
    -- DB.setValue(nodeTarget, "hp.wounds", "number", (nWounds+nDmgBeyondTotalHp));
    -- else
    -- DB.setValue(nodeTarget, "deathsavesuccess", "number", math.min(nDeathSaveSuccess, 3));
    -- DB.setValue(nodeTarget, "deathsavefail", "number", math.min(nDeathSaveFail, 3));
    -- DB.setValue(nodeTarget, "hptemp", "number", nTempHP);
    -- DB.setValue(nodeTarget, "wounds", "number", nWounds);
    -- end

    -- Check for status change
    local bShowStatus = false

    if ActorManager.getFaction(rTarget) == "friend" then
        bShowStatus = not OptionsManager.isOption("SHPC", "off")
    else
        bShowStatus = not OptionsManager.isOption("SHNPC", "off")
    end

    if bShowStatus then
        local _, sNewStatus = ActorHealthManager.getWoundPercent(rTarget)

        if sOriginalStatus ~= sNewStatus then
            table.insert(aNotifications, "[" .. Interface.getString("combat_tag_status") .. ": " .. sNewStatus .. "]")
        end
    end

    -- Output results
    ActionDamage.messageDamage(
        rSource,
        rTarget,
        bSecret,
        rDamageOutput.sTypeOutput,
        sDamage,
        rDamageOutput.sVal,
        table.concat(aNotifications, " "),
        nTotal
    )

    -- Remove target after applying damage
    if bRemoveTarget and rSource and rTarget then
        TargetingManager.removeTarget(ActorManager.getCTNodeName(rSource), ActorManager.getCTNodeName(rTarget))
    end

    -- Check for required concentration checks
    -- changed, using (C) effect to indicate someone is casting and if they take damage
    -- the casting is interrupted and spell lost. --celestian
    if nConcentrationDamage > 0 and ActionSave.hasConcentrationEffects(rTarget) then
        if nWounds < nTotalHP then
            -- local nTargetDC = math.max(math.floor(nConcentrationDamage / 2), 10);
            -- ActionSave.performConcentrationRoll(nil, rTarget, nTargetDC);
            -- else
            ActionSave.expireConcentrationEffects(rTarget)
            local sLmsg = {font = "msgfont"}
            sLmsg.icon = "roll_cast"
            sLmsg.text =
                string.format(Interface.getString("message_concentration_failed"), ActorManager.getDisplayName(rTarget))

            local sSmsg = {font = "msgfont"}
            sSmsg.text = string.format("%s's spell casting interrupted.", ActorManager.getDisplayName(rTarget))

            --ActionsManager.messageResult(bSecret, nil, rTarget, sLmsg, sSmsg);
            ActionsManager.outputResult(bSecret, nil, rTarget, sLmsg, sSmsg)
        end
    end
end

function updatePcCondition(
    sDamageType,
    rSource,
    nWounds,
    nPrevWounds,
    nTotalHP,
    nDeathDoorThreshold,
    rTarget,
    nCurrentHp,
    nAdjustedDamage)
    -- effects management
    --if sTargetType == "pc" then
    Debug.console("manager_action_attack_osric.lua 897", "pc")
    -- ^^ was PC
    --local nDeathValue = (nTotalHP - nWounds) - nDmgBeyondTotalHp;

    -- todo: done? fix this for deaths door and add coma effect
    Debug.console(
        "manager_action_attack_osric.lua 902",
        sDamageType,
        rSource,
        nWounds,
        nPrevWounds,
        nTotalHP,
        nDeathDoorThreshold,
        rTarget,
        nCurrentHp,
        nAdjustedDamage
    )

    -- non-damage
    if sDamageType == "recovery" or sDamageType == "heal" or sDamageType == "temphp" then
        -- damage from another creature
        -- healed to 0 or less hp from negative
        if nWounds > nTotalHP and nPrevWounds >= nTotalHP then
            -- healed to 1 hp or greater from zero or negative
            if EffectManager5E.hasEffect(rTarget, "Unconscious") then
                -- remove and re-add unconscious to remove damage advanced effect
                EffectManager.removeEffect(ActorManager.getCTNode(rTarget), "Unconscious")
                EffectManager.addEffect(
                    "",
                    "",
                    ActorManager.getCTNode(rTarget),
                    {sName = "Unconscious", sLabel = "Unconscious", nDuration = 0},
                    true
                )
            end

            -- add stable if not already present
            if not EffectManager5E.hasEffect(rTarget, "Stable") then
                EffectManager.addEffect(
                    "",
                    "",
                    ActorManager.getCTNode(rTarget),
                    {sName = "Stable", sLabel = "Stable", nDuration = 0},
                    true
                )
            end
        elseif nWounds < nTotalHP and nPrevWounds >= nTotalHP then
            -- dying pc was stabilized, then returned to positive hp
            if EffectManager5E.hasEffect(rTarget, "Stable") then
                -- remove stable
                EffectManager.removeEffect(ActorManager.getCTNode(rTarget), "Stable")
                -- add coma if not already present
                if not EffectManager5E.hasEffect(rTarget, "Coma") then
                    EffectManager.addEffect(
                        "",
                        "",
                        ActorManager.getCTNode(rTarget),
                        {sName = "Coma", sLabel = "Coma", nDuration = 0},
                        true
                    )
                end
            end

            -- unconcious pc returned to positive hp
            if EffectManager5E.hasEffect(rTarget, "Unconscious") then
                -- remove and re-add unconscious to remove damage advanced effect
                EffectManager.removeEffect(ActorManager.getCTNode(rTarget), "Unconscious")
                EffectManager.addEffect(
                    "",
                    "",
                    ActorManager.getCTNode(rTarget),
                    {sName = "Unconscious", sLabel = "Unconscious", nDuration = 0},
                    true
                )
                -- add coma if not already present
                if not EffectManager5E.hasEffect(rTarget, "Coma") then
                    EffectManager.addEffect(
                        "",
                        "",
                        ActorManager.getCTNode(rTarget),
                        {sName = "Coma", sLabel = "Coma", nDuration = 0},
                        true
                    )
                end
            end

            -- dead, then raised or resurrected
            if EffectManager5E.hasEffect(rTarget, "Dead") then
                EffectManager.removeEffect(ActorManager.getCTNode(rTarget), "Dead")
                if EffectManager5E.hasEffect(rTarget, "Unconscious") then
                    -- remove unconscious
                    EffectManager.removeEffect(ActorManager.getCTNode(rTarget), "Unconscious")
                end
                -- add helpless
                EffectManager.addEffect(
                    "",
                    "",
                    ActorManager.getCTNode(rTarget),
                    {sName = "Helpless", sLabel = "Helpless", nDuration = 0},
                    true
                )
            end
        end
    elseif rSource ~= nil then
        -- ongoing damage
        -- deal with death's door threshold
        -- currently has hp
        if nCurrentHp > 0 then
            -- todo: see if this stuff is used in the 2e ruleset
            -- if nPrevWounds >= nTotalHP then
            --     if rDamageOutput.bCritical then
            --         nDeathSaveFail = nDeathSaveFail + 2
            --     else
            --         nDeathSaveFail = nDeathSaveFail + 1
            --     end
            -- end
            -- todo: System Shock
            -- Add check here for nAdjustedDamage > 50 and if so perform system shock check?-- celestian, AD&D
            -- hit after having zero or less hp - dead
            -- new hit causing damage beyond threshold = dead
            if nAdjustedDamage > nCurrentHp + nDeathDoorThreshold then
                -- new hit causing hit points to drop to 0
                if not EffectManager5E.hasEffect(rTarget, "Dead") then
                    EffectManager.removeEffect(ActorManager.getCTNode(rTarget), "Unconscious");
                    EffectManager.addEffect(
                        "",
                        "",
                        ActorManager.getCTNode(rTarget),
                        {sName = "Dead", nDuration = 0},
                        true
                    )
                end
            elseif (nAdjustedDamage == nCurrentHp) then
                -- new hit causing hit points to fall within threshold
                EffectManager.addEffect(
                    "",
                    "",
                    ActorManager.getCTNode(rTarget),
                    {sName = "Unconscious;DMGO:1", sLabel = "Unconscious;DMGO:1", nDuration = 0},
                    true
                )
            elseif (nAdjustedDamage > nCurrentHp) and (nAdjustedDamage <= nCurrentHp + nDeathDoorThreshold) then
                EffectManager.addEffect(
                    "",
                    "",
                    ActorManager.getCTNode(rTarget),
                    {sName = "Unconscious;DMGO:1", sLabel = "Unconscious;DMGO:1", nDuration = 0},
                    true
                )
            end
        else
            -- hit after at 0 hp or less - death
            EffectManager.addEffect("", "", ActorManager.getCTNode(rTarget), {sName = "Dead", nDuration = 0}, true)
            nDeathSaveFail = 3
        end
    else
        Debug.console("ongoing 1076")
        if nCurrentHp <= -9 then
            -- removing an effect here causes an error because we're going through a loop of effects where DMGO is called and if this one
            -- is removed it causes the for loop to crash
            -- if EffectManager5E.hasEffect(rTarget, "Unconscious") then
            --     -- remove unconscious
            --     EffectManager.removeEffect(ActorManager.getCTNode(rTarget), "Unconscious")
            -- end
            if not EffectManager5E.hasEffect(rTarget, "Dead") then
                EffectManager.addEffect(
                    "",
                    "",
                    ActorManager.getCTNode(rTarget),
                    {sName = "Dead", sLabel = "Dead", nDuration = 0},
                    true
                )
                nDeathSaveFail = 3
            end
        end
    end
    Debug.console("1099")
    -- doing this here, outside of the loop that causes an error, line 1083
    if EffectManager5E.hasEffect(rTarget, "Unconscious") and EffectManager5E.hasEffect(rTarget, "Dead") then
        -- remove unconscious
        EffectManager.removeEffect(ActorManager.getCTNode(rTarget), "Unconscious")
    end
end

function updateHealthStatus(
    sTargetType,
    nodeTarget,
    nDeathSaveSuccess,
    nDeathSaveFail,
    nTempHP,
    nWounds,
    nDmgBeyondTotalHp)
    Debug.console(
        "manager_action_attack_osric.lua 1116",
        sTargetType,
        nodeTarget,
        nDeathSaveSuccess,
        nDeathSaveFail,
        nTempHP,
        nWounds,
        nDmgBeyondTotalHp
    )

    if sTargetType == "pc" then
        -- todo: what about this? should it be used?
        -- Set health fields
        DB.setValue(nodeTarget, "hp.deathsavesuccess", "number", math.min(nDeathSaveSuccess, 3))
        DB.setValue(nodeTarget, "hp.deathsavefail", "number", math.min(nDeathSaveFail, 3))
        DB.setValue(nodeTarget, "hp.temporary", "number", nTempHP)
        DB.setValue(nodeTarget, "hp.wounds", "number", (nWounds + nDmgBeyondTotalHp))
    else
        -- was NPC...
        DB.setValue(nodeTarget, "deathsavesuccess", "number", math.min(nDeathSaveSuccess, 3))
        DB.setValue(nodeTarget, "deathsavefail", "number", math.min(nDeathSaveFail, 3))
        DB.setValue(nodeTarget, "hptemp", "number", nTempHP)
        DB.setValue(nodeTarget, "wounds", "number", nWounds)
    end
end
