local sensor_helper = {}

sensor_helper.single_sensor_group = {{1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}, {15}, {16}, {17}, {18}, {19}, {20}, {21}, {22}, {23}, {24}}
sensor_helper.default_two_sensor_group = {{1, 24}, {2,3}, {4, 5}, {6, 7}, {8, 9}, {10, 11}, {12, 13}, {14, 15}, {16, 17}, {18, 19}, {20, 21}, {22, 23}}

function sensor_helper.extend(sensor_list, sensor_group)
    local extensions = {}
    extensions.sum = function(indexes) return sum_sensor_values(sensor_list, indexes) end
    extensions.max_with_index = function(configuration) return find_max_value_in(sensor_list, configuration) end
    extensions.angle_considering = function(indexes) return find_angle_considering(sensor_list, indexes) end          
    return setmetatable(sensor_list, {__index = function(_, key) return extensions[key] end})
end

function sum_sensor_values(sensor_list, indexes)
    local indexes = indexes or sensor_helper.single_sensor_group
    local total = 0
    for i = 1, #indexes do
        total = total + sensor_list[indexes[i]].value
    end
    return total
end

--[[
    Finds the index and value of the maximum 'value' field in a subrange of a sensor list,
    only if the value exceeds a given threshold.

    Parameters:
        sensor_list (table): A list of sensors, where each element is a table containing numeric 'value' and 'angle' fields.
        sensor_threshold (number, optional): A threshold value; only sensor values greater than this are considered. Defaults to sensor_list[1].value.
        start_index (number, optional): The starting index (inclusive) of the range to search. Defaults to 1.
        end_index (number, optional): The ending index (inclusive) of the range to search. Defaults to #sensor_list.

    Returns:
        max_value (number): The maximum sensor value found above the threshold or the threshold if no value exceeds it.
        max_index (number or nil): The index of the maximum sensor value that exceeds the threshold, or nil if no such value is found.
]]
function find_max_value_in(sensor_list, configuration)
    local threshold = configuration.threshold or 0.0
    local sensor_group = configuration.sensor_group or sensor_helper.single_sensor_group
    local start_index = configuration.start_index or 1
    local end_index = configuration.end_index or #sensor_group

    local max_value = threshold 
    local max_index = nil
    for i = start_index, end_index do
        -- avg strategy
        -- local inner_sum = 0.0
        -- for j = 1, #sensor_group[i] do
        --             inner_sum = inner_sum + sensor_list[sensor_group[i][j]].value 
        -- end
        -- inner_sum = inner_sum / #sensor_group[i]    
        -- if inner_sum > max_value then
        --     max_value = inner_sum
        --     max_index = i
        -- end
        -- max strategy
        local index = sensor_group[i][1]
        for j = 1, #sensor_group[i] do
            if sensor_list[index].value > max_value then
                max_value = sensor_list[index].value
                max_index = i
            end
        end    
    end
    return max_value, max_index
end

function find_angle_considering(sensor_list, indexes)
    local sensor_total_value = sum_sensor_values(sensor_list, indexes)
    local cumulative_angle = 0.0
    for i = 1, #indexes do
        local sensor = sensor_list[indexes[i]]
        local weight = sensor.value / sensor_total_value
        cumulative_angle = cumulative_angle + weight * sensor.angle
    end
    return cumulative_angle
end  

return sensor_helper