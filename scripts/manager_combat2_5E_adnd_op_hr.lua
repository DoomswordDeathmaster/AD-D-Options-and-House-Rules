-- function rollRandomInit(nMod, bADV, bDIS)
-- 	local nInitResult = math.random(20);
-- 	if bADV and not bDIS then
-- 		nInitResult = math.max(nInitResult, math.random(20));
-- 	elseif bDIS and not bADV then
-- 		nInitResult = math.min(nInitResult, math.random(20));
-- 	end
-- 	nInitResult = nInitResult + nMod;
-- 	return nInitResult;
-- end

-- function rollEntryInit(nodeEntry)
-- 	if not nodeEntry then
-- 		return;
-- 	end
	
-- 	-- Start with the base initiative bonus
-- 	local nInit = DB.getValue(nodeEntry, "init", 0);
	
-- 	-- Get any effect modifiers
-- 	local bADV = false;
-- 	local bDIS = false;
-- 	local rActor = ActorManager.resolveActor(nodeEntry);
-- 	local bEffects, aEffectDice, nEffectMod, bEffectADV, bEffectDIS = ActionInit.getEffectAdjustments(rActor);
-- 	if bEffects then
-- 		nInit = nInit + StringManager.evalDice(aEffectDice, nEffectMod);
-- 		if bEffectADV then
-- 			bADV = true;
-- 		end
-- 		if bEffectDIS then
-- 			bDIS = true;
-- 		end
-- 	end

-- 	-- For PCs, we always roll unique initiative
-- 	local sClass, sRecord = DB.getValue(nodeEntry, "link", "", "");
-- 	if sClass == "charsheet" then
-- 		local nInitResult = rollRandomInit(nInit, bADV, bDIS);
-- 		DB.setValue(nodeEntry, "initresult", "number", nInitResult);
-- 		return;
-- 	end
	
-- 	-- For NPCs, if NPC init option is not group, then roll unique initiative
-- 	local sOptINIT = OptionsManager.getOption("INIT");
-- 	if sOptINIT ~= "group" then
-- 		local nInitResult = rollRandomInit(nInit, bADV, bDIS);
-- 		DB.setValue(nodeEntry, "initresult", "number", nInitResult);
-- 		return;
-- 	end

-- 	-- For NPCs with group option enabled
	
-- 	-- Get the entry's database node name and creature name
-- 	local sStripName = CombatManager.stripCreatureNumber(DB.getValue(nodeEntry, "name", ""));
-- 	if sStripName == "" then
-- 		local nInitResult = rollRandomInit(nInit, bADV, bDIS);
-- 		DB.setValue(nodeEntry, "initresult", "number", nInitResult);
-- 		return;
-- 	end
		
-- 	-- Iterate through list looking for other creature's with same name and faction
-- 	local nLastInit = nil;
-- 	local sEntryFaction = DB.getValue(nodeEntry, "friendfoe", "");
-- 	for _,v in pairs(CombatManager.getCombatantNodes()) do
-- 		if v.getName() ~= nodeEntry.getName() then
-- 			if DB.getValue(v, "friendfoe", "") == sEntryFaction then
-- 				local sTemp = CombatManager.stripCreatureNumber(DB.getValue(v, "name", ""));
-- 				if sTemp == sStripName then
-- 					local nChildInit = DB.getValue(v, "initresult", 0);
-- 					if nChildInit ~= -10000 then
-- 						nLastInit = nChildInit;
-- 					end
-- 				end
-- 			end
-- 		end
-- 	end
	
-- 	-- If we found similar creatures, then match the initiative of the last one found
-- 	if nLastInit then
-- 		DB.setValue(nodeEntry, "initresult", "number", nLastInit);
-- 	else
-- 		local nInitResult = rollRandomInit(nInit, bADV, bDIS);
-- 		DB.setValue(nodeEntry, "initresult", "number", nInitResult);
-- 	end
-- end

-- function rollInit(sType)
-- 	CombatManager.rollTypeInit(sType, rollEntryInit);
-- end