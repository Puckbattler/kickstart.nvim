-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- C# file type configuration
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'cs', 'vb' },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
    vim.opt_local.smartindent = true
  end,
})

-- Razor/CSHTML file type configuration
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'cshtml' },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
    vim.opt_local.smartindent = true
    -- Set filetype to enable proper syntax highlighting
    vim.bo.filetype = 'html'
  end,
})

-- Detect .cshtml files properly
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '*.cshtml',
  callback = function()
    vim.bo.filetype = 'cshtml'
  end,
})

-- Optional: Format and organize imports on save for C# files
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.cs',
  callback = function()
    if vim.g.omnisharp_organize_imports_on_save then
      vim.lsp.buf.code_action {
        context = { only = { 'source.organizeImports' } },
        apply = true,
      }
    end

    if vim.g.omnisharp_format_on_save then
      vim.lsp.buf.format { async = false }
    end
  end,
})

-- Global configuration variables for OmniSharp
vim.g.omnisharp_organize_imports_on_save = true
vim.g.omnisharp_format_on_save = true
