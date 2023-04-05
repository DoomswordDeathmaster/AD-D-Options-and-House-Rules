local bIsUaComelinessEnabled
local bIsOaComelinessHonorEnabled

function onInit()
    --Debug.console("char_ability_details.lua", "onInit")
    OptionsManager.registerCallback(AdndOpHrManager.useUaComeliness, onUaComelinessOptionChanged)
    OptionsManager.registerCallback(AdndOpHrManager.useOaComelinessHonor, onOaComelinessHonorOptionChanged)

    bIsUaComelinessEnabled = AdndOpHrManager.isUaComelinessEnabled()
    bIsOaComelinessHonorEnabled = AdndOpHrManager.isOaComelinessHonorEnabled()
    
    setPlayerOptionControlVisibility("useUaComeliness")
    setPlayerOptionControlVisibility("useOaComelinessHonor")
end

function onClose()
    OptionsManager.unregisterCallback(AdndOpHrManager.useUaComeliness, onUaComelinessOptionChanged)
    OptionsManager.unregisterCallback(AdndOpHrManager.useOaComelinessHonor, onOaComelinessHonorOptionChanged)
end

function onUaComelinessOptionChanged()
    setPlayerOptionControlVisibility("useUaComeliness")
end

function onOaComelinessHonorOptionChanged()
    setPlayerOptionControlVisibility("useOaComelinessHonor")
end

function setPlayerOptionControlVisibility(sOption)
    bIsUaComelinessEnabled = AdndOpHrManager.isUaComelinessEnabled()
    bIsOaComelinessHonorEnabled = AdndOpHrManager.isOaComelinessHonorEnabled()

    if (sOption == "useUaComeliness" and not bIsOaComelinessHonorEnabled) then
        setUaComelinessVisibility(bIsUaComelinessEnabled)
    elseif (sOption == "useOaComelinessHonor") then
        setOaComelinessHonorVisibility(bIsOaComelinessHonorEnabled)
    end

    -- Debug.console(
    --     "char_main.lua",
    --     "bIsUaComelinessEnabled",
    --     bIsUaComelinessEnabled,
    --     "bIsOaComelinessHonorEnabled",
    --     bIsOaComelinessHonorEnabled
    -- )

    charSheetAdjustment()
end

-- function setPlayerOptionControlVisibility()
--     bIsUaComelinessEnabled = AdndOpHrManager.isUaComelinessEnabled();
-- 	bIsOaComelinessHonorEnabled = AdndOpHrManager.isOaComelinessHonorEnabled();
--     Debug.console("char_ability_details.lua", "bIsUaComelinessEnabled", bIsUaComelinessEnabled, "bIsOaComelinessHonorEnabled", bIsOaComelinessHonorEnabled)

-- 	setUaComelinessVisibility(bIsUaComelinessEnabled);
-- 	setOaComelinessHonorVisibility(bIsOaComelinessHonorEnabled);

-- 	if bIsUaComelinessEnabled then
-- 		honor_label.setAnchor("top", "charisma_label", "top", "relative", 100);
-- 	else
-- 		honor_label.setAnchor("top", "charisma_label", "top", "relative", 50);
-- 	end
-- end

function charSheetAdjustment()
    if bIsUaComelinessEnabled and not bIsOaComelinessHonorEnabled then
        comeliness_label.setAnchor("top", "charisma_label", "top", "relative", 50)
    else
        comeliness_label.setAnchor("top", "charisma_label", "top", "relative", 50)
        honor_label.setAnchor("top", "charisma_label", "top", "relative", 100)
    end
end

function setUaComelinessVisibility(bShow)
    comeliness_label.setVisible(bShow)
    comeliness_base.setVisible(bShow)
    comeliness_base_mod.setVisible(bShow)
    com_plus.setVisible(bShow)
    comeliness_mod.setVisible(bShow)
    com_plus2.setVisible(bShow)
    comeliness_temp.setVisible(bShow)
    comeliness_total.setVisible(bShow)
    comeliness_percent_label.setVisible(bShow)
    comeliness_percent_base.setVisible(bShow)
    comeliness_percent_base_mod.setVisible(bShow)
    com_per_plus.setVisible(bShow)
    comeliness_percent_mod.setVisible(bShow)
    com_per_plus2.setVisible(bShow)
    comeliness_percent_temp.setVisible(bShow)
    comeliness_percent_total.setVisible(bShow)
end

function setOaComelinessHonorVisibility(bShow)
    --Debug.console("char_ability_detals.lua", "bShow", bShow, "bIsUaComelinessEnabled", bIsUaComelinessEnabled)
    if not bShow and bIsUaComelinessEnabled then
        honor_label.setVisible(bShow)
        honor_total.setVisible(bShow)
    else
        comeliness_label.setVisible(bShow)
        comeliness_base.setVisible(bShow)
        comeliness_base_mod.setVisible(bShow)
        com_plus.setVisible(bShow)
        comeliness_mod.setVisible(bShow)
        com_plus2.setVisible(bShow)
        comeliness_temp.setVisible(bShow)
        comeliness_total.setVisible(bShow)
        comeliness_percent_label.setVisible(bShow)
        comeliness_percent_base.setVisible(bShow)
        comeliness_percent_base_mod.setVisible(bShow)
        com_per_plus.setVisible(bShow)
        comeliness_percent_mod.setVisible(bShow)
        com_per_plus2.setVisible(bShow)
        comeliness_percent_temp.setVisible(bShow)
        comeliness_percent_total.setVisible(bShow)

        honor_label.setVisible(bShow)
        honor_total.setVisible(bShow)
    end
end
