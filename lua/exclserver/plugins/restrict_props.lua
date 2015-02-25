
local PLUGIN=ES.Plugin()
PLUGIN:SetInfo("Prop restrict","Handles prop restrictions.","Excl")

PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)


if SERVER then
	util.AddNetworkString("ESTellPropBlocked")
	util.AddNetworkString("ESTellPropBlockAdded")

	PLUGIN:AddCommand("restrictmodelname",function(p,a)
		if not p or not p:IsValid() or not a or not a[1] or not a[2] then return end
		
		ES.AddPropRestriction(a[1],tonumber(a[2]),a[3] and 0 or ES.ServerID)

		net.Start("ESTellPropBlockAdded")
		net.WriteString(a[1])
		net.WriteString(tonumber(a[2]) < 5 and "VIP tier "..a[2] or tonumber(a[2]) == 5 and "Administrator" or tonumber(a[2]) == 6 and "Super Administrator" or tonumber(a[2]) == 7 and "Server Operator")
		net.Broadcast()
	end,60)
	PLUGIN:AddCommand("restrictmodel",function(p,a)
		if not p or not p:IsValid() or not a or not a[1] then return end
		
		local mdl = p:GetEyeTrace().Entity
		if not IsValid(mdl) or not mdl.GetModel then return end
		mdl = mdl:GetModel()

		ES.AddPropRestriction(mdl,tonumber(a[1]),a[2] and 0 or ES.ServerID)

		net.Start("ESTellPropBlockAdded")
		net.WriteString(mdl)
		net.WriteString(tonumber(a[1]) < 5 and "VIP tier "..a[1] or tonumber(a[1]) == 5 and "Administrator" or tonumber(a[1]) == 6 and "Super Administrator" or tonumber(a[1]) == 7 and "Server Operator")
		net.Broadcast()

	end,60)

	ES.RestrictedProps = {}
	ES.CreateSetting("props_blacklist_is_whitelist",0,true)

	local loadedGlobal = {}
	local loadedLocal = {}
	PLUGIN:AddHook("ESDatabaseReady",function()
		if !GAMEMODE.IsSandboxDerived then ES.DebugPrint("Not loading prop restriction - we are not on a sandbox derived gamemode.") return end -- thanks garry, now we can not load this ESPlugin when we are not in a sandbox derive.

		ES.DBQuery("SELECT * FROM es_restrictions_props WHERE serverid = "..ES.ServerID.." OR serverid = 0",function(res)
			if res then
				ES.DebugPrint("Loaded prop restrictions")
				for k,v in pairs(res) do
					model = string.lower(v.model or "")
					model = string.Replace(model, "\\", "/")
					model = string.gsub(model, "[\\/]+", "/")

					ES.RestrictedProps[model] = tonumber(v.req) or 7
					if tonumber(v.serverid) > 0 then
						loadedLocal[#loadedLocal+1] = string.lower(model)
					else
						loadedGlobal[#loadedGlobal+1] = string.lower(model)
					end
				end
			end
		end)
	end)
	local function isBlockedModel(p,model)
		model = string.lower(model or "")
		model = string.Replace(model, "\\", "/")
		model = string.gsub(model, "[\\/]+", "/")

		if (ES.GetSetting("props_blacklist_is_whitelist") == 0 and ES.RestrictedProps[model]) or (ES.GetSetting("props_blacklist_is_whitelist") == 1 and !ES.RestrictedProps[model]) then
			if (ES.RestrictedProps[model] < 5 	and p:ESGetVIPTier() < ES.RestrictedProps[model] )
			or (ES.RestrictedProps[model] == 5 	and !p:ESHasPower(20) )
			or (ES.RestrictedProps[model] == 6 	and !p:ESHasPower(40) )
			or (ES.RestrictedProps[model] == 7 	and !p:ESHasPower(60) ) then 
				ES.DebugPrint(p:Nick().." tried to spawn restricted model "..model)
				net.Start("ESTellPropBlocked")
				net.WriteString(model)
				net.WriteString(ES.RestrictedProps[model] <= 4 and "VIP tier "..tostring(ES.RestrictedProps[model]) or ES.RestrictedProps[model] == 5 and "Administrator" or ES.RestrictedProps[model] == 6 and "Super Administrator" or ES.RestrictedProps[model] == 7 and "Server Operator")
				net.Send(p)

				return true
			end	
		end

		return false
	end
	PLUGIN:AddHook("PlayerSpawnProp", function(p, model)
		if isBlockedModel(p,model) then
			return false
		end
	end)

	function ES.AddPropRestriction(model,tier,serverid)
		model = string.lower(model)
		serverid = serverid or ES.ServerID

		if ES.RestrictedProps[model] then
			ES.RestrictedProps[model] = tier

			if serverid == 0 and table.HasValue(loadedGlobal,model) or serverid > 0 and table.HasValue(loadedLocal,model) then
				ES.DBQuery("UPDATE es_restrictions_props SET req = "..tier.." WHERE model = '"..model.."' AND serverid = "..ES.ServerID.."")
				return
			end
		end

		ES.RestrictedProps[model] = tier
		
		ES.DBQuery("INSERT INTO es_restrictions_props SET model = '"..model.."', serverid = "..ES.ServerID..", req = "..tier.."")
	end
elseif CLIENT then
	net.Receive("ESTellPropBlockAdded",function()
		local mdl = net.ReadString()
		local tier = net.ReadString()
		chat.AddText("server",COLOR_EXCLSERVER,mdl,COLOR_WHITE," was added to the model blacklist (or whitelist) for everyone below ",COLOR_EXCLSERVER,tier,COLOR_WHITE,".")
	end)
	net.Receive("ESTellPropBlocked",function()

		local mdl = net.ReadString()
		local rank = net.ReadString()
		
		chat.AddText("error",COLOR_EXCLSERVER,mdl,COLOR_WHITE," is restricted to ",COLOR_EXCLSERVER,rank,COLOR_WHITE,".")
	end)	
end

PLUGIN()