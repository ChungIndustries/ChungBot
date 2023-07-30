DIRECTIONS = {"north", "east", "south", "west"}
NORTH, EAST, SOUTH, WEST, UP, DOWN = 1, 2, 3, 4, 5, 6
DELTA = {vector.new(0, 0, -1), vector.new(1, 0, 0), vector.new(0, 0, 1), vector.new(-1, 0, 0), vector.new(0, 1, 0), vector.new(0, -1, 0)}

ChungBot = class.Class()

function ChungBot:__init(x, y, z, direction)
    os.loadAPI("chung_helpers")
    print("Booting...")
    textutils.slowPrint("###########")

    self.startPos = vector.new(x, y, z)
    self.startDir = direction

    self.pos = self.startPos
    self.dir = self.startDir

    self.selectedSlot = 1
end


function ChungBot:fuel_level()
    return turtle.getFuelLevel()
end


function ChungBot:info()
    print("-------------------------")
    print("XYZ:", self.pos.x, "/", self.pos.y, "/", self.pos.z)
    print("Facing: "..DIRECTIONS[self.dir])
    print("Fuel Level: "..self:fuel_level())
    print("-------------------------")
end


function ChungBot:get_adjacent_coords(from)
    local adjacent = {}

    for i, delta in ipairs(DELTA) do
        adjacent[i] = from + delta
    end

    return adjacent
end


function ChungBot:rotate_right(count)
    local count = count or 1

    for i=1, count do turtle.turnRight() end

    self.dir = chung_helpers.calc_rotation(self.dir, count)
end


function ChungBot:rotate_left(count)
    local count = count or 1

    for i=1, count do turtle.turnLeft() end

    self.dir = chung_helpers.calc_rotation(self.dir, -count)
end


function ChungBot:turn_around()
    rotate_right(2)
end


function ChungBot:face(direction)
    if self.dir == direction then
        return
    elseif chung_helpers.calc_rotation(self.dir, 1) == direction then
        self:rotate_right()
    elseif chung_helpers.calc_rotation(self.dir, -1) == direction then
        self:rotate_left()
    else
        self:rotate_right(2)
    end
end


function ChungBot:move_forward(count, dig)
    chung_helpers.move(self.dir, turtle.forward, count, dig, turtle.dig)
end


function ChungBot:move_backward(count, dig)
    self:rotate_right(2)
    self:move_forward(count, dig)
    self:rotate_left(2)
end


function ChungBot:move_right(count, dig)
    self:rotate_right()
    self:move_forward(count, dig)
    self:rotate_left()
end


function ChungBot:move_left(count, dig)
    self:rotate_left()
    self:move_forward(count, dig)
    self:rotate_right()
end


function ChungBot:move_up(count, dig)
    chung_helpers.move(UP, turtle.up, count, dig, turtle.digUp)
end


function ChungBot:move_down(count, dig)
    chung_helpers.move(DOWN, turtle.down, count, dig, turtle.digDown)
end


function ChungBot:dig()
    return turtle.dig()
end


function ChungBot:dig_up()
    return turtle.digUp()
end


function ChungBot:dig_down()
    return turtle.digDown()
end


function ChungBot:dist_to(destX, destY, destZ)
    local destX = destX
    local destY = destY
    local destZ = destZ

    local destination = vector.new(destX, destY, destZ)
    local displacement = destination - self.pos

    return math.abs(displacement.x) + math.abs(displacement.y) + math.abs(displacement.z)
end


function ChungBot:go_to(x, y, z)
    local x = x or self.pos.x
    local y = y or self.pos.y
    local z = z or self.pos.z

    local target = vector.new(x, y, z)
    local delta = target - self.pos

    if delta.z > 0 then self:face(SOUTH) elseif delta.z < 0 then self:face(NORTH) end
    for i=1, math.abs(delta.z) do self:move_forward() end

    if delta.y > 0 then for i=1, math.abs(delta.y) do self:move_up() end
    elseif delta.y < 0 then for i=1, math.abs(delta.y) do self:move_down() end
    end

    if delta.x > 0 then self:face(EAST) elseif delta.x < 0 then self:face(WEST) end
    for i=1, math.abs(delta.x) do self:move_forward() end
end


function ChungBot:go_home()
    print("Heading Home...")

    local dz = self.startPos.z - self.pos.z

    if dz > 0 then  -- Right Side
        self:face(SOUTH)
    elseif dz < 0 then
        self:face(NORTH)
    end

    self:move_forward(dz)
    self:face(WEST)

    while self.pos.z ~= self.startPos.z do
        self:move_forward()
    end

    while self.pos.y < self.startPos.y do
        self:move_up()
    end

    self:face(self.startDir)

    print("Exiting")
    error()
