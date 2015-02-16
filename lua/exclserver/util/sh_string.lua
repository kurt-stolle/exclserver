function ES.FixGrammar(s)
	local build=string.upper(string.Left(s,1))..string.Right(s,string.len(s)-1)

	if string.Right(build,1) ~= "." then
		build=build.."."
	end

	return build
end
function ES.FormatLine(str,font,size) --note to self: size equals width in pixes
	surface.SetFont( font )
	
	local start = 1
	local c = 1	
	local endstr = ""
	local n = 0
	local lastspace = 0
	while( string.len( str ) > c )do
		local sub = string.sub( str, start, c )
		if( string.sub( str, c, c ) == " " ) then
			lastspace = c
		end

		if( surface.GetTextSize( sub ) >= size ) then
			local sub2
			
			if( lastspace == 0 ) then
				lastspace = c
			end
			
			if( lastspace > 1 ) then
				sub2 = string.sub( str, start, lastspace - 1 )
				c = lastspace
			else
				sub2 = string.sub( str, start, c )
			end
			endstr = endstr .. sub2 .. "\n"
			start = c + 1
			n = n + 1	
		end
		c = c + 1
	end
	
	if( start < string.len( str ) ) then
		endstr = endstr .. string.sub( str, start )
	end
	
	return endstr, n
end