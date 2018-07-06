local log = require 'log'

box.once('access:v1', function()
    box.schema.user.grant('guest', 'read,write,execute', 'universe')
    -- Uncomment this to create user {{__name__}}_user
    -- box.schema.user.create('{{__name__}}_user', { password = '{{__name__}}_pass' })
    -- box.schema.user.grant('{{__name__}}_user', 'read,write,execute', 'universe')
end)

local app = {
    mod1 = require 'app.router.mod1'
}

function app.init(config)
    log.info('router app init')

    for k, mod in pairs(app) do if type(mod) == 'table' and mod.init ~= nil then mod.init(config) end end
end

function app.destroy()
    log.info('router app destroy')
    for k, mod in pairs(app) do if type(mod) == 'table' and mod.destroy ~= nil then mod.destroy() end end
end

package.reload:register(app)
return app
