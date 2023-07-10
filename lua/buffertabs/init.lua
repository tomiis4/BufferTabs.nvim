local api = vim.api

---@class Data
---@field win_buf number|nil
---@field win number|nil
---@field name string
---@field active boolean

---@type Data[]
local data = {}
local width = 0
local ns = api.nvim_create_namespace('buffertabs')

local cfg = {
    border = 'rounded',
    icons = true,
    hl_group = 'Keyword',
    hl_group_inactive = 'Comment',
    exclude = { 'NvimTree', 'help', 'dashboard', 'lir', 'alpha' }
}

---@param name string
---@param ext string
---@return string
local function get_icon(name, ext)
    local ok, dev_icons = pcall(require, 'nvim-web-devicons')

    if not cfg.icons then
        return ' '
    end

    if not ok then
        return ''
    end

    local icon = dev_icons.get_icon(name, ext, { default = true })
    return icon
end

local function load_buffers()
    data = {}

    for _, buf in pairs(api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
            local name = api.nvim_buf_get_name(buf):match("[^\\/]+$") or ""
            local ext = string.match(name, "%w+%.(.+)") or name
            local icon = get_icon(name, ext)

            local is_excluded = vim.tbl_contains(cfg.exclude, vim.bo[buf].ft)
            if not is_excluded and name ~= "" then
                local is_active = api.nvim_get_current_buf() == buf

                table.insert(data, {
                    win = nil,
                    win_buf = nil,
                    name = icon .. " " .. name .. "",
                    active = is_active,
                })
            end
        end
    end
end

local function delete_buffers()
    for _, v in pairs(data) do
        local win, buf = v.win, v.win_buf

        if win ~= nil or buf ~= nil then
            if api.nvim_win_is_valid(win) then
                api.nvim_win_close(win, true)
                win = nil
            end

            if api.nvim_buf_is_valid(buf) then
                api.nvim_buf_delete(buf, { force = true })
                buf = nil
            end
        end
    end
end

---@return number
local function get_max_width()
    local max = 0

    for _, v in pairs(data) do
        max = max + #v.name + 3
    end

    return max
end

---@param name string
---@param is_active boolean
---@param data_idx number
---@param max_len number
local function create_win(name, is_active, data_idx)
    -- setup buffer
    local buf = api.nvim_create_buf(false, true)
    data[data_idx].win_buf = buf
    api.nvim_buf_set_lines(buf, 0, -1, true, { " " .. name .. " " })

    -- create window
    local win_opts = {
        relative = 'editor',
        width = #name,
        height = 1,
        row = 0,
        col = width + 3,
        style = "minimal",
        border = cfg.border,
        focusable = false,
    }
    local win = api.nvim_open_win(buf, false, win_opts)
    data[data_idx].win = win

    width = width + #name + 3

    -- configure window
    api.nvim_buf_set_option(buf, 'modifiable', false)
    api.nvim_buf_set_option(buf, 'buflisted', false)


    -- add highlight
    if is_active then
        api.nvim_buf_add_highlight(buf, ns, cfg.hl_group, 0, 0, -1)
        api.nvim_win_set_option(win, 'winhighlight', 'FloatBorder:' .. cfg.hl_group)
    else
        api.nvim_buf_add_highlight(buf, ns, cfg.hl_group_inactive, 0, 0, -1)
        api.nvim_win_set_option(win, 'winhighlight', 'FloatBorder:' .. cfg.hl_group_inactive)
    end
end

local function display_buffers()
    delete_buffers()
    width = vim.o.columns / 2 - get_max_width() / 2

    for idx, v in pairs(data) do
        create_win(v.name, v.active, idx)
    end
end


---@param opts table
local function setup(opts)
    for k, v in pairs(opts) do
        cfg[k] = v
    end

    local events = { 'BufEnter', 'BufAdd', 'BufDelete', 'BufLeave', 'InsertChange', 'VimResized' }
    api.nvim_create_autocmd(events, {
        callback = function()
            delete_buffers()
            load_buffers()
            display_buffers()
        end
    })
end

return {
    setup = setup
}
