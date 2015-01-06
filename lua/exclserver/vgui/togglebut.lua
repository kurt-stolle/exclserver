-- Buttons
surface.CreateFont( "ESToggleButtonArrow", { 
font = "Helvetica", 
size = 18 } 
)

local BUTTON = {}
function BUTTON:Init()
	self.Hover = false;
	self.DoClick = function() end
	self.Text = "Meow";
	self.Toggled = true;
	self.moveX = 0;
	self.hoverAlpha = 0;
	self.HideButton = false;
end
function BUTTON:OnCursorEntered()
	if self.HideButton then return end
	self.Hover = true;
end
function BUTTON:OnCursorExited()
	if self.HideButton then return end
	self.Hover = false;
end
function BUTTON:OnMouseReleased()
	if self.HideButton then return end

	self.Toggled = not self.Toggled;
	self:DoClick();
end
function BUTTON:GetChecked()
	return self.Toggled;
end
function BUTTON:SetChecked(b)
	self.Toggled = b;
end
function BUTTON:SetText( str )
	if self.HideButton then return end

	self.Text = str;
end
function BUTTON:SetDoClick(func)
	if self.HideButton then return end

	self.DoClick = func;
end
function BUTTON:Paint()
	draw.RoundedBox(4,0,0,self:GetWide(), self:GetTall(), Color(0,0,0,200))
	draw.RoundedBox(4,1,1,self:GetWide()-2, self:GetTall()-2, Color(230,230,230))
	
	draw.SimpleText(self.Text, "ESDefault", 5, (self:GetTall()/2)-1, Color(0,0,0), 0, TEXT_ALIGN_CENTER)
	
	if self.HideButton then return end
	
	draw.RoundedBox(2,self:GetWide()-(self:GetTall()*2-4)-2,2,self:GetTall()*2-4, self:GetTall()-4, Color(0,0,0,200))

	-- draw the button thingy
	if self.Toggled then
		self.moveX = Lerp(0.1,self.moveX,0)
	else
		self.moveX = Lerp(0.1,self.moveX,self:GetTall()-3);		
	end

	draw.RoundedBox(2,self:GetWide()-(self:GetTall()*2-4)-1,3,self:GetTall()*2-6, self:GetTall()-6, Color(0,138,184))
	draw.RoundedBox(0,self:GetWide()-(self:GetTall()*2-4)-1+4,3,self.moveX-4, self:GetTall()-6, Color(184,46,0))
	draw.RoundedBoxEx(0,self:GetWide()-(self:GetTall()*2-4)-1,3,4, self:GetTall()-6, Color(184,46,0),true,false,true,false)

	draw.RoundedBox(2,self:GetWide()-(self:GetTall()*2-4)-1+self.moveX,3,(self:GetTall()*2-6)/2, self:GetTall()-6, Color(213,213,213))
	draw.RoundedBox(2,self:GetWide()-(self:GetTall()*2-4)+self.moveX,4,(self:GetTall()*2-6)/2-2, (self:GetTall()-6)/2-2, Color(255,255,255,100))

	if self.Hover then
		self.hoverAlpha = Lerp(0.05,self.hoverAlpha,255)
	else
		self.hoverAlpha = Lerp(0.02,self.hoverAlpha,0);		
	end	
	if self.Toggled then
		draw.SimpleText(">", "ESToggleButtonArrow", self:GetWide()-(self:GetTall()*2-4)-1+self.moveX+(self:GetTall()-6)/2,self:GetTall()/2-1, Color(0,0,0,self.hoverAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		draw.SimpleText("<", "ESToggleButtonArrow", self:GetWide()-(self:GetTall()*2-4)-1+self.moveX+(self:GetTall()-6)/2,self:GetTall()/2-1, Color(0,0,0,self.hoverAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end
vgui.Register( "esToggleButton", BUTTON, "Panel" );