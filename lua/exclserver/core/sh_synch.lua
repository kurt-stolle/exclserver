-- sh_synch

ES.SynchronizationKey = 0;

if SERVER then
	
	concommand.Add("excl_synchrequest_user",function(p)
		if not p.excl then 
			p:ESLoadPlayer() 

			ES.DebugPrint("Critical synchronization problem, "..p:Nick().." is out of synch! Reloading player!")
			return 
		end

		p:ESSynchPlayer()

		ES.DebugPrint("Synchronization problem, "..p:Nick().." is out of synch! Resynching userdata!")
	end)

	concommand.Add("excl_synchrequest_rankconfig",function(p)
		p:ESSynchRankConfig();

		ES.DebugPrint("Synchronization problem, "..p:Nick().." is out of synch! Resynching rankconfig!")
	end)

	concommand.Add("excl_synchrequest_globaluserdata",function(p)
		ES:QueueGlobalPlayerDataSynch(p)

		ES.DebugPrint("Synchronization problem, "..p:Nick().." is out of synch! Resynching global userdata!")
	end)

	function ES:GenerateSynchKey()
		ES.SynchronizationKey = math.random(1,1000)
		SetGlobalInt("ESSynchKey",ES.SynchronizationKey);
	end
	ES:GenerateSynchKey()

	

end

