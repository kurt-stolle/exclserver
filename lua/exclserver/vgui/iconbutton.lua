-- Buttons
COLOR_WHITE = COLOR_WHITE or Color(255,255,255);
local BUTTON = {}
function BUTTON:Init()
	self.Hover = false;
	self.DoClick = function() end
	self.Mat = false;
end
function BUTTON:OnMouseReleased()
	self:DoClick();
end
function BUTTON:SetIcon( mat )
	self.Mat = mat;
end
function BUTTON:Paint(w,h)
	if not self.Mat then return end
	
	surface.SetMaterial(self.Mat)
	surface.SetDrawColor(COLOR_WHITE);
	surface.DrawTexturedRect(0,0,w,h);
end
ES.UIAddHoverListener(BUTTON);
vgui.Register( "esIconButton", BUTTON, "Panel" );