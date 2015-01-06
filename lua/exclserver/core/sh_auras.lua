-- sh_auras


ES.AurasBuy = {} -- Will be loaded in seperate files.

function  ES:AddAura(n,d,p,t,rota) -- maybe a bit silly to not just edit the table, but we want to make it so people who edit ExclServer do not have to touch files in core/
	ES.AurasBuy[string.lower(n)] = {name = n, descr = d, cost = p, text= Material(t), rotate = rota}; 
end

if CLIENT then
	CreateConVar("excl_auras_disable", "0", FCVAR_ARCHIVE);


	hook.Add("PostPlayerDraw", "ESPostPlayerDrawAuras", function(p) if not GetConVar("excl_auras_disable"):GetBool() then
		if not p:GetNWString("aura") or not ES.AurasBuy[p:GetNWString("aura")] or not p:Alive() then return end

		local aura = ES.AurasBuy[p:GetNWString("aura")]

		p.rotateaura = ((p.rotateaura or 0) + .2) % 360;
		
		render.SetToneMappingScaleLinear(Vector(0.6,1,1))
		surface.SetMaterial( aura.text )
		surface.SetDrawColor(COLOR_WHITE)
		
		cam.Start3D2D(p:GetPos() + Vector(0, 0, .5), Angle(0, p.rotateaura, 0), 0.4)
			surface.DrawTexturedRect(-64, -64, 128,128)
		cam.End3D2D()
		cam.Start3D2D(p:GetPos() + Vector(0, 0, 0), Angle(0, p.rotateaura, 180), 0.4)
			surface.DrawTexturedRect(-64, -64, 128,128)
		cam.End3D2D()
		render.TurnOnToneMapping()
	end end)
end