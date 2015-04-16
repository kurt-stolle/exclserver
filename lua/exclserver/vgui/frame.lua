local popModelMatrix = cam.PopModelMatrix
local pushModelMatrix = cam.PushModelMatrix
local pushFilterMag = render.PushFilterMag
local pushFilterMin = render.PushFilterMin
local popFilterMag = render.PopFilterMag
local popFilterMin = render.PopFilterMin

local matrixAngle = Angle(0, 0, 0)
local matrixScale = Vector(0, 0, 0)
local matrixTranslation = Vector(0, 0, 0)


local matrix,x,y,width,height,rad

local PANEL = {}
ES.CreateFont( "ESFrameText", {
font = "Roboto",
size = 18,
weight=400 }
)

AccessorFunc(PANEL,"title","Title",FORCE_STRING)
local tex = Material("exclserver/gradient.png")
function PANEL:Init()
	self:DockPadding(5,30,5,5)

	self.scale=0
	self.kill=false
	self.oldRemove=self.Remove
	function self:Remove()
		self.kill=true
	end

	self:SetTitle("FRAME")

	if not IsValid(self.btn_close) then

		self.btn_close=self:Add("esIconButton")
		self.btn_close:SetIcon(Material("exclserver/close.png"))
		self.btn_close:SetSize(16,16)
		self.btn_close.DoClick=function(_self)
			_self:GetParent():Remove()
		end

	end
end
function PANEL:EnableCloseButton(b)
	self.showCloseBut = b
	self.OnClose = function() end
end
function PANEL:PerformLayout()
	self.btn_close:SetPos(self:GetWide()-5-32/2-8,1)
end
function PANEL:Think()
	self.scale=Lerp(FrameTime()* (self.kill and 12 or 8),self.scale,self.kill and 0 or 1)

	if self.kill and self.scale <= 0.01 then
		self:SetVisible(false)
		self:oldRemove()
	end
end
function PANEL:Paint(w,h)

	if self.scale <= 0.99 then
		pushFilterMag( TEXFILTER.ANISOTROPIC )
		pushFilterMin( TEXFILTER.ANISOTROPIC )
	end

	if self.kill then
		x,y=self:LocalToScreen(w/2,h/2)
		x,y=(self.scale-1)*-x,(self.scale-1)*-y

		matrix=Matrix()
		matrix:SetAngles( matrixAngle )
		matrixTranslation.x = x
		matrixTranslation.y = y
		matrix:SetTranslation( matrixTranslation )
		matrixScale.x = self.scale
		matrixScale.y = self.scale
		matrix:Scale( matrixScale )
	else
		x,y=self:LocalToScreen(w/2,h/2)
		x,y=(self.scale-1)*-x,(self.scale-1)*-y

		matrix=Matrix()
		matrix:SetAngles( matrixAngle )
		matrixTranslation.x = x
		matrixTranslation.y = y
		matrix:SetTranslation( matrixTranslation )
		matrixScale.x = self.scale
		matrixScale.y = self.scale
		matrix:Scale( matrixScale )
	end

	-- push matrix
	pushModelMatrix( matrix )

	ES.UIDrawBlur(self,matrix)

	local a,b,c = ES.GetColorScheme()

	surface.SetDrawColor(Color(a.r,a.g,a.b,120))
	surface.DrawRect(1,1,w-2,h-2)
	surface.SetDrawColor(ES.Color["#000000CC"])
	surface.DrawRect(1,1,w-2,h-2)
	surface.SetDrawColor(ES.Color.Black)
	surface.DrawLine(0,0,w,0)
	surface.DrawLine(0,1,0,h-1)
	surface.DrawLine(w-1,1,w-1,h-1)
	surface.DrawLine(0,h-1,w,h-1)
	--surface.DrawLine(0,30,w,30)

	--[[	surface.SetDrawColor(ES.Color["#FFFFFF05"])
	surface.DrawRect(1,31,w-2,1)
	surface.DrawRect(1,h-2,w-2,1)
	surface.DrawRect(1,32,1,h-34)
	surface.DrawRect(w-2,32,1,h-34)]]

	surface.SetDrawColor(ES.GetColorScheme(1))
	surface.DrawRect(1,1,w-2,29)
	surface.DrawRect(1,1,4,h-2)
	surface.DrawRect(w-5,1,4,h-2)
	surface.DrawRect(1,h-5,w-2,4)

	if IsValid(self.btn_close) then
		surface.SetDrawColor(ES.Color.Red)
		surface.DrawRect(w-32-5,1,32,18)
		surface.SetDrawColor(ES.Color["#0000001F"])
		surface.DrawRect(w-31-5,1,30,16)
	end

	draw.SimpleText(self:GetTitle(),"ESFrameText",10,30/2,ES.Color.White,0,1)
end
function PANEL:PaintOver(w,h)
	popModelMatrix()
	if self.scale <= 0.99 then
		popFilterMag( TEXFILTER.ANISOTROPIC )
		popFilterMin( TEXFILTER.ANISOTROPIC )
	else
		self.scale = 1
	end
end
vgui.Register( "esFrame", PANEL, "EditablePanel" )
