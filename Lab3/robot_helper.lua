local sensor_helper = require "sensor_helper"
local RobotExtension = {}
RobotExtension.__index = RobotExtension

local function RobotExtension:new(robot, max_velocity)
    local instance = setmetatable(robot, self)
    instance.light = robot.light and sensor_helper.extend(robot.light)
    instance.proximity = robot.proximity and sensor_helper.extend(robot.proximity)
    instance.max_velocity = max_velocity
    return instance
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

local function RobotExtension:proximity_perception(threshold)
    local max_left_proximity, _ = self.proximity.max_with_index({threshold = threshold, start_index = 1, end_index = 6})
    local max_right_proximity, _ = self.proximity.max_with_index({threshold = threshold, start_index = 19, end_index = 24})
    return max_left_proximity, max_right_proximity
end

local function RobotExtension:rotate_left(velocity)
    self.wheels.set_velocity(-velocity, velocity)
end

local function RobotExtension:rotate_right(velocity)
    self:rotate_left(-velocity)
end

local function RobotExtension:avoid_collision(max_left_proximity, max_right_proximity)
    local obstacle_on_the_left = max_left_proximity > max_right_proximity
    if obstacle_on_the_left then self:rotate_right(self.max_velocity / 2) else self:rotate_left(self.max_velocity / 2) end
end

function RobotExtension:handle_collision(threshold, on_collision)
    local threshold = threshold or 0.0
    local max_left_proximity, max_right_proximity = self:proximity_perception(threshold)
    local collision_detected = max_left_proximity > threshold or max_right_proximity > threshold
    if collision_detected then
        if on_collision then on_collision() end
        self:avoid_collision(max_left_proximity, max_right_proximity)
        self.leds.set_all_colors("red")
    else
        self.leds.set_all_colors("black")  
    end
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
