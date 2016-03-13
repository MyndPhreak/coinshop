 
// kinda ripped from pointshop but slightly modified to not be so shit
function CS:LoadItems()
MsgC(color_white,"[Coinshop]",Color(255,0,0)," Item Loader")
    local files, folders = file.Find('coinshop/item/*', 'LUA'), nil
	PrintTable(files)
	pcall(function() PrintTable(folders) end)
    for _, name in pairs(files) do
		print(name)
	if SERVER then
                AddCSLuaFile('coinshop/item/'.. name)
            end

            SHOPITEM = {}
            SHOPITEM.__index = SHOPITEM
            SHOPITEM.ID = string.gsub(string.lower(name), '.lua', '')
            SHOPITEM.Name = ""
            SHOPITEM.Description = ""
			SHOPITEM.Category = ""
			SHOPITEM.Price = 0
					
			SHOPITEM.AdminOnly = false
			SHOPITEM.AllowedUserGroups = {} 
			SHOPITEM.SingleUse = false
			SHOPITEM.NoPreview = false
					
			SHOPITEM.CanPlayerBuy = true
			SHOPITEM.CanPlayerSell = true
					
			SHOPITEM.CanPlayerEquip = true
			SHOPITEM.CanPlayerHolster = true

			SHOPITEM.OnBuy = function() end
			SHOPITEM.OnSell = function() end
			SHOPITEM.OnEquip = function() end
			SHOPITEM.OnHolster = function() end
			SHOPITEM.OnModify = function() end
			SHOPITEM.MModel = function(SHOPITEM, ply, model, pos, ang)
				return model, pos, ang
			end
			
            include('coinshop/item/' .. name)
            local item = SHOPITEM
            CS.Items[SHOPITEM.ID] = SHOPITEM
            
            	for prop, val in pairs(item) do
						if type(val) == "function" then 
						hook.Add(prop, 'CSH__' .. item.ID.. '_'..prop, function(...)
										print("SHUT",item,ply)
										item[prop](item, ply, unpack({...}))
							end)
						end
				end
  
            SHOPITEM = nil
  
            
        end
end

function CS_InitItems()
CS:LoadItems()
end
CS:LoadItems()
hook.Add( "Initialize", "CS.loaditems", CS_InitItems) 
