-- sv_achievements.lua

util.AddNetworkString("ESAchSynch")
util.AddNetworkString("ESAchProgr")
util.AddNetworkString("ESAchEarned")

hook.Add("ESDatabaseReady","ESAchiesDatatableSetup",function()
	ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_achievements` (`id` int unsigned not null AUTO_INCREMENT, steamid varchar(100), achname varchar(100), progress int unsigned not null default 0, PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1")
end)

local PLAYER = FindMetaTable("Player")
function PLAYER:ESAddAchievementProgress(id,number)
	if ( self:ESHasCompletedAchievement(id) and self._es_achHasInit ) or not ES.Achievements[id] then return end

	if not self._es_achievements then
		self._es_achievements = {}
		self._es_achievements[id] = number
	else
		self._es_achievements[id] = self._es_achievements[id] and (self._es_achievements[id] + number) or number
	end

	ES.DBQuery("SELECT id FROM es_achievements WHERE steamid = '"..self:SteamID().."' AND achname = '"..id.."' LIMIT 1;",function(res)
		if res and res[1] and res[1].id then
			ES.DBQuery("UPDATE es_achievements SET progress = progress + "..number.." WHERE id="..tostring(res[1].id)..";")
		else
			ES.DBQuery("INSERT INTO es_achievements SET steamid = '"..self:SteamID().."', achname='"..id.."', progress = "..self._es_achievements[id]..";")
		end
	end)


	if self._es_achievements[id] >= ES.Achievements[id].progressNeeded then
		net.Start("ESAchEarned")
		net.WriteEntity(self)
		net.WriteString(id)

		if ES.Achievements[id].earnsilent then
			net.Send(self)
		else
			net.Broadcast()
		end

		self:ESGiveBananas(100)

		return
	end

	net.Start("ESAchProgr")
	net.WriteString(id)
	net.WriteUInt(self._es_achievements[id],32)
	net.Send(self)
end

hook.Add("ESPlayerReady","ES.LoadPlayerAchievemenets",function(ply)
	ES.DBQuery("SELECT * FROM es_achievements WHERE steamid = '"..ply:SteamID().."';",function(res)
		if res and res[1] then

			ply._es_achievements = {}
			for k,v in ipairs(res)do
				ply._es_achievements[v.achname] = tonumber(v.progress)

			end

			net.Start("ESAchSynch")
			net.WriteTable(ply._es_achievements)
			net.Send(ply)
		end

		ply._es_achHasInit=true
	end)
end)

hook.Add("GetFallDamage", "ES.AchFall", function(p)
	if IsValid(p) then
		p:ESAddAchievementProgress("fall_times",1)
	end
end)
