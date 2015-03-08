-- handles all bans
function ES.AddBan(steamBanned,steamAdmin,time,global,reason,name,nameAdmin)
	if not ES.ServerID or not steamBanned or not steamAdmin or not time then return end

	local id = ES.ServerID
	if global then
		id = 0
	end

	if name and nameAdmin then
		name = ES.DBEscape(name)
		nameAdmin = ES.DBEscape(nameAdmin)
		ES.DBQuery("INSERT INTO es_bans SET steamid = '"..steamBanned.."', steamidAdmin = '"..steamAdmin.."', name = '"..name.."', nameAdmin = '"..nameAdmin.."', serverid = "..id..", unbanned = 0, time = "..time..", timeStart = "..math.Round(os.time()/60)..", reason = '"..reason.."'")
	elseif name then
		name = ES.DBEscape(name)
		ES.DBQuery("INSERT INTO es_bans SET steamid = '"..steamBanned.."', steamidAdmin = '"..steamAdmin.."', name = '"..name.."', serverid = "..id..", unbanned = 0, time = "..time..", timeStart = "..math.Round(os.time()/60)..", reason = '"..reason.."'")
	else
		ES.DBQuery("INSERT INTO es_bans SET steamid = '"..steamBanned.."', steamidAdmin = '"..steamAdmin.."', serverid = "..id..", unbanned = 0, time = "..time..", timeStart = "..math.Round(os.time()/60)..", reason = '"..reason.."'")
	end


end
function ES.RemoveBan(steamid)
	if not steamid then return end

	ES.DBQuery("UPDATE es_bans SET unbanned = 1 WHERE steamid = '"..steamid.."'")
end

gameevent.Listen("player_connect")
hook.Add("player_connect", "ESHandlePlayerConnect", function(data)
	ES.DBQuery("SELECT timeStart,time,reason FROM es_bans WHERE steamid='"..data.networkid.."' AND unbanned = 0 AND ((("..math.Round(os.time()/60).." - timeStart) < time ) OR time = 0 ) AND (serverid = 0 OR serverid = "..ES.ServerID..") LIMIT 1;",function(res)
		if res and res[1] then
			local expire = "This ban will never expire"
			if res[1].time > 0 then
				expire = "This ban will expire in "..(tonumber(res[1].time) - math.Round(os.time()/60) - tonumber(res[1].timeStart)).." minutes"
			end
			ES.DropUser(data.userid,"You are banned! "..expire..". Reason: "..res[1].reason..".")
		end
	end)
end)
timer.Create("ES.CheckBans",300,0,function()
	ES.DBQuery("SELECT steamid,timeStart,time,reason FROM es_bans WHERE unbanned = 0 AND ((("..math.Round(os.time()/60).." - timeStart) < time ) OR time = 0 ) AND (serverid = 0 OR serverid = "..ES.ServerID..")",function(res)
		if not res or not res[1] then return end

		local bans={};
		for k,v in ipairs(res) do
			if not v.steamid or not v.timeStart or not v.time or not v.reason then continue end

			bans[v.steamid] = {
				reason = v.reason,
				time = tonumber(v.time),
				timeStart = tonumber(v.timeStart),
			}
		end

		for k,v in ipairs(player.GetAll())do
			if bans[v:SteamID()] then
				local steamid = v:SteamID()
				local expire = "This ban will never expire"
				if bans[steamid].time > 0 then
					expire = "This ban will expire in "..bans[steamid].time - (math.Round(os.time()/60) - bans[steamid].timeStart).." minutes"
				end
				ES.DropUser(v:UserID(),"You are banned! "..expire..". Reason: "..res[1].reason..".")
			end
		end
	end)
end)
