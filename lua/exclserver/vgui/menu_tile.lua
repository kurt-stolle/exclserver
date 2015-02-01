-- base for tiles for items

local popModelMatrix = cam.PopModelMatrix
local pushModelMatrix = cam.PushModelMatrix
local pushFilterMag = render.PushFilterMag;
local pushFilterMin = render.PushFilterMin;
local popFilterMag = render.PopFilterMag;
local popFilterMin = render.PopFilterMin;

local matrixAngle = Angle(0, 0, 0)
local matrixScale = Vector(0, 0, 0)
local matrixTranslation = Vector(0, 0, 0)


local matrix,x,y,width,height,rad


surface.CreateFont("ES.TileFont",{
	font="Roboto",
	weight=300,
	size=24
})

local PANEL={};
AccessorFunc(PANEL,"vip","VIP",FORCE_BOOL);
AccessorFunc(PANEL,"text","Text",FORCE_STRING);
AccessorFunc(PANEL,"cost","Cost",FORCE_NUMBER);
AccessorFunc(PANEL,"itemtype","Type",FORCE_NUMBER);
function PANEL:Init()
	self:SetVIP(false);
	self:SetText("Name missing");
	self:SetCost(0);
	self:NoClipping(false);
	self.delay=0;
	self.scale=0;
	self.dummy = self:Add("Panel");
	self.dummy.OnCursorEntered = function() self:OnCursorEntered() end
	self.dummy.OnCursorExited = function() self:OnCursorExited() end
	self.dummy.OnMouseReleased = function() self:OnMouseReleased() end
end
function PANEL:PerformLayout()
	local w = self:GetWide();
	local h = self:GetTall();

	if self.icon then
		self.icon:SetPos(w-67,h-67);
	end

	self.dummy:SetSize(w,h)
	self.dummy:SetPos(0,0);
end
function PANEL:Think()
	if self.delay > CurTime() then return end

	self.scale=Lerp(FrameTime()*8,self.scale,self:GetHover() and 1.05 or 1);
end
function PANEL:Paint(w,h)
	pushFilterMag( TEXFILTER.ANISOTROPIC )
	pushFilterMin( TEXFILTER.ANISOTROPIC )

	x,y=self:LocalToScreen(w/2,h/2);
	x,y=(self.scale-1)*-x,(self.scale-1)*-y;

	matrix=Matrix();
	matrix:SetAngles( matrixAngle )
	matrixTranslation.x = x;
	matrixTranslation.y = y;
	matrix:SetTranslation( matrixTranslation )
	matrixScale.x = self.scale;
	matrixScale.y = self.scale;
	matrix:Scale( matrixScale )
 
	-- push matrix
	pushModelMatrix( matrix )

	if not self:GetVIP() then
		surface.SetDrawColor(Color(255,255,255,20));
		surface.DrawRect(2,2,w-4,h-4);	
	end

	
	if self:GetHover() then
		surface.SetDrawColor(ES.GetColorScheme(1));		
		surface.DrawRect(1,1,w-2,h-2);
	else
		surface.SetDrawColor(ES.Color["#1E1E1F"])
		surface.DrawRect(3,3,w-6,h-6);
	end
	

	if self:GetHover() then
		surface.SetDrawColor(Color(0,0,0,150));	
		surface.DrawRect(1,1,w-2,2);
		surface.DrawRect(1,h-3,w-2,2);
		surface.DrawRect(1,3,2,h-6);
		surface.DrawRect(w-3,3,2,h-6);
	end

	local col = ES.Color["#FFFFFF11"];
	if self:GetHover() then
		col = color_white;
	end
	draw.DrawText(string.gsub(self:GetText()," ","\n"),"ES.TileFont",8,5,col);
	if self:GetVIP() then
		draw.SimpleText("VIP","ES.MainMenu.MainElementHeader",w-8,h-42,Color(255,255,255,20),2);
	end		
end
function PANEL:PaintOver(w,h)
	if self:GetCost() >= 0 then
		local text;
		if LocalPlayer():ESHasItem(self:GetText(),self:GetType()) then 
			text="Owned";
		else
			text=tostring(self:GetCost()).." Bananas";
		end

		for i=0,1 do
			draw.SimpleText(text,"ESDefaultBoldBlur",8,h-14-6 + i,color_black);
		end
		draw.SimpleText(text,"ESDefaultBold",8,h-14-6,color_white);
	end

	popModelMatrix()
	popFilterMag( TEXFILTER.ANISOTROPIC )
	popFilterMin( TEXFILTER.ANISOTROPIC )
end
ES.UIAddHoverListener(PANEL);
vgui.Register("ES.ItemTile",PANEL,"Panel");

local PNL = {};
function PNL:Init()
	self.icon = vgui.Create("Spawnicon",self);
	self.icon:SetToolTip(nil)
	self.icon:SetSize(64,64);
	self.BaseClass.Init(self);
end
function PNL:Setup(item)
	self.icon:SetModel(item:GetModel());
end
vgui.Register("ES.ItemTile.Model",PNL,"ES.ItemTile");

local PNL = {};
function PNL:Init()
	self.icon = vgui.Create("DImage",self);
	self.icon:SetToolTip(nil)
	self.icon:SetSize(64,64);
	self.BaseClass.Init(self);
end
function PNL:Setup(item)
	self.icon:SetMaterial(item:GetModel());
end
vgui.Register("ES.ItemTile.Texture",PNL,"ES.ItemTile");