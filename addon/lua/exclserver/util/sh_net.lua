-- In most situations, out own serialization is a lot faster than the default.

function net.WriteTable(tab)
  net.WriteString(ES.Serialize(tab))
end
function net.ReadTable()
  return ES.Deserialize(net.ReadString())
end
