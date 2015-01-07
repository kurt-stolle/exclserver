-- Tiles for items in the main menu.

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

local PANEL={};

function PANEL:Init()
	self:NoClipping(false);
	self.delay=0;
	self.scale=0;
end
function PANEL:Think()
	if self.delay > CurTime() then return end

	self.scale=Lerp(FrameTime()*4,self.scale,self:GetHover() and 1.05 or 1);
end
function PANEL:Paint(w,h)
	pushFilterMag( TEXFILTER.ANISOTROPIC )
	pushFilterMin( TEXFILTER.ANISOTROPIC )

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
 
	-- push matrix
	pushModelMatrix( matrix )		
end
function PANEL:PaintOver(w,h)
	popModelMatrix()
	popFilterMag( TEXFILTER.ANISOTROPIC )
	popFilterMin( TEXFILTER.ANISOTROPIC )
end
ES.UIAddHoverListener(PANEL);
vgui.Register("ES.ItemTile",PANEL,"Panel");