local api = vim.api
local M = {}
local U = require('buffertabs.utils')

---@class Data
---@field win_buf number|nil
---@field win number|nil
---@field name string
---@field active boolean
---@field modified boolean

---@type Data[]
local data = {}
local width = 0
local is_enabled = false
local ns = api.nvim_create_namespace('buffertabs')

---@class Config
local cfg = {
    ---@type 'none'|'single'|'double'|'rounded'|'solid'|'shadow'|table
    border = 'rounded',
    ---@type integer
    padding = 1,
    ---@type boolean
    icons = true,
    ---@type string
    modified = "",
    ---@type string
    hl_group = 'Keyword',
    ---@type string
    hl_group_inactive = 'Comment',
    ---@type boolean
    show_all = false,
    ---@type 'row'|'column'
    display = 'row',
    ---@type 'left'|'right'|'center'
    horizontal = 'center',
    ---@type 'top'|'bottom'|'center'
    vertical = 'top',
}


---@param d_buf number
local function load_buffers(d_buf)
    data = {}

    local bufs = api.nvim_list_bufs()

    bufs = vim.tbl_filter(function(buf)
        local is_loaded = api.nvim_buf_is_loaded(buf)
        local is_listed = vim.fn.buflisted(buf) == 1

        if not (is_loaded and is_listed) or d_buf == buf then
            return false
        end

        return true
    end, bufs)

    for _, buf in pairs(bufs) do
        local name = api.nvim_buf_get_name(buf):match("[^\\/]+$") or ""
        local is_modified = api.nvim_buf_get_option(buf, 'modified')
        local ext = string.match(name, "%w+%.(.+)") or name
        local icon = U.get_icon(name, ext, cfg)

        if name ~= "" then
            local is_active = api.nvim_get_current_buf() == buf

            table.insert(data, {
                win = nil,
                win_buf = nil,
                name = icon .. " " .. name .. "",
                active = is_active,
                modified = is_modified,
            })
        end
    end
end


---@param name string
---@param is_active boolean
---@param is_modified boolean
---@param data_idx number
local function create_win(name, is_active, is_modified, data_idx)
    local function get_position()
        local res = {
            row = 0,
            col = 0,
        }

        if cfg.display == 'row' then
            res.row = U.get_position_vertical(cfg.vertical)
            res.col = width + 3
            width = width + #name + #cfg.modified + cfg.padding + 2
        end

        if cfg.display == 'column' then
            if cfg.horizontal == 'left' then
                res.col = 0
            elseif cfg.horizontal == 'right' then
                res.col = vim.o.columns - #name
            else
                res.col = vim.o.columns / 2 - #name / 2
            end

            res.row = width
            width = width + cfg.padding + 2
        end

        return res
    end

    -- setup buffer
    local buf = api.nvim_create_buf(false, true)
    local modified_icon = is_modified and cfg.modified or " "

    data[data_idx].win_buf = buf
    api.nvim_buf_set_lines(buf, 0, -1, true,
        { " " .. name .. " " .. modified_icon }
    )

    local pos = get_position()

    -- create window
    local win_opts = {
        relative = 'editor',
        width = #name + 2,
        height = 1,
        row = pos.row,
        col = pos.col,
        style = "minimal",
        border = cfg.border,
        focusable = false,
    }
    local win = api.nvim_open_win(buf, false, win_opts)
    data[data_idx].win = win

    -- configure window
    api.nvim_set_option_value('modifiable', false, { buf = buf })
    api.nvim_set_option_value('buflisted', false, { buf = buf })


    -- add highlight
    if is_active then
        api.nvim_buf_add_highlight(buf, ns, cfg.hl_group, 0, 0, -1)
        api.nvim_set_option_value('winhighlight', 'FloatBorder:' .. cfg.hl_group, { win = win })
    else
        api.nvim_buf_add_highlight(buf, ns, cfg.hl_group_inactive, 0, 0, -1)
        api.nvim_set_option_value('winhighlight', 'FloatBorder:' .. cfg.hl_group_inactive, { win = win })
    end
end

local function display_buffers()
    local max = U.get_max_width(data)
    width = U.get_position_horizontal(cfg, max, #data)

    for idx, v in pairs(data) do
        create_win(v.name, v.active, v.modified, idx)
    end
end


---@param opts table
function M.setup(opts)
    -- setup config
    cfg = vim.tbl_deep_extend('force', cfg, opts or {})

    cfg.hl_group = U.get_color(cfg.hl_group, 0)
    cfg.hl_group_inactive = U.get_color(cfg.hl_group_inactive, 1)


    -- start displaying
    is_enabled = true

    api.nvim_create_autocmd(U.events, {
        callback = function(e)
            if is_enabled then
                local buf = e.event == "BufDelete" and e.buf or -1

                U.delete_buffers(data)
                load_buffers(buf)
                display_buffers()
            end
        end
    })
end

function M.toggle()
    if is_enabled == false then
        U.delete_buffers(data)
        load_buffers(-1)
        display_buffers()

        is_enabled = true
    else
        U.delete_buffers(data)
        is_enabled = false
    end
end

return M
