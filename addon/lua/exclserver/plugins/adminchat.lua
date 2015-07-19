local PLUGIN=ES.Plugin()
PLUGIN:SetInfo("Admin chat","Chat private to admins.","Excl")

PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NOCANDISABLE)

if SERVER then
	PLUGIN:AddCommand("adminchat",function(p,a)
		if not p or not p:IsValid() or not a or not a[1] or a[1] == "" then return end

		local ppl = {}
		for k,v in pairs(player.GetAll())do
			if v:ESHasPower(1) or v == p then
				v:ESChatPrint(p,ES.Color.White," to admins: "..table.concat(a," ",1))
			end
		end
	end,0)
end
PLUGIN()
