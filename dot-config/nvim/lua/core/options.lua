-- SPDX-License-Identifier: MIT
-- Vim options and diagnostic display. Leaders are set in init.lua (before
-- anything else can map).

local opt = vim.opt

-- ---------------------------------------------------------------------
-- Diagnostics
-- ---------------------------------------------------------------------
vim.diagnostic.config({
  virtual_text = true,
  virtual_lines = false,
  underline = true,
  update_in_insert = false, -- don't re-render diagnostics on every keystroke
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '',
      [vim.diagnostic.severity.WARN] = '',
      [vim.diagnostic.severity.INFO] = '',
      [vim.diagnostic.severity.HINT] = '󰌵',
    },
  },
})

-- ---------------------------------------------------------------------
-- General UX
-- ---------------------------------------------------------------------
opt.autowrite = true -- auto-write on buffer switch
opt.confirm = true -- confirm save on exit
opt.mouse = 'a'
opt.mousescroll = 'ver:3,hor:6'
opt.swapfile = false
opt.undofile = true -- persistent undo
opt.undolevels = 10000
opt.clipboard = 'unnamedplus'
opt.updatetime = 200 -- CursorHold delay
opt.inccommand = 'nosplit' -- live :substitute preview
opt.timeoutlen = 300
opt.sessionoptions = { 'buffers', 'curdir', 'tabpages', 'winsize' }
opt.wildmode = 'longest:full,full'
opt.fileencodings = 'ucs-bom,utf-8,sjis,default'
opt.maxmempattern = 5000
opt.redrawtime = 10000
vim.g.markdown_recommended_style = 0

-- ---------------------------------------------------------------------
-- UI
-- ---------------------------------------------------------------------
opt.termguicolors = true
opt.winborder = 'rounded'
opt.number = true
opt.relativenumber = true
opt.cursorline = false
opt.signcolumn = 'yes'
opt.pumblend = 10
opt.pumheight = 10
opt.cmdheight = 0
opt.winminwidth = 5
opt.scrolloff = 4
opt.sidescrolloff = 8
opt.sidescroll = 1
opt.wrap = false
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = 'screen'
opt.conceallevel = 2

-- Filetypes where the dynamic colorcolumn is never shown (prose / UI panels).
vim.g.colorcolumn_skip_filetypes = { 'markdown', 'asciidoc', 'asciidoctor' }

-- Project-root markers, nearest-ancestor wins. Session-wide knob consumed by
-- the mini.starter cd-on-open behavior (and any future root detection);
-- override at runtime with :lua vim.g.root_markers = { ... } when a marker
-- misbehaves for a given project layout.
-- stylua: ignore
vim.g.root_markers = {
  '.git', '.hg',                       -- VCS
  'pyproject.toml',                    -- python
  'package.json',                      -- js/ts
  'Cargo.toml',                        -- rust
  'go.mod',                            -- go
  'build.zig',                         -- zig
  'compile_commands.json',             -- c/cpp
  '.stylua.toml', 'stylua.toml',       -- lua
  '.luarc.json',                       -- lua (lsp workspace)
}

-- ---------------------------------------------------------------------
-- Indentation
-- ---------------------------------------------------------------------
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.shiftround = true
opt.smartindent = true

-- Whitespace hints
opt.list = true
opt.listchars = { tab = '▸ ', trail = '·', nbsp = '␣' }

-- ---------------------------------------------------------------------
-- Searching
-- ---------------------------------------------------------------------
opt.ignorecase = true
opt.smartcase = true
opt.grepprg = 'rg --vimgrep'
opt.grepformat = '%f:%l:%c:%m'

-- ---------------------------------------------------------------------
-- Completion / messages
-- ---------------------------------------------------------------------
opt.completeopt = { 'menu', 'menuone', 'noselect', 'noinsert' }
opt.shortmess:append({
  W = true, -- no [written]
  I = true, -- no intro
  c = true, -- no ins-completion messages
  C = true, -- reduce completion source messages
  F = true, -- no file-info prompts
})
