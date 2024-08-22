local f = assert(io.open("newfile", "w"))
if f ~= nil then
    f:write("test")
    f:close()
end
