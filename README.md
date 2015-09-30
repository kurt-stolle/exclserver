ExclServer2
-----------

# Requirements
To run ExclServer2, you need the following preliminaries:
- The `gmsv_tmysql4_xxx` module;
- A MySQL compatible database;
- Access to the server filesystem;
- Access to the server console.

# Installation

_Installing ExclServer2_
Extract the `exclserver` folder into `~/garrysmod/addons/exclserver`.
There is no need to copy the content to your download server, ExclServer2 is on the Steam Workshop. The content will be downloaded automatically.

_Installing tmysql4_
See the documentation that comes with the `gmsv_tmysql4_xxx` module.

# Setup

_Ranking the server operator_
To make yourself the initial server owner, first connect to your server alone (password your server), then type `lua_run Entity(1):ESSetRank("owner",1)` in console.

# Ranks
These are all ranks from highest to lowest, custom ranks can be added by editing the `es_ranks_config` table in your favorite MySQL editor.
- Owner (owner)
- Operator (operator)
- Super Administrator (superadmin)
- Administrator (admin)
- User (user)

You can promote people in-game with the command `:rank <name/steamid> <rank e.g. superadmin/admin/user/etc...> <global? 1/0>`. For example: `:rank Excl operator 1` will make Excl an operator across all servers.

# Quick commands
_A full list of commands can be found in the in-game menu_
