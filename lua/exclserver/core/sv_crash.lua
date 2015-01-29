-- sv_crash.lua

util.AddNetworkString("ESCrashPong")
concommand.Add("excl_ping",function(p)
	if (p.LastPing and p.LastPing + 4 < CurTime()) or not p.LastPing then      
   		p.LastPing = CurTime()
                       
   		net.Start("ESCrashPong")
    	net.Send( p )
    end
end);