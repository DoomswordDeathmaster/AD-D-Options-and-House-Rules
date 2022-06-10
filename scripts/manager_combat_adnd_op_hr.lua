local rollEntryInitOrig;
local rollRandomInitOrig;

--
-- AD&D Specific combat needs
--
--

PC_LASTINIT = 0;
NPC_LASTINIT = 0;
OOB_MSGTYPE_CHANGEINIT = "changeinitiative";

function onInit()
    local initiativeDie = OptionsManager.getOption("initiativeDie");
    local initiativeDieNumber = initiativeDie:gsub("d", "");

    DataCommonADND.nDefaultInitiativeDice = initiativeDieNumber;

    rollEntryInitOrig = CombatManagerADND.rollEntryInit;
    CombatManagerADND.rollEntryInit = rollEntryInitNew;
    CombatManager2.rollEntryInit = rollEntryInitNew;

    rollRandomInitOrig = CombatManagerADND.rollRandomInit;
    CombatManagerADND.rollRandomInit = rollRandomInitNew;
    CombatManager2.rollRandomInit = rollRandomInitNew;

    CombatManagerADND.handleInitiativeChange = handleInitiativeChange;
    OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_CHANGEINIT, handleInitiativeChange);

    CombatManager.setCustomCombatReset(resetInitNew);
    CombatManager.setCustomRoundStart(onRoundStartNew);
    CombatManager.setCustomSort(sortfuncADnDNew);
end

function rollRandomInitNew(nMod, bADV)
    if OptionsManager.getOption("initiativeModifiersAllow") == "off" then
        -- no modifiers
        Debug.console("init mods not used");
        nMod = 0;
    end

    rollRandomInitOrig(nMod, bADV);
end

