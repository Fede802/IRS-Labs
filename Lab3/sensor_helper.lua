local function default_single_sensor_group_from(sensor_list)
    local sensor_group = {}
    for i = 1, #sensor_list do
        sensor_group[i] = {i}
    end
    return sensor_group
end

local function default_two_sensor_group_from(sensor_list)
    local sensor_group = {}
    table.insert(sensor_group, {1, #sensor_list})
    for i = 2, #sensor_list - 1, 2 do
        table.insert(sensor_group, {i, i + 1})
    end
    return sensor_group
end

local SensorExtension = {}
SensorExtension.__index = SensorExtension

function SensorExtension:new(sensor_list)
    local instance = setmetatable(sensor_list, self)
    instance.default_single_sensor_group = default_single_sensor_group_from(sensor_list)
    instance.default_two_sensor_group = default_two_sensor_group_from(sensor_list)
    return instance
end

function SensorExtension:sum_sensor_values(indexes)
    local indexes = indexes or self.default_single_sensor_group
    local total = 0
    for i = 1, #indexes do
        total = total + self[indexes[i]].value
    end
    return total
end

function SensorExtension:find_max_value_in(configuration)
    local threshold = configuration.threshold or 0.0
    local sensor_group = configuration.sensor_group or self.default_single_sensor_group
    local start_index = configuration.start_index or 1
    local end_index = configuration.end_index or #sensor_group

    local max_value = threshold 
    local max_index = nil
    for i = start_index, end_index do
        for j = 1, #sensor_group[i] do
            local index = sensor_group[i][j]
            if self[index].value > max_value then
                max_value = self[index].value
                max_index = i
            end
        end    
    end
    return max_value, max_index
end

function SensorExtension:find_angle_considering(indexes)
    local sensor_total_value = self:sum_sensor_values(indexes)
    local cumulative_angle = 0.0
    for i = 1, #indexes do
        local sensor = self[indexes[i]]
        local weight = sensor.value / sensor_total_value
        cumulative_angle = cumulative_angle + weight * sensor.angle
    end
    return cumulative_angle
end

local sensor_helper = {}

function sensor_helper.scale_up(value, desired_oom)
    if value == 0 then return 0 end
    while math.abs(value) < desired_oom do
        value = value * 10
    end
    return value
end

function sensor_helper.extend(sensor_list)       
    return SensorExtension:new(sensor_list)
end

return sensor_helper