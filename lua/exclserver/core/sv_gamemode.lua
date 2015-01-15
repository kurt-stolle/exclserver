-- sv_gamemode.lua

hook.Add("PostGamemodeLoad","ES.ImplementHooks",function()
	if type(GAMEMODE.ESPlayerReady) ~= "function" then
		GAMEMODE.ESPlayerReady = function(ply)
			return nil;
		end
	end
end);