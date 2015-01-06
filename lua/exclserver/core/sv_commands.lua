-- sh_chatcommands
-- handles chat commands
util.AddNetworkString("ESNoRunRank");

local esCmd= {}
function ES:AddCommand(n,c,power)
	esCmd[n] = {func = c, power = power};
end
function ES:RemoveCommand(n)
	local c = 0;
	for k,v in pairs(esCmd)do
		c=c+1;
		if k==n then
			table.remove(esCmd,c);
			break;
		end
	end
end
concommand.Add("excl",function(p,c,a)
	if p.esNextCmd and p.esNextCmd > CurTime() then return end
	p.esNextCmd = CurTime()+1;
	
	c = a[1];

	if not esCmd or not esCmd[c] then return end
		if p.excl and p.ESIsRankOrHigher and p.ESIsRank and esCmd[c] and esCmd[c] then
			if esCmd[c].power and (esCmd[c].power > 0 and !p:ESHasPower(esCmd[c].power)) then
				net.Start("ESNoRunRank"); net.Send(p);
				return;
			end
			table.remove(a,1);
			esCmd[c].func(p,a);

			local stringCmd = c.." (";
			if a and a[1] then for k,v in pairs(a)do
				stringCmd = stringCmd.." "..v;
			end end
			stringCmd = stringCmd.." )";
			ES:Log("[ES CMD] "..p:Nick().." ("..p:SteamID().." | "..p:IPAddress()..") : "..stringCmd);
			ES:LogDB(p,stringCmd,"command");
		end
end)
hook.Add("PlayerSay","exclPlayerChatCommandSay",function(p,t)
	if (p.esNextCmd and p.esNextCmd > CurTime()) or not p or not t then return end
	p.esNextCmd = CurTime()+1;
	--t = string.lower(t);
	if t and string.Left(t,4) == "### " and p:ESHasPower(20) then

		local t = string.Explode(" ",t or "",false);
		table.remove(t,1);

		esCmd["anonannounce"].func(p,t);

		return false
	elseif t and string.Left(t,3) == "## " and p:ESHasPower(20) then

		local t = string.Explode(" ",t or "",false);
		table.remove(t,1);

		esCmd["announce"].func(p,t);
		return false
	elseif t and string.Left(t,2) == "# " then

		local t = string.Explode(" ",t or "",false);
		table.remove(t,1);

		esCmd["adminchat"].func(p,t);
		return false
	elseif t and (string.Left(t,1) == ":" --[[or string.Left(t,1) == "!" or string.Left(t,1) == "/" or string.Left(t,1) == "@"]]) then -- strict mode: only allow the : prefix for ExclServer commands.
		local t = string.Explode(" ",t or "",false);
		t[1] = string.gsub(t[1] or "",string.Left(t[1],1) or "","");

		if t and t[1] then
			local c = string.lower(t[1]);
			if esCmd and esCmd[c] then
				if esCmd[c].power and (esCmd[c].power > 0 and !p:ESHasPower(esCmd[c].power)) then
					net.Start("ESNoRunRank"); net.Send(p);
					return false;
				end
				table.remove(t,1);
				esCmd[c].func(p,t);

				local stringCmd = c.." (";
				if t and t[1] then 
					for k,v in pairs(t)do
						stringCmd = stringCmd.." "..v;
					end 
				end
				stringCmd = stringCmd.." )";
				ES:Log("[ES CMD] "..p:Nick().." ("..p:SteamID().." | "..p:IPAddress()..") : "..stringCmd);
				ES:LogDB(p,stringCmd,"command");

				return false
			end
		end

	end
end)