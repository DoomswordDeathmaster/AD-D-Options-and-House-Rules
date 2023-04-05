local bIsUaComelinessEnabled
local bIsOaComelinessHonorEnabled

function onInit()
	-- TODO: test super.oninit here
	if super and super.onInit then
		--Debug.console("super and oninit found")
		super.onInit()
	end

	-- local nodeChar = getDatabaseNode()
	-- DB.addHandler("options.HouseRule_ASCENDING_AC", "onUpdate", updateAscendingValues)

	-- DB.addHandler(DB.getPath(nodeChar, "abilities.*.percentbase"), "onUpdate", updateAbilityScores)
	-- DB.addHandler(DB.getPath(nodeChar, "abilities.*.percentbasemod"), "onUpdate", updateAbilityScores)
	-- DB.addHandler(DB.getPath(nodeChar, "abilities.*.percentadjustment"), "onUpdate", updateAbilityScores)
	-- DB.addHandler(DB.getPath(nodeChar, "abilities.*.percenttempmod"), "onUpdate", updateAbilityScores)

	-- DB.addHandler(DB.getPath(nodeChar, "abilities.*.base"), "onUpdate", updateAbilityScores)
	-- DB.addHandler(DB.getPath(nodeChar, "abilities.*.basemod"), "onUpdate", updateAbilityScores)
	-- DB.addHandler(DB.getPath(nodeChar, "abilities.*.adjustment"), "onUpdate", updateAbilityScores)
	-- DB.addHandler(DB.getPath(nodeChar, "abilities.*.tempmod"), "onUpdate", updateAbilityScores)

	-- DB.addHandler(DB.getPath(nodeChar, "hp.base"), "onUpdate", updateHealthScore)
	-- DB.addHandler(DB.getPath(nodeChar, "hp.basemod"), "onUpdate", updateHealthScore)
	-- --this is managed, not adjusted by players
	-- --DB.addHandler(DB.getPath(nodeChar, "hp.hpconmod"),  "onUpdate", updateHealthScore);

	-- DB.addHandler(DB.getPath(nodeChar, "hp.adjustment"), "onUpdate", updateHealthScore)
	-- DB.addHandler(DB.getPath(nodeChar, "hp.tempmod"), "onUpdate", updateHealthScore)

	-- -- DB.addHandler(DB.getPath(nodeChar, "inventorylist"),  "onChildDeleted", updateEncumbranceForDelete);

	-- DB.addHandler(DB.getPath(nodeChar, "surprise.base"), "onUpdate", updateSurpriseScores)
	-- DB.addHandler(DB.getPath(nodeChar, "surprise.tempmod"), "onUpdate", updateSurpriseScores)
	-- DB.addHandler(DB.getPath(nodeChar, "surprise.mod"), "onUpdate", updateSurpriseScores)

	-- DB.addHandler(DB.getPath(nodeChar, "initiative.tempmod"), "onUpdate", updateInitiativeScores)
	-- DB.addHandler(DB.getPath(nodeChar, "initiative.misc"), "onUpdate", updateInitiativeScores)

	-- DB.addHandler(DB.getPath(nodeChar, "abilities.strength.score"), "onUpdate", onEncumbranceChanged)

	-- --// TODO is this necessary?
	-- --DB.addHandler("combattracker.list", "onChildDeleted", updatesBulk);

	local node = getDatabaseNode()

	DB.addHandler(DB.getPath(node, "abilities.comeliness.percentbase"), "onUpdate", updateUaComeliness)
	DB.addHandler(DB.getPath(node, "abilities.comeliness.percentbasemod"), "onUpdate", updateUaComeliness)
	DB.addHandler(DB.getPath(node, "abilities.comeliness.percentadjustment"), "onUpdate", updateUaComeliness)
	DB.addHandler(DB.getPath(node, "abilities.comeliness.percenttempmod"), "onUpdate", updateUaComeliness)
	DB.addHandler(DB.getPath(node, "abilities.comeliness.base"), "onUpdate", updateUaComeliness)
	DB.addHandler(DB.getPath(node, "abilities.comeliness.basemod"), "onUpdate", updateUaComeliness)
	DB.addHandler(DB.getPath(node, "abilities.comeliness.adjustment"), "onUpdate", updateUaComeliness)
	DB.addHandler(DB.getPath(node, "abilities.comeliness.tempmod"), "onUpdate", updateUaComeliness)
	DB.addHandler(DB.getPath(node, "abilities.honor.score"), "onUpdate", updateOaComelinessHonor)

	OptionsManager.registerCallback(AdndOpHrManager.useUaComeliness, onUaComelinessOptionChanged)
	OptionsManager.registerCallback(AdndOpHrManager.useOaComelinessHonor, onOaComelinessHonorOptionChanged)

	--updateAbilityScores(nodeChar)
	updateAscendingValues()

	updateSurpriseScores()
	updateInitiativeScores()

	updateUaComeliness(node)
	updateOaComelinessHonor(node)

	bIsUaComelinessEnabled = AdndOpHrManager.isUaComelinessEnabled()
	bIsOaComelinessHonorEnabled = AdndOpHrManager.isOaComelinessHonorEnabled()

	setPlayerOptionControlVisibility("useUaComeliness")
	setPlayerOptionControlVisibility("useOaComelinessHonor")
