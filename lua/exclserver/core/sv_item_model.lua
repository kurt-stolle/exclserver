util.AddNetworkString("es.item.model.transform")

local acts={"cheer","disagree","becon","wave","group","forward","agree"}

concommand.Add("excl_item_model_transform",function(p)
  if not IsValid(p) or table.HasValue(ES.DefaultModels,p:ESGetActiveModel()) or p:ESGetActiveModel() == p:GetModel() then return end

  p:ESSendNotification("generic","You have transformed to your active model")
  p:SetModel(p:ESGetActiveModel())

  net.Start("es.item.model.transform")
  net.WriteEntity(p)
  net.Broadcast()

  p:ConCommand("act "..table.Random(acts));
end)

hook.Add("PlayerSpawn","es.item.model.notify",function(p)
  timer.Simple(0,function()
    if not IsValid(p) then return end
    if not table.HasValue(ES.DefaultModels,p:ESGetActiveModel()) then
      p:ChatPrint("You have a custom model equipped. Press <hl>F6</hl> to transform.");
      ES.DebugPrint("Player has a custom model. Let's tell him about it.")
    else
      ES.DebugPrint("Player does not have a custom model. "..p:ESGetActiveModel())
    end
  end)
end)
