surface.CreateFont( "ESSlidebutton", { 
font = "Calibri", 
weight = 700,
size = 14,
--italic = true
 } 
)
surface.CreateFont( "ESSlidebuttonBlur", { 
font = "Calibri", 
weight = 700,
size = 14,
blursize = 2,
--italic = true
 } 
)

local sin,cos,rad = math.sin,math.cos,math.rad; --Only needed when you constantly calculate a new polygon, it slightly increases the speed.
local function generatePoly(x,y,radius,quality)
    local circle = {};
    local tmp = 0;
    for i=1,quality do
        tmp = rad(i*360)/quality
        circle[i] = {x = x + cos(tmp)*radius,y = y + sin(tmp)*radius};
    end
    return circle;
end
local circle = generatePoly(10,20,10,50);
local circleC = generatePoly(10,20,9,50);
local car = Material("exclserver/vgui/sliderhandle.png");


local PANEL = {};
function PANEL:Init()
	self.car = vgui.Create("esSliderCar",self);
	self.car:SetPos(0,3);
	self.car:SetSize(16,16);
	self.text = "x = ";
	self.max = 100;
	self.min = -100;
end
function PANEL:SetValue(n)
	n = math.Clamp(n,self.min,self.max);
	local s = math.abs(self.max) + math.abs(self.min);
	local x = math.abs(self.min) + math.abs(n);
	self.car.x = (x/s) * (self:GetWide()-self.car:GetWide());
end
function PANEL:GetValue()
	return (self.min + (self.car.x / (self:GetWide()-19))*(self.max - self.min ));
end
function PANEL:Paint()
	if not self.car or not self.car:IsValid() or not self.min or not self.max or not self.text then return end

	local circleB = generatePoly(self:GetWide()-10,20,10,50);
	local circleD= generatePoly(self:GetWide()-10,20,9,50);

	surface.SetDrawColor(0,0,0,200);
	surface.SetTexture(0);

	surface.DrawPoly(circle);
	surface.DrawPoly(circleB);
	surface.DrawRect(10,20,self:GetWide()-20,2)

	surface.SetDrawColor(Color(0,138,184));
	surface.DrawPoly(circleD);
	surface.SetDrawColor(Color(184,46,0));
	surface.DrawPoly(circleC);

	draw.SimpleText(string.Left(tostring(self.min + (self.car.x / (self:GetWide()-19))*(self.max - self.min )),5),"ESSlidebuttonBlur",self:GetWide()-30,0,self.car.dragging and COLOR_WHITE or COLOR_BLACK,2,0)
	draw.SimpleText(string.Left(tostring(self.min + (self.car.x / (self:GetWide()-19))*(self.max - self.min )),5),"ESSlidebutton",self:GetWide()-30,0,COLOR_WHITE,2,0)

	draw.SimpleText(self.text,"ESSlidebuttonBlur",30,0,COLOR_BLACK,0,0)
	draw.SimpleText(self.text,"ESSlidebutton",30,0,COLOR_WHITE,0,0)
	
	if self.PaintHook then
		self.PaintHook()
	end
end
vgui.Register( "esSlider", PANEL, "Panel" );

local PANEL = {};
function PANEL:Init()
	self.realPos = 0;
	self.OnDone = function() self:Remove() end;
	self.original = 0;
end
function PANEL:OnMousePressed()
	self.dragging = true;
	self.original = self.x;
	self.startPos = gui.MousePos()--+x;
end
function PANEL:Think()
	if not self.startPos then return end
	local p = gui.MousePos();
	p = self.original + (p - self.startPos);
	if self.dragging and (input.IsMouseDown(MOUSE_LEFT) or input.IsMouseDown(MOUSE_RIGHT)) then
		if p < 0 then 
			self:SetPos(0,3);
			return 
		elseif p > self:GetParent():GetWide()-19 then
			self:SetPos(self:GetParent():GetWide()-19,3)
			return
		end

		self:SetPos(p,3)
	else
		self.dragging = false;
	end
end
function PANEL:Paint()
	surface.SetDrawColor(255,255,255,255);
	surface.SetMaterial(car);
	surface.DrawTexturedRect(0,0,self:GetWide(),self:GetWide());
end
vgui.Register( "esSliderCar", PANEL, "Panel" );