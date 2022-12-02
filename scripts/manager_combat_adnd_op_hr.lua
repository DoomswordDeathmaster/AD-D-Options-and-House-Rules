--
-- AD&D Specific combat needs
--
--

-- for handling determination of ties
pcLastInit = 0
npcLastInit = 0
OOB_MSGTYPE_CHANGEINIT = "changeinitiative"

function onInit()
	--rollEntryInitOrig = CombatManagerADND.rollEntryInit
	CombatManagerADND.rollEntryInit = rollEntryInitAdndOpHr
	CombatManager2.rollEntryInit = rollEntryInitAdndOpHr

	--rollRandomInitOrig = CombatManagerADND.rollRandomInit
	CombatManagerADND.rollRandomInit = rollRandomInitAdndOpHr
	CombatManager2.rollRandomInit = rollRandomInitAdndOpHr

	CombatManagerADND.getLastInitiative = getLastInitiative

	getACHitFromMatrixForNPCOrig = CombatManagerADND.getACHitFromMatrixForNPC
	CombatManagerADND.getACHitFromMatrixForNPC = getACHitFromMatrixForNPCAdndOpHr

	CombatManagerADND.handleInitiativeChange = handleInitiativeChange
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_CHANGEINIT, handleInitiativeChange)

	CombatManager.setCustomCombatReset(resetInitAdndOpHr)
	CombatManager.setCustomRoundStart(onRoundStartAdndOpHr)
	CombatManager.setCustomSort(sortfuncAdndOpHr)
end

-- called when dm rolls init manually or onroundstart
function rollRandomInitAdndOpHr(nInitMod)
	-- Override, TODO should figure out why OSRIC isn't initializing DataCommonADND.nDefaultInitiativeDice and not sure about why 2E is initializing as string
	local initiativeDie = 0

	if User.getRulesetName() == "OSRIC" then
		initiativeDie = 6
	else
		initiativeDie = tonumber(DataCommonADND.nDefaultInitiativeDice)
	end

	--Debug.console("rollRandomInitAdndOpHr", "initiativeDie", initiativeDie)
	local nInitResult = math.random(initiativeDie)
    Debug.console("46: rollRandomInitAdndOpHr", "nInitResult", nInitResult, "nInitMod", nInitMod)

	nInitResult = nInitResult + nInitMod

	-- handle results higher or lower than the max we want to deal with
	if nInitResult <= 0 then
		nInitResult = 1
	elseif nInitResult > 10 then
		nInitResult = 10
	end

    return nInitResult
end

