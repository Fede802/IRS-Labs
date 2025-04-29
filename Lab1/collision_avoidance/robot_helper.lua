local sensor_helper = require "sensor_helper"
local robot_helper = {}

function robot_helper.extend(robot)
    robot.light = robot.light and sensor_helper.extend(robot.light)
    robot.proximity = robot.proximity and sensor_helper.extend(robot.proximity)
    local extensions = {
        set_random_wheel_velocity = function(max_velocity) return set_random_wheel_velocity(robot, max_velocity) end,
        point_to = function(vector) return point_to(robot, vector) end
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

return robot_helper
