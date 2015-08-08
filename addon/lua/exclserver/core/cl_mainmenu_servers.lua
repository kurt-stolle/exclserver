local servers={};

function ES._MMGenerateServerList(base)
  net.Start("ES.GetServerList")
  net.SendToServer()

  local frame= base:OpenFrame(440)
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
          lbl_name:SetText(v.name)
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

          table.insert(panels,pnl)

          local api=ES.GetSetting("API:Url")

          if not api then print("API is not LIVE!") continue end

          HTTP {
            failed=function(err)
              print("Server information fetch failed.",err)
            end,
            success=function(code,res)
              local servers=util.JSONToTable(res)
              PrintTable(res)
            end,
            method="get",
            url=api.."/api/servers/status/"..v.id,
            parameters={},
            headers={}
          }
        end
      end
  end)
end

net.Receive("ES.GetServerList",function(len)
  servers=net.ReadTable() or {}
end)
