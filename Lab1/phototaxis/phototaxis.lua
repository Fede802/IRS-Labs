MAX_VELOCITY = 10
MOVE_STEPS = 15
LIGHT_THRESHOLD = 1.5

local robot_helper = require "robot_helper"
local n_steps = 0
robot = robot_helper.extend(robot)

function init()
	n_steps = 0
	robot.set_random_wheel_velocity(MAX_VELOCITY)
	robot.leds.set_all_colors("black")
end

function step()
	move_with(movement_action)
	update_lights()
end

function move_with(movement_action)
	n_steps = n_steps + 1
	if n_steps % MOVE_STEPS == 0 then
		n_steps = 0
		movement_action()		
	end
end

function movement_action()
	local max_value, max_index = robot.light.max_with_index()
	if max_index == nil then 
		robot.set_random_wheel_velocity(MAX_VELOCITY)
	else
		local k = 0.5
		robot.point_to({length = MAX_VELOCITY, angle = robot.light[max_index].angle * k})
	end
end

function update_lights()
	if robot.light.sum() > LIGHT_THRESHOLD then
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
