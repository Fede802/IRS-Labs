-- Put your global variables here
MOVE_STEPS = 15
MAX_VELOCITY = 10
LIGHT_THRESHOLD = 1.5

n_steps = 0
turn_count = 0
find_obstacle = false
should_turn = false

--[[ This function is executed every time you press the 'execute'
     button ]]
function init()
    left_v = robot.random.uniform(0, MAX_VELOCITY)
    right_v = robot.random.uniform(0, MAX_VELOCITY)
    robot.wheels.set_velocity(left_v, right_v)
    n_steps = 0
    robot.leds.set_all_colors("black")
end
function findMaxValue(arr)
    local maxVal = arr[1].value -- Start with the first element's value
    local maxIdx = 0
    for i = 2, #arr do
        if arr[i].value > maxVal then
            maxVal = arr[i].value
            maxIdx = i
        end
    end

    return maxVal, maxIdx
end
function findMaxValue2(arr)
    local maxVal = 0 -- Start with the first element's value
    local maxIdx = 0
    for i = 1, 7 do
        if arr[i].value > maxVal then
            maxVal = arr[i].value
            maxIdx = i
        end
    end
    for i = 18, 24 do
        if arr[i].value > maxVal then
            maxVal = arr[i].value
            maxIdx = i
        end
    end

    return maxVal, maxIdx
end

function isObstacleInFront(arr)
    proximity_threshold = 0
    if arr[1].value > proximity_threshold or arr[2].value > proximity_threshold or arr[23].value > proximity_threshold or arr[24].value >
        proximity_threshold then return true end
    return false
end
function isObstacleOnTheRight(arr)
    proximity_threshold = 0
    free = false
    for i = 17, 20 do
        log(arr[i].value)
        if arr[i].value > proximity_threshold then free = true end
    end
    return free
end
function turnLeft() robot.wheels.set_velocity(-110, 110) end
function turnRight() robot.wheels.set_velocity(110, -110) end

function step()
    --[[	n_steps = n_steps + 1 ]]
    max_valuel, max_idxl = findMaxValue(robot.light)
    --[[ log("robot.max_light = " .. max_valuel)	
	log("turn_count = " .. turn_count) ]]
    if max_idxl > 0 then
        aa = robot.proximity[max_idxl].value
        log("prox = " .. aa)
    end
    max_valuep, max_idxp = findMaxValue2(robot.proximity)
    if isObstacleInFront(robot.proximity) then
        if not find_obstacle then
            find_obstacle = true
            turn_count = turn_count + 1
        end
        turn_count = turn_count + 1
        turnLeft()

    elseif turn_count < 2 and max_idxl > 0 and robot.proximity[max_idxl].value <=
        0.1 then
        turn_count = 0
        find_obstacle = false
        log("obs")
        angle = robot.light[max_idxl].angle
        wheeldistance = robot.wheels.axis_length
        local k = 0.5
        w = k * angle
        local v = 10
        left_v = v - (w * wheeldistance / 2)
        right_v = v + (w * wheeldistance / 2)
        robot.wheels.set_velocity(left_v, right_v)
    elseif find_obstacle then
        if isObstacleOnTheRight(robot.proximity) then
            robot.wheels.set_velocity(20, 20)
            should_turn = true
        elseif not isObstacleOnTheRight(robot.proximity) then
            if should_turn then
                if n_steps > 3 then
                    n_steps = 0
                    turn_count = turn_count - 1
                    if turn_count == 0 then
                        find_obstacle = false
                    end
                    turnRight()
                    should_turn = false
                else
                    n_steps = n_steps + 1
                    robot.wheels.set_velocity(20, 20)
                end
            else
                robot.wheels.set_velocity(20, 20)
            end
        end
    else
        left_v = robot.random.uniform(0, MAX_VELOCITY)
        right_v = robot.random.uniform(0, MAX_VELOCITY)
        robot.wheels.set_velocity(left_v, right_v)
    end

end

--[[ This function is executed every time you press the 'reset'
     button in the GUI. It is supposed to restore the state
     of the controller to whatever it was right after init() was
     called. The state of sensors and actuators is reset
     automatically by ARGoS. ]]
function reset()
    left_v = robot.random.uniform(0, MAX_VELOCITY)
    right_v = robot.random.uniform(0, MAX_VELOCITY)
    robot.wheels.set_velocity(left_v, right_v)
    n_steps = 0
    find_obstacle = false
    turn_count = 0
    should_turn = false
    robot.leds.set_all_colors("black")
end

--[[ This function is executed only once, when the robot is removed
     from the simulation ]]
function destroy()
    -- put your code here
end
