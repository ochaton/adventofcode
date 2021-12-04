#!/usr/bin/env lua
local pwd = debug.getinfo(1, "S").short_src:match("^(.+)/[^/]+$")

local function split(str, sep)
	sep = sep or ' '
	local r = {}
	for s in str:gmatch(("([^%s]+)"):format(sep)) do
		table.insert(r, s)
	end
	return r
end

local function load_file(file)
	local input = assert(io.open(pwd..'/'..file, 'r'))

	local choices = split(input:read("*l"), ",")

	local function read_board(input)
		local spaces = input:read("*l")
		if not spaces then return nil, "eof" end

		if not spaces:match("^%s*$") then
			return nil, ("malformed header: %q"):format(spaces)
		end

		local board = {}
		for i = 1, 5 do
			local row = input:read("*l")
			board[i] = split(row, " ")
		end

		return board
	end

	local boards = {}
	while true do
		local b, err = read_board(input)
		if err == "eof" then
			break
		elseif err ~= nil then
			error(err)
		else
			table.insert(boards, b)
		end
	end

	return {
		boards = boards,
		choices = choices,
	}
end

local class = require 'metaclass'
local List = require 'metaclass.containers.List'

local Cell = class "Cell" : prototype {
	crossed = false,
}
function Cell:constructor(arg)
	self.value = arg
end

function Cell:cross(v)
	if self.crossed or self.value ~= v then return false end
	self.crossed = true
	return true
end

local Row = List(Cell)

function Row:cross(v)
	for _, c in self:pairs() do
		if c:cross(v) then
			return true
		end
	end
	return false
end

function Row:won(v)
	for _, c in self:pairs() do
		if not c.crossed then
			return false
		end
	end
	return true
end

function Row:tostring()
	local x = {}
	for _, c in self:pairs() do
		if c.crossed then
			table.insert(x, "_"..c.value.."_")
		else
			table.insert(x, c.value)
		end
	end
	return table.concat(x, " ")
end

local Board = List(Row)

function Board:draw(v)
	for _, row in self:pairs() do
		if row:cross(v) then
			return true
		end
	end
end

function Board:won()
	for _, row in self:pairs() do
		if row:won() then
			print("won row", row:tostring())
			return true
		end
	end

	-- check columns
	for col = 1, 5 do
		for _, row in self:pairs() do
			if not row[col].crossed then
				goto lost
			end
		end

		print("won column", col)
		do return true end

		::lost::
	end

	return false
end

function Board:score()
	local sum = 0
	for _, row in self:pairs() do
		for _, cell in row:pairs() do
			if not cell.crossed then
				sum = sum + cell.value
			end
		end
	end
	return sum
end


local function first_win(file)
	local input_data = load_file(file)

	local bs = List(Board)(input_data.boards)
	for _, c in ipairs(input_data.choices) do
		for _, b in bs:pairs() do
			b:draw(c)
			if b:won() then
				local sum = b:score()
				print("Sum: ", sum)
				print("Score: ", sum*c)
				return
			end
		end
	end
end

local function last_win(file)
	local input_data = load_file(file)

	local last_win

	local bs = List(Board)(input_data.boards)
	for _, c in ipairs(input_data.choices) do
		local win = {}
		for i, b in bs:pairs() do
			b:draw(c)
			if b:won() then
				local sum = b:score()
				print("Sum: ", sum)
				print("Score: ", sum*c)

				last_win = sum*c

				table.insert(win, i)
			end
		end
		for _, w in ipairs(win) do bs[w] = nil end
		bs:dropnils()

		if bs:length() == 0 then
			return last_win
		end
	end
end

first_win "input.txt"
print("last win: ", last_win "input.txt")
