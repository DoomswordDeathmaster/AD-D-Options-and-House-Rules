PC_LASTINIT = 0;
NPC_LASTINIT = 0;
OOB_MSGTYPE_APPLYINIT = "applyinit";
--combatantCount = 0;

function onInit()
	getRollOrig = ActionInit.getRoll;
	ActionInit.getRoll = getRollNew;

    handleApplyInitOrig = ActionInit.handleApplyInit;
	ActionInit.handleApplyInit = handleApplyInitNew;

    OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYINIT, handleApplyInitNew);
	--notifyApplyInitOrig = ActionInit.notifyApplyInit;
	--ActionInit.notifyApplyInit = notifyApplyInitNew;
end

-- TODO: add grouping options

-- initiative with modifiers, from item entry in ct or init button on character
function getRollNew(rActor, bSecretRoll, rItem)
    local rRoll;

    if OptionsManager.getOption("initiativeModifiersAllow") == "on" then
        -- default, with modifiers
        Debug.console("getRollOrig");
        rRoll = getRollOrig(rActor, bSecretRoll, rItem);
    else
        -- no initiative modifiers
        rRoll = getRollNoMods(rActor, bSecretRoll, rItem);
    end
    --Debug.console(rRoll.aDice);
    -- local nodeEntry = ActorManager.getCreatureNode(rActor);
    -- Debug.console(nodeEntry);
    -- Debug.console(DB.getValue(nodeEntry, "initresult", 0));
    -- DB.setValue(nodeEntry, "initresult", "number", rRoll.aDice[1].result);
    -- DB.setValue(nodeEntry, "initresult_d6", "number", rRoll.aDice[1].result);
    return rRoll;
end

-- initiative without modifiers, from item entry in ct or init button on character
function getRollNoMods(rActor, bSecretRoll, rItem)
    local rRoll = {};
    rRoll.sType = "init";
    rRoll.aDice = { "d" .. DataCommonADND.nDefaultInitiativeDice };
    rRoll.nMod = 0;
    
    rRoll.sDesc = "[INIT]";
    
    rRoll.bSecret = bSecretRoll;

    -- Debug.console(rRoll);
    -- local nodeEntry = ActorManager.getCreatureNode(rActor);
    -- Debug.console(nodeEntry);
    -- Debug.console(DB.getValue(nodeEntry,"initresult",0));
    --Debug.console(rRoll.aDice);
    -- DB.setValue(nodeEntry, "initresult", "number", rRoll.aDice[1].result);
    -- DB.setValue(nodeEntry, "initresult_d6", "number", rRoll.aDice[1].result);
    return rRoll;
end

