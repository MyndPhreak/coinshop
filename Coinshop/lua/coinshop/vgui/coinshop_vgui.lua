resource.AddFile("fonts/CaviarDreams.ttf")
resource.AddFile("fonts/CaviarDreams_Bold.ttf")

surface.CreateFont( "CSFontBold", {
	font = "Caviar Dreams Bold",
	size = 50,
	antialias = true,
} )
surface.CreateFont( "CSFont", {
	font = "Caviar Dreams",
	size = 50,
	antialias = true
} )
surface.CreateFont( "CSCoin", {
	font = "Caviar Dreams Bold",
	size = 75,
	antialias = true,
} )

CS.IMG = {}
CS.IMG.LOGO = Material("materials/cs_logo.png","")
CS.IMG.BG = Material("materials/bg.png","noclamp smooth")
CS.IMG.CLOSE = Material("materials/close.png","noclamp smooth")
CS.IMG.SHADOW = Material("gui/gradient")

CS.COL = {}
CS.COL.TOPBAR = Color(34,33,31,191)
CS.COL.TOPBORDER = Color(0,0,0,191)
CS.COL.WHITE = Color(255,255,255)
CS.COL.DARK = Color(34,33,31)
CS.COL.MED = Color(122,118,111)
CS.COL.LIGHT = Color(151,146,138)
CS.COL.LGREEN = Color(149,178,153)
CS.COL.DGREEN = Color(86,150,94)
CS.COL.PBLUE = Color(117,138,148)

local myscrw, myscrh = 1920,1080
local blur = Material("pp/blurscreen")

function CS.SizeW(width)
	local screenwidth = myscrw
	return width*ScrW()/screenwidth
end

function CS.SizeH(height)
	local screenheight = myscrh
	return height*ScrH()/screenheight
end 

function CS.SizeWH(width, height)
	local screenwidth = myscrw
	local screenheight = myscrh
	return width*ScrW()/screenwidth, height*ScrH()/screenheight
end

function DrawBlurPanel(panel, amount, heavyness)
	local x, y = panel:LocalToScreen(0, 0)
	local scrW, scrH = ScrW(), ScrH()

	surface.SetDrawColor(255,255,255)
	surface.SetMaterial(blur)

	for i = 1, heavyness do
		blur:SetFloat("$blur", (i / 3) * (amount or 6))
		blur:Recompute()

		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
	end
end

function Selected(s,w,deg)
	local x,y = s:GetPos()
	surface.SetDrawColor(0,0,0,190)
	surface.SetMaterial(CS.IMG.SHADOW)
	surface.DrawTexturedRectRotated(s:GetWide()-w/2,s:GetTall()/2,w,s:GetTall(),deg)
end

local PANEL = {}

function PANEL:Init()
	self:MakePopup(true)
-- top bar container with all the info and shit
	self.TopBar = vgui.Create("DPanel",self)
	self.TopBar.Paint = function(s,w,h)
		surface.SetDrawColor(CS.COL.TOPBORDER)
		surface.DrawRect(0,104,w,2)
		surface.SetDrawColor(CS.COL.TOPBAR)
		surface.DrawRect(0,0,w,h)

		surface.SetDrawColor(CS.COL.WHITE)
		surface.SetMaterial(CS.IMG.LOGO)
		surface.DrawTexturedRect(10,h-CS.SizeH(self.TopBar:GetTall()/2 + 64/2),256,64)
	end
-- close button top right
	self.Close = vgui.Create("DButton",self.TopBar)
	self.Close:SetText("")
	self.Close:SetColor(CS.COL.WHITE)
	self.Close.Paint = function(s,w,h)
		surface.SetDrawColor(CS.COL.WHITE)
		surface.SetMaterial(CS.IMG.CLOSE)
		surface.DrawTexturedRect(0,0,CS.SizeW(27),CS.SizeH(27))
	end
	self.Close.DoClick = function(s)
		self:Remove()
	end
-- player avatar
	self.Avatar = vgui.Create( "AvatarImage", self.TopBar )
	self.Avatar:SetSize(CS.SizeWH(64,64))
	self.Avatar:SetPlayer( LocalPlayer(), 64 )
