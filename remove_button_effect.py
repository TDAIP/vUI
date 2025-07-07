import re

# Đường dẫn file main.lua
LUA_FILE = 'main.lua'

# Đọc nội dung file
with open(LUA_FILE, 'r', encoding='utf-8') as f:
    lua_code = f.read()

# Regex tìm hàm hiệu ứng click button (ví dụ TweenService hoặc di chuyển button)
# Giả sử hiệu ứng là TweenService:Create hoặc TweenPosition, bạn có thể điều chỉnh regex nếu cần
pattern = r'(TweenService:Create\(.*?\):Play\(\))'

# Xóa hiệu ứng
lua_code = re.sub(pattern, '', lua_code, flags=re.DOTALL)

# Thêm code di chuyển button sang trái khi ấn button
# Giả sử tên biến button là Button, bạn cần thay đúng tên biến nếu khác
move_code = '''
Button.MouseButton1Click:Connect(function()
    Button.Position = UDim2.new(Button.Position.X.Scale - 0.1, Button.Position.X.Offset, Button.Position.Y.Scale, Button.Position.Y.Offset)
end)
'''

# Thêm đoạn code vào cuối file
lua_code += '\n' + move_code

# Ghi lại file
with open(LUA_FILE, 'w', encoding='utf-8') as f:
    f.write(lua_code)

print('Đã xóa hiệu ứng và thêm code di chuyển button sang trái!')
