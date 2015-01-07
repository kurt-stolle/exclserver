--ban

local PLUGIN=ES.Plugin();
PLUGIN:SetInfo("Ban","Allows you to ban people from your server if you have the right rank.","Excl")
PLUGIN:AddCommand("ban",function(p,a)
	if !IsValid(p) or !a or !a[1] or !a[2] or !a[3] then
		return;	
	end

	local user = a[1];
	local time = tonumber(a[2]);
	local reason = table.concat(a," ",3);

	if not user or not time or not reason or time < 0 then return end

	local userFound = exclPlayerByName(user);
	if userFound and userFound[1] and #userFound == 1 then
		user = userFound[1];
		if user:ESIsImmuneTo(p) then
			ES:SendMessagePlayerTried(p,user:Nick(),"ban")
			return;
		end

		ES:AddBan(user:SteamID(),p:SteamID(),time,true,reason,user:Nick(),p:Nick())

		net.Start("exclBP");
		net.WriteEntity(p);
		net.WriteString(user:Nick());
		net.WriteInt(tonumber(a[2]),32);
		net.WriteString(reason or "No reason given.");
		net.Broadcast();

		exclDropUser(user:UserID(), "You were globally banned! \""..reason.."\", Your ban will expire in "..time.." minutes.")
	elseif string.upper(string.Left(user,5)) == "STEAM" then
		ES:AddBan(user,p:SteamID(),time,true,reason)

		net.Start("exclBP");
		net.WriteEntity(p);
		net.WriteString(string.upper(user));
		net.WriteInt(tonumber(a[2]),32);
		net.WriteString(reason or "No reason given.");
		net.Broadcast();
	elseif #exclPlayerByName(user) != 1 then
		net.Start("ESCmdOnlyOne"); net.Send(p);
	end
end,20);
PLUGIN:AddCommand("unban",function(p,a)
	if !IsValid(p) or !a or !a[1] then
		return;	
	end

	local user = a[1];
	if string.upper(string.Left(user,5)) == "STEAM" then
		ES:RemoveBan( string.upper(user) );

		net.Start("exclUBP");
		net.WriteEntity(p);
		net.WriteString(user);
		net.Broadcast();
	end
end,40);

PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NOCANDISABLE)
PLUGIN();

if SERVER then
	util.AddNetworkString("exclBP");
	util.AddNetworkString("exclUBP");

elseif CLIENT then
	net.Receive("exclNoBP",function()
		local p = net.ReadEntity();
		local v = net.ReadString();
		if not IsValid(p) then return end
		
		ES:ChatAddText("accessdenied",Color(255,255,255),
		exclFixCaps(p:ESGetRank().name).." ",
		Color(102,255,51),p:Nick(),
		Color(255,255,255),
		" tried to ban ",
		Color(102,255,51),
		v,
		Color(255,255,255,255),
		".");
		chat.PlaySound()
	end)
	net.Receive("exclBP",function()
		local p = net.ReadEntity();
		local v = net.ReadString();
		local t = net.ReadInt(32);
		local r = net.ReadString();
		if r == "" or r == " " then
			r = nil;
		end
		if not IsValid(p) or not t then return end
		if t > 0 then	
			ES:ChatAddText("admincommand",Color(255,255,255),exclFixCaps(p:ESGetRank().name).." ",Color(102,255,51),p:Nick(),Color(255,255,255)," has banned ",Color(102,255,51),v,Color(255,255,255,255), " for ",Color(102,255,51),string.ToMinutesSeconds(tostring(t)),Color(255,255,255,255)," hours with reason: "..(r or "No reason specified.")..".");
		else
			ES:ChatAddText("admincommand",Color(255,255,255),exclFixCaps(p:ESGetRank().name).." ",Color(102,255,51),p:Nick(),Color(255,255,255)," has banned ",Color(102,255,51),v,Color(255,255,255,255), " permanently with reason: "..(r or "No reason specified.")..".");
		end
		chat.PlaySound()
	end)
	net.Receive("exclUBP",function()
		local p = net.ReadEntity();
		local ub = net.ReadString();
		if not IsValid(p) then return end
		ES:ChatAddText("admincommand",Color(255,255,255),exclFixCaps(p:ESGetRank().name).." ",Color(102,255,51),p:Nick(),Color(255,255,255)," has unbanned ",Color(102,255,51),ub,Color(255,255,255,255), ".");
		chat.PlaySound()
	end)
end