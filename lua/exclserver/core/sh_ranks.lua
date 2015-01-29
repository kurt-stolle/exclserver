-- Meta tables for ES.Ranks.
local rankMeta = {};
AccessorFunc(rankMeta,"simpleName","SimpleName",FORCE_STRING);
AccessorFunc(rankMeta,"prettyName","PrettyName",FORCE_STRING);
AccessorFunc(rankMeta,"power","Power",FORCE_NUMBER);
function rankMeta:__eq(compare)
	if self:GetPower() == compare:GetPower() then
		return true;
	end
	return false;
end
function rankMeta:__lt(compare)
	if self:GetPower() < compare:GetPower() then
		return true;
	end
	return false;
end
function rankMeta:__le(compare)
	return (self < compare or self == compare);
end
function rankMeta:__tostring()
	return self:GetSimpleName();
end

-- Function to add ranks, ES.Ranks.
ES.Ranks = {};
setmetatable(ES.Ranks,{
	__index=function(self,key)
		for num,rank in ipairs(self)do
			if rank:GetSimpleName() == key or rank:GetPrettyName() == key then
				return rank;
			end
		end
		return self[1] or nil;
	end,
})
function ES.SetupRank(name,pretty,power)
	local rank = {}
	setmetatable(rank,rankMeta);
	rankMeta.__index = rankMeta;

	rank:SetSimpleName(string.lower(name));
	rank:SetPrettyName(pretty);
	rank:SetPower(power);

	table.insert(ES.Ranks,rank);

	ES.DebugPrint("Setup rank: "..pretty.." (power "..power..")");
end

ES.SetupRank("user","User"						,0); -- Do not delete or edit any of these ES.Ranks! 
ES.SetupRank("admin","Administrator"			,20) -- Do not add ES.Ranks in the code, use MySQL instead! See the ES.Ranks table.
ES.SetupRank("superadmin","Super Administrator"	,40) -- Editing any of these ES.Ranks will cause some plugins to stop functioning correctly!
ES.SetupRank("operator","Server Operator"		,60) -- 
ES.SetupRank("owner","Server Owner"				,80) --

-- grabbers
local PLAYER = FindMetaTable("Player");
function ES.RankExists(name)
	return !(not ES.Ranks[name]);
end
function PLAYER:ESIsRank(r)
	return (tostring(self:ESGetRank()) == string.lower(r));
end
function PLAYER:ESIsRankOrHigher(r)
	return (ES.Ranks[r] and self:ESGetRank() >= ES.Ranks[r]);
end
function PLAYER:ESIsImmuneTo(p)
	return ( IsValid(p) and p != self and self:ESIsRankOrHigher( tostring(self:ESGetRank()) ) );
end
function PLAYER:ESGetRank()
	return ES.Ranks[self:ESGetNetworkedVariable("rank","user")];
end
function PLAYER:ESHasPower(pwr)
	return (self:ESGetRank():GetPower() >= pwr);
end

-- Compatability functions
local oldIsAdmin = PLAYER.IsAdmin;
function PLAYER:IsAdmin()
	return (self:ESIsRankOrHigher("admin") or oldIsAdmin(self));
end

local oldIsSAdmin = PLAYER.IsSuperAdmin;
function PLAYER:IsSuperAdmin()
	return (self:ESIsRankOrHigher("superadmin") or oldIsSAdmin(self));
end
PLAYER.IsUserGroup = PLAYER.ESIsRankOrHigher;
