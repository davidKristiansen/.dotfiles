-- SPDX-License-Identifier: MIT
-- Bitbucket Data Center pull request review. Self-contained module (no external
-- plugin). setup() only reads the git configuration of the checkout; it installs
-- :Bitbucket, the <leader>gc* keymaps and ]r/[r only inside a Bitbucket
-- checkout, and removes them again on a directory change to another host.
--
-- The endpoint comes out of git: an http remote carries it in its /scm/ path, an
-- ssh remote through `git config bitbucket.url <https://host/context>` or an
-- `insteadOf` rewrite. Credentials come from $BITBUCKET_TOKEN, from `token_file`,
-- from `git credential fill` (so ~/.git-credentials and every other credential
-- helper works), or from a prompt on first use.
require('utils.bitbucket').setup({
  -- hosts = { 'bitbucket%.example%.com' },
  -- token_file = '~/.config/bitbucket/token',
  -- curl_args = { '--cacert', '/etc/ssl/certs/ca-certificates.crt' },
})
