function ES.UIAddHoverListener(tab)
	AccessorFunc(tab,"hover","Hover",FORCE_BOOL);
	tab.OnCursorEntered = function(self)
		self:SetHover(true);
	end
	tab.OnCursorExited = function(self)
		self:SetHover(false);
	end

	return tab;
end

-- The ripple effect
local matRipple = Material("exclserver/vgui/ripple.png");
function ES.UIInitRippleEffect(tab)
	tab.rippleColor = Color(255,255,255,0);
	tab.rippleScale = 1;
	tab.cursorPos_x = 0;
	tab.cursorPos_y = 0;
end
function ES.UIMakeRippleEffect(tab)
	if not tab.rippleColor or not tab.rippleScale or not tab.cursorPos_x or not tab.cursorPos_y then return	end

	tab.rippleScale = 0;
	tab.cursorPos_x, tab.cursorPos_y = tab:CursorPos();
end
function ES.UIDrawRippleEffect(tab,w,h)
	if not tab.rippleColor or not tab.rippleScale or not tab.cursorPos_x or not tab.cursorPos_y then return	end

	tab.rippleScale = Lerp(FrameTime()*4,tab.rippleScale,1);

	if tab.rippleScale > 0 and tab.rippleScale < 1 then
		tab.cursorPos_x = Lerp(FrameTime()*1.5,tab.cursorPos_x,w/2);
		tab.cursorPos_y = Lerp(FrameTime()*1.5,tab.cursorPos_y,h/2);
		tab.rippleColor.a = 255 - 255*tab.rippleScale;

		surface.SetDrawColor(tab.rippleColor);
		surface.SetMaterial(matRipple);
		surface.DrawTexturedRectRotated(tab.cursorPos_x,tab.cursorPos_y,128*tab.rippleScale,128*tab.rippleScale,0);
	end
end