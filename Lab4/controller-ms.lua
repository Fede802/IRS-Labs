local vector = require "vector"
local robot_helper = require "robot_helper"
local sensor_helper = require "sensor_helper"

MOVE_STEPS = 15
MAX_VELOCITY = 15
LIGHT_THRESHOLD = 0.02
PROXIMITY_THRESHOLD = 0.4
STANDING_THRESHOLD = 0.1
UNDER_LIGHT_THRESHOLD = 1.5
ROTATION_VELOCITY = 5

n_steps = 0
robot = robot_helper.extend(robot, MAX_VELOCITY, ROTATION_VELOCITY)

function init()
	n_steps = 0
	robot.leds.set_all_colors("black")
end

function proximity_vector_field()
    local _, max_proximity_sensor_index = robot.proximity:max_with_index({threshold = PROXIMITY_THRESHOLD})
    if max_proximity_sensor_index then
        local obstacle_angle = robot.proximity[max_proximity_sensor_index].angle
        local opposite_obstacle_angle = (obstacle_angle + 2*math.pi) % (2*math.pi) - math.pi
        return {length = MAX_VELOCITY * (1 - robot.proximity[max_proximity_sensor_index].value), angle = opposite_obstacle_angle }
    end
    return vector.null_vector
end

function light_vector_field()
    local max_light, max_light_index = robot:light_perception(LIGHT_THRESHOLD)
    if max_light_index then
        local light_angle = robot.light[max_light_index].angle
        return {length = MAX_VELOCITY * (1 - max_light), angle = light_angle}
    end
    return vector.null_vector
end

current_random_walk_field = vector.null_vector
function random_vector_field()
    return {length = MAX_VELOCITY, angle = robot.random.uniform(0, 2 * math.pi) - math.pi} 
end

function random_walk_vector_field()
    n_steps = robot_helper.handle_walk(function() current_random_walk_field = random_vector_field() end, n_steps, MOVE_STEPS)
    random_walk_condition = robot:random_walk_condition({light = LIGHT_THRESHOLD, proximity = PROXIMITY_THRESHOLD, standing = STANDING_THRESHOLD})
    return random_walk_condition and current_random_walk_field or vector.null_vector
end

function standing_vector_field()
    return robot:standing_condition(STANDING_THRESHOLD) and vector.null_vector or vector.unit_vector
end
    
function update_lights()
	if robot.light:sum() > UNDER_LIGHT_THRESHOLD then
		robot.leds.set_all_colors("green")
	else
		robot.leds.set_all_colors("black")	
	end
end

function step() 
    local motion_field = vector.vec2_polar_sum(proximity_vector_field(), light_vector_field(), random_walk_vector_field())
    local inibition_field = standing_vector_field()
    robot:point_to(vector.vec2_polar_dot_product(inibition_field.length, motion_field))  
	update_lights()
end

function reset()
	init()
end

function destroy()
   -- do nothing
end
