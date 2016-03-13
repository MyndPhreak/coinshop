local Player = FindMetaTable('Player')

-- items

function Player:CSGetItems()
	return self.CSItems or {}
end

function Player:CSHasItem(item_id)
	if not self.CSItems then return false end
	return self.CSItems[item_id] and true or false
end

function Player:CSHasItemEquipped(item_id)
	if not self:CSHasItem(item_id) then return false end
	
	return self.CSItems[item_id].Equipped or false
end

function Player:CSBuyItem(item_id)
	if self:CSHasItem(item_id) then return false end
	if not self:CSHasPoints(CS.Config.CalculateBuyPrice(self, CS.Items[item_id])) then return false end
	print("A")
	net.Start('CS.BuyItem')
		net.WriteString(item_id)
	net.SendToServer()
end

function Player:CSSellItem(item_id)
	if not self:CSHasItem(item_id) then return false end
	
	net.Start('CS.SellItem')
		net.WriteString(item_id)
	net.SendToServer()
end

function Player:CSEquipItem(item_id)
	if not self:CSHasItem(item_id) then return false end
	
	net.Start('CS.EquipItem')
		net.WriteString(item_id)
	net.SendToServer()
end

function Player:CSHolsterItem(item_id)
	if not self:CSHasItem(item_id) then return false end
	
	net.Start('CS.HoldItem')
		net.WriteString(item_id)
	net.SendToServer()
end

-- points

function Player:CSGetPoints()
	return self.CSPoints or 0
end

function Player:CSHasPoints(points)
	return self:CSGetPoints() >= points
end

function Player:AddClientsideModels(item_id)
	PrintTable(CS.Items)
	if not CS.Items[item_id] then return false end
	
	local SHOPITEM = CS.Items[item_id]
	
	local mdl = ClientsideModel(SHOPITEM.Model, RENDERGROUP_OPAQUE)
	mdl:SetNoDraw(true)
	
	if not CS.ClientsideModels[self] then CS.ClientsideModels[self] = {} end
	CS.ClientsideModels[self][item_id] = mdl
	print(CS.ClientsideModels[self][item_id])
end

function Player:RemoveClientsideModels(item_id)
	if not CS.Items[item_id] then return false end
	if not CS.ClientsideModels[self] then return false end
	if not CS.ClientsideModels[self][item_id] then return false end
	
	CS.ClientsideModels[self][item_id] = nil
end