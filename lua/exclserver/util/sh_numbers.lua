local oldtonumber=tonumber
function tonumber(n)
  if type(n) == "string" then
    if  n == "inf" or n == "+inf" then
      return 2147483647
    elseif n == "-inf" then
      return -2147483647
    elseif n == "nan" or n == "-nan" then
      return 0
    end
  end
  return oldtonumber(n)
end

function ES.ValidNumber(n)
  return type(n) == "number" and n == n and n ~= math.huge and n ~= -(math.huge) and n ~= 0/0;
end
