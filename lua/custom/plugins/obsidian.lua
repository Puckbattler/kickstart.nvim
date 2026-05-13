return {
  'obsidian-nvim/obsidian.nvim',
  -- TODO: switch back to version = '*' after next release
  branch = 'main',
  -- Only load when at least one workspace directory exists
  enabled = vim.fn.isdirectory(vim.fn.expand '~/OneDrive/Documents/School Stuff') == 1
    or vim.fn.isdirectory(vim.fn.expand '~/Home') == 1,
  lazy = false,
  ft = 'markdown',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  opts = {
    workspaces = {
      {
        name = 'personal',
        path = '~/OneDrive/Documents/School Stuff',
        overrides = {
          daily_notes = {
            workdays_only = false,
          },
        },
      },
      {
        name = 'work',
        path = '~/Home',
        overrides = {
          daily_notes = {
            workdays_only = true,
          },
        },
      },
    },

    notes_subdir = '0 - INBOX',

    -- Where to put new notes.
    --  * "current_dir" - same directory as the current buffer.
    --  * "notes_subdir" - default notes subdirectory.
    new_notes_location = 'current_dir',

    note_id_func = function(title)
      -- Zettelkasten format: timestamp + slugified title
      -- e.g. '20240101120000-my-new-note'
      local suffix = ''
      if title ~= nil then
        suffix = title:gsub(' ', '-'):gsub('[^A-Za-z0-9-]', ''):lower()
      else
        for _ = 1, 4 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
      end
      return tostring(os.date '%Y%m%d%H%M%S') .. '-' .. suffix
    end,

    picker = {
      name = 'telescope.nvim',
      note_mappings = {
        new = '<C-x>',
        insert_link = '<C-l>',
      },
      tag_mappings = {
        tag_note = '<C-x>',
        insert_tag = '<C-l>',
      },
    },

    legacy_commands = false,

    templates = {
      folder = 'Templates',
      substitutions = {
        long_date = function()
          return os.date('%B %d, %Y'):gsub(' 0', ' ')
        end,
      },
    },

    note = {
      template = 'Template, Note.md',
    },

    daily_notes = {
      template = 'Template, Daily Note.md',
      date_format = 'YYYYMMDD-[daily-note]',
      alias_format = '[Daily Note]',
    },

    -- Disable obsidian.nvim's built-in UI rendering since render-markdown.nvim
    -- handles markdown rendering. Recommended by render-markdown's :checkhealth.
    ui = { enable = false },
  },
  config = function(_, opts)
    require('obsidian').setup(opts)

    local ok, _ = pcall(require, 'which-key')
    if not ok then
      return
    end

    require('which-key').add {
      { '<leader>o', buffer = false, group = 'Obsidian' },
      {
        '<leader>oe',
        ":'<,'>Obsidian extract_note<CR>",
        mode = { 'v' },
        buffer = false,
        desc = 'Extract visually selected text into a new note and link to it.',
      },
      { '<leader>on', '<cmd>Obsidian new<CR>',           buffer = false, desc = 'Create a new note.' },
      { '<leader>oo', '<cmd>Obsidian open<CR>',          buffer = false, desc = 'Open a note in the Obsidian app.' },
      { '<leader>oq', '<cmd>Obsidian quick_switch<CR>',  buffer = false, desc = 'Quickly switch to another note in your vault.' },
      { '<leader>os', '<cmd>Obsidian search<CR>',        buffer = false, desc = 'Search for notes in your vault.' },
      { '<leader>ot', '<cmd>Obsidian toc<CR>',           buffer = false, desc = 'Load the table of contents into a picker list.' },
      { '<leader>od', '<cmd>Obsidian today<CR>',         buffer = false, desc = "Open or create today's daily note." },
      { '<leader>oy', '<cmd>Obsidian yesterday<CR>',     buffer = false, desc = "Open or create yesterday's daily note." },
      { '<leader>oT', '<cmd>Obsidian tomorrow<CR>',      buffer = false, desc = "Open or create tomorrow's daily note." },
      { '<leader>oD', '<cmd>Obsidian dailies<CR>',       buffer = false, desc = 'Browse daily notes.' },
      { '<leader>ow', '<cmd>Obsidian workspace<CR>',     buffer = false, desc = 'Switch to another workspace.' },
    }
  end,
}
