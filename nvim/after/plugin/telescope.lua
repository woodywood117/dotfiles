local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fp', builtin.git_files, { desc = 'Git files' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Search Buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Search Help tags' })
