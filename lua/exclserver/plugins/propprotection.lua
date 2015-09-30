local PLUGIN=ES.Plugin()
PLUGIN:SetInfo("Prop protection","Handles prop protection.","Excl")
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)

if SERVER then
	-- Network
	util.AddNetworkString("ES.Plugin.PropRes.blocked")

  -- Config
  ES.CreateSetting("PLUGIN:Prop Protect.Protect.Pickup",true)
  ES.CreateSetting("PLUGIN:Prop Protect.Protect.Tool",true)
  ES.CreateSetting("PLUGIN:Prop Protect.Protect.Use",false)
  ES.CreateSetting("PLUGIN:Prop Protect.Protect.Drive",false)

	-- Commands
	PLUGIN:AddCommand("friends",function(p,a)
    for k,v in ipairs(p._es_friends)do
      p:ChatPrint(v:Nick())
    end
	end,0)

  PLUGIN:AddCommand("friendadd",function(p,a)
    if not a[1] then return end

    local targets=ES.GetPlayerByName(a[1])

    for k,v in ipairs(targets)do
      table.insert(p._es_friends,v)

      p:ESChatPrint("<hl>"..v:Nick().."</hl> was added to your friends.")
    end
	end,0)

	-- Hooks
	PLUGIN:AddHook("ESPlayerReady",function(ply)
		ply._es_friends={}
	end)

	PLUGIN:AddHook("PhysgunPickup", function(p,ent)
    if not ES.GetSetting("PLUGIN:Prop Protect.ProtectPickup") then return end

    if IsValid(ent:GetOwner()) and ent:GetOwner() ~= p and not table.HasValue(ent:GetOwner()._es_friends,p) then
      return false
    end
	end)

  PLUGIN:AddHook("CanDrive", function(p,ent)
    if not ES.GetSetting("PLUGIN:Prop Protect.ProtectDrive") then return end

    if IsValid(ent:GetOwner()) and ent:GetOwner() ~= p and not table.HasValue(ent:GetOwner()._es_friends,p) then
      return false
    end
	end)

  PLUGIN:AddHook("CanTool", function(p,tr,tool)
    if not ES.GetSetting("PLUGIN:Prop Protect.ProtectTool") then return end


	end)

  PLUGIN:AddHook("CanProperty", function(p,prop,ent)
    if not ES.GetSetting("PLUGIN:Prop Protect.ProtectUse") then return end

    if IsValid(ent:GetOwner()) and ent:GetOwner() ~= p and not table.HasValue(ent:GetOwner()._es_friends,p) then
      return false
    end
  end)

  PLUGIN:AddHook("PlayerUse", function(p,ent)
    if not ES.GetSetting("PLUGIN:Prop Protect.ProtectUse") then return end


  end)
end

PLUGIN()
