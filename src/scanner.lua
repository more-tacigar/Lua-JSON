------------------------------------------------------------
-- Copyright (c) 2016 tacigar
-- https://github.com/tacigar/lua-json
------------------------------------------------------------

scanner = {
    T_RCURLY_BRACE  = 1,
    T_LCURLY_BRACE  = 2,
    T_RSQUARE_BRACE = 3,
    T_LSQUARE_BRACE = 4,
    T_COLON         = 5,
    T_COMMA         = 6,
    T_STRING        = 7,
    T_TRUE          = 8,
    T_FALSE         = 9,
    T_NULL          = 10,
}

local function next_valid_char(input, state)
    while true do
	local c = input:read_char()
	if c ~= ' ' and c ~= '\r' and c ~= '\n' and c ~= '\t' then
	    state.valid_char = c
	    return c
	end
    end
end

local function next_string(input, state)
    local res = ""
    local next_string_states = {}
    next_string_states = {
	[1] = function ()
	    local c = input:read_char()
	    if c == '\\' then
		res = res .. c
		next_string_states[3]()
	    elseif c == '"' then
		return
	    else
		res = res .. c
		next_string_states[2]()
	    end
	end,
	[2] = function ()
	    local c = input:read_char()
	    if c == '"' then
		return
	    else
		res = res .. c
		next_string_states[1]()
	    end
	end,
	[3] = function ()
	    local c = input:read_char()
	    if c == '"' or c == '\\' or c == '/' or c == 'b'
	    or c == 'f' or c == 'n' or c == 'r' or c == 't' then
		res = res .. c
		next_string_states[2]()
	    else
		error("Parsing Error in next_string")
	    end
	end,
    }
    next_string_states[1]()
    next_valid_char(input, state)
    return res
end

local function is_digit_1to9(c)
    if c == '1' or c == '2' or c == '3' or c == '4' or c == '5'
    or c == '6' or c == '7' or c == '8' or c == '9' then
	return true
    end
end

local function is_digit(c)
    return is_digit_1to9(c) or c == '0' 
end

local function next_number(input, state)
    local numstr = ""
    local expstr = "" -- exponent potion
    local next_number_states = {}
    next_number_states = {
	[1] = function (c)
	    if c == '-' then
		numstr = numstr .. c
		next_number_states[2](next_valid_char(input, state))
	    elseif is_digit_1to9(c) then
		numstr = numstr .. c
		next_number_states[4](next_valid_char(input, state))
	    else
		error("Error in next_number [1]")
	    end
	end,
	[2] = function (c)
	    if c == '0' then
		numstr = numstr .. c
		next_number_states[3](next_valid_char(input, state))
	    elseif is_digit_1to9(c) then
		numstr = numstr .. c
		next_number_states[4](next_valid_char(input, state))
	    else
		error("Error in next_number [2]")
	    end
	end,
	[3] = function (c)
	    if c == '.' then
		numstr = numstr .. c
		next_number_states[5](next_valid_char(input, state))
	    elseif c == 'e' or c == 'E' then
		next_number_states[6](next_valid_char(input, state))
	    else
		return
	    end
	end,
	[4] = function (c)
	    if is_digit(c) then
		numstr = numstr .. c
		next_number_states[4](next_valid_char(input, state))
	    elseif c == 'e' or c == 'E' then
		next_number_states[6](next_valid_char(input, state))
	    elseif c == '.' then
		numstr = numstr .. c
		next_number_states[5](next_valid_char(input, state))
	    else
		return
	    end
	end,
	[5] = function (c)
	    if is_digit(c) then
		numstr = numstr .. c
		next_number_states[5](next_valid_char(input, state))
	    elseif c == 'e' or c == 'E' then
		next_number_states[6](next_valid_char(input, state))
	    else
		return
	    end
	end,
	[6] = function (c)
	    if is_digit(c) or c == '+' or c == '-' then
		expstr = expstr .. c
		next_number_states[7](next_valid_char(input, state))
	    else
		return
	    end
	end,
	[7] = function (c)
	    if is_digit(c) then
		expstr = expstr .. c
		next_number_states[7](next_valid_char(input, state))
	    else
		return
	    end
	end,
    }
    next_number_states[1](state.valid_char)
    if expstr ~= "" then
	return math.exp(tonumber(numstr), tonumber(expstr))
    else
	return tonumber(numstr)
    end
end

local function check_token_string(input, state, str)
    for i = 1, string.len(str) do
	local c = next_valid_char(input, state)
	if c ~= string.sub(str, i, i) then
	    error("Error in check_token_string")
	end
    end
end

local function next_token(input, state)
    local c = state.valid_char
    if c == '{' then
	next_valid_char(input, state)
	return { type = scanner.T_LCURLY_BRACE }
    elseif c == '}' then
	next_valid_char(input, state)
	return { type = scanner.T_RCURLY_BRACE }
    elseif c == '[' then
	next_valid_char(input, state)
	return { type = scanner.T_LSQUARE_BRACE }
    elseif c == ']' then
	next_valid_char(input, state)
	return { type = scanner.T_RSQUARE_BRACE }
    elseif c == ':' then
	next_valid_char(input, state)
	return { type = scanner.T_COLON }
    elseif c == ',' then
	next_valid_char(input, state)
	return { type = scanner.T_COMMA }
    elseif c == 't' then
	check_token_string(input, state, "rue")
	next_valid_char(input, state)
	return { type = scanner.T_TRUE }
    elseif c == 'f' then
	check_token_string(input, state, "alse")
	next_valid_char(input, state)
	return { type = scanner.T_FALSE }
    elseif c == 'n' then
	check_token_string(input, state, "ull")
	next_valid_char(input, state)
	return { type = scanner.T_NULL }
    elseif c == '"' then
	return { type = scanner.T_STRING, value = next_string(input, state) }
    elseif is_digit(c) or c == '-' then
	return { type = scanner.T_NUMBER, value = next_number(input, state) }
    end
end

function scanner.create(input)
    local state = { valid_char = '' }
    next_valid_char(input, state)
    return {
	next_token = function ()
	    return next_token(input, state)
	end,
    }
end

return scanner
