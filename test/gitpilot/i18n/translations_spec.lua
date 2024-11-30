local assert = require('luassert')

describe('translations', function()
  local en = require('gitpilot.i18n.en')
  local fr = require('gitpilot.i18n.fr')

  it('should have matching keys in English and French', function()
    local function check_tables(en_table, fr_table, path)
      path = path or ''
      for k, v in pairs(en_table) do
        local full_path = path .. (path == '' and '' or '.') .. k
        assert.is_not_nil(fr_table[k], 'Missing French translation for: ' .. full_path)
        
        if type(v) == 'table' then
          assert.is_table(fr_table[k], 'Type mismatch for: ' .. full_path)
          check_tables(v, fr_table[k], full_path)
        end
      end
    end

    check_tables(en, fr)
  end)

  it('should have all required base sections', function()
    local required_sections = {
      'welcome',
      'select_action',
      'confirm',
      'menu',
      'commit',
      'branch',
      'remote',
      'tag',
      'stash'
    }

    for _, section in ipairs(required_sections) do
      assert.is_not_nil(en[section], 'Missing section in English: ' .. section)
      assert.is_not_nil(fr[section], 'Missing section in French: ' .. section)
    end
  end)

  it('should have all required menu items', function()
    local required_menu_items = {
      'main_title',
      'main',
      'commits',
      'commits_title',
      'branches',
      'branches_title',
      'remotes',
      'remotes_title',
      'tags',
      'tags_title',
      'stash',
      'stash_title',
      'search',
      'search_title',
      'rebase',
      'rebase_title'
    }

    for _, item in ipairs(required_menu_items) do
      assert.is_not_nil(en.menu[item], 'Missing menu item in English: ' .. item)
      assert.is_not_nil(fr.menu[item], 'Missing menu item in French: ' .. item)
    end
  end)

  it('should not have empty string translations', function()
    local function check_values(table, path)
      path = path or ''
      for k, v in pairs(table) do
        local full_path = path .. (path == '' and '' or '.') .. k
        if type(v) == 'string' then
          assert.is_true(v ~= '', 'Empty translation found at: ' .. full_path)
        elseif type(v) == 'table' then
          check_values(v, full_path)
        end
      end
    end

    check_values(en, 'en')
    check_values(fr, 'fr')
  end)
end)
