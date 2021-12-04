#!/usr/bin/env lua
local fun = require 'fun'
local pwd = debug.getinfo(1, "S").short_src:match("^(.+)/[^/]+$")

local function load_file(file)
	local input = assert(io.open(pwd..'/'..file, 'r'))
	local lines = {}
	for num in input:lines() do
		local line = {}
		for ch in num:gmatch(".") do
			table.insert(line, ch)
		end
		table.insert(lines, line)
	end
	return lines
end

local function count(lines)
	local counter = {}
	for _, line in ipairs(lines) do
		for i, s in ipairs(line) do
			if not counter[i] then
				counter[i] = { ['1'] = 0, ['0'] = 0 }
			end
			counter[i][s] = counter[i][s] + 1
		end
	end
	return counter
end

local function part1(file)
	local counter = count(load_file(file))

	local gamma, eps = {}, {}
	for pos, cnts in ipairs(counter) do
		if cnts['1'] > cnts['0'] then
			gamma[pos] = '1'
			eps[pos] = '0'
		else
			gamma[pos] = '0'
			eps[pos] = '1'
		end
	end

	print(tonumber(table.concat(gamma), 2)*tonumber(table.concat(eps), 2))
end

local function part2(file)

	local function filter(lines, criteria)
		return fun.range(1, #lines[1])
			:reduce(function(input, pos)
				local counter = count(input)
				local bit = criteria(counter[pos])

				return fun.iter(input)
					:filter(function(line) return line[pos] == bit end)
					:totable()
			end, lines)
	end

	local lines = load_file(file)

	local oxy = filter(lines, function(counts)
		if counts['0'] == 0 then return '1' end
		if counts['1'] == 0 then return '0' end

		if counts['1'] >= counts['0'] then
			return '1'
		else
			return '0'
		end
	end)

	local oxy_num = tonumber(table.concat(oxy[1]), 2)
	print("oxy", oxy_num)

	local co2 = filter(lines, function(counts)
		if counts['0'] == 0 then return '1' end
		if counts['1'] == 0 then return '0' end

		if counts['1'] >= counts['0'] then
			return '0'
		else
			return '1'
		end
	end)

	local co2_num = tonumber(table.concat(co2[1]), 2)
	print("co2", co2_num)

	print("ret", oxy_num*co2_num)

end

part2 "test.txt"
part2 "input.txt"
