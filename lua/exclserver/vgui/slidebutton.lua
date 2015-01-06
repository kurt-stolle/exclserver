surface.CreateFont( "ESSlidebuttonf", { 
font = "Roboto", 
size = 14 } 
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
local circle = generatePoly(10,20,10,64);
local circleC = generatePoly(10,20,9,64);
local car = Material("icon16/car.png");


local PANEL = {};
function PANEL:Init()
	self.car = vgui.Create("esSlideButtonCar",self);
	self.car:SetPos(0,3);
	self.car:SetSize(20,25);
	self.Text = "NOT SET"
end
function PANEL:Paint()
	if not self.car or not self.car:IsValid() then return end

	local circleB = generatePoly(self:GetWide()-10,20,10,64);
	local circleD= generatePoly(self:GetWide()-10,20,9,64);

	surface.SetDrawColor(0,0,0,200);
	surface.SetTexture(0);

	surface.DrawPoly(circle);
	surface.DrawPoly(circleB);
	surface.DrawRect(10,20,self:GetWide()-20,2)

	surface.SetDrawColor(Color(0,138,184));
	surface.DrawPoly(circleD);
	surface.SetDrawColor(Color(184,46,0));
	surface.DrawPoly(circleC);

	local x= self.car:GetPos();
	local alpha = (255-(x/(self:GetWide()/2/2))*255);
	draw.SimpleText(self.Text,"ESSlidebuttonf",self:GetWide()/2,0,Color(255,255,255,alpha),1,0)
	if self.PaintHook then
		self.PaintHook()
	end
end
vgui.Register( "esSlideButton", PANEL, "Panel" );

local PANEL = {};
function PANEL:Init()
	self.realPos = 0;
	self.OnDone = function() self:Remove() end;
end
function PANEL:OnMousePressed()
	local x = self:GetPos();
	self.dragging = true;
	self.startPos = gui.MousePos()+x;
end
function PANEL:Think()
	if not self.startPos then return end
	local p = gui.MousePos();
	p = p - self.startPos;
	if self.dragging and (input.IsMouseDown(MOUSE_LEFT) or input.IsMouseDown(MOUSE_RIGHT)) then
		if p < 0 then 
			self:SetPos(0,3);
			return 
		elseif p > self:GetParent():GetWide()-19 then
			self:SetPos(self:GetParent():GetWide()-19,3)
			return
		end

		self:SetPos(p,3)
	elseif p > self:GetParent():GetWide()-19 and self.dragging then
			self.OnDone()
			return
	else
		local x = self:GetPos();
		self:SetPos(Lerp(0.05,x,0),3);
		self.dragging = false;
	end
end
function PANEL:Paint()
	surface.SetDrawColor(255,255,255,255);
	surface.SetMaterial(car);
	surface.DrawTexturedRect(0,0,self:GetWide(),self:GetWide());
end
vgui.Register( "esSlideButtonCar", PANEL, "Panel" );