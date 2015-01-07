-- cl_player_hooks
net.Receive("ESPlayerDC",function()
	local name = net.ReadString();
	if not name then return end
	MsgC(COLOR_EXCLSERVER,name);
	MsgC(COLOR_WHITE," has left the server.\n");
end)

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

hook.Add("InitPostEntity","LoadMyStuff",function()
	RunConsoleCommand("excl_internal_load");
end)