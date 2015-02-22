-- cl_playerinfo.lua

local plyInfo
net.Receive("ESSendPlayerInfo",function()
	local info = net.ReadTable()
	if not info then return end
	
	PrintTable(info)

	if plyInfo and IsValid(plyInfo) then plyInfo:Remove() end
	
	plyInfo = vgui.Create("esFrame")
	plyInfo:SetSize(600,330)
	plyInfo:Center()
	plyInfo:SetTitle(info.nickname)

	local p = plyInfo:Add("Panel")
	p:SetSize(300,300)
	p:SetPos(0,30)

	local y = 5
	for k,v in pairs(info)do
		local row = p:Add("esPanel")
		row:SetSize(290,22)
		row:SetPos(5,y)

		row.PaintHook = function(w,h)
			draw.SimpleText(string.gsub(exclFixCaps(k),"_"," "),"ESDefaultBold",6,4,COLOR_BLACK) draw.SimpleText(tostring(v),"ESDefaultBold",w-6,4,COLOR_BLACK,2) 
		end

		row.OnMouseReleased = function()
			SetClipboardText(tostring(v))
		end

		y = y + row:GetTall() + 5
	end

	if info.latitude and info.longitude then
		local map = plyInfo:Add("HTML")
		map:SetSize(300,300)
		map:SetPos(300,31)
		map:OpenURL("http://maps.googleapis.com/maps/api/staticmap?center="..info.latitude..",%20"..info.longitude.."&zoom=12&size=298x298&maptype=roadmap&sensor=false")
	else
		plyInfo.PaintHook = function()
			draw.DrawText("No map available\nYou must be Operator or higher","ESDefault",450,160,COLOR_BLACK,1)
		end
	end
	plyInfo:MakePopup()
end)