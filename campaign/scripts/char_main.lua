local bIsUaComelinessEnabled
local bIsOaComelinessHonorEnabled
-- local bIsUse2eKitsEnabled

function onInit()
	if super and super.onInit then
		--Debug.console("super and oninit found")
		super.onInit()
	end

	local node = getDatabaseNode()

	DB.addHandler(DB.getPath(node, "abilities.comeliness.percentbase"), "onUpdate", updateComeliness)
	DB.addHandler(DB.getPath(node, "abilities.comeliness.percentbasemod"), "onUpdate", updateComeliness)
	DB.addHandler(DB.getPath(node, "abilities.comeliness.percentadjustment"), "onUpdate", updateComeliness)
	DB.addHandler(DB.getPath(node, "abilities.comeliness.percenttempmod"), "onUpdate", updateComeliness)
	DB.addHandler(DB.getPath(node, "abilities.comeliness.base"), "onUpdate", updateComeliness)
	DB.addHandler(DB.getPath(node, "abilities.comeliness.basemod"), "onUpdate", updateComeliness)
	DB.addHandler(DB.getPath(node, "abilities.comeliness.adjustment"), "onUpdate", updateComeliness)
	DB.addHandler(DB.getPath(node, "abilities.comeliness.tempmod"), "onUpdate", updateComeliness)
	DB.addHandler(DB.getPath(node, "abilities.honor.score"), "onUpdate", updateHonor)

	OptionsManager.registerCallback(AdndOpHrManager.useUaComeliness, onUaComelinessOptionChanged)
	OptionsManager.registerCallback(AdndOpHrManager.useOaComelinessHonor, onOaComelinessHonorOptionChanged)
	-- OptionsManager.registerCallback(AdndOpHrManager.use2eKits, onUse2eKitsOptionChanged)

	updateSurpriseScores()
	updateInitiativeScores()

	updateComeliness(node)
	updateHonor(node)

	bIsUaComelinessEnabled = AdndOpHrManager.isUaComelinessEnabled()
	bIsOaComelinessHonorEnabled = AdndOpHrManager.isOaComelinessHonorEnabled()
	-- bIs2eKitsEnabled = AdndOpHrManager.is2eKitsEnabled()

	setPlayerOptionControlVisibility("useUaComeliness")
	setPlayerOptionControlVisibility("useOaComelinessHonor")
	-- setPlayerOptionControlVisibility("use2eKits")
end

function onClose()
	local nodeChar = getDatabaseNode()
	DB.removeHandler(DB.getPath(nodeChar, "abilities.honor.score"), "onUpdate", updateHonor)
	DB.removeHandler(DB.getPath(nodeChar, "abilities.comeliness.percentbase"), "onUpdate", updateComeliness)
	DB.removeHandler(DB.getPath(nodeChar, "abilities.comeliness.percentbasemod"), "onUpdate", updateComeliness)
	DB.removeHandler(DB.getPath(nodeChar, "abilities.comeliness.percentadjustment"), "onUpdate", updateComeliness)
	DB.removeHandler(DB.getPath(nodeChar, "abilities.comeliness.percenttempmod"), "onUpdate", updateComeliness)
	DB.removeHandler(DB.getPath(nodeChar, "abilities.comeliness.base"), "onUpdate", updateComeliness)
	DB.removeHandler(DB.getPath(nodeChar, "abilities.comeliness.basemod"), "onUpdate", updateComeliness)
	DB.removeHandler(DB.getPath(nodeChar, "abilities.comeliness.adjustment"), "onUpdate", updateComeliness)
	DB.removeHandler(DB.getPath(nodeChar, "abilities.comeliness.tempmod"), "onUpdate", updateComeliness)

	OptionsManager.unregisterCallback(AdndOpHrManager.useUaComeliness, onUaComelinessOptionChanged)
	OptionsManager.unregisterCallback(AdndOpHrManager.useOaComelinessHonor, onOaComelinessHonorOptionChanged)
	-- OptionsManager.unregisterCallback(AdndOpHrManager.use2eKits, onUse2eKitsOptionChanged)

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

