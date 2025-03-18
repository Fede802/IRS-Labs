-- Put your global variables here

MOVE_STEPS = 15
MAX_VELOCITY = 10
LIGHT_THRESHOLD = 1.5

n_steps = 0


--[[ This function is executed every time you press the 'execute'
     button ]]
function init()
	left_v = robot.random.uniform(0,MAX_VELOCITY)
	right_v = robot.random.uniform(0,MAX_VELOCITY)
	robot.wheels.set_velocity(left_v,right_v)
	n_steps = 0
	robot.leds.set_all_colors("black")
end

function findMaxValue(arr)
    local maxVal = 0  -- Start with the first element's value
    local maxIdx = 0
    for i = 1, 7 do
        if arr[i].value > maxVal then
            maxVal = arr[i].value
            maxIdx = i
        end
    end
    for i = 18, 24 do
        if arr[i].value > maxVal then
            maxVal = arr[i].value
            maxIdx = i
        end
    end
    
    return maxVal, maxIdx
end

--[[ This function is executed at each time step
     It must contain the logic of your controller ]]
function step()
	n_steps = n_steps + 1
	max_value, max_idx = findMaxValue(robot.proximity)
	log("max" .. max_idx)
	if n_steps % MOVE_STEPS == 0 then
		if max_idx == 0 then 
			left_v = robot.random.uniform(0,MAX_VELOCITY)
			right_v = robot.random.uniform(0,MAX_VELOCITY)
			robot.wheels.set_velocity(left_v,right_v)
		else
			log("rotating")
			angle = 5
			wheeldistance = robot.wheels.axis_length
			local k = 0.5
			w = k * angle
			local v = 0 
			left_v = v - (w * wheeldistance / 2)
			right_v = v + (w * wheeldistance / 2)
			robot.wheels.set_velocity(left_v, right_v)
		end			
	end
	--log("robot.position.x = " .. robot.positioning.position.x)
	--log("robot.position.y = " .. robot.positioning.position.y)
	--log("robot.position.z = " .. robot.positioning.position.z)
	
	
	-- Search for the reading with the highest value
	value = -1 -- highest value found so far
	idx = -1   -- index of the highest value
	for i=1,#robot.proximity do
		if value < robot.proximity[i].value then
			idx = i
			value = robot.proximity[i].value
		end
	end
	--log("robot max proximity sensor: " .. idx .. "," .. value)



end



--[[ This function is executed every time you press the 'reset'
     button in the GUI. It is supposed to restore the state
     of the controller to whatever it was right after init() was
     called. The state of sensors and actuators is reset
     automatically by ARGoS. ]]
function reset()
	left_v = robot.random.uniform(0,MAX_VELOCITY)
	right_v = robot.random.uniform(0,MAX_VELOCITY)
	robot.wheels.set_velocity(left_v,right_v)
	n_steps = 0
	robot.leds.set_all_colors("black")
end



--[[ This function is executed only once, when the robot is removed
     from the simulation ]]
function destroy()
   -- put your code here
end
