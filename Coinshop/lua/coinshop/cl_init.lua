include("sh_init.lua")
include("cl_player.lua")
include("vgui/coinshop_vgui.lua")
CS.Menu = nil
CS.ClientsideModels = {}
local invalids = {}

function CS:OpenShopMenu()
	if not IsValid(CS.Menu) then
		CS.Menu = vgui.Create("CS")
		CS.Menu:SetVisible(true)
	end
end
net.Receive("CS.ToggleMenu",function() CS:OpenShopMenu() end)
 
function CS_NetItems()
	local ply = net.ReadEntity()
	local items = net.ReadTable()
	ply.CSItems = CS:ValidateI(items)
end
net.Receive("CS.Items",CS_NetItems)

function CS_NetPoints()
	local ply = net.ReadEntity()
	local ps = net.ReadInt(32)
	ply.CSPoints = CS:ValidateP(points)
end
net.Receive("CS.Points",CS_NetPoints)

function CS_NetAddModel()
	local ply = net.ReadEntity()
	local itemid = net.ReadString()
	
	if not IsValid(ply) then
		if not invalids[ply] then
			invalids[ply] = {}
		end
		
		table.insert(invalids[ply], itemid)
		return
	end
	
	ply:AddClientsideModels(itemid)
end
net.Receive("CS.AddClientsideModels",CS_NetAddModel)

function CS_NetRemoveModel()
local ply = net.ReadEntity()
local itemid = net.ReadString()

	if not ply or not IsValid(ply) or not ply:IsPlayer() then return end
	
	ply:RemoveClientsideModels(itemid)

end
net.Receive("CS.RemoveClientsideModels",CS_NetRemoveModel)

function CS_NetSendModels()
	local items = net.ReadTable()
	
	for p,i in pairs(items) do
		if not IsValid(ply) then
			invalids[ply] = i
			continue 
		end
		
		for _,id in pairs(items) do
			if CS.Items[id] then
				ply:AddClientsideModels(id)
			end
		end
	end
end
net.Receive("CS.SendClientsideModels",CS_NetSendModels)

function CS_Notify()
local txt = net.ReadString()
ply:ChatPrint(txt)
end
net.Receive("CS.Notify",CS_Notify)


function CS_Think()
	for p,i in pairs(invalids) do
		if IsValid(p) then
			for _,id in pairs(i) do
				if CS.Items[id] then
					p:AddClientsideModels(id)
				end
			end
		invalids[p] = nil
		end
	end
end
hook.Add("Think","CS.Think",CS_Think)

function CS_PostDraw(ply)
	if not ply:Alive() then return end
	if ply == LocalPlayer() and GetViewEntity():GetClass() == "player" and  (GetConVar('thirdperson') and GetConVar('thirdperson'):GetInt() == 0) then return end
	if not CS.ClientsideModels[ply] then return end
	
	for id,model in pairs(CS.ClientsideModels[ply]) do
		if not CS.Items[id] then CS.Items[id] = nil continue end
			local SHOPITEM = CS.Items[id]
		if not SHOPITEM.Attachment and not SHOPITEM.Bone then CS.ClientsideModels[ply][id] = nil continue end
		
		local pos = Vector()
		local ang = Angle()
		
		if SHOPITEM.Attachment then
			local attach_id = ply:LookupAttachment(SHOPITEM.Attachment)
			if not attach_id then return end
			
			local attach = ply:GetAttachment(attach_id)
			
			if not attach then return end
			
			pos = attach.Pos
			ang = attach.Ang
		else
			local bone_id = ply:LookupBone(SHOPITEM.Bone)
			if not bone_id then return end
			
			pos, ang = ply:GetBonePosition(bone_id)
		end
		
		model, pos, ang = SHOPITEM:MModel(ply, model, pos, ang)
		
		model:SetPos(pos)
		model:SetAngles(ang)

		model:SetRenderOrigin(pos)
		model:SetRenderAngles(ang)
		model:SetupBones()
		model:DrawModel()
		model:SetRenderOrigin()
		model:SetRenderAngles()
	end
end
hook.Add("PostPlayerDraw","CS.PPD",CS_PostDraw)
	
	
	