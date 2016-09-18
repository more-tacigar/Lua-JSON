package.path = package.path .. ";../?.lua"

local Json = require("json")

function deep_print(e, indent)
	local t1 = string.rep("\t", indent)
	local t2 = string.rep("\t", indent + 1)
	if type(e) == "table" then
		io.write("{\n")
		for k, v in pairs(e) do
			io.write(t2, k, " : ")
			deep_print(v, indent + 1)
		end
		io.write(t1, "}\n")
	else
		print(e)
	end
end

local res = Json.parse("example.json")
deep_print(res, 0)

