function onInit()
    ActorHealthManager.getWoundPercent = getWoundPercentAdndOpHr
end

function getWoundPercentAdndOpHr(rActor)
    --Debug.console("getWoundPercentAdndOpHr")
    -- local rActor = ActorManager.resolveActor(node);
    -- local node = ActorManager.getCreatureNode(rActor);
    local sNodeType, node = ActorManager.getTypeAndNode(rActor)
    local nHP = 0
    local nWounds = 0
    local nConScore = DB.getValue(node, "abilities.constitution.score", 0)

    -- Debug.console("manager_actor_adnd.lua","getWoundPercent","sNodeType",sNodeType);
    if sNodeType == "pc" then
        nHP = math.max(DB.getValue(node, "hp.total", 0), 0)
        nWounds = math.max(DB.getValue(node, "hp.wounds", 0), 0)
    elseif sNodeType == "ct" then
        nHP = math.max(DB.getValue(node, "hptotal", 0), 0)
        nWounds = math.max(DB.getValue(node, "wounds", 0), 0)
    end

    local nPercentWounded = 0
    local nCurrentHp = nHP

    if nHP > 0 then
        nPercentWounded = nWounds / nHP
        nCurrentHp = nHP - nWounds
    end

    local sStatus = ActorHealthManager.STATUS_HEALTHY

    -- default Death's Door Threshold
    local nDeathDoorThreshold = 0
    --default nDEAD_AT
    local nDEAD_AT = 0
    -- default
    local deadAtPositive = 0
    --default
    local deathDoorThresholdPositive = 0

    -- pc-only options for death's door
    if sNodeType == "pc" then
        -- get death's door on/off
        local bOptDeathsDoor = OptionsManager.isOption("HouseRule_DeathsDoor", "on")

        -- death's door ON
        if bOptDeathsDoor then
            -- get pc dead at config value
            local sOptPcDeadAtValue = OptionsManager.getOption("pcDeadAtValue")

            -- minus CON
            if sOptPcDeadAtValue == "minusCon" then
                nDEAD_AT = 0 - nConScore
                --deadAtPositive = nConScore
                --Debug.console("actorhealth: ndeadat", nDEAD_AT)
            -- minus 10
            else
                nDEAD_AT = -10
                --deadAtPositive = 10
            end

            -- get the threshold config setting
            local sOptHouseRuleDeathsDoorThreshold = OptionsManager.getOption("HouseRule_DeathsDoor_Threshold")

            if sOptHouseRuleDeathsDoorThreshold == "exactlyZero" then
                nDeathDoorThreshold = 0
            elseif sOptHouseRuleDeathsDoorThreshold == "zeroToMinusThree" then
                nDeathDoorThreshold = -3
                --deathDoorThresholdPositive = 3
            else
                -- minus 9 because -10 = dead
                nDeathDoorThreshold = -9
                --deathDoorThresholdPositive = 9
            end
        end
    end

    --Debug.console("manager_actor_health_adnd_op_hr.lua", "nPercentWounded", nPercentWounded, "sNodeType", sNodeType, "nDEAD_AT", nDEAD_AT, "nCurrentHp", nCurrentHp, "nDeathDoorThreshold", nDeathDoorThreshold)
    --Debug.console("manager_actor_health_osric.lua 62", nWounds, nPercentWounded, nHP, nCurrentHp)

    if nPercentWounded >= 1 then
        --local bhpltDeadAt = (nCurrentHp <= nDEAD_AT)
        --local bhpltDdt = (nCurrentHp < nDeathDoorThreshold)

        --Debug.console("bhpGtDeadAt", bhpGtDeadAt, "bhpltDdt", bhpltDdt)

        if (nCurrentHp <= nDEAD_AT) then --or (nCurrentHp < nDeathDoorThreshold) then
            --Debug.console("ADD DEAD STATUS")
            sStatus = ActorHealthManager.STATUS_DEAD
        else
            -- add this status if the guy isn't already dead, necessary because the health manager gets called after the damage manager and there's not an elegant way to stop it
            if not EffectManager5E.hasEffect(rActor, "Dead") then
                --Debug.console("ADD DYING STATUS")
                sStatus = ActorHealthManager.STATUS_DYING
            end
        end

        if nCurrentHp < 1 then
            --Debug.console("CURRENT HP LESS THAN ONE")
            sStatus = sStatus .. " (" .. nCurrentHp .. ")"
        end
    elseif OptionsManager.isOption("WNDC", "detailed") then
        if nPercentWounded >= .75 then
            sStatus = ActorHealthManager.STATUS_CRITICAL
        elseif nPercentWounded >= .5 then
            sStatus = ActorHealthManager.STATUS_HEAVY
        elseif nPercentWounded >= .25 then
            sStatus = ActorHealthManager.STATUS_MODERATE
        elseif nPercentWounded > 0 then
            sStatus = ActorHealthManager.STATUS_LIGHT
        else
            sStatus = ActorHealthManager.STATUS_HEALTHY
        end
    else
        if nPercentWounded >= .5 then
            sStatus = ActorHealthManager.STATUS_SIMPLE_HEAVY
        elseif nPercentWounded > 0 then
            sStatus = ActorHealthManager.STATUS_SIMPLE_WOUNDED
        else
            sStatus = ActorHealthManager.STATUS_HEALTHY
        end
    end

    return nPercentWounded, sStatus
end
