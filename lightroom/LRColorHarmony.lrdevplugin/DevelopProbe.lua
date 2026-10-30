local Develop = import 'LrDevelopController'
local LrTasks = import 'LrTasks'

local M = {}

-- A deliberately narrow experiment. No unrelated settings are written.
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

function M.run()
    local originals = {}
    local ranges = {}
    -- Validate every parameter before the first write.
    for _, item in ipairs(changes) do
        local low, high = Develop.getRange(item.name)
        assert(type(low) == 'number' and type(high) == 'number',
            item.name .. ': unavailable numeric range')
        assert(item.value >= low and item.value <= high,
            item.name .. ': test value outside supported range')
        ranges[item.name] = { low, high }
        originals[item.name] = read(item.name)
    end

    local written = {}
    local readings = {}
    local applyOk, applyErr = pcall(function()
        for _, item in ipairs(changes) do
            -- Record intent before calling setValue: the call might partially succeed.
            written[#written + 1] = item.name
            Develop.setValue(item.name, item.value)
            readings[item.name] = read(item.name)
        end
        -- Permit Lightroom to render the experimental grade briefly.
        LrTasks.sleep(1)
    end)

    -- Always attempt restoration, including after partial failure.
    local restoreErrors = {}
    for i = #written, 1, -1 do
        local name = written[i]
        local ok, err = pcall(function()
            Develop.setValue(name, originals[name])
            local actual = read(name)
            assert(math.abs(actual - originals[name]) < 0.0001,
                name .. ': restore readback differs')
        end)
        if not ok then restoreErrors[#restoreErrors + 1] = tostring(err) end
    end

    local lines = {
        'Color Grading feasibility probe (test photo only)',
        'Apply: ' .. (applyOk and 'completed' or ('FAILED: ' .. tostring(applyErr))),
        'Restore: ' .. (#restoreErrors == 0 and 'readback matched' or 'FAILED'),
    }
    for _, item in ipairs(changes) do
        local range = ranges[item.name]
        lines[#lines + 1] = string.format('%s: original=%s target=%s readback=%s range=[%s,%s]',
            item.name, tostring(originals[item.name]), tostring(item.value),
            tostring(readings[item.name]), tostring(range[1]), tostring(range[2]))
    end
    for _, err in ipairs(restoreErrors) do lines[#lines + 1] = 'RESTORE ERROR: ' .. err end
    lines[#lines + 1] = 'Check Develop history and unrelated settings manually.'
    if #restoreErrors > 0 then
        lines[#lines + 1] = 'WARNING: Restoration could not be confirmed. Revert the test photo manually.'
    end
    return table.concat(lines, '\n')
end

return M
