local PANEL={}
function PANEL:Init()
	self.BaseClass.Init(self)

	self:SetDrawBorder( false )
	self:SetDrawBackground( false )
	self:SetEnterAllowed( true )
	self:SetMultiline(false);
	self:SetUpdateOnType( false )
	self:SetNumeric( false )
	self:SetAllowNonAsciiCharacters( false )
	self:SetTall(24);
	self:SetFont("ESDefault")
	self:SetTextColor(ES.Color.White)
end
function PANEL:SetValue( strValue )
	local CaretPos = self:GetCaretPos()

	self:SetText( strValue )
	self:UpdateConvarValue()
	self:OnValueChange( strValue )
	self:SetCaretPos( CaretPos )

end
function PANEL:OnEnter() end
function PANEL:Paint(w,h)
	surface.SetDrawColor(ES.GetColorScheme(1));
	surface.DrawRect(0,h-2,w,2)
	surface.DrawRect(0,h-6,2,4)
	surface.DrawRect(w-2,h-6,2,4)

	self.BaseClass.Paint(self,w,h)

	--[[local xCaret=string.Left(self:GetValue(),self:GetCaretPos())

	surface.SetFont("ESDefault")
	xCaret=surface.GetTextSize(xCaret)

	surface.SetDrawColor(ES.Color.White);
	surface.DrawRect(xCaret,0,2,h);]]
end
vgui.Register("esTextEntry",PANEL,"DTextEntry")