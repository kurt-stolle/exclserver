-- sv_settings.lua
-- handles the setting system

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
function ES.GetSetting(name,def)
	return settings[name] or def;
end
function ES.SetSetting(name,value,serverid)
	serverid=tonumber(serverid) or 0

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

hook.Add("ESDatabaseReady","ES.LoadSettings",function()
	ES.DBQuery("SELECT name,value,serverid FROM `es_settings` WHERE serverid="..ES.ServerID.." OR serverid=0;",function(res)
		if res and res[1] then
			for k,v in ipairs(res)do
				if settings[v.name] and tonumber(v.serverid) == 0 then
					settings[v.name]=settingsTypeFn[v.name](v.value)
				end
			end
			for k,v in ipairs(res)do
				if settings[v.name] and tonumber(v.serverid) ~= 0 then
					settings[v.name]=settingsTypeFn[v.name](v.value)
				end
			end
		end
	end)
end)
