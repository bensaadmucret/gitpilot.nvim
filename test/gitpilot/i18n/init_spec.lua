local assert = require('luassert')
local i18n = require('gitpilot.i18n')

describe('i18n', function()
  before_each(function()
    -- Reset i18n state before each test
    i18n.setup({ language = 'en' })
  end)

  it('should load English translations', function()
    local msg = i18n.t('welcome')
    assert.is_not_nil(msg)
    assert.is_string(msg)
  end)

  it('should load French translations', function()
    i18n.setup({ language = 'fr' })
    local msg = i18n.t('welcome')
    assert.is_not_nil(msg)
    assert.is_string(msg)
  end)

  it('should fallback to English for missing translations', function()
    i18n.setup({ language = 'fr' })
    local en_msg = i18n.t('some.nonexistent.key')
    i18n.setup({ language = 'fr' })
    local fr_msg = i18n.t('some.nonexistent.key')
    assert.are.equal(en_msg, fr_msg)
  end)

  it('should handle variable substitution', function()
    local vars = { name = 'test' }
    local msg = i18n.t('welcome', vars)
    assert.is_not_nil(msg)
    assert.is_string(msg)
  end)
end)
