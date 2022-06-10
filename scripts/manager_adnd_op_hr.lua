function onInit()
	registerOptions();
end

function registerOptions()
	-- Allow Ability Checks
	OptionsManager.registerOption2("abilityCheckAllow", false, "option_header_adnd_op_hr", "option_label_adnd_op_hr_ability_check_allow", "option_entry_cycler", 
		{ labels = "option_val_off", values = "off", baselabel = "option_val_on", baseval = "on", default = "on" });
	-- Allow Initiative Delay
	OptionsManager.registerOption2("initiativeDelayAllow", false, "option_header_adnd_op_hr", "option_label_adnd_op_hr_initiative_delay_allow", "option_entry_cycler", 
		{ labels = "option_val_off", values = "off", baselabel = "option_val_on", baseval = "on", default = "on" });
	-- Allow Initiative Modifiers
	OptionsManager.registerOption2("initiativeModifiersAllow", false, "option_header_adnd_op_hr", "option_label_adnd_op_hr_initiative_modifiers_allow", "option_entry_cycler", 
		{ labels = "option_val_off", values = "off", baselabel = "option_val_on", baseval = "on", default = "on" });
	-- Allow Tied Group Initiative
	OptionsManager.registerOption2("initiativeTiesAllow", false, "option_header_adnd_op_hr", "option_label_adnd_op_hr_initiative_ties_allow", "option_entry_cycler", 
		{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });
	-- Initiative Die
	OptionsManager.registerOption2("initiativeDie", false, "option_header_adnd_op_hr", "option_label_adnd_op_hr_initiative_die", "option_entry_cycler", 
		{ labels = "option_val_d6", values = "d6", baselabel = "option_val_d10", baseval = "d10", default = "d10" });
	-- Initiative Grouping
	OptionsManager.registerOption2("initiativeGrouping", false, "option_header_adnd_op_hr", "option_label_adnd_op_hr_initiative_grouping", "option_entry_cycler", 
		{ labels = "option_val_pc|option_val_both|option_val_neither", values = "pc|both|neither", baselabel = "option_val_npc", baseval = "npc", default = "npc" });
	-- Initiative Grouping Swap
	OptionsManager.registerOption2("initiativeGroupingSwap", false, "option_header_adnd_op_hr", "option_label_adnd_op_hr_initiative_grouping_swap", "option_entry_cycler", 
		{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });
	-- Initiative Ordering
	OptionsManager.registerOption2("initiativeOrdering", false, "option_header_adnd_op_hr", "option_label_adnd_op_hr_initiative_ordering", "option_entry_cycler", 
		{ labels = "option_val_descending", values = "descending", baselabel = "option_val_ascending", baseval = "ascending", default = "ascending" });
	-- Surprise Die
	OptionsManager.registerOption2("surpriseDie", false, "option_header_adnd_op_hr", "option_label_adnd_op_hr_surprise_die", "option_entry_cycler", 
		{ labels = "option_val_d6|option_val_d12", values = "d6|d12", baselabel = "option_val_d10", baseval = "d10", default = "d10" })
	-- Use 2e Kits
	OptionsManager.registerOption2("use2eKits", false, "option_header_adnd_op_hr", "option_label_adnd_op_hr_use_2e_kits", "option_entry_cycler", 
		{ labels = "option_val_off", values = "off", baselabel = "option_val_on", baseval = "on", default = "on" });
	-- Round Start Reset Init
	OptionsManager.registerOption2("roundStartResetInit", false, "option_header_adnd_op_hr", "option_label_adnd_op_hr_round_start_reset_init", "option_entry_cycler", 
		{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });
end