-- ESLabel
local lineHeight=0
local text=""
local function drawText(xOffset,yOffset)
	local curY = 0 + yOffset

	for str in string.gmatch( text, "[^\n]*" ) do
		if #str > 0 then
			surface.SetTextPos( xOffset,curY );
			surface.DrawText(str)
		else--newline
			curY = curY + lineHeight
		end
	end
end


local PANEL={}
AccessorFunc(PANEL,"_text","Text",FORCE_STRING)
AccessorFunc(PANEL,"_color","Color")
AccessorFunc(PANEL,"_shadowEnabled","Shadow",FORCE_NUMBER)
function PANEL:Init()
	self:SetText("")
	self:SetColor(ES.Color.White)
	self:SetShadow(0)
	self:SetMouseInputEnabled(false)
	self:NoClipping(false)

	self._lineHeight=0
end
function PANEL:GetFont()
	return self._font or "ESDefault"
end
function PANEL:SetLineHeight(x)
	self._lineHeight=x
end
function PANEL:SetFont(font)
	if type(font) ~= "string" then
		font="ESDefault"
	end

	self._font=font
	surface.SetFont(font)
	local _
	_,self._lineHeight=surface.GetTextSize("ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()_+")
end
function PANEL:SizeToContents()

	surface.SetFont(self:GetFont());
	self:SetSize(surface.GetTextSize(self:GetText()));

end
function PANEL:Paint()
	text=self:GetText() or ""
	lineHeight=self._lineHeight or 0

	if self:GetShadow() >= 1 then
		surface.SetTextColor(ES.Color.Black)
		surface.SetFont(self:GetFont()..".Shadow")
		for i=1,self:GetShadow()+1 do
			drawText(0,0)
		end

		surface.SetFont(self:GetFont())
		surface.SetTextColor(ES.Color["#000000DF"])
		drawText(1,1)
	else
		surface.SetFont(self:GetFont())
	end

	surface.SetTextColor(self:GetColor())

	drawText(0,0)

end
PANEL.ESIsLabel=true;
vgui.Register("esLabel",PANEL,"Panel")
