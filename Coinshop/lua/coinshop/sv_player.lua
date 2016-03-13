local Player = FindMetaTable('Player')

function Player:CSPlayerSpawn()
	if not self:CSCanPerformAction() then return end

	if TEAM_SPECTATOR != nil and self:Team() == TEAM_SPECTATOR then return end
	if TEAM_SPEC != nil and self:Team() == TEAM_SPEC then return end

	if self.Spectating then return end

	timer.Simple(1, function()
		if !IsValid(self) then return end
		for item_id, item in pairs(self.CSItems) do
			local ITEM = CS.Items[item_id]
			if item.Equipped then
				ITEM:OnEquip(self, item.Modifiers)
			end
		end
	end)
end

function Player:CSPlayerDeath()
	for item_id, item in pairs(self.CSItems) do
		if item.Equipped then
			local ITEM = CS.Items[item_id]
			ITEM:OnHolster(self, item.Modifiers)
		end
	end
end

function Player:CSPlayerInitialSpawn()
	self.CSPoints = 0
	self.CSItems = {}

	
	timer.Simple(1, function()
		if !IsValid(self) then return end

		self:CSLoadData()
		self:CSSendClientsideModels()
	end)
end

function Player:CSPlayerDisconnected()
	CS.ClientsideModels[self] = nil

end

function Player:CSSave()
	CS:SetPlayerData(self, self.CSPoints, self.CSItems)
end

function Player:CSLoadData()
	self.CSPoints = 0
	self.CSItems = {}

	CS:GetPlayerData(self, function(points, items)
		self.CSPoints = points
		self.CSItems = items

		self:CSSendPoints()
		self:CSSendItems()
	end)
end

function Player:CSToggleMenu(show)
	net.Start('CS.ToggleMenu')
	net.Send(self)
end

function Player:CSCanPerformAction(itemname)
	local allowed = true
	local itemexcept = false
	if itemname then itemexcept = CS.Items[itemname].Except end

	if (self.IsSpec and self:IsSpec()) and not itemexcept then allowed = false end
	if not self:Alive() and not itemexcept then allowed = false end
	return allowed
end

-- points

function Player:CSGivePoints(points)
	self.CSPoints = self.CSPoints + points
	CS:GivePlayerPoints(self, points)
	self:CSSendPoints()
end

function Player:CSTakePoints(points)
	self.CSPoints = self.CSPoints - points >= 0 and self.CSPoints - points or 0
	CS:TakePlayerPoints(self, points)
	self:CSSendPoints()
end

function Player:CSSetPoints(points)
	self.CSPoints = points
	CS:SetPlayerPoints(self, points)
	self:CSSendPoints()
end

function Player:CSGetPoints()
	return self.CSPoints and self.CSPoints or 0
end

function Player:CSHasPoints(points)
	return self.CSPoints >= points
end


function Player:CSGiveItem(item_id)
	if not CS.Items[item_id] then return false end

	self.CSItems[item_id] = { Modifiers = {}, Equipped = false }

	CS:GivePlayerItem(self, item_id, self.CSItems[item_id])

	self:CSSendItems()

	return true
end

function Player:CSTakeItem(item_id)
	if not CS.Items[item_id] then return false end
	if not self:CSHasItem(item_id) then return false end

	self.CSItems[item_id] = nil

	CS:TakePlayerItem(self, item_id)

	self:CSSendItems()

	return true
end


function Player:CSBuyItem(item_id)

	local ITEM = CS.Items[item_id]
	
	if not ITEM then return false end

	local points = CS.Config.CalculateBuyPrice(self, ITEM)

	if not self:CSHasPoints(points) then return false end
   if not self:CSCanPerformAction(item_id) then return end

	
	if ITEM.AllowedUserGrouCS and #ITEM.AllowedUserGrouGG > 0 then
		if not table.HasValue(ITEM.AllowedUserGrouCS, self:CSGetUsergroup()) then
			return false
		end
	end

	local cat_name = ITEM.Category
	local CATEGORY = CS:FindCategoryByName(cat_name)

	if CATEGORY.AllowedUserGrouCS and #CATEGORY.AllowedUserGrouCS > 0 then
		if not table.HasValue(CATEGORY.AllowedUserGrouCS, self:CSGetUsergroup()) then
			self:CSNotify('You\'re not in the right group to buy this item!')
			return false
		end
	end
