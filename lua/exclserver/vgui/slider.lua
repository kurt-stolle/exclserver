surface.CreateFont( "ESSlidebutton", { 
font = "Calibri", 
weight = 700,
size = 16,
italic = true
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
	self:SetTall(30);

	self.car = vgui.Create("esSliderCar",self);
	self.car:SetPos(0,self:GetTall()-18);
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

	surface.DrawRect(2,self:GetTall()-2-9,self:GetWide()-4,2)
	surface.DrawRect(2,self:GetTall()-2-10,2,4)
	surface.DrawRect(self:GetWide()-2-2,self:GetTall()-2-10,2,4)

	--draw.SimpleText(self:GetValue(),"ESSlidebuttonBlur",self:GetWide()-30,1,COLOR_BLACK,2,0)
	draw.SimpleText(self:GetValue(),"ESSlidebutton",self:GetWide()-18,0,COLOR_WHITE,2,0)

	--draw.SimpleText(self.text,"ESSlidebuttonBlur",30,0,COLOR_BLACK,0,0)
	draw.SimpleText(self.text,"ESSlidebutton",18,0,COLOR_WHITE,0,0)
	
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
		if p < 2 then 
			self.x=2;
			return 
		elseif p > self:GetParent():GetWide()-18 then
			self.x=self:GetParent():GetWide()-18;
			return
		end

		self.x=p;
	else
		self.dragging = false;
	end
end
function PANEL:Paint()
	surface.SetDrawColor(255,255,255,255);
	surface.SetMaterial(car);
	surface.DrawTexturedRect(0,0,self:GetWide(),self:GetWide());
end
ES.UIAddHoverListener(PANEL)
vgui.Register( "esSliderCar", PANEL, "Panel" );