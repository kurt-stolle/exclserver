local pmeta=FindMetaTable("Player");
hook.Add("ESDBDefineTables","esCreateRankTables",function() 
	ES.DBDefineTable( "ranks_config",false,"name varchar(100), prettyname varchar(200), power int(16)");
	ES.DBDefineTable( "ranks",false,	"steamid varchar(50), serverid int(10), rank varchar(100)" );
end)

hook.Add("Initialize","esGetDBRanksConfig",function()
	ES.DBQuery("SELECT * FROM es_ES.Ranks_config;",function(data)
		if not data or not data[1] then return end
		for k,v in pairs(data)do
			ES:SetupRank(v.name,v.prettyname,tonumber(v.power));
		end
	end);
	ES.DBWait();
end);

util.AddNetworkString("ESSynchRankConfig");
function pmeta:ESSynchRankConfig()
	net.Start("ESSynchRankConfig");
	net.WriteTable(ES.Ranks);
	net.Send(self);
end

function pmeta:ESSetRank(r,global)
	if !ES.Ranks[r] or not ES.ServerID or not self.excl then return end
		
	self:ESSetNetworkedVariable("rank",r)

	if r != "user" then
		if global then -- the rank must be set globally
			if self.excl.globalrank and self.excl.globalrank != "user" then -- he must already be in the db
				ES.DBQuery("UPDATE `es_ranks` SET rank = '"..r.."' WHERE steamid = '"..self:SteamID().."' AND serverid = 0;");
			else
				ES.DBQuery("INSERT INTO `es_ranks` SET rank = '"..r.."', steamid = '"..self:SteamID().."', serverid = 0;");
			end
			self.excl.globalrank = r;
		else -- the rank must be set only on this server
			if self.excl.localrank and self.excl.localrank != "user" then -- he must already be in the db
				ES.DBQuery("UPDATE `es_ranks` SET rank = '"..r.."' WHERE steamid = '"..self:SteamID().."' AND serverid = "..ES.ServerID..";");
			else
				ES.DBQuery("INSERT INTO `es_ranks` SET rank = '"..r.."', steamid = '"..self:SteamID().."', serverid = "..ES.ServerID..";");
			end
			self.excl.localrank = r;
		end
	else
		if global then
			ES.DBQuery("DELETE FROM `es_ranks` WHERE steamid = '"..self:SteamID().."' AND serverid = 0;")
		else
			ES.DBQuery("DELETE FROM `es_ranks` WHERE steamid = '"..self:SteamID().."' AND serverid = "..ES.ServerID..";")
		end
	end
end
function pmeta:ESLoadRank()
	if not ES.ServerID or not self.excl then return end
	
	ES.DBQuery("SELECT rank,serverid FROM `es_ranks` WHERE steamid = '"..self:SteamID().."' AND (serverid = 0 OR serverid = "..ES.ServerID..") LIMIT 2;",function(s)
			if s and s[1] and IsValid(self) then
				for k,v in pairs(s)do
					if v and v.rank and v.serverid and ES.Ranks[ v.rank ] then
						if tonumber(v.serverid) == 0 and v.rank != "user" then
							self.excl.globalrank = v.rank;
						else
							self.excl.localrank = v.rank;
						end
					end
				end
				if self.excl.globalrank or self.excl.localrank then
					self:ESSetNetworkedVariable("rank",self.excl.globalrank or self.excl.localrank);
				end
			end
	end)
end