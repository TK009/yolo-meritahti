
tArgs = {...}

if #tArgs > 0 then
    shell.run "help pwd"
end

print(shell.dir())
