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
local timer = nil
local active_index = nil

---@class Config
local cfg = {
    ---@type 'none'|'single'|'double'|'rounded'|'solid'|'shadow'|table
    border = 'rounded',
    ---@type integer
    padding = 1,
    ---@type boolean
    icons = true,
    ---@type string
    modified = " +",
    ---@type string
    hl_group = 'Keyword',
    ---@type string
    hl_group_inactive = 'Comment',
    ---@type boolean
    show_all = false,
    ---@type boolean
    show_all_listed = false,
    ---@type boolean
    show_single_buffer = true,
    ---@type 'row'|'column'
    display = 'row',
    ---@type 'left'|'right'|'center'
    horizontal = 'center',
    ---@type 'top'|'bottom'|'center'
    vertical = 'top',
    ---@type number ms
    timeout = 0,
    ---@type boolean
    show_id = false,
    ---@type integer
    max_buffers = 0,
    ---@type integer
    surround_active_buffer = 0,
}


---@param d_buf number
local function load_buffers(d_buf)
    data = {}

    local bufs = api.nvim_list_bufs()

    bufs = vim.tbl_filter(function(buf)
        -- Don't load deleted buffer
        if d_buf == buf then
            return false
        end

        if cfg.show_all then
            return true
        end

        local is_listed = vim.fn.buflisted(buf) == 1

        if cfg.show_all_listed and is_listed then
            return true
        end

        local is_loaded = api.nvim_buf_is_loaded(buf)

        return is_loaded and is_listed
    end, bufs)

    for _, buf in pairs(bufs) do
        local name = api.nvim_buf_get_name(buf):match("[^\\/]+$") or ""
        local is_modified = api.nvim_buf_get_option(buf, 'modified')
        local ext = string.match(name, "%w+%.(.+)") or name
        local icon = U.get_icon(name, ext, cfg)

        if name ~= "" then
            local is_active = api.nvim_get_current_buf() == buf
            local final_name = ""
            if cfg.show_id then
                final_name = icon .. buf .. ". " .. name
            else
                final_name = icon .. name
            end
            table.insert(data, {
                win = nil,
                win_buf = nil,
                name = final_name,
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
    local modified_width = is_modified and vim.fn.strdisplaywidth(cfg.modified) or 0

    local function get_position()
        local res = {
            row = 0,
            col = 0,
        }

        if cfg.display == 'row' then
            res.row = U.get_position_vertical(cfg.vertical)
            res.col = width + 3 -- padding at left side
            width = width + vim.fn.strdisplaywidth(name) + cfg.padding + modified_width + 3
        end

        if cfg.display == 'column' then
            if cfg.horizontal == 'left' then
                res.col = 0
            elseif cfg.horizontal == 'right' then
                res.col = vim.o.columns - (vim.fn.strdisplaywidth(name) + modified_width)
            else
                res.col = vim.o.columns / 2 - vim.fn.strdisplaywidth(name) / 2
            end

            res.row = width
            width = width + cfg.padding + 2
        end

        return res
    end

    -- setup buffer
    local buf = api.nvim_create_buf(false, true)
    local modified = is_modified and cfg.modified or ""

    data[data_idx].win_buf = buf
    api.nvim_buf_set_lines(buf, 0, -1, true,
        { " " .. name .. modified .. " " }
    )

    local pos = get_position()

    -- create window
    local win_opts = {
        relative = 'editor',
        width = vim.fn.strdisplaywidth(name) + modified_width + 2, -- 2 for padding
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
        api.nvim_set_option_value('winhighlight', 'NormalFloat:Normal,FloatBorder:' .. cfg.hl_group, { win = win })
    else
        api.nvim_buf_add_highlight(buf, ns, cfg.hl_group_inactive, 0, 0, -1)
        api.nvim_set_option_value('winhighlight', 'NormalFloat:Normal,FloatBorder:' .. cfg.hl_group_inactive, { win = win })
    end
end

local function display_buffers()
    local max = U.get_max_width(data, cfg)
    width = U.get_position_horizontal(cfg, max, #data)

    local buffer_count = #data

    if cfg.show_single_buffer == false and buffer_count <= 1 then
        return
    end

    if cfg.max_buffers > 0 and buffer_count > cfg.max_buffers then
        return
    end

    -- It only makes sense to show the surrounding buffers if there are enough buffers to show
    local minimum_buffers_to_show = 2 * cfg.surround_active_buffer + 1

    if cfg.surround_active_buffer > 0 and buffer_count >= minimum_buffers_to_show then

        -- Find the index of the active buffer
        for idx, v in pairs(data) do
            if v.active then
                active_index = idx
                break
            end
        end

        -- If there is no active buffer, such as when telescope is open, dont show buffer tabs
        if active_index == nil then
            return
        end

        local lowest_idx = active_index - cfg.surround_active_buffer
        local highest_idx = active_index + cfg.surround_active_buffer

        local total_shown = 0
        for idx = lowest_idx, highest_idx do
            total_shown = total_shown + 1
            local buffer_idx = idx % buffer_count -- Wrap around to start of list
            if buffer_idx <= 0 then buffer_idx = buffer_count + buffer_idx end -- Wrap around to end of list
            local buffer_data = data[buffer_idx]
            create_win(buffer_data.name, buffer_data.active, buffer_data.modified, total_shown)
        end
    else
        for idx, v in pairs(data) do
            create_win(v.name, v.active, v.modified, idx)
        end
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
                local buf = e.event == "BufDelete" and e.buf

                U.delete_buffers(data)
                load_buffers(buf)
                display_buffers()

                if cfg.timeout > 0 then
                    if timer ~= nil then
                        timer:stop()
                    end

                    timer = vim.loop.new_timer()
                    timer:start(cfg.timeout, 0, vim.schedule_wrap(function()
                        U.delete_buffers(data)
                    end))
                end
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
