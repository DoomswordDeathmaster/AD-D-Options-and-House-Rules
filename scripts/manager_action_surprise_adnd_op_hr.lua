function onInit()
	getRollOrig = ActionSurprise.getRoll
	ActionSurprise.getRoll = getRollAdndOpHr
end

function getRollAdndOpHr(rActor, nTargetDC, bSecretRoll)
	sOptSurpriseDie = OptionsManager.getOption("surpriseDie")

	if sOptSurpriseDie == "d6" then
		DataCommonADND.aDefaultSurpriseDice = {"d6"}
	elseif sOptSurpriseDie == "d10" then
		DataCommonADND.aDefaultSurpriseDice = {"d10"}
	elseif sOptSurpriseDie == "d12" then
		DataCommonADND.aDefaultSurpriseDice = {"d12"}
	end

	local rRoll = {}
	rRoll.sType = "surprise"
	rRoll.nMod = 0

	local aDice = DB.getValue(nodeChar, "surprise.dice")

	if aDice == nil then
		aDice = DataCommonADND.aDefaultSurpriseDice
	end

	rRoll.aDice = aDice

	if (nTargetDC == nil) then
		--local node = CombatManagerADND.getCTFromActor(rActor)
		local nodeCT = ActorManager.getCTNode(rActor)
		nTargetDC = getSurpriseTarget(nodeCT)
		Debug.console("ActionSurpriseAdndOpHr", "nTargetDC", nTargetDC, "rActor", rActor, "node", node)
	end

	rRoll.sDesc = "[CHECK] "
	rRoll.bSecret = bSecretRoll
	rRoll.nTarget = nTargetDC

	return rRoll
end

-- return the current surprise value for this target.
function getSurpriseTarget(node)
	local nBase = DB.getValue(node, "surprise.base", 3)
	local nMod = DB.getValue(node, "surprise.mod", 0)
	local nTmpMod = DB.getValue(node, "surprise.tempmod", 0)
	local nTotal = nBase + nMod + nTmpMod

	return nTotal
end

function performRoll(draginfo, rActor, nTargetDC, bSecretRoll)
	local rRoll = getRollAdndOpHr(rActor, nTargetDC, bSecretRoll)

	ActionsManager.performAction(draginfo, rActor, rRoll)
end
