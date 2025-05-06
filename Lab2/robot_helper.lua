local function set_random_wheel_velocity(robot, max_velocity)
    local left_v = robot.random.uniform(0, max_velocity)
    local right_v = robot.random.uniform(0, max_velocity)
    robot.wheels.set_velocity(left_v, right_v)
end

local function point_to(robot, vector)
    local wheeldistance = robot.wheels.axis_length
    local w = vector.angle
    local v = vector.length
    
    local left_v = v - (w * wheeldistance / 2)
    local right_v = v + (w * wheeldistance / 2)
    
    local max_v = math.max(math.abs(left_v), math.abs(right_v))
    
    if max_v > vector.max_velocity then
        local scale = vector.max_velocity / max_v
        left_v = left_v * scale
        right_v = right_v * scale
    end
    robot.wheels.set_velocity(left_v, right_v)
end

local function get_proximity_perception(robot, threshold)
    local max_left_proximity, _ = robot.proximity:max_with_index({threshold = threshold, start_index = 1, end_index = 7})
    local max_right_proximity, _ = robot.proximity:max_with_index({threshold = threshold, start_index = 18, end_index = 24})
    return max_left_proximity, max_right_proximity
end

local function rotate_left(robot, velocity)
    robot.wheels.set_velocity(-velocity, velocity)
end

local function rotate_right(robot, velocity)
    rotate_left(robot, -velocity)
end

local function avoid_collision(robot, max_left_proximity, max_right_proximity)
    local obstacle_on_the_left = max_left_proximity > max_right_proximity
    if obstacle_on_the_left then rotate_right(robot, MAX_VELOCITY / 2) else rotate_left(robot, MAX_VELOCITY / 2) end
end

local function handle_collision(robot, threshold, on_collision)
    local threshold = threshold or 0.0
	local max_left_proximity, max_right_proximity = get_proximity_perception(robot, threshold)
    local collision_detected = max_left_proximity > threshold or max_right_proximity > threshold
	if collision_detected then
        if on_collision then on_collision() end
        avoid_collision(robot, max_left_proximity, max_right_proximity)
        -- robot.leds.set_all_colors("red")
	else
		-- robot.leds.set_all_colors("black")  
	end
end

local sensor_helper = require "sensor_helper"
local robot_helper = {}

function robot_helper.handle_walk(movement_action, n_steps)
    n_steps = n_steps + 1
    if n_steps % MOVE_STEPS == 0 then
        n_steps = 0
        movement_action()		
    end
    return n_steps
end

function robot_helper.extend(robot, configuration)
    robot.light = robot.light and sensor_helper.extend(robot.light, configuration.light_sensor_group)
    robot.proximity = robot.proximity and sensor_helper.extend(robot.proximity, configuration.proximity_sensor_group)
    local extensions = {
        set_random_wheel_velocity = function(max_velocity) return set_random_wheel_velocity(robot, max_velocity) end,
        point_to = function(vector) return point_to(robot, vector) end,
        handle_collision = function(threshold, on_collision) return handle_collision(robot, threshold, on_collision) end
    }

    return setmetatable(robot, {
        __index = function(_, key)
            return extensions[key]
        end
    })
end

return robot_helper
