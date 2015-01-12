-- sv_settings.lua
-- handles the setting system

ES.Settings = {};
local settingIDs = {};
local settingIDsGlobal = {};
function ES:CreateSetting(name,default)
	if ES.PostInitialize then Error("setting "..name.." was defined after ES initialization!") return end

	name = string.gsub(name," ","_");

	ES.Settings[name] = default or 0;
end
function ES:GetSetting(name)
	return ES.Settings[name] or 0;
end
local function booltonum(bool)
	return tonumber(bool) or bool and 1 or 0;
end
function ES:SetSetting(name,value,serverid)
	if not ES.Settings[name] then return end

	serverid = serverid or 0;

	ES.Settings[name] = booltonum(value);

	if settingIDs[name] and serverid > 0 then
		ES.DBQuery("UPDATE es_settings SET value = "..booltonum(value).." WHERE id = "..settingIDs[name]..";")
	elseif settingIDsGlobal[name] and serverid == 0 then
		ES.DBQuery("UPDATE es_settings SET value = "..booltonum(value).." WHERE id = "..settingIDsGlobal[name]..";")
	else
		ES.DBQuery("INSERT INTO es_settings SET value = "..booltonum(value)..", name = '"..name.."', serverid = "..serverid..";",function()
			ES.DBQuery("SELECT id FROM es_settings WHERE name = '"..name.."' AND serverid = "..serverid..";",function(res)
				if res and res[1] and res[1].id then
					settingIDs[name] = res[1].id;
				end
			end)
		end)
	end
end

hook.Add("Initialize","INTIWFYUCKIUNGSETTINGESEXLCSEVRER",function()
	ES.DBQuery("SELECT * FROM es_settings WHERE serverid = "..ES.ServerID.." OR serverid = 0;",function(res)
		ES.DebugPrint("Attempting to load settings...")
		if res and res[1] then
			for k,v in pairs(res)do
				if tonumber(v.serverid) == 0 then
					settingIDsGlobal[v.name] = tonumber(v.serverid);
					if settingIDs[v.name] then continue end -- we already loaded a local variant of this variable
				else
					settingIDs[v.name] = tonumber(v.serverid);
				end

				ES.Settings[v.name] = booltonum(v.value);
				ES.DebugPrint("Loaded setting: "..v.name.." = "..ES.Settings[v.name]);
			end
		end
	end)
end)