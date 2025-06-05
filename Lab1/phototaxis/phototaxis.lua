MAX_VELOCITY = 15
MOVE_STEPS = 15
LIGHT_THRESHOLD = 0.01
UNDER_LIGHT_THRESHOLD = 1.5

local robot_helper = require "robot_helper"
local n_steps = 0
robot = robot_helper.extend(robot, MAX_VELOCITY)

function init()
	n_steps = 0
	robot:stop()
	robot.leds.set_all_colors("black")
end

function step()
	n_steps = robot_helper.handle_walk(handle_phototaxis, n_steps, MOVE_STEPS)
	update_lights()
end

function handle_phototaxis()
	local max_value, max_index = robot.light:max_with_index({threshold = LIGHT_THRESHOLD})
	if max_index then 
		robot:point_to({length = MAX_VELOCITY, angle = robot.light[max_index].angle})
	else
		robot:stop()
	end
end

function update_lights()
	if robot.light:sum() > UNDER_LIGHT_THRESHOLD then
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
