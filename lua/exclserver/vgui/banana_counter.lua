local PNL={}
local bananaDisplay;
--local icon_bananas = Material("exclserver/bananas_gray.png")
function PNL:Paint(w,h)
  local p = LocalPlayer()

--[[  surface.SetDrawColor(ES.Color.White)
  surface.SetMaterial(icon_bananas)
  surface.DrawTexturedRect(0,h/2 - 32,64,64)]]

  if not (IsValid(p) and p:ESGetNetworkedVariable("bananas") ) then
    draw.SimpleText("Loading...","ES.Notification",0,h/2,ES.Color.White,0,1)
  else
    if not didLoad then
      bananaDisplay = p:ESGetBananas()
    end
    local add = 0
    local bananaDisplayRound = math.Round(bananaDisplay)
    if bananaDisplayRound ~= p:ESGetBananas() then
      if bananaDisplay - p:ESGetBananas() > 0 then
        bananaDisplay = Lerp(0.01,bananaDisplay-1,p:ESGetBananas())
      else
        bananaDisplay = Lerp(0.01,bananaDisplay+1,p:ESGetBananas())
      end
      add = (p:ESGetBananas()-bananaDisplayRound)
    else
      bananaDisplay = bananaDisplayRound
    end

    draw.SimpleText("You have "..bananaDisplayRound.." Bananas","ESDefaultBold",0,h/2,ES.Color.White,0,1)
  end
end
vgui.Register("esBananaCounter",PNL,"Panel")