-- player name
	self.Nick = vgui.Create( "DLabel", self.TopBar  )
	self.Nick:SetText(LocalPlayer():Nick())
	self.Nick:SetFont("CSFontBold")
	self.Nick:SetTextColor(CS.COL.WHITE)
	self.Nick:SizeToContents()
-- coin symbol, using the cent symbol, because it makes more...cents...get it?
	self.Coin = vgui.Create( "DLabel", self.TopBar  )
	self.Coin:SetText("¢")
	self.Coin:SetFont("CSCoin")
	self.Coin:SetTextColor(CS.COL.DGREEN)
	self.Coin:SizeToContents()
-- wallet amount
	self.Coins = vgui.Create( "DLabel", self.TopBar  )
	self.Coins:SetText("79,154")--eventually this will be replaced by the function for the actual amount
	self.Coins:SetFont("CSFontBold")
	self.Coins:SetTextColor(CS.COL.LGREEN)
	self.Coins:SizeToContents()

-- admin button for shits + admin shits...also, shit's fuckin crude as hell. Fix it.
	self.CSAdmin = vgui.Create("DButton",self)
	self.CSAdmin:SetText("ADMIN")
	self.CSAdmin:SetColor(CS.COL.WHITE)
	self.CSAdmin:SetFont("CSFontBold")
	self.CSAdmin.Paint = function(s,w,h)
		draw.RoundedBox(10,0,0,w,h,CS.COL.MED)
	end
	self.CSAdmin.DoClick = function(s)
		self.CSADialog = vgui.Create("DPanel",self)
		self.CSADialog:SetAlpha(0)
		self.CSADialog:AlphaTo(255,0.25,0)
		self.CSADialog:SetSize(CS.SizeWH(800,600))
		self.CSADialog:SetPos(CS.SizeWH(self:GetWide()/2-self.CSADialog:GetWide()/2,self:GetTall()/2-self.CSADialog:GetTall()/2))
		self.CSADialog.Paint = function(s,w,h)
			surface.DisableClipping( true )
			DrawBlurPanel(s,5,5)
			draw.RoundedBox(0,-10,-10,w+20,h+20,CS.COL.TOPBORDER)
			draw.RoundedBox(0,0,0,w,h,CS.COL.PBLUE)
			surface.SetDrawColor(CS.COL.TOPBORDER)
			surface.DrawRect(0,50,w,2)
			draw.SimpleText("Admin Shits","CSFontBold",5,5,CS.COL.WHITE,TEXT_ALIGN_LEFT,TEXT_ALIGN_BOTTOM)
		end
		self.CSADialogClose = vgui.Create("DButton",self.CSADialog)
		self.CSADialogClose:SetText("")
		self.CSADialogClose:SetSize(CS.SizeWH(27,27))
		self.CSADialogClose:SetPos(self.CSADialog:GetWide()-self.CSADialogClose:GetWide()-5,5)
		self.CSADialogClose.Paint = function(s,w,h)
			surface.SetDrawColor(CS.COL.TOPBORDER)
			surface.SetMaterial(CS.IMG.CLOSE)
			surface.DrawTexturedRect(0,0,CS.SizeW(27),CS.SizeH(27))
		end
		self.CSADialogClose.DoClick = function(s)
			self.CSADialog:AlphaTo(0,0.25,0,function()
				self.CSADialog:Remove()
				self.CSADialogClose:Remove()
			end)
		end
	end


-- background for the playermode view
	self.PlyModelBG = vgui.Create("DPanel", self)
	self.PlyModelBG.Paint = function(s,w,h)
		surface.SetDrawColor(CS.COL.DARK)
		surface.DrawRect(0,0,w,h)
	end
-- background for the store part
	self.StoreBG = vgui.Create("DPanel", self)
	self.StoreBG.Paint = function(s,w,h)
		surface.SetDrawColor(CS.COL.LIGHT)
		surface.DrawRect(0,0,w,h)
	end
