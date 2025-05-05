local sensor_helper = require "sensor_helper"

local RobotExtension = {}
RobotExtension.__index = RobotExtension

function RobotExtension:new(robot, max_velocity)
    setmetatable(robot, self)
    robot.proximity = robot.proximity and sensor_helper.extend(robot.proximity)
    robot.random_walk_behaviour = function() return robot:set_random_wheel_velocity() end
    robot.max_velocity = max_velocity
    return robot
end

function RobotExtension:set_random_wheel_velocity()
    local left_v = self.random.uniform(0, self.max_velocity)
    local right_v = self.random.uniform(0, self.max_velocity)
    self.wheels.set_velocity(left_v, right_v)
end

function RobotExtension:rotate_left(velocity)
    self.wheels.set_velocity(-velocity, velocity)
end

function RobotExtension:rotate_right(velocity)
    self:rotate_left(-velocity)
end

local robot_helper = {}

function robot_helper.handle_walk(movement_action, n_steps, move_steps)
    n_steps = n_steps + 1
    if n_steps % move_steps == 0 then
        n_steps = 0
        movement_action()		
    end
    return n_steps
end

function robot_helper.extend(robot, max_velocity)
    return RobotExtension:new(robot, max_velocity)
end

return robot_helper