---
---
---
---


function onInit()
    -- local node = getDatabaseNode();  
    -- local bisPC = (ActorManager.isPC(node));

    -- Debug.console("char_matrix","onInit","bisPC",bisPC);

    -- DB.addHandler(DB.getPath(node, "fights_as_hd_level"), "onUpdate", createAttackMatrix);

    createAttackMatrix();
end

function onClose()
    -- local node = getDatabaseNode();  
    -- local bisPC = (ActorManager.isPC(node)); 

    -- Debug.console("char_matrix","onClose","bisPC",bisPC); 

    -- DB.removeHandler(DB.getPath(node, "fights_as_hd_level"), "onUpdate", createAttackMatrix);
end

function createAttackMatrix()
    -- default value is 1e.
    local nLowAC = -10;
    local nHighAC = 10;
    local nTotalACs = 11;
    
    if (DataCommonADND.coreVersion == "becmi") then
        nLowAC = -20;
        nHighAC = 19;
        nTotalACs = 20;
    end
  
--   local node = getDatabaseNode();
--   local bClassRecord = node.getPath():match("^class%.");
--   --Debug.console("char_matrix.lua","createAttackMatrix","node",node);

    local node = getDatabaseNode();
    local bisPC = (ActorManager.isPC(node)); 
    local bUseMatrix = (DataCommonADND.coreVersion == "1e");
    local sHitDice = CombatManagerADND.getNPCHitDice(node);
    local bClassRecord = node.getPath():match("^class%.");
    local nTHACO = DB.getValue(node, "combat.thaco.score", 20);
    local fightsAsClass = "";
    local fightsAsHdLevel = 0;
    
    --Debug.console("char_matrix_thaco.lua: 47", "createTHACOMatrix", "node", node);
    
    if (not bisPC) then
        nTHACO = DB.getValue(node, "thaco", 20);
    end
    
    -- 1e matrix
    local aMatrixRolls = {};

    -- assign the proper hit dice and class or monster matrix
    if bUseMatrix and not bisPC and not bClassRecord then
        fightsAsClass = DB.getValue(node, "fights_as");
        fightsAsHdLevel = DB.getValue(node, "fights_as_hd_level");

        Debug.console("fightsAsClass", fightsAsClass);
        Debug.console("fightsAsHdLevel", fightsAsHdLevel);

        if (fightsAsHdLevel == 0) then
            fightsAsHdLevel = tonumber(sHitDice);
        end

        if (fightsAsClass ~= "") then
            if (fightsAsClass == "Assassin") then

                if (fightsAsHdLevel >= 15) then
                    fightsAsHdLevel = 15;
                end

                aMatrixRolls = DataCommonADND.aAssassinToHitMatrix[fightsAsHdLevel];
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
        end
    end

    local sACLabelName = "matrix_ac_label";
    local sRollLabelName = "matrix_roll_label";
    local matrixControlReadOnly = "false";

--   local fightsAsClass = "";

--   -- 1e matrix
--   local bUseMatrix = (DataCommonADND.coreVersion == "1e");
--   local bisPC = (ActorManager.isPC(node)); 
--   local aMatrixRolls = {};
  
--   --Debug.console("char_matrix.lua:39", bClassRecord, bUseMatrix, bisPC);
  
--   -- if it's a 1e npc, use either the class-based matrix or the default hd-based matrix
--   if not bClassRecord and bUseMatrix and not bisPC then
--     local sHitDice = CombatManagerADND.getNPCHitDice(node);

--     fightsAsClass = DB.getValue(node, "fights_as");

--     --Debug.console("char_matrix.lua:47", "fightsAsClass", fightsAsClass);
    
