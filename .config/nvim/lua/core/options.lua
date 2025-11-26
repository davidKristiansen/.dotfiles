-- SPDX-License-Identifier: MIT

-- ---------------------------------------------------------------------
-- Leaders (must be early)
-- ---------------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- ---------------------------------------------------------------------
-- Diagnostics (merge general + signs)
-- ---------------------------------------------------------------------
local diag_base = {
  virtual_text     = true,
  -- virtual_text   = { spacing = 2, source = "if_many", current_line = false },
  virtual_lines    = false, -- { current_line = true },
  signs            = true,
  underline        = true,
  update_in_insert = true,
  severity_sort    = true,
}


local diag_signs = {
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN]  = "",
      [vim.diagnostic.severity.INFO]  = "",
      [vim.diagnostic.severity.HINT]  = "󰌵",
    },
  },
}

vim.diagnostic.config(vim.tbl_deep_extend("force", diag_base, diag_signs))

-- ---------------------------------------------------------------------
-- Options (unified)
-- ---------------------------------------------------------------------
local o                          = vim.o
local opt                        = vim.opt
local cmd                        = vim.cmd

-- General UX
opt.autowrite                    = true  -- Auto-write on buffer switch
opt.confirm                      = true  -- Confirm save on exit
opt.mouse                        = "a"   -- Mouse everywhere
opt.swapfile                     = false -- No swap
opt.undofile                     = true  -- Persistent undo
opt.undolevels                   = 10000
opt.clipboard                    = "unnamedplus"
opt.updatetime                   = 200       -- CursorHold delay
opt.inccommand                   = "nosplit" -- Live :substitute preview
opt.timeoutlen                   = 300
opt.sessionoptions               = { "buffers", "curdir", "tabpages", "winsize" }
opt.wildmode                     = "longest:full,full"
opt.fileencodings                = "ucs-bom,utf-8,sjis,default"
vim.g.markdown_recommended_style = 0

-- UI
opt.termguicolors                = true
opt.winborder                    = "rounded"
opt.number                       = true
opt.relativenumber               = true
opt.cursorline                   = false
opt.signcolumn                   = "yes"
opt.pumblend                     = 10
opt.pumheight                    = 10
opt.cmdheight                    = 0 -- Minimal cmdline (0 on 0.9+)
opt.winminwidth                  = 5
opt.scrolloff                    = 4
opt.sidescrolloff                = 8
opt.wrap                         = false
opt.splitright                   = true
opt.splitbelow                   = true
opt.conceallevel                 = 2
-- Indentation
opt.expandtab                    = true
opt.tabstop                      = 2
opt.shiftwidth                   = 2
opt.softtabstop                  = 2
opt.shiftround                   = true
opt.smartindent                  = true

-- Filetype specific settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  callback = function()
    vim.opt.tabstop = 4
    vim.opt.shiftwidth = 4
    vim.opt.softtabstop = 4
  end,
})

-- Whitespace hints
opt.list                         = true
opt.listchars                    = { tab = "▸ ", trail = "·", nbsp = "␣" }

-- Searching
opt.ignorecase                   = true
opt.smartcase                    = true
opt.grepprg                      = "rg --vimgrep"
opt.grepformat                   = "%f:%l:%c:%m"

-- Completion (append without clobbering)
opt.completeopt                  = { "menu", "menuone", "noselect" } -- base
opt.completeopt:append({ "noinsert" })                               -- tweak if desired

-- Short messages: extend instead of overwrite
opt.shortmess:append({
  W = true, -- no [written]
  I = true, -- no intro
  c = true, -- no ins-completion messages
  C = true, -- (nvim ≥0.9) reduce extra messages
  F = true, -- skip "Press ENTER" after msgs like :y
})

-- 0.9 niceties
if vim.fn.has("nvim-0.9.0") == 1 then
  opt.splitkeep = "screen"
end

-- Undercurl (if likely supported)
if vim.fn.has("termguicolors") == 1 then
  cmd([[let &t_Cs = "\e[4:3m"]])
  cmd([[let &t_Ce = "\e[4:0m"]])
end


vim.g.bullets_delete_last_bullet_if_empty = 1
