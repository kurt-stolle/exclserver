function exclFixCaps(s)
	return string.upper(string.Left(s,1))..string.lower(string.Right(s,string.len(s)-1));
end