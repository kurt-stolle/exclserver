-- Buttons
ES.CreateFont( "ES.ToggleButton", { 
font = "Roboto", 
size = 16,
weight=700 } 
)
ES.CreateFont( "ES.ToggleButton.Shadow", { 
font = "Roboto", 
size = 16,
weight=700,
blursize=2 } 
)

local BUTTON = {}
function BUTTON:Init()
	self.DoClick = function() end
	self.Text = "Meow"
	self.Toggled = true
	self.moveX = 0
	self.hoverAlpha = 0
	self.HideButton = false
end
function BUTTON:OnMouseReleased()
	if self.HideButton then return end

	self.Toggled = not self.Toggled
	self:DoClick()
end
function BUTTON:GetChecked()
	return self.Toggled
end
function BUTTON:SetChecked(b)
	self.Toggled = b
end
function BUTTON:SetText( str )
	if self.HideButton then return end

	self.Text = str
end
function BUTTON:Paint(w,h)
	draw.SimpleText(self.Text, "ES.ToggleButton.Shadow", (h*2) + 8, (h/2), ES.Color.Black, 0, TEXT_ALIGN_CENTER)
	draw.SimpleText(self.Text, "ES.ToggleButton", (h*2) + 8, (h/2), ES.Color.White, 0, TEXT_ALIGN_CENTER)

	if self.HideButton then return end
	
	-- draw the button thingy
	if self.Toggled then
		self.moveX = Lerp(FrameTime()*18,self.moveX,0)
	else
		self.moveX = Lerp(FrameTime()*18,self.moveX,h+1)		
	end


	local x,y=1,1



	draw.RoundedBox(2,x-1,y-1,(h)*2+2,h + 2, Color(0,0,0,200))
	
	draw.SimpleText("I","ESDefaultBold",x+(h)/2 + (h-2), y+(h-2)/2,ES.Color.White,1,1)
	draw.SimpleText("O","ESDefaultBold",x+(h)/2, y+(h-2)/2,ES.Color.White,1,1)

	draw.RoundedBox(2,x+self.moveX,y,h-2,h-2, Color(213,213,213))


end
vgui.Register( "esToggleButton", BUTTON, "Panel" )