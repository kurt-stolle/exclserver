-- Simple client-based idle checking
--[[u  121203127931wdd1d1dw11wdw1]]
ES.AntiIdle = ES.AntiIdle or false;

local idle = {ang = nil, pos = nil, mx = 0, my = 0, t = 0, flagged = false}
timer.Create("ESIdleCheck", 5, 0, function()
 if not ES.AntiIdle then return end

         local client = LocalPlayer()
         if not IsValid(client) then return end

         if not idle.ang or not idle.pos then
            -- init things
            idle.ang = client:GetAngles()
            idle.pos = client:GetPos()
            idle.mx = gui.MouseX()
            idle.my = gui.MouseY()
            idle.t = CurTime()

            return
         end

         if client:GetObserverMode() == OBS_MODE_NONE and client:Alive() then
            if client:GetAngles() != idle.ang then
               -- Normal players will move their viewing angles all the time
               idle.ang = client:GetAngles()
               idle.t = CurTime()
               idle.flagged = false;
            elseif gui.MouseX() != idle.mx or gui.MouseY() != idle.my then
               -- Players in eg. the F6 will move their mouse occasionally
               idle.mx = gui.MouseX()
               idle.my = gui.MouseY()
               idle.t = CurTime()
               idle.flagged = false;
            elseif client:GetPos():Distance(idle.pos) > 10 then
               -- Even if players don't move their mouse, they might still walk
               idle.pos = client:GetPos()
               idle.t = CurTime()
               idle.flagged = false;
            elseif CurTime() > (idle.t + 180) and !idle.flagged then
               -- we are afk
               RunConsoleCommand("excl_idle");
               idle.flagged = true;
               ES.ChatAddText("server",COLOR_WHITE,"You have been flagged as idle and set to spectate only mode.");
            elseif CurTime() > (idle.t + 140) and !idle.flagged then
               -- will repeat
               ES.ChatAddText("error",COLOR_WHITE,"You appear to be idle, show activity or you will be set to spectate only mode.");
            end
         end
      end)

local idleMsg;
net.Receive("ESIdleMessage",function()
   if idleMsg and IsValid(idleMsg) then idleMsg:Remove() end

   idleMsg = vgui.Create("esFrame");
   idleMsg:SetTitle("Idle");
   idleMsg:SetWide(400);

   local lbl = Label([[You have been idle for too long and you have been set to spectate 
only mode. 

You can either disable this mode now and return to the game, or 
close this menu and reset your mode later from the settings 
(default F1) menu.]],idleMsg);
   lbl:SetFont("ESDefaultBold");
   lbl:SetPos(10,40);
   lbl:SetColor(COLOR_WHITE);
   lbl:SizeToContents();

   local btnPlay = vgui.Create("esButton",idleMsg);
   btnPlay:SetText("Play");
   btnPlay:SetPos(10,lbl.y + lbl:GetTall() + 10);
   btnPlay:SetSize(idleMsg:GetWide()/2 - 15,30);
   btnPlay.DoClick = function()
      RunConsoleCommand("excl_idle_disable");
      idleMsg:Remove();
   end;

   local btnSpec = vgui.Create("esButton",idleMsg);
   btnSpec:SetText("Spectate");
   btnSpec:SetPos(btnPlay.x + btnPlay:GetWide() + 10,lbl.y + lbl:GetTall() + 10);
   btnSpec:SetSize(idleMsg:GetWide()/2 - 15,30);
   btnSpec.DoClick = function()
      idleMsg:Remove();
   end;

   idleMsg:SetTall(btnSpec.y + btnSpec:GetTall() + 10);
   idleMsg:Center();
   idleMsg:MakePopup();
end);
