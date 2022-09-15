function onInit()
	Debug.console("getRuleSetName: ", User.getRulesetName())
	-- doesn't work correctly
	--OptionsManager.registerCallback("add1eProperties", dynamicOsricOption);
	registerOptions()
	dynamicOsricOptions()
end

function registerOptions()
	---- INIT OPTIONS
	-- Allow Initiative Delay
	OptionsManager.registerOption2(
		"initiativeDelay",
		false,
		"option_header_adnd_op_hr",
		"option_label_adnd_op_hr_initiative_delay",
		"option_entry_cycler",
		{labels = "option_val_off", values = "off", baselabel = "option_val_on", baseval = "on", default = "on"}
	)

	-- 2E: Allow Tied Group Initiative
	if User.getRulesetName() ~= "OSRIC" then
		OptionsManager.registerOption2(
			"initiativeTiesAllow",
			false,
			"option_header_adnd_op_hr",
			"option_label_adnd_op_hr_initiative_ties_allow",
			"option_entry_cycler",
			{labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off"}
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

	-- Initiative Die
	OptionsManager.registerOption2(
		"initiativeDie",
		false,
		"option_header_adnd_op_hr",
		"option_label_adnd_op_hr_initiative_die",
		"option_entry_cycler",
		{labels = "option_val_d6", values = "d6", baselabel = "option_val_d10", baseval = "d10", default = "d10"}
	)

	-- Initiative Grouping
	OptionsManager.registerOption2(
		"initiativeGrouping",
		false,
		"option_header_adnd_op_hr",
		"option_label_adnd_op_hr_initiative_grouping",
		"option_entry_cycler",
		{
			labels = "option_val_pc|option_val_both|option_val_neither",
			values = "pc|both|neither",
			baselabel = "option_val_npc",
			baseval = "npc",
			default = "npc"
		}
	)

	-- Initiative Ordering
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

	-- Round Start Reset Init
	OptionsManager.registerOption2(
		"roundStartResetInit",
		false,
		"option_header_adnd_op_hr",
		"option_label_adnd_op_hr_round_start_reset_init",
		"option_entry_cycler",
		{labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off"}
	)

	-- 2E: Initiative Grouping Swap
	if User.getRulesetName() == "OSRIC" then
		OptionsManager.registerOption2(
			"initiativeGroupingSwap",
			false,
			"option_header_adnd_op_hr",
			"option_label_adnd_op_hr_initiative_grouping_swap",
			"option_entry_cycler",
			{labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off"}
		)
	end

	---- PC OPTIONS
	-- Allow Ability Checks
	OptionsManager.registerOption2(
		"abilityCheckAllow",
		false,
		"option_header_adnd_op_hr",
		"option_label_adnd_op_hr_ability_check_allow",
		"option_entry_cycler",
		{labels = "option_val_off", values = "off", baselabel = "option_val_on", baseval = "on", default = "on"}
	)

	-- 2E: Use Kits
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
	
	-- Deat at, -10 or -con
	OptionsManager.registerOption2(
		"pcDeadAtValue",
		false,
		"option_header_adnd_op_hr",
		"option_label_adnd_op_hr_pc_dead_at_value",
		"option_entry_cycler",
		{labels = "option_val_minus_con", values = "minusCon", baselabel = "option_val_minus_ten", baseval = "minusTen", default = "minusTen"}
	)
	
	---- SURPRISE OPTIONS
	-- Surprise Die
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
	
	---- SYSTEM OPTIONS
	-- OSRIC: Osric monster attack matrices vs. 1e
	-- TODO: osric monster save matrices vs 1e
	if User.getRulesetName() == "OSRIC" then
		-- monster attack matrices, 1e or osric
		OptionsManager.registerOption2(
			"mosterAttackMatrices",
			false,
			"option_header_adnd_op_hr",
			"option_label_adnd_op_hr_osric_monster_matrices",
			"option_entry_cycler",
			{labels = "option_val_osric", values = "on", baselabel = "option_val_1e", baseval = "off", default = "off"}
		)
	end

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
end

-- doesn't work correctly
-- 2E: If the add 1e option is set
function dynamicOsricOptions()
	local bOptAdd1eProperties = OptionsManager.isOption("add1eProperties", "on");
	Debug.console("dynamicOsricOption", bOptAdd1eProperties)
	if bOptAdd1eProperties then
		-- monster attack matrices, 1e or osric
		OptionsManager.registerOption2(
			"mosterAttackMatrices",
			false,
			"option_header_adnd_op_hr",
			"option_label_adnd_op_hr_osric_monster_matrices",
			"option_entry_cycler",
			{labels = "option_val_osric", values = "on", baselabel = "option_val_1e", baseval = "off", default = "off"}
		)
	end
end