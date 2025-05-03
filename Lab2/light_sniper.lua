MOVE_STEPS = 15
MAX_VELOCITY = 10
LIGHT_THRESHOLD = 1.5
local proximity_threshold = 0.0
local light_threshold = 0.0

local robot_helper = require "robot_helper"
local sensor_helper = require "sensor_helper"
local n_steps = 0
robot = robot_helper.extend(robot)

function init()
    n_steps = 0
    find_obstacle = false
    turn_count = 0
    should_turn = false
	robot.set_random_wheel_velocity(MAX_VELOCITY)
    robot.wheels.set_velocity(10, 10)
	robot.leds.set_all_colors("black")
end

-- function findMaxValue(arr)
--     local maxVal = arr[1].value -- Start with the first element's value
--     local maxIdx = 0
--     for i = 2, #arr do
--         if arr[i].value > maxVal then
--             maxVal = arr[i].value
--             maxIdx = i
--         end
--     end

--     return maxVal, maxIdx
-- end
-- function findMaxValue2(arr)
--     local maxVal = 0 -- Start with the first element's value
--     local maxIdx = 0
--     for i = 1, 7 do
--         if arr[i].value > maxVal then
--             maxVal = arr[i].value
--             maxIdx = i
--         end
--     end
--     for i = 18, 24 do
--         if arr[i].value > maxVal then
--             maxVal = arr[i].value
--             maxIdx = i
--         end
--     end

--     return maxVal, maxIdx
-- end

-- function isObstacleInFront(arr)
--     proximity_threshold = 0
--     if arr[1].value > proximity_threshold or arr[2].value > proximity_threshold or arr[23].value > proximity_threshold or arr[24].value >
--         proximity_threshold then return true end
--     return false
-- end
-- function isObstacleOnTheRight(arr)
--     proximity_threshold = 0
--     free = false
--     for i = 17, 20 do
--         log(arr[i].value)
--         if arr[i].value > proximity_threshold then free = true end
--     end
--     return free
-- end
-- function turnLeft() robot.wheels.set_velocity(-110, 110) end
-- function turnRight() robot.wheels.set_velocity(110, -110) end

-- new things
function phototaxis_movement()
    local max_value, max_index = robot.light.max_with_index(light_threshold)
    if max_index == nil then 
        robot.set_random_wheel_velocity(MAX_VELOCITY)
        light_found = false
    else
        local k = 0.5
        robot.point_to({length = MAX_VELOCITY, angle = robot.light[max_index].angle * k})
        light_found = true
    end
end

function handle_walk(movement_action)
	n_steps = n_steps + 1
	if n_steps % MOVE_STEPS == 0 then
		n_steps = 0
		movement_action()		
	end
end

function handle_collision(threshold)
	local threshold = threshold or 0.0
	local max_left_proximity, max_left_proximity_index = robot.proximity.max_with_index(threshold, 1, 7)
	local max_right_proximity, max_right_proximity_index = robot.proximity.max_with_index(threshold, 18, 24)
	if (max_left_proximity > threshold) or (max_right_proximity > threshold) then
		robot.leds.set_all_colors("red")
        avoiding_obstacle_when_phototaxis = light_found
		if max_left_proximity > max_right_proximity then
			robot.wheels.set_velocity(MAX_VELOCITY / 2, - MAX_VELOCITY / 2)
		else
			robot.wheels.set_velocity(MAX_VELOCITY / 2, - MAX_VELOCITY / 2)
		end
	else
		robot.leds.set_all_colors("black")
	end
end

function is_obstacle_in_front()
    local _, max_index = robot.proximity.max_with_index_in(proximity_threshold, {1, 24})
    return max_index ~= nil
end

function handle_collision_when_phototaxis()
    local max_proximity, max_proximity_index = robot.proximity.max_with_index(proximity_threshold)
    local max_light, max_light_index = robot.light.max_with_index(light_threshold)
    max_light_index = max_light_index or 0
    if max_proximity_index == nil or sensor_helper.is_left_sensor(max_light_index) and sensor_helper.is_right_sensor(max_proximity_index) then
        avoiding_obstacle_when_phototaxis = false
        return
    end
    right_angle = (robot.proximity[18].angle + robot.proximity[19].angle) / 2
    robot.point_to({length = MAX_VELOCITY, angle = right_angle - robot.proximity[max_proximity_index].angle})
end    