end


function ChungBot:refuel(slot)
    print("Fueling up...")

    local selectedSlot = self.selectedSlot

    if slot then
        select(slot)
        turtle.refuel()
    else
        for i=1, 16 do
            self:select(i)
            turtle.refuel()
        end
    end

    self:select(selectedSlot)
end


function ChungBot:has_low_fuel(margin)
    margin = margin or 10
    local neededFuel = self:dist_to(self.startPos.x, self.startPos.y, self.startPos.z)
    local containedFuel = self:fuel_level()

    return containedFuel <= (neededFuel + margin)
end


function ChungBot:select(slot)
    if 0 <= slot and slot <= 16 then
        if turtle.select(slot) then
            self.selectedSlot = slot
            return true
        end
    end

    return false
end


function ChungBot:find_item(item)
    local itemSlot = -1

    for i=1, 16 do
        local itemDetails = turtle.getItemDetail(i)
        if itemDetails ~= nil then
            if itemDetails.name == item then
                itemSlot = i
                break
            end
        end
    end

    return itemSlot
end


function ChungBot:place(slot)
    return chung_helpers.place(slot, turtle.place)
end


function ChungBot:place_down(slot)
    return chung_helpers.place(slot, turtle.placeDown)
end


function ChungBot:place_up(slot)
    return chung_helpers.place(slot, turtle.placeUp)
end


function ChungBot:inspect()
    local success, data = turtle.inspect()
    return {success, data}
end


function ChungBot:inspect_up()
    local success, data = turtle.inspectUp()
    return {success, data}
end


function ChungBot:inspect_down()
    local success, data = turtle.inspectDown()
    return {success, data}
end


function ChungBot:strip_mine(direction)
    self:refuel()

    if direction
        face(direction)
    end

    while self.pos.y > 12 do
        self:move_down(1, true)
    end

    while not self:low_fuel() do
        -- Start At Bottom
        self:move_forward(1, true)
        self:move_up(1, true)
        self:rotate_left()
        self:move_forward(4, true)
        self:rotate_right(2)
        self:move_forward(8, true)
        self:rotate_right(2)
        self:move_forward(4, true)
        self:rotate_right()

        -- Continue forward
        for i=1, 2 do
            self:move_forward(1, true)
            turtle.digDown()
        end

        self:move_down(1, true)

        self:refuel()
    end

    self:go_home()
end


function ChungBot:mine_vein(depth, visited)
    visited = visited or {}
    if depth == 0 then return end

    local localStartDir = self.dir

    for i=0, 3 do
        local newDir = chung_helpers.calc_rotation(localStartDir, i)
        local block = (self.pos + DELTA[newDir]):tostring()

        if visited[block] == nil then
            visited[block] = true

            self:face(newDir)

            local notAir, blockData = table.unpack(self:inspect())
            if notAir and blockData.name == "minecraft:diamond_ore" then
                self:move_forward(1, true)
                self:mine_vein(depth - 1, visited)
                self:face(chung_helpers.calc_rotation(newDir, 2))
                self:move_forward(1, true)
            end
        end
    end
end


function ChungBot:build_farm(x, y)
    function ChungBot:place_water()
        self:select(self:find_item("minecraft:dirt"))
        self:dig_down()
        self:move_up(1, true)
        self:rotate_right()
        self:move_forward(1, true)
        self:rotate_left(2)
        self:place(16)
        self:move_backward(1, true)
        self:place(15)
        self:move_left(2, true)
        self:move_forward(2, true)
        self:rotate_right()
        self:place(15)
        self:move_left(2, true)
        self:move_forward(2, true)
        self:rotate_right()
        self:place(15)
        self:move_left(2, true)
        self:move_forward(2, true)
        self:rotate_right()
        self:place(15)
        self:move_down(1, true)
        self:move_forward(2, true)
        self:rotate_left(2)
        self:select(self:find_item("minecraft:dirt"))
    end

    local width = x
    local depth = y
    local iMod = 5

    for i=1, width do
        local placed = false
        local jMod = 5

        for j=1, depth do            
            self:select(self:find_item("minecraft:dirt"))
            self:dig_down()

            if i % iMod == 0 and j % jMod == 0 then
                placed = true
                jMod = jMod + 9
                self:place_water()
            else
                self:place_down()
            end

            self:move_forward(1, true)
        end

        if i % 2 == 0 then
            self:rotate_right()
            self:move_forward(1, true)
            self:rotate_right()
            self:move_forward(1, true)
        else
            self:rotate_left()
            self:move_forward(1, true)
            self:rotate_left()
            self:move_forward(1, true)
        end
        if placed then iMod = iMod + 9 end
    end
end

