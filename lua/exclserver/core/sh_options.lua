-- sh_options
--[[

local options = {}
local postInitialLoad = false;
function ES:CreateOption(id,default,forceForceToClient)
	options[id] = {var = default, forceForceToClient = tobool(forceForceToClient), forceToClient = false}
end
function ES:GetOptionValue(id)
	if not options[id] then return false; end
	return options[id].var;
end
function ES:SetOptionValue(id,value)
	if not options[id] then return end
	if SERVER then
		
	elseif CLIENT and not options[id].forcedToClient and not options[id].forceForceToClient then
		LocalPlayer():SetPData(id,value);
		options[id].var = value;
	end
end
function ES:LoadOptions()
	if SERVER then
		ES.DBQuery("SELECT * FROM es_options",function(c) if c and c[1] then
			for k,v in pairs(c)do
				if v.name and options[v.name] and v.global and v.typ then
					if v.specific then
						v.specific = string.Explode("|",v.specific);
						local result = {}
						for k,v in pairs(v.specific)do
							local t = string.Explode("=",v);
							v.specific[ t[1] ] = t[2];
						end
						v.specific = result
					end
					if v.typ == "string" then
						options[v.name].var = tostring(v.global)
					elseif v.typ == "boolean" then
						options[v.name].var = tobool(v.global)
					elseif v.typ == "number" then
						options[v.name].var = tonumber(v.global)
					end
				end
			end
		end end)
	elseif CLIENT then
		for k,v in pairs(options)do
			if not v.forcedToClient and not v.forceForceToClient then
				v.var = v:GetPData(k);
			end
		end
	end
end
hook.Add("InitPostEntity","ESOptionsServerLoad",function()
timer.Simple(0,function()
	
	ES:LoadOptions();
		
end)
end);
	
if SERVER then
	hook.Add("ESPreCreateDatatables","ESRanksDatatableSetup",function()
		ES:DefineDataTable("options",false,"name varchar(255), global varchar(255), specific varchar(255), typ varchar(100), forceToClient BOOL")
	end)
end


]]