function handleApplyInitNew(msgOOB)
    local rSource = ActorManager.resolveActor(msgOOB.sSourceNode);
    local nTotal = tonumber(msgOOB.nTotal) or 0;

    local bOptPCVNPCINIT = (OptionsManager.getOption("PCVNPCINIT") == 'on');
    local bOptInitTies = (OptionsManager.getOption("initiativeTiesAllow") == 'on');
    local sOptInitGrouping = OptionsManager.getOption("initiativeGrouping");
    local bOptInitGroupingSwap = (OptionsManager.getOption("initiativeGroupingSwap") == 'on');

    --local nodeEntry = ActorManager.getCreatureNode(rSource);
    --Debug.console(ActorManager.isPC(rSource));

    -- grouped initiative options
    if bOptPCVNPCINIT or (sOptInitGrouping ~= "neither") then
        if (bOptPCVNPCINIT or sOptInitGrouping == "both") then
            if ActorManager.isPC(rSource) then
                CombatManagerAdndOpHr.applyInitResultToAllPCs(nTotal);
                PC_LASTINIT = nTotal;
            elseif not ActorManager.isPC(rSource) then
                CombatManagerAdndOpHr.applyInitResultToAllNPCs(nTotal);
                NPC_LASTINIT = nTotal;
            end
        elseif (sOptInitGrouping == "pc") then
            if ActorManager.isPC(rSource) then
                CombatManagerAdndOpHr.applyInitResultToAllPCs(nTotal);
                PC_LASTINIT = nTotal;
            elseif not ActorManager.isPC(rSource) then
                CombatManagerAdndOpHr.applyIndividualInit(nTotal, rSource);
                NPC_LASTINIT = nTotal;
            end
        elseif (sOptInitGrouping == "npc") then
            if not ActorManager.isPC(rSource) then
                CombatManagerAdndOpHr.applyInitResultToAllNPCs(nTotal);
                NPC_LASTINIT = nTotal;
            elseif ActorManager.isPC(rSource) then
                CombatManagerAdndOpHr.applyIndividualInit(nTotal, rSource);
                PC_LASTINIT = nTotal;
            end
        end
    else
        -- no group options set
        Debug.console("no grouped initiative options set");
        CombatManagerAdndOpHr.applyIndividualInit(nTotal, rSource);
    end

    -- if grouping involving pcs is on
    -- if bOptPCVNPCINIT or (sOptInitGrouping == "pc") then
        
    --     Debug.console("applyInitResultToAllPCs 1");
    --     if ActorManager.isPC(rSource) then
    --         CombatManagerAdndOpHr.applyInitResultToAllPCs(nTotal);
    --     end

    --     PC_LASTINIT = nTotal;
    -- elseif sOptInitGrouping == "npc" then
    --     -- if grouping involving npcs is on
    --     local nodeEntry = ActorManager.getCreatureNode(rSource);
    --     Debug.console(ActorManager.isPC(rSource));
    --     --if DB.getValue(nodeEntry, "friendfoe", "") ~= "friend" then
    --     if not ActorManager.isPC(rSource) then
    --         CombatManagerAdndOpHr.applyInitResultToAllNPCs(nTotal);
    --     end

    --     NPC_LASTINIT = nTotal;
    -- elseif sOptInitGrouping == "both" then
    --     -- TODO
    -- end

    -- if ties are turned off
    if not bOptInitTies then
        -- if a side's init has already been rolled
        if NPC_LASTINIT ~= 0 or PC_LASTINIT ~= 0 then
            Debug.console("init 134");
            Debug.console(NPC_LASTINIT);
            Debug.console(PC_LASTINIT);
            Debug.console("npc or pc last inits not 0");
            -- if a PC rolled for initiative
            if ActorManager.isPC(rSource) then
                -- check for ties and correct
                -- this is to make sure we dont have same initiative
                -- give the benefit to players.
                if PC_LASTINIT == NPC_LASTINIT then
                    Debug.console("correcting a tie from prior NPC roll");
                    -- don't want init = 0
                    -- standard tiebreaker, without swapping
                    if not bOptInitGroupingSwap then
                        if NPC_LASTINIT ~= 1 then
                            nInitResult = NPC_LASTINIT - 1;
                            CombatManagerAdndOpHr.applyInitResultToAllPCs(nInitResult);
                            PC_LASTINIT = nInitResult;
                        else
                            nInitResult = PC_LASTINIT + 1;
                            CombatManagerAdndOpHr.applyInitResultToAllNPCs(nInitResult);
                            NPC_LASTINIT = nInitResult;
                        end
                    else
                    -- do the reverse so that pcs still have the advantage
                        if PC_LASTINIT ~= 1 then
                            nInitResult = PC_LASTINIT - 1;
                            CombatManagerAdndOpHr.applyInitResultToAllNPCs(nInitResult);
                            NPC_LASTINIT = nInitResult;
                        else
                            nInitResult = NPC_LASTINIT + 1;
                            CombatManagerAdndOpHr.applyInitResultToAllPCs(nInitResult);
                            PC_LASTINIT = nInitResult;
                        end
                    end
                    -- don't want inits > 6
                    if PC_LASTINIT > 6 or NPC_LASTINIT > 6 then
                        -- subtract 1 from each group's init
                        PC_LASTINIT = PC_LASTINIT - 1;
                        NPC_LASTINIT = NPC_LASTINIT - 1;
                        -- re-apply all inits
                        CombatManagerAdndOpHr.applyInitResultToAllPCs(PC_LASTINIT);
                        CombatManagerAdndOpHr.applyInitResultToAllNPCs(NPC_LASTINIT);
                    end
                end
            -- if an npc rolled for initiative
            else
                -- check for ties and correct
                -- this is to make sure we dont have same initiative
                -- give the benefit to players.
                if NPC_LASTINIT == PC_LASTINIT then
                    Debug.console("correcting a tie from prior PC roll");

                    -- standard tiebreaker, without swapping
                    if not bOptInitGroupingSwap then
                        nInitResult = PC_LASTINIT + 1;
                        CombatManagerAdndOpHr.applyInitResultToAllNPCs(nInitResult);
                        NPC_LASTINIT = nInitResult;
                    else
                    -- do the reverse so that pcs still have the advantage
                        nInitResult = NPC_LASTINIT + 1;
                        CombatManagerAdndOpHr.applyInitResultToAllPCs(nInitResult);
                        PC_LASTINIT = nInitResult;
                    end
                end
                -- don't want inits > 6
                if PC_LASTINIT > 6 or NPC_LASTINIT > 6 then
                    -- subtract 1 from each group's init
                    PC_LASTINIT = PC_LASTINIT - 1;
                    NPC_LASTINIT = NPC_LASTINIT - 1;
                    -- re-apply all inits
                    CombatManagerAdndOpHr.applyInitResultToAllPCs(PC_LASTINIT);
                    CombatManagerAdndOpHr.applyInitResultToAllNPCs(NPC_LASTINIT);
                end
            end
        end
    end

    Debug.console(bOptInitGroupingSwap);
    -- init grouping swap
    if bOptInitGroupingSwap then
        Debug.console("init grouping swap");
        if bOptPCVNPCINIT or (sOptInitGrouping ~= "neither") then
            -- combatantCount = combatantCount + 1;

            -- for _,v in pairs(CombatManager.getCombatantNodes()) do
            --     --Debug.console(DB.getValue(v, "initrolled"));
            --     --Debug.console(combatantCount);
            --     --Debug.console(nInitResult);
            --     -- if DB.getValue(v, "friendfoe") == "friend" then
            --     --     Debug.console("friend");
            --     --     Debug.console(initresult);
            --     --     -- just set both of these values regardless of initiative die used, so we don't have to mod other places where initresult is displayed
            --     --     DB.setValue(v, "initresult", "number", nInitResult);
            --     --     DB.setValue(v, "initresult_d6", "number", nInitResult);
            --     --     -- set init rolled
            --     --     Debug.console("set pc init rolled");
            --     --     DB.setValue(v, "initrolled", "number", 1);
            --     -- end
            -- end

            Debug.console("swapping init");
            Debug.console(PC_LASTINIT);
            Debug.console(NPC_LASTINIT);
            CombatManagerAdndOpHr.applyInitResultToAllPCs(NPC_LASTINIT);
            CombatManagerAdndOpHr.applyInitResultToAllNPCs(PC_LASTINIT);
        end
    end

    -- Debug.console("assign init results");
    -- DB.setValue(ActorManager.getCTNode(rSource), "initresult", "number", nInitResult);
    -- DB.setValue(ActorManager.getCTNode(rSource), "initresult_d6", "number", nInitResult);
    -- DB.setValue(ActorManager.getCTNode(rSource), "initrolled", "number", 1);
end