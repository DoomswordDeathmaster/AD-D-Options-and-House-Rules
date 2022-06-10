PC_LASTINIT = 0;
NPC_LASTINIT = 0;
OOB_MSGTYPE_APPLYINIT = "applyinit";

function onInit()
	getRollOrig = ActionInit.getRoll;
	ActionInit.getRoll = getRollNew;

    handleApplyInitOrig = ActionInit.handleApplyInit;
	ActionInit.handleApplyInit = handleApplyInitNew;

    OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYINIT, handleApplyInitNew);
end

-- initiative with modifiers, from item entry in ct or init button on character
function getRollNew(rActor, bSecretRoll, rItem)
    local rRoll;

    if OptionsManager.getOption("initiativeModifiersAllow") == "on" then
        -- default, with modifiers
        rRoll = getRollOrig(rActor, bSecretRoll, rItem);
    else
        -- no initiative modifiers
        rRoll = getRollNoMods(rActor, bSecretRoll, rItem);
    end

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

    return rRoll;
end

function handleApplyInitNew(msgOOB)
    local rSource = ActorManager.resolveActor(msgOOB.sSourceNode);
    local nTotal = tonumber(msgOOB.nTotal) or 0;

    local bOptPCVNPCINIT = (OptionsManager.getOption("PCVNPCINIT") == 'on');
    local bOptInitTies = (OptionsManager.getOption("initiativeTiesAllow") == 'on');
    local sOptInitGrouping = OptionsManager.getOption("initiativeGrouping");
    local bOptInitGroupingSwap = (OptionsManager.getOption("initiativeGroupingSwap") == 'on');

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
        CombatManagerAdndOpHr.applyIndividualInit(nTotal, rSource);
    end

    -- if ties are turned off
    if not bOptInitTies then
        -- if a side's init has already been rolled
        if NPC_LASTINIT ~= 0 or PC_LASTINIT ~= 0 then
            -- if a PC rolled for initiative
            if ActorManager.isPC(rSource) then
                -- check for ties and correct
                -- this is to make sure we dont have same initiative
                -- give the benefit to players.
                if PC_LASTINIT == NPC_LASTINIT then
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

    -- init grouping swap
    if bOptInitGroupingSwap then
        if bOptPCVNPCINIT or (sOptInitGrouping ~= "neither") then
            CombatManagerAdndOpHr.applyInitResultToAllPCs(NPC_LASTINIT);
            CombatManagerAdndOpHr.applyInitResultToAllNPCs(PC_LASTINIT);
        end
    end
end