-- player mode on the playermodel background
	self.PlyModelView = vgui.Create( "DModelPanel", self )
	self.PlyModelView:SetModel( LocalPlayer():GetModel() )
	self.PlyModelView:SetAnimated( ACT_WALK )
	self.PlyModelView:SetMouseInputEnabled(false)
	function self.PlyModelView.Entity:GetPlayerColor() LocalPlayer():GetPlayerColor() end
	function self.PlyModelView:LayoutEntity( ent ) return end
	self.PlyModelView:SetAmbientLight( Color( 92, 95, 144, 255 ) )
	local eyepos = self.PlyModelView.Entity:GetBonePosition( self.PlyModelView.Entity:LookupBone( "ValveBiped.Bip01_Head1" ) )
	eyepos:Add( Vector( 0, 0, -20 ) )	-- Move up slightly
	self.PlyModelView:SetLookAt( eyepos )
	self.PlyModelView:SetCamPos( eyepos-Vector( -40, 20, -10 ) )	-- Move cam in front of eyes
	self.PlyModelView.Entity:SetEyeTarget( eyepos-Vector( 25, 20, -20 ) )

	-- THE TABS ON THE SIDE FOR THE DIFFERENT CATEGORIES AND SHIT
	self.Tab1 = vgui.Create("DButton",self)
	self.Tab1:SetText("MODELS")
	self.Tab1:SetColor(CS.COL.WHITE)
	self.Tab1.Paint = function(s,w,h)
		surface.DisableClipping( true )
		draw.RoundedBoxEx(10,0,0,w,h,CS.COL.MED,true,false,true,false)
		Selected(s,30,180)
	end
	self.Tab2 = vgui.Create("DButton",self)
	self.Tab2:SetText("SHIRTS")
	self.Tab2.Paint = function(s,w,h)
		draw.RoundedBoxEx(10,0,0,w,h,CS.COL.MED,true,false,true,false)
	end
	self.Tab3 = vgui.Create("DButton",self)
	self.Tab3:SetText("HATS")
	self.Tab3.Paint = function(s,w,h)
		draw.RoundedBoxEx(10,0,0,w,h,CS.COL.MED,true,false,true,false)
	end
	self.Tab4 = vgui.Create("DButton",self)
	self.Tab4:SetText("BACK")
	self.Tab4.Paint = function(s,w,h)
		draw.RoundedBoxEx(10,0,0,w,h,CS.COL.MED,true,false,true,false)
	end
	self.Tab5 = vgui.Create("DButton",self)
	self.Tab5:SetText("WEAPONS")
	self.Tab5.Paint = function(s,w,h)
		draw.RoundedBoxEx(10,0,0,w,h,CS.COL.MED,true,false,true,false)
	end
	self.Tab6 = vgui.Create("DButton",self)
	self.Tab6:SetText("POWERUPS")
	self.Tab6.Paint = function(s,w,h)
		draw.RoundedBoxEx(10,0,0,w,h,CS.COL.MED,true,false,true,false)
	end
	self.Tab7 = vgui.Create("DButton",self)
	self.Tab7:SetText("INVENTORY")
	self.Tab7.Paint = function(s,w,h)
		draw.RoundedBoxEx(10,0,0,w,h,CS.COL.MED,true,false,true,false)
	end
	self.Tab8 = vgui.Create("DButton",self)
	self.Tab8:SetText("SETTINGS")
	self.Tab8.Paint = function(s,w,h)
		draw.RoundedBoxEx(10,0,0,w,h,CS.COL.MED,true,false,true,false)
	end

end


