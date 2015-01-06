-- Buttons
COLOR_WHITE = COLOR_WHITE or Color(255,255,255);
local BUTTON = {}
function BUTTON:Init()
	self.Hover = false;
	self.DoClick = function() end
	self.Mat = false;
end
function BUTTON:OnCursorEntered()
	self.Hover = true;
end
function BUTTON:OnCursorExited()
	self.Hover = false;
end
function BUTTON:OnMouseReleased()
	self:DoClick();
end
function BUTTON:SetIcon( mat )
	self.Mat = mat;
end
function BUTTON:SetDoClick(func)
	self.DoClick = func;
end
function BUTTON:Paint(w,h)
	if not self.Mat then return end
	
	surface.SetMaterial(self.Mat)
	surface.SetDrawColor(COLOR_WHITE);
	surface.DrawTexturedRect(0,0,w,h);
end
vgui.Register( "esIconButton", BUTTON, "Panel" );