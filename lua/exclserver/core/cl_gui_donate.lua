
local wide=330;

local pnl;
concommand.Add("es_menu_donate",function()
  if IsValid(pnl) then pnl:Remove() end

  pnl=vgui.Create("esFrame")
  pnl:SetSize(wide,wide*.65)
  pnl:Center()
  pnl:SetTitle("DONATE")
  pnl:DockPadding(0,30,0,0)


  local text=Label(ES.FormatLine("For every $1 you donate, you will get 1000 bananas.\nDonating is the easiest way to earn bananas quickly.\nDon't wait any longer!","ESDefault",pnl:GetWide()-40),pnl)
  text:DockMargin(20,20,20,20)
  text:SetFont("ESDefault")
  text:Dock(TOP)
  text:SizeToContents()

  local sub=pnl:Add("Panel")
  sub:SetTall(20)
  sub:Dock(TOP)
  sub:DockMargin(20,0,40,0)

    local amount_lbl=Label("DONATION AMOUNT (USD):   ",sub)
    amount_lbl:SetFont("ESDefaultBold")
    amount_lbl:Dock(LEFT)
    amount_lbl:SizeToContents()

    local entry=vgui.Create("esTextEntry",sub)
    entry:Dock(FILL);
    entry:SetNumeric(true)
    entry:SetFont("ESDefaultBold")
    entry:SetValue(5)

  local btn_donate=vgui.Create("esButton",pnl)
  btn_donate:SetText("Donate")
  btn_donate:Dock(BOTTOM)
  btn_donate:SetTall(30)
  btn_donate:DockMargin(20,40,20,20)
  btn_donate.OnMouseReleased=function()
    gui.OpenURL("https://es2-api.casualbananas.com/donate?amt="..(entry:GetValue() ~= "" and entry:GetValue() or "1").."&sid="..LocalPlayer():SteamID())

    local fill=vgui.Create("esPanel")
    fill:SetSize(ScrW(),ScrH())
    fill:MakePopup()

    local lbl=Label("You are currently making a donation of $"..(entry:GetValue() ~= "" and entry:GetValue() or "1").." to Casual Bananas.",fill)
    lbl:SetFont("ESDefault++")
    lbl:SizeToContents()
    lbl:Center();
    lbl:SetColor(ES.Color.White)

    local btn=fill:Add("esButton")
    btn:SetText("Done")
    btn:SetSize(300,30)
    btn:SetPos(fill:GetWide()/2 - btn:GetWide()/2, lbl.y + lbl:GetTall()+30)
    btn.DoClick=function()
      LocalPlayer():ConCommand("retry;")
    end
  end

  pnl:MakePopup()
end)
