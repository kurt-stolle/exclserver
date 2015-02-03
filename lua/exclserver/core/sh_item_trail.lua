-- sh_trails.lua

ES.Trails = {} 
ES.ImplementIndexMatcher(ES.Trails,"_name");

function  ES.AddTrail(n,d,p,t,color)
	local tab=ES.Item( ES.ITEM_TRAIL );
	AccessorFunc(tab,"_color","Color");
	tab:SetName(n);
	tab:SetDescription(d);
	tab:SetCost(p);
	tab:SetModel(t);
	tab:SetColor(color);

	table.insert(ES.Trails,tab);
end

if CLIENT then
	CreateConVar("excl_trails_disable", "0", FCVAR_ARCHIVE);
	hook.Add("OnEntityCreated","ESDisableTrailsIHateMyself",function(e)
		if e and IsValid(e) and GetConVar("excl_trails_disable"):GetBool() and e:GetClass() == "env_spritetrail" then
			e:SetNoDraw(true);
		end
	end)

	concommand.Add("excl_trails_reload",function()
		for k,v in pairs(ents.FindByClass("env_spritetrail"))do
			if GetConVar("excl_trails_disable"):GetBool() then
				v:SetNoDraw(true);
			else
				v:SetNoDraw(false);
			end
		end
	end)
end

ES.AddTrail ("Laser","The classic laser trail",80,"trails/laser.vmt");
ES.AddTrail ("Blue Laser","The classic laser trail in blue",100,"trails/laser.vmt",Color(0,0,255));
ES.AddTrail ("The attention whore","Look at me!",90,"trails/lol.vmt");
ES.AddTrail ("Electricity","Lights will turn on when you walk by.",100,"trails/electric.vmt");
ES.AddTrail ("Smoke","You're smoking hot!",120,"trails/smoke.vmt");
ES.AddTrail ("Tube","Tubes r 4 noobs",130,"trails/tube.vmt");
ES.AddTrail ("Physbeam","Bend the laws of physics",140,"trails/physbeam.vmt");
ES.AddTrail ("Plasma","A plasma trail",150,"trails/plasma.vmt");
ES.AddTrail ("Love","Wear this trail as a sign that you truly love this server.",10000,"trails/love.vmt");