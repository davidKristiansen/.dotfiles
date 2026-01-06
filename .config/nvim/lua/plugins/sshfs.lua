vim.pack.add({
  { src = "https://github.com/uhs-robert/sshfs.nvim" },
}, { confirm = false })


require("sshfs").setup({
  host_paths = {
    ["EUDC2"] = "/srv/traefik"
  },
})