end

function onClose()
	local nodeChar = getDatabaseNode()
	DB.removeHandler(DB.getPath(nodeChar, "abilities.honor.score"), "onUpdate", updateOaComelinessHonor)
	DB.removeHandler(DB.getPath(nodeChar, "abilities.comeliness.percentbase"), "onUpdate", updateUaComeliness)
	DB.removeHandler(DB.getPath(nodeChar, "abilities.comeliness.percentbasemod"), "onUpdate", updateUaComeliness)
	DB.removeHandler(DB.getPath(nodeChar, "abilities.comeliness.percentadjustment"), "onUpdate", updateUaComeliness)
	DB.removeHandler(DB.getPath(nodeChar, "abilities.comeliness.percenttempmod"), "onUpdate", updateUaComeliness)
	DB.removeHandler(DB.getPath(nodeChar, "abilities.comeliness.base"), "onUpdate", updateUaComeliness)
	DB.removeHandler(DB.getPath(nodeChar, "abilities.comeliness.basemod"), "onUpdate", updateUaComeliness)
	DB.removeHandler(DB.getPath(nodeChar, "abilities.comeliness.adjustment"), "onUpdate", updateUaComeliness)
	DB.removeHandler(DB.getPath(nodeChar, "abilities.comeliness.tempmod"), "onUpdate", updateUaComeliness)

	OptionsManager.unregisterCallback(AdndOpHrManager.useUaComeliness, onUaComelinessOptionChanged)
	OptionsManager.unregisterCallback(AdndOpHrManager.useOaComelinessHonor, onOaComelinessHonorOptionChanged)

	super.onClose()
end

---
--- Update surprise scores
---
function updateSurpriseScores()
	local sOptSurpriseDie = OptionsManager.getOption("surpriseDie")

	local nodeChar = getDatabaseNode()

	-- with default d10 surprise die
	local surpriseBase = 3

	-- d6
	if sOptSurpriseDie == "d6" then
		-- d12
		surpriseBase = 2
	elseif sOptSurpriseDie == "d12" then
		surpriseBase = 4
	end

	--Debug.console("sOptSurpriseDie", sOptSurpriseDie, "surpriseBase", surpriseBase)

	local nMod = DB.getValue(nodeChar, "surprise.mod", 0)
	local nTmpMod = DB.getValue(nodeChar, "surprise.tempmod", 0)
	local nTotal = surpriseBase + nMod + nTmpMod

	DB.setValue(nodeChar, "surprise.total", "number", nTotal)
	DB.setValue(nodeChar, "surprise.base", "number", surpriseBase)
end

---
--- Update initiative scores
---
function updateInitiativeScores()
	local nodeChar = getDatabaseNode()

	-- default with modifiers on
	local initiativeMod = DB.getValue(nodeChar, "initiative.misc", 0)
	-- modifiers off
	if OptionsManager.getOption("initiativeModifiersAllow") == "off" then
		initiativeMod = 0
	end

	local nTmpMod = DB.getValue(nodeChar, "initiative.tempmod", 0)
	local nTotal = initiativeMod + nTmpMod

	DB.setValue(nodeChar, "initiative.total", "number", nTotal)
	DB.setValue(nodeChar, "initiative.misc", "number", nMod)
end

function updateOaComelinessHonor(node)
	local nodeChar = node.getChild("....")
	if (nodeChar == nil and node.getPath():match("^charsheet%.id%-%d+$")) then
		nodeChar = node
	end
	--AbilityScorePO.updateHonor(nodeChar);
end

function updateUaComeliness(node)
	local nodeChar = node.getChild("....")
	-- onInit doesn't have the same path for node, so we check here so first time
	-- load works.
	if (nodeChar == nil and node.getPath():match("^charsheet%.id%-%d+$")) then
		nodeChar = node
	end
	--local dbAbility = AbilityScorePO.updateComeliness(nodeChar)
	-- set tooltip for this because it's just to big for the abilities pane
	--comeliness_effects.setTooltipText(dbAbility.effects_TT)