function rollEntryInitAdndOpHr(nodeEntry)
	--Debug.console("rollEntryInitAdndOpHr", nodeEntry)

	local bOptInitMods = (OptionsManager.getOption("initiativeModifiersAllow") == "on")
	local bOptInitSizeMods = (OptionsManager.getOption("OPTIONAL_INIT_SIZEMODS") == "on")
	--local bOptInitTies = (OptionsManager.getOption("initiativeTiesAllow") == "on")
	local sOptInitGrouping = OptionsManager.getOption("initiativeGrouping")
	local bOptInitGroupingSwap = (OptionsManager.getOption("initiativeGroupingSwap") == "on")

	-- for handling determination of ties
	--local pcLastInit = 0
	--local npcLastInit = 0

	if not nodeEntry then
		return
	end

	-- default init mods to 0, should stay that way in OSRIC
	local nInitMOD = 0

	-- effect mods
	-- mods on - 2E option only, no init mods in OSRIC
	if bOptInitMods then
		-- Get any effect modifiers
		local rActor = ActorManager.resolveActor(nodeEntry)
		local aEffectDice, nEffectBonus = EffectManager5E.getEffectsBonus(rActor, "INIT")

		nInitEffectMod = StringManager.evalDice(aEffectDice, nEffectBonus)
		--Debug.console("nInitEffectMod", nInitEffectMod)
	end

	-- Check for the ADVINIT effect
	--local bADV = EffectManager5E.hasEffectCondition(rActor, "ADVINIT")

	-- set custom init to 0
	local nCustomInit = 0

	-- get actual value
	nCustomInit = DB.getValue(nodeEntry, "init", 0)
	--Debug.console("nCustomInit", nCustomInit)

	-- PC/NPC init
	local sClass, sRecord = DB.getValue(nodeEntry, "link", "", "")
	--Debug.console("sClass", sClass, sRecord)

	-- it's a pc
	if sClass == "charsheet" then
		--Debug.console("type", "PC")

		-- init mods enabled
		if bOptInitMods then
			-- init grouping disabled for the pc group
			if (sOptInitGrouping == "neither") or (sOptInitGrouping == "npc") then
				-- get each pc's highest weapon speed factor
				local nSpeedFactor = getHighestWeaponSpeedFactor(nodeEntry)

				-- get total init mod
				nInitMod = nSpeedFactor + nInitEffectMod

				-- roll init and apply mod
				nInitResult = rollRandomInitAdndOpHr(nInitMod)
			-- some init grouping enabled
			else
				-- roll init without mods
				nInitMod = 0
				nInitResult = rollRandomInitAdndOpHr(nInitMod)
			end
		-- init mods disabled
		else
			-- roll init without mods
			nInitMod = 0
			nInitResult = rollRandomInitAdndOpHr(nInitMod)
		end

		pcLastInit = nInitResult

		if sOptInitGrouping == "both" then
			-- init swap
			if bOptInitGroupingSwap or (User.getRulesetName() == "OSRIC") then
				--applyInitResultToAllPCs(npcLastInit)
				applyInitResultToAllNPCs(nInitResult)
				--npcLastInit = nInitResult
			else
				--applyInitResultToAllNPCs(pcLastInit)
				applyInitResultToAllPCs(nInitResult)
				--pcLastInit = nInitResult
			end
		elseif sOptInitGrouping == "pc" then
			applyInitResultToAllPCs(nInitResult)
			--pcLastInit = nInitResult
		else
			--Debug.console("117:PC", "applyIndividualInit", "ninitresult", nInitResult)
			applyIndividualInit(nInitResult, nodeEntry)
		end
	else
		--Debug.console("type", "NPC")

		-- init mods enabled
		if bOptInitMods then
			-- init grouping disabled for the npc group
			if (sOptInitGrouping == "neither") or (sOptInitGrouping == "pc") then
				local nSpeedFactor = getHighestWeaponSpeedFactor(nodeEntry)

				-- size mods enabled
				-- default nInitSizeMod to 0, for disallowing NPC size mods
				local nInitSizeMod = 0
				if bOptInitSizeMods then
					-- Get the base init (size mod)
					nInitSizeMod = DB.getValue(nodeEntry, "init", 0)
				end

				-- apply whichever init mod (size vs speed factor) is greater
				if nSpeedFactor > nInitSizeMod then
					nInitMod = nSpeedFactor
				else
					nInitMod = nInitSizeMod
				end

				-- apply prior mods plus any effects mods
				nInitMod = nInitMod + nInitEffectMod

				-- roll init and apply mods
				nInitResult = rollRandomInitAdndOpHr(nInitMod)
			-- some init grouping enabled
			else
				-- roll init without mods
				nInitMod = 0
				nInitResult = rollRandomInitAdndOpHr(nInitMod)
			end
		-- init mods disabled
		else
			-- roll init without mods
			nInitMod = 0
			nInitResult = rollRandomInitAdndOpHr(nInitMod)
		end

		if sOptInitGrouping == "both" then
			-- evaluate ties and adjust
			nInitResult = resolveInitTie(pcLastInit, nInitResult)

			-- init swap
			if bOptInitGroupingSwap or (User.getRulesetName() == "OSRIC") then
				applyInitResultToAllPCs(nInitResult)
			else
				applyInitResultToAllNPCs(nInitResult)
			end
		elseif sOptInitGrouping == "npc" then
			--npcLastInit = nInitResult
			--nInitResult = resolveInitTie(pcLastInit, nInitResult)
			applyInitResultToAllNPCs(nInitResult)
		else
			--Debug.console("211: NPC", "applyIndividualInit", "nInitResult", nInitResult, "nInitMod", nInitMod)
			applyIndividualInit(nInitResult, nodeEntry)
		end
	end
end

function resolveInitTie(pcLastInit, npcLastInit)
	local bOptInitTies = (OptionsManager.getOption("initiativeTiesAllow") == "on")
	--Debug.console("resolveInitTie", "bOptInitTies", bOptInitTies)

	if not bOptInitTies then
		--Debug.console("pcLastInit", pcLastInit, "npcLastInit", npcLastInit)
		if pcLastInit == nInitResult then
			nInitResult = nInitResult + 1
			--Debug.console("nInitResult", nInitResult)
		end
	end

	return nInitResult
end

