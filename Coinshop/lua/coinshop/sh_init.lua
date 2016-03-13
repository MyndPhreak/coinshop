

CS = {}
CS.__index = CS
 
CS.Items = {}
CS.Categories = {Hats = 
	{Name="Hats",
	 Icon = "",
	 Order = 0,
	 AllowedEquipped=1,
	 AllowedUsergroups = {},
	 CanPlayerSee = function() return true end,
	 ModifyTab = function(tab) return true end
	 }

}
CS.ClientsideModels = {}

CS.Config = {}
CS.Config.ShopKey = 'F3'


CS.Config.CalcBuyPrice = function(ply, item)
	return item.Price
end


function CS:ValidateI(items)
	if type(items) ~= 'table' then return {} end

	for item_id, item in pairs(items) do
		if not self.Items[item_id] then
			items[item_id] = nil
		end
	end
	
	return items 
end
 
function CS:ValidateP(points)
	if type(points) != 'number' then return 0 end
	
	return points >= 0 and points or 0
end



function CS:FindCategoryByName(cat_name)
	for id, cat in pairs(self.Categories) do
		if cat.Name == cat_name then
			return cat
		end
	end
	
	return false
end


include("sh_item.lua")
AddCSLuaFile("sh_item.lua")