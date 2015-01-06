-- A bunch of command aliases to open up the main menu. Nothing special here.
if SERVER then
	util.AddNetworkString("ESToggleMenu");
end

PLUGIN:SetInfo("Buy","Allows users to buy stuff in the ExclServer shop, and activate items bought. This command is mostly called internally.","Excl")
PLUGIN:AddCommand("buy",function(p,a)
	if not (IsValid(p) and p.excl and type(p.excl.invaura) == "table" and a[1] and a[2]) then return end
	
	local name		= a[1];
	local itemtype	= a[2];
	if itemtype == "taunt" then
		itemtype = ITEM_TAUNT;
	elseif itemtype == "model" then
		itemtype = ITEM_MODEL;

		if ES.ModelsBuy[name] and ES.ModelsBuy[name].VIPOnly and p:ESGetVIPTier() < 3 then
			return false;
		end
	elseif itemtype == "trail" then
		itemtype = ITEM_TRAIL;
	elseif itemtype == "melee" then
		itemtype = ITEM_MELEE;
	elseif itemtype == "prop" then
		itemtype = ITEM_PROP;
	else--if itemtype == "aura" then
		itemtype = ITEM_AURA;
	--[[else
		itemtype = ITEM_HAT;

		if ES.Hats[name] and ES.Hats[name]:GetVIPOnly() and p:ESGetVIPTier() < 1 then
			return false;
		end]]
	end
	if itemtype != ITEM_PROP then
		local iprice = tonumber(ES:GetItemPrice(name,itemtype));
		if iprice > 0 and ((p:ESGetBananas() - iprice) > 0) and p:ESGiveItem(name,itemtype,true) then
			p:ESTakeBananas(iprice)
			p:ESActivateItem(name,itemtype,true)

			p:ESAddAchievementProgress("shop_buy",1);
		else
			net.Start("ESNoBuy"); net.Send(p);
		end
		ES.DebugPrint("Item bought "..p:Nick())
	else
		local iprice = ES.Items[name].cost;
		if iprice > 0 and ((p:ESGetBananas() - iprice) > 0) and p:ESGetInventory():AddItem(name,1,true) then
			p:ESTakeBananas(iprice)

			p:ESAddAchievementProgress("shop_buy",1);
		else
			net.Start("ESNoBuy"); net.Send(p);
		end
	end

end);
PLUGIN:AddCommand("sell",function(p,a)
	if not IsValid(p) or not p.excl then return end
	local name = a[1];
	if not ES.Items[name] or not p:ESGetInventory():ContainsItem(name) then p:ChatPrint("You don't have this item") return end
	
	local iprice = math.floor(ES.Items[name].cost *.5);
		if iprice > 0 and p:ESGetInventory():RemoveItem(name,1,true) then
			p:ESGiveBananas(iprice)
		else
			net.Start("ESNoBuy"); net.Send(p);
		end
end)
PLUGIN:AddCommand("activate",function(p,a)
	if not (IsValid(p) and p.excl and type(p.excl.invaura) == "table" and a[1] and a[2]) then return end
	
	local name		= a[1];
	local itemtype	= a[2];
	if itemtype == "taunt" then
		itemtype = ITEM_TAUNT;
	elseif itemtype == "model" then
		itemtype = ITEM_MODEL;
	elseif itemtype == "trail" then
		itemtype = ITEM_TRAIL;
	elseif itemtype == "aura" then
		itemtype = ITEM_AURA;
	else--if itemtype == "melee" then
		itemtype = ITEM_MELEE;
	--[[else
		itemtype = ITEM_HAT;]]
	end

	p:ESActivateItem(name,itemtype)
end);
PLUGIN:AddCommand("deactivate",function(p,a)
	if not (IsValid(p) and p.excl and type(p.excl.invaura) == "table" and a[1]) then return end
	local itemtype	= a[1];
	if itemtype == "taunt" then
		itemtype = ITEM_TAUNT;
	elseif itemtype == "model" then
		itemtype = ITEM_MODEL;
	elseif itemtype == "trail" then
		itemtype = ITEM_TRAIL;
	elseif itemtype == "aura" then
		itemtype = ITEM_AURA;
	else--if itemtype == "melee" then
		itemtype = ITEM_MELEE;
	--[[else
		itemtype = ITEM_HAT;]]
	end
	
	p:ESDeactivateItem(itemtype)
end);
PLUGIN:AddCommand("buyvip",function(p,a)
	if not p or not IsValid(p) or not p.excl or not p:ESGetBananas() or p:ESGetBananas() < 2500 then return end
	local tier = tonumber( a[1] );
	local curtier = p:ESGetVIPTier();
	if not tier or tier > 4 or tier <= curtier then return end
	
	local price = (tier - curtier) * 5000;
	if tier == 1 and ES:IsCasualFriday() then
		price = math.Round(price * 0.5);
	end

	if p:ESGetBananas() < price then return end

	p:ESTakeBananas(price);
	ES:AddPlayerData(p,"viptier",tier);

	p:ESSetGlobalData("VIP",p.excl.viptier);

	if tier == 4 then
		p:ESAddAchievementProgress("vip_carebear",1);
	end

	net.Start("ESVIPBought");
	net.WriteEntity(p);
	net.WriteInt(tier,16);
	net.Broadcast();
end)
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NOCANDISABLE)

if SERVER then
	util.AddNetworkString("ESNoBuy");
	util.AddNetworkString("ESVIPBought")
end

local pnlVip;
net.Receive("ESVIPBought",function()
	local p = net.ReadEntity();
	local tiern = net.ReadInt(16);

	local tier = "error lol xD ~excl"
	if tiern == 1 then
		tier = "bronze";
	elseif tiern == 2 then
		tier = "silver";
	elseif tiern == 3 then
		tier = "gold";
	elseif tiern == 4 then
		tier = "carebear"
	end

	if p == LocalPlayer() and p.excl then
		p.excl.viptier = tiern;



		if pnlVip and IsValid(pnlVip) then pnlVip:Remove() end
		pnlVip = vgui.Create("esFrame");
		pnlVip:SetTitle("Thank you");
		local l = Label("You successfully bought "..tier.." VIP.\nThank you for joining our VIP community!",pnlVip)
		l:SetPos(15,45);
		l:SizeToContents();
		l:SetColor(COLOR_BLACK);
		pnlVip:SetSize(15+l:GetWide()+15,45+l:GetTall()+15);
		pnlVip:Center();
		pnlVip:MakePopup();

	end

	if not IsValid(p) or not tier then return end

	ES:ChatAddText("star",p,Color(255,255,255)," has upgraded to ",Color(102,255,51),tier,Color(255,255,255)," VIP.");
end)
net.Receive("ESNoBuy",function()
	chat.AddText(Color(255,255,255),"You can't buy this item.");
	chat.PlaySound();
end);