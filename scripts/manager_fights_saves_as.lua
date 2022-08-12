function updateCombatValuesNPC(nodeNPC, fightsAsClass, fightsAsHdLevel)
    Debug.console("updateCombatValuesNPC", nodeNPC, fightsAsClass, fightsAsHdLevel);

    local bUseMatrix = (DataCommonADND.coreVersion == "1e");
    --local bClassRecord = node.getPath():match("^class%.");
    local nTHACO = DB.getValue(nodeNPC, "combat.thaco.score", 20);
    local sHitDice = CombatManagerADND.getNPCHitDice(nodeNPC);
    local aMatrixRolls = {};

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
    fightsAsHdLevel = DB.getValue(nodeNPC, "fights_as_hd_level");

    Debug.console("fightsAsClass", fightsAsClass);
    Debug.console("fightsAsHdLevel", fightsAsHdLevel);

    if (fightsAsHdLevel == 0) then
        fightsAsHdLevel = tonumber(sHitDice);
    end

    Debug.console("31", "fightsAsHdLevel", fightsAsHdLevel);

    if (fightsAsClass ~= "") then
        if (fightsAsClass == "Assassin") then
            
            if (fightsAsHdLevel >= 15) then
                fightsAsHdLevel = 15;
            end

            aMatrixRolls = DataCommonADND.aAssassinToHitMatrix[fightsAsHdLevel];
            
            Debug.console("36", "Assassin");
        elseif (fightsAsClass == "Cleric") then
            
            if (fightsAsHdLevel >= 19) then
                fightsAsHdLevel = 19;
            end
            
            aMatrixRolls = DataCommonADND.aClericToHitMatrix[fightsAsHdLevel]
        end
    else
        if (fightsAsHdLevel >= 16) then
            fightsAsHdLevel = 16;
        end

        aMatrixRolls = DataCommonADND.aMatrix[tostring(fightsAsHdLevel)];
        Debug.console("53", fightsAsHdLevel, DataCommonADND.aMatrix);
        Debug.console("54", aMatrixRolls);
    end

    Debug.console("56", aMatrixRolls);

      -- assign matrix values
    for i=nLowAC, nHighAC, 1 do
        local nTHAC = nTHACO - i; -- to hit AC value. Current THACO for this Armor Class. so 20 - 10 for AC 10 would be 30.

        Debug.console("manager_fights_saves_as:138", "nodeNPC", nodeNPC);
            -- db values only for PCs, calculated values for NPCs
        if bUseMatrix then
            if bisPC then
                Debug.console("manager_fights_saves_as:142", bisPC);
                nTHAC = DB.getValue(nodeNPC,"combat.matrix.thac" .. i, 20);
            else--if not bisPC and #aMatrixRolls > 0 then
                -- math.abs(i-11), this table is reverse of how we display the matrix
                -- so we start at the end instead of at the front by taking I - 11 then get the absolute value of it.
                nTHAC = aMatrixRolls[math.abs(i-11)];

                -- get value from db, in case it's been explicitly set
                local nTHACDb = DB.getValue(nodeNPC, "thac" .. i);
                Debug.console("manager_fights_saves_as:151", "nTHACDb", nTHACDb);

                -- get value from aMatrixRolls
                local nTHACM = aMatrixRolls[math.abs(i - nTotalACs)];
                Debug.console("manager_fights_saves_as:155", "nTHACM", nTHACM);

                if (fightsAsClass ~= "" or fightsAsHdLevel ~= 0) then
                    Debug.console("87", fightsAsClass, fightsAsHdLevel);
                    nTHAC = nTHACM;
                    Debug.console("manager_fights_saves_as:160", "nTHAC", nTHAC);
                elseif (nTHACDb ~= nil and nTHACDb ~= nTHACM) then
                    nTHAC = nTHACDb;
                    Debug.console("manager_fights_saves_as:163", "nTHAC", nTHAC);
                else
                    nTHAC = nTHACM;
                    Debug.console("manager_fights_saves_as:166", "nTHAC", nTHAC);
                end

                DB.setValue(nodeNPC,"thac" .. i, "number", nTHAC);
            end
        end
    end
end

function updateSavesNPC(nodeNPC, savesAsClass, savesAsHdLevel)
    Debug.console("updateSavesNpc");
    --local nodeNPC = getDatabaseNode();
    Debug.console(nodeNPC);
    local sHitDice = CombatManagerADND.getNPCHitDice(nodeNPC);
    local aSaveScores = {};
    local saveScore = 20;

    if (savesAsClass == "") then
        savesAsClass = DB.getValue(nodeNPC, "saves_as");
    end

    if (savesAsHdLevel == 0) then
        savesAsHdLevel = DB.getValue(nodeNPC, "saves_as_hd_level");
    end

    Debug.console("15:savesAsClass", savesAsClass);
    Debug.console("16:savesAsHdLevel", savesAsHdLevel);

    if (savesAsHdLevel == 0) then
        savesAsHdLevel = tonumber(sHitDice);
    end

    Debug.console("manager:62", nodeNPC, nodeNPC);
    updateNPCSaves(nodeNPC, nodeNPC, savesAsClass, savesAsHdLevel);
end

-- Set NPC Saves -celestian
-- move to manager_action_save.lua?
function updateNPCSaves(nodeEntry, nodeNPC, savesAsClass, savesAsHdLevel)
    Debug.console("manager:69","updateNPCSaves","nodeNPC",nodeNPC);
    --if  (bForceUpdate) or (DB.getChildCount(nodeNPC, "saves") <= 0) then
        for i=1,10,1 do
            local sSave = DataCommon.saves[i];
            Debug.console("manager:73", nodeEntry, sSave, nodeNPC);
            --local nSave = DB.getValue(nodeNPC, "saves." .. sSave .. ".score", -1);
            setNPCSave(nodeEntry, sSave, nodeNPC, savesAsClass, savesAsHdLevel)
        end
    --end
end

function setNPCSave(nodeEntry, sSave, nodeNPC, savesAsClass, savesAsHdLevel)
    local nSaveIndex = DataCommonADND.saves_table_index[sSave];
    local aSaveScores = {};

    Debug.console("84", savesAsClass);
    
    if (savesAsClass ~= "") then
        if (savesAsClass == "Assassin") then
            if (savesAsHdLevel <= 15) then
                aSaveScores = DataCommonADND.aAssassinSaves[savesAsHdLevel];
            else
                aSaveScores = DataCommonADND.aAssassinSaves[15];
            end
        elseif (savesAsClass == "Cleric") then
            if (savesAsHdLevel <= 19) then
                aSaveScores = DataCommonADND.aClericSaves[savesAsHdLevel];
            else
                aSaveScores = DataCommonADND.aAssassinSaves[19];
            end
        end
    else
        aSaveScores = DataCommonADND.aWarriorSaves[savesAsHdLevel];
    end
    
    Debug.console("104", aSaveScores, aSaveScores[nSaveIndex]);
    local nSaveScore = aSaveScores[nSaveIndex];
    Debug.console("106", "nodeEntry", nodeEntry, "nodeNPC", nodeNPC, "sSave", sSave, "nSaveScore", nSaveScore);
    
    DB.setValue(nodeEntry, "saves." .. sSave .. ".score", "number", nSaveScore);
    DB.setValue(nodeEntry, "saves." .. sSave .. ".base", "number", nSaveScore);
end