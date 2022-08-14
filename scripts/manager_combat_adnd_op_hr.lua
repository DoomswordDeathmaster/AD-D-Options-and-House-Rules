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

    getACHitFromMatrixForNPCOrig = CombatManagerADND.getACHitFromMatrixForNPC;
    CombatManagerADND.getACHitFromMatrixForNPC = getACHitFromMatrixForNPCNew;

    CombatManagerADND.handleInitiativeChange = handleInitiativeChange;
    OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_CHANGEINIT, handleInitiativeChange);

    CombatManager.setCustomCombatReset(resetInitNew);
    CombatManager.setCustomRoundStart(onRoundStartNew);
    CombatManager.setCustomSort(sortfuncADnDNew);
end

function rollRandomInitNew(nMod, bADV)
    if OptionsManager.getOption("initiativeModifiersAllow") == "off" then
        -- no modifiers
        nMod = 0;
    end

    rollRandomInitOrig(nMod, bADV);
end

function rollEntryInitNew(nodeEntry)
    local bOptInitMods = (OptionsManager.getOption("initiativeModifiersAllow") == 'on');
    local bOptInitTies = (OptionsManager.getOption("initiativeTiesAllow") == 'on');
    local sOptInitGrouping = OptionsManager.getOption("initiativeGrouping");
    local bOptInitGroupingSwap = (OptionsManager.getOption("initiativeGroupingSwap") == 'on');

	if not nodeEntry then
		return;
	end

    local bOptPCVNPCINIT = (OptionsManager.getOption("PCVNPCINIT") == 'on');
    -- default init mods to 0
    local nInitMOD = 0;

    -- mods on
    if bOptInitMods then
        -- Start with the base initiative bonus
        local nInit = DB.getValue(nodeEntry, "init", 0);
        -- Get any effect modifiers
        local rActor = ActorManager.resolveActor(nodeEntry);
        local aEffectDice, nEffectBonus = EffectManager5E.getEffectsBonus(rActor, "INIT");
        nInitMOD = StringManager.evalDice(aEffectDice, nEffectBonus);
    end

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
            nInitResult = rollRandomInitOrig(nInitPC + nInitMOD, bADV);
        end

        -- just set both of these values regardless of initiative die used, so we don't have to mod other places where initresult is displayed
        DB.setValue(nodeEntry, "initresult", "number", nInitResult);
        DB.setValue(nodeEntry, "initresult_d6", "number", nInitResult);
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
        
        -- init ties off
        if not bOptInitTies then
            -- this is to make sure we dont have same initiative
            -- give the benefit to players.
            if PC_LASTINIT == NPC_LASTINIT then
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

        -- init grouping swap
        if bOptInitGroupingSwap then
            if bOptPCVNPCINIT or (sOptInitGrouping ~= "neither") then
                applyInitResultToAllPCs(NPC_LASTINIT);
                applyInitResultToAllNPCs(PC_LASTINIT);
            end
        end
    end
end

function applyInitResultToAllPCs(nInitResult)

    -- group init - apply init result to all PCs
    for _,v in pairs(CombatManager.getCombatantNodes()) do
        if DB.getValue(v, "friendfoe") == "friend" then
            -- just set both of these values regardless of initiative die used, so we don't have to mod other places where initresult is displayed
            DB.setValue(v, "initresult", "number", nInitResult);
            DB.setValue(v, "initresult_d6", "number", nInitResult);
            -- set init rolled
            DB.setValue(v, "initrolled", "number", 1);
        end
    end
end

function applyInitResultToAllNPCs(nInitResult)

    -- group init - apply init result to remaining NPCs
    for _,v in pairs(CombatManager.getCombatantNodes()) do
        if DB.getValue(v, "friendfoe") ~= "friend" then
            -- just set both of these values regardless of initiative die used, so we don't have to mod other places where initresult is displayed
            DB.setValue(v, "initresult", "number", nInitResult);
            DB.setValue(v, "initresult_d6", "number", nInitResult);
            -- set init rolled
            DB.setValue(v, "initrolled", "number", 1);
        end
    end
end

function applyIndividualInit(nTotal, rSource)
    local nodeEntry = ActorManager.getCTNode(rSource);

    -- just set both of these values regardless of initiative die used, so we don't have to mod other places where initresult is displayed
    DB.setValue(nodeEntry, "initresult", "number", nTotal);
    DB.setValue(nodeEntry, "initresult_d6", "number", nTotal);
    -- set init rolled
    DB.setValue(nodeEntry, "initrolled", "number", 1);
end

