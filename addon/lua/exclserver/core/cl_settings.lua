-- Getting a setting
local settings={}
function ES.GetSetting(name,default)
	return settings[name] or settings[name] == nil and ES.Error("SETTING_GET_NOT_FOUND",name) and default;
end

function ES.GetSettings()
	return table.Copy(settings);
end

-- Receive settings
net.Receive("exclserver.settings.send",function()
  settings=net.ReadTable()
	ES.DebugPrint("Received new settings table.",ES.GetSettings())

	hook.Call("ESSettingsChanged",GAMEMODE,settings);
end)
