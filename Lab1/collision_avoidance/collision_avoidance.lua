MOVE_STEPS = 15
MAX_VELOCITY = 15
ROTATION_VELOCITY = 5
PROXIMITY_THRESHOLD = 0.01

local robot_helper = require "robot_helper"
local n_steps = 0
robot = robot_helper.extend(robot, MAX_VELOCITY)

function init()
	n_steps = 0
	robot:set_random_wheel_velocity()
	robot.leds.set_all_colors("black")
end

function step()
	n_steps = robot_helper.handle_walk(robot.random_walk_behaviour, n_steps, MOVE_STEPS)
    handle_collision(PROXIMITY_THRESHOLD)
end

function proximity_perception(threshold)
	local max_left_value, max_left_index = robot.proximity:max_with_index({threshold = threshold, start_index = 1, end_index = 5})
	local max_right_value, max_right_index = robot.proximity:max_with_index({threshold = threshold, start_index = 20, end_index = 24})
	if max_left_index and max_right_index then
		return max_left_value > max_right_value and max_left_value, max_left_index or max_right_value, max_right_index
	elseif max_left_index then
		return max_left_value, max_left_index
	elseif max_right_index then
		return max_right_value, max_right_index
	else
		return nil
	end				
end

function handle_collision(threshold)
	local _, max_index = proximity_perception(threshold)
	if max_index then
		-- With this avoidance strategy, the robot might get stuck.
		-- if robot.proximity:is_left(max_index) then
		-- 	robot:rotate_right(ROTATION_VELOCITY)
		-- else 
		-- 	robot:rotate_left(ROTATION_VELOCITY)
		-- end	
		robot:rotate_left(ROTATION_VELOCITY)
		robot.leds.set_all_colors("red")
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