--
-- AD&D Style ordering (low to high initiative)
--
function sortfuncADnDNew(node2, node1)
    local sOptInitOrdering = OptionsManager.getOption("initiativeOrdering");
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
                return nValue1 > nValue2;
            else
                return nValue1 < nValue2;
            end
        end
        
        nValue1 = DB.getValue(node1, "init", 0);
        nValue2 = DB.getValue(node2, "init", 0);
        if nValue1 ~= nValue2 then
            if sOptInitOrdering == "ascending" then
                return nValue1 > nValue2;
            else
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
        if sValue1 ~= sValue2 then
            return sValue1 < sValue2;
        end
    
        return node1.getNodeName() < node2.getNodeName();
    else
        if sValue1 ~= sValue2 then
            return sValue2 < sValue1;
        end
    
        return node2.getNodeName() < node1.getNodeName();
    end
end

function handleInitiativeChange(msgOOB)
    local nodeCT = DB.findNode(msgOOB.sCTRecord);

    if nodeCT then
        DB.setValue(nodeCT,"initresult","number",msgOOB.nNewInit);
        DB.setValue(nodeCT,"initresult_d6","number",msgOOB.nNewInit);
    end
end

function resetInitNew()
    -- set last init results to 0
    PC_LASTINIT = 0;
    NPC_LASTINIT = 0;

    for _,nodeCT in pairs(CombatManager.getCombatantNodes()) do
        resetCombatantInit(nodeCT);
    end

end

function onRoundStartNew(nCurrent)
    local bOptRoundStartResetInit = (OptionsManager.getOption("roundStartResetInit") == 'on');

    PC_LASTINIT = 0;
    NPC_LASTINIT = 0;
    
    if bOptRoundStartResetInit then
        for _,nodeCT in pairs(CombatManager.getCombatantNodes()) do
            resetCombatantInit(nodeCT);
        end
    end
end

function resetCombatantInit(nodeCT)
    DB.setValue(nodeCT, "initresult", "number", 0);
    DB.setValue(nodeCT, "initresult_d6", "number", 0);
    DB.setValue(nodeCT, "reaction", "number", 0);
    
    -- toggle portrait initiative icon
    CharlistManagerADND.turnOffAllInitRolled();
    -- toggle all "initrun" values to not run
    CharlistManagerADND.turnOffAllInitRun();
end

