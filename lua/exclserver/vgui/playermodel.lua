local PNL = {};
AccessorFunc(PNL,"useOutfit","UseOutfit",FORCE_BOOL);
AccessorFunc(PNL,"focusBone","Focus",FORCE_STRING);
AccessorFunc(PNL,"zoom","Zoom",FORCE_NUMBER);
AccessorFunc(PNL,"rotate","Rotation",FORCE_NUMBER);
AccessorFunc(PNL,"rotate_y","RotationY",FORCE_NUMBER);

function PNL:Init() 
	self:SetZoom(40);
	self:SetRotation(90);
	self:SetRotationY(0);

	self.Slots = {};
	self.dragging=false;
end
function PNL:OnMousePressed()
	self.dragging = true;
	self.startPos = Vector(gui.MousePos());
end
function PNL:SetFocus(b)
	if b then
		local bone = self.Entity:LookupBone(b)
		if not bone then ES.DebugPrint("ERROR! Bone not found! "..b) return end

		self:SetLookAt(self.Entity:GetBonePosition(bone));
		self:SetCamPos(self.Entity:GetBonePosition(bone) + Vector(math.sin(math.rad(self.rotate))*self.zoom,math.cos(math.rad(self.rotate))*self.zoom,0--[[self:GetRotationY()]]));
		self.focusBone = b;
	end
end
function PNL:LayoutEntity() end -- override so it doesn't fuck us over.
function PNL:Paint()
	if ( !IsValid( self.Entity ) ) then return end

	if self.dragging and self.startPos then
		local p = Vector(gui.MousePos());
		
		local dx = p.x - self.startPos.x;
		local dy = p.y - self.startPos.y;

		if self.dragging and (input.IsMouseDown(MOUSE_LEFT) or input.IsMouseDown(MOUSE_RIGHT)) then
			self:SetRotation(self:GetRotation()+dx);
			self:SetRotationY(self:GetRotationY()+dy);
			self:SetFocus(self.focusBone);

			self.startPos=p;
		else
			self.dragging = false;
		end
	end
		
	local p = LocalPlayer();

	local x, y = self:LocalToScreen( 0, 0 )
	
	self:LayoutEntity( self.Entity )
	
	local ang = self.aLookAngle
	if ( !ang ) then
		ang = (self.vLookatPos-self.vCamPos):Angle()
	end
	
	local w, h = self:GetSize()
	cam.Start3D( self.vCamPos, ang, self.fFOV, x, y, w, h, 5, 4096 )
	cam.IgnoreZ( true )
	
	render.SuppressEngineLighting( true )
	render.SetLightingOrigin( self.Entity:GetPos() )
	render.ResetModelLighting( self.colAmbientLight.r/255, self.colAmbientLight.g/255, self.colAmbientLight.b/255 )
	render.SetColorModulation( self.colColor.r/255, self.colColor.g/255, self.colColor.b/255 )
	render.SetBlend( self.colColor.a/255 )
	

	for i=0, 6 do
		local col = self.DirectionalLight[ i ]
		if ( col ) then
			render.SetModelLighting( i, col.r/255, col.g/255, col.b/255 )
		end
	end

	self.Entity:DrawModel()		
	local item,pos,ang,scale,bone,color,drawang,drawpos,mtr;
	for k,v in pairs(self.Slots)do
		item = ES.Props[v.item];
		if not item or not IsValid(item.cMdl) or not v.pos or not v.ang or not v.scale or not v.bone or not v.color then continue end

		pos = v.pos;
		ang = v.ang;
		scale = item.scale + v.scale;
		bone = v.bone;
		color = ES.Color[v.color];
		item = item.cMdl;

		bone = self.Entity:LookupBone(bone)

		if not bone then continue end

		mtr = Matrix();
		mtr:Scale(scale);

		item:EnableMatrix("RenderMultiply", mtr);

		item:SetColor(color or ES.Color.White);
				
		drawpos, drawang = self.Entity:GetBonePosition(bone)
		
		drawpos = drawpos + (drawang:Up() * 			pos.z);
		drawpos = drawpos +	(drawang:Forward() * 		pos.y);
		drawpos = drawpos + (drawang:Right() * 			pos.x);
			
		drawang:RotateAroundAxis( drawang:Forward(), 	ang.p)
		drawang:RotateAroundAxis( drawang:Up(), 		ang.y)
		drawang:RotateAroundAxis( drawang:Right(), 		ang.r)

		item:SetRenderOrigin( drawpos )
		item:SetRenderAngles( drawang )
		item:SetupBones()
		item:DrawModel()
		item:SetRenderOrigin()
		item:SetRenderAngles()
	end	

	render.SuppressEngineLighting( false )
	cam.IgnoreZ( false )
	cam.End3D()

	self.LastPaint = RealTime()
	
end
vgui.Register("ES.PlayerModel",PNL,"DModelPanel")