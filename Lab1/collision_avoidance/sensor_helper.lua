function extend(sensor_list)
    return setmetatable(sensor_list, {
        __index = function(table, key)
            if key == "sum" then
                return sum_sensor_values(table)
            end
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