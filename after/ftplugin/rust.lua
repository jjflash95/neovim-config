-- Rust specific settings
--
-- refactoring.nvim has no Rust support (no queries/rust, not in its supported
-- language list), so the <leader>r* maps from after/plugin/refactor.lua would
-- throw "scope_names setting is empty in treesitter for this language" here.
-- rust-analyzer ships equivalent assists, so point the same keys at those.

local function assist(title, kind)
    return function()
        vim.lsp.buf.code_action({
            apply = true,
            context = { only = { kind } },
            filter = function(action)
                if type(title) == 'function' then
                    return title(action.title)
                end
                return action.title == title
            end,
        })
    end
end

local function map(lhs, rhs, desc)
    vim.keymap.set({ 'n', 'x' }, lhs, rhs, { buffer = true, desc = desc })
end

-- Select the exact expression in visual mode; rust-analyzer only offers
-- "Extract into variable" when the range covers a whole expression node.
map('<leader>rv', assist('Extract into variable', 'refactor.extract'),
    'Rust: extract variable')
map('<leader>re', assist('Extract into function', 'refactor.extract'),
    'Rust: extract function')
map('<leader>ri', assist('Inline variable', 'refactor.inline'),
    'Rust: inline variable')

-- Inlining a function is titled "Inline `name`", so match on anything under
-- refactor.inline that is not the variable case.
map('<leader>rI', assist(function(t) return t ~= 'Inline variable' end, 'refactor.inline'),
    'Rust: inline function')

-- Every refactor rust-analyzer offers here, including "Extract into constant",
-- "Extract into static" and "Promote local to constant".
map('<leader>rr', function()
    vim.lsp.buf.code_action({ context = { only = { 'refactor' } } })
end, 'Rust: pick a refactor')

-- No rust-analyzer equivalent for these, so say so instead of letting the
-- global maps raise a treesitter error.
for _, lhs in ipairs({ '<leader>rf', '<leader>rbb', '<leader>rbf' }) do
    map(lhs, function()
        vim.notify('No rust-analyzer equivalent; try <leader>rr', vim.log.levels.WARN)
    end, 'Rust: unsupported refactor')
end

-- Debug-print helpers are also unsupported for Rust by refactoring.nvim.
for _, lhs in ipairs({ '<leader>rp', '<leader>rP', '<leader>rc' }) do
    map(lhs, function()
        vim.notify('refactoring.nvim debug prints do not support Rust', vim.log.levels.WARN)
    end, 'Rust: unsupported debug print')
end
