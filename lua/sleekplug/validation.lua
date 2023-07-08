local M = {}

M.isEmpty = function(item)
    return not item
end

M.isNumber = function(item)
    return type(item) == 'number'
end

M.isString = function(item)
    return type(item) == 'string'
end

M.isTable = function(item)
    return type(item) == 'table'
end

M.isEmptyTable = function(item)
    return M.isTable(item) and #vim.tbl_count(item) == 0
end

M.err = function(message)
    vim.notify('SLEEKPLUG ERROR: ' .. message, vim.log.levels.ERROR)
end

M.validateSetupOpts = function(userSetupOpts)
    if not M.isTable(userSetupOpts) then
        M.err('Need to pass setup a table with pluginFolder = "someFolder" and plugins = { yourPluginsList }')
        return false
    end
    if not M.isString(userSetupOpts.pluginFolder) then
        M.err('Need to pass setup a table including pluginFolder = "someFolder"')
        return false
    end
    if not M.isTable(userSetupOpts.plugins) then
        M.err('Need to pass setup a table including plugins = { yourPluginsList }')
        return false
    end
    return true
end

return M
