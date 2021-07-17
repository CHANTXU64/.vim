set guicursor=
set noruler

lua << EOF
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    disable = { "cpp", "lua" },
  },
  textobjects = { enable = true },
}
EOF

