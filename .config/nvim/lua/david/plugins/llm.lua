return {
  {
    "robitx/gp.nvim",
    dependencies = {
      "folke/which-key.nvim",
    },
    opts = {
      providers = {
        openai = {
          disable = false,
          endpoint = "https://api.openai.com/v1/chat/completions",
        },
      },
      cmd = {
        "CodeReview",
      },
      hooks = {
        -- example of usig enew as a function specifying type for the new buffer
        CodeReview = function(gp, params)
          local template = "I have the following code from {{filename}}:\n\n"
              .. "```{{filetype}}\n{{selection}}\n```\n\n"
              .. "Please analyze for code smells and suggest improvements."
          local agent = gp.get_chat_agent()
          gp.Prompt(params, gp.Target.enew("markdown"), agent, template)
        end,
      },
    },
    init = function()
      require("which-key").add({
        { mode = { "v", "n", "i" }, "<C-g>",  group = "LLM" },
        { mode = { "v", "n", "i" }, "<C-g>g", group = "generate into new .." },
        { mode = { "v", "n", "i" }, "<C-g>w", group = "Whisper" },
      })
    end,
    keys = {
      { mode = { "v" },      "<C-g><C-t>", ":<C-u>'<,'>GpChatNew tabnew<cr>", desc = "ChatNew tabnew" },
      { mode = { "v" },      "<C-g><C-v>", ":<C-u>'<,'>GpChatNew vsplit<cr>", desc = "ChatNew vsplit" },
      { mode = { "v" },      "<C-g><C-x>", ":<C-u>'<,'>GpChatNew split<cr>",  desc = "ChatNew split" },
      { mode = { "v" },      "<C-g>a",     ":<C-u>'<,'>GpAppend<cr>",         desc = "Visual Append (after)" },
      { mode = { "v" },      "<C-g>b",     ":<C-u>'<,'>GpPrepend<cr>",        desc = "Visual Prepend (before)" },
      { mode = { "v" },      "<C-g>c",     ":<C-u>'<,'>GpChatNew<cr>",        desc = "Visual Chat New" },
      { mode = { "v" },      "<C-g>ge",    ":<C-u>'<,'>GpEnew<cr>",           desc = "Visual GpEnew" },
      { mode = { "v" },      "<C-g>gn",    ":<C-u>'<,'>GpNew<cr>",            desc = "Visual GpNew" },
      { mode = { "v" },      "<C-g>gp",    ":<C-u>'<,'>GpPopup<cr>",          desc = "Visual Popup" },
      { mode = { "v" },      "<C-g>gt",    ":<C-u>'<,'>GpTabnew<cr>",         desc = "Visual GpTabnew" },
      { mode = { "v" },      "<C-g>gv",    ":<C-u>'<,'>GpVnew<cr>",           desc = "Visual GpVnew" },
      { mode = { "v" },      "<C-g>i",     ":<C-u>'<,'>GpImplement<cr>",      desc = "Implement selection" },
      { mode = { "v" },      "<C-g>n",     "<cmd>GpNextAgent<cr>",            desc = "Next Agent" },
      { mode = { "v" },      "<C-g>p",     ":<C-u>'<,'>GpChatPaste<cr>",      desc = "Visual Chat Paste" },
      { mode = { "v" },      "<C-g>r",     ":<C-u>'<,'>GpRewrite<cr>",        desc = "Visual Rewrite" },
      { mode = { "v" },      "<C-g>s",     "<cmd>GpStop<cr>",                 desc = "GpStop" },
      { mode = { "v" },      "<C-g>t",     ":<C-u>'<,'>GpChatToggle<cr>",     desc = "Visual Toggle Chat" },
      { mode = { "v" },      "<C-g>wa",    ":<C-u>'<,'>GpWhisperAppend<cr>",  desc = "Whisper Append" },
      { mode = { "v" },      "<C-g>wb",    ":<C-u>'<,'>GpWhisperPrepend<cr>", desc = "Whisper Prepend" },
      { mode = { "v" },      "<C-g>we",    ":<C-u>'<,'>GpWhisperEnew<cr>",    desc = "Whisper Enew" },
      { mode = { "v" },      "<C-g>wn",    ":<C-u>'<,'>GpWhisperNew<cr>",     desc = "Whisper New" },
      { mode = { "v" },      "<C-g>wp",    ":<C-u>'<,'>GpWhisperPopup<cr>",   desc = "Whisper Popup" },
      { mode = { "v" },      "<C-g>wr",    ":<C-u>'<,'>GpWhisperRewrite<cr>", desc = "Whisper Rewrite" },
      { mode = { "v" },      "<C-g>wt",    ":<C-u>'<,'>GpWhisperTabnew<cr>",  desc = "Whisper Tabnew" },
      { mode = { "v" },      "<C-g>wv",    ":<C-u>'<,'>GpWhisperVnew<cr>",    desc = "Whisper Vnew" },
      { mode = { "v" },      "<C-g>ww",    ":<C-u>'<,'>GpWhisper<cr>",        desc = "Whisper" },
      { mode = { "v" },      "<C-g>x",     ":<C-u>'<,'>GpContext<cr>",        desc = "Visual GpContext" },
      { mode = { "n", "i" }, "<C-g><C-t>", "<cmd>GpChatNew tabnew<cr>",       desc = "New Chat tabnew" },
      { mode = { "n", "i" }, "<C-g><C-v>", "<cmd>GpChatNew vsplit<cr>",       desc = "New Chat vsplit" },
      { mode = { "n", "i" }, "<C-g><C-x>", "<cmd>GpChatNew split<cr>",        desc = "New Chat split" },
      { mode = { "n", "i" }, "<C-g>a",     "<cmd>GpAppend<cr>",               desc = "Append (after)" },
      { mode = { "n", "i" }, "<C-g>b",     "<cmd>GpPrepend<cr>",              desc = "Prepend (before)" },
      { mode = { "n", "i" }, "<C-g>c",     "<cmd>GpChatNew<cr>",              desc = "New Chat" },
      { mode = { "n", "i" }, "<C-g>f",     "<cmd>GpChatFinder<cr>",           desc = "Chat Finder" },
      { mode = { "n", "i" }, "<C-g>ge",    "<cmd>GpEnew<cr>",                 desc = "GpEnew" },
      { mode = { "n", "i" }, "<C-g>gn",    "<cmd>GpNew<cr>",                  desc = "GpNew" },
      { mode = { "n", "i" }, "<C-g>gp",    "<cmd>GpPopup<cr>",                desc = "Popup" },
      { mode = { "n", "i" }, "<C-g>gt",    "<cmd>GpTabnew<cr>",               desc = "GpTabnew" },
      { mode = { "n", "i" }, "<C-g>gv",    "<cmd>GpVnew<cr>",                 desc = "GpVnew" },
      { mode = { "n", "i" }, "<C-g>n",     "<cmd>GpNextAgent<cr>",            desc = "Next Agent" },
      { mode = { "n", "i" }, "<C-g>r",     "<cmd>GpRewrite<cr>",              desc = "Inline Rewrite" },
      { mode = { "n", "i" }, "<C-g>s",     "<cmd>GpStop<cr>",                 desc = "GpStop" },
      { mode = { "n", "i" }, "<C-g>t",     "<cmd>GpChatToggle<cr>",           desc = "Toggle Chat" },
      { mode = { "n", "i" }, "<C-g>wa",    "<cmd>GpWhisperAppend<cr>",        desc = "Whisper Append (after)" },
      { mode = { "n", "i" }, "<C-g>wb",    "<cmd>GpWhisperPrepend<cr>",       desc = "Whisper Prepend (before)" },
      { mode = { "n", "i" }, "<C-g>we",    "<cmd>GpWhisperEnew<cr>",          desc = "Whisper Enew" },
      { mode = { "n", "i" }, "<C-g>wn",    "<cmd>GpWhisperNew<cr>",           desc = "Whisper New" },
      { mode = { "n", "i" }, "<C-g>wp",    "<cmd>GpWhisperPopup<cr>",         desc = "Whisper Popup" },
      { mode = { "n", "i" }, "<C-g>wr",    "<cmd>GpWhisperRewrite<cr>",       desc = "Whisper Inline Rewrite" },
      { mode = { "n", "i" }, "<C-g>wt",    "<cmd>GpWhisperTabnew<cr>",        desc = "Whisper Tabnew" },
      { mode = { "n", "i" }, "<C-g>wv",    "<cmd>GpWhisperVnew<cr>",          desc = "Whisper Vnew" },
      { mode = { "n", "i" }, "<C-g>ww",    "<cmd>GpWhisper<cr>",              desc = "Whisper" },
      { mode = { "n", "i" }, "<C-g>x",     "<cmd>GpContext<cr>",              desc = "Toggle GpContext" },
    }
  }
}