function getHighestWeaponSpeedFactor(nodeEntry)
	-- flip through weaponlist, get the largest speedfactor as default
	local nSpeedFactor = 0
	
	for _, nodeWeapon in pairs(DB.getChildren(nodeEntry, "weaponlist")) do
		local nSpeed = DB.getValue(nodeWeapon, "speedfactor", 0)
		if nSpeed > nSpeedFactor then
			nSpeedFactor = nSpeed
		end
	end

	return nSpeedFactor
end

function applyInitResultToAllPCs(nInitResult)
	--Debug.console("applyInitResultToAllPCs", nInitResult)
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
	--Debug.console("applyInitResultToAllNPCs", nInitResult)
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

			-- Override, TODO should figure out why OSRIC isn't initializing DataCommonADND.nDefaultInitiativeDice and not sure about why 2E is initializing as string
			local initiativeDie = 0

			if User.getRulesetName() == "OSRIC" then
				initiativeDie = 6
			else
				initiativeDie = tonumber(DataCommonADND.nDefaultInitiativeDice)
			end

			--local bOptInitMods = (OptionsManager.getOption("initiativeModifiersAllow") == "on")
			--local bOptInitSizeMods = (OptionsManager.getOption("OPTIONAL_INIT_SIZEMODS") == "on")
			--local sOptInitGrouping = OptionsManager.getOption("initiativeGrouping")

			-- modify init results for size or other custom init
			-- higher than the max init die (zombies, etc)
			if nCustomInit > initiativeDie then
				nInitResultNew = nCustomInit
			-- init mods on, size mods on, and grouped init not involving npcs - add size mod to init roll
			--elseif (bOptInitMods and bOptInitSizeMods) and (sOptInitGrouping ~= "both" and sOptInitGrouping ~= "npc") then
			--	nInitResultNew = nInitResult + nCustomInit
			-- just the init roll, including any weapon mods
			else
				nInitResultNew = nInitResult
			end
			
			--Debug.console("applyInitResultToAllNPCs", "nInitResult", nInitResult, "nCustomInit", nCustomInit, "nInitResultNew", nInitResultNew)
			--Debug.console("applyInitResultToAllNPCs", "nInitResult", nInitResult, "nCustomInit", nCustomInit)
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

	--local bOptInitSizeMods = (OptionsManager.getOption("OPTIONAL_INIT_SIZEMODS") == "on")

	-- Override, TODO should figure out why OSRIC isn't initializing DataCommonADND.nDefaultInitiativeDice and not sure about why 2E is initializing as string
	local initiativeDie = 0

	if User.getRulesetName() == "OSRIC" then
		initiativeDie = 6
	else
		initiativeDie = tonumber(DataCommonADND.nDefaultInitiativeDice)
	end

	-- modify init results for size or other custom init
	-- higher than the max init die (zombies, etc)
	if nCustomInit > initiativeDie then
		nInitResultNew = nCustomInit
	-- size mods on, add size mod to init roll
	--elseif bOptInitSizeMods then
	--	nInitResultNew = nInitResult + nCustomInit
	-- just the init roll, including any weapon mods
	else
		nInitResultNew = nInitResult
	end


	-- set custom init as new init result if custom init is higher (zombies, etc)
	-- if nCustomInit > nInitResult then
	-- 	nInitResultNew = nCustomInit
	-- else
	-- 	nInitResultNew = nInitResult
	-- end

	-- just set both of these values regardless of initiative die used, so we don't have to mod other places where initresult is displayed
	DB.setValue(nodeEntry, "initresult", "number", nInitResultNew)
	DB.setValue(nodeEntry, "initresult_d6", "number", nInitResultNew)
	-- set init rolled
	DB.setValue(nodeEntry, "initrolled", "number", 1)
end

