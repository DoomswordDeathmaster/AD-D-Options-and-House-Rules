-- allow drag/drop of class/race/backgrounds onto main sheet
function onDrop(x, y, draginfo)
    Debug.console("drop");
    if draginfo.isType("shortcut") then
        Debug.console(draginfo.getDescription());
        
        local sClass, sRecord = draginfo.getShortcutData();
        
        Debug.console(sClass);
        Debug.console(sRecord);
        
        if StringManager.contains({"reference_class"}, sClass) then
            local fightsAsClass = draginfo.getDescription();
            local savesAsClass = draginfo.getDescription();

            Debug.console(fightsAsClass);
        
            AttackSaveMatricesAdndOpHr.addFightsAsDb(getDatabaseNode(), sClass, fightsAsClass);
            AttackSaveMatricesAdndOpHr.addSavesAsDb(getDatabaseNode(), sClass, savesAsClass);
            AttackSaveMatricesAdndOpHr.updateAttackMatrixNpc(getDatabaseNode(), sClass, fightsAsClass);
            AttackSaveMatricesAdndOpHr.updateSavesNpc(getDatabaseNode(), sClass, fightsAsClass);
        end
    end

    UtilityManagerADND.onDropStory(x, y, draginfo, getDatabaseNode());
  end