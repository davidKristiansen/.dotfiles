-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

-- Define MarkdownTOC command
vim.api.nvim_create_user_command("MarkdownTOC", function()
  if vim.bo.filetype ~= "markdown" then
    vim.notify("Not a markdown file", vim.log.levels.WARN)
    return
  end

  vim.cmd("write") -- save the file
  vim.fn.jobstart({ "markdown-toc", "-i", vim.fn.expand("%:p") }, {
    on_exit = function()
      vim.cmd("edit!") -- reload file
      vim.notify("Markdown TOC updated")
    end,
  })
end, { desc = "Update markdown table of contents using markdown-toc" })

-- Map <leader>cm in Markdown files to MarkdownTOC
vim.keymap.set("n", "<leader>cm", "<cmd>MarkdownTOC<CR>", {
  buffer = true,
  desc = "Update Markdown TOC",
})
