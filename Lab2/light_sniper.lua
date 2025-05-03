MOVE_STEPS = 15
MAX_VELOCITY = 10
LIGHT_THRESHOLD = 1.5
local proximity_threshold = 0.0
local light_threshold = 0.0

local robot_helper = require "robot_helper"
local sensor_helper = require "sensor_helper"
local n_steps = 0
robot = robot_helper.extend(robot, {proximity_sensor_group = sensor_helper.default_two_sensor_group})

function init()
    n_steps = 0
    find_obstacle = false
    turn_count = 0
    should_turn = false
	robot.set_random_wheel_velocity(MAX_VELOCITY)
    robot.wheels.set_velocity(10, 10)
	robot.leds.set_all_colors("black")
end

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

local light_found = false
local avoiding_obstacle_when_phototaxis = false
local reference_angle = (robot.proximity[6].angle + robot.proximity[7].angle) / 2
function step()
    for i = 1, #robot.proximity do
        print(i .. " " .. robot.proximity[i].angle)
    end
    local max_proximity, max_proximity_index = robot.proximity.max_with_index(proximity_threshold)
    if light_found then
        local sensed_angle = max_proximity_index and robot.proximity.angle_for(max_proximity_index) or -2 * reference_angle
        sensors = max_proximity_index and sensor_helper.default_two_sensor_group[max_proximity_index] or {0,0}
        local angle_diff = reference_angle + sensed_angle
        local angle_k if max_proximity > 0.2 then angle_k = 10 else angle_k = 1 end
        log("angle_diff = " .. angle_diff)
        local velocity_k = max_proximity_index and max_proximity > 0.2 and angle_diff > 0.1 and 0.0 or MAX_VELOCITY
        -- log(sensor_helper.default_two_sensor_group[max_proximity_index][1])
        -- log(sensor_helper.default_two_sensor_group[max_proximity_index][2])
        -- log("reference_angle = " .. reference_angle .. " sensed_angle = " .. sensed_angle .. " angle_diff = " .. angle_diff) -- .. "sensors = " .. sensor_helper.default_two_sensor_group[max_proximity_index])
        robot.point_to({length = velocity_k , angle = angle_diff * angle_k})
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
end



function reset()
   init()
end

function destroy()
    -- do nothing
end