function rollEntryInitNew(nodeEntry)
    Debug.console("rollEntryInitNew");
    Debug.console(DataCommonADND.nDefaultInitiativeDice);

    local bOptInitMods = (OptionsManager.getOption("initiativeModifiersAllow") == 'on');
    local bOptInitTies = (OptionsManager.getOption("initiativeTiesAllow") == 'on');
    local sOptInitGrouping = OptionsManager.getOption("initiativeGrouping");
    local bOptInitGroupingSwap = (OptionsManager.getOption("initiativeGroupingSwap") == 'on');
    --local sOptInitOrdering = OptionsManager.getOption("initiativeOrdering");
    
    Debug.console(bOptInitMods);
    Debug.console(bOptInitTies);
    Debug.console("init grouping: " .. sOptInitGrouping);
    Debug.console(bOptInitGroupingSwap);
    --Debug.console("init ordering: " .. sOptInitOrdering);

	if not nodeEntry then
		return;
	end

    local bOptPCVNPCINIT = (OptionsManager.getOption("PCVNPCINIT") == 'on');
    -- default init mods to 0
    local nInitMOD = 0;

    -- mods on
    if bOptInitMods then
        Debug.console("init mods on");
    
        -- Start with the base initiative bonus
        local nInit = DB.getValue(nodeEntry, "init", 0);
        -- Get any effect modifiers
        local rActor = ActorManager.resolveActor(nodeEntry);
        local aEffectDice, nEffectBonus = EffectManager5E.getEffectsBonus(rActor, "INIT");
        nInitMOD = StringManager.evalDice(aEffectDice, nEffectBonus);
    else
        -- mods off
        Debug.console("init mods off")
    end

    Debug.console(nInitMOD);

	-- Check for the ADVINIT effect
	local bADV = EffectManager5E.hasEffectCondition(rActor, "ADVINIT");

	-- PC/NPC init
	local sClass, sRecord = DB.getValue(nodeEntry, "link", "", "");

    -- it's a pc
	if sClass == "charsheet" then
        local nodeChar = DB.findNode(sRecord);
        -- default PC initiative totals to 0
        local nInitPC = 0;
        local nInitResult = 0;
        
        -- if init mods are on
        if bOptInitMods then
            nInitPC = DB.getValue(nodeChar,"initiative.total",0);
        end
        
        Debug.console(sOptInitGrouping);

        -- if grouping involving pcs is on
        if bOptPCVNPCINIT or (sOptInitGrouping == "pc" or sOptInitGrouping == "both") then
            -- roll without mods
            nInitResult = rollRandomInitOrig(0, bADV);

            -- group init - apply init result to remaining PCs
            applyInitResultToAllPCs(nInitResult);

            -- set last init for comparison for ties and swapping
            PC_LASTINIT = nInitResult;
        else
            -- individual init
            Debug.console("rollRandomInitOrig");
            nInitResult = rollRandomInitOrig(nInitPC + nInitMOD, bADV);
        end

        -- just set both of these values regardless of initiative die used, so we don't have to mod other places where initresult is displayed
        DB.setValue(nodeEntry, "initresult", "number", nInitResult);
        DB.setValue(nodeEntry, "initresult_d6", "number", nInitResult);

        --return;
    else
        -- it's an npc
        -- if grouping involving npcs is on
        if bOptPCVNPCINIT or (sOptInitGrouping == "npc" or sOptInitGrouping == "both") then

            -- roll without mods
            nInitResult = rollRandomInitOrig(0, bADV);

            -- group init - apply init result to remaining NPCs
            applyInitResultToAllNPCs(nInitResult);

            -- set last init for comparison for ties and swapping
            NPC_LASTINIT = nInitResult;
        else
            -- set nInit to 0 for disallowing mods
            local nInit = 0;

            -- for npcs we allow them to have custom initiative. Check for it 
            -- and set nInit.
            local nTotal = DB.getValue(nodeEntry,"initiative.total",0);

            if bOptInitMods then
                -- flip through weaponlist, get the largest speedfactor as default
                local nSpeedFactor = 0;
                
                for _,nodeWeapon in pairs(DB.getChildren(nodeEntry, "weaponlist")) do
                    local nSpeed = DB.getValue(nodeWeapon,"speedfactor",0);
                    if nSpeed > nSpeedFactor then
                        nSpeedFactor = nSpeed;
                    end
                end
                
                if nSpeedFactor ~= 0 then
                    nInit = nSpeedFactor + nInitMOD ;
                elseif (nTotal ~= 0) then 
                    nInit = nTotal + nInitMOD ;
                end
            end
            
            --[[ IF we ignore size/mods, clear nInit ]]
            if OptionsManager.getOption("OPTIONAL_INIT_SIZEMODS") ~= "on" then
                nInit = 0;
            end
            
            -- For NPCs, if NPC init option is not group, then roll unique initiative
            local sOptINIT = OptionsManager.getOption("INIT");
            
            if sOptINIT ~= "group" then
                -- if they have custom init then we use it.
                local nInitResult = rollRandomInitOrig(nInit, bADV);

                DB.setValue(nodeEntry, "initresult", "number", nInitResult);
                DB.setValue(nodeEntry, "initresult_d6", "number", nInitResult);
            else
                -- For NPCs with group option enabled
                -- Get the entry's database node name and creature name
                local sStripName = CombatManager.stripCreatureNumber(DB.getValue(nodeEntry, "name", ""));

                if sStripName == "" then
                    local nInitResult = rollRandomInitOrig(nInit, bADV);

                    DB.setValue(nodeEntry, "initresult", "number", nInitResult);
                    DB.setValue(nodeEntry, "initresult_d6", "number", nInitResult);

                    return;
                end
            
                -- Iterate through list looking for other creature's with same name and faction
                local nLastInit = nil;
                local sEntryFaction = DB.getValue(nodeEntry, "friendfoe", "");

                for _,v in pairs(CombatManager.getCombatantNodes()) do
                    if v.getName() ~= nodeEntry.getName() then
                        if DB.getValue(v, "friendfoe", "") == sEntryFaction then
                            local sTemp = CombatManager.stripCreatureNumber(DB.getValue(v, "name", ""));
                            
                            if sTemp == sStripName then
                                local nChildInit = DB.getValue(v, "initresult", 0);
                                
                                if nChildInit ~= -10000 then
                                    nLastInit = nChildInit;
                                end
                            end
                        end
                    end
                end

                -- If we found similar creatures, then match the initiative of the last one found
                if nLastInit then
                    DB.setValue(nodeEntry, "initresult", "number", nLastInit);
                    DB.setValue(nodeEntry, "initresult_d6", "number", nLastInit);
                else
                    local nInitResult = rollRandomInitOrig(nInit, bADV);

                    DB.setValue(nodeEntry, "initresult", "number", nInitResult);
                    DB.setValue(nodeEntry, "initresult_d6", "number", nInitResult);
                end
            end
        end
    end

    -- deal with ties when all initiative is grouped and ties are turned off
    if bOptPCVNPCINIT or (sOptInitGrouping == "both") then
        Debug.console(bOptInitTies);
        -- init ties off
        if not bOptInitTies then
            Debug.console("init ties off");

            -- this is to make sure we dont have same initiative
            -- give the benefit to players.
            if PC_LASTINIT == NPC_LASTINIT then
                Debug.console("correcting a tie");
                -- don't want 0 inits
                if NPC_LASTINIT ~= 1 then
                    nInitResult = NPC_LASTINIT - 1;
                    applyInitResultToAllPCs(nInitResult);
                    PC_LASTINIT = nInitResult;
                else
                    nInitResult = PC_LASTINIT + 1;
                    applyInitResultToAllNPCs(nInitResult);
                    NPC_LASTINIT = nInitResult;
                end
            end
        end

        Debug.console(bOptInitGroupingSwap);
        -- init grouping swap
        if bOptInitGroupingSwap then
            if bOptPCVNPCINIT or (sOptInitGrouping ~= "neither") then
                Debug.console("swapping init");
                Debug.console(PC_LASTINIT);
                Debug.console(NPC_LASTINIT);
                applyInitResultToAllPCs(NPC_LASTINIT);
                applyInitResultToAllNPCs(PC_LASTINIT);
            end
        end
    end
