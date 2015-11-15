--[[

ES.TimeProbe( String id )

Useful function to check how fast your code is.
Usage:

local probe=ES.TimeProbe("my function"); // Start the timer.
...
...
...
probe(); // Print the time that passed since the timer was started to console.

]]

function ES.TimeProbe(id)
  local runtime=os.clock();
  return (function()
    ES.DebugPrint(id.." took "..(os.clock() - runtime).." to run.");
  end)
end

function ES.Void() end
