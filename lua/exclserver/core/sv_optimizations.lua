local consoleCommands={
  "sv_forcepreload 1",
  "sv_unlag 1",
  "sv_maxunlag 0.5",
  "sv_minrate 5000",
  "sv_maxrate 15000",
  "sv_minupdaterate 33",
  "sv_maxupdaterate 67",
  "sv_mincmdrate 33",
  "sv_maxcmdrate 67",
  "sv_client_cmdrate_difference 1",
  "sv_client_predict 1",
  "sv_client_interpolate 1",
  "sv_client_min_interp_ratio -1",
  "sv_client_max_interp_ratio -1",
  " sv_turbophysics 1",
  "net_queued_packet_thread 0",
}

hook.Add("Initialize","ES.ApplyOptimizationCMDs",function()
  for k,v in ipairs(consoleCommands)do
    game.ConsoleCommand(v)
  end
end)
