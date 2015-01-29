-- sv_misc.lua

util.AddNetworkString("ESCmdOnlyOne");
function ES.SendMessagePlayerTried(ply,vic,msg)
	net.Start("ESTriedRun");
	net.WriteEntity(ply);
	net.WriteString(vic);
	net.WriteString(msg);
	net.Broadcast();
end

local oldCleanUp = game.CleanUpMap;
function game.CleanUpMap(send,filters)
	if not filters then filters = {} end
	
	table.insert(filters,"es_blockade");
	table.insert(filters,"es_advert");

	oldCleanUp(send or false, filters)
end