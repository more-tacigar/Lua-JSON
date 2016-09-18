------------------------------------------------------------
-- Copyright (c) 2016 tacigar. All rights reserved.
-- https://github.com/tacigar/lua-json
------------------------------------------------------------

local Parser = require("parser")

json = {}

function json.parse(filename)
	local input = io.input(filename)
	return Parser.parse{
		read_char = function(self)
			return input:read(1)
		end,
	}
end

return json
