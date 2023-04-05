function updateCombatValuesNPC(nodeNPC, fightsAsClass, fightsAsHdLevel)
	--Debug.console("updateCombatValuesNPC", nodeNPC, fightsAsClass, fightsAsHdLevel)

	local bUseMatrix = (DataCommonADND.coreVersion ~= "2e")
	local nTHACO = DB.getValue(nodeNPC, "combat.thaco.score", 20)
	local sHitDice = DB.getValue(nodeNPC, "hitDice")
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

	fightsAsClass = DB.getValue(nodeNPC, "fights_as")
	fightsAsClass = fightsAsClass:gsub("%s+", "")
	fightsAsHdLevel = DB.getValue(nodeNPC, "fights_as_hd_level")

	--Debug.console("24", "npcHitDice", sHitDice, "fightsAsClass", fightsAsClass, "fightsAsHdLevel", fightsAsHdLevel)

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

	--Debug.console("51", "fightsAsClass", fightsAsClass)
	--Debug.console("52", "fightsAsHdLevel", fightsAsHdLevel, "sHitDice", sHitDice)

	if (fightsAsClass ~= "") then
		if (fightsAsClass == "Assassin") then
			if (fightsAsHdLevel >= 13) then
				fightsAsHdLevel = 13
			end

			aMatrixRolls = DataCommonADND1e.aAssassinToHitMatrix[fightsAsHdLevel]
		elseif (fightsAsClass == "Cleric") then
			if (fightsAsHdLevel >= 19) then
				fightsAsHdLevel = 19
			end
			--Debug.console("65", "fightsAsHdLevel", fightsAsHdLevel, "DataCommonADND1e.aClericToHitMatrix", DataCommonADND1e.aClericToHitMatrix)
			aMatrixRolls = DataCommonADND1e.aClericToHitMatrix[fightsAsHdLevel]
		elseif (fightsAsClass == "Druid") then
			if (fightsAsHdLevel >= 13) then
				fightsAsHdLevel = 13
			end

			aMatrixRolls = DataCommonADND1e.aDruidToHitMatrix[fightsAsHdLevel]
		elseif (fightsAsClass == "Fighter") then
			if (fightsAsHdLevel >= 20) then
				fightsAsHdLevel = 20
			end

			aMatrixRolls = DataCommonADND1e.aFighterToHitMatrix[fightsAsHdLevel]
		elseif (fightsAsClass == "Illusionist") then
			if (fightsAsHdLevel >= 21) then
				fightsAsHdLevel = 21
			end

			aMatrixRolls = DataCommonADND1e.aIllusionistToHitMatrix[fightsAsHdLevel]
		elseif (fightsAsClass == "MagicUser") then
			if (fightsAsHdLevel >= 21) then
				fightsAsHdLevel = 21
			end

			aMatrixRolls = DataCommonADND1e.aMagicUserToHitMatrix[fightsAsHdLevel]
		elseif (fightsAsClass == "Paladin") then
			if (fightsAsHdLevel >= 20) then
				fightsAsHdLevel = 20
			end

			aMatrixRolls = DataCommonADND1e.aPaladinToHitMatrix[fightsAsHdLevel]
		elseif (fightsAsClass == "Ranger") then
			if (fightsAsHdLevel >= 20) then
				fightsAsHdLevel = 20
			end

			aMatrixRolls = DataCommonADND1e.aRangerToHitMatrix[fightsAsHdLevel]
		elseif (fightsAsClass == "Thief") then
			if (fightsAsHdLevel >= 21) then
				fightsAsHdLevel = 21
			end

			aMatrixRolls = DataCommonADND1e.aThiefToHitMatrix[fightsAsHdLevel]
		end
	else
		if (fightsAsHdLevel >= 20) then
			fightsAsHdLevel = 20
		end

		local bmonsterAttackMatrices = (OptionsManager.getOption("monsterAttackMatrices") == "on")
		--Debug.console("116", "fightsAsHdLevel", fightsAsHdLevel, "bmonsterAttackMatrices", bmonsterAttackMatrices)

		if bmonsterAttackMatrices then
			aMatrixRolls = DataCommonADND1e.aOsricToHitMatrix[fightsAsHdLevel]
		else
			aMatrixRolls = DataCommonADND1e.aMatrix[sHitDice]

			-- for hit dice above 16, use 16
			if (aMatrixRolls == nil) then
				sHitDice = "16"
				aMatrixRolls = DataCommonADND1e.aMatrix[sHitDice]
			end
		end
	end

	--Debug.console("131", "aMatrixrolls", aMatrixRolls)

	-- assign matrix values
	for i = nLowAC, nHighAC, 1 do
		local nTHAC = nTHACO - i -- to hit AC value. Current THACO for this Armor Class. so 20 - 10 for AC 10 would be 30.

		--Debug.console("manager_fights_saves_as:138", "nodeNPC", nodeNPC)
		-- db values only for PCs, calculated values for NPCs
		if bUseMatrix then
			if bisPC then
				--Debug.console("manager_fights_saves_as:142", bisPC)
				nTHAC = DB.getValue(nodeNPC, "combat.matrix.thac" .. i, 20)
			else
				-- math.abs(i-11), this table is reverse of how we display the matrix
				-- so we start at the end instead of at the front by taking I - 11 then get the absolute value of it.
				nTHAC = aMatrixRolls[math.abs(i - 11)]

				-- get value from db, in case it's been explicitly set
				local nTHACDb = DB.getValue(nodeNPC, "thac" .. i)
				--Debug.console("manager_fights_saves_as:151", "nTHACDb", nTHACDb)

				-- get value from aMatrixRolls
				local nTHACM = aMatrixRolls[math.abs(i - nTotalACs)]
				--Debug.console("manager_fights_saves_as:155", "nTHACM", nTHACM)

				if (fightsAsClass ~= "" or fightsAsHdLevel ~= 0) then
					--Debug.console("87", fightsAsClass, fightsAsHdLevel)
					nTHAC = nTHACM
					--Debug.console("manager_fights_saves_as:160", "nTHAC", nTHAC)
				elseif (nTHACDb ~= nil and nTHACDb ~= nTHACM) then
					nTHAC = nTHACDb
					--Debug.console("manager_fights_saves_as:163", "nTHAC", nTHAC)
				else
					nTHAC = nTHACM
					--Debug.console("manager_fights_saves_as:166", "nTHAC", nTHAC)
				end

				DB.setValue(nodeNPC, "thac" .. i, "number", nTHAC)
			end
		end
	end