if CLIENT then
	net.Receive("ESSynchInvAdd",function()
		name = net.ReadString();
		itemtype = net.ReadInt(8);

		--[[if itemtype == ITEM_HAT and LocalPlayer().excl then
			if not LocalPlayer().excl.invhat then
				LocalPlayer().excl.invhat = {name}
				return;
			end
			LocalPlayer().excl.invhat[#LocalPlayer().excl.invhat + 1] = name;
		else]]if itemtype == ITEM_TRAIL and LocalPlayer().excl then
			if not LocalPlayer().excl.invtrail then
				LocalPlayer().excl.invtrail = {name}
				return;
			end
			LocalPlayer().excl.invtrail[#LocalPlayer().excl.invtrail + 1] = name;
		elseif itemtype == ITEM_MODEL and LocalPlayer().excl then
			if not LocalPlayer().excl.invmodel then
				LocalPlayer().excl.invmodel = {name}
				return;
			end
			LocalPlayer().excl.invmodel[#LocalPlayer().excl.invmodel + 1] = name;
		elseif itemtype == ITEM_MELEE and LocalPlayer().excl then
			if not LocalPlayer().excl.invmelee then
				LocalPlayer().excl.invmelee = {name}
				return;
			end
			LocalPlayer().excl.invmelee[#LocalPlayer().excl.invmelee + 1] = name;
		end 
	end)
	net.Receive("ESSynchInvRemove",function()
		name = net.ReadString();
		itemtype = net.ReadInt(8);

		--[[if itemtype == ITEM_HAT and LocalPlayer().excl.invhat then
			for k,v in pairs(LocalPlayer().excl.invhat)do
				if v == name then
					table.remove(LocalPlayer().excl.invhat,k);
					return;
				end
			end
		else]]if itemtype == ITEM_TRAIL and LocalPlayer().excl.invtrail then
			for k,v in pairs(LocalPlayer().excl.invtrail)do
				if v == name then
					table.remove(LocalPlayer().excl.invtrail,k);
					return;
				end
			end
		elseif itemtype == ITEM_MODEL and LocalPlayer().excl.invmodel then
			for k,v in pairs(LocalPlayer().excl.invmodel)do
				if v == name then
					table.remove(LocalPlayer().excl.invmodel,k);
					return;
				end
			end
		elseif itemtype == ITEM_MELEE and LocalPlayer().excl.invmelee then
			for k,v in pairs(LocalPlayer().excl.invmelee)do
				if v == name then
					table.remove(LocalPlayer().excl.invmelee,k);
					return;
				end
			end
		end  
	end)
	net.Receive("ESSynchInvActivate",function()
		name = net.ReadString();
		itemtype = net.ReadInt(8);

		if itemtype == ITEM_HAT and LocalPlayer().excl then
			LocalPlayer().excl.activehat = name;
		elseif itemtype == ITEM_TRAIL and LocalPlayer().excl then
			LocalPlayer().excl.activetrail = name;
		elseif itemtype == ITEM_MODEL and LocalPlayer().excl then
			LocalPlayer().excl.activemodel = name;
		elseif itemtype == ITEM_MELEE and LocalPlayer().excl then
			LocalPlayer().excl.activemelee = name;
		end 
	end)

	net.Receive("ESSynchInventory",function()
		if not LocalPlayer().excl then return end
		local t = net.ReadTable();
		--LocalPlayer().excl.invhat = t.invhat;
		LocalPlayer().excl.invmodel = t.invmodel;
		LocalPlayer().excl.invtrail = t.invtrail;
		--LocalPlayer().excl.invtaunt = t.invtaunt;
		LocalPlayer().excl.invmelee = t.invmelee;
		--LocalPlayer().excl.activehat = t.activehat;
		LocalPlayer().excl.activemodel = t.activemodel;
		LocalPlayer().excl.activetrail = t.activetrail;
		LocalPlayer():ESDecodeInventory()
	end);
	net.Receive("ESSynchBnns",function()
		if not LocalPlayer().excl then return end
		LocalPlayer().excl.bananas = net.ReadUInt(32);
	end);
	net.Receive("ESSynchPlayer",function()
		if not LocalPlayer() or not IsValid(LocalPlayer()) then
			local t= net.ReadTable();
			timer.Simple(3,function() -- player not loaded yet (probrably cause of joining issues)
				if not LocalPlayer() or not IsValid(LocalPlayer()) then return; end -- don't load, hope for the best. I know it's bad too :(
				LocalPlayer().excl = t;
			end)
		else
			LocalPlayer().excl = net.ReadTable();
		end
	end)
	net.Receive("ESSynchRankConfig",function()
		local tbl = net.ReadTable();
		if not tbl then return end
		for k,v in pairs(tbl) do
			ES:SetupRank(k,v.pretty,v.power);
		end
	end)
	local performedInitialSynch = false;
	net.Receive("ESSynchGlobalPlayerData",function()
		performedInitialSynch = true;

		local tbl = net.ReadTable();

		ES.SynchronizationKey = net.ReadInt(32);

		if not tbl then return end
		for k,v in pairs(tbl)do
			if v and k and IsValid(k) then
				if not k.exclGlobal then k.exclGlobal = {} end
				
				for a,b in pairs(v)do
					k.exclGlobal[a] = b;
					ES.DebugPrint("Received global variable for "..k:Nick()..": "..a.." = "..tostring(b));
				end
			else
				Error("ExclServer has received a invalid playerdata synch. (error GBA1)")
			end
		end

	end)
	net.Receive("ESSynchGlobalPlayerDataSingle",function()
		local ply = net.ReadEntity();
		local tbl = net.ReadTable();

		ES.SynchronizationKey = net.ReadInt(32);

		if not tbl or not IsValid(ply) then Error("ExclServer has received a invalid single playerdata synch. (error GBS1) "..tostring(ply).." | "..tostring(tbl))  return end
		
		if !ply.exclGlobal then 
			ply.exclGlobal = {} 
		end
		
		for k,v in pairs(tbl)do

			if not ply.exclGlobal or not k then Error("ExclServer has received a invalid single playerdata synch. (error GBS2)") return end

			ply.exclGlobal[k] = v;

			ES.DebugPrint("Received single global variable for "..ply:Nick()..": "..k.." = "..tostring(v));
		end
	end)

	timer.Create("ESHandleSynchRequests",30,0,function()
		if not LocalPlayer().excl then
			RunConsoleCommand("excl_synchrequest_user");
			return;
		end

		if ES:CountRanks() <= 4 then
			RunConsoleCommand("excl_synchrequest_rankconfig");
			return;
		end

		if GetGlobalInt("ESSynchKey") != ES.SynchronizationKey then
			RunConsoleCommand("excl_synchrequest_globaluserdata");
			return;
		end
	end)

end