-- Simple client-based idle checking
-- This system is ONLY for disallowing certain things for AFKers. It is NOT meant as a reliable anti-AFK system. The gamemode should handle that!

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

          if client:GetAngles() ~= idle.ang then
               -- Normal players will move their viewing angles all the time
               idle.ang = client:GetAngles()
               idle.t = CurTime()

               if idle.flagged then
                 net.Start("ES.Idle")
                 net.WriteBit(false)
                 net.SendToServer()
               end

               idle.flagged = false
          elseif gui.MouseX() ~= idle.mx or gui.MouseY() ~= idle.my then
               -- Players in eg. the F6 will move their mouse occasionally
               idle.mx = gui.MouseX()
               idle.my = gui.MouseY()
               idle.t = CurTime()

               if idle.flagged then
                 net.Start("ES.Idle")
                 net.WriteBit(false)
                 net.SendToServer()
               end

               idle.flagged = false
          elseif client:GetPos():Distance(idle.pos) > 10 then
               -- Even if players don't move their mouse, they might still walk
               idle.pos = client:GetPos()
               idle.t = CurTime()

               if idle.flagged then
                 net.Start("ES.Idle")
                 net.WriteBit(false)
                 net.SendToServer()
               end

               idle.flagged = false
          elseif CurTime() > (idle.t + 180) and not idle.flagged then
               -- we are afk

               net.Start("ES.Idle")
               net.WriteBit(true)
               net.SendToServer()

               idle.flagged = true
          end
      end)
