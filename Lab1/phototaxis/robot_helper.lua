
return function(global_config)
    local sensor_helper = require "sensor_helper"
    robot_helper = {}
    function robot_helper.extend(robot)
        print("robot_helper.extend")
        robot.light = sensor_helper.extend(robot.light)
        robot.proximity = sensor_helper.extend(robot.proximity)

        return setmetatable(robot, {
            __index = function(_, key)
                if key == "set_random_wheel_velocity" then
                    return set_random_wheel_velocity(robot)
                end
            end
        })
    end

    function set_random_wheel_velocity(robot)
        left_v = robot.random.uniform(0, global_config.MAX_VELOCITY)
        right_v = robot.random.uniform(0, global_config.MAX_VELOCITY)
        robot.wheels.set_velocity(left_v, right_v)
    end

    return robot_helper
end