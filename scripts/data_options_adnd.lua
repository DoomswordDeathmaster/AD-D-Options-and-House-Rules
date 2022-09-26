--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onInit()
    registerOptions()
    OptionsManager.registerCallback("OPTIONAL_ENCUMBRANCE", updateForEncumbranceOption)

    createBackupDBOnStartCheck()
end

function registerOptions()
    Debug.console("ORIGINAL OPTIONS")
    -- use Menus or Sidebar
    OptionsManager.registerOption2(
        "OPTIONS_MENU",
        true,
        "option_header_client",
        "option_label_OPTION_MENU",
        "option_entry_cycler",
        {
            labels = "option_val_sidebar",
            values = "sidebar",
            baselabel = "option_val_menus",
            baseval = "menus",
            default = "menus"
        }
    )

    -- GAME
    -- use Fighter Handbook armor damagepoint rules
    if User.getRulesetName() ~= "OSRIC" then
        OptionsManager.registerOption2(
            "OPTIONAL_ARMORDP",
            false,
            "option_header_adnd_op_hr",
            "option_label_OPTIONAL_ARMORDB",
            "option_entry_cycler",
            {labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off"}
        )
    end

    -- encumbrance optional
    --if User.getRuleSetName() ~= "OSRIC" then
        OptionsManager.registerOption2(
            "OPTIONAL_ENCUMBRANCE",
            false,
            "option_header_adnd_op_hr",
            "option_label_OPTIONAL_ENCUMBRANCE",
            "option_entry_cycler",
            {labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "on"}
        )
    --end

    -- Doesn't exist in 2e ruleset, needs to be removed there
    -- OptionsManager.registerOption2("OPTIONAL_ENCUMBRANCE_COIN", false, "option_header_adnd_options", "option_label_OPTIONAL_ENCUMBRANCE_COIN", "option_entry_cycler",
    --   { labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });

    -- Changed to a threshold to account for differences between 1e and OSRIC
    --if user.getRuleSetName == "OSRIC" then

    --else
    -- let's try to move this to see if dynamic option works if we do...
    -- it does, TODO: consider moving other modified options to mod options file
    -- OptionsManager.registerOption2(
    --     "HouseRule_DeathsDoor",
    --     false,
    --     "option_header_adnd_op_hr",
    --     "option_label_ADND_DEATHSDOOR",
    --     "option_entry_cycler",
    --     {labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "on"}
    -- )
    --end

    -- size mods and init mods don't exist in 1e or OSRIC, make 2e only
    -- move to options mod file
    -- if User.getRulesetName ~= "OSRIC" then
    --     OptionsManager.registerOption2(
    --         "OPTIONAL_INIT_SIZEMODS",
    --         false,
    --         "option_header_adnd_op_hr",
    --         "option_label_OPTIONAL_INIT_SIZEMODS",
    --         "option_entry_cycler",
    --         {labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "on"}
    --     )
    -- end

    -- skip 0 hitpoint NPCs in the CT when advancing initiative.
    -- COMBAT
    OptionsManager.registerOption2(
        "CT_SKIP_DEAD_NPC",
        false,
        "option_header_combat",
        "option_label_CT_SKIP_DEAD_NPC",
        "option_entry_cycler",
        {labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off"}
    )

    -- re-register the version of this that CoreRPG does so that we can set the default ON since AD&D uses re-roll each round also --celestian
    OptionsManager.registerOption2(
        "RNDS",
        false,
        "option_header_combat",
        "option_label_RNDS",
        "option_entry_cycler",
        {labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "on"}
    )

    -- PC vs NPC initiative type
    -- doesn't exist in 1e/OSRIC and seems to be of limited usefulness in 2e
    -- deprecate option
    -- OptionsManager.registerOption2("PCVNPCINIT", false, "option_header_combat", "option_label_PCVNPCINIT", "option_entry_cycler",
    --     { labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });

    -- TOKEN OPTIONS
    -- show npc effects to PC
    OptionsManager.registerOption2(
        "TNPCE",
        false,
        "option_header_token",
        "option_label_TNPCE",
        "option_entry_cycler",
        {
            labels = "option_val_tooltip|option_val_icons|option_val_iconshover|option_val_mark|option_val_markhover",
            values = "tooltip|on|hover|mark|markhover",
            baselabel = "option_val_off",
            baseval = "off",
            default = "on"
        }
    )
    -- show npc health bars to PC
    OptionsManager.registerOption2(
        "TNPCH",
        false,
        "option_header_token",
        "option_label_TNPCH",
        "option_entry_cycler",
        {
            labels = "option_val_tooltip|option_val_bar|option_val_barhover|option_val_dot|option_val_dothover",
            values = "tooltip|bar|barhover|dot|dothover",
            baselabel = "option_val_off",
            baseval = "off",
            default = "dot"
        }
    )

    -- show pc effects to PC
    OptionsManager.registerOption2(
        "TPCE",
        false,
        "option_header_token",
        "option_label_TPCE",
        "option_entry_cycler",
        {
            labels = "option_val_tooltip|option_val_icons|option_val_iconshover|option_val_mark|option_val_markhover",
            values = "tooltip|on|hover|mark|markhover",
            baselabel = "option_val_off",
            baseval = "off",
            default = "on"
        }
    )
    -- show pc health bars to PC
    OptionsManager.registerOption2(
        "TPCH",
        false,
        "option_header_token",
        "option_label_TPCH",
        "option_entry_cycler",
        {
            labels = "option_val_tooltip|option_val_bar|option_val_barhover|option_val_dot|option_val_dothover",
            values = "tooltip|bar|barhover|dot|dothover",
            baselabel = "option_val_off",
            baseval = "off",
            default = "dot"
        }
    )
    -- show name/tooltip
    -- OptionsManager.registerOption2("TNAM", false, "option_header_token", "option_label_TNAM", "option_entry_cycler",
    --     { labels = "option_val_tooltip|option_val_title|option_val_titlehover", values = "tooltip|on|hover", baselabel = "option_val_off", baseval = "off", default = "tooltip" });

    -- set "has initiative" highlight overlay token
    OptionsManager.registerOption2(
        "TOKEN_OPTION_INIT",
        false,
        "option_header_token",
        "option_label_TOKEN_OPTION_INIT",
        "option_entry_cycler",
        {
            labels = "option_val_has_init_token2|option_val_has_init_token3|option_val_has_init_token4|option_val_has_init_token5|option_val_has_init_token6",
            values = "2|3|4|5|6",
            baselabel = "option_val_has_init_token1",
            baseval = "1",
            default = "1"
        }
    )

    --- HOUSE RULES
    -- TODO: consider changing HD/HP values or removing this
    OptionsManager.registerOption2(
        "HRNH",
        false,
        "option_header_adnd_op_hr",
        "option_label_HRNH",
        "option_entry_cycler",
        {
            labels = "option_val_max|option_val_random|option_val_80plus",
            values = "max|random|80plus",
            baselabel = "option_val_off",
            baseval = "off",
            default = "random"
        }
    )

    -- auto init each round, on round start?
    OptionsManager.registerOption2(
        "HouseRule_InitEachRound",
        false,
        "option_header_adnd_op_hr",
        "option_label_HOUSE_RULE_AUTO_INIT_EACH_ROUND",
        "option_entry_cycler",
        {labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off"}
    )

    -- crtical types
    OptionsManager.registerOption2(
        "HouseRule_CRIT_TYPE",
        false,
        "option_header_adnd_op_hr",
        "option_label_HR_CRIT",
        "option_entry_cycler",
        {
            labels = "option_val_hr_crit_maxdmg|option_val_hr_crit_timestwo|option_val_hr_crit_doubledice",
            values = "max|timestwo|doubledice",
            baselabel = "option_val_hr_crit_none",
            baseval = "none",
            default = "none"
        }
    )

    -- this is not a option in AD&D 2e?
    -- OptionsManager.registerOption2("HouseRule_ASCENDING_AC", false, "option_header_houserule", "option_label_HR_ASENDING_AC", "option_entry_cycler",
    -- { labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });

    OptionsManager.registerOption2(
        "OPTIONS_DBBACKUP",
        false,
        "option_header_system",
        "option_label_OPTION_DBBACKUP",
        "option_entry_cycler",
        {labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off"}
    )

    -- OptionsManager.registerOption2("OPTIONS_EFFECT_AURA", false, "option_header_system", "option_label_OPTION_EFFECT_AURA", "option_entry_cycler",
    --   { labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "on" });
end

wMenuWindow = nil

function registerWindowMenu(wWindow)
    if not wMenuWindow then
        wMenuWindow = wWindow
        updateMenuStyle()
    end
end

wSidebarWindow = nil

function registerWindowSidebar(wWindow)
    if not wSidebarWindow then
        wSidebarWindow = wWindow
        updateMenuStyle()
    end
end

local nUpdateVersion = 35

function updateMenuStyle()
    if wMenuWindow and wSidebarWindow then
        Debug.console(
            "data_options_adnd.lua",
            "updateMenuStyle",
            "OPTIONS_MENU",
            OptionsManager.getOption("OPTIONS_MENU")
        )
        local bMenuStyle =
            (OptionsManager.getOption("OPTIONS_MENU") == "menus" or OptionsManager.getOption("OPTIONS_MENU") == "")

        if bMenuStyle then
            enableMenuStyleButtons()
        else
            enableMenuStyleSidebar()
        end
    end
end

function enableMenuStyleButtons()
    --  Debug.console("data_options_adnd.lua","enableMenuStyleButtons");
    wSidebarWindow.setEnabled(false)
    wSidebarWindow.close()
end

function enableMenuStyleSidebar()
    --  Debug.console("data_options_adnd.lua","enableMenuStyleSidebar");
    wMenuWindow.setEnabled(false)
    -- and this is required because of the call back mess
    wMenuWindow.close()
end

function createBackupDBOnStartCheck()
    if Session.IsHost and OptionsManager.getOption("OPTIONS_DBBACKUP") == "on" then
        print("Creating database backup. Saved to a unique file name. (db.script.#.xml)")
        DB.backup()
    end
end

--recheck encumbrance settings with value changed.
function updateForEncumbranceOption()
    for _, nodeChar in pairs(DB.getChildren("charsheet")) do
        CharManager.calcWeightCarried(nodeChar)
    end
end