-- return the Best ac hit from a roll for this NPC
function getACHitFromMatrixForNPCNew(nodeCT,nRoll)
    Debug.console(nodeCT, sHitDice, aMatrixRolls);

    local sClass, nodePath = DB.getValue(nodeCT,"sourcelink");
    local nodeNPC = DB.findNode(nodePath);
    Debug.console("394", sClass, nodeNPC);
    Debug.console("395", rActor, nodeNPC, sHitDice, aMatrixRolls);

    
    local nACHit = 20;
    local sHitDice = DB.getValue(nodeNPC, "hitDice"); --CombatManagerADND.getNPCHitDice(node);
    local aMatrixRolls = {}

    -- default value is 1e.
    local nLowAC = -10;
    local nHighAC = 10;
    local nTotalACs = 11;
    
    if (DataCommonADND.coreVersion == "becmi") then
        nLowAC = -20;
        nHighAC = 19;
        nTotalACs = 20;
    end

    fightsAsClass = DB.getValue(nodeNPC, "fights_as");
      fightsAsClass = string.gsub(fightsAsClass, "%s+", "");
      fightsAsHdLevel = DB.getValue(nodeNPC, "fights_as_hd_level");

      Debug.console("111", "npcHitDice", sHitDice, "fightsAsClass", fightsAsClass, "fightsAsHdLevel", fightsAsHdLevel);
    
      -- fights_as_hd_level not set
      if (fightsAsHdLevel == nil or fightsAsHdLevel == 0) then
          if (sHitDice == "0") then
              sHitDice = "-1";
              fightsAsHdLevel = 0;
          elseif (sHitDice == "1-1") then
              fightsAsHdLevel = 1;
          -- string contains a +, as in hd 1+1
          elseif string.find(sHitDice, "%+") then
              -- OSRIC
              fightsAsHdLevel = string.match(sHitDice, "%d+") + 2;
              -- 1e DMG
              if (sHitDice ~= "1+1") then
                  sHitDice = string.match(sHitDice, "%d+");
              else
                  sHitDice = "1+";
              end

          elseif (fightsAsClass == "") then
              fightsAsHdLevel = tonumber(sHitDice) + 1;
          else
              -- fights_as is set, so take the creature's hd
              fightsAsHdLevel = tonumber(sHitDice);
          end
      end

      Debug.console("121", "fightsAsClass", fightsAsClass);
      Debug.console("122", "fightsAsHdLevel", fightsAsHdLevel, "sHitDice", sHitDice);

      if (fightsAsClass ~= "") then
        if (fightsAsClass == "Assassin") then

            if (fightsAsHdLevel >= 13) then
                fightsAsHdLevel = 13;
            end

            aMatrixRolls = DataCommonADND.aAssassinToHitMatrix[fightsAsHdLevel];
        elseif (fightsAsClass == "Cleric") then

            if (fightsAsHdLevel >= 19) then
                fightsAsHdLevel = 19;
            end

            aMatrixRolls = DataCommonADND.aClericToHitMatrix[fightsAsHdLevel];
        elseif (fightsAsClass == "Druid") then

            if (fightsAsHdLevel >= 13) then
                fightsAsHdLevel = 13;
            end

            aMatrixRolls = DataCommonADND.aDruidToHitMatrix[fightsAsHdLevel];
        elseif (fightsAsClass == "Fighter") then

            if (fightsAsHdLevel >= 20) then
                fightsAsHdLevel = 20;
            end

            aMatrixRolls = DataCommonADND.aFighterToHitMatrix[fightsAsHdLevel];
        elseif (fightsAsClass == "Illusionist") then

            if (fightsAsHdLevel >= 21) then
                fightsAsHdLevel = 21;
            end

            aMatrixRolls = DataCommonADND.aIllusionistToHitMatrix[fightsAsHdLevel];
        elseif (fightsAsClass == "MagicUser") then

            if (fightsAsHdLevel >= 21) then
                fightsAsHdLevel = 21;
            end

            aMatrixRolls = DataCommonADND.aMagicUserToHitMatrix[fightsAsHdLevel];
        elseif (fightsAsClass == "Paladin") then

            if (fightsAsHdLevel >= 20) then
                fightsAsHdLevel = 20;
            end

            aMatrixRolls = DataCommonADND.aPaladinToHitMatrix[fightsAsHdLevel];
        elseif (fightsAsClass == "Ranger") then

            if (fightsAsHdLevel >= 20) then
                fightsAsHdLevel = 20;
            end

            aMatrixRolls = DataCommonADND.aRangerToHitMatrix[fightsAsHdLevel];
        elseif (fightsAsClass == "Thief") then

            if (fightsAsHdLevel >= 21) then
                fightsAsHdLevel = 21;
            end

            aMatrixRolls = DataCommonADND.aThiefToHitMatrix[fightsAsHdLevel];
        end
    else
        if (fightsAsHdLevel >= 20) then
            fightsAsHdLevel = 20;
        end

        local bUseOsricMonsterMatrix = (OptionsManager.getOption("useOsricMonsterMatrix") == 'on');
        Debug.console("514", "fightsAsHdLevel", fightsAsHdLevel, "bUseOsricMonsterMatrix", bUseOsricMonsterMatrix);
        
        if bUseOsricMonsterMatrix then
            aMatrixRolls = DataCommonADND.aOsricToHitMatrix[fightsAsHdLevel];
        else
            aMatrixRolls = DataCommonADND.aMatrix[sHitDice];

            -- for hit dice above 16, use 16
            if (aMatrixRolls == nil) then
              sHitDice = "16";
              aMatrixRolls = DataCommonADND.aMatrix[sHitDice];
            end
        end
    end

    Debug.console("manager_combat_adnd_op_hr","getACHitFromMatrixForNPCNew","aMatrixRolls",aMatrixRolls);
    local nACBase = 11;
      
    if (DataCommonADND.coreVersion == "becmi") then 
        nACBase = 20;
    end
      
    for i=#aMatrixRolls,1,-1 do
        local sCurrentTHAC = "thac" .. i;
        local nAC = nACBase - i;
        local nCurrentTHAC = aMatrixRolls[i];

        -- get value from db, in case it's been explicitly set
        local nTHACDb = DB.getValue(nodeNPC, "thac" .. i);
        Debug.console("char_matrix_thaco:151", "nTHACDb", nTHACDb);

        -- get value from aMatrixRolls
        local nTHACM = aMatrixRolls[math.abs(i - nTotalACs)];
        Debug.console("char_matrix_thaco:155", "nTHACM", nTHACM);

        if (fightsAsClass ~= "" or (fightsAsHdLevel ~= 0 and fightsAsHdLevel ~= tonumber(sHitDice))) then
            Debug.console("119", fightsAsClass, fightsAsHdLevel, tonumber(sHitDice));
            sCurrentTHAC = nTHACM;
            Debug.console("char_matrix_thaco:173", "nTHAC", nTHAC);
        elseif (nTHACDb ~= nil and nTHACDb ~= nTHACM) then
            sCurrentTHAC = nTHACDb;
            Debug.console("char_matrix_thaco:176", "nTHAC", nTHAC);
        else
            sCurrentTHAC = nTHACM;
            Debug.console("char_matrix_thaco:179", "nTHAC", nTHAC);
        end

        if nRoll >= nCurrentTHAC then
          -- find first AC that matches our roll
          nACHit = nAC;
          break;
        end
    end

    return nACHit;
end