function onInit()
    ItemManager.handleAnyDrop = ItemManagerAdndOpHr.handleAnyDrop
end

function handleAnyDrop(vTarget, draginfo)
    Debug.console("manager_item_adnd_op_hr.lua", "vTarget", vTarget, "draginfo", draginfo)
    local sDragType = draginfo.getType()

    if not Session.IsHost then
        local sTargetType = ItemManager.getItemSourceType(vTarget)
        if sTargetType == "item" then
            return false
        elseif sTargetType == "treasureparcels" then
            return false
        elseif sTargetType == "partysheet" then
            if sDragType ~= "shortcut" then
                return false
            end
            local sClass, sRecord = draginfo.getShortcutData()
            if not LibraryData.isRecordDisplayClass("item", sClass) then
                return false
            end
            local sSourceType = ItemManager.getItemSourceType(sRecord)
            if sSourceType ~= "charsheet" then
                return false
            end
        elseif sTargetType == "charsheet" then
            if not DB.isOwner(vTarget) then
                return false
            end
        end
    end

    if sDragType == "number" then
        ItemManager.handleString(vTarget, draginfo.getDescription(), draginfo.getNumberData())
        return true
    elseif sDragType == "string" then
        ItemManager.handleString(vTarget, draginfo.getStringData())
        return true
    elseif sDragType == "shortcut" then
        local sClass, sRecord = draginfo.getShortcutData()
        if LibraryData.isRecordDisplayClass("item", sClass) then
            local bTransferAll = false
            local sSourceType = ItemManager.getItemSourceType(sRecord)
            local sTargetType = ItemManager.getItemSourceType(vTarget)
            if
                StringManager.contains({"charsheet", "partysheet"}, sSourceType) and
                    StringManager.contains({"charsheet", "partysheet"}, sTargetType)
             then
                bTransferAll = Input.isShiftPressed()
            end

            local bIsArmor = ItemManager2.isArmor(sRecord)

            Debug.console("manager_item_adnd_op_hr.lua", "sRecord", sRecord, "bIsArmor", bIsArmor)

            if bIsArmor then
                Debug.console("manager_item_adnd_op_hr.lua", "sRecord", sRecord)
                --sRecord.armor.dp = 20
            end

            ItemManager.handleItem(vTarget, nil, sClass, sRecord, bTransferAll)
            return true
        elseif sClass == "treasureparcel" or sClass == "npc" then
            ItemManager.handleParcel(vTarget, sRecord)
            return true
        elseif sClass == "battle" then
            -- flip through each encounter, get the npc and apply inventory
            -- battle.id-X.npclist.id-X.link.class = npc
            -- battle.id-X.npclist.id-X.link.recordname = npc.id-00006
            -- s'sRecord' | s'battle.id-00001'
            local nodeBattle = DB.findNode(sRecord)
            for _, vNPC in pairs(DB.getChildren(nodeBattle, "npclist")) do
                local nCount = DB.getValue(vNPC, "count", 1)
                local _, sNPCRecord = DB.getValue(vNPC, "link", "", "")
                if (sNPCRecord ~= "") then
                    -- run for each # of them appearing
                    for i = 1, nCount do
                        handleParcel(vTarget, sNPCRecord)
                    end
                end
            end
            return true
        end
    end

    return false
end