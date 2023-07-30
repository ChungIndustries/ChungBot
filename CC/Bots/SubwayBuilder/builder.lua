require("/lib/class")
require("chung_bot")


bot = ChungBot(-45, 0, 190, 4)

FILLER_BLOCKS = {
    "minecraft:cobblestone",
    "minecraft:netherrack",
    "minecraft:grass_block",
    "minecraft:dirt",
    "minecraft:diorite",
    "minecraft:andesite",
    "minecraft:granite",
    "minecraft:stone",
}


function find_filler_block()
    local itemSlot = -1

    for i, name in ipairs(FILLER_BLOCKS) do
        itemSlot = bot:find_item(name)

        if itemSlot ~= -1 then
            return itemSlot
        end
    end

    return -1
end


function build_powered_segment()
    local itemSlot = bot:find_item("minecraft:redstone_block")

    if bot:select(itemSlot) then
        bot:move_down(1, true)
        bot:dig_down()
        bot:place_down()
        bot:move_up()
    else
        -- Get More Items
        print("Need more redstone blocks!")
        return false
    end


    local itemSlot = bot:find_item("minecraft:powered_rail")

    if bot:select(itemSlot) then
        bot:place_down()
    else
        -- Get More Items
        print("Need more powered rails!")
        return false
    end

    return true
end


function build_normal_segment(length, dig)
    dig = dig or true

    for i=1, length do
        local railSlot = bot:find_item("minecraft:rail")

        if bot:select(railSlot) then
            if not bot:place_down() then  -- If we can't place the rail, there must be a block right beneath or empty block 2 blocks down
                bot:move_down(1, true)

                if not bot:inspect_down() then
                    local blockSlot = find_filler_block()
                    if bot:select(blockSlot) then
                        bot:dig_down()
                        bot:select(blockSlot)
                        bot:place_down()
                        bot:move_up()
                        bot:select(railSlot)
                        bot:place_down()
                    else
                        -- Get More Items
                        print("Need more filler blocks!")
                        return false
                    end
                else
                    bot:move_up()
                    bot:place_down()
                end
            end
        else
            -- Get More Items
            print("Need more rails!")
            return false
        end

        if not dig then  -- Add "or turn"
            if bot:inspect() then
                bot:rotate_left()

                if bot:inspect() then
                    bot:rotate_right(2)
                end

                railSlot = bot:find_item("minecraft:rail")
                if bot:select(railSlot) then
                    bot:place_down()
                else
                    -- Get More Items
                    print("Need more rails!")
                    return false
                end
            end
        end

        if i ~= length then
            bot:move_forward(1, dig)
        end
    end
end


function build_path(x, y, z, dig)  -- End coords
    dig = dig or true

    while bot.position.x ~= x and bot.position.y ~= y and bot.position.z ~= z do
        build_powered_segment()
        bot:move_forward(1, dig)

        if build_normal_segment(20, dig) then
            if not bot:inspect() then
                bot:move_forward(1, false)
            end
        end
    end
end