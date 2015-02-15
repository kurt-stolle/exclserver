-- sh_auras


ES.Auras = {} -- Will be loaded in seperate files.
ES.ImplementIndexMatcher(ES.Auras,"_name");

function  ES.AddAura(n,d,p,t) -- maybe a bit silly to not just edit the table, but we want to make it so people who edit ExclServer do not have to touch files in core/
	local tab=ES.Item( ES.ITEM_AURA );
	tab:SetName(n);
	tab:SetDescription(d);
	tab:SetCost(p);
	tab:SetModel(t);

	if CLIENT then
		tab._material = Material(t);
	end

	table.insert(ES.Auras,tab);
end

if CLIENT then
	CreateConVar("excl_auras_disable", "0", FCVAR_ARCHIVE);


	local aura;
	hook.Add("PostPlayerDraw", "ESPostPlayerDrawAuras", function(p) 
		if not GetConVar("excl_auras_disable"):GetBool() then
			aura=ES.Auras[p:ESGetNetworkedVariable("active_aura",nil)];
			if not aura or not p:Alive() then return end

			if not p._es_auraAngle then
				p._es_auraAngle=0
			end

			p._es_auraAngle = (p._es_auraAngle + FrameTime()*4) % 360;
			
			local tr=util.TraceHull{start=p:GetPos()+Vector(0,0,.5),endpos=p:GetPos()-Vector(0,0,10000),filter=p,maxs=Vector(16,16,0),mins=Vector(-16,-16,0),mask=MASK_PLAYERSOLID};

			if not tr then return end

			local pos=tr.HitPos;
			local normal=tr.HitNormal:Angle();

			if not pos or not normal then return end

			
			normal:RotateAroundAxis(normal:Right(),-90);
			normal:RotateAroundAxis(normal:Up(),p._es_auraAngle);

			render.SetToneMappingScaleLinear(Vector(0.6,1,1))
			surface.SetMaterial( aura._material )
			surface.SetDrawColor(COLOR_WHITE)
			
			cam.Start3D2D(pos + Vector(0, 0, .2), normal, 0.3)
				surface.DrawTexturedRect(-64, -64, 128,128)
			cam.End3D2D()

			normal:RotateAroundAxis(normal:Right(),180);
			cam.Start3D2D(pos + Vector(0, 0, .2), normal, 0.3)
				surface.DrawTexturedRect(-64, -64, 128,128)
			cam.End3D2D()
			render.TurnOnToneMapping()
		end 
	end)
end

ES.AddAura("Casual Bananas","For the truly loyal members",								20000,"exclserver/auras/logo.png",true);
ES.AddAura("Firefox","Foxy",														20000,"exclserver/auras/firefox.png",false);
ES.AddAura("Rainbows","Gay gay gay",											1000,"exclserver/auras/rainbow.png",true);   
ES.AddAura("Banana","Proud Casual Bananas member",							25000,"exclserver/auras/banana.png",true);      
ES.AddAura("Plexcon","Plexcon was here",								11000,"exclserver/auras/plexcon.png",true);   
ES.AddAura("Sucky sucky","Sucky sucky $5",							8000,"exclserver/auras/sucky.png",true);  
ES.AddAura("Kill you","Uh, you know that I will kill you, right?",9000,"exclserver/auras/killyou.png",true);  
ES.AddAura("Target","Bomb here" ,							15000,"exclserver/auras/redcircle.png",true);     