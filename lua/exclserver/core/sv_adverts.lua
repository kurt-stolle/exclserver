-- sv_adverts.lua

ES.Adverts = {}
hook.Add("ESDBDefineTables","ESAdsDatatableSetup",function()
	ES.DBDefineTable("adverts",function(serverid)
		ES.DBQuery("SELECT * FROM es_adverts WHERE map = '"..game.GetMap().."'",function(res)
			if res and res[1] then
				for k,v in pairs(res)do
					local ad = ents.Create("es_advert")
					ad:SetPos(Vector(v.pos))
					ad:SetAngles(Angle(v.ang))
					ad:Spawn()
					ad:SetText(v.text)
					ad:SetXAlignment(v.xalign)
					ad:SetTextScale(v.scale)
					ad:SetID(v.id)

					ES.Adverts[v.id] = ad
				end
			end
			ES.DebugPrint("3d2d adverts loaded")
		end)
	end,"pos varchar(255), ang varchar(255), text varchar(255), xalign int(1), map varchar(100), scale float(8,8)")
end)

function ES.AddAdvert(text,pos,normal,scale,align)
	scale = scale or .4
	align = align or 1

	pos = pos + normal * 0.2

	ES.DBQuery("INSERT INTO es_adverts SET text = '"..text.."', pos = '"..tostring(pos).."', ang = '"..tostring(normal:Angle()).."', scale = "..scale..", xalign = "..align..", map = '"..game.GetMap().."'")

	local ad = ents.Create("es_advert")
		ad:SetPos(pos)
		ad:SetAngles(normal:Angle())
		ad:Spawn()
		ad:SetText(text)
		ad:SetXAlignment(align)
		ad:SetTextScale(scale)
end

hook.Add("Initialize","addCom`wddwmandswdouhdawiuawdhiuwadd",function()

ES.AddCommand("advert",function(p,a)
	if not IsValid(p) or not a or not a[1] then return end
	
	ES.AddAdvert(table.concat(a," "), p:GetEyeTrace().HitPos, p:GetEyeTrace().HitNormal, .4, 1)
end,60)

ES.AddCommand("editadvert",function(p,a)
	if not IsValid(p) or not a[1] then return end

	local id = tonumber(a[1])
	local ent = ES.Adverts[id]
	if not ent or not IsValid(ent) then p:ChatPrint("Not a valid advert (try reloading the map)") return end

	local scale = tonumber(a[2]) or ent:GetTextScale()
	local xalign = tonumber(a[3]) or ent:GetXAlignment()
	local text = ent:GetText()
	if a[4] then
		table.remove(a,1)
		table.remove(a,1)
		table.remove(a,1)
		text = table.concat(a," ")
	end

	ES.DBQuery("UPDATE es_adverts SET scale = "..scale..", xalign = "..xalign..", text = '"..text.."' WHERE id = "..id.."")
	ent:SetText(text)
	ent:SetTextScale(scale)
	ent:SetXAlignment(xalign)
end,60)

end)