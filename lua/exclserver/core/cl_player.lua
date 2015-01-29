-- cl_player_hooks
hook.Add("PostPlayerDraw", "ESPostPlayerDraw", function(p)
	local drawpos,drawang,slotdata,pos,ang,item,scale,bone,color;
	for i=1, 2+(p:ESGetVIPTier()) do
		slotdata = p:ESGetGlobalData("slot"..i,false);
		if slotdata and type( slotdata ) == "string" and slotdata != "" then
			local exp = string.Explode("|",slotdata);
			if not exp or not exp[1] or not exp[2] or not exp[3] or not exp[4] or not exp[5] or not exp[6] then continue end

			item = ES.Items[exp[1]];
			if not item or not item.cMdl or not IsValid(item.cMdl) then continue end
			scale = Vector(item:GetScale(),item:GetScale(),item:GetScale()) + Vector(exp[4]);
			item = item.cMdl;
			pos = Vector(exp[2]);
			ang = Angle(exp[3]);
			bone = tostring(exp[5]);
			color = string.Explode(" ",exp[6]) or {};
			color = Color(color[1] or 255,color[2] or 255,color[3] or 255)

			bone = p:LookupBone(bone)
			local mtr = Matrix();
			if not bone or not mtr then continue end
			mtr:Scale(scale);
			item:EnableMatrix("RenderMultiply", mtr);
			item:SetColor(color or COLOR_WHITE);
		
			drawpos, drawang = p:GetBonePosition(bone)
			
			drawpos = drawpos + (drawang:Up() * 			pos.z);
			drawpos = drawpos +	(drawang:Forward() * 		pos.y);
			drawpos = drawpos + (drawang:Right() * 			pos.x);
			
			drawang:RotateAroundAxis( drawang:Forward(), 	ang.p)
			drawang:RotateAroundAxis( drawang:Up(), 		ang.y)
			drawang:RotateAroundAxis( drawang:Right(), 		ang.r)

			item:SetRenderOrigin( drawpos )
			item:SetRenderAngles( drawang )
			item:SetupBones()
			item:DrawModel()
			item:SetRenderOrigin()
			item:SetRenderAngles()
		end
	end

end)

hook.Add("InitPostEntity","ES.FixLadders",function()
    RunConsoleCommand("cl_pred_optimize","1");
end)

hook.Add("InitPostEntity","LoadMyStuff",function()
	net.Start("ES.PlayerReady") net.SendToServer();
end)

function ES.TauntCamera()

    local CAM = {}

    local WasOn                    = false;

    local CustomAngles            = Angle( 0, 0, 0 )
    local PlayerLockAngles        = nil

    local InLerp                = 0;
    local OutLerp                = 1;
    
    CAM.ShouldDrawLocalPlayer = function( self, ply, on )

        return on || OutLerp < 1;

    end
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

local camera = ES.TauntCamera();
hook.Add("CreateMove","ES.Taunt.HandleMove",function()
	if LocalPlayer():IsPlayingTaunt() then return true end
end)
hook.Add("ShouldDrawLocalPlayer","ES.Taunt.HandleThirdPerson",function()
	if camera:ShouldDrawLocalPlayer( LocalPlayer(), LocalPlayer():IsPlayingTaunt() ) then return true end
end)
hook.Add("CalcView", "ES.Taunt.HandleView", function(ply, pos , angles ,fov,znear,zfar)
	local view = {origin = pos, angles = angles, fov = fov, znear = znear, zfar = zfar, drawviewer = false}

	if camera:CalcView(  view, ply, LocalPlayer():IsPlayingTaunt() ) then return view end
end)
hook.Add("CreateMove","ES.Taunt.HandleMove2",function(cmd)
	if camera:CreateMove( cmd, LocalPlayer(), LocalPlayer():IsPlayingTaunt() ) then return true end
end)