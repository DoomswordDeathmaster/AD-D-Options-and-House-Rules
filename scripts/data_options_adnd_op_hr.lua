function onInit()
	--Debug.console("getRulesetName: ", User.getRulesetName())
	-- doesn't work correctly
	--OptionsManager.registerCallback("add1eProperties", dynamicOsricOption);
	sRulesetName = User.getRulesetName()
	registerOptions()
	--registerDynamicOptions()
	--dynamicOsricOptions()
	--dynamic2eOptions()
end

function registerOptions()
	---- INIT OPTIONS
	-- Allow Initiative Delay
	-- if User.getRulesetName() ~= "OSRIC" then
	-- 	OptionsManager.registerOption2(
	-- 		"initiativeDelay",
	-- 		false,
	-- 		"option_header_adnd_op_hr",
	-- 		"option_label_adnd_op_hr_initiative_delay",
	-- 		"option_entry_cycler",
	-- 		{labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off"}
	-- 	)
	-- else
		OptionsManager.registerOption2(
			"initiativeDelay",
			false,
			"option_header_adnd_op_hr",
			"option_label_adnd_op_hr_initiative_delay",
			"option_entry_cycler",
			{labels = "option_val_off", values = "off", baselabel = "option_val_on", baseval = "on", default = "on"}
		)
	--end

	-- 2E: Allow Tied Group Initiative
	if User.getRulesetName() ~= "OSRIC" then
		OptionsManager.registerOption2(
			"initiativeTiesAllow",
			false,
			"option_header_adnd_op_hr",
			"option_label_adnd_op_hr_initiative_ties_allow",
			"option_entry_cycler",
			{labels = "option_val_off", values = "off", baselabel = "option_val_on", baseval = "on", default = "on"}
		)
	end

	-- 2E: Allow Initiative Modifiers
	if User.getRulesetName() ~= "OSRIC" then
		OptionsManager.registerOption2(
			"initiativeModifiersAllow",
			false,
			"option_header_adnd_op_hr",
			"option_label_adnd_op_hr_initiative_modifiers_allow",
			"option_entry_cycler",
			{labels = "option_val_off", values = "off", baselabel = "option_val_on", baseval = "on", default = "on"}
		)
	end

	-- Initiative Size Modifiers
	if User.getRulesetName() ~= "OSRIC" then
		OptionsManager.registerOption2(
			"OPTIONAL_INIT_SIZEMODS",
			false,
			"option_header_adnd_op_hr",
			"option_label_OPTIONAL_INIT_SIZEMODS",
			"option_entry_cycler",
			{labels = "option_val_off", values = "off", baselabel = "option_val_on", baseval = "on", default = "on"}
		)
	end

	-- Initiative Die
	if User.getRulesetName() ~= "OSRIC" then
	-- 	OptionsManager.registerOption2(
	-- 		"initiativeDie",
	-- 		false,
	-- 		"option_header_adnd_op_hr",
	-- 		"option_label_adnd_op_hr_initiative_die",
	-- 		"option_entry_cycler",
	-- 		{labels = "option_val_d10", values = "d10", baselabel = "option_val_d6", baseval = "d6", default = "d6"}
	-- 	)
	-- else
		OptionsManager.registerOption2(
			"initiativeDie",
			false,
			"option_header_adnd_op_hr",
			"option_label_adnd_op_hr_initiative_die",
			"option_entry_cycler",
			{labels = "option_val_d6", values = "d6", baselabel = "option_val_d10", baseval = "d10", default = "d10"}
		)
	end

	-- Initiative Grouping
	if User.getRulesetName() ~= "OSRIC" then
		OptionsManager.registerOption2(
			"initiativeGrouping",
			false,
			"option_header_adnd_op_hr",
			"option_label_adnd_op_hr_initiative_grouping",
			"option_entry_cycler",
			{
				labels = "option_val_pc|option_val_npc|option_val_neither",
				values = "pc|npc|neither",
				baselabel = "option_val_both",
				baseval = "both",
				default = "both"
			}
		)
	else
		--Debug.console("OSRIC Option")
		OptionsManager.registerOption2(
			"initiativeGrouping",
			false,
			"option_header_adnd_op_hr",
			"option_label_adnd_op_hr_initiative_grouping_osric",
			"option_entry_cycler",
			{
				labels = "option_val_pc|option_val_npc|option_val_neither",
				values = "pc|npc|neither",
				baselabel = "option_val_both",
				baseval = "both",
				default = "both"
			}
		)
	end

	-- Initiative Ordering
	if User.getRulesetName() ~= "OSRIC" then
		OptionsManager.registerOption2(
			"initiativeOrdering",
			false,
			"option_header_adnd_op_hr",
			"option_label_adnd_op_hr_initiative_ordering",
			"option_entry_cycler",
			{
				labels = "option_val_descending",
				values = "descending",
				baselabel = "option_val_ascending",
				baseval = "ascending",
				default = "ascending"
			}
		)
	end

	-- Round Start Reset Init
	OptionsManager.registerOption2(
		"roundStartResetInit",
		false,
		"option_header_adnd_op_hr",
		"option_label_adnd_op_hr_round_start_reset_init",
		"option_entry_cycler",
		{labels = "option_val_off", values = "off", baselabel = "option_val_on", baseval = "on", default = "on"}
	)

	-- 2E: Initiative Grouping Swap
	if User.getRulesetName() == "2E" then
		OptionsManager.registerOption2(
			"initiativeGroupingSwap",
			false,
			"option_header_adnd_op_hr",
			"option_label_adnd_op_hr_initiative_grouping_swap",
			"option_entry_cycler",
			{labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off"}
		)
	end

	---- PC Death Options
	-- PC Death: Death's Door Threshold
	if User.getRulesetName() == "OSRIC" then
		-- death's door threshold
		OptionsManager.registerOption2(
			"HouseRule_DeathsDoor_Threshold",
			false,
			"option_header_adnd_op_hr",
			"option_label_ADND_DEATHSDOOR_Threshold",
			"option_entry_cycler",
			{
				labels = "option_val_zero|option_val_minus_three",
				values = "exactlyZero|zeroToMinusThree",
				baselabel = "option_val_zero_or_less",
				baseval = "zeroOrLess",
				default = "zeroOrLess"
			}
		)
	elseif User.getRulesetName() == "2E" then
		-- death's door threshold
		OptionsManager.registerOption2(
			"HouseRule_DeathsDoor_Threshold",
			false,
			"option_header_adnd_op_hr",
			"option_label_ADND_DEATHSDOOR_Threshold",
			"option_entry_cycler",
			{
				labels = "option_val_zero|option_val_minus_three",
				values = "exactlyZero|zeroToMinusThree",
				baselabel = "option_val_zero_or_less",
				baseval = "zeroOrLess",
				default = "zeroOrLess"
			}
		)
	end
	-- PC Death: Dead At HP
	OptionsManager.registerOption2(
		"pcDeadAtValue",
		false,
		"option_header_adnd_op_hr",
		"option_label_adnd_op_hr_pc_dead_at_value",
		"option_entry_cycler",
		{
			labels = "option_val_minus_con",
			values = "minusCon",
			baselabel = "option_val_minus_ten",
			baseval = "minusTen",
			default = "minusTen"
		}
	)

	---- PC OPTIONS
	-- PC: Allow Ability Checks
	if User.getRulesetName() == "OSRIC" then
		OptionsManager.registerOption2(
			"abilityCheckAllow",
			false,
			"option_header_adnd_op_hr",
			"option_label_adnd_op_hr_ability_check_allow",
			"option_entry_cycler",
			{labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off"}
		)
	elseif User.getRulesetName() == "2E" then
		OptionsManager.registerOption2(
			"abilityCheckAllow",
			false,
			"option_header_adnd_op_hr",
			"option_label_adnd_op_hr_ability_check_allow",
			"option_entry_cycler",
			{labels = "option_val_off", values = "off", baselabel = "option_val_on", baseval = "on", default = "on"}
		)
	end

	-- PC: Allow Kits
	if User.getRulesetName() ~= "OSRIC" then
		OptionsManager.registerOption2(
			"use2eKits",
			false,
			"option_header_adnd_op_hr",
			"option_label_adnd_op_hr_use_2e_kits",
			"option_entry_cycler",
			{labels = "option_val_off", values = "off", baselabel = "option_val_on", baseval = "on", default = "on"}
		)
	end

	---- SURPRISE OPTIONS
	-- Surprise Die
	-- if User.getRulesetName() == "OSRIC" then
	-- 	OptionsManager.registerOption2(
	-- 		"surpriseDie",
	-- 		false,
	-- 		"option_header_adnd_op_hr",
	-- 		"option_label_adnd_op_hr_surprise_die",
	-- 		"option_entry_cycler",
	-- 		{
	-- 			labels = "option_val_d10|option_val_d12",
	-- 			values = "d10|d12",
	-- 			baselabel = "option_val_d6",
	-- 			baseval = "d6",
	-- 			default = "d6"
	-- 		}
	-- 	)
	-- else
	if User.getRulesetName() == "2E" then
		OptionsManager.registerOption2(
			"surpriseDie",
			false,
			"option_header_adnd_op_hr",
			"option_label_adnd_op_hr_surprise_die",
			"option_entry_cycler",
			{
				labels = "option_val_d6|option_val_d12",
				values = "d6|d12",
				baselabel = "option_val_d10",
				baseval = "d10",
				default = "d10"
			}
		)
	end

	---- SYSTEM OPTIONS
	-- OSRIC: Osric monster attack matrices vs. 1e
	-- TODO: osric monster save matrices vs 1e
	-- if User.getRulesetName() == "OSRIC" then
	-- 	-- monster attack matrices, 1e or osric
	-- 	OptionsManager.registerOption2(
	-- 		"monsterAttackMatrices",
	-- 		false,
	-- 		"option_header_adnd_op_hr",
	-- 		"option_label_adnd_op_hr_osric_monster_matrices",
	-- 		"option_entry_cycler",
	-- 		{labels = "option_val_osric", values = "on", baselabel = "option_val_1e", baseval = "off", default = "off"}
	-- 	)
	-- end

	--  2E: Set osric/1e data
	if User.getRulesetName() ~= "OSRIC" then
		-- for those people not using osric ruleset - 1e matrices, saves and ability properties
		OptionsManager.registerOption2(
			"add1eProperties",
			false,
			"option_header_adnd_op_hr",
			"option_label_adnd_op_hr_add1e_properties",
			"option_entry_cycler",
			{labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off"}
		)
	end

	-- monster attack matrices, 1e or osric
	if sRulesetName == "OSRIC" then
		OptionsManager.registerOption2(
			"monsterAttackMatrices",
			false,
			"option_header_adnd_op_hr",
			"option_label_adnd_op_hr_osric_monster_matrices_osric",
			"option_entry_cycler",
			{labels = "option_val_1e", values = "off", baselabel = "option_val_osric", baseval = "on", default = "on"}
		)
	elseif sRulesetName == "2E" then
		OptionsManager.registerOption2(
			"monsterAttackMatrices",
			false,
			"option_header_adnd_op_hr",
			"option_label_adnd_op_hr_osric_monster_matrices",
			"option_entry_cycler",
			{labels = "option_val_osric", values = "on", baselabel = "option_val_1e", baseval = "off", default = "off"}
		)
	end

	-- Death's door
	if User.getRulesetName() == "OSRIC" then
		OptionsManager.registerOption2(
			"HouseRule_DeathsDoor",
			false,
			"option_header_adnd_op_hr",
			"option_label_ADND_DEATHSDOOR",
			"option_entry_cycler",
			{labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "on"}
		)
	elseif User.getRulesetName() == "2E" then
		OptionsManager.registerOption2(
			"HouseRule_DeathsDoor",
			false,
			"option_header_adnd_op_hr",
			"option_label_ADND_DEATHSDOOR",
			"option_entry_cycler",
			{labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off"}
		)
	end

	
end

-- -- Dynamic Options
-- function registerDynamicOptions()
-- 	-- add1e properties
-- 	local bOptAdd1eProperties = OptionsManager.isOption("add1eProperties", "on")
-- 	Debug.console("dynamicOsricOption", bOptAdd1eProperties)
-- 	--local sRuleSetName = User.getRuleSetName
-- 	Debug.console("RULESET", sRulesetName)
-- 	if bOptAdd1eProperties or (sRulesetName == "OSRIC") then
-- 		-- monster attack matrices, 1e or osric
-- 		if sRulesetName == "OSRIC" then
-- 			OptionsManager.registerOption2(
-- 				"monsterAttackMatrices",
-- 				false,
-- 				"option_header_adnd_op_hr",
-- 				"option_label_adnd_op_hr_osric_monster_matrices_osric",
-- 				"option_entry_cycler",
-- 				{labels = "option_val_1e", values = "off", baselabel = "option_val_osric", baseval = "on", default = "on"}
-- 			)
-- 		elseif sRulesetName == "2E" then
-- 			OptionsManager.registerOption2(
-- 				"monsterAttackMatrices",
-- 				false,
-- 				"option_header_adnd_op_hr",
-- 				"option_label_adnd_op_hr_osric_monster_matrices",
-- 				"option_entry_cycler",
-- 				{labels = "option_val_osric", values = "on", baselabel = "option_val_1e", baseval = "off", default = "off"}
-- 			)
-- 		end
-- 	end
-- 	-- death's door
-- 	-- local bOptDeathsDoor = OptionsManager.isOption("HouseRule_DeathsDoor", "on")
-- 	-- Debug.console("DeathsDoor", bOptDeathsDoor)
-- 	-- --2E: if death's door turned on
-- 	-- if bOptDeathsDoor then
-- 	-- 	-- same for each ruleset right now but bolierplate it to maybe revisit
-- 	-- 	if User.getRulesetName() == "OSRIC" then
-- 	-- 		-- death's door threshold
-- 	-- 		OptionsManager.registerOption2(
-- 	-- 			"HouseRule_DeathsDoor_Threshold",
-- 	-- 			false,
-- 	-- 			"option_header_adnd_op_hr",
-- 	-- 			"option_label_ADND_DEATHSDOOR_Threshold",
-- 	-- 			"option_entry_cycler",
-- 	-- 			{
-- 	-- 				labels = "option_val_zero|option_val_minus_three",
-- 	-- 				values = "exactlyZero|zeroToMinusThree",
-- 	-- 				baselabel = "option_val_zero_or_less",
-- 	-- 				baseval = "zeroOrLess",
-- 	-- 				default = "zeroOrLess"
-- 	-- 			}
-- 	-- 		)
-- 	-- 	elseif User.getRulesetName() == "2E" then
-- 	-- 		-- death's door threshold
-- 	-- 		OptionsManager.registerOption2(
-- 	-- 			"HouseRule_DeathsDoor_Threshold",
-- 	-- 			false,
-- 	-- 			"option_header_adnd_op_hr",
-- 	-- 			"option_label_ADND_DEATHSDOOR_Threshold",
-- 	-- 			"option_entry_cycler",
-- 	-- 			{
-- 	-- 				labels = "option_val_zero|option_val_minus_three",
-- 	-- 				values = "exactlyZero|zeroToMinusThree",
-- 	-- 				baselabel = "option_val_zero_or_less",
-- 	-- 				baseval = "zeroOrLess",
-- 	-- 				default = "zeroOrLess"
-- 	-- 			}
-- 	-- 		)
-- 	-- 	end
-- 	-- 	-- Dead at, -10 or -con
-- 	-- 	OptionsManager.registerOption2(
-- 	-- 		"pcDeadAtValue",
-- 	-- 		false,
-- 	-- 		"option_header_adnd_op_hr",
-- 	-- 		"option_label_adnd_op_hr_pc_dead_at_value",
-- 	-- 		"option_entry_cycler",
-- 	-- 		{
-- 	-- 			labels = "option_val_minus_con",
-- 	-- 			values = "minusCon",
-- 	-- 			baselabel = "option_val_minus_ten",
-- 	-- 			baseval = "minusTen",
-- 	-- 			default = "minusTen"
-- 	-- 		}
-- 	-- 	)
-- 	-- end
-- 	---- init size mods only for 2e and if modifiers are turned on
-- 	--local bOptInitModifiersAllow = OptionsManager.isOption("initiativeModifiersAllow", "on")
-- 	--Debug.console("InitModifiersAllow", bOptInitModifiersAllow)
-- 	--if bOptInitModifiersAllow then
-- 		-- if User.getRulesetName() ~= "OSRIC" then
-- 		-- 	OptionsManager.registerOption2(
-- 		-- 		"OPTIONAL_INIT_SIZEMODS",
-- 		-- 		false,
-- 		-- 		"option_header_adnd_op_hr",
-- 		-- 		"option_label_OPTIONAL_INIT_SIZEMODS",
-- 		-- 		"option_entry_cycler",
-- 		-- 		{labels = "option_val_off", values = "off", baselabel = "option_val_on", baseval = "on", default = "on"}
-- 		-- 	)
-- 		-- end
-- 	--end
-- end

-- 2E: If the add 1e option is set
-- function dynamicOsricOptions()
-- 	local bOptAdd1eProperties = OptionsManager.isOption("add1eProperties", "on")
-- 	Debug.console("dynamicOsricOption", bOptAdd1eProperties)
-- 	if bOptAdd1eProperties then
-- 		-- monster attack matrices, 1e or osric
-- 		OptionsManager.registerOption2(
-- 			"monsterAttackMatrices",
-- 			false,
-- 			"option_header_adnd_op_hr",
-- 			"option_label_adnd_op_hr_osric_monster_matrices",
-- 			"option_entry_cycler",
-- 			{labels = "option_val_osric", values = "on", baselabel = "option_val_1e", baseval = "off", default = "off"}
-- 		)
-- 	end
-- end

-- function dynamic2eOptions()
-- 	local bOptDeathsDoor = OptionsManager.isOption("HouseRule_DeathsDoor", "on")
-- 	Debug.console("DeathsDoor", bOptDeathsDoor)
-- 	--2E: if death's door turned on
-- 	if bOptDeathsDoor then
-- 		-- death's door threshold
-- 		OptionsManager.registerOption2(
-- 			"HouseRule_DeathsDoor_Threshold",
-- 			false,
-- 			"option_header_adnd_op_hr",
-- 			"option_label_ADND_DEATHSDOOR_Threshold",
-- 			"option_entry_cycler",
-- 			{
-- 				labels = "option_val_zero|option_val_minus_three",
-- 				values = "exactlyZero|zeroToMinusThree",
-- 				baselabel = "option_val_zero_or_less",
-- 				baseval = "zeroOrLess",
-- 				default = "zeroOrLess"
-- 			}
-- 		)
-- 		-- Dead at, -10 or -con
-- 		OptionsManager.registerOption2(
-- 			"pcDeadAtValue",
-- 			false,
-- 			"option_header_adnd_op_hr",
-- 			"option_label_adnd_op_hr_pc_dead_at_value",
-- 			"option_entry_cycler",
-- 			{
-- 				labels = "option_val_minus_con",
-- 				values = "minusCon",
-- 				baselabel = "option_val_minus_ten",
-- 				baseval = "minusTen",
-- 				default = "minusTen"
-- 			}
-- 		)
-- 	end
-- 	-- init size mods only for 2e and if modifiers are turned on
-- 	local bOptInitModifiersAllow = OptionsManager.isOption("initiativeModifiersAllow", "on")
-- 	Debug.console("InitModifiersAllow", bOptInitModifiersAllow)
-- 	if bOptInitModifiersAllow then
-- 		if User.getRulesetName ~= "OSRIC" then
-- 			OptionsManager.registerOption2(
-- 				"OPTIONAL_INIT_SIZEMODS",
-- 				false,
-- 				"option_header_adnd_op_hr",
-- 				"option_label_OPTIONAL_INIT_SIZEMODS",
-- 				"option_entry_cycler",
-- 				{labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "on"}
-- 			)
-- 		end
-- 	end
-- end
