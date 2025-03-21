---@diagnostic disable: undefined-global
-- Put your global variables here
local vector = require "vector"

MOVE_STEPS = 15
MAX_VELOCITY = 10
LIGHT_THRESHOLD = 1.5

n_steps = 0


--[[ This function is executed every time you press the 'execute'
     button ]]
function init()
	local left_v = robot.random.uniform(0,MAX_VELOCITY)
	local right_v = robot.random.uniform(0,MAX_VELOCITY)
	robot.wheels.set_velocity(left_v,right_v)
	n_steps = 0
	robot.leds.set_all_colors("black")
end

function proximity_vector_field()
    local max_proximity_sensor_index = find_max_value(robot.proximity)
    print("proximity" .. max_proximity_sensor_index)
    if max_proximity_sensor_index > 0 then
        local obstacle_angle = robot.proximity[max_proximity_sensor_index].angle
        local opposite_obstacle_angle = (obstacle_angle + math.pi) % (2*math.pi)
        return (10 - robot.proximity[max_proximity_sensor_index].value) / 10, opposite_obstacle_angle
    end
    return 0, 0

end
function on_spot()
	for i=1,4 do
		if robot.motor_ground[i].value <= 0.1 then
			return true
		end
	end
	return false
end	

function light_vector_field()
    local max_light_sensor_index = find_max_value(robot.light)
    print("light" .. max_light_sensor_index)
    if on_spot() then
        return 0, 0, true
    end
    if max_light_sensor_index > 0 then
        local light_angle = robot.light[max_light_sensor_index].angle
        return -(-1 + robot.light[max_light_sensor_index].value), light_angle, false
    end
    return 0, 0, false
end


function find_max_value(arr)
    local maxVal = 0.02  -- Start with the first element's value
    local maxIdx = 0
    for i = 1, #arr do
        if arr[i].value > maxVal then
            maxVal = arr[i].value
            maxIdx = i
        end
    end
    return maxIdx
end



--[[ This function is executed at each time step
     It must contain the logic of your controller ]]
function step()
	n_steps = n_steps + 1
    local v1, w1 = proximity_vector_field()
    local v2, w2, stand = light_vector_field()
    local v_polar_coordinate = vector.vec2_polar_sum({length = v1, angle = w1}, {length = v2, angle = w2})
    local v = v_polar_coordinate.length * 15
    local w = v_polar_coordinate.angle / 2
	if v == 0 and not stand then
		if n_steps % MOVE_STEPS == 0 then 
			local left_v = robot.random.uniform(0,MAX_VELOCITY)
			local right_v = robot.random.uniform(0,MAX_VELOCITY)
            print("random")
			robot.wheels.set_velocity(15, 15)
        end
    else    
        local wheeldistance = robot.wheels.axis_length
        local left_v = math.max(-15, math.min( v - (w * wheeldistance / 2), 15))
        local right_v = math.max(-15, math.min( v + (w * wheeldistance / 2), 15))
        print("detected" .. v)
        robot.wheels.set_velocity(left_v, right_v)			
	end
	
	sum = 0
	for i=1,#robot.light do
		sum = sum + robot.light[i].value
	end
	if sum > LIGHT_THRESHOLD then
		robot.leds.set_all_colors("green")
	else
	robot.leds.set_all_colors("black")
			
	end


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
