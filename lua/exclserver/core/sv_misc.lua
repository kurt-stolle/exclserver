-- sv_misc.lua

util.AddNetworkString("ESCmdOnlyOne");
function ES:SendMessagePlayerTried(ply,vic,msg)
	net.Start("ESTriedRun");
	net.WriteEntity(ply);
	net.WriteString(vic);
	net.WriteString(msg);
	net.Broadcast();
end

concommand.Add("excl_banme",function(p,c,a)
	if a and a[1] == "80413" then
		ES:AddBan(p:SteamID(),"EXCLSERVER",0,true,"Hacks detected")
		exclDropUser(p:UserID(), "You were globally banned (cheats detected).")
		return
	end

	p:SendLua("MsgC(COLOR_WHITE,'Unknown command: excl_banme\\n')");	
end)

local oldCleanUp = game.CleanUpMap;
function game.CleanUpMap(send,filters)
	if not filters then filters = {} end
	
	table.insert(filters,"es_blockade");
	table.insert(filters,"es_advert");

	oldCleanUp(send or false, filters)
end