end

function applyInitResultToAllPCs(nInitResult)
    Debug.console("applyInitResultToAllPCs");
    -- group init - apply init result to all PCs
    for _,v in pairs(CombatManager.getCombatantNodes()) do
        --Debug.console(DB.getValue(v, "name"));
        --Debug.console(DB.getValue(v, "friendfoe"));
        --Debug.console(nInitResult);
        if DB.getValue(v, "friendfoe") == "friend" then
            --Debug.console("friend");
            --Debug.console(initresult);
            -- just set both of these values regardless of initiative die used, so we don't have to mod other places where initresult is displayed
            DB.setValue(v, "initresult", "number", nInitResult);
            DB.setValue(v, "initresult_d6", "number", nInitResult);
            -- set init rolled
            --Debug.console("set pc init rolled");
            DB.setValue(v, "initrolled", "number", 1);
        end
    end
end

function applyInitResultToAllNPCs(nInitResult)
    Debug.console("applyInitResultToAllNPCs");
    -- group init - apply init result to remaining NPCs
    for _,v in pairs(CombatManager.getCombatantNodes()) do
        --Debug.console(DB.getValue(v, "name"));
        --Debug.console(DB.getValue(v, "friendfoe"));
        --Debug.console(nInitResult);
        if DB.getValue(v, "friendfoe") ~= "friend" then
            Debug.console("not friend");
            Debug.console(nInitResult);
            -- just set both of these values regardless of initiative die used, so we don't have to mod other places where initresult is displayed
            DB.setValue(v, "initresult", "number", nInitResult);
            DB.setValue(v, "initresult_d6", "number", nInitResult);
            -- set init rolled
            --Debug.console("set npc init rolled");
            DB.setValue(v, "initrolled", "number", 1);
        end
    end
end

function applyIndividualInit(nTotal, rSource)
    local nodeEntry = ActorManager.getCTNode(rSource);
    --local node = ActorManager.getCreatureNode(rSource);
    Debug.console("applyIndividualInit");
    Debug.console(nodeEntry);
    Debug.console(nTotal);
    -- just set both of these values regardless of initiative die used, so we don't have to mod other places where initresult is displayed
    DB.setValue(nodeEntry, "initresult", "number", nTotal);
    DB.setValue(nodeEntry, "initresult_d6", "number", nTotal);
    -- set init rolled
    Debug.console("set init rolled");
    DB.setValue(nodeEntry, "initrolled", "number", 1);
end

