local pmeta = FindMetaTable("Player");

function pmeta:ESGetBananas()
	return self:ESGetGlobalData("bananas",0);
end

function ES:IsCasualFriday()
	return GetGlobalBool("casualfriday",false);
end

if SERVER then
	util.AddNetworkString("ESSynchBnns");

	function pmeta:ESSetBananas( a, nosave )
		if !self.excl or !self:ESGetGlobalData("bananas",false) or tonumber( a ) < 0 then return end
		a =  tonumber( a );
		if !nosave then
			ES.DBQuery("UPDATE es_player SET bananas = bananas + "..tostring(a - self:ESGetGlobalData("bananas",0)).." WHERE id = "..self:NumSteamID()..";");
		end
		--self.excl.bananas = a;

		self:ESSetGlobalData("bananas",a);

		if a > 50000 then
			self:ESAddAchievementProgress("bananas_amount",1);
		end

		--net.Start("ESSynchBnns");
		--net.WriteUInt(self.excl.bananas,32);
		--net.Send(self);
	end
	function pmeta:ESGetBananas()
		return tonumber(self:ESGetGlobalData("bananas",0));
	end	
	function pmeta:ESAddBananas( a )
		self:ESSetBananas( a + self:ESGetBananas() );

		if a > 0 then
			self:ESAddAchievementProgress("bananas_count",a);
		end
	end
	function pmeta:ESTakeBananas( a )
		self:ESAddBananas( -a );
	end
	pmeta.ESRemoveBananas = pmeta.ESTakeBananas;
	pmeta.ESGiveBananas = pmeta.ESAddBananas;
	
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