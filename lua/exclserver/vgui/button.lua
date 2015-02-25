local color_white = ES.Color.White
local color_gray = ES.Color["#DDD"]

ES.CreateFont("ES.ButtonFont",{
	font = "Roboto",
	weight = 700,
	size = 16,
})

local tab = ES.UIAddHoverListener({
	Init = function(self)
		self:SetText("UNDEFINED")
		ES.UIInitRippleEffect(self)
		self.alpha=0
		self.hovercolor=Color(0,0,0)
	end,
	OnMousePressed = function(self)
		ES.UIMakeRippleEffect(self)
	end,
	OnMouseReleased = function(self)
		self:DoClick()
	end,
	SetDoClick = function(self,fn)
		self.DoClick = fn
	end,
	Paint = function(self,w,h)
		draw.RoundedBox(2,0,0,w,h,ES.Color.Black)
		draw.RoundedBox(2,1,1,w-2,h-2,ES.Color["#151515"])

		surface.SetDrawColor(ES.Color["#FFFFFF02"])
		surface.DrawLine(1,1,w-2,1)
		surface.DrawLine(1,h-2,w-2,h-2)
		surface.DrawLine(1,2,1,h-3)
		surface.DrawLine(w-2,2,w-2,h-3)

		ES.UIDrawRippleEffect(self,w,h)

		draw.SimpleText(self:GetText(),"ES.ButtonFont",w/2,h/2,self:GetHover() and color_white or color_gray,1,1)
	end,
})
AccessorFunc(tab,"Text","Text",FORCE_STRING)

vgui.Register("esButton",tab,"Panel")