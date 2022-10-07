pcLastInit = 0
npcLastInit = 0
pcInit = 0
npcInit = 0

OOB_MSGTYPE_APPLYINIT = "applyinit"

function onInit()
	--getRollOrig = ActionInit.getRoll
	ActionInit.getRoll = getRollAdndOpHr

	--handleApplyInitOrig = ActionInit.handleApplyInit
	ActionInit.handleApplyInit = handleApplyInitAdndOpHr

	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYINIT, handleApplyInitAdndOpHr)
end

-- initiative roll, from item entry in ct or init button on character
function getRollAdndOpHr(rActor, bSecretRoll, rItem)
	Debug.console("getRollAdndOpHr", rActor, bSecretRoll, rItem);

	local bOptInitMods = (OptionsManager.getOption("initiativeModifiersAllow") == "on")
	--local bOptInitSizeMods = (OptionsManager.getOption("OPTIONAL_INIT_SIZEMODS") == "on")
	local sOptInitGrouping = OptionsManager.getOption("initiativeGrouping")
	
	local rRoll

	local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor)

	-- init modifiers on
	if bOptInitMods then
		-- check grouping types and actor types to determine whether init mods should be supported
		if sOptInitGrouping == "both" then
			rRoll = getRollNoMods(rActor, bSecretRoll, rItem)
		elseif sOptInitGrouping == "pc" and sActorType == "pc" then
			rRoll = getRollNoMods(rActor, bSecretRoll, rItem)
		elseif sOptInitGrouping == "npc" and sActorType == "ct" then
			rRoll = getRollNoMods(rActor, bSecretRoll, rItem)
		else
			-- default, with modifiers
			rRoll = getRoll(rActor, bSecretRoll, rItem)
		end
	-- init modifiers off
	else
		rRoll = getRollNoMods(rActor, bSecretRoll, rItem)
	end

	--Debug.console("getRollAdndOpHr", rRoll.aDice);
	return rRoll
end

-- standard roll when modifiers are turned on
function getRoll(rActor, bSecretRoll, rItem)
	local bOptInitSizeMods = (OptionsManager.getOption("OPTIONAL_INIT_SIZEMODS") == "on")

	local rRoll = {}
	rRoll.sType = "init"
	rRoll.aDice = {"d" .. DataCommonADND.nDefaultInitiativeDice}
	rRoll.nMod = 0

	rRoll.sDesc = "[INIT]"

	rRoll.bSecret = bSecretRoll

	-- Determine the modifier and ability to use for this roll
	local sAbility = nil
	-- local nodeActor = ActorManager.getCreatureNode(rActor);
	local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor)
	Debug.console("manager_action_init.lua","getRoll","sActorType",sActorType);
	if nodeActor then
		if rItem then
			if sActorType == "pc" then
				rRoll.nMod = rItem.nInit
				rRoll.sDesc = rRoll.sDesc .. " [MOD:" .. rItem.sName .. "]"
			-- npc get size mod or item mod, whichever is greater
			else
				local itemMod = rItem.nInit
				local sizeMod = 0
				local nMod = 0

				-- size mods enabled
				if bOptInitSizeMods then
					sizeMod = DB.getValue(nodeActor, "initiative.total", 0)
				end
				
				if itemMod >= sizeMod then
					nMod = itemMod

					-- size mods enabled
					if bOptInitSizeMods then
						rRoll.sDesc = rRoll.sDesc .. " [MOD:" .. rItem.sName .. " >= size mod]"
					-- size mods OFF
					else
						rRoll.sDesc = rRoll.sDesc .. " [MOD:" .. rItem.sName .. " - size mods OFF]"
					end
				else
					nMod = sizeMod

					-- size mods enabled
					if bOptInitSizeMods then
						rRoll.sDesc = rRoll.sDesc .. " [MOD:Size Mod:" .. nMod .. "]"
					-- size mods OFF
					else
						rRoll.sDesc = rRoll.sDesc .. " [MOD:" .. nMod .. " - size mods OFF]"
					end
				end

				rRoll.nMod = nMod
			end
		-- pc generic, non-item
		elseif sActorType == "pc" then
			rRoll.nMod = DB.getValue(nodeActor, "initiative.total", 0)
		-- npc generic, non-item
		else
			local nMod = DB.getValue(nodeActor, "initiative.total", 0)

			if nMod == 0 then
				nMod = DB.getValue(nodeActor, "init", 0)
			end
			
			--handle size mods and outputting to chat
			if not bOptInitSizeMods then
				nMod = 0
				rRoll.sDesc = rRoll.sDesc .. " [MOD:Size mods OFF]"
			else
				rRoll.sDesc = rRoll.sDesc .. " [MOD:Size Mod:" .. nMod .. "]"
			end

			rRoll.nMod = nMod
		end
	end

	return rRoll