--
-- AD&D Style ordering (low to high initiative)
--
function sortfuncAdndOpHr(node2, node1)
	local sOptInitOrdering = OptionsManager.getOption("initiativeOrdering")
	local bHost = Session.IsHost
	local sOptCTSI = OptionsManager.getOption("CTSI")

	local sFaction1 = DB.getValue(node1, "friendfoe", "")
	local sFaction2 = DB.getValue(node2, "friendfoe", "")

	local bShowInit1 = bHost or ((sOptCTSI == "friend") and (sFaction1 == "friend")) or (sOptCTSI == "on")
	local bShowInit2 = bHost or ((sOptCTSI == "friend") and (sFaction2 == "friend")) or (sOptCTSI == "on")

	if bShowInit1 ~= bShowInit2 then
		if bShowInit1 then
			return true
		elseif bShowInit2 then
			return false
		end
	else
		if bShowInit1 then
			local nValue1 = DB.getValue(node1, "initresult", 0)
			local nValue2 = DB.getValue(node2, "initresult", 0)
			if nValue1 ~= nValue2 then
				if (sOptInitOrdering == "ascending") or (User.getRulesetName() == "OSRIC") then
					return nValue1 > nValue2
				else
					return nValue1 < nValue2
				end
			end

			nValue1 = DB.getValue(node1, "init", 0)
			nValue2 = DB.getValue(node2, "init", 0)
			if nValue1 ~= nValue2 then
				if (sOptInitOrdering == "ascending") or (User.getRulesetName() == "OSRIC") then
					return nValue1 > nValue2
				else
					return nValue1 < nValue2
				end
			end
		else
			if sFaction1 ~= sFaction2 then
				if sFaction1 == "friend" then
					return true
				elseif sFaction2 == "friend" then
					return false
				end
			end
		end
	end

	local sValue1 = DB.getValue(node1, "name", "")
	local sValue2 = DB.getValue(node2, "name", "")

	if (sOptInitOrdering == "ascending") or (User.getRulesetName() == "OSRIC") then
		--Debug.console("sOptInitOrdering", sOptInitOrdering, "User.getRulesetName()", User.getRulesetName())
		if sValue1 ~= sValue2 then
			return sValue1 < sValue2
		end

		return node1.getNodeName() < node2.getNodeName()
	else
		if sValue1 ~= sValue2 then
			return sValue2 < sValue1
		end

		return node2.getNodeName() < node1.getNodeName()
	end
end

function handleInitiativeChange(msgOOB)
	local nodeCT = DB.findNode(msgOOB.sCTRecord)

	if nodeCT then
		DB.setValue(nodeCT, "initresult", "number", msgOOB.nNewInit)
		DB.setValue(nodeCT, "initresult_d6", "number", msgOOB.nNewInit)
	end
end

function resetInitAdndOpHr()
	-- set last init results to 0
	pcLastInit = 0
	npcLastInit = 0

	for _, nodeCT in pairs(CombatManager.getCombatantNodes()) do
		resetCombatantInit(nodeCT)
	end
end

function onRoundStartAdndOpHr(nCurrent)
	local bOptAutoRollInitEachRound = (OptionsManager.getOption("HouseRule_InitEachRound") == "on")
	local bOptRoundStartResetInit = (OptionsManager.getOption("roundStartResetInit") == "on")
	local bOptAutoNpcInitiative = (OptionsManager.getOption("autoNpcInitiative") == "on")

	--Debug.console("bOptRoundStartResetInit", bOptRoundStartResetInit)
	pcLastInit = 0
	npcLastInit = 0

	-- toggle portrait initiative icon
	CharlistManagerADND.turnOffAllInitRolled()
	-- toggle all "initrun" values to not run
	CharlistManagerADND.turnOffAllInitRun()

	-- resets init
	if bOptRoundStartResetInit then
		for _, nodeCT in pairs(CombatManager.getCombatantNodes()) do
			resetCombatantInit(nodeCT)
		end
	end

	-- auto rolls all inits
	if bOptAutoRollInitEachRound then
		dmGenerateInit("both")
	end

	-- auto rolls npc inits
	if bOptAutoNpcInitiative then
		dmGenerateInit("npc")
	end
end

function dmGenerateInit(combatantSide)
	--Debug.console("dmGenerateInit", "combatantSide", combatantSide)
	-- roll only for non-friend CT nodes
	if combatantSide == "npc" then
		for _, nodeEntry in pairs(CombatManager.getCombatantNodes()) do
			if DB.getValue(nodeEntry, "friendfoe") ~= "friend" then
				--local rActor = ActorManager.resolveActor(nodeEntry);
				--Debug.console("RACTOR", rActor)
				--ActionInitManagerAdndOpHr.getRollAdndOpHr(rActor, bSecretRoll, rItem)
				rollEntryInitAdndOpHr(nodeEntry)
			end
		end
	-- roll only for non-friend CT nodes
	elseif combatantSide == "pc" then
		for _, nodeEntry in pairs(CombatManager.getCombatantNodes()) do
			if DB.getValue(nodeEntry, "friendfoe") == "friend" then
				rollEntryInitAdndOpHr(nodeEntry)
			end
		end
	-- roll for all CT nodes
	elseif combatantSide == "both" then
		for _, nodeEntry in pairs(CombatManager.getCombatantNodes()) do
			rollEntryInitAdndOpHr(nodeEntry)
		end
	end
