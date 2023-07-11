vim.api.nvim_create_user_command(
    'BufferTabsToggle',
    require('buffertabs').toggle,
    {}
)
