---@diagnostic disable: undefined-global

MAX_RANGE = 30
MAX_VELOCITY = 15
MOVE_STEPS = 60
n_steps = 0

Ps0 = 0.01
Ps_MAX = 0.99
Alpha = 0.1
Ps = 0.0
Ds = 0.0

Pw0 = 0.1
Pw_MIN = 0.005
Beta = 0.05
Pw = 0.0
Dw = 0.0

Moving = false

function init()
	n_steps = 0
	robot.leds.set_all_colors("black")
end

function update_ps(n)    
    Ps = math.min(Ps_MAX, Ps0 + Alpha * n + Ds)
end

function update_pw(n)
    Pw = math.max(Pw_MIN, Pw0 - Beta * n + Dw)
end

function set_random_movement()
    local left_v = robot.random.uniform(0,MAX_VELOCITY)
    local right_v = robot.random.uniform(0,MAX_VELOCITY)
    robot.wheels.set_velocity(left_v,right_v)
end
function sensor_max_intensity(sensor, lb, ub)
    local max_intensity = 0
    for i = lb, ub do 
        if sensor[i].value > max_intensity then
            max_intensity = sensor[i].value
        end
    end
    return max_intensity
end

function handle_walk()
    n_steps = n_steps + 1
    if n_steps > MOVE_STEPS then
        set_random_movement()
        n_steps = 0
    elseif n_steps > MOVE_STEPS/2 then
        robot.wheels.set_velocity(MAX_VELOCITY, MAX_VELOCITY)
    end
end

function handle_collision()
    local max_left_proximity = sensor_max_intensity(robot.proximity, 1, 7)
    local max_right_proximity = sensor_max_intensity(robot.proximity, 18, 24)
    if (max_left_proximity > 0.1) or (max_right_proximity > 0.1) then
        if max_left_proximity > max_right_proximity then
            robot.wheels.set_velocity(MAX_VELOCITY / 2, - MAX_VELOCITY / 2)
        else
            robot.wheels.set_velocity(- MAX_VELOCITY / 2,  MAX_VELOCITY / 2)
        end
    end
end

function countRAB_standing_robots()
    local number_robot_sensed = 0
    for i = 1, #robot.range_and_bearing do
        if robot.range_and_bearing[i].range < MAX_RANGE and 
        robot.range_and_bearing[i].data[1] == 1 then
            number_robot_sensed = number_robot_sensed + 1
        end
    end
    return number_robot_sensed
end

function do_when_moving()
    robot.leds.set_all_colors("green")
    if Ps < robot.random.uniform() then
        handle_walk()
        handle_collision()
    else
        Moving = false
    end
end

function do_when_standing()
    robot.leds.set_all_colors("red")
    if Pw >= robot.random.uniform() then
        Moving = true
    else
        robot.wheels.set_velocity(0, 0)
    end
end

function on_spot()
	for i=1,4 do
		if robot.motor_ground[i].value <= 0.1 then
			return true
		end
	end
	return false
end	

function step()
    if on_spot() then
        Ds = 0.5
        Dw = 0.05
    else
        Ds = 0.0
        Dw = 0.0
    end    
    if Moving then
        robot.range_and_bearing.set_data(1,0)
        update_ps(countRAB_standing_robots())
        do_when_moving()
    else
        robot.range_and_bearing.set_data(1,1)
        update_pw(countRAB_standing_robots())
        do_when_standing()
    end
end

function reset()
	init()
end

function destroy()
   -- do nothing
end
