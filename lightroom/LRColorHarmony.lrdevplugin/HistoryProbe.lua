local Develop = import 'LrDevelopController'
local LrTasks = import 'LrTasks'

local M = {}

local changes = {
    { name = 'SplitToningShadowHue', value = 210 },
    { name = 'SplitToningShadowSaturation', value = 20 },
    { name = 'SplitToningHighlightHue', value = 30 },
    { name = 'SplitToningHighlightSaturation', value = 20 },
}

local function read(name)
    local value = Develop.getValue(name)
    assert(type(value) == 'number', name .. ': expected numeric value')
    return value
end

local function snapshot()
    local original = {}
    for _, item in ipairs(changes) do
        local low, high = Develop.getRange(item.name)
        assert(type(low) == 'number' and type(high) == 'number', item.name .. ': range unavailable')
        assert(item.value >= low and item.value <= high, item.name .. ': target outside range')
        original[item.name] = read(item.name)
    end
    return original
end

local function write(values, attempted)
    for _, item in ipairs(changes) do
        local name = item.name
        attempted[#attempted + 1] = name
        Develop.setValue(name, values[name])
        assert(math.abs(read(name) - values[name]) < 0.0001, name .. ': readback mismatch')
    end
end

local function restore(original, attempted)
    local errors = {}
    for i = #attempted, 1, -1 do
        local name = attempted[i]
        local ok, err = LrTasks.pcall(function()
            Develop.setValue(name, original[name])
            assert(math.abs(read(name) - original[name]) < 0.0001, name .. ': restore mismatch')
        end)
        if not ok then errors[#errors + 1] = tostring(err) end
    end
    return errors
end

function M.run(mode)
    assert(mode == 'plain' or mode == 'grouped' or mode == 'restore', 'unknown probe mode')
    local original = snapshot()
    local target = {}
    for _, item in ipairs(changes) do target[item.name] = item.value end
    local attempted = {}
    local applied = false
    local errors = {}

    -- The SDK describes this as a history grouping threshold, not a transaction.
    -- There is no documented getter for the prior threshold, so we use documented
    -- defaults and reset them after the experiment.
    local groupingEnabled = mode ~= 'plain'
    if groupingEnabled then
        Develop.setTrackingDelay(2)
        Develop.setMultipleAdjustmentThreshold(1)
    end

    local ok, err = LrTasks.pcall(function()
        write(target, attempted)
        applied = true
        if mode == 'restore' then
            -- Do not sleep: we want to learn whether rapid restoration coalesces.
            local restored = restore(original, attempted)
            for _, message in ipairs(restored) do errors[#errors + 1] = message end
        end
    end)

    if not ok then
        errors[#errors + 1] = tostring(err)
        -- Any failed apply must be restored even in the apply-only modes.
        local restored = restore(original, attempted)
        for _, message in ipairs(restored) do errors[#errors + 1] = message end
    end

    if groupingEnabled then
        -- Restore documented SDK defaults; preexisting nondefault values cannot be queried.
        local resetOk, resetErr = LrTasks.pcall(function()
            Develop.setMultipleAdjustmentThreshold(0.5)
            Develop.setTrackingDelay(2)
        end)
        if not resetOk then errors[#errors + 1] = 'Threshold reset failed: ' .. tostring(resetErr) end
    end

    local finalMatchesOriginal = true
    local finalMatchesTarget = true
    for _, item in ipairs(changes) do
        local value = read(item.name)
        if math.abs(value - original[item.name]) > 0.0001 then finalMatchesOriginal = false end
        if math.abs(value - target[item.name]) > 0.0001 then finalMatchesTarget = false end
    end

    local lines = {
        'History Probe: ' .. mode,
        'Apply readback: ' .. (applied and 'passed' or 'failed'),
        'Final matches original: ' .. tostring(finalMatchesOriginal),
        'Final matches target: ' .. tostring(finalMatchesTarget),
        'Inspect History panel before doing anything else.',
    }
    if mode ~= 'restore' and #errors == 0 then
        lines[#lines + 1] = 'Changes intentionally remain applied. Test ONE Undo and check all four values.'
    end
    if mode == 'restore' then
        lines[#lines + 1] = 'Check whether Apply+Restore created history entries despite unchanged final values.'
    end
    if #errors > 0 then
        for _, message in ipairs(errors) do lines[#lines + 1] = 'ERROR: ' .. message end
        lines[#lines + 1] = 'If restoration failed, revert the virtual copy manually.'
    end
    return table.concat(lines, '\n')
end

return M
