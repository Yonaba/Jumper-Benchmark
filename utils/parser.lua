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

-- HOG Map and Scenarios (version 1.0) files parser

local tonumber, assert, io = tonumber, assert, io
local mapFilesPath = 'benchmarks/maps/%s'
local scenFilesPath = 'benchmarks/scenarios/%s.scen'

-- Private helpers

-- Parses a scenario line
local function parseScenLine(l)
  local fields = {}
  for w in l:gmatch('[^\t]+') do fields[#fields+1] = w end
  local f_fields = {}
  f_fields.bucket = tonumber(fields[1])
  f_fields.map = fields[2]
  f_fields.map_width = tonumber(fields[3])
  f_fields.map_height = tonumber(fields[4])
  f_fields.start_x = tonumber(fields[5])
  f_fields.start_y = tonumber(fields[6])
  f_fields.end_x = tonumber(fields[7])
  f_fields.end_y = tonumber(fields[8])
  f_fields.optimal_cost = tonumber(fields[9])
  return f_fields
end

-- Gets a file contents
local function getFileContents(file)
  local f = io.open(file,'r')
  local contents = f:read('*a')
  f:close()
  return contents
end

--[[
  Map file description
    Header:
      type octile
      height (int)
      width (int)
      map
      
  (ASCII) String data , '[\n\r]' line-endings, containing the following characters)
    . terrain (passable)
    G terrain (passable)
    @ void (out of map bounds)
    O void (out of map bounds)
    T tree (unpassable)
    S swamp (passable from terrain)
    W water (passable from terrain)
    
  Implementation note
    We will only consider '[.G]' as passable
--]] 

-- Parses a map file
local function parseMap(mapFile)
  local map_data = getFileContents(mapFilesPath:format(mapFile))
  local map_type = map_data:match('^type (%w+)[\n\r]')
  local map_height = tonumber(map_data:match('height (%d+)[\n\r]'))
  local map_width = tonumber(map_data:match('width (%d+)[\n\r]'))
  local _,map_offset = map_data:find('map[\n\r]')
  map_data = map_data:sub(map_offset+1)
  local map = {}
  repeat
    local EOS = map_data:find('[\n\r]')
    if EOS then
      local line = map_data:sub(1,EOS-1)
      map_data = map_data:sub(EOS+1)
      map[#map+1] = {}
      local row = map[#map]
        for char in line:gmatch('.') do
          row[#row+1] = char:match('[.G]') and 0 or 1
        end
    end
  until not EOS
  assert(#map == map_height,'Error parsing map height')
  assert(#map[1] == map_width,'Error parsing map width')  
  return map
end

--[[
  Scenario file description
    Header:
      version (%d+)
      
    (ASCII) String data, '[\n\r]' line-endings
    Each line describes a scenario in nine fields, separated by '\t')
      bucket (int)
      mapfile name (string)
      starting x-coordinate (int)
      starting y-coordinate (int)
      ending x-coordinate (int)
      ending y-coordinate (int)
      optimal length (float)
--]] 

-- Parses a scenario file
local function parseScenario(scenarioFile)
  local scen_data = getFileContents(scenFilesPath:format(scenarioFile))  
  local _,v_offset = scen_data:find('^%w*%s*(%d+)[\n\r]')
  local _version = v_offset and scen_data:sub(1,v_offset-1) or ''
  scen_data = scen_data:sub(v_offset and v_offset+1 or 1)
  local scen = {}
  repeat
    local EOS = scen_data:find('[\n\r]')
    if EOS then
      local line = scen_data:sub(1,EOS-1)
      scen_data = scen_data:sub(EOS+1)
      scen[#scen+1] = parseScenLine(line)
    end
  until not EOS  
  return scen
end

return {parseMap = parseMap, parseScenario = parseScenario}