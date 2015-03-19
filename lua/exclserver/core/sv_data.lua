-- Edit these variables to configurate MySQL.
-- Edit these variables to configurate MySQL.
-- You can download MySQL server from the official MySQL website.

local DATABASE_HOST     = "188.165.214.55";                                     -- (String) IPv4 IP of the mysql server.
local DATABASE_PORT     = 3306;                                                 -- (Number) mysql server port.
local DATABASE_SCHEMA   = "exclserver";                                         -- (String) name of the schema that shoul$
local DATABASE_USERNAME = "exclserver";                                         -- (String) Username
local DATABASE_PASSWORD = "#x6eQ56m593r83b5mky2YvbeP64E2MyQP";						  		-- (String) Password

-- Do not edit anything under this line, unless you're a competent Lua developer.

require "mysqloo"

ES.ServerID = -1

if not mysqloo then
	ES.DebugPrint("MySQLOO module not found. Please install the MySQLOO module before using ExclServer.")
	return
end
local esDataTables = {}

local initialized=false

ES.DebugPrint("Connecting to MySQL...")
local db = mysqloo.connect( DATABASE_HOST, DATABASE_USERNAME, DATABASE_PASSWORD, DATABASE_SCHEMA, DATABASE_PORT )
db.onConnected = function(database)
	ES.DebugPrint("Successfully connected to MySQL database :)")

	-- Make sure we don't call this twice.
	if initialized then return end
	initialized=true

	-- Get the server's IP.
	local serverIP=ES.GetServerIP()

	-- Query to check whether the required tables exist.
	ES.DBQuery("SELECT `table_name` FROM information_schema.tables WHERE `table_schema` = '"..DATABASE_SCHEMA.."';",function(res)
		local notFound = false

		-- Check whether we have at least 11 tab
		if not res or #res < 12 then

			notFound=true

		else
			for _,lookup in ipairs{"es_restrictions_props","es_restrictions_tools","es_blockades","es_settings","es_player_inventory","es_player_fields","es_player_outfit","es_ranks","es_bans","es_ranks_config","es_logs","es_servers"} do
				local found=false;
				for _,v in ipairs(res)do
					if v.table_name == lookup then
						found=true
						break;
					end
				end

				if not found then
					notFound=true
					break;
				end
			end

		end

		if notFound then

			ES.DebugPrint("Server not fully set up yet. Setting up server...")

			ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_restrictions_props` (`id` smallint unsigned not null AUTO_INCREMENT, model varchar(255), serverid smallint unsigned not null default 0, req int(8) unsigned, PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1"):wait()
			ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_restrictions_tools` (`id` smallint unsigned not null AUTO_INCREMENT, toolmode varchar(255), serverid smallint unsigned not null default 0, req int(9) unsigned, PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1"):wait()
			ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_blockades` (`id` smallint unsigned not null AUTO_INCREMENT, mapname varchar(255), startX int(16), startY int(16), startZ int(16), endX int(16), endY int(16), endZ int(16), PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1"):wait()
			ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_settings` (`id` smallint unsigned NOT NULL AUTO_INCREMENT, value varchar(255), name varchar(255), serverid tinyint(3) unsigned, PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1"):wait()
			ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_player_inventory` (`id` int unsigned NOT NULL AUTO_INCREMENT, steamid varchar(100), itemtype tinyint unsigned, name varchar(255), PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=InnoDB DEFAULT CHARSET=latin1"):wait()
			ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_player_fields` (`id` int unsigned NOT NULL AUTO_INCREMENT, steamid varchar(100), PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=InnoDB DEFAULT CHARSET=latin1"):wait()
			ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_player_outfit` (`id` int unsigned NOT NULL AUTO_INCREMENT, steamid varchar(100), slot int(8) unsigned NOT NULL, item varchar(255), bone varchar(255), pos varchar(255), ang varchar(255), scale varchar(255), color varchar(255), UNIQUE KEY (`id`, `slot`)) ENGINE=MyISAM DEFAULT CHARSET=latin1"):wait()
			ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_ranks` ( `id` int unsigned NOT NULL AUTO_INCREMENT, steamid varchar(50), serverid int(10), rank varchar(100), PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1" ):wait()
			ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_bans` (`ban_id` int unsigned NOT NULL AUTO_INCREMENT, steamid varchar(100), steamidAdmin varchar(100), name varchar(100), nameAdmin varchar(100), serverid int(8), unbanned tinyint(1), time int(32), timeStart int(32), reason varchar(255), PRIMARY KEY (`ban_id`), UNIQUE KEY `ban_id` (`ban_id`)) ENGINE=MyISAM DEFAULT CHARSET=utf8"):wait()
			ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_ranks_config` ( `id` int(10) unsigned NOT NULL AUTO_INCREMENT, name varchar(100), prettyname varchar(200), power int(16), PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1"):wait()
			ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_logs` (`id` int unsigned NOT NULL AUTO_INCREMENT, text varchar(255), type tinyint unsigned not null, time int unsigned not null, serverid tinyint unsigned not null, PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8"):wait()
			ES.DBQuery("CREATE TABLE IF NOT EXISTS `es_servers` ( `id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT, ip varchar(100), PRIMARY KEY (`id`), UNIQUE KEY (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1"):wait()

			ES.DebugPrint("Reloading server to finalise data setup (1/2)...")
			game.ConsoleCommand("map "..game.GetMap().."\n")
		else

			ES.DebugPrint("Setting up server ID...")

			ES.DBQuery("SELECT id FROM es_servers WHERE ip = '"..serverIP.."' LIMIT 1",function(r)
				if r and r[1] then
					ES.DebugPrint("Server ID found: "..r[1].id)
					ES.ServerID = r[1].id
					hook.Call("ESDatabaseReady",GM or GAMEMODE,ES.ServerID)
				else
					ES.DebugPrint("No server ID found! Registering server...")
					ES.DBQuery("INSERT INTO es_servers SET ip = '"..serverIP.."'",function()
						ES.DebugPrint("Reloading server to finalise data setup (2/2)...")
						game.ConsoleCommand("map "..game.GetMap().."\n")
					end):wait()
				end
			end):wait()

			ES.DebugPrint("Checking player fields...")

			for k,v in pairs(ES.NetworkedVariables)do
				if v.save then
					ES.DebugPrint("Checking player field: "..k)
					ES.DBQuery("ALTER TABLE `es_player_fields` ADD "..ES.DBEscape(k).." "..v.save.."",function()
						ES.DebugPrint("Added column.")
					end,function()
						ES.DebugPrint("Column already exists.")
					end):wait()
				end
			end

			ES.DebugPrint("Loading custom ranks...")

			ES.DBQuery("SELECT * FROM es_ranks_config",function(data)
				if not data or not data[1] then return end
				for k,v in pairs(data)do
					ES.SetupRank(v.name,v.prettyname,tonumber(v.power))
				end
			end):wait()
		end
	end):wait()
end
db.onConnectionFailed = function(Q,e)
	ES.DebugPrint("Could not connect to mysql, "..e)
end

local void=true
hook.Add("InitPostEntity","ES.InitDatabase",function()
	void=nil

	db:connect()
	db:wait()
end)

local function MySQLError(q,e,sql)
	ES.DebugPrint("MySQL error:")
	ES.DebugPrint("   > "..tostring(sql))
	ES.DebugPrint("   < error: "..e)
end

function ES.DBQuery(request,fn,fnError)
	local query = db:query(request)

	if not query then
		if void then
			ES.DebugPrint("Voided MySQL call - called too early!")
			return
		end

		if db:status() ~= DATABASE_CONNECTED then
			db:connect()
			db:wait()

			query=db:query(request)
		end
	end

	query:setOption(mysqloo.OPTION_CACHE,true)
	query.onError = fnError or (MySQLError)
	query.onSuccess = function(self,dt)
		if not fn or type(fn) ~= "function" then return end
		fn( dt )
	end
	query:start()

	return query
end
function ES.DBEscape(t)
 	return db:escape(t)
end
