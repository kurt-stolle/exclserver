local PNL = {}

local icon_car = Material("icon16/car.png")
function PNL:Init()
	self.title = "Unnamed"
	self.Icon = icon_car
	self.Position = 1
	self.Selected = false
end
function PNL:Paint(w,h)
	draw.RoundedBox(0,0,0,self:GetWide(),self:GetTall(),Color(0,0,0,200))

	if not self.Selected then
		draw.RoundedBox(0,1,1,self:GetWide()-2,self:GetTall()-2,ES.Color["#1A1A1A"])
		
		if self:GetHover() then
			draw.RoundedBox(0,1,1,self:GetWide()-2,self:GetTall()-2,ES.GetColorScheme(3))
		end

		draw.SimpleText(self.title,"ESDefaultBold.Shadow",6 + 16 + 6,self:GetTall()/2-1,ES.Color.Black,0,1)
		draw.SimpleText(self.title,"ESDefaultBold",6 + 16 + 6,self:GetTall()/2-1,ES.Color["#DDD"],0,1)

		

	elseif self.Selected then
		draw.RoundedBox(0,1,1,self:GetWide()-2,self:GetTall()-1,ES.GetColorScheme(2))
		draw.SimpleText(self.title,"ESDefaultBold.Shadow",6 + 16 + 6,self:GetTall()/2-1,ES.Color.Black,0,1)
		draw.SimpleText(self.title,"ESDefaultBold",6 + 16 + 6,self:GetTall()/2-1,ES.Color.White,0,1)
	end

	surface.SetMaterial(self.Icon)
	surface.SetDrawColor(ES.Color.White)
	surface.DrawTexturedRect(6,(h/2) - (16/2),16,16) 
end
ES.UIAddHoverListener(PNL)
vgui.Register( "esTabPanel.Tab", PNL, "Panel" )

local PNL = {}
function PNL:Init()
	self.PaintHook = function() end
	self._tabs = {}
	self._x_tab = 1
end
function PNL:AddTab(title,icon)
	title=string.upper(title)

	local p = vgui.Create("Panel",self)
	p:SetTall(self:GetTall()-24)
	p:Dock(BOTTOM)

	self._tabs[#self._tabs+1]=p
	p:SetVisible(#self._tabs==1)

	local b = vgui.Create("esTabPanel.Tab",self)
	b.Position = #self._tabs
	b.Selected = (#self._tabs == 1)
	b.Icon = icon and Material(icon) or icon_car
	b.title = title or "Untitled"
	b.OnMouseReleased= function(btn)
		for k,v in pairs(self._tabs)do
			if b.Position != v.button.Position then
				v:SetVisible(false)
				v.button.Selected=false
			end
		end
		p:SetVisible(true)
		b.Selected = true
	end

	p.button = b

	surface.SetFont("ESDefaultBold")
	local w,h=surface.GetTextSize(b.title)
	b:SetSize(6+16+6+w+8,24)
	b:SetPos(self._x_tab-1,0)

	self._x_tab=b.x+b:GetWide()
	
	return p
end
function PNL:Paint(w,h)
	surface.SetDrawColor(ES.Color.Black)
	surface.DrawRect(0,23,w,h-23)
	surface.SetDrawColor(ES.GetColorScheme(2))
	surface.DrawRect(1,24,w-2,h-25)
end
vgui.Register( "esTabPanel", PNL,"Panel")
