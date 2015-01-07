-- sh_achievements.lua
ES.Achievements = {};

function ES:DefineAchievement(identity, name, description, progressNeeded, icon, hidden, nonotify,earnsilent)
	ES.Achievements[identity] = {id = identity, name = name, descr = description, progressNeeded = progressNeeded, icon = icon, hidden = (hidden or false), nonotify = (nonotify or false), earnsilent = (earnsilent or false)};
end

ES:DefineAchievement("shop_buy", "My first...", "Buy an item from the ExclServer shop.", 1, Material("excl/achies/first.png"),false,false,false);
ES:DefineAchievement("fall_times", "The fallen", "Fall from a distance at least 50 times.", 50, Material("excl/achies/fallen.png"),false,false,false);
ES:DefineAchievement("vip_carebear", "High society", "Purchase Carebear VIP.", 1, Material("excl/achies/vip.png"),false,false,false);
ES:DefineAchievement("bananas_amount", "Savings", "Own over 50.000 bananas.", 1, Material("excl/achies/piggy.png"),false,false,false);
ES:DefineAchievement("bananas_count", "Banana bunch millionaire", "Gain over 100.000 bananas.", 100000, Material("excl/achies/banana.png"),false,true,false);
ES:DefineAchievement("funny","Standup comedy","Tell over 50 jokes",50,Material("excl/achies/comedy.png"),true,false,false);
--ES:DefineAchievement("jb_guard","You're hired!","Pass the required guard test on any of the JailBreak servers.",1,Material("icon64/tool.png"),false,false,false);
--ES:DefineAchievement("donate","Eternal love","Donate $1 or more to Casual Bananas to gain the community's eternal love",1,Material("excl/achies/money.png"),false,false,false);
--ES:DefineAchievement("warden","WarDON'T","Kill the warden",1, Material("icon64/tool.png"),false,false,false);
--ES:DefineAchievement("betraythis","Betray this","Kill 30 traitors",30, Material("icon64/tool.png"),false,false,true);
--ES:DefineAchievement("backstab","Backstabbed","Stab a detective in the back",1, Material("icon64/tool.png"),false,false,true)

local pmeta = FindMetaTable("Player");
function pmeta:ESHasCompletedAchievement(id)
	return self.excl and self.excl.achievements and self.excl.achievements[id] and ES.Achievements[id] and self.excl.achievements[id] >= ES.Achievements[id].progressNeeded;
end