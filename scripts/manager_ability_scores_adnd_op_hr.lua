local fDetailsUpdate;
local fDetailsPercentUpdate;

function onInit()
    fDetailsUpdate = AbilityScoreADND.detailsUpdate;
    AbilityScoreADND.detailsUpdate = detailsUpdateOverride;

    fDetailsPercentUpdate = AbilityScoreADND.detailsPercentUpdate;
    AbilityScoreADND.detailsPercentUpdate = detailsPercentUpdateOverride;    
end

function updateHonor(nodeChar)
    local dbAbility = getHonorProperties(nodeChar);
    
    --DB.setValue(nodeChar, "abilities.honor.honorDice", "string", dbAbility.honorDice);
    DB.setValue(nodeChar, "abilities.honor.score", "number", dbAbility.score);
    --DB.setValue(nodeChar, "abilities.honor.honorWindow", "string", dbAbility.honorWindow);
    --DB.setValue(nodeChar, "abilities.honor.honorState", "number", dbAbility.honorState);
end

function getHonorProperties(nodeChar)
    local nScore = DB.getValue(nodeChar, "abilities.honor.score", 0);
    -- local nMaxActiveClassLevel = CharManager.getAbsoluteClassMaxLevel(nodeChar);
    -- local nActiveClasses = CharManager.getClassCount(nodeChar);
    -- local nSaneLevel = levelSanityCheck(nMaxActiveClassLevel + nActiveClasses - 1);
    -- local nChartIndex = math.ceil(honorSanityCheck(nScore) / 5);
    -- local nHonorState = 0;
    
    -- local sHonorWindow = "Normal";
    -- if nScore < DataCommonPO.aHonorThresholdsByLevel[nSaneLevel][1] then
    --     sHonorWindow = "Dishonor";
    --     nHonorState = -1;
    -- elseif nScore >= DataCommonPO.aHonorThresholdsByLevel[nSaneLevel][2] and nScore <= DataCommonPO.aHonorThresholdsByLevel[nSaneLevel][3] then   
    --     sHonorWindow = "Great Honor";
    --     nHonorState = 1;
    -- elseif nScore > DataCommonPO.aHonorThresholdsByLevel[nSaneLevel][3] then
    --     sHonorWindow = "Too Much Honor";
    --     nHonorState = 2;
    -- end
            
    local dbAbility = {};
    dbAbility.score = nScore;
    -- dbAbility.honorDice = DataCommonPO.aHonorDice[nChartIndex][nSaneLevel];
    -- dbAbility.honorWindow = sHonorWindow;
    -- dbAbility.honorState = nHonorState;
    return dbAbility;
end

function detailsUpdateOverride(nodeChar)
    fDetailsUpdate(nodeChar);
    local nBase =       DB.getValue(nodeChar, "abilities.comeliness.base",9);
    local nBaseMod =    DB.getValue(nodeChar, "abilities.comeliness.basemod",0);
    local nAdjustment = DB.getValue(nodeChar, "abilities.comeliness.adjustment",0);
    local nTempMod =    DB.getValue(nodeChar, "abilities.comeliness.tempmod",0);
    local nFinalBase = nBase;

    -- if Base Modifier isn't 0 then lets use that instead
    if (nBaseMod ~= 0) then
      nFinalBase = nBaseMod;
    end
    
    local nTotal = (nFinalBase + nAdjustment + nTempMod);
    if (nTotal < 1) then
      nTotal = 1;
    end
    if (nTotal > 25) then
      nTotal = 25;
    end
    local nScoreCurrent = DB.getValue(nodeChar, "abilities.comeliness.score",0);
    
    local nTotalCurrent = DB.getValue(nodeChar, "abilities.comeliness.total",0);
    
    if nTotalCurrent ~= nTotal then
      DB.setValue(nodeChar, "abilities.comeliness.total","number", nTotal);
    end
end

function detailsPercentUpdateOverride(nodeChar)
    fDetailsPercentUpdate(nodeChar);
    local nBase =       DB.getValue(nodeChar, "abilities.comeliness.percentbase",0);
    local nBaseMod =    DB.getValue(nodeChar, "abilities.comeliness.percentbasemod",0);
    local nAdjustment = DB.getValue(nodeChar, "abilities.comeliness.percentadjustment",0);
    local nTempMod =    DB.getValue(nodeChar, "abilities.comeliness.percenttempmod",0);
    local nFinalBase = nBase;

    if (nBaseMod ~= 0) then
        nFinalBase = nBaseMod;
    end
    local nTotal = (nFinalBase + nAdjustment + nTempMod);
    if (nTotal < 1) then
        nTotal = 0;
    end
    if (nTotal > 100) then
        nTotal = 100;
    end
    DB.setValue(nodeChar, "abilities.comeliness.percent","number", nTotal);
    DB.setValue(nodeChar, "abilities.comeliness.percenttotal","number", nTotal);
  end

function updateComeliness(nodeChar)
    local dbAbility = getComelinessProperties(nodeChar);
    local nScore = dbAbility.score;
    
    DB.setValue(nodeChar, "abilities.comeliness.score", "number", nScore);
    --DB.setValue(nodeChar, "abilities.comeliness.effects", "string", dbAbility.effects);
    return dbAbility;
end

function getComelinessProperties(nodeChar)
    local nScore = DB.getValue(nodeChar, "abilities.comeliness.total", DB.getValue(nodeChar, "abilities.comeliness.score", 0));
    local rActor = ActorManager.resolveActor(nodeChar);
    
    if rActor then
      -- adjust ability scores from effects!
      local sAbilityEffect = "BCOM";
      local nAbilityMod, nAbilityEffects = EffectManager5E.getEffectsBonus(rActor, sAbilityEffect, true);
      if (nAbilityMod ~= 0) then
       nScore = nAbilityMod;
      end
      
      sAbilityEffect = "COM";
      nAbilityMod, nAbilityEffects = EffectManager5E.getEffectsBonus(rActor, sAbilityEffect, true);
      nScore = nScore + nAbilityMod;
    end
    
    nScore = AbilityScoreADND.abilityScoreSanity(nScore);
    local dbAbility = {};
    dbAbility.score = nScore;
    --dbAbility.effects = DataCommonPO.aComeliness[nScore][1];
    --dbAbility.effects_TT = DataCommonPO.aComeliness[nScore][2];
    return dbAbility;
end