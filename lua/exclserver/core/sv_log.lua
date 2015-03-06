-- sv_log.lua
ES.LOG_DEBUG = 1
ES.LOG_COMMAND = 2
ES.LOG_CHAT = 4
ES.LOG_ERROR = 8
ES.LOG_OTHER = 16

local logfile

local databaseBuffer={}
function ES.Log(logtype,text)
	if not logtype or not text then
		return
	end

	if not logfile then
		if not file.IsDir("exclserver", "DATA") then
			file.CreateDir("exclserver")
		end
		if not file.IsDir("exclserver/logs", "DATA") then
			file.CreateDir("exclserver/logs")
		end
		logfile = "exclserver/logs/"..os.date("%d_%m_%Y_%I_%M_%p")..".txt"

		file.Write(logfile, "EXCLSERVER LOG\n"..os.date("%d/%m/%Y %I:%M %p")..")\n\n["..os.date().. "]\t".. text)

		return
	end
	file.Append(logfile, "\n["..os.date().. "]\t"..(text or ""))

	table.insert(databaseBuffer,"('"..ES.DBEscape(text).."',"..logtype..","..os.time()..","..ES.ServerID..")");

	if timer.Exists("ES.Logs.WriteBuffer") then return end

	timer.Create("ES.Logs.WriteBuffer",1,1,function()

		ES.DBQuery("INSERT INTO `es_logs` (text,type,time,serverid) VALUES "..table.concat(databaseBuffer,","));
		databaseBuffer={};
		timer.Remove("ES.Logs.WriteBuffer")
	end);
end

hook.Add("PlayerSay","ES.Logs.BigBrotherChat",function(p,t)
	if IsValid(p) and p:IsPlayer() and t then
		ES.Log(ES.LOG_CHAT,p:Nick().." ("..p:SteamID().."): "..string.gsub(t,"\\","/"))
	end
end)
