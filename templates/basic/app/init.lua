local conf = require('config')

box.once('access:v1', function()
	box.schema.user.grant('guest', 'read,write,execute', 'universe')
end)

local {{__appname__}} = require('{{__appname__}}')
package.reload:register({{__appname__}})
rawset(_G, '{{__appname__}}', {{__appname__}})

{{__appname__}}.start(conf.get('app'))
