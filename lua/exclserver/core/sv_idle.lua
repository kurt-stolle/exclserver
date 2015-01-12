-- sv_idle.lua
ES.AntiIdle = true;

util.AddNetworkString("ESIdleMessage")

concommand.Add("excl_idle",function(p)
	if !ES.AntiIdle then return end

	hook.Call("ESPlayerIdle",GAMEMODE,p,true);

	net.Start("ESIdleMessage");
	net.Send(p);

	for k,v in pairs(player.GetAll())do
		if v == p or !IsValid(v) then continue end

		v:ESChatPrint("server",p:Nick().." has been moved to spectate mode (idle for too long).")
	end
end);

concommand.Add("excl_idle_disable",function(p)
	if !ES.AntiIdle then return end
	
	hook.Call("ESPlayerIdle",GAMEMODE,p,false);
end)

