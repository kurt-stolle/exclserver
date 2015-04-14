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
size = 20,
weight=500 }
)

AccessorFunc(PANEL,"title","Title",FORCE_STRING)
local tex = Material("exclserver/gradient.png")
function PANEL:Init()
	self:DockPadding(0,30,0,0)

	self.scale=0
	self.kill=false
	self.oldRemove=self.Remove
	function self:Remove()
		self.kill=true
	end

	self:SetTitle("FRAME")

	self.btn_close=self:Add("esIconButton")
	self.btn_close:SetIcon(Material("exclserver/close.png"))
	self.btn_close:SetSize(16,16)
	self.btn_close.DoClick=function(_self)
		_self:GetParent():Remove()
	end
end
function PANEL:EnableCloseButton(b)
	self.showCloseBut = b
	self.OnClose = function() end
end
function PANEL:PerformLayout()
	self.btn_close:SetPos(self:GetWide()-(30/2 + 16/2),(30/2 - 16/2))
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

	local a,b,c = ES.GetColorScheme()

	surface.SetDrawColor(ES.Color.Black)
	surface.DrawRect(0,0,w,h)
	surface.SetDrawColor(ES.Color["#1E1E1E"])
	surface.DrawRect(1,1,w-2,h-2)

	surface.SetDrawColor(ES.Color["#FFFFFF03"])
	surface.DrawRect(1,1,w-2,1)
	surface.DrawRect(1,h-2,w-2,1)
	surface.DrawRect(1,2,1,h-4)
	surface.DrawRect(w-2,2,1,h-4)

	surface.SetDrawColor(ES.GetColorScheme(1))
	surface.DrawRect(1,1,w-2,29)

	draw.SimpleText(self:GetTitle(),"ESFrameText",10,30/2,COLOR_WHITE,0,1)
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
