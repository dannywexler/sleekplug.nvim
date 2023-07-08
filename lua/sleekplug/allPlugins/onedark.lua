return {
    'navarasu/onedark.nvim',
    priority = 1000,
    config = function(_, opts)
        require 'onedark'.setup(opts)
        require 'onedark'.load()
    end,
}
