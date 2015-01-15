-- sh_auras


ES.Auras = {} -- Will be loaded in seperate files.

function  ES.AddAura(n,d,p,t) -- maybe a bit silly to not just edit the table, but we want to make it so people who edit ExclServer do not have to touch files in core/
	local tab=ES.Item( ES.ITEM_AURA );
	tab:SetName(n);
	tab:SetDescription(d);
	tab:SetCost(p);
	tab:SetModel(t);

	table.insert(ES.Auras,tab);
end

if CLIENT then
	CreateConVar("excl_auras_disable", "0", FCVAR_ARCHIVE);


	hook.Add("PostPlayerDraw", "ESPostPlayerDrawAuras", function(p) if not GetConVar("excl_auras_disable"):GetBool() then
		if not p:GetNWString("aura") or not ES.Auras[p:GetNWString("aura")] or not p:Alive() then return end

		local aura = ES.Auras[p:GetNWString("aura")]

		p.rotateaura = ((p.rotateaura or 0) + .2) % 360;
		
		render.SetToneMappingScaleLinear(Vector(0.6,1,1))
		surface.SetMaterial( aura.material )
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

ES.AddAura("Casual Bananas","For the truly loyal members",								20000,"exclserver/auras/logo.png",true);
ES.AddAura("Firefox","Foxy",														20000,"exclserver/auras/firefox.png",false);
ES.AddAura("Rainbows","Gay gay gay",											1000,"exclserver/auras/rainbow.png",true);   
ES.AddAura("Banana","Proud Casual Bananas member",							25000,"exclserver/auras/banana.png",true);      
ES.AddAura("Plexcon","Plexcon was here",								11000,"exclserver/auras/plexcon.png",true);   
ES.AddAura("Sucky sucky","Sucky sucky $5",							8000,"exclserver/auras/sucky.png",true);  
ES.AddAura("Kill you","Uh, you know that I will kill you, right?",9000,"exclserver/auras/killyou.png",true);  
ES.AddAura("Target","Bomb here" ,							15000,"exclserver/auras/redcircle.png",true);     