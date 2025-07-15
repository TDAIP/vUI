local HttpService = game:GetService("HttpService")
local PlaceId = tostring(game.PlaceId)
local FILE_NAME = "vtrip_ui_autosave_"..PlaceId..".json"

local rawWrite = writefile
local rawRead = readfile
local rawIsFile = isfile

local SaveData = {}
local Hooks = {}

local function safe_read()
	if rawIsFile(FILE_NAME) then
		local s, r = pcall(function()
			return HttpService:JSONDecode(rawRead(FILE_NAME))
		end)
		if s and type(r) == "table" then
			SaveData = r
		end
	end
end

local function safe_write()
	pcall(function()
		rawWrite(FILE_NAME, HttpService:JSONEncode(SaveData))
	end)
end

safe_read()

-- Hook tất cả thành phần của vUI tự động
local function hook_component(obj, id, typeCheck)
	if not id then return end
	if not SaveData[id] then
		SaveData[id] = obj.Value
	else
		-- Áp dụng giá trị đã lưu
		if type(SaveData[id]) == "table" then
			for i, v in pairs(SaveData[id]) do
				obj.Value[i] = v
			end
		else
			obj:Set(SaveData[id])
		end
	end

	-- Tự động ghi lại khi thay đổi
	local oldCallback = obj.Callback
	obj.Callback = function(val)
		SaveData[id] = val
		safe_write()
		if oldCallback then oldCallback(val) end
	end
end

-- Hook vào hàm Tab để override tất cả khi tạo component
local function hook_tab(tab)
	local meta = getmetatable(tab)
	local oldNew = meta.__index

	meta.__index = setmetatable({}, {
		__index = function(_, key)
			local original = oldNew[key]
			if typeof(original) ~= "function" then return original end

			return function(self, data)
				if data and data.Title then
					local id = data.Title:gsub("%s+", "_")
					if key == "Toggle" or key == "Textbox" or key == "Slider" or key == "Dropdown" then
						data.Value = SaveData[id] or data.Value
					end
				end

				local object = original(self, data)

				-- Tự động hook nếu là component cần theo dõi
				if data and data.Title then
					local id = data.Title:gsub("%s+", "_")
					if key == "Toggle" or key == "Textbox" or key == "Slider" or key == "Dropdown" then
						task.delay(0.1, function()
							hook_component(object, id)
						end)
					end
				end

				return object
			end
		end
	})
end

-- Hook toàn bộ các Tab khi tạo Window
local _oldWindow = Library.Window
Library.Window = function(data)
	local win = _oldWindow(data)
	local _oldTab = win.Tab

	win.Tab = function(tabData)
		local tab = _oldTab(tabData)
		hook_tab(tab)
		return tab
	end

	return win
end
