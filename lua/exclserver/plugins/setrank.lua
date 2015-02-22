local PLUGIN=ES.Plugin()
PLUGIN:SetInfo("Rank","Allows you to set somebody's rank.","Excl")

PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NOCANDISABLE)

if SERVER then 
	util.AddNetworkString("exclSetRankOnlyOne")
	util.AddNetworkString("exclSetRank")
	util.AddNetworkString("exclSetRankGlobal")

	PLUGIN:AddCommand("rank",function(p,a)
		if not p or not p:IsValid() or not a or not a[1] or a[1] == "" then return end
		local vTbl = exclPlayerByName(a[1])
		if not vTbl or #vTbl > 1 then net.Start("exclSetRankOnlyOne") net.Send(p) return end
		
		local r = a[2]
		if not ES.RankExists(r) then return end
		
		local v = vTbl[1]

		local global = tobool(a[3])
		
		if not v or not IsValid(v) then net.Start("exclSetRankOnlyOne") net.Send(p) return end
		
		if global then
			v:ESSetRank(r,true)
		else 
			v:ESSetRank(r)
		end

		net.Start("exclSetRank")
		net.WriteEntity(p)
		net.WriteEntity(v)
		net.WriteString(r)
		net.WriteBit(global or false)
		net.Broadcast()	
		
	end,60)
	
	return 
end
net.Receive("exclSetRank",function()
	local p = net.ReadEntity()
	local v = net.ReadEntity()
	local r = net.ReadString()
	local global = (net.ReadBit() == 1)
	if not IsValid(p) or not IsValid(v) then return end
	
	local txt = ""
	if global then
		txt = "global "
	end

	chat.AddText(Color(255,255,255),
	exclFixCaps(p:ESGetRank().name).." ",
	Color(102,255,51),p:Nick(),
	Color(255,255,255),
	" has set ",
	Color(102,255,51),
	v:Nick(),
	ES.Color.White,
	"'s "..txt.."rank to ",
	Color(102,255,51),
	exclFixCaps(r))
	chat.PlaySound()
end)
net.Receive("exclSetRankOnlyOne",function()
	chat.AddText(Color(255,255,255),"You can only set the rank of one person at a time.")
	chat.PlaySound()
end)

PLUGIN()