end

function updateSavesNPC(nodeNPC, savesAsClass, savesAsHdLevel)
	--Debug.console("updateSavesNpc")
	--Debug.console(nodeNPC)
	local sHitDice = CombatManagerADND.getNPCHitDice(nodeNPC)
	local aSaveScores = {}
	local saveScore = 20

	if (savesAsClass == "") then
		savesAsClass = DB.getValue(nodeNPC, "saves_as")
	end

	-- if (savesAsHdLevel == 0) then
	-- 	savesAsHdLevel = DB.getValue(nodeNPC, "saves_as_hd_level")
	-- end

	--Debug.console("15:savesAsClass", savesAsClass)
	--Debug.console("16:savesAsHdLevel", savesAsHdLevel)

	-- fights_as_hd_level not set
	if (savesAsHdLevel == nil or savesAsHdLevel == 0) then
		if (sHitDice == "0") then
			sHitDice = "-1"
			savesAsHdLevel = 0
		elseif (sHitDice == "1-1") then
			-- string contains a +, as in hd 1+1
			savesAsHdLevel = 1
		elseif string.find(sHitDice, "%+") then
			-- OSRIC
			savesAsHdLevel = string.match(sHitDice, "%d+") + 2
			-- 1e DMG
			if (sHitDice ~= "1+1") then
				sHitDice = string.match(sHitDice, "%d+")
			else
				sHitDice = "1+"
			end
		elseif (savesAsClass == "") then
			savesAsHdLevel = tonumber(sHitDice) + 1
		else
			-- fights_as is set, so take the creature's hd
			savesAsHdLevel = tonumber(sHitDice)
		end
	end

	if (savesAsHdLevel == 0) then
		savesAsHdLevel = tonumber(sHitDice)
	end

	--Debug.console("manager:62", nodeNPC, nodeNPC)
	updateNPCSaves(nodeNPC, nodeNPC, savesAsClass, savesAsHdLevel)
