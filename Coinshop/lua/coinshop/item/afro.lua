SHOPITEM.Name = 'afro'
SHOPITEM.Description = "A seductive Afro"
SHOPITEM.Category = "Hats"
SHOPITEM.Price = 2700
SHOPITEM.Model = 'models/gmod_tower/afro.mdl'
SHOPITEM.Attachment = 'eyes'

function SHOPITEM:OnEquip(ply, modifications)
	ply:AddClientsideModels(self.ID)
end

function SHOPITEM:OnHolster(ply)
	ply:RemoveClientsideModels(self.ID)
end


function SHOPITEM:ModifyModel(ply, model, pos, ang)
	model:SetModelScale(0.9, 0)
	pos = pos + (ang:Up() * 2+ang:Forward()*-4)
	ang:RotateAroundAxis(ang:Right(), 0)
	
	return model, pos, ang
end
