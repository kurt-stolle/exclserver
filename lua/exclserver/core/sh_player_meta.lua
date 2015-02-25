-- sh_player_meta

local PLAYER = FindMetaTable("Player")
local CacheID={}
local oldUniqueID = PLAYER.UniqueID
function PLAYER:UniqueID()
	return CacheID[self] or ( rawset( CacheID,self,oldUniqueID(self) ) )[self]
end
PLAYER.ESID = PLAYER.UniqueID

function PLAYER:ESGetBananas()
	return self:ESGetNetworkedVariable("bananas",-1)
end

function PLAYER:ESGetVIPTier()
	return self:ESGetNetworkedVariable("VIP",0)
end

function PLAYER:ESIsInitialized()
	return (not not self.excl)
end

function PLAYER:ESHasCompletedAchievement(id)
	return self._es_achievements and self._es_achievements[id] and ES.Achievements[id] and self._es_achievements[id] >= ES.Achievements[id].progressNeeded
end
