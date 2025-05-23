local robot_helper = require "robot_helper"
local sensor_helper = require "sensor_helper"

MAX_VELOCITY = 15
robot = robot_helper.extend(robot, MAX_VELOCITY)
local n_steps = 0
local line_found = false
MOVE_STEPS = 15
GROUND_PERCEPTION_THRESHOLD = 0.5

function init()
    line_found = false
    n_steps = 0
    robot.wheels.set_velocity(MAX_VELOCITY, MAX_VELOCITY)
end

function move_on_the_line()
    local velocity, rotation_angle = compute_velocity_and_rotation_angle()
    robot:point_to({length = velocity, angle = rotation_angle})
end    

function compute_velocity_and_rotation_angle()
    local sensor_group = {{1}, {2}, {3}, {4}}
    local min_ground_value, min_ground_value_index = robot.motor_ground:min_with_index({threshold = GROUND_PERCEPTION_THRESHOLD, sensor_group = sensor_group})
    local total_ground_value = robot.motor_ground:sum()
    local rotation_angle = 0.0
    local velocity = MAX_VELOCITY

    if total_ground_value > 1 then
        if min_ground_value_index == 1 or min_ground_value_index == 2 then
            rotation_angle = 0.3
        elseif min_ground_value_index == 3 or min_ground_value_index == 4 then
            rotation_angle = -0.3
        end
        velocity = MAX_VELOCITY * 0.5
    end
    
    return velocity, rotation_angle
end    

function look_for_line() 
    local total_value = robot.motor_ground:sum() 
    n_steps = robot_helper.handle_walk(robot.random_walk_behaviour, n_steps, MOVE_STEPS) 
    if total_value < 0.6 then line_found = true robot.wheels.set_velocity(0, 0) end 
end

function step()
    if line_found then 
        move_on_the_line() 
    else 
        look_for_line() 
    end
end

function reset()
    init()
end

function destroy()
    -- Do nothing
end
