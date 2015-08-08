-- Getting a setting
local settings={}
function ES.GetSetting(name)
	return settings[name] or ES.Error("SETTING_GET_NOT_FOUND",name) and nil;
end

-- Receive settings
net.Receive("exclserver.settings.send",function()
  settings=net.ReadTable()
end)
