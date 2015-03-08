local escape='(['..("%^$().[]*+-?"):gsub("(.)", "%%%1")..'])';
local function getServerInfo(ip,callback)
        HTTP{
            url="https://www.gametracker.com/server_info/"..ip.."/",
            method="get",
            parameters={},
            headers={},
            failed=function(e)
                    ES.DebugPrint("Failed to receive server info for ip "..ip.." with reason "..e)
            end,
            success=function(code,body,headers)
                pcall(function()ES.DebugPrint("Received server info (code "..code..")");
                    body=string.gsub(body,escape, "%%%1")

                    local _,startpos,endpos
                    _,startpos=string.find(body,"SERVER DETAILS");
                    endpos=string.find(body,"GAME SERVER BANNERS");
                    body=string.sub( body, startpos, endpos)

                    body=string.gsub( body, "<(.-)>", "")
                    body=string.gsub( body, "\n", "")
                    body=string.gsub( body, "&nbsp;","");
                    body=string.gsub( body, "\t","")
                    body=string.gsub( body, "%%","")

                    local players=string.match(body,"Current Players:(%d+ / %d+)")
                    local map=string.match(body,"CURRENT MAP(.*)Upload")
                    local name=string.match(body,"Name:(.*)Game:")
                    local status=string.match(body,"Status:(.*)Server Manager:")

                    callback(name or "", map or "", players or "", status or "Offline")
                  end)
            end
        }

end

local servers={};

function ES._MMGenerateServerList(base)
  net.Start("ES.GetServerList")
  net.SendToServer()

  local frame= base:OpenFrame(500)
  frame:SetTitle("Servers")

  local panels={}
  local container=vgui.Create("esPanel",frame)
  container:SetSize(frame:GetWide()-30,frame:GetTall()-30)
  container:SetPos(15,15)
  container:SetColor(ES.Color.Invisible)
  container:AddScrollbar()

  hook.Add("Think","ES.MM_Servers.ServerListUpdate",function()
      if not IsValid(frame) then
        hook.Remove("Think","ES.MM_Servers.ServerListUpdate")
        return
      end

      if #servers ~= #panels then
        for k,v in ipairs(panels)do
          if IsValid(v) then
            v:Remove()
          end
        end

        for k,v in ipairs(servers)do
          local pnl=vgui.Create("esPanel",container)
          pnl:SetSize(container:GetWide()-8-8,66)
          pnl:SetPos(0,#panels*(pnl:GetTall()+15))

          local lbl_name = pnl:Add("esLabel");
          lbl_name:SetText(v)
          lbl_name:SetPos(10,8)
          lbl_name:SetFont("ESDefaultBold")
          lbl_name:SizeToContents()

          local lbl_players = pnl:Add("esLabel")
          lbl_players:SetPos(10,lbl_name.y + lbl_name:GetTall() + 4)
          lbl_players:SetFont("ESDefault");
          lbl_players:SetText("0/0 Players")
          lbl_players:SizeToContents()

          local lbl_map = pnl:Add("esLabel")
          lbl_map:SetPos(10,lbl_players.y + lbl_players:GetTall() + 4)
          lbl_map:SetFont("ESDefault");
          lbl_map:SetText("Playing on unknown map")
          lbl_map:SizeToContents()

          local btn_conn =pnl:Add("esButton")
          btn_conn:SetPos(pnl:GetWide()-102,2)
          btn_conn:SetSize(100,30)
          btn_conn:SetText("Connect")

          local btn_copy = pnl:Add("esButton")
          btn_copy:SetPos(pnl:GetWide()-102,34)
          btn_copy:SetSize(100,30)
          btn_copy:SetText("Copy IP")

          getServerInfo(v,function(name,map,players,status)
            if IsValid(pnl) then
              if status ~= "Alive" then
                lbl_players:SetText("OFFLINE")
                lbl_players:SizeToContents()
                lbl_map:SetText("")
                return
              end

              lbl_name:SetText(name)
              lbl_name:SizeToContents()

              lbl_players:SetText(players.." Players")
              lbl_players:SizeToContents()

              lbl_map:SetText("Playing on "..map)
              lbl_map:SizeToContents()
            end
          end)

          table.insert(panels,pnl)
        end
      end
  end)
end

net.Receive("ES.GetServerList",function(len)
  servers=net.ReadTable() or {}
end)
