# Neovim Configuration

Modern, performant Neovim configuration using lazy.nvim and native LSP.

## Installation

### Prerequisites

**Required:**
- Neovim >= 0.11.0
- Git
- A C compiler (gcc/clang) for Treesitter
- Node.js (for some LSP servers)
- ripgrep (`rg`) - for Telescope live_grep

**Optional but recommended:**
- fd - faster file finding for Telescope
- A Nerd Font - for icons (nvim-web-devicons)

### Normal User Installation

```bash
# 1. Backup existing config (if any)
mv ~/.config/nvim ~/.config/nvim.backup 2>/dev/null || true

# 2. Clone or copy this config
cp -r /path/to/nvim ~/.config/nvim

# 3. Start Neovim - plugins will auto-install
nvim

# 4. After plugins install, run health check
:checkhealth

# 5. Install LSP servers (optional - they install on-demand)
:Mason
```

### Root User Installation

For root user, symlink to your user config with safety overrides:

```bash
# As root:
sudo mkdir -p /root/.config
sudo ln -s /home/YOUR_USERNAME/.config/nvim /root/.config/nvim

# The config automatically detects root and disables persistent files
# (no undo history, no shada, etc.) for security
```

### Server Installation

#### Option 1: Full Config (Recommended)
```bash
# Same as normal user installation
# UI plugins are lazy-loaded so minimal performance impact
cp -r /path/to/nvim ~/.config/nvim
nvim
```

#### Option 2: Minimal Mode
```bash
# Copy config
cp -r /path/to/nvim ~/.config/nvim

# Edit ~/.config/nvim/init.lua and set:
# vim.g.minimal_mode = true

# This skips UI plugins (nvim-tree, lualine, themes, etc.)
```

#### Option 3: Server-specific config
```bash
# Create minimal config on server
mkdir -p ~/.config/nvim/lua/plugins

# Copy only:
# - init.lua (base settings)
# - lua/plugins/lsp.lua
# - lua/plugins/editor.lua (without Telescope if no ripgrep)
# - lua/user/ directory

# Skip: ui.lua, git.lua, coding.lua (except treesitter basics)
```

## Configuration Structure

```
~/.config/nvim/
├── init.lua                    # Main entry point, settings, keymaps
├── lazy-lock.json              # Plugin version lock file
├── lua/
│   ├── config/
│   │   └── project.lua         # Project-specific overrides
│   ├── plugins/
│   │   ├── init.lua            # Plugin loader (imports all modules)
│   │   ├── ui.lua              # UI plugins (tree, statusline, theme)
│   │   ├── lsp.lua             # LSP servers and Mason
│   │   ├── editor.lua          # Core editing (cmp, telescope, sessions)
│   │   ├── git.lua             # Git integration (gitsigns, diffview)
│   │   └── coding.lua          # Language-specific (treesitter, etc)
│   └── user/
│       ├── tabnames.lua        # Custom tab naming
│       └── treepath.lua        # Tree navigation helpers
└── README.md                   # This file
```

## Key Bindings

### Leader Key
- Leader: `,`
- LocalLeader: `_`

### File Operations
- `<leader>w` - Save file
- `<leader>q` - Quit
- `<leader>Q` - Quit all
- `<C-s>` - Save (normal and insert mode)
- `<leader>y` - Yank entire buffer to clipboard

### Fuzzy Finding (Telescope)
- `<leader>ff` - Find files
- `<leader>fg` - Live grep (search in files)
- `<leader>fb` - List buffers
- `<leader>fh` - Search help tags
- `<leader>fr` - Recent files

### File Tree (NvimTree)
- `<F4>` - Toggle file tree
- `o` - Open file/folder
- `C` - Change root to node
- `u` - Change root to parent

