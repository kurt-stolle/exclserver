function exclGetIP()
	if game.SinglePlayer() then
		return "127.0.0.1";
	end
	
	local hostip = GetConVarString( "hostip" )
	hostip = tonumber( hostip )
	 
	local ip = {}
	ip[ 1 ] = bit.rshift( bit.band( hostip, 0xFF000000 ), 24 )
	ip[ 2 ] = bit.rshift( bit.band( hostip, 0x00FF0000 ), 16 )
	ip[ 3 ] = bit.rshift( bit.band( hostip, 0x0000FF00 ), 8 )
	ip[ 4 ] = bit.band( hostip, 0x000000FF )
	 
	return table.concat( ip, "." )..":"..GetConVarString( "hostport" );
end