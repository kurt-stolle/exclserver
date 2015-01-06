function exclPlayerBySteamID(sid)
	for k,v in pairs(player.GetAll())do
		if IsValid(v) and v:SteamID() == sid then
			return v;
		end
	end
	return nil;
end