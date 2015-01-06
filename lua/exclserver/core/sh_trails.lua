-- sh_trails.lua
-- handles the trials people can have

ES.TrailsBuy = {} -- Will be loaded in seperate files.

function  ES:AddTrail(n,d,p,t,color) -- maybe a bit silly to not just edit the table, but we want to make it so people who edit ExclServer do not have to touch files in core/
	ES.TrailsBuy[string.lower(n)] = {name = n, descr = d, cost = p, text= t,color = (color or Color(255,255,255))}; 
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