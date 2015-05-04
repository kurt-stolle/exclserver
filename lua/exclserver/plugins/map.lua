local PLUGIN=ES.Plugin()
PLUGIN:SetInfo("Map","Changes the map.","Excl")

PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NOCANDISABLE)

if SERVER then
	util.AddNetworkString("exclChMap")

	PLUGIN:AddCommand("map",function(p,a)
		if not p or not p:IsValid() or not a or not a[1] or a[1] == "" then return end

		ES.ChatBroadcast("<hl>"..p:Nick().."</hl> has initiated a mapchange to <hl>"..a[1].."</h1>. Loading new map in 5 seconds.");

		timer.Simple(5,function()
			RunConsoleCommand("changelevel",a[1])
		end)
	end,20)

	PLUGIN:AddCommand("restart",function(p,a)
		if not p or not p:IsValid() then return end

		ES.ChatBroadcast("<hl>"..p:Nick().."</hl> has initiated a restart. Restarting in 5 seconds.");

		timer.Simple(5,function()
			RunConsoleCommand("changelevel",game.GetMap())
		end)
	end,20)
end

PLUGIN()
