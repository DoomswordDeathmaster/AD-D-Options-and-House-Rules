PC_LASTINIT = 0;
NPC_LASTINIT = 0;
OOB_MSGTYPE_APPLYINIT = "applyinit";

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
    Debug.console(rRoll);
    local nodeEntry = ActorManager.getCreatureNode(rActor);
    Debug.console(nodeEntry);
    Debug.console(DB.getValue(nodeEntry, "initresult", 0));
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

    Debug.console(rRoll);
    local nodeEntry = ActorManager.getCreatureNode(rActor);
    Debug.console(nodeEntry);
    Debug.console(DB.getValue(nodeEntry,"initresult",0));
    Debug.console(rRoll.aDice);
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

    local nodeEntry = ActorManager.getCreatureNode(rSource);
    Debug.console(ActorManager.isPC(rSource));

    if bOptPCVNPCINIT or (sOptInitGrouping ~= "neither") then
        if (sOptInitGrouping == "both") then
            if ActorManager.isPC(rSource) then
                CombatManagerAdndOpHr.applyInitResultToAllPCs(nTotal);
            elseif not ActorManager.isPC(rSource) then
                CombatManagerAdndOpHr.applyInitResultToAllNPCs(nTotal);
            end
        elseif (sOptInitGrouping == "pc") then
            if ActorManager.isPC(rSource) then
                CombatManagerAdndOpHr.applyInitResultToAllPCs(nTotal);
            elseif not ActorManager.isPC(rSource) then
                CombatManagerAdndOpHr.applyInitResultToAllNPCs(nTotal);
            end
        elseif (sOptInitGrouping == "npc") then
            if not ActorManager.isPC(rSource) then
                CombatManagerAdndOpHr.applyInitResultToAllPCs(nTotal);
            elseif ActorManager.isPC(rSource) then
                CombatManagerAdndOpHr.applyInitResultToAllNPCs(nTotal);
            end
        end
        NPC_LASTINIT = nTotal;
        PC_LASTINIT = nTotal;
    end

    -- if grouping involving pcs is on
    if bOptPCVNPCINIT or (sOptInitGrouping == "pc") then
        
        --if DB.getValue(noodeEntry, "friendfoe", "") == "friend" then
        
        if ActorManager.isPC(rSource) then
            CombatManagerAdndOpHr.applyInitResultToAllPCs(nTotal);
        end

        PC_LASTINIT = nTotal;
    elseif sOptInitGrouping == "npc" then
        -- if grouping involving npcs is on
        local nodeEntry = ActorManager.getCreatureNode(rSource);
        Debug.console(ActorManager.isPC(rSource));
        --if DB.getValue(nodeEntry, "friendfoe", "") ~= "friend" then
        if not ActorManager.isPC(rSource) then
            CombatManagerAdndOpHr.applyInitResultToAllNPCs(nTotal);
        end

        NPC_LASTINIT = nTotal;
    elseif sOptInitGrouping == "both" then

    end

    if not bOptInitTies then
        Debug.console("init ties off");

        -- this is to make sure we dont have same initiative
        -- give the benefit to players.
        if PC_LASTINIT == NPC_LASTINIT then
            Debug.console("correcting a tie");
            -- don't want 0 inits
            if NPC_LASTINIT ~= 1 then
                nInitResult = NPC_LASTINIT - 1;
                CombatManagerAdndOpHr.applyInitResultToAllPCs(nInitResult);
                PC_LASTINIT = nInitResult;
            else
                nInitResult = PC_LASTINIT + 1;
                CombatManagerAdndOpHr.applyInitResultToAllNPCs(nInitResult);
                NPC_LASTINIT = nInitResult;
            end
        end
    end

    Debug.console(bOptInitGroupingSwap);
    -- init grouping swap
    if bOptInitGroupingSwap then
        Debug.console("swapping init");
        CombatManagerAdndOpHr.applyInitResultToAllPCs(NPC_LASTINIT);
        CombatManagerAdndOpHr.applyInitResultToAllNPCs(PC_LASTINIT);
    end

    Debug.console("handleApplyInitNew");
    DB.setValue(ActorManager.getCTNode(rSource), "initresult", "number", nTotal);
    DB.setValue(ActorManager.getCTNode(rSource), "initresult_d6", "number", nTotal);
    DB.setValue(ActorManager.getCTNode(rSource), "initrolled", "number", 1);
end