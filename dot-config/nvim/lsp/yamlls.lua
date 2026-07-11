-- lsp/yamlls.lua
-- SPDX-License-Identifier: MIT
return {
  settings = {
    yaml = {
      keyOrdering = false,
      customTags = {
        '!include scalar',
        '!include_dir_list scalar',
        '!include_dir_named scalar',
        '!include_dir_merge_list scalar',
        '!include_dir_merge_named scalar',
        '!secret scalar',
        '!env_var scalar',
        '!input scalar',
        '!lambda scalar',
      },
    },
  },
}
