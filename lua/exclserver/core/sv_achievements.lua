-- sv_achievements.lua

util.AddNetworkString("ESAchSynch");
util.AddNetworkString("ESAchProgr");
util.AddNetworkString("ESAchEarned");

hook.Add("ESPreCreateDatatables","ESAchiesDatatableSetup",function()
	local str = "";
	for k,v in pairs(ES.Achievements)do
		str = str..", "..k.." int(9) NOT NULL";
	end

	ES:DefineDataTable("achievements",false,"steamid varchar(100)"..str);
end)

local pmeta = FindMetaTable("Player");
function pmeta:ESAddAchievementProgress(id,number)
	if not self.excl or self:ESHasCompletedAchievement(id) then return end

	if not self.excl.achievements then 
		self.excl.achievements = {};
		self.excl.achievements[id] = number; 
		return;
	end
	
	self.excl.achievements[id] = self.excl.achievements[id] and (self.excl.achievements[id] + number) or number;

	ES.DBQuery("INSERT INTO es_achievements SET id = "..self:NumSteamID()..", steamid = '"..self:SteamID().."', "..id.." = "..self.excl.achievements[id].." ON DUPLICATE KEY UPDATE  "..id.." = "..id.." + "..number..";");

	if self.excl.achievements[id] >= ES.Achievements[id].progressNeeded then
		net.Start("ESAchEarned");
		net.WriteEntity(self);
		net.WriteString(id);

		if ES.Achievements[id].earnsilent then
			net.Send(self);
		else
			net.Broadcast();
		end

		self:ESGiveBananas(100);

		return
	end
	net.Start("ESAchProgr");
	net.WriteString(id);
	net.WriteUInt(self.excl.achievements[id],32);
	net.Send(self);
end

function pmeta:LoadAchievements()
	ES.DBQuery("SELECT * FROM es_achievements WHERE steamid = '"..self:SteamID().."' LIMIT 1;",function(res)
		if res and res[1] then
			self.excl.achievements = {};
			for k,v in pairs(res[1])do
				self.excl.achievements[k] = v;
				net.Start("ESAchSynch");
				net.WriteTable(self.excl.achievements);
				net.Send(self);
			end
		end
	end)
end

hook.Add("GetFallDamage", "ESAchFall", function(p)
	if IsValid(p) and p.excl then
		p:ESAddAchievementProgress("fall_times",1);
	end
end);
