local PLUGIN=ES.Plugin()
PLUGIN:SetInfo("Prop Restrict","Handles prop restrictions.","Excl")
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)

if SERVER then
	-- net
	util.AddNetworkString("ES.Plugin.PropRes.blocked")

	-- Vars
	ES.RestrictedProps = {}
	ES.CreateSetting("PLUGIN:Prop Restrict.Whitelist",true)

	local loadedGlobal = {}
	local loadedLocal = {}

	-- Utility
	local function parseModel(model)
		model = string.lower(model or "")
		model = string.Replace(model, "\\", "/")
		model = string.gsub(model, "[\\/]+", "/")

		return model
	end
	local function addPropRestriction(model,serverid)
		model = parseModel(model)
		serverid = serverid or ES.ServerID

		if table.HasValue(ES.RestrictedProps,models) then
			return
		end

		table.insert(ES.RestrictedProps,model)

		ES.DBQuery("INSERT INTO es_restrictions_props SET model = '"..model.."', serverid = "..ES.ServerID..";")
	end
	local function isBlockedModel(p,model)
		model=parseModel(model)

		if ES.GetSetting("PLUGIN:Prop Restrict.Whitelist",false) then
			if table.HasValue(ES.RestrictedProps,model) then
				return false
			else
				return true
			end
		else
			if table.HasValue(ES.RestrictedProps,model) then
				return true
			else
				return false
			end
		end
	end

	-- Commands
	PLUGIN:AddCommand("blockmdl",function(p,a)
		if not p or not p:IsValid() or not a or not a[1] then return p:ChatPrint("Invalid arguments, format: <model> <global or ~NOTHING~>") end

		addPropRestriction(a[1],a[2] and 0 or ES.ServerID)

		ES.ChatBroadcast("Restricted ",ES.Color.Highlight,a[1],ES.Color.White,".")
	end,40)

	-- Hooks
	PLUGIN:AddHook("ESDatabaseReady",function()
		ES.DBQuery("SELECT * FROM es_restrictions_props WHERE serverid = "..ES.ServerID.." OR serverid = 0",function(res)
			if res then
				ES.DebugPrint("Loaded prop restrictions")
				for k,v in pairs(res) do
					v.model = parseModel(v.model)

					table.insert(ES.RestrictedProps,v.model)
				end
			end
		end)
	end)

	PLUGIN:AddHook("PlayerSpawnObject", function(p, model)
		if isBlockedModel(p,model) then
			p:ESSendNotification("generic","This object is blocked.")
			return false
		end
	end)
end

PLUGIN()
