--[[
Copyright (c) 2012 Roland Yonaba

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

-- Requiring dependancies
local socket = assert(require 'socket','LuaSocket is required.')
local parser = require 'utils.parser'
local map_list = require "benchmarks.map_list"
local Jumper = require 'Jumper.init'
local log = require 'utils.logging'

-- Triggers help printing
local print_help = false

-- Redefines native Lua print function to export logging information
local oldprint = print
local print = function(...)
  oldprint(...)
  log:add(...)
end

-- Finds a value inside a table
local function tfind(t,value)
	for i,v in pairs(t) do
		if v==value then return true,i end
	end
	return nil
end

-- Processes a single map
local function processMap(mapName)
	local map = parser.parseMap(mapName)
	local scen = parser.parseScenario(mapName)
	local grid_m_count = collectgarbage('count')
	local pather = Jumper(map)
	grid_m_count = collectgarbage('count')-grid_m_count
	return #map[1], #map, scen, pather,grid_m_count
end

-- Processes an entire map set
local function processMapList(mapList)
  local n_maps = #mapList
	local current_bucket = 0

	for i,v in ipairs(mapList) do
		log:setName(v)
		local w,h,Exp,pather,memory = processMap(v)

		print(('='):rep(126))
		print(('  Map n°         : %d/%d\n'..
		       '  Map file       : %s\n'..
			     '  Width x Height : %d x %d\n'..
			     '  Size           : %d\n'..
			     '  Buckets        : %d\n'..
			     '  Experiments    : %d\n'..
			     '  Grid memory    : %d kB')
            :format(i,n_maps,v,w,h,w*h,Exp[#Exp].bucket,#Exp,memory))
		print(('='):rep(126))

		local map_time_count,success,fail

		for k = 1,#Exp do

			local status,time

			time = socket.gettime()
			local path,len = pather:getPath(Exp[k].start_x,Exp[k].start_y,Exp[k].end_x,Exp[k].end_y)
			time = (socket.gettime()-time)*1000

			map_time_count = (map_time_count or 0)+time
			if not path then
				status,len,time = 'Failed',0,0
				fail = (fail or 0) + 1
			else
				status = 'Found'
				success = (success or 0) + 1
			end
			if current_bucket~= Exp[k].bucket then
        current_bucket = Exp[k].bucket
        print(('\n  Processing bucket: %04d/%04d\n')
                :format(current_bucket,Exp[#Exp].bucket))
			end

			print(('  Experiment: %04d/%04d: '..
             'Path: [%04d,%04d]->[%04d,%04d]: '..
             '%6s : Time: %7s ms : '..
             'Length: %7s : '..
             'Optimal Length: %7s')
                :format(k,#Exp,
                        Exp[k].start_x,Exp[k].start_y,
                        Exp[k].end_x,Exp[k].end_y,status,
                        tostring(string.format('%.2f',time)),
                        tostring(string.format('%.2f',len)),
                        tostring(string.format('%.2f',Exp[k].optimal_cost))))

    end

    print('\n')
		current_bucket = 0

		print(('='):rep(126))
		print(('  Number of experiments    : %04d'):format(#Exp))
		print(('  Success/Fails            : %04d/%04d'):format(success,fail or 0))
		print(('  Total computational time : %.2f seconds'):format(map_time_count/1000))
		print(('='):rep(126))

		map_time_count = 0
		log:export()
		log:clear()

	end

	collectgarbage()
end


-- Command-line Options
local options={}

-- Sets custom output directory for logs files
options.l = function(path)
  if path and not path:match('/$') then path = path..'/' end
  local f = io.open(path..'a.txt','w')
  if not f then
    oldprint(('Error : Folder \'%s\' not found or read-only!'):format(path))
    print_help = true
  else
    log.output = path
  end
end

-- Process a single map
options.m = function(mapFile)
	if mapFile and tfind(map_list,mapFile) then
		map_list = {mapFile}
	else
		oldprint(('Map \'%s\' not found!'):format(mapFile))
		print_help = true
	end
end

-- Process command-line options
local function processOptions(arg)
	local flag_processing = false
	if arg[1] then
		local argstr = table.concat(arg,' ',1,arg.n)
		for flag,param in argstr:gmatch('%-(%a)%s([^%s]+)%s*') do
			flag_processing = true
			if options[flag] then
				options[flag](param)
			else
				print_help = true
			end
		end
		if not flag_processing then
			print_help = true
		end
	end
end

local function print_Help(bool)
	if bool then
		oldprint ("\nCommand line help:\n"..
		          '  '..arg[0]..' [options]\n\n'..
			        'Available options are:\n'..
				      '  -l path    : output directory for *.log files\n'..
				      '  -m mapfile : single mapfile test to be processed\n')
	end
end

-- Wrapping up
local function main(arg)
  processOptions(arg)
  print_Help(print_help)
  if not print_help then
    processMapList(map_list)
  end
end

-- Run benchmark
main(arg)