MOVE_STEPS = 15
MAX_VELOCITY = 10
LIGHT_THRESHOLD = 1.5
local proximity_threshold = 0.0
local light_threshold = 0.0

local robot_helper = require "robot_helper"
local sensor_helper = require "sensor_helper"
local n_steps = 0
local light_found = false
local avoiding_obstacle_when_phototaxis = false
local reference_angle = (robot.proximity[6].angle + robot.proximity[7].angle) / 2
local max_light_percieved = 0.0
robot = robot_helper.extend(robot, {proximity_sensor_group = sensor_helper.default_two_sensor_group})

function init()
    n_steps = 0
    light_found = false
    avoiding_obstacle_when_phototaxis = false
	robot.set_random_wheel_velocity(MAX_VELOCITY)
    robot.wheels.set_velocity(10, 10)
	robot.leds.set_all_colors("black")
end

function phototaxis_movement()
    local max_value, max_index = robot.light.max_with_index({threshold = light_threshold})
    if max_index == nil then 
        robot.set_random_wheel_velocity(MAX_VELOCITY)
        light_found = false
    else
        max_light_percieved = math.max(max_light_percieved, max_value)
        local k = 0.5
        robot.point_to({length = MAX_VELOCITY, angle = robot.light[max_index].angle * k, max_velocity = MAX_VELOCITY})
        light_found = true
    end
end

function handle_walk(movement_action)
    log("Handling walk")
	n_steps = n_steps + 1
	if n_steps % MOVE_STEPS == 0 then
		n_steps = 0
		movement_action()		
	end
end

function handle_collision(threshold)
    log("Handling collision")
	local threshold = threshold or 0.0
	local max_left_proximity, max_left_proximity_index = robot.proximity.max_with_index({threshold = threshold, start_index = 1, end_index = 7})
	local max_right_proximity, max_right_proximity_index = robot.proximity.max_with_index({threshold = threshold, start_index = 18, end_index = 24})
	if (max_left_proximity > threshold) or (max_right_proximity > threshold) then
		robot.leds.set_all_colors("red")
        avoiding_obstacle_when_phototaxis = light_found
		if max_left_proximity > max_right_proximity then
			robot.wheels.set_velocity( MAX_VELOCITY / 2, - MAX_VELOCITY / 2)
		else
			robot.wheels.set_velocity(- MAX_VELOCITY / 2, MAX_VELOCITY / 2)
		end
	else
		robot.leds.set_all_colors("black")
	end
end

function handle_collision_when_phototaxis()
    log("Handling collision when phototaxis")
    local sensor_group = sensor_helper.default_two_sensor_group
    local max_proximity, max_proximity_index = robot.proximity.max_with_index({threshold = proximity_threshold, sensor_group = sensor_group})
    local sensed_angle = max_proximity_index and robot.proximity.angle_considering(sensor_group[max_proximity_index]) or -2 * reference_angle
    local angle_diff = reference_angle + sensed_angle
    log("Sensed angle: " .. sensed_angle .. " Angle diff: " .. angle_diff)
    local angle_k if max_proximity > 0.2 then angle_k = 10 else angle_k = 0.8 end
    local velocity_k = max_proximity_index and max_proximity > 0.2 and angle_diff > 0.1 and 0.0 or MAX_VELOCITY
    robot.point_to({length = velocity_k , angle = angle_diff * angle_k, max_velocity = MAX_VELOCITY})
    local max_value, max_index = robot.light.max_with_index({threshold = light_threshold})
    if max_index ~= nil and max_value > max_light_percieved then
        -- avoiding_obstacle_when_phototaxis = false
        log("Light found, stopping avoidance")
        return
    end

end    


function step()
    if not avoiding_obstacle_when_phototaxis then
        handle_walk(phototaxis_movement)
        handle_collision(proximity_threshold)
    else
        handle_collision_when_phototaxis()
    end
end

function reset()
   init()
end

function destroy()
    -- do nothing
end