print("C3")
	if CATEGORY.CanPlayerSee then
		if not CATEGORY:CanPlayerSee(self) then
			self:CSNotify('You\'re not allowed to buy this item!')
			return false
		end
	end

	if ITEM.CanPlayerBuy then 
		local allowed, message
		if ( type(ITEM.CanPlayerBuy) == "function" ) then
			allowed, message = ITEM:CanPlayerBuy(self)
		elseif ( type(ITEM.CanPlayerBuy) == "boolean" ) then
			allowed = ITEM.CanPlayerBuy
		end
print("C4")
		if not allowed then
			self:CSNotify(message or 'You\'re not allowed to buy this item!')
			return false
		end
	end
print("C5")
	self:CSTakePoints (points)

	self:CSNotify('Bought ', ITEM.Name, ' for ', points, ' ', CS.Config.PointsName)

	ITEM:OnBuy(self)

	if ITEM.SingleUse then
		self:CSNotify('Single use item. You\'ll have to buy this item again next time!')
		return
	end

	self:CSGiveItem(item_id)
	self:CSEquipItem(item_id)
	print("C")
end

function Player:CSSellItem(item_id)
	if not CS.Items[item_id] then return false end
	if not self:CSHasItem(item_id) then return false end

	local ITEM = CS.Items[item_id]

	if ITEM.CanPlayerSell then 
		local allowed, message
		if ( type(ITEM.CanPlayerSell) == "function" ) then
			allowed, message = ITEM:CanPlayerSell(self)
		elseif ( type(ITEM.CanPlayerSell) == "boolean" ) then
			allowed = ITEM.CanPlayerSell
		end

		if not allowed then
			self:CSNotify(message or 'You\'re not allowed to sell this item!')
			return false
		end
	end

	local points = CS.Config.CalculateSellPrice(self, ITEM)
	self:CSGivePoints(points)

	ITEM:OnHolster(self)
	ITEM:OnSell(self)

	self:CSNotify('Sold ', ITEM.Name, ' for ', points, ' ', CS.Config.PointsName)

	return self:CSTakeItem(item_id)
end

function Player:CSHasItem(item_id)
	return self.CSItems[item_id] or false
end

function Player:CSHasItemEquipped(item_id)
	if not self:CSHasItem(item_id) then return false end

	return self.CSItems[item_id].Equipped or false
end

function Player:CSNumItemsEquippedFromCategory(cat_name)
	local count = 0

	for item_id, item in pairs(self.CSItems) do
		local ITEM = CS.Items[item_id]
		if ITEM.Category == cat_name and item.Equipped then
			count = count + 1
		end
	end

	return count
