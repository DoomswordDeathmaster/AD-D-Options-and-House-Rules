function onInit()
    -- TODO: test super.oninit here
    local nodeChar = getDatabaseNode();
    DB.addHandler("options.HouseRule_ASCENDING_AC", "onUpdate", updateAscendingValues);
  
    DB.addHandler(DB.getPath(nodeChar, "abilities.*.percentbase"),      "onUpdate", updateAbilityScores);
    DB.addHandler(DB.getPath(nodeChar, "abilities.*.percentbasemod"),   "onUpdate", updateAbilityScores);
    DB.addHandler(DB.getPath(nodeChar, "abilities.*.percentadjustment"),"onUpdate", updateAbilityScores);
    DB.addHandler(DB.getPath(nodeChar, "abilities.*.percenttempmod"),   "onUpdate", updateAbilityScores);
  
    DB.addHandler(DB.getPath(nodeChar, "abilities.*.base"),       "onUpdate", updateAbilityScores);
    DB.addHandler(DB.getPath(nodeChar, "abilities.*.basemod"),    "onUpdate", updateAbilityScores);
    DB.addHandler(DB.getPath(nodeChar, "abilities.*.adjustment"), "onUpdate", updateAbilityScores);
    DB.addHandler(DB.getPath(nodeChar, "abilities.*.tempmod"),    "onUpdate", updateAbilityScores);
    
    DB.addHandler(DB.getPath(nodeChar, "hp.base"),        "onUpdate", updateHealthScore);
    DB.addHandler(DB.getPath(nodeChar, "hp.basemod"),     "onUpdate", updateHealthScore);
    --this is managed, not adjusted by players
    --DB.addHandler(DB.getPath(nodeChar, "hp.hpconmod"),  "onUpdate", updateHealthScore);
    
    DB.addHandler(DB.getPath(nodeChar, "hp.adjustment"),  "onUpdate", updateHealthScore);
    DB.addHandler(DB.getPath(nodeChar, "hp.tempmod"),     "onUpdate", updateHealthScore);
    
    -- DB.addHandler(DB.getPath(nodeChar, "inventorylist"),  "onChildDeleted", updateEncumbranceForDelete);
  
    DB.addHandler(DB.getPath(nodeChar, "surprise.base"),     "onUpdate", updateSurpriseScores);
    DB.addHandler(DB.getPath(nodeChar, "surprise.tempmod"),     "onUpdate", updateSurpriseScores);
    DB.addHandler(DB.getPath(nodeChar, "surprise.mod"),     "onUpdate", updateSurpriseScores);
    
    DB.addHandler(DB.getPath(nodeChar, "initiative.tempmod"),     "onUpdate", updateInitiativeScores);
    DB.addHandler(DB.getPath(nodeChar, "initiative.misc"),     "onUpdate", updateInitiativeScores);
  
    DB.addHandler(DB.getPath(nodeChar, "abilities.strength.score"), "onUpdate", onEncumbranceChanged);
  
    --// TODO is this necessary?
    --DB.addHandler("combattracker.list", "onChildDeleted", updatesBulk);
    
    updateAbilityScores(nodeChar);
    updateAscendingValues();

    updateSurpriseScores();
    updateInitiativeScores();
end

---
--- Update surprise scores
---
function updateSurpriseScores()
    local sOptSurpriseDie = OptionsManager.getOption("surpriseDie");

    local nodeChar = getDatabaseNode();

    -- with default d10 surprise die
    local surpriseBase = 3;

    -- d6
    if sOptSurpriseDie == "d6" then
        surpriseBase = 2;
    -- d12
    elseif sOptSurpriseDie == "d12" then
        surpriseBase = 4;
    end

    local nMod = DB.getValue(nodeChar,"surprise.mod",0);
    local nTmpMod = DB.getValue(nodeChar,"surprise.tempmod",0);
    local nTotal = surpriseBase + nMod + nTmpMod;

    DB.setValue(nodeChar,"surprise.total","number",nTotal);
    DB.setValue(nodeChar,"surprise.base","number",surpriseBase);
end

---
--- Update initiative scores
---
function updateInitiativeScores()
  local nodeChar = getDatabaseNode();

    -- default with modifiers on
    local initiativeMod = DB.getValue(nodeChar,"initiative.misc",0);
    -- modifiers off
    if OptionsManager.getOption("initiativeModifiersAllow") == "off" then
        initiativeMod = 0;
    end
    
  local nTmpMod = DB.getValue(nodeChar,"initiative.tempmod",0);
  local nTotal = initiativeMod + nTmpMod;

  DB.setValue(nodeChar,"initiative.total","number",nTotal);
  DB.setValue(nodeChar,"initiative.misc","number",nMod);
end