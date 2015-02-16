-- A bunch of command aliases to open up the main menu. Nothing special here.
if SERVER then
	util.AddNetworkString("ESToggleTP")
end

local PLUGIN=ES.Plugin()
PLUGIN:SetInfo("Thirdperson","Allow you to toggle thirdperson.","Excl")
PLUGIN:AddCommand("thirdperson",function(p,a)
	if p:ESGetVIPTier() < 3  then return end
	net.Start("ESToggleTP") net.Send(p)
end)
PLUGIN:AddCommand("firstperson",function(p,a)
	if p:ESGetVIPTier() < 3 then return end
	net.Start("ESToggleTP") net.Send(p)
end)
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)
PLUGIN()

if SERVER then return end

net.Receive("ESToggleTP",function()
	if not LocalPlayer().excl then return end
	LocalPlayer()._es_thirdpersonMode = !LocalPlayer()._es_thirdpersonMode
	
	if LocalPlayer()._es_thirdpersonMode then
		chat.AddText(Color(255,255,255),"You have enabled thirdperson mode.")
	end
	chat.PlaySound()
end)

local fov = 0
local newpos
local tracedata = {}
local distance = 60
local camPos = Vector(0, 0, 0)
local camAng = Angle(0, 0, 0)

local newpos
local newangles
hook.Add("CalcView", "exclThirdperson", function(ply, pos , angles ,fov)
	--[[local view = {}
hook.Add("CalcView","ES.MMCalcView",function(ply,pos,angles,fov)
	if IsValid(mm) then
		local bone=ply:LookupBone("ValveBiped.Bip01_Head1")

		if bone then
		
			pos,angles=ply:GetBonePosition(bone)

			if pos and angles then

				angles:RotateAroundAxis(angles:Up(),110)
				angles:RotateAroundAxis(angles:Forward(),90)
				angles:RotateAroundAxis(angles:Up(),180)

				view.origin=LerpVector(FrameTime()*10,view.origin,pos)
				view.angles=LerpAngle(FrameTime()*10,view.angles,angles)

				view.fov = fov
				
				return view

			end
		end
	else
		view.origin=pos
		view.angles=angles
	end
end)]]
	
	if !newpos then
		newpos = pos
		newangles = angles
	end

	if( ply.excl and ply._es_thirdpersonMode ) and distance > 2 then					
		local side = ply:GetActiveWeapon()
		side = side and IsValid(side) and side.GetHoldType and side:GetHoldType() != "normal" and side:GetHoldType() != "melee" and side:GetHoldType() != "melee2" and side:GetHoldType() != "knife"

		if side then
			tracedata.start = pos
			tracedata.endpos = pos - ( angles:Forward() * distance ) + ( angles:Right()* ((distance/90)*50) )
			tracedata.filter = player.GetAll()
			trace = util.TraceLine(tracedata)  
	        pos = newpos
			newpos = LerpVector( 0.5, pos, trace.HitPos + trace.HitNormal*2 )
			angles = newangles
			newangles = LerpAngle( 0.5, angles, (ply:GetEyeTraceNoCursor().HitPos-newpos):Angle() )

			camPos = pos
			camAng = angles
			return GAMEMODE:CalcView(ply, newpos, angles, fov)
		else
			tracedata.start = pos
			tracedata.endpos = pos - ( angles:Forward() * distance * 2 ) + ( angles:Up()* ((distance/60)*10) )
			tracedata.filter = player.GetAll()
			
	    	trace = util.TraceLine(tracedata)
	        pos = newpos
			newpos = trace.HitPos + trace.HitNormal*2

			camPos = pos
			camAng = angles
			return GAMEMODE:CalcView(ply, newpos , angles ,fov)

		end
	else
		newpos = ply:EyePos()
	end
end)

hook.Add("ShouldDrawLocalPlayer", "ESThirdpersonDrawLocal", function()
	if LocalPlayer().excl and LocalPlayer()._es_thirdpersonMode == true then
		return true
	end
end)
