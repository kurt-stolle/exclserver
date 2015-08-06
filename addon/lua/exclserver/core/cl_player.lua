hook.Add("InitPostEntity","exclserver.player.ready",function()
    timer.Simple(0,function()
      RunConsoleCommand("excl_ready");
    end)
end)

-- Taunt Camera, shamelessly stolen from the garrysmod base.
function ES.TauntCamera()

    local CAM = {}

    local WasOn                    = false

    local CustomAngles            = Angle( 0, 0, 0 )
    local PlayerLockAngles        = nil

    local InLerp                = 0
    local OutLerp                = 1

    CAM.ShouldDrawLocalPlayer = function( self, ply, on )

        return on or OutLerp < 1

    end
    CAM.CalcView = function( self, view, ply, on )

        if ( !ply:Alive() ) then on = false end

        if ( WasOn ~= on ) then

            if ( on ) then InLerp = 0 end
            if ( !on ) then OutLerp = 0 end

            WasOn = on

        end

        if ( !on && OutLerp >= 1 ) then

            CustomAngles = view.angles * 1
            PlayerLockAngles = nil
            InLerp = 0
            return

        end

        if ( PlayerLockAngles == nil ) then return end

        trace = {}
        trace.start = view.origin
		trace.endpos = view.origin - CustomAngles:Forward() * 128
		trace.filter = player.GetAll()

	    trace = util.TraceLine(trace)
        local TargetOrigin = trace.HitPos + trace.HitNormal*2

        if ( InLerp < 1 ) then

            InLerp = InLerp + FrameTime() * 5.0
            view.origin = LerpVector( InLerp, view.origin, TargetOrigin )
            view.angles = LerpAngle( InLerp, PlayerLockAngles, CustomAngles )
            return true

        end

        if ( OutLerp < 1 ) then

            OutLerp = OutLerp + FrameTime() * 3.0
            view.origin = LerpVector( 1-OutLerp, view.origin, TargetOrigin )
            view.angles = LerpAngle( 1-OutLerp, PlayerLockAngles, CustomAngles )
            return true

        end

        view.angles = CustomAngles * 1
        view.origin = TargetOrigin
        return true

    end
    CAM.CreateMove = function( self, cmd, ply, on )

        if ( !ply:Alive() ) then on = false end
        if ( !on ) then return end

        if ( PlayerLockAngles == nil ) then
            PlayerLockAngles = CustomAngles * 1
        end

        --
        -- Rotate our view
        --
        CustomAngles.pitch    = CustomAngles.pitch    + cmd:GetMouseY() * 0.01
        CustomAngles.yaw    = CustomAngles.yaw        - cmd:GetMouseX() * 0.01

        --
        -- Lock the player's controls and angles
        --
        cmd:SetViewAngles( PlayerLockAngles )
        cmd:ClearButtons()
        cmd:ClearMovement()

        return true

    end

    return CAM
end

local camera = ES.TauntCamera()
hook.Add("CreateMove","ES.Taunt.HandleMove",function()
	if LocalPlayer():IsPlayingTaunt() then return true end
end)
hook.Add("ShouldDrawLocalPlayer","ES.Taunt.HandleThirdPerson",function()
	if camera:ShouldDrawLocalPlayer( LocalPlayer(), LocalPlayer():IsPlayingTaunt() ) then return true end
end)
hook.Add("CalcView", "ES.Taunt.HandleView", function(ply, pos , angles ,fov,znear,zfar)
	local view = {origin = pos, angles = angles, fov = fov, znear = znear, zfar = zfar, drawviewer = false}

	if camera:CalcView(  view, ply, ply:IsPlayingTaunt() ) then return view end
end)
hook.Add("CreateMove","ES.Taunt.HandleMove2",function(cmd)
	if camera:CreateMove( cmd, LocalPlayer(), LocalPlayer():IsPlayingTaunt() ) then return true end
end)