--     robot.wheels.set_velocity(MAX_VELOCITY / 2, -MAX_VELOCITY / 2)
--     local max_right_proximity, max_right_proximity_index = robot.proximity.max_with_index(proximity_threshold)
--     if robot.light.has_left_perception(light_threshold) and robot.light.has_right_perception(light_threshold) then
        
--     local is_obstacle_in_front = is_obstacle_in_front()
-- end

local light_found = false
local avoiding_obstacle_when_phototaxis = false
function step()
    for i = 1, #robot.proximity do
        print(i .. " " .. robot.proximity[i].angle)
    end
    local max_proximity, max_proximity_index = robot.proximity.max_with_index(proximity_threshold)
    if light_found then
        local reference_angle = robot.proximity[8].angle
        local sensed_angle = max_proximity_index and robot.proximity[max_proximity_index].angle or -2 * reference_angle
        local angle_diff = reference_angle + sensed_angle
        robot.point_to({length = 5, angle = angle_diff })
        -- robot.set_random_wheel_velocity(MAX_VELOCITY)
    else
        light_found = max_proximity_index ~= nil
    end

    -- -- print("max_proximity_index = " .. max_proximity_index)
    -- print("max_proximity = " .. max_proximity)
    -- print("reference_angle = " .. reference_angle)
    -- -- print("robot.proximity[max_proximity_index].angle = " .. robot.proximity[max_proximity_index].angle)
    -- if max_proximity_index ~= nil and max_proximity > 0.5 then 
    --     print("max_index = " .. max_proximity_index)
    --     print("robot.proximity[max_proximity_index].angle = " .. angle_diff)
    --     speed = angle_diff < 0.01 and MAX_VELOCITY or 5
    -- end
    -- local max_light_value, max_light_index = robot.light.max_with_index(light_threshold)
    -- if not avoiding_obstacle_when_phototaxis then
    --     handle_walk(phototaxis_movement)
    --     handle_collision(proximity_threshold)
    -- else
    --     handle_collision_when_phototaxis()
    -- end

    -- --[[	n_steps = n_steps + 1 ]]
    -- max_valuel, max_idxl = findMaxValue(robot.light)
    -- --[[ log("robot.max_light = " .. max_valuel)	
	-- log("turn_count = " .. turn_count) ]]
    -- if max_idxl > 0 then
    --     aa = robot.proximity[max_idxl].value
    --     log("prox = " .. aa)
    -- end
    -- max_valuep, max_idxp = findMaxValue2(robot.proximity)
    -- if isObstacleInFront(robot.proximity) then
    --     if not find_obstacle then
    --         find_obstacle = true
    --         turn_count = turn_count + 1
    --     end
    --     turn_count = turn_count + 1
    --     turnLeft()

    -- elseif turn_count < 2 and max_idxl > 0 and robot.proximity[max_idxl].value <=
    --     0.1 then
    --     turn_count = 0
    --     find_obstacle = false
    --     log("obs")
    --     angle = robot.light[max_idxl].angle
    --     wheeldistance = robot.wheels.axis_length
    --     local k = 0.5
    --     w = k * angle
    --     local v = 10
    --     left_v = v - (w * wheeldistance / 2)
    --     right_v = v + (w * wheeldistance / 2)
    --     robot.wheels.set_velocity(left_v, right_v)
    -- elseif find_obstacle then
    --     if isObstacleOnTheRight(robot.proximity) then
    --         robot.wheels.set_velocity(20, 20)
    --         should_turn = true
    --     elseif not isObstacleOnTheRight(robot.proximity) then
    --         if should_turn then
    --             if n_steps > 3 then
    --                 n_steps = 0
    --                 turn_count = turn_count - 1
    --                 if turn_count == 0 then
    --                     find_obstacle = false
    --                 end
    --                 turnRight()
    --                 should_turn = false
    --             else
    --                 n_steps = n_steps + 1
    --                 robot.wheels.set_velocity(20, 20)
    --             end
    --         else
    --             robot.wheels.set_velocity(20, 20)
    --         end
    --     end
    -- else
    --     left_v = robot.random.uniform(0, MAX_VELOCITY)
    --     right_v = robot.random.uniform(0, MAX_VELOCITY)
    --     robot.wheels.set_velocity(left_v, right_v)
    -- end

end



function reset()
   init()
end

function destroy()
    -- do nothing
end
