local log = require 'log'

return {
	start = function(config)
		log.info('Staring {{__appname__}}')
	end,
	destroy = function()
		log.info('Unloading {{__appname__}}')
	end
}
