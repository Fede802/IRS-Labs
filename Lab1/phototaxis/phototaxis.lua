local sensor_helper = require "sensor_helper"

MOVE_STEPS = 15
MAX_VELOCITY = 10
LIGHT_THRESHOLD = 1.5

n_steps = 0

function set_random_wheel_velocity()
	left_v = robot.random.uniform(0,MAX_VELOCITY)
	right_v = robot.random.uniform(0,MAX_VELOCITY)
	robot.wheels.set_velocity(left_v,right_v)
end

function init()
	n_steps = 0
	robot.light = sensor_helper.extend(robot.light)
	set_random_wheel_velocity()
	robot.leds.set_all_colors("black")
end

function step()
	n_steps = n_steps + 1
	max_value, max_index = robot.light.max_with_index()
	
	if n_steps % MOVE_STEPS == 0 then
		if max_index == nil then 
			set_random_wheel_velocity()
		else
			angle = robot.light[max_index].angle
			wheeldistance = robot.wheels.axis_length
			local k = 0.5
			w = k * angle
			local v = 10 
			left_v = v - (w * wheeldistance / 2)
			right_v = v + (w * wheeldistance / 2)
			robot.wheels.set_velocity(left_v, right_v)
		end			
	end
	
	if robot.light.sum > LIGHT_THRESHOLD then
		robot.leds.set_all_colors("green")
	else
		robot.leds.set_all_colors("black")	
	end


end

function reset()
	init()
end

function destroy()
	-- do nothing
end
