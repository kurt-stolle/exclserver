-- sv_achievements.lua

util.AddNetworkString("ESAchSynch")
util.AddNetworkString("ESAchProgr")
util.AddNetworkString("ESAchEarned")

hook.Add("ESDatabaseReady","ESAchiesDatatableSetup",function()
	local str = ""
	for k,v in pairs(ES.Achievements)do
		str = str..", "..k.." int(9) unsigned not null"
	end

	ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_achievements` (`id` int unsigned not null AUTO_INCREMENT, steamid varchar(100)"..str..", PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1"):wait()
end)

local PLAYER = FindMetaTable("Player")
function PLAYER:ESAddAchievementProgress(id,number)
	if self:ESHasCompletedAchievement(id) then return end

	if not self._es_achievements then
		self._es_achievements = {}
		self._es_achievements[id] = number
	else
		self._es_achievements[id] = self._es_achievements[id] and (self._es_achievements[id] + number) or number
	end

	ES.DBQuery("INSERT INTO es_achievements SET steamid = '"..self:SteamID().."', "..id.." = "..self._es_achievements[id].." ON DUPLICATE KEY UPDATE  "..id.." = "..id.." + "..number.."")

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
	ES.DBQuery("SELECT * FROM es_achievements WHERE steamid = '"..ply:SteamID().."' LIMIT 1",function(res)
		if res and res[1] then
			ply._es_achievements = {}
			for k,v in pairs(res[1])do
				ply._es_achievements[k] = v
				net.Start("ESAchSynch")
				net.WriteTable(ply._es_achievements)
				net.Send(ply)
			end
		end
	end)
end)

hook.Add("GetFallDamage", "ES.AchFall", function(p)
	if IsValid(p) then
		p:ESAddAchievementProgress("fall_times",1)
	end
end)
