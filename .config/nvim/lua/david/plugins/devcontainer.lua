return {
  -- {
  --   'https://codeberg.org/esensar/nvim-dev-container',
  --   event = "VeryLazy",
  --   dependencies = 'nvim-treesitter/nvim-treesitter',
  --   opts = {
  --     autocommands = {
  --       -- can be set to true to automatically start containers when devcontainer.json is available
  --       init = false,
  --       -- can be set to true to automatically remove any started containers and any built images when exiting vim
  --       clean = true,
  --       -- can be set to true to automatically restart containers when devcontainer.json file is updated
  --       update = true,
  --     },
  --     attach_mounts = {
  --       neovim_config = {
  --         -- enables mounting local config to /root/.config/nvim in container
  --         enabled = true,
  --         -- makes mount readonly in container
  --         options = { "readonly" }
  --       },
  --       neovim_data = {
  --         -- enables mounting local data to /root/.local/share/nvim in container
  --         enabled = true,
  --         -- no options by default
  --         options = {}
  --       },
  --       -- Only useful if using neovim 0.8.0+
  --       neovim_state = {
  --         -- enables mounting local state to /root/.local/state/nvim in container
  --         enabled = true,
  --         -- no options by default
  --         options = {}
  --       },
  --     },
  --   }
  -- },
  {
    "arnaupv/nvim-devcontainer-cli",
    opts = {
      -- By default, if no extra config is added, following nvim_dotfiles are
      -- installed: "https://github.com/LazyVim/starter"
      -- This is an example for configuring other nvim_dotfiles inside the docker container
      nvim_dotfiles_repo = "https://github.com/davidKristiansen/dotfiles.git",
      nvim_dotfiles_install_command = "cd ~/dotfiles/ && ./devcontainer_install.sh",
      -- In case you want to change the way the devenvironment is setup, you can also provide your own setup
      -- setup_environment_repo = "https://github.com/arnaupv/setup-environment",
      -- setup_environment_install_command = "./install.sh -p 'nvim stow zsh'",
    },
    keys = {
      -- stylua: ignore
      {
        "<leader>cdu",
        ":DevcontainerUp<cr>",
        desc = "Up the DevContainer",
      },
      {
        "<leader>cdc",
        ":DevcontainerConnect<cr>",
        desc = "Connect to DevContainer",
      },
    }
  },
}
