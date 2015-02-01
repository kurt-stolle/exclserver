local popModelMatrix = cam.PopModelMatrix
local pushModelMatrix = cam.PushModelMatrix
local pushFilterMag = render.PushFilterMag;
local pushFilterMin = render.PushFilterMin;
local popFilterMag = render.PopFilterMag;
local popFilterMin = render.PopFilterMin;

local matrixAngle = Angle(0, 0, 0)
local matrixScale = Vector(0, 0, 0)
local matrixTranslation = Vector(0, 0, 0)


local matrix,x,y,width,height,rad

local PANEL = {}
surface.CreateFont( "ESFrameText", { 
font = "Calibri", 
size = 18,
weight=400 } 
)
surface.CreateFont( "ESFrameTextShadow", { 
font = "Calibri", 
size = 20,
weight=500,
blursize=2 } 
)

AccessorFunc(PANEL,"title","Title",FORCE_STRING);
local tex = Material("exclserver/gradient.png")
function PANEL:Init()
	self.scale=0;
	self.kill=false;
	self.oldRemove=self.Remove;
	function self:Remove()
		self.kill=true;
	end

	self:SetTitle("FRAME")

	self.btn_close=self:Add("esIconButton");
	self.btn_close:SetIcon(Material("exclserver/close.png"));
	self.btn_close:SetSize(16,16);
	self.btn_close.DoClick=function(_self)
		_self:GetParent():Remove();
	end
end
function PANEL:EnableCloseButton(b)
	self.showCloseBut = b;
	self.OnClose = function() end
end
function PANEL:PerformLayout()
	self.btn_close:SetPos(self:GetWide()-(30/2 + 16/2),(30/2 - 16/2));
end
function PANEL:Think()
	self.scale=Lerp(FrameTime()* (self.kill and 28 or 16),self.scale,self.kill and 0 or 1);

	if self.kill and self.scale <= 0.01 then
		self:SetVisible(false);
		self:oldRemove();
		ES.DebugPrint("Closed ES Frame.");
	end
end
function PANEL:Paint(w,h)
	if self.scale <= 0.99 then
		pushFilterMag( TEXFILTER.ANISOTROPIC )
		pushFilterMin( TEXFILTER.ANISOTROPIC )
	end

	if self.kill then
		x,y=self:LocalToScreen(w/2,h/2);
		x,y=(self.scale-1)*-x,(self.scale-1)*-y;

		matrix=Matrix();
		matrix:SetAngles( matrixAngle )
		matrixTranslation.x = x;
		matrixTranslation.y = y;
		matrix:SetTranslation( matrixTranslation )
		matrixScale.x = self.scale;
		matrixScale.y = self.scale;
		matrix:Scale( matrixScale )
	else
		x,y=self:LocalToScreen(w/2,h/2 + h * self.scale);
		x,y=(self.scale-1)*-x,(self.scale-1)*-y;

		matrix=Matrix();
		matrix:SetAngles( matrixAngle )
		matrixTranslation.x = x;
		matrixTranslation.y = y;
		matrix:SetTranslation( matrixTranslation )
		matrixScale.x = self.scale;
		matrixScale.y = self.scale;
		matrix:Scale( matrixScale )	
	end
 
	-- push matrix
	pushModelMatrix( matrix )

	local a,b,c = ES.GetColorScheme();

	draw.RoundedBoxEx(2,0,0,w,h,ES.Color["#000000AA"],true,true) 
	draw.RoundedBoxEx(2,1,1,w-2,30,a,true,true) 

	draw.RoundedBoxEx(2,1,30,w-2,h-31,ES.Color["#1E1E1E"],false,false,true,true);

	local title = string.upper(self:GetTitle());
	--draw.SimpleText(title,"ESFrameTextShadow",11,30/2+1,ES.Color["#00000066"],0,1);
	draw.SimpleText(title,"ESFrameText",10,30/2,COLOR_WHITE,0,1);
end
function PANEL:PaintOver(w,h)
	popModelMatrix()
	if self.scale <= 0.99 then
		popFilterMag( TEXFILTER.ANISOTROPIC )
		popFilterMin( TEXFILTER.ANISOTROPIC )
	else
		self.scale = 1;
	end
end
vgui.Register( "esFrame", PANEL, "EditablePanel" );