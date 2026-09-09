-- SPDX-License-Identifier: MIT
-- nvim-hlslens: show the position and the count of the search matches next to
-- them (loaded on the first search motion or on the first cmdline).

-- Run a search motion with its count, then draw the lens. `keys` needs a
-- function, not the rhs string from the README: a stub replays a string through
-- feedkeys, which loses the count of the first press.
local function lens(motion)
  return function()
    local ok, err = pcall(vim.cmd, ('normal! %d%s'):format(vim.v.count1, motion))
    if not ok then
      vim.api.nvim_echo({ { tostring(err):gsub('^Vim:', ''), 'ErrorMsg' } }, true, {})
      return
    end
    require('hlslens').start()
  end
end

require('utils.lazy').add({
  src = 'https://github.com/kevinhwang91/nvim-hlslens',
  main = 'hlslens',
  opts = {},
  -- The cmdline trigger covers `/` and `?`, where the lens follows incsearch.
  event = 'CmdlineEnter',
  keys = {
    { 'n', lens('n'), desc = 'Next search match' },
    { 'N', lens('N'), desc = 'Previous search match' },
    { '*', lens('*'), desc = 'Search the word under the cursor forward' },
    { '#', lens('#'), desc = 'Search the word under the cursor backward' },
    { 'g*', lens('g*'), desc = 'Search the partial word under the cursor forward' },
    { 'g#', lens('g#'), desc = 'Search the partial word under the cursor backward' },
    { '<leader>l', '<cmd>nohlsearch<cr>', desc = 'Clear the search highlight' },
  },
})
