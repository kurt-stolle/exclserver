-- sv_log.lua
hook.Add("ESDBDefineTables","ES.DataDefine.Logs",function()
	ES.DBDefineTable("logs",false,"steamid varchar(100), ip varchar(100), nick varchar(100), text varchar(255), type varchar(100), time int(32), serverid int(32)");
end)

ES.LOG_DEBUG = 1;
ES.LOG_COMMAND = 2;
ES.LOG_CHAT = 4;
ES.LOG_ERROR = 8;
ES.LOG_OTHER = 16;

local logfile;
function ES.Log(logtype,text)
	if not logtype or not text then 
		ES.DebugPrint("Failed to log; bad arguments!");
		return
	end

	if not logfile then
		if not file.IsDir("es_logs", "DATA") then
			file.CreateDir("es_logs")
		end
		logfile = "es_logs/"..os.date("%d_%m_%Y_%I_%M_%p")..".txt"
		file.Write(logfile, "ExclServer Log (session: "..os.date("%d/%m/%Y %I:%M %p")..")\n\n\n["..os.date().. "]\t".. text)
		return
	end
	file.Append(logfile, "\n["..os.date().. "]\t"..(text or ""))
end

local logTemp = {};
local triggered = false;
function ES.LogDB(ply,text,typ)
	logTemp[#logTemp+1] = "('"..ply:SteamID().."', '"..ply:IPAddress().."', '"..ES.DBEscape(ply:Nick()).."', '"..ES.DBEscape(text).."', '"..typ.."', "..os.time()..", "..ES.ServerID..")";

	if triggered then return end
	
	triggered = true;
	timer.Simple(6,function()
		ES.DBQuery("INSERT INTO es_logs (steamid, ip, nick, text, type, time, serverid) VALUES "..table.concat(logTemp,", ")..";");
		triggered = false;
		logTemp = {};
	end)
end

hook.Add("PlayerSay","exclIsWatchingYouChatLogs",function(p,t)
	if IsValid(p) and t then
		ES.Log(p:Nick().." ("..p:SteamID().." | "..p:IPAddress()..") : "..string.gsub(t,"\\","/"));
		ES.LogDB(p,t,"chat");
	end
end);
