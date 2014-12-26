
turtle.detectEntity = function()
    if (turtle.detect()) then
        return false
    end

    if(turtle.getFuelLevel() == 0) then
        error("Fuel is needed to check entity presence")
    end
    
    local canmove = turtle.forward()
    
    if canmove then
        turtle.back()
    end
    
    return not canmove
end