function PANEL:PerformLayout(w,h)
	self:Center()
	self:SetSize(CS.SizeWH(1900,1060))

	self.TopBar:SetSize(CS.SizeWH(1900,106))
	self.Close:SetSize(CS.SizeWH(27,27))
	self.Close:SetPos(w-CS.SizeW(self.Close:GetWide()+5),5)
	self.Avatar:SetPos(CS.SizeW(207+self.Avatar:GetWide()),self.TopBar:GetTall()/2 - self.Avatar:GetTall()/2)
	self.Nick:SetPos(CS.SizeW(207+self.Avatar:GetWide()+80),self.TopBar:GetTall()/2 - self.Nick:GetTall()/2)
	self.Coin:SetPos(CS.SizeW(207+self.Avatar:GetWide()+self.Nick:GetWide()*2+self.Coin:GetWide()),self.TopBar:GetTall()/2 - self.Coin:GetTall()/2.5)
	self.Coins:SetPos(CS.SizeW(207+self.Avatar:GetWide()+self.Nick:GetWide()*2+self.Coin:GetWide()*2),self.TopBar:GetTall()/2 - self.Coins:GetTall()/2)
	self.CSAdmin:SetSize(CS.SizeWH(226,73))
	self.CSAdmin:SetPos(w-CS.SizeW(self.CSAdmin:GetWide()+self.Close:GetWide()+50),self.TopBar:GetTall()/2-self.CSAdmin:GetTall()/2)

	self.PlyModelBG:SetPos(56,CS.SizeH(h/2 + self.TopBar:GetTall()/2 - self.PlyModelBG:GetTall()/2))
	self.PlyModelBG:SetSize(CS.SizeWH(592,848))

	self.PlyModelView:SetSize(CS.SizeWH(self.PlyModelBG:GetSize()))
	self.PlyModelView:SetPos(CS.SizeWH(56,h/2 + self.TopBar:GetTall()/2 - self.PlyModelBG:GetTall()/2))

	self.StoreBG:SetPos(CS.SizeW(w-self.StoreBG:GetWide()-56),CS.SizeH(h/2 + self.TopBar:GetTall()/2 - self.StoreBG:GetTall()/2))
	self.StoreBG:SetSize(CS.SizeWH(1196,848))

	self.Tab1:SetPos(CS.SizeW(self.PlyModelBG:GetWide()+56-94),CS.SizeH(h/2 + self.TopBar:GetTall()/2 - self.StoreBG:GetTall()/2))
	self.Tab1:SetSize(CS.SizeWH(94,78))

	self.Tab2:SetPos(CS.SizeW(self.PlyModelBG:GetWide()+56-94),CS.SizeH(h/2 + self.TopBar:GetTall()/2 - self.StoreBG:GetTall()/2)+80)
	self.Tab2:SetSize(CS.SizeWH(94,78))

	self.Tab3:SetPos(CS.SizeW(self.PlyModelBG:GetWide()+56-94),CS.SizeH(h/2 + self.TopBar:GetTall()/2 - self.StoreBG:GetTall()/2)+80*2)
	self.Tab3:SetSize(CS.SizeWH(94,78))

	self.Tab4:SetPos(CS.SizeW(self.PlyModelBG:GetWide()+56-94),CS.SizeH(h/2 + self.TopBar:GetTall()/2 - self.StoreBG:GetTall()/2)+80*3)
	self.Tab4:SetSize(CS.SizeWH(94,78))

	self.Tab5:SetPos(CS.SizeW(self.PlyModelBG:GetWide()+56-94),CS.SizeH(h/2 + self.TopBar:GetTall()/2 - self.StoreBG:GetTall()/2)+80*4)
	self.Tab5:SetSize(CS.SizeWH(94,78))

	self.Tab6:SetPos(CS.SizeW(self.PlyModelBG:GetWide()+56-94),CS.SizeH(h/2 + self.TopBar:GetTall()/2 - self.StoreBG:GetTall()/2)+80*5)
	self.Tab6:SetSize(CS.SizeWH(94,78))

	self.Tab7:SetPos(CS.SizeW(self.PlyModelBG:GetWide()+56-94),CS.SizeH(h/2 + self.TopBar:GetTall()/2 - self.StoreBG:GetTall()/2)+80*6)
	self.Tab7:SetSize(CS.SizeWH(94,78))

	self.Tab8:SetPos(CS.SizeW(self.PlyModelBG:GetWide()+56-94),CS.SizeH(h/2 + self.TopBar:GetTall()/2 - self.StoreBG:GetTall()/2)+80*7)
	self.Tab8:SetSize(CS.SizeWH(94,78))
end

function PANEL:Paint(w,h)
	Derma_DrawBackgroundBlur( self, self.startTime )
	surface.SetDrawColor(Color(255,255,255))
	surface.SetMaterial(CS.IMG.BG)
	surface.DrawTexturedRectUV( 0, 0, w, h, 0, 0, w / 200, h / 200 )
end

vgui.Register("CS",PANEL)
