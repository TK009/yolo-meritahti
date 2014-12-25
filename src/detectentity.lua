function detectEntity()
    if (turtle.detect()) then
        return false
    end
    
    local canmove = turtle.forward()
    
    if canmove then
        turtle.back()
    end
    
    return not canmove
end