end

-- standard roll when modifiers are turned off
function getRollNoMods(rActor, bSecretRoll, rItem)
	Debug.console("getRollNoMods", rActor, bSecretRoll, rItem);
	local rRoll = {}

	rRoll.sType = "init"
	rRoll.aDice = {"d" .. DataCommonADND.nDefaultInitiativeDice}
	Debug.console("getRollNoMods", rRoll.aDice);
	rRoll.nMod = 0
	rRoll.sDesc = "[INIT][Mods OFF]"
	rRoll.bSecret = bSecretRoll

	return rRoll
end

-- apply init based on chat window result
function handleApplyInitAdndOpHr(msgOOB)
	local rSource = ActorManager.resolveActor(msgOOB.sSourceNode)
	local nodeEntry = ActorManager.getCTNode(rSource)

	local nInitRoll = tonumber(msgOOB.nTotal) or 0

	local bOptInitTies = (OptionsManager.getOption("initiativeTiesAllow") == "on")
	local bOptInitGroupingSwap = (OptionsManager.getOption("initiativeGroupingSwap") == "on")
	local sOptInitGrouping = OptionsManager.getOption("initiativeGrouping")
	local sOptInitOrdering = OptionsManager.getOption("initiativeOrdering")

	Debug.console("handleApplyInitAdndOpHr", "msgOOB", msgOOB, "sOptInitGrouping", sOptInitGrouping)

	-- set inits to 0, in case a grouping option has been changed and inits not fully reset after some inits have been rolled
	pcInit = 0
	npcInit = 0

	-- grouped initiative options
	if sOptInitGrouping == "both" then
		-- if swapping turned on, swap rolls between sides
		-- if ties turned off, make npc roll higher or lower by 1, determined by initiative ordering
		-- apply results
		
		-- pc rolled
		if ActorManager.isPC(rSource) then
			-- init swap
			if bOptInitGroupingSwap or (User.getRulesetName() == "OSRIC") then
				-- apply to npcs
				npcInit = nInitRoll
				npcLastInit = npcInit
				pcInit = 0
			else
				-- apply to pcs
				pcInit = nInitRoll
				pcLastInit = pcInit
				npcInit = 0
			end
		-- npc rolled
		else
			-- init swap
			if bOptInitGroupingSwap or (User.getRulesetName() == "OSRIC") then
				-- apply to pcs
				pcInit = nInitRoll
				pcLastInit = pcInit
				npcInit = 0
			else
				-- apply to npcs
				npcInit = nInitRoll
				npcLastInit = npcInit
				pcInit = 0
			end
		end

		Debug.console("SOPTINITGROUPING", sOptInitGrouping, "BOPTINITGROUPINGSWAP", bOptInitGroupingSwap, "BOPTINITTIES", bOptInitTies, "PCINIT", pcInit, "NPCINIT", npcInit, "PCLASTINIT", pcLastInit, "NPCLASTINIT", npcLastInit)

		-- handle disallowing ties
		if not bOptInitTies then
			if pcLastInit == npcLastInit then
				Debug.console("TIE FOUND, FIX")

				if sOptInitOrdering == "ascending" then
					if pcInit == 1 then
						-- don't want inits of 0 or less
						npcInit = npcInit + 1
					else
						pcInit = pcInit - 1
					end
				else
					if pcInit == 10 then
						-- don't want inits of higher than 10
						npcInit = npcInit - 1
					else
						pcInit = pcInit + 1
					end
				end

				-- we should be finished with these values now, so reset them?
				pcLastInit = 0
				npcLastInit = 0
			end
		end

	elseif sOptInitGrouping == "pc" then
		-- apply pc result to all pcs
		-- pc rolled
		if ActorManager.isPC(rSource) then
			pcInit = nInitRoll
			npcInit = 0
		-- npc rolled
		else
			-- apply result to the actor that rolled it
			applyIndividualInit(nInitRoll, nodeEntry)
		end
	elseif sOptInitGrouping == "npc" then
		-- apply npc result to all npcs
		-- npc rolled
		if not ActorManager.isPC(rSource) then
			npcInit = nInitRoll
			pcInit = 0
		-- pc rolled
		else
			-- apply result to the actor that rolled it
			applyIndividualInit(nInitRoll, nodeEntry)
		end
	end
	
	Debug.console("SOPTINITGROUPING", sOptInitGrouping, "BOPTINITGROUPINGSWAP", bOptInitGroupingSwap, "BOPTINITTIES", bOptInitTies, "PCINIT", pcInit, "NPCINIT", npcInit)

	if pcInit ~= 0 then
		applyInitResultToAllPCs(pcInit)
	elseif npcInit ~= 0 then
		applyInitResultToAllNPCs(npcInit)
	end
	
	if sOptInitGrouping == "neither" then
		-- apply result to the actor that rolled it
		applyIndividualInit(nInitRoll, nodeEntry)
	end
