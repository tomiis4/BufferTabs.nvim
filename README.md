<h1 align="center"> BufferTabs - Simple and Fancy tabline for NeoVim </h1>


<hr>

<h3 align="center"> <img src='https://media.discordapp.net/attachments/772927831441014847/1127980296537657456/image.png?ex=66a3bc83&is=66a26b03&hm=f8be87dc55e8a780d6482f0195ad945c4a5aa21317636039d4db689d1575b568&=&format=webp&quality=lossless&width=1177&height=662'> </h3>
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

    ---@type integer
    padding = 1,

    ---@type boolean
    icons = true,

    ---@type string
    modified = " ",

    ---@type string use hl Group or hex color
    hl_group = 'Keyword',

    ---@type string use hl Group or hex color
    hl_group_inactive = 'Comment',

    ---@type boolean
    show_all = false,

    ---@type 'row'|'column'
    display = 'row',

    ---@type 'left'|'right'|'center'
    horizontal = 'center',

    ---@type 'top'|'bottom'|'center'
    vertical = 'top',

    ---@type number in ms (recommend 2000)
    timeout = 0
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
            <td align="center" valign="top" width="14.28%">
                <a href="https://github.com/futsuuu">
                <img src="https://avatars.githubusercontent.com/u/105504350?v=4" width="50px;" alt="futsuuu"/><br />
                <sub><b> futsuuu </b></sub><br />
                </a><br />
            </td>
        </tr>
    </tbody>
</table>
