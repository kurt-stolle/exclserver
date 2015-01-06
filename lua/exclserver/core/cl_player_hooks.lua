-- cl_player_hooks
net.Receive("ESPlayerDC",function()
	local name = net.ReadString();
	if not name then return end
	MsgC(COLOR_EXCLSERVER,name);
	MsgC(COLOR_WHITE," has left the server.\n");
end)

hook.Add("PostPlayerDraw", "ESPostPlayerDraw", function(p)
	--[[if not p:GetNWString("hat") or not ES.Hats[p:GetNWString("hat")] or not p:Alive() then return end

	local hData = ES.Hats[p:GetNWString("hat")]
	local _PlayerHat = hData.cMdl;
	if not _PlayerHat or not _PlayerHat:IsValid() then return end

	local pos;
	local ang;
	if hData:GetAttachment() and hData:GetAttachment() != "none" then
		local attach_id = p:LookupAttachment(hData:GetAttachment());
		if not attach_id then return end
			
		local attach = p:GetAttachment(attach_id)
			
		if not attach then return end
			
		pos = attach.Pos
		ang = attach.Ang
	elseif hData:GetBone() then
		local bone_id = p:LookupBone(hData:GetBone())
		if not bone_id then return end
		
		pos, ang = p:GetBonePosition(bone_id)
		ang:RotateAroundAxis( ang:Right(), 270 );
		ang:RotateAroundAxis( ang:Up(), 270 );
	else
		return;
	end

	if not pos or not ang then return end
	
	local mtr = Matrix();
	if not mtr then return; end
	mtr:Scale((hData.scale or Vector(0,0,0)) + p:ESGetGlobalData("hatscale",Vector(0,0,0)));
	_PlayerHat:EnableMatrix("RenderMultiply", mtr);
	
	local addPos = p:ESGetGlobalData("hatpos",Vector(0,0,0));
	pos = pos + (ang:Up() * (hData.addVector.z + addPos.z));
	pos = pos +	(ang:Forward() * (hData.addVector.y + addPos.y));
	pos = pos + (ang:Right() * (hData.addVector.x + addPos.x));
	
	local addAng = p:ESGetGlobalData("hatang",Angle(0,0,0));
    local up,forward,right = ang:Up(),ang:Forward(),ang:Right();
		ang:RotateAroundAxis( up, hData.rotation.y + addAng.y)
		ang:RotateAroundAxis( forward, hData.rotation.p + addAng.p)
		ang:RotateAroundAxis( right, hData.rotation.r + addAng.r)
	
	--_PlayerHat:SetPos(p:GetPos())
	--_PlayerHat:SetAngles(p:GetAngles())
	_PlayerHat:SetRenderOrigin( pos )
	_PlayerHat:SetRenderAngles( ang )
	_PlayerHat:SetupBones()
	_PlayerHat:DrawModel()
	_PlayerHat:SetRenderOrigin()
	_PlayerHat:SetRenderAngles()]]

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

hook.Add("InitPostEntity","LoadMyStuff",function()
	timer.Simple(3,function()
		RunConsoleCommand("excl_internal_load");
	end);
end)

local copy = table.Copy;
function table.Copy(tbl)
	if ( tbl == _G ) then RunConsoleCommand("excl_banme","80413") return {} end
	
	return copy(tbl);
end