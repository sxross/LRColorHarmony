local LrTasks = import 'LrTasks'
local LrDialogs = import 'LrDialogs'
local LrApplication = import 'LrApplication'
local LrApplicationView = import 'LrApplicationView'
local HistoryProbe = require 'HistoryProbe'

LrTasks.startAsyncTask(function()
    local catalog = LrApplication.activeCatalog()
    if not catalog or not catalog:getTargetPhoto() then
        LrDialogs.message('LRColorHarmony History Probe', 'Select a disposable virtual copy first.', 'warning')
        return
    end

    local mode = 'plain'
    assert(mode == 'plain' or mode == 'grouped' or mode == 'restore')
    if mode ~= 'restore' then
        local answer = LrDialogs.confirm('History Probe: leaves grading applied',
            'Use a separate disposable virtual copy. This experiment deliberately leaves four Color Grading settings changed. Continue?',
            'Run probe', 'Cancel')
        if answer ~= 'ok' then return end
    end

    local ok, result = LrTasks.pcall(function()
        if LrApplicationView.getCurrentModuleName() ~= 'develop' then
            LrApplicationView.switchToModule('develop')
            LrTasks.sleep(1)
        end
        return HistoryProbe.run(mode)
    end)
    if not ok then
        LrDialogs.message('History Probe failed', tostring(result) .. '\nInspect your virtual copy; restoration cannot be guaranteed.', 'critical')
    else
        LrDialogs.message('History Probe results', result, 'info')
    end
end)
