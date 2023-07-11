<h1 align="center"> BufferTabs - Simple and Fancy tabline for NeoVim </h1>


<hr>

<h3 align="center"> <img src='https://media.discordapp.net/attachments/772927831441014847/1127980296537657456/image.png?width=881&height=495'> </h3>
<h6 align="center"> Colorscheme: RoseBones; Font: JetBrainsMono NF </h6>

<hr>


## Installation

<details>
<summary> Using vim-plug </summary>

```vim
Plug 'tomiis4/BufferTabs.nvim'
```

</details>

<details>
<summary> Using packer </summary>

```lua
use 'tomiis4/BufferTabs.nvim'
```

</details>

<details>
<summary> Using lazy </summary>

```lua
{
    'tomiis4/BufferTabs.nvim',
    dependencies = {
        'nvim-tree/nvim-web-devicons', -- optional
    },
    lazy = false,
    config = function()
        require('buffertabs').setup({
            -- config
        })
    end
},
```

</details>

## Toggle

```lua
-- 1) lua code
require('buffertabs').toggle()

-- 2) command
:BufferTabsToggle
```

## Setup

```lua
require('buffertabs').setup()
```

<details>
<summary> Default configuration </summary>

```lua
require('buffertabs').setup({
    ---@type 'none'|'single'|'double'|'rounded'|'solid'|'shadow'|table
    border = 'rounded',

    ---@type boolean
    icons = true,

    ---@type string
    hl_group = 'Keyword',

    ---@type string
    hl_group_inactive = 'Comment',

    ---@type table<string>
    exclude = { 'NvimTree', 'help', 'dashboard', 'lir', 'alpha' },

    ---@type 'row'|'column'
    display = 'row',

    ---@type 'left'|'right'|'center'
    horizontal = 'center',

    ---@type 'top'|'bottom'|'center'
    vertical = 'top',
})
```

</details>


## File order
```
|   LICENSE
|   README.md
|
+---lua
|   \---buffertabs
|           init.lua
|           utils.lua
|
\---plugin
        buffertabs.lua
```


## Contributors

<table>
    <tbody>
        <tr>
            <td align="center" valign="top" width="14.28%">
                <a href="https://github.com/tomiis4">
                <img src="https://avatars.githubusercontent.com/u/87276646?v=4" width="50px;" alt="tomiis4"/><br />
                <sub><b> tomiis4 </b></sub><br />
                <sup> founder </sup>
                </a><br/>
            </td>
        </tr>
    </tbody>
</table>
