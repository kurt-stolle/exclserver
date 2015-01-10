-- Edit these variables to configurate MySQL.
-- You can download MySQL server from the official MySQL website.

local DATABASE_HOST 	= "localhost";	-- (String) IPv4 IP of the mysql server.
local DATABASE_PORT 	= 3306;			-- (Number) mysql server port.
local DATABASE_SCHEMA 	= "exclserver"; -- (String) name of the schema that should be used.
local DATABASE_USERNAME = "root";		-- (String) Username
local DATABASE_PASSWORD = "rordrmew";   -- (String) Password

-- Do not edit anything under this line, unless you're a competent Lua developer.

require "mysqloo"

ES.ServerID = 0;

if not mysqloo then 
	ES:DebugPrint("MySQLOO module not found. Please install the MySQLOO module before using ExclServer.");
	return;
end

local db = mysqloo.connect( DATABASE_HOST, DATABASE_USERNAME, DATABASE_PASSWORD, DATABASE_SCHEMA, DATABASE_PORT );
db.onConnected = function(database)
	ES.DebugPrint("Successfully connected to MySQL database! :)");
end;
db.onConnectionFailed = function(Q,e) 
	ES.DebugPrint("Could not connect to mysql, "..e);
end

local function MySQLError(q,e)
	e = string.gsub(e,"You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near","Syntax error at");
	ES.DebugPrint("MySQL error:")
	ES.DebugPrint("   > "..tostring(q));
	ES.DebugPrint("   < error: "..e);
end

function ES.DBQuery(request,fn,fnError)
	if db:status() != mysqloo.DATABASE_CONNECTED then 
		ES.DebugPrint("No connection to MySQL server active, (re)connecting.");
		db:connect();
		db:wait();
	end
		
	local query = db:query(request);
	query:setOption(mysqloo.OPTION_CACHE,true);
	query.onError = fnError or (MySQLError)
	query.onSuccess = function(self,dt)
		if not fn or type(fn) != "function" then return end
		fn( dt )
	end
	query:start()
end
function ES.DBEscape(t)
 	return db:escape(t);
end
function ES.DBWait()
	return db:wait();
end

local esDataTables = {};
function ES.DBDefineTable(name,onLoad,vars)
	if vars then
		vars = vars..",";
	end

	table.insert(esDataTables,{name = name,onLoad = (onLoad or false),vars = (vars or "")});
end
ES.DBDefineTable( "player",false,	"steamid varchar(32), bananas int(32), inventory varchar(255), invmodel char(255), invtrail char(255), invmelee char(255), invtaunt char(255), invaura char(255), activehat varchar(64), activeaura varchar(64), activetrail varchar(64), activemelee varchar(255), activemodel varchar(255), viptier int(8), trailcolor varchar(255), trailscale varchar(255), slot1 varchar(255), slot2 varchar(255), slot3 varchar(255), slot4 varchar(255), slot5 varchar(255), slot6 varchar(255), slot7 varchar(255), slot8 varchar(255)")
ES.DBDefineTable( "servers_lookup",false,	"ip varchar(100), prettyname varchar(100)")

function ES:AddPlayerData(p,k,v,nosave)
	v=tostring(v);
	if not p.excl then 
		p.excl = {} 
	end
	p.excl[k] = v;

	if nosave then return end
	
	ES.DBQuery("UPDATE es_player SET "..k.." = '"..ES.DBEscape(v).."' WHERE id = "..tonumber(p:ESID())..";", function() end);
end

hook.Add("Initialize","ES.Data.InitializeServer",function()
	hook.Call("ESDBDefineTables")
	for k,v in pairs(esDataTables)do
		ES.DBQuery("CREATE TABLE IF NOT EXISTS es_"..v.name.." ( id int(16) NOT NULL AUTO_INCREMENT,"..v.vars.." PRIMARY KEY (id) );",function() end);
	end
	ES.DBWait()
	ES.DBQuery("SELECT id FROM es_servers_lookup WHERE ip = '"..exclGetIP().."' LIMIT 1;",function(r)
		if r and r[1] then
			ES.ServerID = r[1].id;
			hook.Call("ESPostGetServerID")
		else
			ES.DBQuery("INSERT INTO es_servers_lookup SET ip = '"..exclGetIP().."';",function()
				ES.DBQuery("SELECT id FROM es_servers_lookup WHERE ip = '"..exclGetIP().."' LIMIT 1;",function(r)
					if r and r[1] then
						ES.ServerID = r[1].id;
						hook.Call("ESPostGetServerID")
					end
				end);
			end)
			ES.DBWait()
		end
	end)
	ES.DBWait() 
end);


hook.Add("ESPostGetServerID","ES.Data.PostServerID",function()
	ES.DebugPrint("Server ID set: "..ES.ServerID);

	for k,v in pairs(esDataTables) do
		if v.onLoad and type(v.onLoad) == "function" then
			v.onLoad(ES.ServerID);
		end
	end
end)