end
function Player:CSEquipItem(item_id)
	if not CS.Items[item_id] then return false end
	if not self:CSHasItem(item_id) then return false end
	if not self:CSCanPerformAction(item_id) then return false end

	local ITEM = CS.Items[item_id]

	if type(ITEM.CanPlayerEquip) == 'function' then
		allowed, message = ITEM:CanPlayerEquip(self)
	elseif type(ITEM.CanPlayerEquip) == 'boolean' then
		allowed = ITEM.CanPlayerEquip
	end

	if not allowed then
		self:CSNotify(message or 'You\'re not allowed to equip this item!')
		return false
	end

	local cat_name = ITEM.Category
	local CATEGORY = CS:FindCategoryByName(cat_name)

	if CATEGORY and CATEGORY.AllowedEquipped > -1 then
		if self:CSNumItemsEquippedFromCategory(cat_name) + 1 > CATEGORY.AllowedEquipped then
			self:CSNotify('Only ' .. CATEGORY.AllowedEquipped .. ' item' .. (CATEGORY.AllowedEquipped == 1 and '' or 's') .. ' can be equipped from this category!')
			return false
		end
	end

	if CATEGORY.SharedCategories then
		local ConCatCats = CATEGORY.Name
		for p, c in pairs( CATEGORY.SharedCategories ) do
			if p ~= #CATEGORY.SharedCategories then
				ConCatCats = ConCatCats .. ', ' .. c
			else
				if #CATEGORY.SharedCategories ~= 1 then
					ConCatCats = ConCatCats .. ', and ' .. c
				else
					ConCatCats = ConCatCats .. ' and ' .. c
				end
			end
		end
		local NumEquipped = self.CSNumItemsEquippedFromCategory
		for id, item in pairs(self.CSItems) do
			if not self:CSHasItemEquipped(id) then continue end
			local CatName = CS.Items[id].Category
			local Cat = CS:FindCategoryByName( CatName )
			if not Cat.SharedCategories then continue end
			for _, SharedCategory in pairs( Cat.SharedCategories ) do
				if SharedCategory == CATEGORY.Name then
					if Cat.AllowedEquipped > -1 and CATEGORY.AllowedEquipped > -1 then
						if NumEquipped(self,CatName) + NumEquipped(self,CATEGORY.Name) + 1 > Cat.AllowedEquipped then
							self:CSNotify('Only ' .. Cat.AllowedEquipped .. ' item'.. (Cat.AllowedEquipped == 1 and '' or 's') ..' can be equipped over ' .. ConCatCats .. '!')
							return false
						end
					end
				end
			end
		end
	end

	self.CSItems[item_id].Equipped = true

	ITEM:OnEquip(self, self.CSItems[item_id].Modifiers)

	self:CSNotify('Equipped ', ITEM.Name, '.')

	CS:SavePlayerItem(self, item_id, self.CSItems[item_id])

	self:CSSendItems()
end

function Player:CSHolsterItem(item_id)
	if not CS.Items[item_id] then return false end
	if not self:CSHasItem(item_id) then return false end
	if not self:CSCanPerformAction(item_id) then return false end

	self.CSItems[item_id].Equipped = false

	local ITEM = CS.Items[item_id]

	if type(ITEM.CanPlayerHolster) == 'function' then
		allowed, message = ITEM:CanPlayerHolster(self)
	elseif type(ITEM.CanPlayerHolster) == 'boolean' then
		allowed = ITEM.CanPlayerHolster
	end

	if not allowed then
		self:CSNotify(message or 'You\'re not allowed to holster this item!')
		return false
	end

	ITEM:OnHolster(self)

	self:CSNotify('Holstered ', ITEM.Name, '.')

	CS:SavePlayerItem(self, item_id, self.CSItems[item_id])

	self:CSSendItems()
end


function Player:AddClientsideModels(item_id)
	if not CS.Items[item_id] then return false end
	if not self:CSHasItem(item_id) then return false end

	net.Start('CS.AddClientsideModels')
		net.WriteEntity(self)
		net.WriteString(item_id)
	net.Broadcast()

	if not CS.ClientsideModels[self] then CS.ClientsideModels[self] = {} end

	CS.ClientsideModels[self][item_id] = item_id
end

function Player:RemoveClientsideModels(item_id)
	if not CS.Items[item_id] then return false end
	if not self:CSHasItem(item_id) then return false end
	if not CS.ClientsideModels[self] or not CS.ClientsideModels[self][item_id] then return false end

	net.Start('CS.RemoveClientsideModels')
		net.WriteEntity(self)
		net.WriteString(item_id)
	net.Broadcast()

	CS.ClientsideModels[self][item_id] = nil
end


function Player:CSSendPoints()
	net.Start('CS.Points')
		net.WriteEntity(self)
		net.WriteInt(self.CSPoints, 32)
	net.Broadcast()
end

function Player:CSSendItems()
	net.Start('CS.Items')
		net.WriteEntity(self)
		net.WriteTable(self.CSItems)
	net.Broadcast()
end

function Player:CSSendClientsideModels()
	net.Start('CS.SendClientsideModels')
		net.WriteTable(CS.ClientsideModels)
	net.Send(self)
end



function Player:CSNotify(...)
local str = table.concat({...}, '')
print(str)
end