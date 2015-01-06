-- A bunch of command aliases to open up the main menu. Nothing special here.
if SERVER then
	util.AddNetworkString("ESToggleTP");
end

PLUGIN:SetInfo("Thirdperson","Allow you to toggle thirdperson.","Excl")
PLUGIN:AddCommand("thirdperson",function(p,a)
	if not p.excl or p:ESGetVIPTier() < 3  then return end
	net.Start("ESToggleTP"); net.Send(p);
end);
PLUGIN:AddCommand("firstperson",function(p,a)
	if not p.excl or p:ESGetVIPTier() < 3 then return end
	net.Start("ESToggleTP"); net.Send(p);
end);
PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)
--PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NOCANDISABLE)

if SERVER then return end

net.Receive("ESToggleTP",function()
	if not LocalPlayer().excl then return end
	LocalPlayer().excl.thirdperson = !LocalPlayer().excl.thirdperson;
	
	if LocalPlayer().excl.thirdperson then
		chat.AddText(Color(255,255,255),"You have enabled thirdperson mode.");
	end
	chat.PlaySound();
end)

local fov = 0;
local thirdperson = true;
local newpos
local tracedata = {}
local distance = 60;
local camPos = Vector(0, 0, 0)
local camAng = Angle(0, 0, 0)

local newpos;
local newangles;
hook.Add("CalcView", "exclThirdperson", function(ply, pos , angles ,fov)
	if !newpos then
		newpos = pos;
		newangles = angles;
	end

	if( ply.excl and ply.excl.thirdperson ) and distance > 2 then					
		local side = ply:GetActiveWeapon();
		side = side and IsValid(side) and side.GetHoldType and side:GetHoldType() != "normal" and side:GetHoldType() != "melee" and side:GetHoldType() != "melee2" and side:GetHoldType() != "knife";

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
			camAng = angles;
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
		newpos = ply:EyePos();
	end
end)
--[[
hook.Add("CalcView", "ESThirdpersonCalcView", function(player, pos, angles, fov)
	if player.excl and player.excl.thirdperson == true then
		local smooth = 1
		local smoothscale = 0.2
		angles = player:GetAimVector():Angle()

		local targetpos = Vector(0, 0, 60)
		if player:KeyDown(IN_DUCK) then
			if player:GetVelocity():Length() > 0 then
				targetpos.z = 50
			else
				targetpos.z = 40
			end
		end

		player:SetAngles(angles)
		local targetfov = fov
		if player:GetVelocity():DotProduct(player:GetForward()) > 10 then
			if player:KeyDown(IN_SPEED) then
				targetpos = targetpos + player:GetForward() * -10
				if 1 != 0 and player:OnGround() then
					angles.pitch = angles.pitch + .5 * math.sin(CurTime() * 10)
					angles.roll = angles.roll + .5 * math.cos(CurTime() * 10)
					targetfov = targetfov + 3
				end
			else
				targetpos = targetpos + player:GetForward() * -5
			end
		end 

		// tween to the target position
		pos = player:GetVar("thirdperson_pos") or targetpos
		if smooth != 0 then
			pos.x = math.Approach(pos.x, targetpos.x, math.abs(targetpos.x - pos.x) * smoothscale)
			pos.y = math.Approach(pos.y, targetpos.y, math.abs(targetpos.y - pos.y) * smoothscale)
			pos.z = math.Approach(pos.z, targetpos.z, math.abs(targetpos.z - pos.z) * smoothscale)
		else
			pos = targetpos
		end
		player:SetVar("thirdperson_pos", pos)

		// offset it by the stored amounts, but trace so it stays outside walls
		// we don't tween this so the camera feels like its tightly following the mouse
		local offset = Vector(5, 5, 5)
		offset.x = 120;
		offset.y = 0;
		offset.z = 0;
		
		local t = {}
		t.start = player:GetPos() + pos
		t.endpos = t.start + angles:Forward() * -offset.x
		t.endpos = t.endpos + angles:Right() * offset.y
		t.endpos = t.endpos + angles:Up() * offset.z
		t.filter = player
		
		local tr = util.TraceLine(t)
		pos = tr.HitPos
		if tr.Fraction < 1.0 then
			pos = pos + tr.HitNormal * 5
		end
			
		player:SetVar("thirdperson_viewpos", pos)

		// tween the fov
		fov = player:GetVar("thirdperson_fov") or targetfov
		if smooth != 0 then
			fov = math.Approach(fov, targetfov, math.abs(targetfov - fov) * smoothscale)
		else
			fov = targetfov
		end
		player:SetVar("thirdperson_fov", fov)

		return GAMEMODE:CalcView(player, pos, angles, fov)
	end
end)]]

hook.Add("ShouldDrawLocalPlayer", "ESThirdpersonDrawLocal", function()
	if LocalPlayer().excl and LocalPlayer().excl.thirdperson == true then
		return true;
	end
end)
