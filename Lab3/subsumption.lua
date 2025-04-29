-- Put your global variables here

MOVE_STEPS = 15
MAX_VELOCITY = 10
LIGHT_THRESHOLD = 0.02
n_steps = 0

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
	log("RandomWalk")
	self.active = true
	left_v = robot.random.uniform(0,MAX_VELOCITY)
	right_v = robot.random.uniform(0,MAX_VELOCITY)
	robot.wheels.set_velocity(left_v,right_v)
end

Phototaxis = Behavior:new(2)
function findLight()
    local maxVal = LIGHT_THRESHOLD  -- Start with the first element's value
    local maxIdx = 0
    for i = 1, #robot.light do
        if robot.light[i].value > maxVal then
            maxVal = robot.light[i].value
            maxIdx = i
        end
    end
    return maxVal, maxIdx
end
function Phototaxis:senseAndDecice()
max_value, max_idx = findLight()
	if max_idx > 0 then
		log("Phototaxis")
		angle = robot.light[max_idx].angle
		wheel_distance = robot.wheels.axis_length
		local k = 0.5
		w = k * angle
		local v = 10 
		left_v = v - (w * wheel_distance / 2)
		right_v = v + (w * wheel_distance / 2)
		self.active = true
		robot.wheels.set_velocity(left_v, right_v)
	else
		self.active = false
	end					
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
max_value, max_idx = findObstacle()
	if max_idx > 0 then
		log("CollisionAvoidance")
		angle = 0.5
		wheeldistance = robot.wheels.axis_length
		local k = 0.5
    	w = k * angle
		local v = 0 
		left_v = v - (w * wheeldistance / 2)
		right_v = v + (w * wheeldistance / 2)
		self.active = true
		robot.wheels.set_velocity(left_v, right_v)
	else
		self.active = false
	end				
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


--[[ This function is executed every time you press the 'execute'
     button ]]
function init()
	left_v = robot.random.uniform(0,MAX_VELOCITY)
	right_v = robot.random.uniform(0,MAX_VELOCITY)
	robot.wheels.set_velocity(left_v,right_v)
	behaviors = { RandomWalk, Phototaxis, CollisionAvoidance, Standing}
	controller = SubsumptionController:new(behaviors)
	n_steps = 0
	robot.leds.set_all_colors("black")
end

function step()
	n_steps = n_steps + 1
	if n_steps % MOVE_STEPS == 0 then
		n_steps = 0
		controller:decide_action()
	end	
end




--[[ This function is executed every time you press the 'reset'
     button in the GUI. It is supposed to restore the state
     of the controller to whatever it was right after init() was
     called. The state of sensors and actuators is reset
     automatically by ARGoS. ]]
function reset()
	left_v = robot.random.uniform(0,MAX_VELOCITY)
	right_v = robot.random.uniform(0,MAX_VELOCITY)
	robot.wheels.set_velocity(left_v,right_v)
	n_steps = 0
	robot.leds.set_all_colors("black")
end



--[[ This function is executed only once, when the robot is removed
     from the simulation ]]
function destroy()
   -- put your code here
end
