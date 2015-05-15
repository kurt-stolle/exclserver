AddCSLuaFile()

ES = {}

ES.debug = game.SinglePlayer()

if ES.debug then
	_G["Error"]=_G["ErrorNoHalt"];
end

ES.version = "6.x.x"

-- Debug methods
local color_debug_text=Color(255,255,255)
local color_debug_client=Color(245,184,0)
local color_debug_server=Color(0,200,255)
function ES.DebugPrint(s)
	if not ES.debug or not s then return end

	MsgC(SERVER and color_debug_server or color_debug_client,"[ES] ")
	MsgC(color_debug_text,tostring(s).."\n")
end
ES.DebugPrint("Initializing ExclServer @ version "..ES.version)

local path = "exclserver/"
function ES.Include(name, folder, runtype)

	if not runtype then
		runtype = string.Left(name, 2)
	end

	if not runtype or ( runtype ~= "sv" and runtype ~= "sh" and runtype ~= "cl" ) then ErrorNoHalt("Could not include file, no prefix!") return false end

	path = ""

	if folder then
		path = path .. folder .. "/"
	end

	path = path .. name

	if SERVER then
		if runtype == "sv" then
			ES.DebugPrint("> Loading... "..path)
			include(path)
		elseif runtype == "sh" then
			ES.DebugPrint("> Loading... "..path)
			include(path)
			AddCSLuaFile(path)
		elseif runtype == "cl" then
			AddCSLuaFile(path)
		end
	elseif CLIENT then
		if (runtype == "sh" or runtype == "cl") then
			ES.DebugPrint("> Loading... "..path)
			include(path)
		end
	end

	return true
end


function ES.IncludeFolder(folder,runtype)
	ES.DebugPrint("Initializing "..folder)

	local exp=(string.Explode("/",folder,false))[1]

	for k,v in pairs(file.Find(folder.."/*.lua","LUA")) do
		ES.Include(v, folder, runtype)
	end
end

ES.IncludeFolder ("exclserver/util")
ES.IncludeFolder ("exclserver/core")
ES.IncludeFolder ("exclserver/vgui", "cl")
ES.IncludeFolder ("exclserver/plugins", "sh")