end

-- function resolveInitTie(actorType, pcLastInit, npcLastInit, bOptInitGroupingSwap)
-- 	-- -- only if one or the other has already been rolled so we have something to compare to
-- 	-- -- mainly done in case init is rolled mutiple times for either side
-- 	--if (pcLastInit ~= 0) and (npcLastInit ~= 0) then
-- 		local bOptInitTies = (OptionsManager.getOption("initiativeTiesAllow") == "on")
-- 		local nInitResult = 0
-- 		Debug.console("resolveInitTie", "actorType", actorType, "pcLastInit", pcLastInit, "npcLastInit", npcLastInit, "bOptInitTies", bOptInitTies, "bOptInitGroupingSwap", bOptInitGroupingSwap)

-- 		-- a pc rolled
-- 		if actorType == "pc" then
-- 			-- if the roll is the same as the previous npc roll
-- 			if pcLastInit == npcLastInit then
-- 				Debug.console("pcLastInit = npcLastInit")
-- 				-- ties off
-- 				if not bOptInitTies then
-- 					-- reduce the pc init by 1
-- 					nInitResult = pcLastInit - 1
-- 					Debug.console("ties off", "nInitResult", nInitResult)
-- 				else
-- 					-- keep the pc init
-- 					Debug.console("ties on", "nInitResult", nInitResult)
-- 					nInitResult = pcLastInit
-- 				end
-- 			else
-- 				Debug.console("pcLastInit <> npcLastInit")
-- 				-- init swap
-- 				if bOptInitGroupingSwap or (User.getRulesetName() == "OSRIC") then
-- 					nInitResult = npcLastInit
-- 					Debug.console("swap!", nInitResult)
-- 				else
-- 					nInitResult = pcLastInit
-- 					Debug.console("no swap...", nInitResult)
-- 				end
-- 			end
-- 		-- an npc rolled
-- 		else
-- 			-- if the roll is the same as the previous pc roll
-- 			if npcLastInit == pcLastInit then
-- 				Debug.console("npcLastInit = pcLastInit")
-- 				-- ties off
-- 				if not bOptInitTies then
-- 					-- increase the npc init by 1
-- 					nInitResult = npcLastInit + 1
-- 					Debug.console("ties off", "nInitResult", nInitResult)
-- 				else
-- 					-- keep the npc init
-- 					Debug.console("ties on", "nInitResult", nInitResult)
-- 					nInitResult = npcLastInit
-- 				end
-- 			else
-- 				Debug.console("npcLastInit <> pcLastInit")
-- 				-- init swap
-- 				if bOptInitGroupingSwap or (User.getRulesetName() == "OSRIC") then
-- 					nInitResult = pcLastInit
-- 					Debug.console("swap!", nInitResult)
-- 				else
-- 					nInitResult = npcLastInit
-- 					Debug.console("no swap...", nInitResult)
-- 				end
-- 			end
-- 		end
-- 	--only one has been rolled, either by the pcs or npcs
-- 	-- else
-- 	-- 	Debug.console("one of the inits is zero")
-- 	-- 	-- a pc rolled
-- 	-- 	if actorType == "pc" then
-- 	-- 		nInitResult = pcLastInit
-- 	-- 	-- an npc rolled
-- 	-- 	else
-- 	-- 		nInitResult = npcLastInit
-- 	-- 	end
-- 	-- end

-- 	-- pcLastInit = 0
-- 	-- npcLastInit = 0

