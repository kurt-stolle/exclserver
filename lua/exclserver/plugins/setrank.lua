local PLUGIN=ES.Plugin()
PLUGIN:SetInfo("Rank","Allows you to set somebody's rank.","Excl")

PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NOCANDISABLE)

if SERVER then
	PLUGIN:AddCommand("rank",function(p,a)
		if type(a[1]) ~= "string" or type(a[2]) ~= "string" then p:ESChatPrint("Invalid parameters.") return end
		local vTbl = ES.GetPlayerByName(a[1])
		if not vTbl or #vTbl > 1 then p:ESChatPrint("This command can only be ran on one person.") return end

		local r = string.Trim(string.lower(a[2]))
		if not ES.RankExists(r) then p:ESChatPrint("Unknown rank: "..r) return end

		local v = vTbl[1]

		local global = tobool(a[3])

		if not v or not IsValid(v) then p:ESChatPrint("No player matching <hl>"..a[1].."</hl> could be found. Try finding the player by SteamID.") return end

		if global then
			v:ESSetRank(r,true)
		else
			v:ESSetRank(r)
		end

		ES.ChatBroadcast("<hl>"..p:Nick().."</hl> has given <hl>"..v:Nick().."</hl> "..(global and "global " or "").."rank <hl>"..r.."</hl>")

	end,60)
end

PLUGIN()
