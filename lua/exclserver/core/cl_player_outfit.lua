net.Receive("ES.Player.UpdateOutfit",function(len)
	ES.DebugPrint("Received item update. len: "..len);

	local ply=net.ReadEntity();

	if not IsValid(ply) then return end
	
	local outfit=net.ReadTable();

	if not outfit then return end
	
	ply._es_outfit=outfit;
end);

local drawPos,drawAng,drawScale,item,mtr,drawBone,pos,ang;
hook.Add("PostPlayerDraw", "ES.DrawPlayerOutfit", function(p)
	if p._es_outfit then

		for k,v in pairs(p._es_outfit) do
			item=ES.Props[v.item];
			drawBone=v.bone;
			drawPos=v.pos;
			drawAng=v.ang;
			drawScale=v.scale;
			drawColor=v.color;

			if not item or not drawPos or not drawAng or not drawScale or not drawColor or not IsValid(item.cMdl) or not drawBone then continue end

			drawColor=ES.Color[v.color];
			drawScale=item.scale + drawScale;

			item=item.cMdl;

			drawBone=p:LookupBone(drawBone);

			if not drawColor or not drawScale or not drawBone then continue end

			mtr=Matrix();
			mtr:Scale(drawScale);

			item:EnableMatrix("RenderMultiply", mtr);
			item:SetColor(drawColor);

			pos,ang = p:GetBonePosition(drawBone);

			pos = pos + (ang:Up() * drawPos.y) + (ang:Forward() * drawPos.y) + (ang:Right() * drawPos.x);

			ang:RotateAroundAxis(ang:Forward(),drawAng.p);
			ang:RotateAroundAxis(ang:Up(),drawAng.y);
			ang:RotateAroundAxis(ang:Right(),drawAng.r);

			item:SetRenderOrigin( pos );
			item:SetRenderAngles( ang );
			item:SetupBones();
			item:DrawModel();
			item:SetRenderOrigin();
			item:SetRenderAngles();
		end
	end
end)