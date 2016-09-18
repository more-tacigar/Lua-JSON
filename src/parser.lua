------------------------------------------------------------
-- Copyright (c) 2016 tacigar. All rights reserved.
-- https://github.com/tacigar/lua-json
------------------------------------------------------------

local Scanner = require("scanner")

parser = {}

local parse_elements, parse_array, parse_value
local parse_pair, parse_members, parse_object

local function check_token(token, token_type)
    if token.type ~= token_type then
	error("Error: "..token_type.. " is expected, but "..token.type)
    end
end

local function table_insert_kv(t1, t2)
    for k, v in pairs(t2) do
	t1[k] = v
    end
end

function parse_elements(scanner)
    local elements = {}
    local value = parse_value(scanner)
    table.insert(elements, value)
    while true do
	if scanner.token.type == Scanner.T_COMMA then
	    scanner:next_token()
	    value = parse_value(scanner)
	    table.insert(elements, value)
	else
	    return elements
	end
    end
end

function parse_array(scanner)
    local array = {}
    local token = scanner:next_token()
    if token.type ~= Scanner.T_RSQUARE_BRACE then
	local elements = parse_elements(scanner)
	table_insert_kv(array, elements)
    end
    check_token(scanner.token, Scanner.T_RSQUARE_BRACE)
    return array
end

function parse_value(scanner)
    local token = scanner.token
    local value = nil
    if token.type == Scanner.T_STRING or token.type == Scanner.T_NUMBER then
	value = token.value
    elseif token.type == Scanner.T_LCURLY_BRACE then
	value = parse_object(scanner)
    elseif token.type == Scanner.T_LSQUARE_BRACE then
	value = parse_array(scanner)
    elseif token.type == Scanner.T_TRUE then
	value = true
    elseif token.type == Scanner.T_FALSE then
	value = false
    elseif token.type == Scanner.T_NULL then
	value = nil
    else
	error("Error in parse_value")
    end
    scanner:next_token()
    return value
end

function parse_pair(scanner)
    check_token(scanner.token, Scanner.T_STRING)
    local key = scanner.token.value
    scanner:next_token()
    check_token(scanner.token, Scanner.T_COLON)
    scanner:next_token()
    local value = parse_value(scanner)
    return { [key] = value }
end

function parse_members(scanner)
    local members = {}
    local pair = parse_pair(scanner)
    table_insert_kv(members, pair)
    while true do
	if scanner.token.type == Scanner.T_COMMA then
	    scanner:next_token()
	    pair = parse_pair(scanner)
	    table_insert_kv(members, pair)
	else
	    return members
	end
    end
end

function parse_object(scanner)
    local object = {}
    local token = scanner:next_token()
    if token.type ~= Scanner.T_RCURLY_BRACE then
	local members = parse_members(scanner)
	table_insert_kv(object, members)
    end
    check_token(scanner.token, Scanner.T_RCURLY_BRACE)
    return object
end

function parser.parse(input)
    local scnr = Scanner.create(input)
    local scanner = {
	token = nil,
	next_token = function(self)
	    self.token = scnr:next_token()
	    return self.token
	end,
    }
    local token = scanner:next_token()
    check_token(token, Scanner.T_LCURLY_BRACE)
    return parse_object(scanner)
end

return parser