### Window/Split Navigation
- `<C-h/j/k/l>` - Move between splits
- `<leader>-` - Horizontal split
- `<leader>\` - Vertical split

### Tabs
- `<leader>t` - New tab
- `<leader>T` - Close tab
- `:TabRename <name>` - Rename current tab

### Buffers
- `<M-j>` - Next buffer
- `<M-k>` - Previous buffer
- `<F6>` - Toggle to alternate buffer

### LSP & Diagnostics
- `K` - Hover documentation
- `gl` or `<leader>d` - Show diagnostics float
- `gd` - Go to definition
- `gi` - Go to implementation
- `gD` - Go to declaration
- `gr` - Go to file (LS-aware)
- `gr` - Find references
- `<leader>rn` - Rename symbol
- `<leader>ca` - Code actions
- `<leader>F` - Format file with LSP

### Git
- `]g` - Next git hunk
- `[g` - Previous git hunk
- `<leader>gb` - Git blame line
- `<leader>gs` - Stage hunk
- `<leader>gr` - Reset hunk
- `<leader>gd` - Open diff view
- `<leader>gh` - File history

### Code Editing
- `<leader>c` - Comment line (normal) or selection (visual)
- `gcc` - Comment line toggle
- `gc` - Comment operator
- `ga` - Align (visual mode)
- `ys`, `ds`, `cs` - Surround operations

### Code Navigation
- `<F8>` - Toggle code outline (Aerial)
- `:TSPlaygroundToggle` - View syntax tree

### Sessions
- `<leader>ss` - Restore session
- `<leader>sl` - Restore last session
- `<leader>sd` - Don't save session on exit

### Formatting
- `<leader>f` - Convert 2 spaces to tabs + single to double quotes
- `<leader>2f`, `<leader>4f`, `<leader>8f` - Convert N spaces to tabs
- `<F1>` - Wrap line at 80 chars (markdown)
- `<F2>` - Toggle line wrap

### Markdown
- `<Space>` - Toggle checkbox (in markdown files)

### Other
- `<leader><space>` - Clear search highlight
- `<` / `>` - Indent/dedent (keeps selection in visual)
- `j/k` with wrapped lines - Move by display lines

## Plugin List

### UI & Navigation

**nvim-tree.lua**
- What: File explorer sidebar
- Why: Modern NERDTree replacement with git integration
- Usage: `<F4>` to toggle, `o` to open, `C` to cd into folder

**telescope.nvim**
- What: Fuzzy finder for files, grep, buffers, etc.
- Why: Essential for fast navigation in projects
- Usage: `<leader>ff` files, `<leader>fg` grep, `<leader>fb` buffers

**lualine.nvim**
- What: Fast statusline
- Why: Shows file info, git branch, LSP status
- Usage: Automatic, always visible at bottom

**onedark.nvim**
- What: Dark color scheme
- Why: Easy on the eyes, good contrast
- Usage: Loaded automatically

**nvim-notify**
- What: Notification manager
- Why: Non-intrusive notifications
- Usage: Automatic for all vim.notify() calls

**nvim-colorizer.lua**
- What: Highlights color codes (#ff0000, etc.)
- Why: Visual feedback for colors in CSS/code
- Usage: Automatic in supported files

### LSP & Completion

**mason.nvim**
- What: LSP/DAP/Linter installer
- Why: Easy management of language servers
- Usage: `:Mason` to open, auto-installs configured servers

**nvim-lspconfig**
- What: LSP client configurations
- Why: Native Neovim LSP support
- Usage: Automatic, provides completions, diagnostics, goto definition

**nvim-cmp**
- What: Autocompletion engine
- Why: Fast, extensible completion
- Usage: `<Tab>` next, `<S-Tab>` prev, `<CR>` confirm, `<C-Space>` trigger

**LuaSnip**
- What: Snippet engine
- Why: Code snippets support
- Usage: Integrated with nvim-cmp

**typescript-tools.nvim**
- What: Enhanced TypeScript LSP
- Why: Faster than ts_ls, better code actions
- Usage: Automatic for TS/JS files

### Editing

**nvim-autopairs**
- What: Auto-close brackets, quotes
- Why: Less typing, maintains balance
- Usage: Automatic, type `(` get `(|)` with cursor in middle

**nvim-surround**
- What: Manipulate surrounding characters
- Why: Quickly change/delete quotes, brackets, tags
- Usage: `ysiw"` surround word with quotes, `cs"'` change " to ', `ds"` delete "

**Comment.nvim**
- What: Smart commenting
- Why: Language-aware comment toggle
- Usage: `gcc` toggle line, `gc` in visual, `<leader>c`

**vim-abolish**
- What: Smart substitution and case coercion
- Why: Case-preserving search/replace
- Usage: `:%S/old/new/g` for smart replace

**vim-easy-align**
- What: Text alignment
- Why: Align columns, assignments, etc.
- Usage: Select text, `ga` then delimiter (e.g., `ga=`)

**marks.nvim**
- What: Better mark visualization
- Why: See marks in sign column
- Usage: `m{a-z}` set mark, `'{a-z}` jump to mark, `dm{a-z}` delete

**persistence.nvim**
- What: Session management
- Why: Save/restore workspace state
- Usage: `<leader>ss` restore, auto-saves on exit

**editorconfig-vim**
- What: EditorConfig support
- Why: Respect project coding standards
- Usage: Automatic, reads `.editorconfig`

### Git

**gitsigns.nvim**
- What: Git gutter signs, hunk management
- Why: See changes inline, stage/reset hunks
- Usage: `]g` next hunk, `[g` prev, `<leader>gb` blame

**diffview.nvim**
- What: Git diff viewer
- Why: Better visualization than fugitive
- Usage: `<leader>gd` open diff, `<leader>gh` file history

### Language Support

**nvim-treesitter**
- What: Advanced syntax highlighting, AST-based
- Why: Better highlighting, text objects, indentation
- Usage: Automatic, install languages with `:TSInstall <lang>`

**playground**
- What: Treesitter AST viewer
- Why: Debugging syntax highlighting, learning
- Usage: `:TSPlaygroundToggle`

**aerial.nvim**
- What: Code outline sidebar
- Why: Navigate by functions/classes
- Usage: `<F8>` toggle outline

**markdown-checkbox.nvim**
- What: Markdown checkbox toggler
- Why: Quickly toggle task list items
- Usage: `<Space>` on checkbox line

**mdx.nvim**
- What: MDX file support
- Why: Syntax highlighting for MDX
- Usage: Automatic for .mdx files

**vim-slim**
- What: Slim template syntax
- Why: Support for Slim HTML templates
- Usage: Automatic for .slim files

## Customization

### Add a Plugin

Edit `~/.config/nvim/lua/plugins/<category>.lua`:

```lua
{
  "user/plugin-name",
  event = "VeryLazy", -- or cmd, keys, ft, etc.
  config = function()
    require("plugin-name").setup({
      -- options
    })
  end,
}
```

Then run `:Lazy sync`

### Change Color Scheme

Edit `lua/plugins/ui.lua`, replace onedark.nvim with your theme.

### Disable Plugins for Server

Edit `init.lua`, set:
```lua
vim.g.minimal_mode = true
```

This skips all UI plugins (defined in `lua/plugins/ui.lua`).

### LSP Environment Toggles

Set env vars before launching Neovim:

- `NVIM_LSP_DISABLE=1` - skip loading all LSP plugins/config (fastest for servers)

### Override Settings per Project

Create `.nvim.lua` in project root:
```lua
vim.opt.tabstop = 4
vim.opt.expandtab = true
```

Or use `lua/config/project.lua` for another config directory.

## Troubleshooting

### Slow Performance
1. Check `:Lazy profile` for slow plugins
2. Disable unused LSP servers in `lua/plugins/lsp.lua`
3. Run `:checkhealth` for issues

### LSP Not Working
1. Check `:LspInfo` for attached servers
2. Install server with `:Mason`
3. Check `:checkhealth lsp`

### Treesitter Errors
1. Update: `:TSUpdate`
2. Reinstall: `:TSInstall! <language>`
3. Check `:checkhealth nvim-treesitter`

### Telescope Errors
1. Install ripgrep: `sudo pacman -S ripgrep` (Arch) or equivalent
2. Check `:checkhealth telescope`

### "No such file" on nvim-tree
Issue: Plugin not loaded yet
Fix: Press `<F4>` again after Lazy finishes loading

## Migration from nvim

```bash
# 1. Backup current config
mv ~/.config/nvim ~/.config/nvim.backup

# 2. Move to standard location
mv ~/.config/nvim.backup ~/.config/nvim

# 3. Everything should work - paths are now standard
```

## Performance Tips

1. **Lazy loading is already configured** - plugins load on-demand
2. **Disable unused LSP servers** - edit `lua/plugins/lsp.lua`, remove unwanted servers
3. **For very large files** - Treesitter auto-disables for files >100KB
4. **Root user** - Auto-disables persistent files for security/speed
5. **Server mode** - Set `vim.g.minimal_mode = true` to skip UI plugins

## Credits

- Based on modern Neovim best practices
- Uses lazy.nvim for plugin management
- Optimized for performance and minimal startup time
- Configuration structure inspired by LazyVim and NvChad
