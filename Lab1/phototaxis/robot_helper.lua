return function(global_config)
    local sensor_helper = require "sensor_helper"

    local robot_helper = {}

    function robot_helper.extend(robot)
        robot.light = robot.light and sensor_helper.extend(robot.light)
        robot.proximity = robot.proximity and sensor_helper.extend(robot.proximity)
        local extensions = {
            set_random_wheel_velocity = function() return set_random_wheel_velocity(robot) end
        }
    
        return setmetatable(robot, {
            __index = function(_, key)
                return extensions[key]
            end
        })
    end

    function set_random_wheel_velocity(robot)
        local left_v = robot.random.uniform(0, global_config.MAX_VELOCITY)
        local right_v = robot.random.uniform(0, global_config.MAX_VELOCITY)
        robot.wheels.set_velocity(left_v, right_v)
    end

    return robot_helper
end
