MAX_VELOCITY = 15

local robot_helper = require "robot_helper"
local sensor_helper = require "sensor_helper"
robot = robot_helper.extend(robot, MAX_VELOCITY)

Behavior = {}
Behavior.__index = Behavior

function Behavior:new(priority)
    local obj = { active = false, priority = priority }
    setmetatable(obj, self)
    return obj
end

function Behavior:senseAndDecice()
    -- To be implemented by subclasses
end

function Behavior:act()
    return self.active
end

function Behavior:reset()
	self.active = false
end

RandomWalk = Behavior:new(1)
function RandomWalk:senseAndDecice()
	self.active = true
	robot:set_random_wheel_velocity()
end

Phototaxis = Behavior:new(2)
Phototaxis.n_steps = 0
Phototaxis.MOVE_STEPS = 15
Phototaxis.LIGHT_THRESHOLD = 0.02
function Phototaxis:senseAndDecice()
	self.n_steps = robot_helper.handle_walk(function() 
		self.active = false
		robot:handle_phototaxis(self.LIGHT_THRESHOLD, function() self.active = true end) 
	end, self.n_steps, self.MOVE_STEPS)
end
function Phototaxis:reset()
	Behavior.reset(self)
	self.n_steps = 0
end
-- BUG: Double direction rotation can cause deadlock between two robots
CollisionAvoidance = Behavior:new(3)
CollisionAvoidance.PROXIMITY_THRESHOLD = 0.6
function CollisionAvoidance:senseAndDecice()
	self.active = false
	robot:handle_collision(self.PROXIMITY_THRESHOLD, function() self.active = true end)
end

Standing = Behavior:new(4)
Standing.STANDING_THRESHOLD = 0.1
function Standing:onSpot()
	_, min_index = robot.motor_ground:min_with_index({threshold = self.STANDING_THRESHOLD})
	return min_index ~= nil
end	

function Standing:senseAndDecice()
	if self:onSpot() then
		self.active = true
		robot:stop()
	else
		self.active = false
	end				
end


SubsumptionController = {}
SubsumptionController.__index = SubsumptionController

function SubsumptionController:new(behaviors)
    local obj = { behaviors = behaviors }
    table.sort(obj.behaviors, function(a, b) return a.priority > b.priority end) -- Sort by priority
    setmetatable(obj, self)
    return obj
end

function SubsumptionController:decide_action()
    for _, behavior in ipairs(self.behaviors) do
        behavior:senseAndDecice()
        if behavior.active then
        	behavior:act()
            return 
        end
    end
    return nil
end

function SubsumptionController:reset()
	for _, behavior in ipairs(self.behaviors) do
		behavior:reset()
	end
end

behaviors = { RandomWalk, Phototaxis, CollisionAvoidance, Standing}
controller = SubsumptionController:new(behaviors)

function init()
	controller:reset()
	robot.leds.set_all_colors("black")
end

function step()
	controller:decide_action()
end

function reset()
	init()
end

function destroy()
    -- do nothing
end
