-- This is basically a rewrite of vON.
-- Most if not all serializations should be fully compatible.
-- Be aware though that it is not recommended to use both notations interchangably.

-- Prototypes
local Deserialize, Serialize;

-- Functions, this is an optimization.
local sub, gsub, find, insert, concat, error, tonumber, tostring, type, next, Entity = string.sub, string.gsub, string.find, table.insert, table.concat, error, tonumber, tostring, type, next, Entity;

-- This is kept away from the table for speed.
local function findVariable(s, i, len, lastType, jobstate)
	local i, c, typeRead, val = i or 1

	while true do
		if i > len then
			error("Reached end of string, can not parse.")
		end
		c = sub(s, i, i)
		if typeRead then
			val, i = Deserialize[lastType](s, i, len, false, jobstate)
			return val, i, lastType
		elseif c == "@" then
			return nil, i, lastType
		elseif c == "$" then
			lastType = "table_reference"
			typeRead = true
		elseif c == "n" then
			lastType = "number"
			typeRead = true
		elseif c == "b" then
			lastType = "boolean"
			typeRead = true
		elseif c == "'" then
			lastType = "string"
			typeRead = true
		elseif c == "{" then
			lastType = "table"
			typeRead = true
		elseif c == "e" then
			lastType = "Entity"
			typeRead = true
		elseif c == "p" then
			lastType = "Entity"
			typeRead = true
		elseif c == "v" then
			lastType = "Vector"
			typeRead = true
		elseif c == "a" then
			lastType = "Angle"
			typeRead = true
		elseif lastType then
			val, i = Deserialize[lastType](s, i, len, false, jobstate)
			return val, i, lastType
		else
			error("Can't find a type definition. Char#" .. i .. ":" .. c)
		end

		i = i + 1
	end
end

local function serializeVariable(data, lastType, isNumeric, isKey, isLast, jobstate)
	local tp = type(data)

	if jobstate[1] and jobstate[2][data] then
		tp = "table_reference"
	end

	if lastType ~= tp then
		lastType = tp

		if Serialize[lastType] then
			return Serialize[lastType](data, true, isNumeric, isKey, isLast, false, jobstate), lastType
		else
			error("No serializer for type \"" .. lastType .. "\"!")
		end
	end

	return Serialize[lastType](data, false, isNumeric, isKey, isLast, false, jobstate), lastType
end

