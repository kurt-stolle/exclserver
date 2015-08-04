-- Write things into the database every 1 second to avoid too many calls to mysql.
local databaseBuffer={}
timer.Create("ES.Logs.WriteBuffer",1,0,function()
	if not databaseBuffer[1] then return end

	ES.DBQuery("INSERT INTO `es_logs` (text,type,time,serverid) VALUES "..table.concat(databaseBuffer,","));

	databaseBuffer={};
end);

-- The logging function
ES.LOG_OTHER = 0
ES.LOG_COMMAND = 1
ES.LOG_CHAT = 2
ES.LOG_ERROR = 4
function ES.Log(logtype,text)
	if not logtype or not text then
		return
	end

	table.insert(databaseBuffer,"('"..ES.DBEscape(text).."',"..logtype..","..os.time()..","..ES.ServerID..")");
end

-- Logging hooks
hook.Add("PlayerSay","exclserver.log.chat",function(p,t)
	if IsValid(p) and p:IsPlayer() and t then
		ES.Log(ES.LOG_CHAT,p:Nick().." ("..p:SteamID().."): "..string.gsub(t,"\\","/"))
	end
end)

hook.Add("ESError","exclserver.log.error",function(error,data)
	ES.Log(ES.LOG_ERROR,error..": "..data)
end)
