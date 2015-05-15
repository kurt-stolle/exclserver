hook.Add("ESPlayerReady","ES.ClaimDonations",function(ply)
  ES.DBQuery("SELECT amount FROM `es_donations` WHERE paid=1 AND claimed=0 AND steamid='"..ply:SteamID().."';",function(res)
    if res and res[1] then
      for k,v in ipairs(res) do
        local amt=tonumber(v.amount)*1000;

        ES.DBQuery("UPDATE `es_donations` SET claimed=1 WHERE steamid='"..ply:SteamID().."';",function()
          ply:ESAddBananas(amt)
          ply:ESChatPrint("Thank you for donating! You have been given <hl>"..tostring(amt).."</hl> bananas.");
        end)
      end
    end
  end)
end)