end

-- Set NPC Saves -celestian
-- move to manager_action_save.lua?
function updateNPCSaves(nodeEntry, nodeNPC, savesAsClass, savesAsHdLevel)
	--Debug.console("manager:203", "nodeEntry", nodeEntry, "nodeNPC", nodeNPC, "savesAsClass", savesAsClass, "savesAsHdLevel", savesAsHdLevel)
	--if  (bForceUpdate) or (DB.getChildCount(nodeNPC, "saves") <= 0) then
	for i = 1, 10, 1 do
		local sSave = DataCommon.saves[i]
		--Debug.console("manager:73", nodeEntry, sSave, nodeNPC)
		--local nSave = DB.getValue(nodeNPC, "saves." .. sSave .. ".score", -1);
		setNPCSave(nodeEntry, sSave, nodeNPC, savesAsClass, savesAsHdLevel)
	end
	--end
end

function setNPCSave(nodeEntry, sSave, nodeNPC, savesAsClass, savesAsHdLevel)
	local nSaveIndex = DataCommonADND.saves_table_index[sSave]
	local aSaveScores = {}

	savesAsClass = savesAsClass:gsub("%s+", "")

	--Debug.console("220", "savesAsClass", savesAsClass, "savesAsHdLevel", savesAsHdLevel)

	if (savesAsClass ~= "") then
		if (savesAsClass == "Assassin") then
			if (savesAsHdLevel >= 13) then
				savesAsHdLevel = 13
			end

			aSaveScores = DataCommonADND1e.aAssassinSaves[savesAsHdLevel]
		elseif (savesAsClass == "Cleric") then
			if (savesAsHdLevel >= 19) then
				savesAsHdLevel = 19
			end

			aSaveScores = DataCommonADND1e.aClericSaves[savesAsHdLevel]
		elseif (savesAsClass == "Druid") then
			if (savesAsHdLevel >= 13) then
				savesAsHdLevel = 13
			end

			aSaveScores = DataCommonADND1e.aDruidSaves[savesAsHdLevel]
		elseif (savesAsClass == "Fighter") then
			if (savesAsHdLevel >= 20) then
				savesAsHdLevel = 20
			end

			aSaveScores = DataCommonADND1e.aFighterSaves[savesAsHdLevel]
		elseif (savesAsClass == "Illusionist") then
			if (savesAsHdLevel >= 21) then
				savesAsHdLevel = 21
			end

			aSaveScores = DataCommonADND1e.aIllusionistSaves[savesAsHdLevel]
		elseif (savesAsClass == "MagicUser") then
			if (savesAsHdLevel >= 21) then
				savesAsHdLevel = 21
			end

			aSaveScores = DataCommonADND1e.aMagicUserSaves[savesAsHdLevel]
		elseif (savesAsClass == "Paladin") then
			if (savesAsHdLevel >= 20) then
				savesAsHdLevel = 20
			end

			aSaveScores = DataCommonADND1e.aPaladinSaves[savesAsHdLevel]
		elseif (savesAsClass == "Ranger") then
			if (savesAsHdLevel >= 20) then
				savesAsHdLevel = 20
			end

			aSaveScores = DataCommonADND1e.aRangerSaves[savesAsHdLevel]
		elseif (savesAsClass == "Thief") then
			if (savesAsHdLevel >= 21) then
				savesAsHdLevel = 21
			end

			aSaveScores = DataCommonADND1e.aThiefSaves[savesAsHdLevel]
		end
	else
		aSaveScores = DataCommonADND1e.aWarriorSaves[savesAsHdLevel]
	end

	--Debug.console("104", aSaveScores, aSaveScores[nSaveIndex])
	local nSaveScore = aSaveScores[nSaveIndex]
	--Debug.console("106", "nodeEntry", nodeEntry, "nodeNPC", nodeNPC, "sSave", sSave, "nSaveScore", nSaveScore)

	DB.setValue(nodeEntry, "saves." .. sSave .. ".score", "number", nSaveScore)
	DB.setValue(nodeEntry, "saves." .. sSave .. ".base", "number", nSaveScore)
end
