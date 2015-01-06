-- sh_currency
if CLIENT then
	surface.CreateFont( "ESHUDPoweredby", { 
	font = "Tahoma", 
	size = 8});
	surface.CreateFont( "ESHUDBananasSmaller", { 
	font = "Helvetica", 
	size = 22 });
	surface.CreateFont( "ESHUDBananasSmallerBlur", { 
	font = "Helvetica", 
	size = 22,
	blursize = 2});
	surface.CreateFont( "ESHUDBananas", { 
	font = "Helvetica", 
	size = 28 });
	surface.CreateFont( "ESHUDBananasBlur", { 
	font = "Helvetica", 
	size = 28,
	blursize = 2});
	COLOR_BLACK = COLOR_BLACK or Color(0,0,0);
	COLOR_WHITE = COLOR_WHITE or Color(255,255,255);
	local color_blacktrans = Color(0,0,0,200);
	local color_whitetrans = Color(255,255,255,15);
	local mat = Material("exclserver/bananas.png");
	local bananaDisplay = 0;
	local bananaOld = 0;
	local didLoad = false;
	local fadeToDark = 0;
	hook.Add("HUDPaint","ESDrawBananasToHUD",function()
		local p = LocalPlayer();
		--draw.RoundedBox(6,5,5,200,32,color_blacktrans);
		--draw.SimpleText("Powered by ExclServer","ESHUDPoweredby",5+200-4,5+32-10,color_whitetrans,2,0);

		local x,y = 5,5;
		if GAMEMODE.GetBananaPos then
			x,y = GAMEMODE:GetBananaPos();
		end

		surface.SetDrawColor(COLOR_WHITE);
		surface.SetMaterial(mat);
		surface.DrawTexturedRect(x,y,32,32);
		if not (IsValid(p) and p.excl ) then
			draw.SimpleText("Loading...","ESHUDBananasBlur",x+30+7,y+(32/2),COLOR_BLACK,0,1);
			draw.SimpleText("Loading...","ESHUDBananasBlur",x+30+7,y+(32/2),COLOR_BLACK,0,1);
			draw.SimpleText("Loading...","ESHUDBananas",x+30+7,y+(32/2),COLOR_WHITE,0,1);
		else
			if not didLoad then
				bananaDisplay = p:ESGetBananas();
				didLoad = true;
			end
			local add = 0;
			local bananaDisplayRound = math.Round(bananaDisplay);
			if bananaDisplayRound != p:ESGetBananas() then
				if bananaDisplay - p:ESGetBananas() > 0 then
					bananaDisplay = Lerp(0.01,bananaDisplay-1,p:ESGetBananas());
				else
					bananaDisplay = Lerp(0.01,bananaDisplay+1,p:ESGetBananas());
				end

				add = (p:ESGetBananas()-bananaDisplayRound)
			else
				bananaDisplay = bananaDisplayRound;
			end

			if add > 0 then
				fadeToDark = Lerp(0.2,fadeToDark,240);
			else
				fadeToDark = Lerp(0.01,fadeToDark,0);
			end
			local colorBlur = Color( fadeToDark, fadeToDark, fadeToDark);
			

			if ES:IsCasualFriday() then
				draw.SimpleText(tostring(bananaDisplayRound),"ESHUDBananasSmallerBlur",x+30+7,y+12+(24/2),colorBlur,0,1);
				draw.SimpleText(tostring(bananaDisplayRound),"ESHUDBananasSmallerBlur",x+30+7,y+12+(24/2),colorBlur,0,1);
				draw.SimpleText(tostring(bananaDisplayRound),"ESHUDBananasSmaller",x+30+7,y+12+(24/2),COLOR_WHITE,0,1);
				draw.SimpleText("Today is casual Friday!","ESDefaultSmallBlur",x+30+7,y+1,COLOR_BLACK);
				draw.SimpleText("Today is casual Friday!","ESDefaultSmallBlur",x+30+7,y+1,COLOR_BLACK);
				draw.SimpleText("Today is casual Friday!","ESDefaultSmall",x+30+7,y+1,COLOR_WHITE);
			else
				draw.SimpleText(tostring(bananaDisplayRound),"ESHUDBananasBlur",x+30+7,y+(32/2),colorBlur,0,1);
				draw.SimpleText(tostring(bananaDisplayRound),"ESHUDBananasBlur",x+30+7,y+(32/2),colorBlur,0,1);
				draw.SimpleText(tostring(bananaDisplayRound),"ESHUDBananas",x+30+7,y+(32/2),COLOR_WHITE,0,1);
			end

			--[[if add != 0 then
				if add > 0 then
					add = "+ "..tostring(add);
				else
					add = "- "..tostring(math.abs(add));
				end
				--draw.SimpleText(add,"ESDefaultSmallBlur",30,38,COLOR_BLACK);
				--draw.SimpleText(add,"ESDefaultSmallBlur",30,38,COLOR_BLACK);
				draw.SimpleText(add,"ESDefaultSmall",30,38,COLOR_BLACK);
			end]]
		end
	end)
end
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