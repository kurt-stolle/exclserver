-- sv_geo.lua

require "geoip"

if not GeoIP then ES.DebugPrint("Failed to load GeoIP module.") return end

util.AddNetworkString("ESSendPlayerInfo")
ES.AddCommand("info",function(p,a)
	if not p:ESHasPower(20) or not a or not a[1] then p:ChatPrint("You are not authorized to use this command") return end

	local targ = ES.GetPlayerByName(a[1])
	if not targ then p:ChatPrint("No target found") end
	targ = targ[1]
	if not targ or not IsValid(targ) or not targ.Nick then p:ChatPrint("No target found") return end

	local info = p:IsSuperAdmin() and GeoIP.Get(string.Left(targ:IPAddress(),string.len(targ:IPAddress()) - 6)) or {}
	info.nickname = targ:Nick()
	info.SteamID = targ:SteamID()
	info.rank = targ:ESGetRank().pretty
	info.IP = p:IsSuperAdmin() and targ:IPAddress() or "HIDDEN"

	net.Start("ESSendPlayerInfo")
	net.WriteTable(info)
	net.Send(p)
end,20)