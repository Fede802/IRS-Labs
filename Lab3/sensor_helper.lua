local function indexes_from(sensor_list)
    local indexes = {}
    for i = 1, #sensor_list do
        indexes[i] = i
    end
    return indexes
end

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
    setmetatable(sensor_list, self)
    sensor_list.sensor_indexes = indexes_from(sensor_list)
    sensor_list.default_single_sensor_group = default_single_sensor_group_from(sensor_list)
    sensor_list.default_two_sensor_group = default_two_sensor_group_from(sensor_list)
    return sensor_list
end

function SensorExtension:sum(indexes)
    local indexes = indexes or self.sensor_indexes
    local total = 0
    for i = 1, #indexes do
        total = total + self[indexes[i]].value
    end
    return total
end

local function find_value_in(self, configuration, condition)
    local threshold = configuration.threshold or 0.0
    local sensor_group = configuration.sensor_group or self.default_single_sensor_group
    local start_index = configuration.start_index or 1
    local end_index = configuration.end_index or #sensor_group

    local searched_value = threshold 
    local searched_index = nil
    for i = start_index, end_index do
        for j = 1, #sensor_group[i] do
            local index = sensor_group[i][j]
            if condition(self[index].value, searched_value) then
                searched_value = self[index].value
                searched_index = i
            end
        end    
    end
    return searched_value, searched_index
end

function SensorExtension:max_with_index(configuration)
    return find_value_in(self, configuration, function(a, b) return a > b end)
end

function SensorExtension:min_with_index(configuration)
    return find_value_in(self, configuration, function(a, b) return a < b end)
end

function SensorExtension:is_right(sensor_index)
    return sensor_index > #self/2 and sensor_index <= #self
end

function SensorExtension:is_left(sensor_index)
    return sensor_index > 0 and sensor_index <= #self/2
end

function SensorExtension:estimate_angle_of(indexes)
    local sensor_total_value = self:sum(indexes)
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