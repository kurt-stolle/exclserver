ES.CreateFont( "ESSlidebutton", { 
	font = ES.Font, 
	weight = 700,
	size = 16,
	italic = true
})

local car = Material("exclserver/vgui/sliderhandle.png")
local PANEL= {}
AccessorFunc(PANEL,"precision","Precision",FORCE_NUMBER)
function PANEL:Init()
	self:SetTall(30)

	self:SetPrecision(1)

	self.car = vgui.Create("esSliderCar",self)
	self.car:SetPos(0,self:GetTall()-18)
	self.car:SetSize(16,16)
	self.text = "x = "
	self.max = 100
	self.min = -100
end
function PANEL:SetValue(n)
	n = math.Clamp(n,self.min,self.max)
	local s = math.abs(self.max) + math.abs(self.min)
	local x = math.abs(self.min) + math.abs(n)
	self.car.x = (x/s) * ((self:GetWide()-4)-self.car:GetWide()) + 2

	self.valueSet=n
end
function PANEL:Think()
	local n=self.valueSet
	--if not n then return end
	local s = math.abs(self.max) + math.abs(self.min)
	local x = math.abs(self.min) + math.abs(n)
	self.car.x = (x/s) * ((self:GetWide()-4)-self.car:GetWide()) + 2
end
function PANEL:GetValue()
	if self.valueSet then
		return self.valueSet
	end



	local value=(self.min + ((self.car.x-2) / (self:GetWide()-4-self.car:GetWide()))*( math.abs(self.max) + math.abs(self.min) ))

	value=tostring(value)

	local pos=string.find( value, ".", 0, true )

	local afterDot,beforeDot
	if pos and pos>1 then
		afterDot=string.Right(value,string.len(value)-pos).."000000000"
		beforeDot=string.Left(value,pos-1)
	else
		afterDot="0000000000"
		beforeDot=value
	end

	if self:GetPrecision() == 0 then
		value=math.Round(tonumber(value))
	else
		value=math.Round(tonumber(beforeDot..string.Left(afterDot,self:GetPrecision()).."."..string.Right(afterDot,string.len(afterDot)-self:GetPrecision())))
		value=beforeDot.."."..string.Right(value,self:GetPrecision())
	end

	value=tonumber(value)

	return value
end
function PANEL:Paint()
	if not self.car or not self.car:IsValid() or not self.min or not self.max or not self.text then return end

	local n=self.valueSet
	if n then
		local s = math.abs(self.max) + math.abs(self.min)
		local x = math.abs(self.min) + math.abs(n)
		self.car.x = (x/s) * ((self:GetWide()-4)-self.car:GetWide()) + 2
	end

	surface.SetDrawColor(0,0,0,200)
	surface.SetTexture(0)

	surface.DrawRect(2,self:GetTall()-2-9,self:GetWide()-4,2)
	surface.DrawRect(2,self:GetTall()-2-10,2,4)
	surface.DrawRect(self:GetWide()-2-2,self:GetTall()-2-10,2,4)

	--draw.SimpleText(self:GetValue(),"ESSlidebuttonBlur",self:GetWide()-30,1,COLOR_BLACK,2,0)
	draw.SimpleText(self:GetValue(),"ESSlidebutton",self:GetWide()-18,0,COLOR_WHITE,2,0)

	--draw.SimpleText(self.text,"ESSlidebuttonBlur",30,0,COLOR_BLACK,0,0)
	draw.SimpleText(self.text,"ESSlidebutton",18,0,COLOR_WHITE,0,0)
	
	if self.PaintHook then
		self.PaintHook()
	end
end
vgui.Register( "esSlider", PANEL, "Panel" )

local PANEL = {}
function PANEL:Init()
	self.realPos = 0
	self.OnDone = function() self:Remove() end
	self.original = 0
end
function PANEL:OnMousePressed()
	self.dragging = true
	self.original = self.x
	self.startPos = gui.MousePos()--+x
	self:GetParent().valueSet=nil
end
function PANEL:Think()
	if not self.startPos then return end
	local p = gui.MousePos()
	p = self.original + (p - self.startPos)
	if self.dragging and (input.IsMouseDown(MOUSE_LEFT) or input.IsMouseDown(MOUSE_RIGHT)) then
		if p < 2 then 
			self.x=2
			return 
		elseif p > self:GetParent():GetWide()-18 then
			self.x=self:GetParent():GetWide()-18
			return
		end

		self.x=p
	else
		self.dragging = false
	end
end
function PANEL:Paint()
	surface.SetDrawColor(ES.Color.White)
	surface.SetMaterial(car)
	surface.DrawTexturedRect(0,0,self:GetWide(),self:GetWide())
end
ES.UIAddHoverListener(PANEL)
vgui.Register( "esSliderCar", PANEL, "Panel" )