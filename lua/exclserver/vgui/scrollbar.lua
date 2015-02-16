--scrollbar
local PANEL = {}
PANEL.scrollTbl = {}
PANEL.scrollMax = 0
PANEL.setUp = false
PANEL.barH = 10
PANEL.dragging = false
PANEL.barY = 0

PANEL.calcScrolled = 0

local function setupMouseScroll(p,f)
	function p:OnMouseWheeled(mc)
		y= mc
		if f.YPassed then
			if f.overY > y then
				f.YPassed = false
			else
				return
			end
		elseif f.YPrePassed then
			if f.overY < y then
				f.YPrePassed = false
			else
				return
			end
		end	
		f.startDrag = y
		f.barY = f.barY + (y-f.startDrag)
		

		if f.barY > f:GetTall()-(f:GetWide()+f.barH) then
			f.barY = f:GetTall()-(f:GetWide()+f.barH)
			f.YPassed = true
			f.overY = y
		elseif f.barY < f:GetWide() then
			f.barY = f:GetWide()
			f.YPrePassed = true
			f.overY = y
		end
		f.scrollBar:SetPos(1,f.barY)

		f:Scroll(   -(((f.barY-f:GetWide()) / (f:GetTall()-(f:GetWide()+f:GetWide()+f.barH))) *  (f.scrollMax))   )
	end
end
function PANEL:Init()
	timer.Simple(0,function()
		if IsValid(self) and self:GetParent() and self:GetParent():GetChildren() then
			for k,v in pairs(self:GetParent():GetChildren()) do
				setupMouseScroll(v,self)
				if v:GetChildren() and v:GetChildren()[1] then
					for _,h in pairs(v:GetChildren()) do
						setupMouseScroll(h,self)
					end
				end
			end
		end
	end)
end

function PANEL:Scroll(n)
	for k,v in pairs(self.scrollTbl)do
		if v == self or !IsValid(v) then table.remove(self.scrollTbl,k) return end
		local x,y = v:GetPos() 
		if not v.originalPos then
			v.originalPos = y
		end
		v:SetPos(x, v.originalPos+n)
	end
end
function PANEL:SetUp()
	self.scrollTbl = self:GetParent():GetChildren()
	local hMax = 0
	for k,v in pairs(self.scrollTbl)do
		if v == self then
			table.remove(self.scrollTbl,k)
		else
			local _,y = v:GetPos()
			local h = v:GetTall()
			v.originalPos = y
			if y+h > hMax then
				hMax = y+h+5
			end
			if (y+h+5)-self:GetParent():GetTall() > self.scrollMax then
				self.scrollMax = (y+h+5)-self:GetParent():GetTall()
			end
		end
	end
	self.setUp = true
	self.barH = (self:GetParent():GetTall()/hMax)*(self:GetTall()-(self:GetWide()*2))
	self.barY = self:GetWide()
	self.scrollBar = vgui.Create("esScrollbarScrollButton",self)
	self.scrollBar:SetPos(1,self.barY)
	self.scrollBar:SetSize(self:GetWide()-2,self.barH)
end

PANEL.overY = 0
PANEL.YPassed = false
PANEL.YPrePassed = false
function PANEL:Think()
	if not self.dragging or not (input.IsMouseDown(MOUSE_LEFT) or input.IsMouseDown(MOUSE_RIGHT)) then self.dragging = false return end
	local _,y = gui.MousePos()

	if self.YPassed then
		if self.overY > y then
			self.YPassed = false
		else
			return
		end
	elseif self.YPrePassed then
		if self.overY < y then
			self.YPrePassed = false
		else
			return
		end
	end	

	self.barY = self.barY + (y-self.startDrag)
	self.startDrag = y

	if self.barY > self:GetTall()-(self:GetWide()+self.barH) then
		self.barY = self:GetTall()-(self:GetWide()+self.barH)
		self.YPassed = true
		self.overY = y
	elseif self.barY < self:GetWide() then
		self.barY = self:GetWide()
		self.YPrePassed = true
		self.overY = y
	end
	self.scrollBar:SetPos(1,self.barY)

	self:Scroll(   -(((self.barY-self:GetWide()) / (self:GetTall()-(self:GetWide()+self:GetWide()+self.barH))) *  (self.scrollMax))   )
end
function PANEL:Paint()
	if not self.setUp then return end

	-- drawing
	local a,b,c = ES.GetColorScheme()

	draw.RoundedBox(0,0,0,self:GetWide(),self:GetTall(),Color(0,0,0,240))

	draw.RoundedBox(0,1,1,self:GetWide()-2,self:GetWide()-2,Color(213,213,213))
	draw.RoundedBox(2,2,2,self:GetWide()-4,(self:GetWide()/2)-2,Color(255,255,255,100))
	draw.SimpleText("+","ESDefaultBold",self:GetWide()/2,self:GetWide()/2 - 1,COLOR_BLACK,1,1,1,Color(255,255,255,10))


	draw.RoundedBox(0,1,self.barY,self:GetWide()-2,self.barH,Color(213,213,213))
	if self.dragging or self.scrollBar.hover then
		local d = table.Copy(a)
		d.a = 200
		draw.RoundedBox(2,2,self.barY+1,self:GetWide()-4,self.barH-2,d)
	end

	draw.RoundedBox(0,1,self:GetTall()-self:GetWide()+1,self:GetWide()-2,self:GetWide()-2,Color(213,213,213))
	draw.RoundedBox(2,2,self:GetTall()-self:GetWide()+2,self:GetWide()-4,(self:GetWide()/2)-2,Color(250,250,250,100))
	draw.SimpleText("-","ESDefaultBold",self:GetWide()/2 + 1,self:GetTall()-self:GetWide()/2 - 1,COLOR_BLACK,1,1,1,Color(255,255,255,10))
	if self.PaintHook then
		self.PaintHook()
	end
end
vgui.Register( "esScrollbar", PANEL, "Panel" )

local PANEL = {}
PANEL.hover = false
function PANEL:OnCursorEntered()
	self.hover = true
end
function PANEL:OnCursorExited()
	self.hover = false
end
function PANEL:OnMousePressed()
	self:GetParent().dragging = true
	local _,y=gui.MousePos()
	self:GetParent().startDrag = y
end
vgui.Register( "esScrollbarScrollButton", PANEL, "Panel")