MOVE_STEPS = 15
MAX_VELOCITY = 10
LIGHT_THRESHOLD = 0.02
PROXIMITY_THRESHOLD = 0.02

local robot_helper = require "robot_helper"
local sensor_helper = require "sensor_helper"
local n_steps = 0
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

RandomWalk = Behavior:new(1)
function RandomWalk:senseAndDecice()
	self.active = true
	robot:set_random_wheel_velocity()
end

Phototaxis = Behavior:new(2)

function Phototaxis:senseAndDecice()
	self.active = false
	robot:handle_phototaxis(LIGHT_THRESHOLD, function() self.active = true end)		
end
	
CollisionAvoidance = Behavior:new(3)
function findObstacle()
    local maxVal = 0.02  -- Start with the first element's value
    local maxIdx = 0
    for i = 1, 7 do
        if robot.proximity[i].value > maxVal then
            maxVal = robot.proximity[i].value
            maxIdx = i
        end
    end
    for i = 18, 24 do
        if robot.proximity[i].value > maxVal then
            maxVal = robot.proximity[i].value
            maxIdx = i
        end
    end
    return maxVal, maxIdx
end
function CollisionAvoidance:senseAndDecice()
	self.active = false
	robot:handle_collision(PROXIMITY_THRESHOLD, function() self.active = true end)
end

Standing = Behavior:new(4)
function onSpot()
	for i=1,4 do
		if robot.motor_ground[i].value <= 0.1 then
			return true
		end
	end
	return false
end	
function Standing:senseAndDecice()
	if onSpot() then
		log("Standing")
		self.active = true
		robot.wheels.set_velocity(0, 0)
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

behaviors = { RandomWalk, Phototaxis, CollisionAvoidance, Standing}
controller = SubsumptionController:new(behaviors)

function init()
	n_steps = 0
	robot.leds.set_all_colors("black")
end

function step()
	n_steps = robot_helper.handle_walk(function() controller:decide_action() end, n_steps, MOVE_STEPS)
end

function reset()
	init()
end

function destroy()
    -- do nothing
end