-- 	Debug.console("return nInitResult", nInitResult)
-- 	return nInitResult
-- end

function applyInitResultToAllPCs(nInitResult)
	Debug.console("applyInitResultToAllPCs", nInitResult)
	-- group init - apply init result to all PCs
	for _, nodeEntry in pairs(CombatManager.getCombatantNodes()) do
		if DB.getValue(nodeEntry, "friendfoe") == "friend" then
			-- just set both of these values regardless of initiative die used, so we don't have to mod other places where initresult is displayed
			DB.setValue(nodeEntry, "initresult", "number", nInitResult)
			DB.setValue(nodeEntry, "initresult_d6", "number", nInitResult)
			-- set init rolled
			DB.setValue(nodeEntry, "initrolled", "number", 1)
		end
	end
end

function applyInitResultToAllNPCs(nInitResult)
	Debug.console("applyInitResultToAllNPCs", nInitResult)
	-- group init - apply init result to remaining NPCs
	for _, nodeEntry in pairs(CombatManager.getCombatantNodes()) do
		if DB.getValue(nodeEntry, "friendfoe") ~= "friend" then
			-- reset nInitResult
			nInitResult = nInitResult
			-- get custom init value
			-- default to 0 each iteration
			local nCustomInit = 0
			-- get actual value
			nCustomInit = DB.getValue(nodeEntry, "init", 0)
			-- new var for storing any new result
			local nInitResultNew = 0

			local bOptInitSizeMods = (OptionsManager.getOption("OPTIONAL_INIT_SIZEMODS") == "on")

			-- Override, TODO should figure out why OSRIC isn't initializing DataCommonADND.nDefaultInitiativeDice and not sure about why 2E is initializing as string
			local initiativeDie = 0

			if User.getRulesetName() == "OSRIC" then
				initiativeDie = 6
			else
				initiativeDie = tonumber(DataCommonADND.nDefaultInitiativeDice)
			end

			-- modify init for custom inits higher than the max init die (zombies, etc)
			if nCustomInit > initiativeDie then
				nInitResultNew = nCustomInit
			-- use the modifier that's already been calculated
			else
				nInitResultNew = nInitResult
			end

			--Debug.console("applyInitResultToAllNPCs", "nInitResult", nInitResult, "nCustomInit", nCustomInit, "nInitResultNew", nInitResultNew)
			Debug.console("applyInitResultToAllNPCs", "nInitResult", nInitResult, "nCustomInit", nCustomInit, "nInitResultNew", nInitResultNew)
			-- just set both of these values regardless of initiative die used, so we don't have to mod other places where initresult is displayed
			DB.setValue(nodeEntry, "initresult", "number", nInitResultNew)
			DB.setValue(nodeEntry, "initresult_d6", "number", nInitResultNew)
			-- set init rolled
			DB.setValue(nodeEntry, "initrolled", "number", 1)
		end
	end
end

function applyIndividualInit(nInitResult, nodeEntry)
	-- reset nInitResult
	nInitResult = nInitResult
	-- get custom init value
	-- default to 0 each iteration
	local nCustomInit = 0
	-- get actual value
	nCustomInit = DB.getValue(nodeEntry, "init", 0)
	-- new var for storing any ne result
	local nInitResultNew = 0

	local bOptInitSizeMods = (OptionsManager.getOption("OPTIONAL_INIT_SIZEMODS") == "on")
	
	-- Override, TODO should figure out why OSRIC isn't initializing DataCommonADND.nDefaultInitiativeDice and not sure about why 2E is initializing as string
	local initiativeDie = 0

	if User.getRulesetName() == "OSRIC" then
		initiativeDie = 6
	else
		initiativeDie = tonumber(DataCommonADND.nDefaultInitiativeDice)
	end

	-- modify init for custom inits higher than the max init die (zombies, etc)
	if nCustomInit > initiativeDie then
		nInitResultNew = nCustomInit
	-- use the modifier that's already been calculated
	else
		nInitResultNew = nInitResult
	end

	-- just set both of these values regardless of initiative die used, so we don't have to mod other places where initresult is displayed
	DB.setValue(nodeEntry, "initresult", "number", nInitResultNew)
	DB.setValue(nodeEntry, "initresult_d6", "number", nInitResultNew)
	-- set init rolled
	DB.setValue(nodeEntry, "initrolled", "number", 1)
end
