AddCSLuaFile()

if jit then
	jit.on();
end
ES = {}

ES.debug = game.SinglePlayer()
if not ES.debug then
	local hostip = GetConVarString( "hostip" )
	hostip = tonumber( hostip )
	hostip = bit.rshift( bit.band( hostip, 0xFF000000 ), 24 ).."."..bit.rshift( bit.band( hostip, 0x00FF0000 ), 16 )

	ES.debug = (hostip == "192.168" or hostip == "10.0") or false;
end
ES.version = "6.x.x"

-- Debug methods
local color_debug_text=Color(255,255,255)
local color_debug_client=Color(245,184,0)
local color_debug_server=Color(0,200,255)

function ES.DebugPrint(...)
	if not ES.debug then return end

	local s="";
	for k,v in ipairs{...}do
		local part;

		if type(v) == "table" then
			part=util.TableToJSON(v)
		elseif type(v) == "Entity" and v:IsPlayer() and IsValid(v) then
			part=v:Nick()
		else
			part=tostring(v)
		end

		s=s.." "..part
	end
	s=s.."\n";

	MsgC(SERVER and color_debug_server or color_debug_client,"[ES "..ES.version.."]")
	MsgC(color_debug_text,s)
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
