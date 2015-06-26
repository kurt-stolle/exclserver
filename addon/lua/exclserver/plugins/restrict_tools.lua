local PLUGIN=ES.Plugin()
PLUGIN:SetInfo("Tool restrict","Allows you to restrict certain tools.","Excl")
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)

if SERVER then
	local function canTool(p,tool)
		if ES.ToolRestrictions[tool] then
			local cantool = true
			if ES.ToolRestrictions[tool] > 4 then
				if ES.ToolRestrictions[tool] == 5 and not p:IsAdmin() then cantool=false end
				if ES.ToolRestrictions[tool] == 6 and not p:IsSuperAdmin() then cantool=false end
				if ES.ToolRestrictions[tool] == 7 and not p:ESHasPower(60) then cantool=false end
			elseif p:ESGetVIPTier() < ES.ToolRestrictions[tool] then cantool=false end

			if not cantool then
				p:ESSendNotificationPopup("Restricted","You must be "..(ES.ToolRestrictions[tool] <= 4 and "VIP tier "..tostring(ES.ToolRestrictions[tool]) or ES.ToolRestrictions[tool] == 5 and "Administrator" or ES.ToolRestrictions[tool] == 6 and "Super Administrator" or ES.ToolRestrictions[tool] == 7 and "Operator").." to use this tool.")
				return false
			end
			return true
		else
			p:ESSendNotification("generic","This tool is disabled.")
			return p:IsSuperAdmin()
		end
	end

	PLUGIN:AddCommand("blocktool",function(p,a)
		if not p or not p:IsValid() or not a or not a[1] or a[1] == "" then return p:ChatPrint("Invalid arguments, format: <power: VIP Tier or 5 [for A] or 6 [for SA] or 7 [for OP].") end
		if not (p:GetActiveWeapon() and IsValid(p:GetActiveWeapon()) and p:GetActiveWeapon():GetClass() == "gmod_tool") then return p:ChatPrint("You don't have a tool equipped.") end

		local toolmode = p:GetWeapon("gmod_tool").Mode
		local req = tonumber(a[1])

		ES.DBQuery("SELECT * FROM es_restrictions_tools WHERE toolmode='"..toolmode.."' LIMIT 1",function(res)
			if res and res[1] then
				ES.DBQuery("UPDATE es_restrictions_tools SET req = "..req.." WHERE toolmode='"..toolmode.."', serverid = "..ES.ServerID.."")
			else
				ES.DBQuery("INSERT INTO es_restrictions_tools SET toolmode='"..toolmode.."', req = "..req..", serverid = "..ES.ServerID.."")
			end
		end)

		ES.ToolRestrictions[toolmode] = req

		ES.ChatBroadcast(ES.Color.Highlight,toolmode,ES.Color.White," was restricted to ",ES.Color.Highlight,req <= 4 and "VIP tier "..tostring(req) or req == 5 and "Administrator" or req == 6 and "Super Administrator" or req == 7 and "Operator")
	end,60)

	ES.ToolRestrictions = {}
	PLUGIN:AddHook("ESDatabaseReady",function()
		ES.DBQuery("SELECT * FROM es_restrictions_tools WHERE serverid = "..ES.ServerID.."",function(res)
			if res then
				ES.DebugPrint("Loaded tool restrictions")
				for k,v in pairs(res) do
					ES.ToolRestrictions[v.toolmode] = tonumber(v.req)
				end
			end
		end)
	end)

	PLUGIN:AddHook("CanTool",function(p,tr,tool)
		if not canTool(p,tool) then
			return false
		end
	end)

	PLUGIN:AddHook("CanProperty", function( ply, property, ent )
		if ply:IsSuperAdmin() then
			return true
		end

		ply:ESSendNotification("generic","Properties are restricted to Super Administrators")
		return ply:IsSuperAdmin()
	end)

	-- Reimplement some gmod code.

	function CC_GMOD_Tool( player, command, arguments )
		if ( arguments[1] == nil ) then return end
		if not ( canTool(player,arguments[1]) ) then return end

		player:ConCommand( "gmod_toolmode "..arguments[1] )

		local activeWep = player:GetActiveWeapon()
		local isTool = (activeWep and activeWep:IsValid() and activeWep:GetClass() == "gmod_tool")

		player:SelectWeapon( "gmod_tool")

		local wep = player:GetWeapon("gmod_tool")

		if (wep:IsValid()) then
			if ( not isTool ) then
				wep.wheelModel = nil
			end

			if ( wep.Holster ) then
				wep:Holster()
			end

			wep.Mode = arguments[1]

			if ( wep.Deploy ) then
				wep:Deploy()
			end
		end

	end

	concommand.Add( "gmod_tool", CC_GMOD_Tool, nil, nil, { FCVAR_SERVER_CAN_EXECUTE } )
else
	hook.Add("InitPostEntity","ES.ToolRestrictions.DisableHelp",function()
		LocalPlayer():ConCommand("gmod_drawhelp 0")
	end)
end
PLUGIN()