function updateHonor(node)
	local nodeChar = node.getChild("....")

	if (nodeChar == nil and node.getPath():match("^charsheet%.id%-%d+$")) then
		nodeChar = node
	end

	--Debug.console("char_main.lua", "updateHonor", "nodeChar", nodechar)
	AbilityScoreManagerAdndOpHr.updateHonor(nodeChar);
end

function updateComeliness(node)
	local nodeChar = node.getChild("....")
	-- onInit doesn't have the same path for node, so we check here so first time
	-- load works.
	if (nodeChar == nil and node.getPath():match("^charsheet%.id%-%d+$")) then
		nodeChar = node
	end

	--Debug.console("char_main.lua", "updateComeliness", "nodeChar", nodechar)

	AbilityScoreManagerAdndOpHr.updateComeliness(nodeChar)
end

function onUaComelinessOptionChanged()
	setPlayerOptionControlVisibility("useUaComeliness")
end

function onOaComelinessHonorOptionChanged()
	setPlayerOptionControlVisibility("useOaComelinessHonor")
end

-- function onUse2eKitsOptionChanged()
-- 	setPlayerOptionControlVisibility("use2eKits")
-- end

function setPlayerOptionControlVisibility(sOption)
	bIsUaComelinessEnabled = AdndOpHrManager.isUaComelinessEnabled()
	bIsOaComelinessHonorEnabled = AdndOpHrManager.isOaComelinessHonorEnabled()
	-- bIsUse2eKitsEnabled = AdndOpHrManager.is2eKitsEnabled()


	if (sOption == "useUaComeliness" and not bIsOaComelinessHonorEnabled) then
		setUaComelinessVisibility(bIsUaComelinessEnabled)
	elseif (sOption == "useOaComelinessHonor") then
		setOaComelinessHonorVisibility(bIsOaComelinessHonorEnabled)
	-- elseif (sOption == "use2eKits") then
	-- 	set2eKitsVisibility(bIsUse2eKitsEnabled)
	end

	--Debug.console("char_main.lua", "bIsUaComelinessEnabled", bIsUaComelinessEnabled, "bIsOaComelinessHonorEnabled", bIsOaComelinessHonorEnabled)

	charSheetAdjustment()
end

function charSheetAdjustment()
	local nOffsetAmount = 0

	if bIsUaComelinessEnabled and not bIsOaComelinessHonorEnabled then
		nOffsetAmount = 40
	end

	if bIsOaComelinessHonorEnabled then
		nOffsetAmount = 80
	end

	--Debug.console("char_main.lua", "nOffsetAmount", nOffsetAmount)

	combattitle.setAnchor("top", "charisma", "bottom", "relative", 15 + nOffsetAmount)
	combatanchor.setAnchor("top", "combattitle", "bottom", "relative", 15)
end

function setUaComelinessVisibility(bShow)
	comeliness.setVisible(bShow)
	com_label.setVisible(bShow)
	com_label_actual.setVisible(bShow)
	comdetailframe.setVisible(false)
	comeliness_percent.setVisible(bShow)
	com_percent_label.setVisible(bShow)
end

function setOaComelinessHonorVisibility(bShow)
	--Debug.console("char_main.lua", "bShow", bShow, "bIsUaComelinessEnabled", bIsUaComelinessEnabled)
	if not bShow and bIsUaComelinessEnabled then
        honor.setVisible(bShow)
		hon_label.setVisible(bShow)
    else
		comeliness.setVisible(bShow)
		com_label.setVisible(bShow)
		com_label_actual.setVisible(bShow)
		comdetailframe.setVisible(false)
		comeliness_percent.setVisible(bShow)
		com_percent_label.setVisible(bShow)
		honor.setVisible(bShow)
		hon_label.setVisible(bShow)
	end
end

-- function set2eKitsVisibility(bShow)
-- 	Debug.console("char_main.lua", "bShow", bShow, "bIsUse2eKitsEnabled", bIsUse2eKitsEnabled)
-- 	background.setVisible(bshow)
-- 	background_choose.setVisible(bshow)
-- 	backgroundlink.setVisible(bShow)
-- 	kit_title.setVisible(bShow)
-- end
