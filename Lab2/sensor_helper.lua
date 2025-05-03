local sensor_helper = {}

sensor_helper.single_sensor_group = {{1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}, {15}, {16}, {17}, {18}, {19}, {20}, {21}, {22}, {23}, {24}}
sensor_helper.default_two_sensor_group = {{0, 24}, {2,3}, {4, 5}, {6, 7}, {8, 9}, {10, 11}, {12, 13}, {14, 15}, {16, 17}, {18, 19}, {20, 21}, {22, 23}}

function sensor_helper.extend(sensor_list, sensor_group)
    local sensor_group = sensor_group or sensor_helper.single_sensor_group
    local extensions = {
        sum = function() return sum_sensor_values(sensor_list) end,
        max_with_index = function(threshold, start_index, end_index)
                return find_max_value_in(sensor_list, threshold, start_index, end_index, sensor_group)
              end,
        max_with_index_in = function(threshold, indexes)
                return find_max_value_in_indexes(sensor_list, threshold, indexes)
              end,
        has_right_perception = function(threshold)
                local _, max_index = find_max_value_in(sensor_list, threshold, 13, 24)
                return max_index ~= nil
              end,
        has_left_perception = function(threshold)
                local _, max_index = find_max_value_in(sensor_list, threshold, 1, 12)
                return max_index ~= nil
              end                        
    }

    return setmetatable(sensor_list, {
        __index = function(_, key)
            return extensions[key]
        end
    })

end

function sensor_helper.is_right_sensor(sensor_index)
    return sensor_index >= 13 and sensor_index <= 24
end

function sensor_helper.is_left_sensor(sensor_index)
    return sensor_index >= 1 and sensor_index <= 12
end

function sum_sensor_values(sensor_list)
    local total = 0
    for i = 1, #sensor_list do
        total = total + sensor_list[i].value
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
function find_max_value_in(sensor_list, sensor_threshold, start_index, end_index, sensor_group)
    local max_value = sensor_threshold 
    local start_index = start_index or 1
    local end_index = end_index or #sensor_group
    local max_index = nil
    for i = start_index, end_index do
        for j = 1, #sensor_group[i] do
            local index = sensor_group[i][j]
            -- max startegy instead of avg statetgy
            if sensor_list[index].value > max_value then
                max_value = sensor_list[index].value
                max_index = i
            end
        end
    end
    return max_value, max_index
end

function find_max_value_in_indexes(sensor_list, sensor_threshold, indexes)
    local max_value = sensor_threshold
    local max_index = nil
    
    for i = 1, #indexes do
        local index = indexes[i]
        if sensor_list[index].value > max_value then
            max_value = sensor_list[index].value
            max_index = index
        end
    end

    return max_value, max_index
end

return sensor_helper