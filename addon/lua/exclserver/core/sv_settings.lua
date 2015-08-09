
local settings = {}
local settingsTypeFn = {}

function ES.CreateSetting(name,default)
	settings[name] = default or false

	if type(def) == "number" then
		settingsTypeFn[name]=tonumber
	elseif type(def) == "boolean" then
		settingsTypeFn[name]=tobool
	else
		settingsTypeFn[name]=tostring
	end
end
function ES.GetSetting(name)
	return settings[name] or ES.Error("SETTING_GET_NOT_FOUND",name) and nil;
end
function ES.SetSetting(name,value,serverid)
	if not serverid then
		serverid = ES.ServerID
	end

	if type(settings[name]) == "nil" or (serverid ~= 0 and serverid ~= ES.ServerID) then return end

	value=ES.DBEscape(value)

	ES.DBQuery("SELECT id FROM `es_settings` WHERE serverid="..serverid.." AND name='"..name.."' LIMIT 1;",function(res)
		if res and res[1] and res[1].id then
			ES.DBQuery("UPDATE `es_settings` SET name='"..name.."', value='"..value.."' WHERE id="..res[1].id..";")
		else
			ES.DBQuery("INSERT INTO `es_settings` SET name='"..name.."', value='"..value.."', serverid="..serverid..";")
		end
	end)
end

--Basic settings
ES.CreateSetting("API:Url","https://es2-api.casualbananas.com")

--Hooks
hook.Add("ESDatabaseReady","exclserver.settings.load",function()
	ES.DBQuery("SELECT name,value,serverid FROM `es_settings` WHERE serverid="..ES.ServerID..";",function(res)
		if res and res[1] then
			for k,v in ipairs(res)do
				settings[v.name]=settingsTypeFn[v.name](v.value)
			end
		end
	end)
end)

util.AddNetworkString("exclserver.settings.send")
hook.Add("ESPlayerReady","exclserver.settings.send",function(ply)
	net.Start("exclserver.settings.send")
	net.WriteTable(settings)
	net.Send(ply)
end)

--Network
net.Receive("exclserver.settings.send",function(len,ply)
	if not IsValid(ply) or ply:ESGetRank():GetPower() < ES.POWER_SUPERADMIN then return ply:ESSendNotificationPopup("Error","You need at least Super Admin rank to set settings") end

	local setti=net.ReadString()

	local fnType=settingsTypeFn[setti]
	if not fnType then return end

	local var=fnType(net.ReadString())

	if not var then return end

	ES.SetSetting(setti,var)

	ply:ESSendNotificationPopup("Success",setti.." was set to "..var)
end)