end

function resetCombatantInit(nodeCT)
	DB.setValue(nodeCT, "initresult", "number", 0)
	DB.setValue(nodeCT, "initresult_d6", "number", 0)
	DB.setValue(nodeCT, "reaction", "number", 0)

	-- toggle portrait initiative icon
	CharlistManagerADND.turnOffAllInitRolled()
	-- toggle all "initrun" values to not run
	CharlistManagerADND.turnOffAllInitRun()
end

-- return the Best ac hit from a roll for this NPC
function getACHitFromMatrixForNPCAdndOpHr(nodeCT, nRoll)
	--Debug.console(nodeCT, sHitDice, aMatrixRolls)

	local sClass, nodePath = DB.getValue(nodeCT, "sourcelink")
	local nodeNPC = DB.findNode(nodePath)
	--Debug.console("394", sClass, nodeNPC)
	--Debug.console("395", rActor, nodeNPC, sHitDice, aMatrixRolls)

	local nACHit = 20
	local sHitDice = DB.getValue(nodeNPC, "hitDice") --CombatManagerADND.getNPCHitDice(node);
	local aMatrixRolls = {}

	-- default value is 1e.
	local nLowAC = -10
	local nHighAC = 10
	local nTotalACs = 11

	if (DataCommonADND.coreVersion == "becmi") then
		nLowAC = -20
		nHighAC = 19
		nTotalACs = 20
	end

	--Debug.console("nodeNpc", nodeNPC);
	fightsAsClass = DB.getValue(nodeNPC, "fights_as")

	--Debug.console("fightsAs", DB.getValue(nodeNPC, "fights_as"))

	if fightsAsClass ~= nil then
		fightsAsClass = string.gsub(fightsAsClass, "%s+", "")
	else
		fightsAsClass = ""
	end

	fightsAsHdLevel = DB.getValue(nodeNPC, "fights_as_hd_level")

	--Debug.console("111", "npcHitDice", sHitDice, "fightsAsClass", fightsAsClass, "fightsAsHdLevel", fightsAsHdLevel)

	-- fights_as_hd_level not set
	if (fightsAsHdLevel == nil or fightsAsHdLevel == 0) then
		if (sHitDice == "0") then
			sHitDice = "-1"
			fightsAsHdLevel = 0
		elseif (sHitDice == "1-1") then
			-- string contains a +, as in hd 1+1
			fightsAsHdLevel = 1
		elseif string.find(sHitDice, "%+") then
			-- OSRIC
			fightsAsHdLevel = string.match(sHitDice, "%d+") + 2
			-- 1e DMG
			if (sHitDice ~= "1+1") then
				sHitDice = string.match(sHitDice, "%d+")
			else
				sHitDice = "1+"
			end
		elseif (fightsAsClass == "") then
			fightsAsHdLevel = tonumber(sHitDice) + 1
		else
			-- fights_as is set, so take the creature's hd
			fightsAsHdLevel = tonumber(sHitDice)
		end
	end

	--Debug.console("121", "fightsAsClass", fightsAsClass)
	--Debug.console("122", "fightsAsHdLevel", fightsAsHdLevel, "sHitDice", sHitDice)

	if (fightsAsClass ~= "") then
		if (fightsAsClass == "Assassin") then
			if (fightsAsHdLevel >= 13) then
				fightsAsHdLevel = 13
			end

			aMatrixRolls = DataCommonADND.aAssassinToHitMatrix[fightsAsHdLevel]
		elseif (fightsAsClass == "Cleric") then
			if (fightsAsHdLevel >= 19) then
				fightsAsHdLevel = 19
			end

			aMatrixRolls = DataCommonADND.aClericToHitMatrix[fightsAsHdLevel]
		elseif (fightsAsClass == "Druid") then
			if (fightsAsHdLevel >= 13) then
				fightsAsHdLevel = 13
			end

			aMatrixRolls = DataCommonADND.aDruidToHitMatrix[fightsAsHdLevel]
		elseif (fightsAsClass == "Fighter") then
			if (fightsAsHdLevel >= 20) then
				fightsAsHdLevel = 20
			end

			aMatrixRolls = DataCommonADND.aFighterToHitMatrix[fightsAsHdLevel]
		elseif (fightsAsClass == "Illusionist") then
			if (fightsAsHdLevel >= 21) then
				fightsAsHdLevel = 21
			end

			aMatrixRolls = DataCommonADND.aIllusionistToHitMatrix[fightsAsHdLevel]
		elseif (fightsAsClass == "MagicUser") then
			if (fightsAsHdLevel >= 21) then
				fightsAsHdLevel = 21
			end

			aMatrixRolls = DataCommonADND.aMagicUserToHitMatrix[fightsAsHdLevel]
		elseif (fightsAsClass == "Paladin") then
			if (fightsAsHdLevel >= 20) then
				fightsAsHdLevel = 20
			end

			aMatrixRolls = DataCommonADND.aPaladinToHitMatrix[fightsAsHdLevel]
		elseif (fightsAsClass == "Ranger") then
			if (fightsAsHdLevel >= 20) then
				fightsAsHdLevel = 20
			end

			aMatrixRolls = DataCommonADND.aRangerToHitMatrix[fightsAsHdLevel]
		elseif (fightsAsClass == "Thief") then
			if (fightsAsHdLevel >= 21) then
				fightsAsHdLevel = 21
			end

			aMatrixRolls = DataCommonADND.aThiefToHitMatrix[fightsAsHdLevel]
		end
	else
		if (fightsAsHdLevel >= 20) then
			fightsAsHdLevel = 20
		end

		local bmosterAttackMatrices = (OptionsManager.getOption("mosterAttackMatrices") == "on")
		--Debug.console("514", "fightsAsHdLevel", fightsAsHdLevel, "bmosterAttackMatrices", bmosterAttackMatrices)

		if bmosterAttackMatrices then
			aMatrixRolls = DataCommonADND.aOsricToHitMatrix[fightsAsHdLevel]
		else
			aMatrixRolls = DataCommonADND.aMatrix[sHitDice]

			-- for hit dice above 16, use 16
			if (aMatrixRolls == nil) then
				sHitDice = "16"
				aMatrixRolls = DataCommonADND.aMatrix[sHitDice]
			end
		end
	end

	--Debug.console("manager_combat_adnd_op_hr", "getACHitFromMatrixForNPCNew", "aMatrixRolls", aMatrixRolls)
	local nACBase = 11

	if (DataCommonADND.coreVersion == "becmi") then
		nACBase = 20
	end

	for i = #aMatrixRolls, 1, -1 do
		local sCurrentTHAC = "thac" .. i
		local nAC = nACBase - i
		local nCurrentTHAC = aMatrixRolls[i]

		-- get value from db, in case it's been explicitly set
		local nTHACDb = DB.getValue(nodeNPC, "thac" .. i)
		--Debug.console("char_matrix_thaco:151", "nTHACDb", nTHACDb)

		-- get value from aMatrixRolls
		local nTHACM = aMatrixRolls[math.abs(i - nTotalACs)]
		--Debug.console("char_matrix_thaco:155", "nTHACM", nTHACM)

		if (fightsAsClass ~= "" or (fightsAsHdLevel ~= 0 and fightsAsHdLevel ~= tonumber(sHitDice))) then
			--Debug.console("119", fightsAsClass, fightsAsHdLevel, tonumber(sHitDice))
			sCurrentTHAC = nTHACM
			--Debug.console("char_matrix_thaco:173", "nTHAC", nTHAC)
		elseif (nTHACDb ~= nil and nTHACDb ~= nTHACM) then
			sCurrentTHAC = nTHACDb
			--Debug.console("char_matrix_thaco:176", "nTHAC", nTHAC)
		else
			sCurrentTHAC = nTHACM
			--Debug.console("char_matrix_thaco:179", "nTHAC", nTHAC)
		end

		if nRoll >= nCurrentTHAC then
			-- find first AC that matches our roll
			nACHit = nAC
			break
		end
	end

	return nACHit
end

-- return the initiative value of the last entry with initiative.
function getLastInitiative()
	iibOptAdd1eProperties = (OptionsManager.getOption("add1eProperties") == "on")

	if DataCommonADND.coreVersion ~= "2e" then
		nLastInit = 7
	else
		local nLastInit = -100
		for _, nodeCT in pairs(CombatManager.getCombatantNodes()) do
			local nInit = DB.getValue(nodeCT, "initresult", 0)

			if nInit > nLastInit then
				nLastInit = nInit
			end
		end
	end

	return nLastInit
end
