local U = {}

---@param name string
---@param ext string
---@param cfg table
---@return string
function U.get_icon(name, ext, cfg)
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

---@param data Data[]
---@return number
function U.get_max_width(data)
    local max = 0

    for _, v in pairs(data) do
        max = max + #v.name + 4
    end

    return max
end

local api = vim.api
---@param data Data[]
function U.delete_buffers(data)
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

--- return number  based of position, default is center
---@param pos 'left'|'right'|'center'
---@param max number 
---@return number
function U.get_position_horizontal(pos, max)
    if pos == 'left' then
        return 0
    elseif pos == 'right' then
        return vim.o.columns - max
    else
        return vim.o.columns / 2 - max / 2
    end
end

---@param pos 'top'|'bottom'|'center'
---@return number
function U.get_position_vertical(pos)
    if pos == 'bottom' then
        return vim.o.lines - 5
    elseif pos == 'center' then
        return vim.o.lines / 2 - 2 -- window is 3 height
    else
        return 0
    end
end

U.events = { 'BufEnter', 'BufAdd', 'BufDelete', 'BufLeave', 'InsertChange', 'VimResized' }

return U
