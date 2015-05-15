-- tp
-- tp people

local PLUGIN=ES.Plugin()
PLUGIN:SetInfo("Teleport","Allows you to teleport.","Excl")

PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NOCANDISABLE)
PLUGIN()

if SERVER then
	util.AddNetworkString("exclTP")

	local function findLocation( from, to, force )
		if not to:IsInWorld() and not force then return false end

		local yawForward = to:EyeAngles().yaw
		local directions = {
			math.NormalizeAngle( yawForward - 180 ),
			math.NormalizeAngle( yawForward + 90 ),
			math.NormalizeAngle( yawForward - 90 ),
			yawForward,
		}

		local t = {}
		t.start = to:GetPos() + Vector( 0, 0, 32 )
		t.filter = { to, from }

		local i = 1
		t.endpos = to:GetPos() + Angle( 0, directions[ i ], 0 ):Forward() * 47
		local tr = util.TraceEntity( t, from )
		while tr.Hit do
			i = i + 1
			if i > #directions then
				if force then
					return to:GetPos() + Angle( 0, directions[ 1 ], 0 ):Forward() * 47
				else
					return false
				end
			end

			t.endpos = to:GetPos() + Angle( 0, directions[ i ], 0 ):Forward() * 47

			tr = util.TraceEntity( t, from )
		end

		return tr.HitPos
	end
	local function teleport(p,arg)
		if not p or not IsValid(p) or not arg or not arg[2] then return end

		local a = ES.GetPlayerByName(arg[1])
		local b = ES.GetPlayerByName(arg[2])

		if !a or !b then return end

		a = a[1]
		b = b[1]

		if !a or !b or !IsValid(a) or !IsValid(b) then return end

		local pos = findLocation( a,b,p:GetMoveType() == MOVETYPE_NOCLIP or p:GetMoveType() == MOVETYPE_OBSERVER or tobool(a[3]) )
		if not pos and tobool(arg[3]) == false then
			p:ChatPrint("Not enough space to teleport, put <hl>1</hl> as third argument to force teleport.")
			return
		elseif not pos then
			pos = b:GetPos()
		end

		a:SetPos(pos)

		ES.ChatBroadcast("<hl>"..p:Nick().."</hl> has teleported <hl>"..a:Nick().."</hl> to <hl>"..(b==p and "themself" or b:Nick()).."</hl>.")
	end
	PLUGIN:AddCommand("tp",teleport,10)
	PLUGIN:AddCommand("teleport",teleport,10)

end
