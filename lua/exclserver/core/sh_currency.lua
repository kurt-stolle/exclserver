local PLAYER = FindMetaTable("Player");

function ES:IsCasualFriday()
	return GetGlobalBool("casualfriday",false);
end

if SERVER then
	
	
	timer.Create("ESHandOutBananas",900,0,function()
		for k,v in pairs(player.GetAll())do
			timer.Simple(math.random(0,120),function()
				if IsValid(v) and v.excl and v:ESGetGlobalData("bananas",false) then
					v:ESGiveBananas(math.random(2,8));
				end
			end);
		end
	end);

	timer.Create("ESIsCasualFridayUpdate",420,0,function()
		if os.date("%A") == "Friday" then
			SetGlobalBool("casualfriday",true);
		end
	end)

	hook.Add("Initialize","ESInitcasualFriday",function()
		if os.date("%A") == "Friday" then
			SetGlobalBool("casualfriday",true);
		end
	end)
end