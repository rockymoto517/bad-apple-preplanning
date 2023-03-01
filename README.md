# Bad Apple in Preplanning
This mod is pretty easy to setup, just drag and drop "PaydayMod" into your mods folder and assign the proper keybinds after you load the game. You can rename it to whatever you want.

If you want to change the framerate that the video is rendered at (the default is 3fps) then go to PaydayMod/lua/draw.lua and edit what comes after the >= sign. If you want it to play in x fps, then set the value to 1/x. 

    local  function  do_drawing(t, dt)
	    if BadAppleTime >=  0.333333  then
		    -- Play video at 3 fps (speed up later in editing)
		    -- Can set to 0.0333667 if you want to play it at the original ~29.97fps
		    managers.menu_component._preplanning_map:erase_drawing()
		    if  not  draw_data(get_data_from_file(get_file())) then
			    -- When we exhaust all data files, stop drawing
			    Hooks:UnregisterHook("draw_bad_apple")
		    end
		    BadAppleTime =  BadAppleTime - 0.333333
	    else
		    BadAppleTime = BadAppleTime + dt
	    end
    end
    