-- Definitions for deserialization
Deserialize = {
	["table"] = function(s, i, len, unnecessaryEnd, jobstate)
		local ret, numeric, i, c, lastType, val, ind, expectValue, key = {}, true, i or 1, nil, nil, nil, 1

		if sub(s, i, i) == "#" then
			local e = find(s, "#", i + 2, true)

			if e then
				local id = tonumber(sub(s, i + 1, e - 1))

				if id then
					if jobstate[1][id] and not jobstate[2] then
						error("There already is a table of reference #" .. id .. "! Missing an option maybe?")
					end

					jobstate[1][id] = ret

					i = e + 1
				else
					error("Malformed table! Reference ID starting at char #" .. i .. " doesn't contain a number!")
				end
			else
				error("Malformed table! Cannot find end of reference ID start at char #" .. i .. "!")
			end
		end

		while true do
			if i > len then
				if unnecessaryEnd then
					return ret, i
				else
					error("Reached end of string, incomplete table definition.")
				end
			end
			c = sub(s, i, i)

			if c == "}" then
				return ret, i
			elseif c == "~" then
				numeric = false
			elseif c == ";" then
        -- NOTHING
			elseif numeric then
				val, i, lastType = findVariable(s, i, len, lastType, jobstate)

				ret[ind] = val

				ind = ind + 1
			else
				if expectValue then
					val, i, lastType = findVariable(s, i, len, lastType, jobstate)
					ret[key] = val
					expectValue, key = false, nil
				elseif c == ":" then
					expectValue = true
				elseif key then
					error("Malformed table. Char#" .. i .. ":" .. c)
				else
					key, i, lastType = findVariable(s, i, len, lastType, jobstate)
				end
			end

			i = i + 1
		end

		return nil, i
	end,
	["table_reference"] = function(s, i, len, unnecessaryEnd, jobstate)
		local i, a = i or 1

		a = find(s, "[;:}~]", i)

		if a then
			local n = tonumber(sub(s, i, a - 1))

			if n then
				return jobstate[1][n] or error("Table reference does not point to known table!"), a - 1
			else
				error("Table reference definition does not contain a valid number!")
			end
		end
		error("Number definition started. Found no end.")
	end,
	["number"] = function(s, i, len, unnecessaryEnd, jobstate)
		local i, a = i or 1

		a = find(s, "[;:}~]", i)

		if a then
			return tonumber(sub(s, i, a - 1)) or error("Number definition does not contain a valid number!"), a - 1
		end
		error("Number definition started. Found no end.")
	end,
	["boolean"] = function(s, i, len, unnecessaryEnd, jobstate)
		local c = sub(s,i,i)

		if c == "1" then
			return true, i
		elseif c == "0" then
			return false, i
		end

		error("Invalid value on boolean type. Char#" .. i .. ": " .. c)
	end,
	["string"] = function(s, i, len, unnecessaryEnd, jobstate)
		local res, i, a = "", i or 1

		while true do
			a = find(s, "\"", i, true)

			if a then
				if sub(s, a - 1, a - 1) == "\\" then
					res = res .. sub(s, i, a - 2) .. "\""
					i = a + 1
				else
					return res .. sub(s, i, a - 1), a
				end
			else
				error("String definition started. Found no end.")
			end
		end
	end,
  ["Entity"] = function(s, i, len, unnecessaryEnd, jobstate)
    local i, a = i or 1
    --	Locals, locals, locals, locals

    a = find(s, "[;:}~]", i)

    if a then
      return Entity(tonumber(sub(s, i, a - 1))), a - 1
    end

    error("Entity ID definition started. Found no end.")
  end,
  ["Vector"] = function(s, i, len, unnecessaryEnd, jobstate)
    local i, a, x, y, z = i or 1
    --	Locals, locals, locals, locals

    a = find(s, ",", i)

    if a then
      x = tonumber(sub(s, i, a - 1))
      i = a + 1
    end

    a = find(s, ",", i)

    if a then
      y = tonumber(sub(s, i, a - 1))
      i = a + 1
    end

    a = find(s, "[;:}~]", i)

    if a then
      z = tonumber(sub(s, i, a - 1))
    end

    if x and y and z then
      return Vector(x, y, z), a - 1
    end

    error("Vector definition started. Found no end.")
  end,
  ["Angle"] = function(s, i, len, unnecessaryEnd, jobstate)
    local i, a, p, y, r = i or 1
    --	Locals, locals, locals, locals

    a = find(s, ",", i)

    if a then
      p = tonumber(sub(s, i, a - 1))
      i = a + 1
    end

    a = find(s, ",", i)

    if a then
      y = tonumber(sub(s, i, a - 1))
      i = a + 1
    end

    a = find(s, "[;:}~]", i)

    if a then
      r = tonumber(sub(s, i, a - 1))
    end

    if p and y and r then
      return Angle(p, y, r), a - 1
    end

    error("Angle definition started. Found no end.")
  end
}

