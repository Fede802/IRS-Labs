MOVE_STEPS = 15
MAX_VELOCITY = 10
LIGHT_THRESHOLD = 1.5
PHOTOTAXIS_ROTATION_STRENGTH = 0.5


local proximity_threshold = 0.0
local light_threshold = 0.0

local robot_helper = require "robot_helper"
local sensor_helper = require "sensor_helper"
local n_steps = 0
local light_found = false
local avoiding_obstacle_when_phototaxis = false
local reference_angle = (robot.proximity[6].angle + robot.proximity[7].angle) / 2
local max_light_percieved = 0.0
robot = robot_helper.extend(robot, {proximity_sensor_group = sensor_helper.default_two_sensor_group})

function init()
    n_steps = 0
    light_found = false
    avoiding_obstacle_when_phototaxis = false
    max_light_percieved = 0.0
	robot.set_random_wheel_velocity(MAX_VELOCITY)
    robot.wheels.set_velocity(MAX_VELOCITY, MAX_VELOCITY)
	robot.leds.set_all_colors("black")
end

function phototaxis_movement()
    local max_value, max_index = robot.light:max_with_index({threshold = light_threshold})
    if max_index == nil then 
        robot.set_random_wheel_velocity(MAX_VELOCITY)
        light_found = false
        -- robot.leds.set_all_colors("black")
    else
        max_light_percieved = math.max(max_light_percieved, max_value)
        local k = 0.5
        robot.point_to({length = MAX_VELOCITY, angle = robot.light[max_index].angle * PHOTOTAXIS_ROTATION_STRENGTH, max_velocity = MAX_VELOCITY})
        light_found = true
        -- robot.leds.set_all_colors("green")
    end
end

function handle_collision_when_phototaxis(configuration)
    local velocity, rotation_angle = compute_velocity_and_rotation_angle(configuration)
    robot.point_to({length = velocity , angle = rotation_angle, max_velocity = MAX_VELOCITY})
    if is_obstacle_avoided() then avoiding_obstacle_when_phototaxis = false end
end    

function compute_velocity_and_rotation_angle(configuration)
    local max_proximity, max_proximity_index, sensed_angle = get_proximity_perception()
    local rotation_angle = reference_angle + sensed_angle
    local velocity = MAX_VELOCITY
    configuration.max_proximity = max_proximity
    configuration.max_proximity_index = max_proximity_index
    return adjust_velocity_and_rotation_angle(velocity, rotation_angle, configuration)
end

function get_proximity_perception()
    local sensor_group = robot.proximity.default_two_sensor_group
    local max_proximity, max_proximity_index = robot.proximity:max_with_index({threshold = proximity_threshold, sensor_group = sensor_group})
    if max_proximity_index then
    log("sensor_group", sensor_group[max_proximity_index], #sensor_group)
        for i = 1, #sensor_group[max_proximity_index] do
        log("sensor_group[" .. i .. "]", sensor_group[max_proximity_index][i], sensor_group[max_proximity_index][i])
        -- for j = 1, #sensor_group[i] do
        --     local index = sensor_group[i][j]
        --     log("robot.proximity[" .. index .. "]", robot.proximity[index].value)
        -- end
        end
    end
    local sensed_angle = max_proximity_index and robot.proximity:estimate_angle_of(sensor_group[max_proximity_index]) or -2 * reference_angle
    return max_proximity, max_proximity_index, sensed_angle
end

function adjust_velocity_and_rotation_angle(velocity, rotation_angle, configuration)
    local velocity, rotation_angle, _ = amplify_rotation_signal(adjust_rotation_based_on_proximity(adjust_velocity_based_on_proximity(velocity, rotation_angle, configuration)))
    return velocity, rotation_angle
end

function adjust_velocity_based_on_proximity(velocity, rotation_angle, configuration)
    if configuration.max_proximity_index and 
        configuration.max_proximity > configuration.proximity_threshold_before_stop_and_only_rotate and 
        rotation_angle > configuration.rotation_angle_threshold_for_considering_robot_aligned_with_obstacle 
    then velocity = 0.0 end
    return velocity, rotation_angle, configuration
end

function adjust_rotation_based_on_proximity(velocity, rotation_angle, configuration)    
    if configuration.max_proximity_index and 
        configuration.max_proximity > configuration.proximity_threshold_to_adjust_robot_direction 
    then rotation_angle = math.abs(sensor_helper.scale_up(rotation_angle, configuration.order_of_magniture_to_achieve_when_scaling_for_adjust_robot_direction)) end
    return velocity, rotation_angle, configuration
end

function amplify_rotation_signal(velocity, rotation_angle, configuration)
    if math.abs(rotation_angle) < configuration.order_of_magniture_to_achieve_when_scaling_for_adjust_robot_direction then 
        rotation_angle = sensor_helper.scale_up(rotation_angle, configuration.order_of_magniture_to_achieve_when_scaling_for_adjust_robot_direction)
    end
    return velocity, rotation_angle, configuration
end

function is_obstacle_avoided()
    local max_value, max_index = robot.light:max_with_index({threshold = light_threshold})
    return max_index ~= nil and max_value > max_light_percieved
end    

function step()
    if not avoiding_obstacle_when_phototaxis then
        -- robot.leds.set_all_colors("black")
        n_steps = robot_helper.handle_walk(phototaxis_movement, n_steps)
        robot.handle_collision(proximity_threshold, function() avoiding_obstacle_when_phototaxis = light_found end)
    else
        -- robot.leds.set_all_colors("yellow")
        handle_collision_when_phototaxis({
            proximity_threshold_before_stop_and_only_rotate = 0.3,
            rotation_angle_threshold_for_considering_robot_aligned_with_obstacle = 0.1,
            proximity_threshold_to_adjust_robot_direction = 0.7,
            order_of_magniture_to_achieve_when_scaling_for_adjust_robot_direction = 0.01
        })
    end
end

function reset()
   init()
end

function destroy()
    -- do nothing
end
