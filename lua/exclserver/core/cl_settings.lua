-- Getting a setting
local settings={}
function ES.GetSetting(name,default)
	if type(settings[name]) == "nil" then
		ES.Error("SETTING_GET_NOT_FOUND",name);
		return default;
	end

	return settings[name];
end

function ES.GetSettings()
	return table.Copy(settings);
end

-- Receive settings
net.Receive("exclserver.settings.send",function()
  settings=net.ReadTable()
	ES.DebugPrint("Received new settings table.")

	timer.Simple(0,function()
		hook.Call("ESSettingsChanged",GAMEMODE,settings);
	end);
end)
