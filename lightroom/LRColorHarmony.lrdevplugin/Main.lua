local LrTasks = import 'LrTasks'
local LrDialogs = import 'LrDialogs'
local LrApplication = import 'LrApplication'
local LrApplicationView = import 'LrApplicationView'
local DevelopProbe = require 'DevelopProbe'

LrTasks.startAsyncTask(function()
    local catalog = LrApplication.activeCatalog()
    if not catalog or not catalog:getTargetPhoto() then
        LrDialogs.message('LRColorHarmony Slice 0', 'Select a test photo before running the probe.', 'warning')
        return
    end

    local ok, result = LrTasks.pcall(function()
        if LrApplicationView.getCurrentModuleName() ~= 'develop' then
            LrApplicationView.switchToModule('develop')
            LrTasks.sleep(1)
        end
        return DevelopProbe.run()
    end)

    if not ok then
        LrDialogs.message('LRColorHarmony Slice 0', 'Probe failed. Check Lightroom plugin logs or report this error:\n' .. tostring(result), 'critical')
    else
        LrDialogs.message('LRColorHarmony Slice 0', result, 'info')
    end
end)
