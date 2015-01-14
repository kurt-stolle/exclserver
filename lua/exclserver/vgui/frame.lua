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
font = "Roboto", 
size = 20,
weight=500 } 
)
surface.CreateFont( "ESFrameTextShadow", { 
font = "Roboto", 
size = 20,
weight=500,
blursize=2 } 
)

local tex = Material("exclserver/gradient.png")
function PANEL:Init()
	self.PaintHook = false;
	self.Title = "Hey fuck face, give me a name."
	self.showCloseBut = true;

	if self.ShowCloseButton then
		self:ShowCloseButton(false);
	end
	if self.btnClose then
		self.btnClose:Remove();
		self.btnMaxim:Remove();
		self.btnMinim:Remove();
	end
	
	if self.SetTitle then
		self:SetTitle( "" )
	end
	function self:SetTitle(title)
		self.Title = title;
	end
	self.PerformLayout = function() end
	
	self.scale=0;
	self.kill=false;
	self.oldRemove=self.Remove;
	function self:Remove()
		self.kill=true;
	end
end
function PANEL:EnableCloseButton(b)
	self.showCloseBut = b;
	self.OnClose = function() end
end
function PANEL:OnMouseReleased()
	if not self.showCloseBut then return end

    local x, y = gui.MousePos();	
	local xPanel,yPanel = self:GetPos();
	if x > xPanel+self:GetWide()-24 and x < xPanel+self:GetWide()-1 and y > yPanel and y < yPanel+30 then
		if self and self:IsValid() then
			if self.OnClose then
				self.OnClose();
			end	
			self:Remove();
		end
	end
end
function PANEL:Think()
	self.scale=Lerp(FrameTime()* (self.kill and 20 or 10),self.scale,self.kill and 0 or 1);

	if self.kill and self.scale <= 0.01 then
		self:SetVisible(false);
		self:oldRemove();
		ES.DebugPrint("Closed ES Frame.");
	end
end
--local matShading = Material("exclserver/scanlines.png");
local mat_close = Material("exclserver/close.png")
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

	draw.RoundedBoxEx(4,0,0,w,h,ES.Color["#000000AA"],true,true) 
	draw.RoundedBoxEx(4,1,1,w-2,30,a,true,true) 

	draw.RoundedBoxEx(4,1,30,w-2,h-31,ES.Color["#1E1E1E"],false,false,true,true);
	draw.SimpleText(string.upper(self.Title),"ESFrameTextShadow",11,30/2+1,ES.Color["#00000022"],0,1);
	draw.SimpleText(string.upper(self.Title),"ESFrameText",10,30/2,COLOR_WHITE,0,1);

	if self.showCloseBut then
		surface.SetMaterial(mat_close);
		surface.SetDrawColor(ES.Color.White);
		surface.DrawTexturedRect(self:GetWide()-24,15-8,16,16);
	end

	if self.PaintHook then
		self.PaintHook()
	end
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