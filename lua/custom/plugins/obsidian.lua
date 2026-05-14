local function get_rolled_over(section_keyword)
  -- Determine vault from current buffer path
  local buf_path = vim.fn.expand '%:p'
  local vault
  if buf_path:find('HockeyDJPlans', 1, true) then
    vault = vim.fn.expand '~/source/repos/HockeyDJ/HockeyDJPlans'
  else
    vault = vim.fn.expand '~/OneDrive/Documents/School Stuff'
  end
  local daily_dir = vault .. '/Daily Notes'
  local today = os.date '%Y-%m-%d'
  local files = vim.fn.globpath(daily_dir, '*.md', false, true)
  table.sort(files)
  local prev_file = nil
  for _, f in ipairs(files) do
    local name = vim.fn.fnamemodify(f, ':t:r')
    if name < today then
      prev_file = f
    end
  end
  if not prev_file then return '' end
  local lines = vim.fn.readfile(prev_file)
  local in_section = false
  local items = {}
  for _, line in ipairs(lines) do
    if line:match '^## ' then
      if in_section then break end
      if line:find(section_keyword, 1, true) then
        in_section = true
      end
    elseif in_section then
      if line:match '^%s*%- %[ %]' then
        local text = line:match '^%s*%- %[ %] (.*)'
        if text and text:match '%S' then
          table.insert(items, line)
        end
      end
    end
  end
  if #items == 0 then return '' end
  return table.concat(items, '\n')
end

return {
  'obsidian-nvim/obsidian.nvim',
  -- TODO: switch back to version = '*' after next release
  branch = 'main',
  -- Only load when at least one workspace directory exists
  enabled = vim.fn.isdirectory(vim.fn.expand '~/OneDrive/Documents/School Stuff') == 1
    or vim.fn.isdirectory(vim.fn.expand '~/Home') == 1
    or vim.fn.isdirectory(vim.fn.expand '~/source/repos/HockeyDJ/HockeyDJPlans') == 1,
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
        name = 'hockeydj',
        path = '~/source/repos/HockeyDJ/HockeyDJPlans',
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
        rolled_over_notes = function()
          return get_rolled_over 'Notes'
        end,
        rolled_over_todo = function()
          return get_rolled_over 'TODO'
        end,
      },
    },

    note = {
      template = 'Template, Note.md',
    },

    daily_notes = {
      folder = 'Daily Notes',
      template = 'Template, Daily Note.md',
      date_format = 'YYYY-MM-DD',
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
