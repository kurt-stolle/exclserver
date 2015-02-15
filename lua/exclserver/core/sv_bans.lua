-- handles all bans
local bansLoaded = false;
local bans = {};

function ES.AddBan(steamBanned,steamAdmin,time,global,reason,name,nameAdmin)
	if not ES.ServerID or not steamBanned or not steamAdmin or not time then return end

	local id = ES.ServerID;
	if global then
		id = 0;
	end

	bans[steamBanned] = {reason = reason, time = time, timeStart = math.Round(os.time()/60)}

	if name and nameAdmin then
		name = ES.DBEscape(name);
		nameAdmin = ES.DBEscape(nameAdmin);
		ES.DBQuery("INSERT INTO es_bans SET steamid = '"..steamBanned.."', steamidAdmin = '"..steamAdmin.."', name = '"..name.."', nameAdmin = '"..nameAdmin.."', serverid = "..id..", unbanned = 0, time = "..time..", timeStart = "..math.Round(os.time()/60)..", reason = '"..reason.."';");	
	elseif name then
		name = ES.DBEscape(name);
		ES.DBQuery("INSERT INTO es_bans SET steamid = '"..steamBanned.."', steamidAdmin = '"..steamAdmin.."', name = '"..name.."', serverid = "..id..", unbanned = 0, time = "..time..", timeStart = "..math.Round(os.time()/60)..", reason = '"..reason.."';");	
	else
		ES.DBQuery("INSERT INTO es_bans SET steamid = '"..steamBanned.."', steamidAdmin = '"..steamAdmin.."', serverid = "..id..", unbanned = 0, time = "..time..", timeStart = "..math.Round(os.time()/60)..", reason = '"..reason.."';");	
	end

	
end
function ES.RemoveBan(steamid)
	if not steamid then return end
	
	bans[steamid] = false;
	ES.DBQuery("UPDATE es_bans SET unbanned = 1 WHERE steamid = '"..steamid.."';");
end
function ES.LoadBans()
	ES.DBQuery("SELECT steamid,timeStart,time,reason FROM es_bans WHERE unbanned = 0 AND ((("..math.Round(os.time()/60).." - timeStart) < time ) OR time = 0 ) AND (serverid = 0 OR serverid = "..ES.ServerID..");",function(d)
		ES.DebugPrint("Bans have been loaded.");
		bansLoaded = true;
		
		if not d or not d[1] then return end

		for k,v in pairs(d) do
			if not v.steamid or not v.timeStart or not v.time or not v.reason then continue end

			bans[v.steamid] = {
				reason = v.reason,
				time = tonumber(v.time),
				timeStart = tonumber(v.timeStart),
			}
		end

		for k,v in pairs(player.GetAll())do
			if bans[v:SteamID()] then
				local steamid = v:SteamID();
				local expire = "This ban will never expire";
				if bans[steamid].time > 0 then
					expire = "This ban will expire in "..bans[steamid].time - (math.Round(os.time()/60) - bans[steamid].timeStart).." minutes"
				end
				exclDropUser(v:UserID(),"Banned for reason \""..bans[steamid].reason.."\". "..expire..".");
			end
		end
	end)
end
hook.Add("ES.MySQLReady","ES.InitializeBans",function(id)
	ES.LoadBans();
	timer.Create("ES.RefreshBans",600,0,function()
		ES.LoadBans()
	end)
end)

function ES.CheckBans(steamid,userid)
	if !bansLoaded then
		return false;
	end

	if bans[steamid] and ( ( math.Round(os.time()/60) - bans[steamid].timeStart ) < bans[steamid].time or bans[steamid].time == 0 )then
		local expire = "This ban will never expire";
		if bans[steamid].time > 0 then
			expire = "This ban will expire in "..bans[steamid].time - (math.Round(os.time()/60) - bans[steamid].timeStart).." minutes"
		end
		exclDropUser(userid,"Banned for reason \""..bans[steamid].reason.."\". "..expire..".");
		return true;
	end
	return false;
end