-- sh_achievements.lua
ES.Achievements = {}

function ES.DefineAchievement(identity, name, description, progressNeeded, icon, hidden, nonotify,earnsilent)
	ES.Achievements[identity] = {id = identity, name = name, descr = description, progressNeeded = progressNeeded, icon = icon, hidden = (hidden or false), nonotify = (nonotify or false), earnsilent = (earnsilent or false)}
end

ES.DefineAchievement("shop_buy", "My first...", "Buy an item from the ExclServer shop.", 1, Material("exclserver/achies/first.png"),false,false,false)
ES.DefineAchievement("fall_times", "The fallen", "Fall from a distance at least 50 times.", 50, Material("exclserver/achies/fallen.png"),false,false,false)
ES.DefineAchievement("vip_carebear", "High society", "Purchase Carebear VIP.", 1, Material("exclserver/achies/vip.png"),false,false,false)
ES.DefineAchievement("bananas_amount", "Savings", "Own over 50.000 bananas.", 1, Material("exclserver/achies/piggy.png"),false,false,false)
ES.DefineAchievement("bananas_count", "Banana bunch millionaire", "Gain over 100.000 bananas.", 100000, Material("exclserver/achies/banana.png"),false,true,false)
ES.DefineAchievement("funny","Standup comedy","Tell over 50 jokes",50,Material("exclserver/achies/comedy.png"),true,false,false)
