MOVE_STEPS = 15
MAX_VELOCITY = 10
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
	handle_walk()
    handle_collision()
end

function handle_walk()
	n_steps = n_steps + 1
	if n_steps % MOVE_STEPS == 0 then
		n_steps = 0
		robot.set_random_wheel_velocity(MAX_VELOCITY)		
	end
end

function handle_collision(threshold)
	local threshold = threshold or 0.0
	local max_left_proximity, max_left_proximity_index = robot.proximity.max_with_index(threshold, 1, 7)
	local max_right_proximity, max_right_proximity_index = robot.proximity.max_with_index(threshold, 18, 24)
	if (max_left_proximity > threshold) or (max_right_proximity > threshold) then
		robot.leds.set_all_colors("red")
		if max_left_proximity > max_right_proximity then
			robot.wheels.set_velocity(MAX_VELOCITY / 2, - MAX_VELOCITY / 2)
		else
			robot.wheels.set_velocity(MAX_VELOCITY / 2, - MAX_VELOCITY / 2)
		end
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