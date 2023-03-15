local Trans = require('Trans')

local function set_strategy_opts(conf)
    local define       = Trans.define
    local all_modes    = define.modes
    local all_backends = define.backends

    local function parse_backend(backend)
        if type(backend) == 'string' then
            return backend == '*' and all_backends or { backend }
        end

        return backend
    end

    local default_strategy = conf.strategy.default
    default_strategy.backend = parse_backend(default_strategy.backend)



    local meta = {
        __index = function(tbl, key)
            tbl[key] = default_strategy[key]
            return tbl[key]
        end
    }

    local strategy = conf.strategy
    for _, mode in ipairs(all_modes) do
        strategy[mode] = setmetatable(strategy[mode] or {}, meta)
        if type(strategy[mode].backend) == 'string' then
            strategy[mode].backend = parse_backend(strategy[mode].backend)
        end
    end
end


local function set_frontend_opts(conf)
    local all_frontends = Trans.define.frontends


    local global_frontend_opts = conf.frontend
    local meta = {
        __index = function(tbl, key)
            tbl[key] = global_frontend_opts[key]
            return tbl[key]
        end
    }

    for _, frontend in ipairs(all_frontends) do
        local frontend_opts = global_frontend_opts[frontend]
        if not frontend_opts then
            global_frontend_opts[frontend] = setmetatable({}, meta)
        else
            setmetatable(frontend_opts, meta)
        end
    end
end


local function define_highlights(conf)
    local set_hl     = vim.api.nvim_set_hl
    local highlights = Trans.style.theme[conf.theme]
    for hl, opt in pairs(highlights) do
        set_hl(0, hl, opt)
    end
end


---@alias TransMode
---|'normal' # Normal mode
---|'visual' # Visual mode
---|'input' # Input mode
---@class Trans
---@field setup fun(opts: { mode: string, mode: TransMode })
return function(opts)
    if opts then
        Trans.conf = vim.tbl_deep_extend('force', Trans.conf, opts)
    end
    local conf = Trans.conf
    conf.dir = vim.fn.expand(conf.dir)

    set_strategy_opts(conf)
    set_frontend_opts(conf)
    define_highlights(conf)
end
