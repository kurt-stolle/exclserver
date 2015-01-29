-- ESLabel

local PANEL={}
function PANEL:Init()
	self:SetFont("ESDefault");
	self:SetMouseInputEnabled(false);
end
vgui.Register("esLabel",PANEL,"DLabel"); 