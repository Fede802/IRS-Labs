local sensor_helper = require "sensor_helper"
local robot_helper = {}

function robot_helper.extend(robot, configuration)
    robot.light = robot.light and sensor_helper.extend(robot.light, configuration.light_sensor_group)
    robot.proximity = robot.proximity and sensor_helper.extend(robot.proximity, configuration.proximity_sensor_group)
    local extensions = {
        set_random_wheel_velocity = function(max_velocity) return set_random_wheel_velocity(robot, max_velocity) end,
        point_to = function(vector) return point_to(robot, vector) end,
        handle_collision = function(threshold) return handle_collision(robot, threshold) end
    }

    return setmetatable(robot, {
        __index = function(_, key)
            return extensions[key]
        end
    })
end

function set_random_wheel_velocity(robot, max_velocity)
    local left_v = robot.random.uniform(0, max_velocity)
    local right_v = robot.random.uniform(0, max_velocity)
    robot.wheels.set_velocity(left_v, right_v)
end

function point_to(robot, vector)
    local wheeldistance = robot.wheels.axis_length
    local w = vector.angle
    local v = vector.length 
    local left_v = v - (w * wheeldistance / 2)
    local right_v = v + (w * wheeldistance / 2)
    robot.wheels.set_velocity(left_v, right_v)
end

function handle_collision(robot, threshold)
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

return robot_helper
