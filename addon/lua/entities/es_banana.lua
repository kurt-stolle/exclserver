-- es_banana.lua

AddCSLuaFile()

ENT.Type             = "anim"
ENT.Base             = "base_anim"

function ENT:SetupDataTables()
	self:NetworkVar( "Int", 0, "BananaCount")
end

local ONE = Model("models/props/cs_italy/bananna.mdl")
local MORE = Model("models/props/cs_italy/bananna_bunch.mdl")
function ENT:Initialize()
  if SERVER then
  	self:SetBananaCount(1)

  	local size=8

    self:SetModel( ONE )

	self:PhysicsInitSphere( size, "rubber" )
		
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if phys and phys:IsValid() then
      phys:Wake()
      phys:SetMass(5)
    end

    self:SetCollisionBounds( Vector( -size, -size, -size ), Vector( size, size, size ) )

    self:SetTrigger(true)
    self:SetFriction(100)
  end

  self._timeCreate=CurTime()
end

if SERVER then
	function ENT:Touch( ply )
		if self._merged or self._pickedUp then return end

		if IsValid(self) and  self._timeCreate+1 < CurTime() and IsValid(ply) and ply.IsPlayer and ply:IsPlayer() and ply.ESSetBananas then
			ply:ESAddBananas(self:GetBananaCount())
			self._pickedUp = true
			self:Remove()			
		elseif IsValid(self) and  self._timeCreate+1 < CurTime()  and IsValid(ply) and ply.GetClass and ply:GetClass() == "es_banana" then
			self:SetBananaCount(ply:GetBananaCount() + self:GetBananaCount())
			ply:Remove()
			ply._merged=true

			local phys=self:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetVelocityInstantaneous(Vector(0,0,0))
				phys:SetVelocity(Vector(0,0,0))
			end			
		end
	end

	function ENT:Think()
		if self:GetModel() == ONE and self:GetBananaCount() > 1 then
			self:SetModel(MORE)
		end

		if self._timeCreate+1 > CurTime() then return end

		for _,ent in ipairs(ents.FindByClass( "es_banana" ))do
			if IsValid(ent) and ent:GetPos():Distance(self:GetPos()) < 200 then
				local delta=(ent:GetPos() - self:GetPos()):Angle():Forward() * 40

				local phys=self:GetPhysicsObject()
				if IsValid(phys) then
					phys:ApplyForceCenter(delta)
				end
			end
		end

		for _,ent in ipairs(player.GetAll())do
			if IsValid(ent) and ent:GetObserverMode() == OBS_MODE_NONE and ent:GetPos():Distance(self:GetPos()) < 200 then
				local delta=(ent:GetPos() - self:GetPos()):Angle():Forward() * 40

				local phys=self:GetPhysicsObject()
				if IsValid(phys) then
					phys:ApplyForceCenter(delta)
				end
			end
		end
	end

	concommand.Add("excl_drop_banana",function(ply,cmd,args)
		local amount = tonumber(args[1]);

		if amount > ply:ESGetBananas() or amount < 1 then ply:ESSendNotificationPopup("Error","You don't have enough bananas to throw.") return end

		local myBananas = 0

		for k,v in ipairs(ents.FindByClass( "es_banana" ))do
			if v._bananaOwner and v._bananaOwner == ply then
				myBananas = myBananas + 1
			end
		end

		if myBananas > 10 then ply:ESSendNotificationPopup("Error","You may not throw over 10 bananas at a time.") return end

		ply:ESTakeBananas(amount)

		local ent=ents.Create("es_banana")
		ent:SetPos(ply:EyePos() + ply:GetAngles():Forward()*30)
		ent:Spawn()
		ent._bananaOwner = ply
		ent:SetBananaCount(amount)

		local phys=ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:ApplyForceCenter(ply:EyeAngles():Forward()*500)
		end
	end)
elseif CLIENT then
	local color_glow=Color( 200, 150, 50 )

	function ENT:Draw()
		render.SetLightingMode( 2 )

		self:SetRenderAngles(Angle(0,CurTime()*100%360,0))
		self:DrawModel()

		render.SetLightingMode( 0 )		
	end

	function ENT:Think()
		local dlight = DynamicLight( self:EntIndex() )

		if ( dlight ) then
			local size=80
			local c = color_glow
			dlight.Pos = self:GetPos()
			dlight.r = c.r
			dlight.g = c.g
			dlight.b = c.b
			dlight.Brightness = 1
			dlight.Decay = size * 5
			dlight.Size = size
			dlight.DieTime = CurTime() + 1
		end
	end

	hook.Add( "PreDrawHalos", "exclserver.es_banana", function() 
		halo.Add( ents.FindByClass( "es_banana" ), color_glow, 6, 6, 1, true )
	end )

	hook.Add("PostDrawOpaqueRenderables", "exclserver.es_banana", function()
		local eye = LocalPlayer():EyePos()
		for _,self in ipairs(ents.FindByClass( "es_banana" ))do
			local ang = (self:GetPos()-eye):Angle()
			ang:RotateAroundAxis(ang:Right(),90)
			ang:RotateAroundAxis(ang:Up(),-90)
			cam.Start3D2D( self:GetPos() + Vector(0,0,10), ang, .2 )
				draw.SimpleText(self:GetBananaCount(),"ESDefault+++.Shadow",0,0,ES.Color.Black,1,1)
				draw.SimpleText(self:GetBananaCount(),"ESDefault+++",0,0,ES.Color.White,1,1)
			cam.End3D2D()	
		end
	end)


		
	local was_pressed = false
	hook.Add("Think","exclserver.es_banana",function()
		if input.IsKeyDown(KEY_F7) and not was_pressed then
			was_pressed = true
			RunConsoleCommand("excl_drop_banana",1)
		elseif not input.IsKeyDown(KEY_F7) then
			was_pressed = false
		end
	end)
end