--     -- check if fights_as is set and use the values from the class matrix
--     if (fightsAsClass ~= "") then
--         -- TODO factor in hit dice and finish matrices
--         if (fightsAsClass == "Assassin") then
--             aMatrixRolls = DataCommonADND.aAssassinToHitMatrix[1];
--             --Debug.console("charmatrix.lua:54", "set class-based matrix");
--             --Debug.console("char_matrix.lua:54","createAttackMatrix","isAssassin","aMatrixRolls",aMatrixRolls);
--         end
--     -- use the default hd-based matrix
--     else
--         --Debug.console("charmatrix.lua:58", "set hd-based matrix");
--         aMatrixRolls = DataCommonADND.aMatrix[sHitDice];
--     end
--   end
  
    -- loop through possible ac values and assign a to-hit value
    for i=nLowAC, nHighAC, 1 do
        -- to hit AC value, default to 20
        local nTHAC = DB.getValue(node,"combat.matrix.thac" .. i, 20);

        -- db values only for PCs, calculated values for NPCs
        if bUseMatrix then
            Debug.console("char_matrix:131", bisPC);
            if bisPC or bClassRecord then
                Debug.console("char_matrix:116", bisPC, bClassRecord);
                nTHAC = DB.getValue(node,"combat.matrix.thac" .. i, 20);
                matrixControlReadOnly = "true";
            else--if not bisPC and #aMatrixRolls > 0 then
                -- math.abs(i-11), this table is reverse of how we display the matrix
                -- so we start at the end instead of at the front by taking I - 11 then get the absolute value of it.
                nTHAC = aMatrixRolls[math.abs(i-11)];
        
                -- get value from db, in case it's been explicitly set
                local nTHACDb = DB.getValue(node, "thac" .. i);
                Debug.console("char_matrix:142", "nTHACDb", nTHACDb);
        
                -- get value from aMatrixRolls
                local nTHACM = aMatrixRolls[math.abs(i - nTotalACs)];
                Debug.console("char_matrix:146", "nTHACM", nTHACM);
        
                if (fightsAsClass ~= "" or (fightsAsHdLevel ~= 0 and fightsAsHdLevel ~= tonumber(sHitDice))) then
                    --Debug.console("119", fightsAsClass);
                    nTHAC = nTHACM;
                    matrixControlReadOnly = "true";
                    Debug.console("char_matrix:151", "nTHAC", nTHAC);
                elseif (nTHACDb ~= nil and nTHACDb ~= nTHACM) then
                    nTHAC = nTHACDb;
                    Debug.console("char_matrix:154", "nTHAC", nTHAC);
                else
                    nTHAC = nTHACM;
                    Debug.console("char_matrix:157", "nTHAC", nTHAC);
                end
            end
        end
        --Debug.console("char_matrix.lua:68", nTHAC);

        -- get value from db, in case it's been explicitly set
        --local nTHACDb = DB.getValue(node, "thac" .. i, 20);
        --Debug.console("char_matrix.lua:71", "nTHACDb", nTHACDb);

        -- if bUseMatrix then
        --     -- get value from aMatrixRolls
        --     local nTHACM = aMatrixRolls[math.abs(i - nTotalACs)];
        --     --Debug.console("char_matrix.lua:75", "nTHACM", nTHACM);

        --     Debug.console("79", nTHAC, nTHACDb, nTHACM);

        --     -- compare and take class-based value if fights_as has been set, otherwise take db value (if set) or default hd-based matrix value
        --     if (fightsAsClass ~= "") then
        --         nTHAC = nTHACM;
        --         --Debug.console("char_matrix.lua:80", "nTHAC", nTHAC);
        --     elseif (nTHACDb ~= nTHACM) then
        --         nTHAC = nTHACDb;
        --         Debug.console("char_matrix.lua:86", "nTHAC", nTHAC);
        --     else
        --         nTHAC = nTHACM;
        --         --Debug.console("char_matrix.lua:86", "nTHAC", nTHAC);
        --     end
        -- end

        local sMatrixACName = "matrix_ac_" .. i;
        local sMatrixACValue = i;
        local sMatrixNumberName = "thac" .. i;

        local cntNum = nil;

        cntNum = createControl("number_matrix", sMatrixNumberName); --, "combat.matrix." .. sMatrixNumberName);

        --Debug.console("char_matrix.lua:97", sMatrixACName, sMatrixACValue, sMatrixNumberName, nTHAC);
        if (matrixControlReadOnly == "false") then
            cntNum.setReadOnly(false);
        else
            cntNum.setReadOnly(true);
        end

        cntNum.setValue(nTHAC);

        -- if not bClassRecord and bUseMatrix and not bisPC then
        --     cntNum.setReadOnly(false);
        -- end

        local cntAC = createControl("label_fieldtop_matrix", sMatrixACName);
        
        cntAC.setReadOnly(true);
        cntAC.setValue(sMatrixACValue);
        --cntAC.setValue(nTHAC);
        cntAC.setAnchor("left", sMatrixNumberName,"left","absolute",0);
    end
end