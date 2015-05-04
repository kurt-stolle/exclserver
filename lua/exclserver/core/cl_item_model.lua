net.Receive("es.item.model.transform",function(len)
  local ply = net.ReadEntity()

  if not IsValid(ply) or not ply:Alive() or ply:GetObserverMode() ~= OBS_MODE_NONE then return end

  ES.DebugPrint("Playing change model effect")

  if not IsValid(ply._es_particle_emitter) then
		ply._es_particle_emitter = ParticleEmitter( ply:GetPos() )
	end

	for i=0,20 do
		local part = ply._es_particle_emitter:Add("particle/smokesprites_000" .. math.random(1, 9), ply:EyePos()+Vector(0,0,-i*2))
		part:SetStartSize(20)
		part:SetEndSize(35)
		part:SetStartAlpha(255)
		part:SetEndAlpha(0)
		part:SetDieTime(3)
		part:SetRoll(math.random(120, 220))
		part:SetRollDelta(0)
		local r=math.random(5,30);
		part:SetColor(r,r,r)
		part:SetLighting(true)
		part:SetGravity(Vector(0, 0, 1+i));
		part:SetVelocity(Vector(math.random(-8,8),math.random(-8,8),-25))
	end
end)

local was_pressed = false
hook.Add("Think","excl.activemodel.F6",function()
	if input.IsKeyDown(KEY_F6) and not was_pressed then
		was_pressed = true
		RunConsoleCommand("excl_item_model_transform")

    return true
	elseif not input.IsKeyDown(KEY_F6) then
		was_pressed = false
    return true
	end
end)
