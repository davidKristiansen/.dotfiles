return {
  "RRethy/vim-illuminate",
  event = { "BufEnter" },
  config = function()
    require("illuminate").configure()
  end,
  -- init = function()
  --   vim.cmd [[hi illuminatedWord cterm=underline gui=underline]]
  -- end,
}
