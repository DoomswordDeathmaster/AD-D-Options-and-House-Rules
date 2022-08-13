---
--- Creates controls/updates for THACO Attack Matrix window
---
---
function onInit()
    local node = getDatabaseNode();
    --Debug.console("char_matrix_thaco.lua","onInit","node",node);      
    local bisPC = (ActorManager.isPC(node)); 
    --Debug.console("char_matrix_thaco.lua","onInit","bisPC",bisPC);      
    local bUseMatrix = (DataCommonADND.coreVersion == "1e");
    --Debug.console("char_matrix_thaco.lua","onInit","bUseMatrix1",bUseMatrix);    
  
    if bUseMatrix then
        -- default value is 1e.
        local nLowAC = -10;
        local nHighAC = 10;
        local nTotalACs = 11;
        
        if (DataCommonADND.coreVersion == "becmi") then
            nLowAC = -20;
            nHighAC = 19;
            nTotalACs = 20;
        end

        for i=nLowAC, nHighAC, 1 do
            DB.addHandler(DB.getPath(node, "thac" .. i), "onUpdate", update);
        end
    else
        if (bisPC) then
            DB.addHandler(DB.getPath(node, "combat.thaco.score"), "onUpdate", update);
        else
            DB.addHandler(DB.getPath(node, "thaco"), "onUpdate", update);
        end
    end

    createTHACOMatrix();
end

function onClose()
    local node = getDatabaseNode();
    local bisPC = (ActorManager.isPC(node)); 
    local bUseMatrix = (DataCommonADND.coreVersion == "1e");

    if bUseMatrix then
        --DB.removeHandler(DB.getPath(node, "combat.matrix.*"), "onUpdate", update);
        -- default value is 1e.
        local nLowAC = -10;
        local nHighAC = 10;
        local nTotalACs = 11;
        
        if (DataCommonADND.coreVersion == "becmi") then
            nLowAC = -20;
            nHighAC = 19;
            nTotalACs = 20;
        end

        for i=nLowAC, nHighAC, 1 do
            DB.removeHandler(DB.getPath(node, "thac" .. i), "onUpdate", update);
        end
    else
        if (bisPC) then
            DB.removeHandler(DB.getPath(node, "combat.thaco.score"), "onUpdate", update);
        else
            DB.removeHandler(DB.getPath(node, "thaco"), "onUpdate", update);  
        end
    end
end

