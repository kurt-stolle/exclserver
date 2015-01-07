local color_white = ES.Color.White;
local color_gray = ES.Color["#444"];

surface.CreateFont("ES.ButtonFont",{
	font = "Roboto",
	weight = 700,
	size = 16,
})

local tab = ES.UIAddHoverListener({
	Init = function(self)
		self:SetText("UNDEFINED");
		ES.UIInitRippleEffect(self);
		self.alpha=0;
		self.hovercolor=Color(0,0,0);
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
		if self:GetHover() then
			self.hovercolor=table.Copy(ES.GetColorScheme(2));
			self.alpha=Lerp(FrameTime()*10,self.alpha,255);
		else
			self.alpha=Lerp(FrameTime()*10,self.alpha,0);
		end
		self.hovercolor.a=self.alpha;

		draw.RoundedBox(2,0,0,w,h,Color(0,0,0,80));
		draw.RoundedBox(2,1,1,w-2,h-2,color_white);
		draw.RoundedBox(2,1,1,w-2,h-2,self.hovercolor);

		ES.UIDrawRippleEffect(self,w,h);

		draw.SimpleText(self:GetText(),"ES.ButtonFont",w/2,h/2,self:GetHover() and color_white or color_gray,1,1);
	end,
});
AccessorFunc(tab,"Text","Text",FORCE_STRING);

vgui.Register("esButton",tab,"Panel");