-- lua/gitpilot/features/backup.lua

local M = {}
local ui = require('gitpilot.ui')
local utils = require('gitpilot.utils')
local i18n = require('gitpilot.i18n')

-- Configuration locale
local config = {
    backup_dir = vim.fn.stdpath('data') .. '/gitpilot/backups',
    auto_backup = true,
    backup_on_switch = true,
    max_backups = 10,
    include_stashes = true,
    backup_format = '%Y%m%d_%H%M%S'
}

-- Initialisation du module
function M.setup(opts)
    if opts then
        config = vim.tbl_deep_extend("force", config, opts)
    end
    -- Crée le répertoire de backup s'il n'existe pas
    if not utils.is_directory(config.backup_dir) then
        vim.fn.mkdir(config.backup_dir, 'p')
    end
end

-- Vérifie si le répertoire courant est un dépôt git
local function is_git_repo()
    local success, _ = utils.execute_command("git rev-parse --is-inside-work-tree")
    return success
end

-- Obtient le nom du dépôt
local function get_repo_name()
    local success, output = utils.execute_command("git rev-parse --git-dir")
    if success then
        return vim.fn.fnamemodify(output:gsub("/.git/?$", ""), ":t")
    end
    return nil
end

-- Crée un backup d'une branche
function M.backup_branch(branch_name)
    if not is_git_repo() then
        ui.show_error(i18n.t('error.no_git_repo'))
        return false
    end

    local repo_name = get_repo_name()
    if not repo_name then
        ui.show_error(i18n.t('backup.error.repo_name'))
        return false
    end

    -- Format du nom du backup
    local timestamp = os.date(config.backup_format)
    local backup_name = string.format("%s_%s_%s.bundle", repo_name, branch_name, timestamp)
    local backup_path = config.backup_dir .. '/' .. backup_name

    -- Crée le bundle
    local success, error = utils.execute_command(string.format(
        "git bundle create %s %s --branches --tags", 
        utils.escape_string(backup_path), 
        utils.escape_string(branch_name)
    ))

    if success then
        ui.show_info(i18n.t('backup.success.created', {name = backup_name}))
        return true
    else
        ui.show_error(i18n.t('backup.error.create_failed', {error = error}))
        return false
    end
end

-- Restaure un backup
function M.restore_backup(backup_path, branch_name)
    if not is_git_repo() then
        ui.show_error(i18n.t('error.no_git_repo'))
        return false
    end

    -- Vérifie si le bundle est valide
    local success, error = utils.execute_command(string.format(
        "git bundle verify %s",
        utils.escape_string(backup_path)
    ))

    if not success then
        ui.show_error(i18n.t('backup.error.invalid_bundle', {error = error}))
        return false
    end

    -- Restaure le bundle dans une nouvelle branche
    success, error = utils.execute_command(string.format(
        "git bundle unbundle %s && git checkout -b %s FETCH_HEAD",
        utils.escape_string(backup_path),
        utils.escape_string(branch_name)
    ))

    if success then
        ui.show_info(i18n.t('backup.success.restored', {name = branch_name}))
        return true
    else
        ui.show_error(i18n.t('backup.error.restore_failed', {error = error}))
        return false
    end
end

-- Liste tous les backups disponibles
function M.list_backups()
    if not utils.is_directory(config.backup_dir) then
        return {}
    end

    local backups = {}
    local files = vim.fn.glob(config.backup_dir .. '/*.bundle', true, true)
    
    for _, file in ipairs(files) do
        local name = vim.fn.fnamemodify(file, ':t')
        local stat = vim.loop.fs_stat(file)
        if stat then
            table.insert(backups, {
                name = name,
                path = file,
                size = stat.size,
                mtime = stat.mtime,
                formatted_time = os.date('%Y-%m-%d %H:%M:%S', stat.mtime)
            })
        end
    end

    -- Trie par date de modification (plus récent en premier)
    table.sort(backups, function(a, b) return a.mtime > b.mtime end)
    return backups
end

