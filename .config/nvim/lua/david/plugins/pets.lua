return {
  {
    "giusgad/pets.nvim",
    cmd = {"PetsNew"},
    dependencies = { "MunifTanjim/nui.nvim", "giusgad/hologram.nvim" },
    opts = {},
    keys = {
      {
        "<leader>pd",
        "<cmd>PetsNewCustom rubber-duck yellow mcduckface<cr>",
        desc = "McDuckface"
      },
    }
  }
}