-- Definitions for serilizations
Serialize = {
	["table"] = function(data, mustInitiate, isNumeric, isKey, isLast, first, jobstate)
		local result, keyvals, len, keyvalsLen, keyvalsProgress, val, lastType, newIndent, indentString = {}, {}, #data, 0, 0

		for k, v in next, data do
			if type(k) ~= "number" or k < 1 or k > len or (k % 1 ~= 0) then
				keyvals[#keyvals + 1] = k
			end
		end

		keyvalsLen = #keyvals

		if not first then
			result[#result + 1] = "{"
		end

		if jobstate[1] and jobstate[1][data] then
			if jobstate[2][data] then
				error("Table #" .. jobstate[1][data] .. " written twice..?")
			end

			result[#result + 1] = "#"
			result[#result + 1] = jobstate[1][data]
			result[#result + 1] = "#"

			jobstate[2][data] = true
		end

		if len > 0 then
			for i = 1, len do
				val, lastType = serializeVariable(data[i], lastType, true, false, i == len and not first, jobstate)
				result[#result + 1] = val
			end
		end

		if keyvalsLen > 0 then
			result[#result + 1] = "~"

			for _i = 1, keyvalsLen do
				keyvalsProgress = keyvalsProgress + 1

				val, lastType = serializeVariable(keyvals[_i], lastType, false, true, false, jobstate)

				result[#result + 1] = val..":"

				val, lastType = serializeVariable(data[keyvals[_i]], lastType, false, false, keyvalsProgress == keyvalsLen and not first, jobstate)

				result[#result + 1] = val
			end
		end
		if not first then
			result[#result + 1] = "}"
		end

		return concat(result)
	end,
	["table_reference"] = function(data, mustInitiate, isNumeric, isKey, isLast, first, jobstate)
		data = jobstate[1][data]

		if mustInitiate then
			if isKey or isLast then
				return "$"..data
			else
				return "$"..data..";"
			end
		end

		if isKey or isLast then
			return data
		else
			return data..";"
		end
	end,
	["number"] = function(data, mustInitiate, isNumeric, isKey, isLast, first, jobstate)
		--	If a number hasn't been written before, add the type prefix.
		if mustInitiate then
			if isKey or isLast then
				return "n"..data
			else
				return "n"..data..";"
			end
		end

		if isKey or isLast then
			return data
		else
			return data..";"
		end
	end,
	["string"] = function(data, mustInitiate, isNumeric, isKey, isLast, first, jobstate)
		if sub(data, #data, #data) == "\\" then	--	Hah, old strings fix this best.
			return "\"" .. gsub(data, "\"", "\\\"") .. "v\""
		end

		return "'" .. gsub(data, "\"", "\\\"") .. "\""
	end,
	["boolean"] = function(data, mustInitiate, isNumeric, isKey, isLast, first, jobstate)
		--	Prefix if we must.
		if mustInitiate then
			if data then
				return "b1"
			else
				return "b0"
			end
		end

		if data then
			return "1"
		else
			return "0"
		end
	end,
  ["Entity"] = function(data, mustInitiate, isNumeric, isKey, isLast, first, jobstate)
    data = data:EntIndex()

    if mustInitiate then
      if isKey or isLast then
        return "e"..data
      else
        return "e"..data..";"
      end
    end

    if isKey or isLast then
      return data
    else
      return data..";"
    end
  end,
  ["Vector"] = function(data, mustInitiate, isNumeric, isKey, isLast, first, jobstate)
    if mustInitiate then
      if isKey or isLast then
        return "v"..data.x..","..data.y..","..data.z
      else
        return "v"..data.x..","..data.y..","..data.z..";"
      end
    end

    if isKey or isLast then
      return data.x..","..data.y..","..data.z
    else
      return data.x..","..data.y..","..data.z..";"
    end
  end,
  ["Angle"] = function(data, mustInitiate, isNumeric, isKey, isLast, first, jobstate)
    if mustInitiate then
      if isKey or isLast then
        return "a"..data.p..","..data.y..","..data.r
      else
        return "a"..data.p..","..data.y..","..data.r..";"
      end
    end

    if isKey or isLast then
      return data.p..","..data.y..","..data.r
    else
      return data.p..","..data.y..","..data.r..";"
    end
  end,
	["nil"] = function(data, mustInitiate, isNumeric, isKey, isLast, first, jobstate)
		return "@"
	end
}


-- There are multiple types that are all child classes of Entity type.
local extraEntityTypes = { "Vehicle", "Weapon", "NPC", "Player", "NextBot" }

for i = 1, #extraEntityTypes do
	Serialize[extraEntityTypes[i]] = Serialize.Entity
end

-- Check whether table has recursive elements
local function checkTableForRecursion(tab, checked, assoc)
	local id = checked.ID

	if not checked[tab] and not assoc[tab] then
		assoc[tab] = id
		checked.ID = id + 1
	else
		checked[tab] = true
	end

	for k, v in pairs(tab) do
		if type(k) == "table" and not checked[k] then
			checkTableForRecursion(k, checked, assoc)
		end

		if type(v) == "table" and not checked[v] then
			checkTableForRecursion(v, checked, assoc)
		end
	end
end


-- This is an optimization
local serializeTable = Serialize.table
local deserializeTable = Deserialize.table

-- Implement into ES
function ES.Deserialize(str, allowIdRewriting)
	if type(str) == "string" then
		return deserializeTable(str, nil, #str, true, {{}, allowIdRewriting})
	end
	error("Unsupported type "..type(str))
end
function ES.Serialize(data, checkRecursion)
	if type(data) == "table" then
		if checkRecursion then
			local assoc, checked = {}, {ID = 1}
			checkTableForRecursion(data, checked, assoc)
			return serializeTable(data, nil, nil, nil, nil, true, {assoc, {}})
		end
		return serializeTable(data, nil, nil, nil, nil, true, {false})
	end
	error("Unsupported type: "..type(data))
end