-- Exporte une branche en patch
function M.export_patch(branch_name, target_path)
    if not is_git_repo() then
        ui.show_error(i18n.t('error.no_git_repo'))
        return false
    end

    local success, error = utils.execute_command(string.format(
        "git format-patch %s --output-directory %s",
        utils.escape_string(branch_name),
        utils.escape_string(target_path)
    ))

    if success then
        ui.show_info(i18n.t('backup.success.patch_exported', {path = target_path}))
        return true
    else
        ui.show_error(i18n.t('backup.error.patch_export_failed', {error = error}))
        return false
    end
end

-- Importe un patch
function M.import_patch(patch_path)
    if not is_git_repo() then
        ui.show_error(i18n.t('error.no_git_repo'))
        return false
    end

    local success, error = utils.execute_command(string.format(
        "git am %s",
        utils.escape_string(patch_path)
    ))

    if success then
        ui.show_info(i18n.t('backup.success.patch_imported'))
        return true
    else
        ui.show_error(i18n.t('backup.error.patch_import_failed', {error = error}))
        return false
    end
end

-- Configure un mirror repository
function M.setup_mirror(remote_url)
    if not is_git_repo() then
        ui.show_error(i18n.t('error.no_git_repo'))
        return false
    end

    -- Ajoute le remote mirror
    local success, error = utils.execute_command(string.format(
        "git remote add mirror %s",
        utils.escape_string(remote_url)
    ))

    if not success then
        ui.show_error(i18n.t('backup.error.mirror_setup_failed', {error = error}))
        return false
    end

    -- Configure le push mirror
    success, error = utils.execute_command(
        "git config remote.mirror.mirror true && " ..
        "git config remote.mirror.push '+refs/heads/*:refs/heads/*' && " ..
        "git config remote.mirror.push '+refs/tags/*:refs/tags/*'"
    )

    if success then
        ui.show_info(i18n.t('backup.success.mirror_configured'))
        return true
    else
        ui.show_error(i18n.t('backup.error.mirror_config_failed', {error = error}))
        return false
    end
end

-- Synchronise avec le mirror
function M.sync_mirror()
    if not is_git_repo() then
        ui.show_error(i18n.t('error.no_git_repo'))
        return false
    end

    local success, error = utils.execute_command("git push mirror --mirror")

    if success then
        ui.show_info(i18n.t('backup.success.mirror_synced'))
        return true
    else
        ui.show_error(i18n.t('backup.error.mirror_sync_failed', {error = error}))
        return false
    end
end

-- Obtient l'historique des commits
function M.get_commit_history(max_count)
    max_count = max_count or 100 -- Limite par défaut
    
    local success, output = utils.execute_command(string.format(
        "git log -%d --pretty=format:%%H|%%s|%%ar|%%an",
        max_count
    ))

    if not success then
        return {}
    end

    local commits = {}
    for line in output:gmatch("[^\n]+") do
        local hash, subject, date, author = line:match("([^|]+)|([^|]+)|([^|]+)|([^|]+)")
        if hash then
            table.insert(commits, {
                hash = hash,
                subject = subject,
                date = date,
                author = author
            })
        end
    end

    return commits
end

-- Restaure une version spécifique dans une nouvelle branche
function M.restore_version(commit_hash, branch_name)
    if not is_git_repo() then
        ui.show_error(i18n.t('error.no_git_repo'))
        return false
    end

    -- Vérifie si le commit existe
    local success, _ = utils.execute_command(string.format(
        "git cat-file -e %s^{commit}",
        utils.escape_string(commit_hash)
    ))

    if not success then
        ui.show_error(i18n.t('version.error.commit_not_found'))
        return false
    end

    -- Crée une nouvelle branche à partir du commit
    success, error = utils.execute_command(string.format(
        "git checkout -b %s %s",
        utils.escape_string(branch_name),
        utils.escape_string(commit_hash)
    ))

    if success then
        ui.show_info(i18n.t('version.success.restored', {branch = branch_name}))
        return true
    else
        ui.show_error(i18n.t('version.error.restore_failed', {error = error}))
        return false
    end
end

-- Obtient les différences entre deux commits
function M.get_commit_diff(commit_hash)
    local success, output = utils.execute_command(string.format(
        "git show --stat %s",
        utils.escape_string(commit_hash)
    ))

    if success then
        return output
    end
    return nil
end

return M
