-- cl_fonts
surface.CreateFont( "ESDefaultSmall.Shadow", { 
	font = "Calibri", 
	size = 13,
	weight = 500,
	blursize = 2
})
surface.CreateFont( "ESDefaultSmall", { 
	font = "Calibri", 
	size = 13,
	weight = 500
})
surface.CreateFont( "ESDefault", { 
	font = "Calibri", 
	size = 15,
	weight = 500
})
surface.CreateFont( "ESDefault.Shadow", { 
	font = "Calibri", 
	size = 15,
	weight = 500,
	blursize = 2
})
surface.CreateFont( "ESDefaultBold", { 
	font = "Calibri", 
	size = 15,
	weight = 800
})
surface.CreateFont( "ESDefaultBold.Shadow", { 
	font = "Calibri", 
	size = 15,
	weight = 800,
	blursize = 2
})
surface.CreateFont( "ESDefaultBig", {
	font = "Calibri",
	size=27,
	weight=400
})

function ES.UIAddHoverListener(panel)
	AccessorFunc(panel,"hover","Hover",FORCE_BOOL)
	panel.OnCursorEntered = function(self)
		self:SetHover(true)
		self:SetCursor("hand")
	end
	panel.OnCursorExited = function(self)
		self:SetHover(false)
		self:SetCursor("arrow")
	end

	return panel
end

-- The ripple effect
local matRipple = Material("exclserver/vgui/ripple.png")
function ES.UIInitRippleEffect(tab)
	tab.rippleColor = Color(255,255,255,0)
	tab.rippleScale = 1
	tab.cursorPos_x = 0
	tab.cursorPos_y = 0
end
function ES.UIMakeRippleEffect(tab)
	if not tab.rippleColor or not tab.rippleScale or not tab.cursorPos_x or not tab.cursorPos_y then return	end

	tab.rippleScale = 0
	tab.cursorPos_x, tab.cursorPos_y = tab:CursorPos()
end
function ES.UIDrawRippleEffect(tab,w,h)
	if not tab.rippleColor or not tab.rippleScale or not tab.cursorPos_x or not tab.cursorPos_y then return	end

	tab.rippleScale = Lerp(FrameTime()*3,tab.rippleScale,1)

	if tab.rippleScale > 0 and tab.rippleScale < 1 then
		tab.cursorPos_x = Lerp(FrameTime()*0.1,tab.cursorPos_x,w/2)
		tab.cursorPos_y = Lerp(FrameTime()*0.1,tab.cursorPos_y,h/2)
		tab.rippleColor.a = 255 - 255*tab.rippleScale

		surface.SetDrawColor(tab.rippleColor)
		surface.SetMaterial(matRipple)
		surface.DrawTexturedRectRotated(tab.cursorPos_x,tab.cursorPos_y,128*tab.rippleScale,128*tab.rippleScale,0)
	end
end

-- Disable ugly progress thingy
hook.Remove( "SpawniconGenerated", "SpawniconGenerated")