-- create combat_mini_thaco_matrix
function createTHACOMatrix()
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
  local bisPC = (ActorManager.isPC(node));
  local bUseMatrix = (DataCommonADND.coreVersion == "1e");
  local sHitDice = CombatManagerADND.getNPCHitDice(node);
  --local bClassRecord = node.getPath():match("^class%.");
  local nTHACO = DB.getValue(node, "combat.thaco.score", 20);
  local fightsAsClass = "";
  local fightsAsHdLevel = 0;
  local sACLabelName = "matrix_ac_label";
  local sRollLabelName = "matrix_roll_label";
  local sHightlightColor = "a5a7aa";
  local sRedColor = "ddaf90";
  local bHighlight = true;

  --Debug.console("char_matrix_thaco.lua: 47", "createTHACOMatrix", "node", node);
  
  if (not bisPC) then
    nTHACO = DB.getValue(node, "thaco", 20);
  end
  
  -- 1e matrix
  local aMatrixRolls = {};

  -- assign the proper hit dice and class or monster matrix
  if bUseMatrix and not bisPC then
      fightsAsClass = DB.getValue(node, "fights_as");
      fightsAsClass = fightsAsClass:gsub("%s+", "");
      fightsAsHdLevel = DB.getValue(node, "fights_as_hd_level");

      if (fightsAsHdLevel == 0) then
        fightsAsHdLevel = tonumber(sHitDice);
      end

      Debug.console("fightsAsClass", fightsAsClass);
      Debug.console("fightsAsHdLevel", fightsAsHdLevel);

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
          if (fightsAsHdLevel >= 16) then
              fightsAsHdLevel = 16;
          end

          aMatrixRolls = DataCommonADND.aMatrix[tostring(fightsAsHdLevel)];
      end
  end

  -- assign matrix values
  for i=nLowAC, nHighAC, 1 do
    local nTHAC = nTHACO - i; -- to hit AC value. Current THACO for this Armor Class. so 20 - 10 for AC 10 would be 30.
    
    Debug.console("char_matrix_thaco:138", "node", node);
    -- db values only for PCs, calculated values for NPCs
    if bUseMatrix then
      if bisPC then
          Debug.console("char_matrix_thaco:142", bisPC);
          nTHAC = DB.getValue(node,"combat.matrix.thac" .. i, 20);
      else--if not bisPC and #aMatrixRolls > 0 then
          -- math.abs(i-11), this table is reverse of how we display the matrix
          -- so we start at the end instead of at the front by taking I - 11 then get the absolute value of it.
          nTHAC = aMatrixRolls[math.abs(i-11)];

          -- get value from db, in case it's been explicitly set
          local nTHACDb = DB.getValue(node, "thac" .. i);
          Debug.console("char_matrix_thaco:151", "nTHACDb", nTHACDb);

          -- get value from aMatrixRolls
          local nTHACM = aMatrixRolls[math.abs(i - nTotalACs)];
          Debug.console("char_matrix_thaco:155", "nTHACM", nTHACM);

          if (fightsAsClass ~= "" or (fightsAsHdLevel ~= 0 and fightsAsHdLevel ~= tonumber(sHitDice))) then
              Debug.console("119", fightsAsClass, fightsAsHdLevel, tonumber(sHitDice));
              nTHAC = nTHACM;
              Debug.console("char_matrix_thaco:173", "nTHAC", nTHAC);
          elseif (nTHACDb ~= nil and nTHACDb ~= nTHACM) then
              nTHAC = nTHACDb;
              Debug.console("char_matrix_thaco:176", "nTHAC", nTHAC);
          else
              nTHAC = nTHACM;
              Debug.console("char_matrix_thaco:179", "nTHAC", nTHAC);
          end

          DB.setValue(node,"thac" .. i, "number", nTHAC);
      end
    end

    local sMatrixACName = "thaco_matrix_ac_" .. i; -- control name for the AC label
    local sMatrixACValue = i;                      -- AC control value
    local sMatrixNumberName = "thac" .. i;         -- control name for the THACO label
    local cntNum = nil;

    if bUseMatrix then
        cntNum = createControl("number_thaco_matrix", sMatrixNumberName, "combat.matrix." .. sMatrixNumberName);
    else
        cntNum = createControl("number_thaco_matrix", sMatrixNumberName);
    end
    
    cntNum.setFrame(nil);
    cntNum.setValue(nTHAC);
    --DB.setValue(node,"combat.matrix.thac" .. i, "number", nTHAC);

    --Debug.console("char_matrix_thaco.lua:112", cntNum.getValue())

    local cntAC = createControl("label_fieldtop_thaco_matrix", sMatrixACName);
    cntAC.setReadOnly(false);
    cntAC.setValue(sMatrixACValue);

    if (i == 0) then
        cntNum.setBackColor(sRedColor);
        cntAC.setBackColor(sRedColor);
    elseif bHighlight then
        cntNum.setBackColor(sHightlightColor);
        cntAC.setBackColor(sHightlightColor);
    end
    
    cntAC.setAnchor("left", sMatrixNumberName,"left","absolute",0);
    
    bHighlight = not bHighlight;
  end
end

-- update combat_mini_thaco_matrix from db values
function update()
    Debug.console("char_matrix_thaco.lua:130", "updating combat_mini_thaco_matrix");
    local node = getDatabaseNode();
    --Debug.console("char_matrix_thaco.lua:132","update","node",node);
    local bisPC = (ActorManager.isPC(node)); 
    --Debug.console("char_matrix_thaco.lua:134","createTHACOMatrix","node",node);
    local bUseMatrix = (DataCommonADND.coreVersion ~= "2e");

    local nTHACO = DB.getValue(node,"combat.thaco.score",20);

    if (not bisPC) then
        nTHACO = DB.getValue(node,"thaco",20);
    end
    
    -- update to changed THACO. Set the new values in previously created controls
    for i=-10, 10, 1 do
        local nTHAC = nTHACO - i;
        
        -- IF SOMETHING BREAKS, re-add combat.matrix. to thac
        if bUseMatrix then
          nTHAC = DB.getValue(node,"thac" .. i, 20);
          --Debug.console("char_matrix_thaco.lua:151", nTHAC);
        end
        
        local sMatrixNumberName = "thac" .. i; -- control name for the THACO label
        local cnt = self[sMatrixNumberName];   -- get the control for this, stringcontrol named thac-10 .. thac10
        
        --uncomment for updates
        if cnt then
            cnt.setValue(nTHAC); -- set new to hit AC value
        end
    end
end