---
--- Creates controls/updates for THACO Attack Matrix window
---
---
function onInit()
	local node = getDatabaseNode()
	local bisPC = (ActorManager.isPC(node))
	local bUseMatrix = (DataCommonADND.coreVersion == "1e")

	if bUseMatrix then
		-- default value is 1e.
		local nLowAC = -10
		local nHighAC = 10
		local nTotalACs = 11

		if (DataCommonADND.coreVersion == "becmi") then
			nLowAC = -20
			nHighAC = 19
			nTotalACs = 20
		end

		for i = nLowAC, nHighAC, 1 do
			DB.addHandler(DB.getPath(node, "thac" .. i), "onUpdate", update)
		end
	else
		if (bisPC) then
			DB.addHandler(DB.getPath(node, "combat.thaco.score"), "onUpdate", update)
		else
			DB.addHandler(DB.getPath(node, "thaco"), "onUpdate", update)
		end
	end

	createTHACOMatrix()
end

function onClose()
	local node = getDatabaseNode()
	local bisPC = (ActorManager.isPC(node))
	local bUseMatrix = (DataCommonADND.coreVersion == "1e")

	if bUseMatrix then
		-- default value is 1e.
		local nLowAC = -10
		local nHighAC = 10
		local nTotalACs = 11

		if (DataCommonADND.coreVersion == "becmi") then
			nLowAC = -20
			nHighAC = 19
			nTotalACs = 20
		end

		for i = nLowAC, nHighAC, 1 do
			DB.removeHandler(DB.getPath(node, "thac" .. i), "onUpdate", update)
		end
	else
		if (bisPC) then
			DB.removeHandler(DB.getPath(node, "combat.thaco.score"), "onUpdate", update)
		else
			DB.removeHandler(DB.getPath(node, "thaco"), "onUpdate", update)
		end
	end
end

-- create combat_mini_thaco_matrix
function createTHACOMatrix()
	-- default value is 1e.
	local nLowAC = -10
	local nHighAC = 10
	local nTotalACs = 11

	if (DataCommonADND.coreVersion == "becmi") then
		nLowAC = -20
		nHighAC = 19
		nTotalACs = 20
	end

	local node = getDatabaseNode()
	local bisPC = (ActorManager.isPC(node))
	local bUseMatrix = (DataCommonADND.coreVersion == "1e")
	local sHitDice = DB.getValue(node, "hitDice")
	local nTHACO = DB.getValue(node, "combat.thaco.score", 20)
	local fightsAsClass = ""
	local fightsAsHdLevel = 0
	local sACLabelName = "matrix_ac_label"
	local sRollLabelName = "matrix_roll_label"
	local sHightlightColor = "a5a7aa"
	local sRedColor = "ddaf90"
	local bHighlight = true

	if (not bisPC) then
		nTHACO = DB.getValue(node, "thaco", 20)
	end

	-- 1e matrix
	local aMatrixRolls = {}

	-- assign the proper hit dice and class or monster matrix
	if bUseMatrix and not bisPC then
		fightsAsClass = DB.getValue(node, "fights_as")
		fightsAsClass = fightsAsClass:gsub("%s+", "")
		fightsAsHdLevel = DB.getValue(node, "fights_as_hd_level")

		Debug.console("111", "npcHitDice", sHitDice, "fightsAsClass", fightsAsClass, "fightsAsHdLevel", fightsAsHdLevel)

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

		Debug.console("121", "fightsAsClass", fightsAsClass)
		Debug.console("122", "fightsAsHdLevel", fightsAsHdLevel, "sHitDice", sHitDice)

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

			local bUseOsricMonsterMatrix = (OptionsManager.getOption("useOsricMonsterMatrix") == "on")
			Debug.console("213", "fightsAsHdLevel", fightsAsHdLevel, "bUseOsricMonsterMatrix", bUseOsricMonsterMatrix)

			if bUseOsricMonsterMatrix then
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
	end

	-- assign matrix values
	for i = nLowAC, nHighAC, 1 do
		local nTHAC = nTHACO - i -- to hit AC value. Current THACO for this Armor Class. so 20 - 10 for AC 10 would be 30.

		-- db values only for PCs, calculated values for NPCs
		if bUseMatrix then
			if bisPC then
				nTHAC = DB.getValue(node, "combat.matrix.thac" .. i, 20)
			else --if not bisPC and #aMatrixRolls > 0 then
				-- math.abs(i-11), this table is reverse of how we display the matrix
				-- so we start at the end instead of at the front by taking I - 11 then get the absolute value of it.
				nTHAC = aMatrixRolls[math.abs(i - 11)]

				-- get value from db, in case it's been explicitly set
				local nTHACDb = DB.getValue(node, "thac" .. i)

				-- get value from aMatrixRolls
				local nTHACM = aMatrixRolls[math.abs(i - nTotalACs)]

				if (fightsAsClass ~= "" or (fightsAsHdLevel ~= 0 and fightsAsHdLevel ~= tonumber(sHitDice))) then
					nTHAC = nTHACM
				elseif (nTHACDb ~= nil and nTHACDb ~= nTHACM) then
					nTHAC = nTHACDb
				else
					nTHAC = nTHACM
				end

				DB.setValue(node, "thac" .. i, "number", nTHAC)
			end
		end

		local sMatrixACName = "thaco_matrix_ac_" .. i -- control name for the AC label
		local sMatrixACValue = i -- AC control value
		local sMatrixNumberName = "thac" .. i -- control name for the THACO label
		local cntNum = nil

		if bUseMatrix then
			cntNum = createControl("number_thaco_matrix", sMatrixNumberName, "combat.matrix." .. sMatrixNumberName)
		else
			cntNum = createControl("number_thaco_matrix", sMatrixNumberName)
		end

		cntNum.setFrame(nil)
		cntNum.setValue(nTHAC)

		local cntAC = createControl("label_fieldtop_thaco_matrix", sMatrixACName)
		cntAC.setReadOnly(false)
		cntAC.setValue(sMatrixACValue)

		if (i == 0) then
			cntNum.setBackColor(sRedColor)
			cntAC.setBackColor(sRedColor)
		elseif bHighlight then
			cntNum.setBackColor(sHightlightColor)
			cntAC.setBackColor(sHightlightColor)
		end

		cntAC.setAnchor("left", sMatrixNumberName, "left", "absolute", 0)

		bHighlight = not bHighlight
	end
end

-- update combat_mini_thaco_matrix from db values
function update()
	Debug.console("char_matrix_thaco.lua:130", "updating combat_mini_thaco_matrix")
	local node = getDatabaseNode()
	local bisPC = (ActorManager.isPC(node))
	local bUseMatrix = (DataCommonADND.coreVersion ~= "2e")

	local nTHACO = DB.getValue(node, "combat.thaco.score", 20)

	if (not bisPC) then
		nTHACO = DB.getValue(node, "thaco", 20)
	end

	-- update to changed THACO. Set the new values in previously created controls
	for i = -10, 10, 1 do
		local nTHAC = nTHACO - i

		if bUseMatrix then
			nTHAC = DB.getValue(node, "thac" .. i, 20)
		end

		local sMatrixNumberName = "thac" .. i -- control name for the THACO label
		local cnt = self[sMatrixNumberName] -- get the control for this, stringcontrol named thac-10 .. thac10

		if cnt then
			cnt.setValue(nTHAC) -- set new to hit AC value
		end
	end
end
