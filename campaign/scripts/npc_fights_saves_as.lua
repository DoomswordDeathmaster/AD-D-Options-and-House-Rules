function onInit()
    Debug.console("npc_fights_saves_as");
    local node = getDatabaseNode();

    if super and super.onInit then
        Debug.console("super and oninit found");
        super.onInit();
    end
end

function onClose()
    if super and super.onClose then
        Debug.console("super and onclose found");
        super.onClose();
    end
end

-- allow drag/drop of class/race/backgrounds onto main sheet
function onDrop(x, y, draginfo)
    Debug.console("drop");
    if draginfo.isType("shortcut") then
        Debug.console(draginfo.getDescription());
        local node = getDatabaseNode();
        local sClass, sRecord = draginfo.getShortcutData();
        
        Debug.console(sClass:gsub("Class: ", ""));
        Debug.console(sRecord);
        Debug.console(draginfo.getStringData());
        Debug.console(x, y, draginfo);
        
        if StringManager.contains({"reference_class"}, sClass) then
            if y >= 194 and y<= 222 then
                local fightsAsClass = draginfo.getDescription():gsub("Class: ", "");
                addFightsAsDb(node, sClass, fightsAsClass);
                Debug.console(fightsAsClass);
                FightsSavesAsManager.updateCombatValuesNPC(node, fightsAsClass, 0);
            elseif y >= 327 and y <= 352 then
                local savesAsClass = draginfo.getDescription():gsub("Class: ", "");
                addSavesAsDb(node, sClass, savesAsClass);
                Debug.console(savesAsClass);
                FightsSavesAsManager.updateSavesNPC(node, savesAsClass, 0);
            end
        end
    end

    UtilityManagerADND.onDropStory(x, y, draginfo, getDatabaseNode());
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