local M = {}
local debug = false

local val = require('sleekplug.validation')

local allPluginsSpec = {
    {
        'dannywexler/sleekplug.nvim',
        name = 'sleekplug'
    },
}
local lazyOptions = {}
local userPlugins = {}
local userPluginFolder = ''

local function req(item)
    local status, res = pcall(require, item)
    if status then return res end
    return nil
end

local function p(item)
    if debug then
        print(vim.inspect(item))
    end
end

local function merge(table1, table2)
    return vim.tbl_extend('force', table1, table2)
end

local function getDefaultSpec(pluginName)
    local defaultSpec = req('sleekplug.allPlugins.' .. pluginName)
    if not defaultSpec then
        val.err('Unknown plugin ' .. pluginName)
        return
    end
    p('default spec found:')
    p(defaultSpec)
    return defaultSpec
end

local function getUserSpec(pluginName)
    local userSpec = req(userPluginFolder .. '.' .. pluginName)
    if not userSpec then
        p('no user spec found')
        return
    end
    return userSpec
end

local function parseSinglePlugin(pluginString, pluginTable)
    p('parsingPluginString ' .. pluginString)
    if pluginString == 'lazy' then
        lazyOptions = getUserSpec(pluginString)
        p('found lazyOptions:')
        p(lazyOptions)
        return
    end
    local defaultSpec = getDefaultSpec(pluginString)
    if not defaultSpec then return end

    local userSpec = pluginTable or getUserSpec(pluginString)
    p('user spec found:')
    p(userSpec)
    local combinedSpec = merge(defaultSpec, userSpec or {})
    combinedSpec = merge(combinedSpec, { name = pluginString })
    if not combinedSpec.opts and not combinedSpec.config then
        combinedSpec.config = true
    end

    p('combinedSpec:')
    p(combinedSpec)

    table.insert(allPluginsSpec, combinedSpec)
end

local function parseUserPlugins()
    p('initial allPluginsSpec:')
    p(allPluginsSpec)
    for key, value in pairs(userPlugins) do
        p('key: ' .. vim.inspect(key))
        p('value: ' .. vim.inspect(value))
        if val.isNumber(key) and val.isString(value) then
            parseSinglePlugin(value)
        elseif val.isString(key) and val.isTable(value) then
            parseSinglePlugin(key, value)
        else
            val.err('Error for key: ' .. vim.inspect(key))
            val.err('  and value: ' .. vim.inspect(value))
            val.err(
                '  Plugin needs to be either a string of the plugin name, or a key with the plugin name and a table of plugin options')
        end
    end
    p('final allPluginsSpec:')
    p(allPluginsSpec)
end

--------------------------------------------------------------------------------

M.setup = function(userOpts)
    p('hello from sleekplug setup')
    p(userOpts)
    if not val.validateSetupOpts(userOpts) then return end
    userPluginFolder = userOpts.pluginFolder
    userPlugins = userOpts.plugins
    parseUserPlugins()
    require 'sleekplug.lazy'.bootstrapLazy(allPluginsSpec, lazyOptions)
    p('')
end

return M
