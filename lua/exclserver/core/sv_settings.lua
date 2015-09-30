
local settings = {}
local settingsTypeFn = {}

function ES.CreateSetting(name,default,onChanged)
	settings[name] = default or false

	if type(default) == "number" then
		settingsTypeFn[name]=tonumber
	elseif type(default) == "boolean" then
		settingsTypeFn[name]=tobool
	else
		settingsTypeFn[name]=tostring
	end

	hook.Add("ESSettingChanged","exclserver.settings.watchdog:"..name,function(key,value)
		if key == name then
			onChanged(value);
		end
	end)
end
function ES.GetSetting(name)
	return settings[name] or settings[name] == nil and ES.Error("SETTING_GET_NOT_FOUND",name);
end
function ES.SetSetting(name,value,serverid)
	if not serverid then
		serverid = ES.ServerID
	end

	if type(settings[name]) == "nil" or (serverid ~= 0 and serverid ~= ES.ServerID) then return end

	value=settingsTypeFn[name](value)

	if settingsTypeFn[name] == tostring then
		value=ES.DBEscape(value)
	end

	ES.DBQuery("SELECT id FROM `es_settings` WHERE serverid="..serverid.." AND name='"..name.."' LIMIT 1;",function(res)
		if res and res[1] and res[1].id then
			ES.DBQuery("UPDATE `es_settings` SET name='"..name.."', value='"..value.."' WHERE id="..res[1].id..";")
		else
			ES.DBQuery("INSERT INTO `es_settings` SET name='"..name.."', value='"..value.."', serverid="..serverid..";")
		end
	end)

	if serverid == ES.ServerID then
		hook.Call("ESSettingChanged",GAMEMODE,name,value);
	end

	for _,ply in ipairs(player.GetAll())do
		net.Start("exclserver.settings.send")
		net.WriteTable(settings)
		net.Send(ply)

		ES.DebugPrint("Sending settings to "..ply:Nick());
	end

	if not file.Exists("exclserver","DATA") then
		file.CreateDir("exclserver")
	end

	file.Write("exclserver/.settings_cache.txt",util.TableToJSON(settings))
end

function ES.GetSettings()
	return table.Copy(settings);
end

--Basic settings
ES.CreateSetting("API:URL","https://api.example.com")
ES.CreateSetting("Community:Name","my server")
ES.CreateSetting("Community:URL","https://example.com")
ES.CreateSetting("General:MOTD.Enabled",true)
ES.CreateSetting("General:Snapshots.Enabled",true)
ES.CreateSetting("General:Chatbox.Enabled",true)

--Hooks
hook.Add("ESDatabaseReady","exclserver.settings.load",function()
	ES.DBQuery("SELECT name,value,serverid FROM `es_settings` WHERE serverid="..ES.ServerID..";",function(res)
		if res and res[1] then
			for k,v in ipairs(res)do
				settings[v.name]=settingsTypeFn[v.name](v.value)
			end
			ES.DebugPrint("Successfully loaded settings.",settings);
			hook.Call("ESPostSettingsLoaded",GAMEMODE,settings);

			if not file.Exists("exclserver","DATA") then
				file.CreateDir("exclserver")
			end

			file.Write("exclserver/.settings_cache.txt",util.TableToJSON(settings))
		end
	end)
end)

hook.Add("Initialize","exclserver.settings.preload",function()
	if not file.Exists("exclserver/.settings_cache.txt","DATA") then return end

	local cacheSettings = util.JSONToTable(file.Read("exclserver/.settings_cache.txt","DATA"));
	for k,v in pairs(cacheSettings)do
		settings[k]=v;
	end
	hook.Call("ESPostSettingsLoaded",GAMEMODE,settings,true);
end);

util.AddNetworkString("exclserver.settings.send")
hook.Add("ESPlayerReady","exclserver.settings.sendToAll",function(ply)
	net.Start("exclserver.settings.send")
	net.WriteTable(settings)
	net.Send(ply)
	ES.DebugPrint("Sending settings to "..ply:Nick());
end)

--Network
net.Receive("exclserver.settings.send",function(len,ply)
	if not IsValid(ply) or ply:ESGetRank():GetPower() < ES.POWER_OWNER then return ply:ESSendNotificationPopup("Error","You need at least Owner rank to set settings") end

	local setti=net.ReadString()

	local fnType=settingsTypeFn[setti]
	if not fnType then return end

	local var=fnType(net.ReadString())

	if not var then return end

	ES.SetSetting(setti,var)

	ply:ESSendNotificationPopup("Success",setti.." was set to "..var)
end)
