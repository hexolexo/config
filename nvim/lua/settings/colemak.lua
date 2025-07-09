local keymap = vim.keymap.set
keymap('n', 'n', 'h', { noremap = true })
keymap('n', 'e', 'k', { noremap = true })
keymap('n', 'i', 'j', { noremap = true })
keymap('n', 'o', 'l', { noremap = true })
keymap('n', 'h', 'b', { noremap = true })
keymap('n', "'", 'e', { noremap = true })
keymap('n', ',', 'o', { noremap = true })

keymap('v', 'n', 'h', { noremap = true })
keymap('v', 'e', 'k', { noremap = true })
keymap('v', 'i', 'j', { noremap = true }) -- Error is happening here
keymap('v', 'o', 'l', { noremap = true })
keymap('v', 'h', 'b', { noremap = true })
keymap('v', "'", 'e', { noremap = true })
keymap('v', ',', 'o', { noremap = true })

keymap('n', ';', 'p', { noremap = true })
keymap('n', 'u', 'i', { noremap = true })
keymap('n', 'l', 'u', { noremap = true })

-- Include uppercase
keymap('n', 'U', 'I', { noremap = true })

-- Move in splits
keymap('n', '<c-n>', '<c-w>h', { noremap = true })
keymap('n', '<c-e>', '<c-w>k', { noremap = true })
keymap('n', '<c-i>', '<c-w>j', { noremap = true })
keymap('n', '<c-o>', '<c-w>l', { noremap = true })

keymap('n', '<sc-n>', '<C-w>v<C-w>h', { noremap = true })
keymap('n', '<sc-e>', '<C-w>s<C-w>k', { noremap = true })
keymap('n', '<sc-i>', '<C-w>s<C-w>j', { noremap = true })
keymap('n', '<sc-o>', '<C-w>v<C-w>l', { noremap = true })

-- Create splits
-- normal and visual
-- n -> h
-- e -> k
-- i -> j
-- o -> l
-- h -> b -- beginning of word backwards
-- ' -> e -- end of word forward
-- , -> o -- newline
-- only normal
-- ; -> p
-- u -> i
-- l -> u
