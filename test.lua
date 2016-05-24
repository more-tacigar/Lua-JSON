------------------------------------------------------------
-- TEST
------------------------------------------------------------
package.path = package.path .. ";./src/?.lua"

local Json = require("json")

function deep_print(e)
    if type(e) == "table" then
	print("{")
	for k, v in pairs(e) do
	    io.write(k, " : ")
	    deep_print(v)
	end
	print("}")
    else
	print(e)
    end
end

local res = Json.parse("test.json")
deep_print(res)

