function exclDropUser(userid, reason)
    game.ConsoleCommand(string.format("kickid %d %s\n",userid,reason:gsub(';|\n','')))
end