--
-- AD&D Style ordering (low to high initiative)
--
function sortfuncADnDNew(node2, node1)
    local sOptInitOrdering = OptionsManager.getOption("initiativeOrdering");
    Debug.console("sortFuncADnDNew");
    local bHost = Session.IsHost;
    local sOptCTSI = OptionsManager.getOption("CTSI");
    
    local sFaction1 = DB.getValue(node1, "friendfoe", "");
    local sFaction2 = DB.getValue(node2, "friendfoe", "");
    
    local bShowInit1 = bHost or ((sOptCTSI == "friend") and (sFaction1 == "friend")) or (sOptCTSI == "on");
    local bShowInit2 = bHost or ((sOptCTSI == "friend") and (sFaction2 == "friend")) or (sOptCTSI == "on");
    
    if bShowInit1 ~= bShowInit2 then
      if bShowInit1 then
        return true;
      elseif bShowInit2 then
        return false;
      end
    else
      if bShowInit1 then
        local nValue1 = DB.getValue(node1, "initresult", 0);
        local nValue2 = DB.getValue(node2, "initresult", 0);
        if nValue1 ~= nValue2 then
            if sOptInitOrdering == "ascending" then
                Debug.console(sOptInitOrdering);
                return nValue1 > nValue2;
            else
                Debug.console(sOptInitOrdering);
                return nValue1 < nValue2;
            end
        end
        
        nValue1 = DB.getValue(node1, "init", 0);
        nValue2 = DB.getValue(node2, "init", 0);
        if nValue1 ~= nValue2 then
            if sOptInitOrdering == "ascending" then
                Debug.console(sOptInitOrdering);
                return nValue1 > nValue2;
            else
                Debug.console(sOptInitOrdering);
                return nValue1 < nValue2;
            end
        end
      else
        if sFaction1 ~= sFaction2 then
          if sFaction1 == "friend" then
            return true;
          elseif sFaction2 == "friend" then
            return false;
          end
        end
      end
    end
    
    local sValue1 = DB.getValue(node1, "name", "");
    local sValue2 = DB.getValue(node2, "name", "");

    if sOptInitOrdering == "ascending" then
        Debug.console(sOptInitOrdering);
        if sValue1 ~= sValue2 then
            return sValue1 < sValue2;
        end
    
        return node1.getNodeName() < node2.getNodeName();
    else
        Debug.console(sOptInitOrdering);
        if sValue1 ~= sValue2 then
            return sValue2 < sValue1;
        end
    
        return node2.getNodeName() < node1.getNodeName();
    end
end

function handleInitiativeChange(msgOOB)
    Debug.console("handle init change");
    local nodeCT = DB.findNode(msgOOB.sCTRecord);
    if nodeCT then
        DB.setValue(nodeCT,"initresult","number",msgOOB.nNewInit);
        DB.setValue(nodeCT,"initresult_d6","number",msgOOB.nNewInit);
    end
end

function resetInitNew()
    -- set last init results to 0
    Debug.console("setting last inits to 0");
    PC_LASTINIT = 0;
    NPC_LASTINIT = 0;

    for _,nodeCT in pairs(CombatManager.getCombatantNodes()) do
        resetCombatantInit(nodeCT);
    end

    Debug.console(NPC_LASTINIT);
    Debug.console(PC_LASTINIT);
end

function onRoundStartNew(nCurrent)
    local bOptRoundStartResetInit = (OptionsManager.getOption("roundStartResetInit") == 'on');
    Debug.console(bOptRoundStartResetInit);

    PC_LASTINIT = 0;
    NPC_LASTINIT = 0;
    
    if bOptRoundStartResetInit then
        for _,nodeCT in pairs(CombatManager.getCombatantNodes()) do
            resetCombatantInit(nodeCT);
        end
    end
end

function resetCombatantInit(nodeCT)
    Debug.console("reset init new");
    
    DB.setValue(nodeCT, "initresult", "number", 0);
    DB.setValue(nodeCT, "initresult_d6", "number", 0);
    DB.setValue(nodeCT, "reaction", "number", 0);
    
    -- toggle portrait initiative icon
    CharlistManagerADND.turnOffAllInitRolled();
    -- toggle all "initrun" values to not run
    CharlistManagerADND.turnOffAllInitRun();
end