-- sh_player_meta

local pmeta = FindMetaTable("Player");
local CacheID={};
local oldUniqueID = pmeta.UniqueID;
function pmeta:UniqueID()
	return CacheID[self] or ( rawset( CacheID,self,oldUniqueID(self) ) )[self];
end
pmeta.NumSteamID = pmeta.UniqueID;

function pmeta:ESGetVIPTier()
	return tonumber(self:ESGetGlobalData("VIP",0) or 0);
end

function pmeta:ESGetGlobalData(name,default)
	if self.exclGlobal and self.exclGlobal[name] then
		return self.exclGlobal[name];
	end
	return default or nil;
end

function pmeta:ESIsInitialized()
	return (not not self.excl);
end