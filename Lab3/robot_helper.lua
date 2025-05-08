local sensor_helper = require "sensor_helper"

local RobotExtension = {}
RobotExtension.__index = RobotExtension

function RobotExtension:new(robot, max_velocity)
    setmetatable(robot, self)
    robot.light = robot.light and sensor_helper.extend(robot.light)
    robot.proximity = robot.proximity and sensor_helper.extend(robot.proximity)
    robot.motor_ground = robot.motor_ground and sensor_helper.extend(robot.motor_ground)
    robot.random_walk_behaviour = function() return robot:set_random_wheel_velocity() end
    robot.max_velocity = max_velocity
    return robot
end

function RobotExtension:random_walk_condition(thesholds)
    local phototaxis_condition = self.light and self:phototaxis_condition(thesholds.light) or nil
    local proximity_condition = self.proximity and self:proximity_condition(thesholds.proximity) or nil
    local standing_condition = self.motor_ground and self:standing_condition(thesholds.standing) or nil
    return not phototaxis_condition and not proximity_condition and not standing_condition
end

function RobotExtension:set_random_wheel_velocity()
    local left_v = self.random.uniform(0, self.max_velocity)
    local right_v = self.random.uniform(0, self.max_velocity)
    self.wheels.set_velocity(left_v, right_v)
end

function RobotExtension:point_to(vector)
    local wheeldistance = self.wheels.axis_length
    local w = vector.angle
    local v = vector.length
    
    local left_v = v - (w * wheeldistance / 2)
    local right_v = v + (w * wheeldistance / 2)
    
    local max_v = math.max(math.abs(left_v), math.abs(right_v))
    
    if max_v > self.max_velocity then
        local scale = self.max_velocity / max_v
        left_v = left_v * scale
        right_v = right_v * scale
    end
    self.wheels.set_velocity(left_v, right_v)
end

function RobotExtension:light_perception(threshold)
    return self.light:max_with_index({threshold = threshold})
end

function RobotExtension:phototaxis_condition(threshold)
    local max_value, max_index = self:light_perception(threshold)
    return max_index ~= nil
end

function RobotExtension:handle_phototaxis(threshold, on_phototaxis)
    local max_value, max_index = self:light_perception(threshold)
    local light_found = max_index ~= nil
    if light_found then 
        if on_phototaxis then on_phototaxis() end
        local k = 0.5
        self:point_to({length = self.max_velocity, angle = self.light[max_index].angle * k})
    else
        self:set_random_wheel_velocity()
    end
end

function RobotExtension:proximity_perception(threshold)
    local max_left_proximity, max_left_proximity_index = self.proximity:max_with_index({threshold = threshold, start_index = 1, end_index = 6})
    local max_right_proximity, max_right_proximity_index = self.proximity:max_with_index({threshold = threshold, start_index = 19, end_index = 24})
    return max_left_proximity, max_left_proximity_index, max_right_proximity, max_right_proximity_index
end

function RobotExtension:proximity_condition(threshold)
    local _, max_left_proximity_index, _, max_right_proximity_index = self:proximity_perception(threshold)
    return max_left_proximity_index ~= nil or max_right_proximity_index ~= nil
end

function RobotExtension:rotate_left(velocity)
    self.wheels.set_velocity(-velocity, velocity)
end

function RobotExtension:rotate_right(velocity)
    self:rotate_left(-velocity)
end

function RobotExtension:avoid_collision(max_left_proximity, max_right_proximity)
    self:rotate_leftq(self.max_velocity / 2)
end

function RobotExtension:handle_collision(threshold, on_collision)
    local threshold = threshold or 0.0
    local max_left_proximity, _, max_right_proximity, _ = self:proximity_perception(threshold)
    local collision_detected = max_left_proximity > threshold or max_right_proximity > threshold
    if collision_detected then
        if on_collision then on_collision() end
        self:avoid_collision(max_left_proximity, max_right_proximity)
        self.leds.set_all_colors("red")
    else
        self.leds.set_all_colors("black")  
    end
end

function RobotExtension:standing_condition(threshold)
    local _, min_index = self.motor_ground:min_with_index({threshold = threshold})
    return min_index ~= nil
end

function RobotExtension:stop()
    self.wheels.set_velocity(0, 0)
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
