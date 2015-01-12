local PLAYER=FindMetaTable("Player");

util.AddNetworkString("ESSynchRankConfig");
hook.Add("PlayerInitialSpawn","ES.SynchRanks",function(ply)
	net.Start("ESSynchRankConfig");
	net.WriteTable(ES.Ranks);
	net.Send(ply);
end)

function PLAYER:ESSetRank(r,global)
	if !ES.Ranks[r] or not ES.ServerID then return end
		
	self:ESSetNetworkedVariable("rank",r)

	if r != "user" then
		if global then -- the rank must be set globally
			if self._es_globalrank and self._es_globalrank != "user" then -- he must already be in the db
				ES.DBQuery("UPDATE `es_ranks` SET rank = '"..r.."' WHERE steamid = '"..self:SteamID().."' AND serverid = 0;");
			else
				ES.DBQuery("INSERT INTO `es_ranks` SET rank = '"..r.."', steamid = '"..self:SteamID().."', serverid = 0;");
			end
			self._es_globalrank = r;
		else -- the rank must be set only on this server
			if self._es_localrank and self._es_localrank != "user" then -- he must already be in the db
				ES.DBQuery("UPDATE `es_ranks` SET rank = '"..r.."' WHERE steamid = '"..self:SteamID().."' AND serverid = "..ES.ServerID..";");
			else
				ES.DBQuery("INSERT INTO `es_ranks` SET rank = '"..r.."', steamid = '"..self:SteamID().."', serverid = "..ES.ServerID..";");
			end
			self._es_localrank = r;
		end
	else
		if global then
			ES.DBQuery("DELETE FROM `es_ranks` WHERE steamid = '"..self:SteamID().."' AND serverid = 0;")
		else
			ES.DBQuery("DELETE FROM `es_ranks` WHERE steamid = '"..self:SteamID().."' AND serverid = "..ES.ServerID..";")
		end
	end
end
function PLAYER:ESLoadRank()
	if not ES.ServerID or not self.excl then return end
	
	ES.DBQuery("SELECT rank,serverid FROM `es_ranks` WHERE steamid = '"..self:SteamID().."' AND (serverid = 0 OR serverid = "..ES.ServerID..") LIMIT 2;",function(s)
			if s and s[1] and IsValid(self) then
				for k,v in pairs(s)do
					if v and v.rank and v.serverid and ES.Ranks[ v.rank ] then
						if tonumber(v.serverid) == 0 and v.rank != "user" then
							self._es_globalrank = v.rank;
						else
							self._es_localrank = v.rank;
						end
					end
				end
				if self._es_globalrank or self._es_localrank then
					self:ESSetNetworkedVariable("rank",self._es_globalrank or self._es_localrank);
				end
			end
	end)
end