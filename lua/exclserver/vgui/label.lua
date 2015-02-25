-- ESLabel
local PANEL={}
function PANEL:Init()
	self:SetFont("ESDefault")
	self:SetMouseInputEnabled(false)
end
PANEL.ESIsLabel=true;
vgui.Register("esLabel",PANEL,"DLabel")
