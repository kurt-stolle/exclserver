local PANEL = {}
function PANEL:Init()
	self.PaintHook = false;

	self.Tabs = {}
	self.selection = 1;
	self.hover = 0;
	self.countTabLen = 0;
end
function PANEL:AddTab(n,icon)
	local p = vgui.Create("esDummyPanel",self);
	p:SetSize(self:GetWide()-2,self:GetTall()-22)
	p:SetPos(1,21);
	p:SetVisible(false);

	local wText,_ = surface.GetTextSize(n);
	local w = wText + 10 + 20;
	local id = #self.Tabs+1;
	local poo = vgui.Create("esDummyPanel",self);
	poo:SetPos(self.countTabLen,0);
	poo:SetSize(w,20);
	poo.id = id;
    function poo:OnCursorEntered()
   		self:GetParent().hover = self.id; 	
   	end
   	function poo:OnCursorExited()
   		self:GetParent().hover = 0; 	
   	end
   	function poo:OnMouseReleased()
    	self:GetParent().selection = self.id
    	for k,v in pairs(self:GetParent().Tabs)do
    		v.pnl:SetVisible(false);
    	end
    	self:GetParent().Tabs[self.id].pnl:SetVisible(true);
	end

	self.countTabLen = self.countTabLen+w-1;
	self.Tabs[id] = {name = n,pnl = p,icon = Material(icon or "icon16/page.png")};
	self.Tabs[1].pnl:SetVisible(true);
	return self.Tabs[id].pnl, id;
end
function PANEL:Paint()
	local a,b,c =ES.GetColorScheme()
	draw.RoundedBoxEx(0,0,20,self:GetWide(), self:GetTall()-20, Color(10,10,10,200),false,true,true,true)	
	draw.RoundedBoxEx(0,1,21,self:GetWide()-2, self:GetTall()-22, a,false,true,true,true)	
	
	local l = 0;
	surface.SetFont("ESDefaultBold")
	for k,v in pairs(self.Tabs)do
		local wText,_ = surface.GetTextSize(v.name);
		local w = wText + 4+16+6+8;

		draw.RoundedBoxEx(0,l,0,w,20,Color(10,10,10,200),true,true,false,false)
		if self.selection ~= k then
			local d = table.Copy(a);
			d.a = 50;
			draw.RoundedBoxEx(0,l+1,1,w-2,19,Color(0,0,0),true,true,false,false)
			draw.RoundedBoxEx(0,l+1,1,w-2,19,d,true,true,false,false)
		else	
			draw.RoundedBoxEx(0,l+1,1,w-2,20,a,true,true,false,false)
		end

		if self.hover == k and self.selection ~= k then
			local _,a = ES.GetColorScheme();
			local e = table.Copy(a); e.a = 140;
			draw.RoundedBoxEx(0,l+1,1,w-2,19,e,true,true,false,false)
		end

		surface.SetDrawColor(255,255,255,255);
		surface.SetMaterial(v.icon);
		surface.DrawTexturedRect(l+4,2,16,16);

		draw.SimpleText(v.name,"ESDefaultBoldBlur",l + 6+16+4,10,COLOR_BLACK,0,1);
		draw.SimpleText(v.name,"ESDefaultBold",l +  6+16+4+1,11,Color(0,0,0,200),0,1);
		draw.SimpleText(v.name,"ESDefaultBold",l +  6+16+4,10,self.selection ~= k and Color(220,220,220) or COLOR_WHITE,0,1);

		l = l+w-1;
	end

	if self.PaintHook then
		self.PaintHook()
	end
end
vgui.Register( "esTabPanel", PANEL,"Panel");

local DUMMY = {}
function DUMMY:Paint()
	--draw.RoundedBox(4,0,0,self:GetWide(),self:GetTall(),Color(200,200,0,100))
	if self.PaintHook then
		self.PaintHook();
	end
end
vgui.Register( "esDummyPanel",DUMMY,"Panel")