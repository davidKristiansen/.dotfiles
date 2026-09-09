-- SPDX-License-Identifier: MIT
-- tabout.nvim: jump out of a treesitter pair with <Tab> (loaded on first InsertEnter).
--
-- blink.cmp owns the insert-mode <Tab>/<S-Tab> chain, so tabout installs no key of
-- its own (empty tabkey/backwards_tabkey) and only exposes its API. The last step
-- of that chain in plugin/blink-cmp.lua calls it. Its built-in completion guard is
-- no help here: it tests pumvisible(), and the blink menu is a floating window.

require('utils.lazy').add({
  src = 'https://github.com/abecodes/tabout.nvim',
  event = 'InsertEnter',
  opts = {
    tabkey = '',
    backwards_tabkey = '',
    -- Insert a <Tab>, or dedent with <C-d>, when there is no pair to jump over.
    act_as_tab = true,
    act_as_shift_tab = true,
  },
})
