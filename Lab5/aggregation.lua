local robot_helper = require "robot_helper"
local sensor_helper = require "sensor_helper"

MAX_RANGE = 30
MAX_VELOCITY = 15
ROTATION_VELOCITY = 5
MOVE_STEPS = 60

PROXIMITY_THRESHOLD = 0.01
STANDING_THRESHOLD = 0.1

Ps0 = 0.01
Ps_MAX = 0.99
Alpha = 0.1
Ps = 0.0
Ds = 0.0

Pw0 = 0.1
Pw_MIN = 0.05
Beta = 0.05
Pw = 0.0
Dw = 0.0

Moving = false
n_steps = 0
robot = robot_helper.extend(robot, MAX_VELOCITY, ROTATION_VELOCITY)

function init()
	n_steps = 0
	robot.leds.set_all_colors("black")
end

function update_ps(n)   
    Ps = math.min(Ps_MAX, Ps0 + Alpha * n + Ds)
end

function update_pw(n)
    Pw = math.max(Pw_MIN, Pw0 - Beta * n - Dw)
end

function handle_black_spot()
    if robot:standing_condition(STANDING_THRESHOLD) then
        Ds = 0.4
        Dw = 0.2
    else
        Ds = -0.2
        Dw = -0.1   
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
    n_steps = robot_helper.handle_walk(robot.random_walk_behaviour, n_steps, MOVE_STEPS)
    robot:handle_collision(PROXIMITY_THRESHOLD)
    if Ps >= robot.random.uniform() then
        Moving = false
    end
end

function do_when_standing()
    robot.leds.set_all_colors("red")
    robot:stop()
    if Pw >= robot.random.uniform() then
        Moving = true
    end
end

function step()    
    if Moving then
        robot.range_and_bearing.set_data(1,0)
        handle_black_spot()
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
