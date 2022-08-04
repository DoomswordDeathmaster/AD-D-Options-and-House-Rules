function onInit()
    --ActionSave.setNPCSave = setNPCSave;
	-- TODO: Add Attack Matrix stuff
end

function addFightsAsDb(nodeNpc, sClass, fightsAsClass)
	-- Validate parameters
	if nodeChar then
	  return false;
	end
	
	if sClass == "reference_class" then
	    DB.setValue(nodeNpc, "fights_as", "string", fightsAsClass);
	else
	  return false;
	end
	
	return true;
end

function addSavesAsDb(nodeNpc, sClass, savesAsClass)
	-- Validate parameters
	if nodeChar then
	  return false;
	end
	
	if sClass == "reference_class" then
	    DB.setValue(nodeNpc, "saves_as", "string", savesAsClass);
	else
	  return false;
	end
	
	return true;
end

function updateAttackMatrixNpc()
    Debug.console("updateAttackMatrixNpc");
    -- default value is 1e.
    local nLowAC = -10;
    local nHighAC = 10;
    local nTotalACs = 11;
    
    if (DataCommonADND.coreVersion == "becmi") then
        nLowAC = -20;
        nHighAC = 19;
        nTotalACs = 20;
    end
    
    local node = getDatabaseNode();
    local bClassRecord = node.getPath():match("^class%.");
    --Debug.console("char_matrix.lua","createAttackMatrix","node",node);    
    local sACLabelName = "matrix_ac_label";
    local sRollLabelName = "matrix_roll_label";

    -- 1e matrix
    local bUseMatrix = (DataCommonADND.coreVersion == "1e");
    local bisPC = (ActorManager.isPC(node)); 
    local aMatrixRolls = {};
    if not bClassRecord and bUseMatrix and not bisPC then 
        local sHitDice = CombatManagerADND.getNPCHitDice(node);
        if DataCommonADND.aMatrix[sHitDice] then
        aMatrixRolls = DataCommonADND.aMatrix[sHitDice];
    --Debug.console("char_matrix.lua","createAttackMatrix","aMatrixRolls",aMatrixRolls);              
        end
    end
    --
    
    for i=nLowAC,nHighAC,1 do
        local nTHAC = DB.getValue(node,"combat.matrix.thac" .. i, 20);
        
        -- 1e matrix
        if bUseMatrix and not bisPC and #aMatrixRolls > 0 then
        -- math.abs(i-21), this table is reverse of how we display the matrix
        -- so we start at the end instead of at the front by taking I - 21 then get the absolute value of it.
        nTHAC = aMatrixRolls[math.abs(i-nTotalACs)];
        end
        --
        local sMatrixACName = "matrix_ac_" .. i;
        local sMatrixACValue = i;
        local sMatrixNumberName = "thac" .. i;
        local cntNum = createControl("number_matrix", sMatrixNumberName, "combat.matrix." .. sMatrixNumberName);
        cntNum.setValue(nTHAC);
        if not bClassRecord and bUseMatrix and not bisPC then
        cntNum.setReadOnly(true);
        end

        local cntAC = createControl("label_fieldtop_matrix", sMatrixACName);
        cntAC.setReadOnly(true);
        cntAC.setValue(sMatrixACValue);
        cntAC.setAnchor("left", sMatrixNumberName,"left","absolute",0);
    end
end

function updateSavesNpc(nodeEntry, sSave, nodeNPC)
    Debug.console("updateSavesNpc");

    --Debug.console("manager_action_save.lua", "setNPCSave", "DataCommonADND.aWarriorSaves[nLevel][nSaveIndex]", DataCommonADND.aWarriorSaves[0][1]);    
    --Debug.console("manager_action_save.lua", "setNPCSave", sSave);

    local nSaveIndex = DataCommonADND.saves_table_index[sSave];

    --Debug.console("manager_action_save.lua", "setNPCSave", "DataCommonADND.saves_table_index[sSave]", DataCommonADND.saves_table_index[sSave]);
    
    --Debug.console("manager_action_save.lua", "setNPCSave", "nSaveIndex", nSaveIndex);
    
    local nSaveScore = 20;

    -- check if the monster has a 'savesAs' entry
    local sSavesAs = DB.getValue(nodeNPC, "savesAs", "");
    --Debug.console("saves_becmi.lua", "setNPCSave", "sSavesAs", sSavesAs);
    if (sSavesAs ~= "") then
        -- use BECMI monster saves
        --Debug.console("saves_becmi.lua", "setNPCSave", "DataCommonADND.aNPCSaves[sSavesAs]", DataCommonADND.aNPCSaves[sSavesAs]);
        if (DataCommonADND.aNPCSaves[sSavesAs] ~= nil) then
            nSaveScore = DataCommonADND.aNPCSaves[sSavesAs][nSaveIndex];
        end
    else
        --Debug.console("saves_becmi.lua", "setNPCSave", "hitdice calculation");
        -- use AD&D saves based on hit dice
        local sHitDice = DB.getValue(nodeNPC, "hitDice", "1");
        DB.setValue(nodeEntry,"hitDice","string", sHitDice);
        
        local nLevel = CombatManagerADND.getNPCLevelFromHitDice(nodeNPC);

        -- store it incase we wanna look at it later
        DB.setValue(nodeEntry, "level", "number", nLevel);
        
        --Debug.console("manager_action_save.lua", "setNPCSave", "nLevel", nLevel);
        
        if (nLevel > 17) then
            nSaveScore = DataCommonADND.aWarriorSaves[17][nSaveIndex];
        elseif (nLevel < 1) then
            nSaveScore = DataCommonADND.aWarriorSaves[0][nSaveIndex];
        else
            nSaveScore = DataCommonADND.aWarriorSaves[nLevel][nSaveIndex];
        --Debug.console("manager_action_save.lua", "setNPCSave", "DataCommonADND.aWarriorSaves[nLevel][nSaveIndex]", DataCommonADND.aWarriorSaves[nLevel][nSaveIndex]);
        end
    end

    --Debug.console("manager_action_save.lua", "setNPCSave", "nSaveScore", nSaveScore);
    
    DB.setValue(nodeEntry, "saves." .. sSave .. ".score", "number", nSaveScore);
    DB.setValue(nodeEntry, "saves." .. sSave .. ".base", "number", nSaveScore);

    --Debug.console("manager_action_save.lua", "setNPCSave", "setValue Done");

    return nSaveScore;
end

function getNpcFightsAs()
    Debug.console("getNpcFightsAs");
    local sFightsAs = DB.getValue(nodeNPC, "fights_as", "1");
    return sFightsAs;
end