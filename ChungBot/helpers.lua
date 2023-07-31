require("constants")

function calc_rotation(currentDir, rotations)
    local dir = currentDir - 1
    dir = (dir + rotations) % 4
    return dir + 1
end


function move(dir, moveFunc, count, dig, digFunc)
    local count = count or 1
    local dig = dig or false
    local hasMoved = false

    for i=1, count do
        hasMoved = false

        while not hasMoved do
            hasMoved = moveFunc()
            if not hasMoved then
                if dig then digFunc() else print("Error Moving!") end
            end
        end

        self.pos = self.pos + DELTA[dir]
        self:info()
    end
end


function place(slot, placeFunc)
    local selectedSlot = self.selectedSlot

    if slot then
       self:select(slot)
    end

    local success = placeFunc()
    self:select(selectedSlot)
    return success
end