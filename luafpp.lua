require("pl")

local path = arg[1]

-- Be nice and make a backup
file.copy(path, path .. ".bkp")

local f = io.open(path)
local line_iter = f:lines()

local lines_tbl = {}

-- Keep a global index of the current line number in the file
-- and wrap the iterator in a function and also keep the lines in another table
local glob_nr = 0
function next_line()
	local new_l = line_iter()
	table.insert(lines_tbl, new_l)
	glob_nr = glob_nr + 1
	return new_l
end

for l in next_line do
	-- Find ths start of interesting section
	if string.find(l, "class mydsp : public dsp {") ~= nil then
		--  Skip 3 lines to get to private variables declarations
		next_line()
		next_line()
		next_line()
		break
	end
end

local defs = {}
local l  = next_line()
-- Iterate over lines and stop on next empty line bc declarations end with
-- an empty line
while #l > 2 do
	-- Match declarations into 2 groups: type and name + array size
	local pat = "%c(%w+) ([%w%d%[%]]+);"
	local type, name = string.match(l, pat)
	--  is array if contains [ character
	local is_array = string.find(name, "%[")
	if is_array ~= nil then
		-- Find length inside [] and name
		array_length = tonumber(string.sub(name, is_array+1, -2))
		name = string.sub(name, 0, is_array-1)
	end
	-- print(string.format("Variable of type %s with name %s", type, name))
	-- if is_array ~= nil then
		-- print(string.format(" and is an array of size %d", array_length))
	-- end
	-- Use reference return value for non-pointer variables
	local ret = "&" .. name
	if is_array ~= nil then
		ret = name
	end
	-- Generate function based on type, name and return value
	local def = string.format("	%s* get%s() { return %s; }", type, name, ret)
	-- print(string.format("\t -> %s", def))
	table.insert(defs, def)
	print(def)
	l = next_line()
end

-- Skip some lines to get to the public: section of dsp class
next_line()
next_line()
next_line()

-- Add the new lines and comments to the global lines table
if #defs > 0 then table.insert(lines_tbl, "	// Begin auto added getters") end
for i, d in ipairs(defs) do
	table.insert(lines_tbl, d)
end
if #defs > 0 then table.insert(lines_tbl, "	// End auto added getters\n	") end

-- This is important so that the table gets filled with remaining lines
for l in next_line do
end

f:close()

-- Finally write to original file
local fo = io.open(path, "w")

for i, v in ipairs(lines_tbl) do
	fo:write(v)
	fo:write("\n")
end

fo:close()