local consoleCommands={
  "r_threaded_client_shadow_manager 1",
  "r_threaded_renderables 1",
  "cl_ejectbrass 0",
  "mat_showlowresimage 0",
  "mat_fastnobump 1",
  "mat_framebuffercopyoverlaysize 0",
  "mat_forcehardwaresync 0",
  "mat_forcemanagedtextureintohardware 0",
  "r_updaterefracttexture 0",
  "r_renderoverlayfragment 0",
  "r_maxnewsamples 0",
  "r_maxsampledist 0",
  "r_norefresh 0",
  "r_minnewsamples 0",
  "flex_smooth 0",
  "mat_disable_fancy_blending 1",
  "mat_force_bloom 0",
  "r_worldlightmin 0",
  "r_dopixelvisibility 0",
  "r_ambientboost 0",
  "r_ambientfactor 1",
  "r_PhysPropStaticLighting 0",
  "mat_disable_lightwarp 1",
  "mat_shadowstate 0",
  "fov_desired 90",
  "cl_forcepreload 1",
  "rate 15000",
  "cl_cmdrate 67",
  "cl_updaterate 67"
}

hook.Add("InitPostEntity","ES.ApplyOptimizationCMDs",function()
  for k,v in ipairs(consoleCommands)do
    LocalPlayer():ConCommand(v)
  end
end)
