local sensor_helper = {}

function sensor_helper.extend(sensor_list)
    local extensions = {
        sum = function() return sum_sensor_values(sensor_list) end,
        max_with_index = function(threshold, start_index, end_index)
                return find_max_value_in(sensor_list, threshold, start_index, end_index)
              end
    }

    return setmetatable(sensor_list, {
        __index = function(_, key)
            return extensions[key]
        end
    })

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
function find_max_value_in(sensor_list, sensor_threshold, start_index, end_index)
    local max_value = sensor_threshold or sensor_list[1].value
    local start_index = start_index or 1
    local end_index = end_index or #sensor_list
    local max_index = nil
	if sensor_threshold == nil then
		max_index = start_index
	end	

    for i = start_index, end_index do
        if sensor_list[i].value > max_value then
            max_value = sensor_list[i].value
            max_index = i
        end
    end

    return max_value, max_index
end

return sensor_helper