end

function onUaComelinessOptionChanged()
	setPlayerOptionControlVisibility("useUaComeliness")
end

function onOaComelinessHonorOptionChanged()
	setPlayerOptionControlVisibility("useOaComelinessHonor")
end

function setPlayerOptionControlVisibility(sOption)
	if (sOption == "useUaComeliness") then
		bIsUaComelinessEnabled = AdndOpHrManager.isUaComelinessEnabled()
		setUaComelinessVisibility(bIsUaComelinessEnabled)
	elseif (sOption == "useOaComelinessHonor") then
		bIsOaComelinessHonorEnabled = AdndOpHrManager.isOaComelinessHonorEnabled()
		setOaComelinessHonorVisibility(bIsOaComelinessHonorEnabled)
	end

	Debug.console("char_main.lua", "bIsUaComelinessEnabled", bIsUaComelinessEnabled, "bIsOaComelinessHonorEnabled", bIsOaComelinessHonorEnabled)

	charSheetAdjustment()
end

function charSheetAdjustment()
	local nOffsetAmount = 0

	if bIsUaComelinessEnabled then
		nOffsetAmount = nOffsetAmount + 36
	end

	if bIsOaComelinessHonorEnabled then
		nOffsetAmount = nOffsetAmount + 81
	end

	Debug.console("char_main.lua", "nOffsetAmount", nOffsetAmount)

	combattitle.setAnchor("top", "charisma", "bottom", "relative", 15 + nOffsetAmount)
	combatanchor.setAnchor("top", "combattitle", "bottom", "relative", 15)
end

-- function setPlayerOptionControlVisibility(sOption)
-- 	local bIsUaComelinessEnabled = AdndOpHrManager.isUaComelinessEnabled()
-- 	local bIsOaComelinessHonorEnabled = AdndOpHrManager.isOaComelinessHonorEnabled()
-- 	Debug.console("char_main.lua", "bIsUaComelinessEnabled", bIsUaComelinessEnabled, "bIsOaComelinessHonorEnabled", bIsOaComelinessHonorEnabled)

-- 	setUaComelinessVisibility(bIsUaComelinessEnabled)
-- 	setOaComelinessHonorVisibility(bIsOaComelinessHonorEnabled)

-- 	local nOffsetAmount = 0

-- 	if bIsUaComelinessEnabled then
-- 		nOffsetAmount = nOffsetAmount + 36
-- 		--combattitle.setAnchor("top", "comeliness", "bottom", "relative", 15 + nOffsetAmount)
-- 		--combatanchor.setAnchor("top", "combattitle", "bottom", "relative", 15)
-- 	end

-- 	if bIsOaComelinessHonorEnabled then
-- 		nOffsetAmount = nOffsetAmount + 45
-- 		--combattitle.setAnchor("top", "honor", "bottom", "relative", 15 + nOffsetAmount)
-- 		--combatanchor.setAnchor("top", "combattitle", "bottom", "relative", 15)
-- 	end

-- 	Debug.console("char_main.lua", "nOffsetAmount", nOffsetAmount)

-- 	combattitle.setAnchor("top", "charisma", "bottom", "relative", 15 + nOffsetAmount)
-- 	combatanchor.setAnchor("top", "combattitle", "bottom", "relative", 15)
-- end

function setUaComelinessVisibility(bShow)
	comeliness.setVisible(bShow)
	com_label.setVisible(bShow)
	com_label_actual.setVisible(bShow)
	comdetailframe.setVisible(bShow)
	comeliness_percent.setVisible(bShow)
	com_percent_label.setVisible(bShow)
	comeliness_effects.setVisible(bShow)
	comeliness_effects_label.setVisible(bShow)
end

function setOaComelinessHonorVisibility(bShow)
	comeliness.setVisible(bShow)
	com_label.setVisible(bShow)
	com_label_actual.setVisible(bShow)
	comdetailframe.setVisible(bShow)
	comeliness_percent.setVisible(bShow)
	com_percent_label.setVisible(bShow)
	comeliness_effects.setVisible(bShow)
	comeliness_effects_label.setVisible(bShow)
	honor.setVisible(bShow)
	hon_label.setVisible(bShow)
	-- honor_label_actual.setVisible(bShow)
	-- hondetailframe.setVisible(bShow);
	-- honor_temp.setVisible(bShow);
	-- hon_temp_label.setVisible(bShow);
	-- honor_dice.setVisible(bShow);
	-- honor_dice_label.setVisible(bShow);
	-- honor_window.setVisible(bShow);
	-- honor_window_label.setVisible(bShow);
end
