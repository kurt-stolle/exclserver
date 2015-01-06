-- Buttons
--[[[
surface.CreateFont("ESButtonFont",{
	font = "Roboto",
	size = 14,
	weight = 700,
})
surface.CreateFont("ESButtonFontBlur",{
	font = "Roboto",
	size = 14,
	blursize = 2,
	weight = 700,
})

local BUTTON = {}
function BUTTON:Init()
	self.Hover = false;
	self.DoClick = function() end
	self.Text = "Kittens Meow";
	self.Right = false;
	self.Evil = false;
	self.FadeGlow = 0;
	self.HoverAlpha = 0;
end
function BUTTON:OnCursorEntered()
	self.Hover = true;
end
function BUTTON:OnCursorExited()
	self.Hover = false;
end
function BUTTON:OnMouseReleased()
	self:DoClick();
	self.FadeGlow = 255;
end
function BUTTON:SetText( str )
	self.Text = str;
end
function BUTTON:SetDoClick(func)
	self.DoClick = func;
	
end
function BUTTON:Paint(w,h)
	local a,b,c = ES.GetColorScheme();
	local d = table.Copy(a);
	local e = table.Copy(c);
	e.a = 240;

	self.HoverAlpha = Lerp(0.2,self.HoverAlpha,self.Hover and 255 or 0)

	d.a = self.HoverAlpha;
	draw.RoundedBox(2,0,0,w,h,Color(50,50,50,255))
	draw.RoundedBox(2,1,1,w-2,h-2,e) 
	draw.RoundedBox(2,0,0,w,h,d) 

	surface.SetDrawColor(Color(0,0,0,140));
	surface.DrawRect(0,0,w,3);
	surface.DrawRect(0,h-3,w,3);
	surface.DrawRect(0,3,3,h-6);
	surface.DrawRect(w-3,3,3,h-6)

	draw.RoundedBox(4,2,(h)/2,w-4,(h-6)/2,Color(0,0,0,10));

	draw.SimpleText(self.Text, "ESButtonFontBlur", self:GetWide()/2, (self:GetTall()/2), COLOR_BLACK, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	self.FadeGlow = Lerp(0.1,self.FadeGlow,0);
	if self.FadeGlow > 1 then
		draw.SimpleText(self.Text, "ESButtonFontBlur", self:GetWide()/2, (self:GetTall()/2), Color(255,255,255,self.FadeGlow), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	draw.SimpleText(self.Text, "ESButtonFont", self:GetWide()/2, (self:GetTall()/2), COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
vgui.Register( "esButton", BUTTON, "Panel" );--]]

local color_white = ES.Color.White;
local color_gray = ES.Color["#888"];
local color_lightgray = ES.Color["#EAEAEA"];

surface.CreateFont("ES.ButtonFont",{
	font = "Roboto",
	weight = 500,
	size = 18,
})

local tab = ES.UIAddHoverListener({
	Init = function(self)
		self:SetText("UNDEFINED");
		ES.UIInitRippleEffect(self);
	end,
	OnMousePressed = function(self)
		ES.UIMakeRippleEffect(self);
	end,
	OnMouseReleased = function(self)
		self:DoClick();
	end,
	SetDoClick = function(self,fn)
		self.DoClick = fn;
	end,
	Paint = function(self,w,h)
		draw.RoundedBox(4,0,0,w,h,Color(0,0,0,80));
		draw.RoundedBox(4,1,1,w-2,h-2,self:GetHover() and color_lightgray or color_white);

		ES.UIDrawRippleEffect(self,w,h);

		draw.SimpleText(self:GetText(),"ES.ButtonFont",w/2,h/2,color_gray,1,1);
	end,
});
AccessorFunc(tab,"Text","Text",FORCE_STRING);

vgui.Register("esButton",tab,"Panel");