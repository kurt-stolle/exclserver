-- sh_protected
-- the rank system.
hook.Add("ES.DefineNetworkedVariables","ES.RankVariables",function()
	ES.DefineNetworkedVariable("rank","String");
end);

-- Meta tables for protected.
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
	if me:GetPower() < compare:GetPower() then
		return true;
	end
	return false;
end
function rankMeta:__le(compare)
	return (me < compare or me == compare);
end
function rankMeta:__tostring()
	return self:GetSimpleName();
end

-- Function to add ranks, protected.
local protected={};
ES.Ranks = {};
setmetatable(ES.Ranks,{
	__index=function(self,key)
		return rawget(protected,key);
	end,
	__newindex=function(self)
		return nil;
	end,
})
function ES:SetupRank(name,pretty,power)
	local rank = {}
	setmetatable(rank,rankMeta);
	rankMeta.__index = rankMeta;

	rank:SetSimpleName(string.lower(name));
	rank:SetPrettyName(pretty);
	rank:SetPower(power);

	table.insert(protected,rank);
end

ES:SetupRank("user","User"						,0); -- Do not delete or edit any of these protected! 
ES:SetupRank("admin","Administrator"			,20) -- Do not add protected in the code, use MySQL instead! See the protected table.
ES:SetupRank("superadmin","Super Administrator"	,40) -- Editing any of these protected will cause some plugins to stop functioning correctly!
ES:SetupRank("operator","Server Operator"		,60) -- 
ES:SetupRank("owner","Server Owner"				,80) --

-- grabbers
local pmeta = FindMetaTable("Player");
function ES:RankExists(name)
	return !(not protected[name]);
end
function pmeta:ESIsRank(r)
	return (tostring(self:ESGetRank()) == string.lower(r));
end
function pmeta:ESIsRankOrHigher(r)
	return (protected[r] and self:GetRank() >= protected[r]);
end
function pmeta:ESIsImmuneTo(p)
	return ( IsValid(p) and p != self and self:ESIsRankOrHigher( tostring(self:ESGetRank()) ) );
end
function pmeta:ESGetRank()
	return self:ESGetNetworkedVariable("rank");
end
function pmeta:ESHasPower(pwr)
	return (self:ESGetRank().power >= pwr);
end

-- Compatability functions
local oldIsAdmin = pmeta.IsAdmin;
function pmeta:IsAdmin()
	return (self:ESIsRankOrHigher("admin") or oldIsAdmin(self));
end

local oldIsSAdmin = pmeta.IsSuperAdmin;
function pmeta:IsSuperAdmin()
	return (self:ESIsRankOrHigher("superadmin") or oldIsSAdmin(self));
end
pmeta.IsUserGroup = pmeta.ESIsRankOrHigher;
