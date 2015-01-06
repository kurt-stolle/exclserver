-- taunts are getting annoying >.>


function ES:TauntCamera()

    local CAM = {}

    local WasOn                    = false;

    local CustomAngles            = Angle( 0, 0, 0 )
    local PlayerLockAngles        = nil

    local InLerp                = 0;
    local OutLerp                = 1;
    

    --
    -- Draw the local player if we're active in any way
    --
    CAM.ShouldDrawLocalPlayer = function( self, ply, on )

        return on || OutLerp < 1;

    end

    --
    -- Implements the third person, rotation view (with lerping in/out)
    --
    CAM.CalcView = function( self, view, ply, on )
            
        if ( !ply:Alive() ) then on = false end

        if ( WasOn != on ) then

            if ( on ) then InLerp = 0 end
            if ( !on ) then OutLerp = 0 end

            WasOn = on

        end

        if ( !on && OutLerp >= 1 ) then 

            CustomAngles = view.angles * 1
            PlayerLockAngles = nil
            InLerp = 0;
            return 

        end

        if ( PlayerLockAngles == nil ) then return end

        trace = {};
        trace.start = view.origin
		trace.endpos = view.origin - CustomAngles:Forward() * 128;
		trace.filter = player.GetAll()
		
	    trace = util.TraceLine(trace)
        local TargetOrigin = trace.HitPos + trace.HitNormal*2;

        if ( InLerp < 1 ) then

            InLerp = InLerp + FrameTime() * 5.0
            view.origin = LerpVector( InLerp, view.origin, TargetOrigin )
            view.angles = LerpAngle( InLerp, PlayerLockAngles, CustomAngles )
            return true;

        end

        if ( OutLerp < 1 ) then

            OutLerp = OutLerp + FrameTime() * 3.0
            view.origin = LerpVector( 1-OutLerp, view.origin, TargetOrigin )
            view.angles = LerpAngle( 1-OutLerp, PlayerLockAngles, CustomAngles )
            return true;

        end

        view.angles = CustomAngles * 1
        view.origin = TargetOrigin
        return true;

    end

    --
    -- Freezes the player in position and uses the input from the user command to
    -- rotate the custom third person camera
    --
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
        cmd:SetViewAngles( PlayerLockAngles );
        cmd:ClearButtons();
        cmd:ClearMovement();
        
        return true

    end
        

    return CAM;

end

local camera = ES:TauntCamera();

hook.Add("CreateMove","disableMovesOnTaunt",function()
	if LocalPlayer():IsPlayingTaunt() then return true end
end)

hook.Add("ShouldDrawLocalPlayer","enableTPOnTaunt",function()
	if camera:ShouldDrawLocalPlayer( LocalPlayer(), LocalPlayer():IsPlayingTaunt() ) then return true end
end)

hook.Add("CalcView", "exclTPTaunt", function(ply, pos , angles ,fov,znear,zfar)
	local view = {origin = pos, angles = angles, fov = fov, znear = znear, zfar = zfar, drawviewer = false}

	if camera:CalcView(  view, ply, LocalPlayer():IsPlayingTaunt() ) then return view end
end)

hook.Add("CreateMove","disableMovesOnTaunt",function(cmd)
	if camera:CreateMove( cmd, LocalPlayer(), LocalPlayer():IsPlayingTaunt() ) then return true end
end)