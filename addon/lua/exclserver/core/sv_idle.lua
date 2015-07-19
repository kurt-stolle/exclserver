-- sv_idle.lua
util.AddNetworkString("ES.Idle")

net.Receive("ES.Idle",function(len,p)
	p:ESSetNetworkedVariable("idle",net.ReadBit() or false)

	hook.Call("ESPlayerIdle",GAMEMODE,p)
end)
