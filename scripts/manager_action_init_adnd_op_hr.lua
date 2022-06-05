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

    local bOptInitMods = (OptionsManager.getOption("initiativeModifiersAllow") == 'on');
    local bOptInitTies = (OptionsManager.getOption("initiativeTiesAllow") == 'on');
    local sOptInitGrouping = OptionsManager.getOption("initiativeGrouping");
    local bOptInitGroupingSwap = (OptionsManager.getOption("initiativeGroupingSwap") == 'on');

    -- TODO: ties and swapping
    -- if grouping involving pcs is on
    if bOptPCVNPCINIT or (sOptInitGrouping == "pc" or sOptInitGrouping == "both") then
        local nodeEntry = ActorManager.getCreatureNode(rSource);
        Debug.console(ActorManager.isPC(rSource));
        --if DB.getValue(noodeEntry, "friendfoe", "") == "friend" then
        if ActorManager.isPC(rSource) then
            CombatManagerAdndOpHr.applyInitResultToAllPCs(nTotal);
        end
    end
    -- if grouping involving npcs is on
    if bOptPCVNPCINIT or (sOptInitGrouping == "npc" or sOptInitGrouping == "both") then
        local nodeEntry = ActorManager.getCreatureNode(rSource);
        Debug.console(ActorManager.isPC(rSource));
        --if DB.getValue(nodeEntry, "friendfoe", "") ~= "friend" then
        if not ActorManager.isPC(rSource) then
            CombatManagerAdndOpHr.applyInitResultToAllNPCs(nTotal);
        end
    end

    Debug.console("handleApplyInitNew");
    DB.setValue(ActorManager.getCTNode(rSource), "initresult", "number", nTotal);
    DB.setValue(ActorManager.getCTNode(rSource), "initresult_d6", "number", nTotal);
    DB.setValue(ActorManager.getCTNode(rSource), "initrolled", "number", 1);
end