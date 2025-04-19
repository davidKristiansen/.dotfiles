-- Set <leader> keys
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Diagnostic display config
vim.diagnostic.config({
  virtual_text = {
    spacing = 2,
    source = "if_many",  -- optional: shows source only when there are multiple
  },
  virtual_lines = false, -- disable inline virtual lines
  signs = true,          -- still show gutter signs
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})


local opt = vim.opt
local cmd = vim.cmd

-- General
opt.autowrite = true          -- Auto-write on buffer switch
opt.confirm = true            -- Confirm to save changes before exiting
opt.mouse = "a"               -- Enable mouse
opt.swapfile = false          -- Disable swapfile
opt.undofile = true           -- Persistent undo
opt.undolevels = 10000
opt.clipboard = "unnamedplus" -- System clipboard integration
opt.updatetime = 200          -- CursorHold delay

-- UI
opt.number = true         -- Show line numbers
opt.relativenumber = true -- Relative line numbers
opt.cursorline = true     -- Highlight current line
opt.signcolumn = "yes"    -- Always show signcolumn
opt.termguicolors = true  -- True color support
opt.pumblend = 10         -- Popup menu transparency
opt.pumheight = 10        -- Max items in completion menu
opt.cmdheight = 0         -- Minimal command line height
opt.laststatus = 3        -- Global statusline
opt.winminwidth = 5       -- Minimum window width
opt.scrolloff = 4         -- Vertical scroll context
opt.sidescrolloff = 8     -- Horizontal scroll context
opt.wrap = false          -- Disable line wrap
opt.splitright = true     -- Horizontal splits open to the right
opt.splitbelow = true     -- Vertical splits open below

-- Indentation
opt.expandtab = true   -- Use spaces, not tabs
opt.tabstop = 2        -- Tabs = 2 spaces
opt.shiftwidth = 2     -- Indent width = 2
opt.softtabstop = 2    -- Tab key = 2 spaces
opt.shiftround = true  -- Round indent to multiple of shiftwidth
opt.smartindent = true -- Smart indenting

-- Listchars (whitespace hints)
opt.list = true
opt.listchars = { tab = "▸ ", trail = "·", nbsp = "␣" }

-- Searching
opt.ignorecase = true        -- Ignore case in search...
opt.smartcase = true         -- ...unless capital letters present
opt.grepprg = "rg --vimgrep" -- Use ripgrep for :grep
opt.grepformat = "%f:%l:%c:%m"

-- Completion
opt.completeopt = "menu,menuone,noselect" -- Better completion UX

-- Behavior
opt.inccommand = "nosplit"         -- Live preview for substitute
opt.timeoutlen = 300               -- Keybind timeout
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize" }
opt.wildmode = "longest:full,full" -- Tab completion mode

-- Spelling
opt.spell = false
opt.spelllang = { "en_us" }

-- Formatting
opt.formatoptions = "jcroqlnt" -- Text formatting behavior

-- Short messages: make command-line output less intrusive
opt.shortmess:append({
  W = true, -- Don't show [written] after :write
  I = true, -- Don't show the intro message on startup
  c = true, -- Don't show completion messages
  C = true, -- Don't show ins-completion-menu messages (nvim 0.9+)
  F = true, -- Don't prompt "Press ENTER" after messages like :y
})

-- Neovim 0.9+ niceties
if vim.fn.has("nvim-0.9.0") == 1 then
  opt.splitkeep = "screen"
  opt.shortmess:append({ C = true })
end

-- Encoding & files
opt.fileencodings = "ucs-bom,utf-8,sjis,default"

-- Markdown
vim.g.markdown_recommended_style = 0 -- Don't mess with markdown indent

-- Undercurl (only if terminal likely supports it)
if vim.fn.has("termguicolors") == 1 then
  cmd([[let &t_Cs = "\e[4:3m"]])
  cmd([[let &t_Ce = "\e[4:0m"]])
end
