-- sh_ranks
-- the rank system.
hook.Add("ES.DefineNetworkedVariables","ES.RankVariables",function()
	ES.DefineNetworkedVariable("rank","String",nil,true);
end);


local pmeta = FindMetaTable("Player");

local ranks = {};
function ES:SetupRank(name,pretty,power)
	ranks[name] = {
		name=string.lower(name),
		pretty=pretty,
		power=tonumber(power),
	};
end
function ES:CountRanks()
	return table.Count(ranks);
end

ES:SetupRank("user","User"						,0); -- Do not delete or edit any of these ranks! 
ES:SetupRank("admin","Administrator"			,20) -- Do not add ranks in the code, use MySQL instead! See the ranks table.
ES:SetupRank("superadmin","Super Administrator"	,40) -- Editing any of these ranks will cause some plugins to stop functioning correctly!
ES:SetupRank("operator","Server Operator"		,60) -- 
ES:SetupRank("owner","Server Owner"				,80) --

-- grabbers
function ES:RankExists(name)
	return !(not ranks[name]);
end
function pmeta:ESIsRank(r)
	return (string.lower(self:ESGetRankName()) == string.lower(r));
end
function pmeta:ESIsRankOrHigher(r)
	return (IsValid(self) and r and ranks and ranks[r] and self:ESGetRank() and self:ESGetRank().power >= ranks[r].power );
end
function pmeta:ESIsImmuneTo(p)
	return ( IsValid(p) and p != self and self:ESIsRankOrHigher( p:ESGetRankName() ) );
end
function pmeta:ESGetRank()
	return ranks[self:ESGetRankName()];
end
function pmeta:ESGetRankName()
	return self:ESGetGlobalData("rank","user");
end
function pmeta:ESHasPower(pwr)
	return (self:ESGetRank().power >= pwr);
end


-- legacy gmod
local oldIsAdmin = pmeta.IsAdmin;
function pmeta:IsAdmin()
	return (self:ESIsRankOrHigher("admin") or oldIsAdmin(self));
end

local oldIsSAdmin = pmeta.IsSuperAdmin;
function pmeta:IsSuperAdmin()
	return (self:ESIsRankOrHigher("superadmin") or oldIsSAdmin(self));
end
pmeta.IsUserGroup = pmeta.ESIsRankOrHigher;

if SERVER then

	hook.Add("ESDBDefineTables","esCreateRankTables",function() 
		ES.DBDefineTable( "ranks_config",false,"name varchar(100), prettyname varchar(200), power int(16)");
		ES.DBDefineTable( "ranks",false,	"steamid varchar(50), serverid int(10), rank varchar(100)" );
	end)

	hook.Add("Initialize","esGetDBRanksConfig",function()
		ES.DBQuery("SELECT * FROM es_ranks_config;",function(r)
			if not r or not r[1] then return end
			for k,v in pairs(r)do
				ES:SetupRank(v.name,v.prettyname,tonumber(v.power));
			end
		end);
	end);

	util.AddNetworkString("ESSynchRankConfig");
	function pmeta:ESSynchRankConfig()
		net.Start("ESSynchRankConfig");
		net.WriteTable(ranks);
		net.Send(self);
	end

	function pmeta:ESSetRank(r,global)
		if !ranks[r] or not ES.ServerID or not self.excl then return end
		
		self:ESSetGlobalData("rank",r)

		if r != "user" then
			if global then -- the rank must be set globally
				
				if self.excl.globalrank and self.excl.globalrank != "user" then -- he must already be in the db
					ES.DBQuery("UPDATE es_ranks SET rank = '"..r.."' WHERE steamid = '"..self:SteamID().."' AND serverid = 0;");
				else
					ES.DBQuery("INSERT INTO es_ranks SET rank = '"..r.."', steamid = '"..self:SteamID().."', serverid = 0;");
				end

				self.excl.globalrank = r;
				
			else -- the rank must be set only on this server

				if self.excl.localrank and self.excl.localrank != "user" then -- he must already be in the db
					ES.DBQuery("UPDATE es_ranks SET rank = '"..r.."' WHERE steamid = '"..self:SteamID().."' AND serverid = "..ES.ServerID..";");
				else
					ES.DBQuery("INSERT INTO es_ranks SET rank = '"..r.."', steamid = '"..self:SteamID().."', serverid = "..ES.ServerID..";");
				end

				self.excl.localrank = r;

			end
		else
			if global then
				ES.DBQuery("DELETE FROM es_ranks WHERE steamid = '"..self:SteamID().."' AND serverid = 0;")
			else
				ES.DBQuery("DELETE FROM es_ranks WHERE steamid = '"..self:SteamID().."' AND serverid = "..ES.ServerID..";")
			end
		end
	end
	function pmeta:ESLoadRank()
		if not ES.ServerID or not self.excl then return end
		
		ES.DBQuery("SELECT rank,serverid FROM `es_ranks` WHERE steamid = '"..self:SteamID().."' AND (serverid = 0 OR serverid = "..ES.ServerID..") LIMIT 2;",function(s)
				if s and s[1] and IsValid(self) then
					for k,v in pairs(s)do
						if v and v.rank and v.serverid and ranks[ v.rank ] then
							if tonumber(v.serverid) == 0 and v.rank != "user" then
								self.excl.globalrank = v.rank;
							else
								self.excl.localrank = v.rank;
							end
						end
					end

					if self.excl.globalrank or self.excl.localrank then
						self:ESSetGlobalData("rank",self.excl.globalrank or self.excl.localrank);
					end
				end
				--[[
				ES.DBQuery("SELECT rank FROM `es_ranks` WHERE steamid = '"..self:SteamID().."' AND serverid = "..ES.ServerID.." LIMIT 1;",function(r)
					if r and r[1] and ranks[ r[1].rank ] then
						self.excl.localrank = r[1].rank;
						self:ESSetGlobalData("rank",ranks[r[1].rank].name);
					else
						self.excl.localrank = "user";
					end

					self:ESSetGlobalData("rank",self.excl.globalrank or self.excl.localrank);
				end)]]
		end)
	end
end