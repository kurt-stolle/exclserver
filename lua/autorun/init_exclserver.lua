AddCSLuaFile()

-- Tables and variables
local cvarDebug = CreateConVar("excl_debug","0",{FCVAR_ARCHIVE})

ES = {}
setmetatable(ES,{
	__index = function(tbl,key)
		if key == "Debug" then
			return cvarDebug:GetBool();
		end
		return nil;
	end
})
ES.version = "4.7.0"
ES.PostInitialize = false;
COLOR_EXCLSERVER = Color(102,255,51,255);
COLOR_EXCLSERVER_DEBUG_CLIENT = Color(255,204,51);
COLOR_EXCLSERVER_DEBUG_SERVER = Color(51,204,255);
COLOR_WHITE = Color(255,255,255,255);
COLOR_EXCLSERVER_DEBUG = Color(213,213,213,255);
-- Debug methods
function ES.DebugPrint(s)
	if not cvarDebug:GetBool() or not s then return end
	
	MsgC(SERVER and COLOR_EXCLSERVER_DEBUG_SERVER or COLOR_EXCLSERVER_DEBUG_CLIENT,"[ES] ");
	MsgC(COLOR_EXCLSERVER_DEBUG,tostring(s).."\n");
end
ES.DebugPrint("Initializing ExclServer @ version "..ES.version);

local path = "exclserver/";
function ES.Include(name, folder, runtype)

	if not runtype then
		runtype = string.Left(name, 2);
	end

	if not runtype or ( runtype ~= "sv" and runtype ~= "sh" and runtype ~= "cl" ) then ErrorNoHalt("Could not include file, no prefix!"); return false; end
	
	path = "";

	if folder then
		path = path .. folder .. "/";
	end

	path = path .. name;
		
	if SERVER then
		if runtype == "sv" then
			ES.DebugPrint("> Loading... "..path);
			include(path);
		elseif runtype == "sh" then
			ES.DebugPrint("> Loading... "..path);
			include(path);
			AddCSLuaFile(path);
		elseif runtype == "cl" then		
			AddCSLuaFile(path);
		end
	elseif CLIENT then
		if (runtype == "sh" or runtype == "cl") then	
			ES.DebugPrint("> Loading... "..path);
			include(path);
		end
	end

	return true;
end


function ES.IncludeFolder(folder,runtype)
	ES.DebugPrint("Initializing "..folder)

	local exp=(string.Explode("/",folder,false))[1];
	
	for k,v in pairs(file.Find(folder.."/*.lua","LUA")) do
		ES.Include(v, folder, runtype);
	end	
end

ES.IncludeFolder ("exclserver/util");
ES.IncludeFolder ("exclserver/core");
ES.IncludeFolder ("exclserver/vgui", "cl");
ES.IncludeFolder ("exclserver/plugins", "sh");

ES.PostInitialize = true;