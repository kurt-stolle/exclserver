-- sh_player_meta

local pmeta = FindMetaTable("Player");
local CacheID={};
local oldUniqueID = pmeta.UniqueID;
function pmeta:UniqueID()
	return CacheID[self] or ( rawset( CacheID,self,oldUniqueID(self) ) )[self];
end
pmeta.ESID = pmeta.UniqueID;

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

function pmeta:ESHasCompletedAchievement(id)
	return self.excl and self.excl.achievements and self.excl.achievements[id] and ES.Achievements[id] and self.excl.achievements[id] >= ES.Achievements[id].progressNeeded;
end