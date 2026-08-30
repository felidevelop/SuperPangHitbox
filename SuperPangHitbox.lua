--[[
Proyecto Super Pang Hitbox v0.1

Esta primera version solo tiene proposito de muestra de funcionamiento.
Aun hay caracteristicas que no estan pulidas para una version final, funcional o presentable.
]]


local HITBOX_SIZE4 = {
    {0x02, 0x04},
    {0x02, 0x04},
    {0x07, 0x0E},
    {0x09, 0x12},
    {0x0B, 0x16},
    {0x0C, 0x18},
    {0x0D, 0x1A},
    {0x0E, 0x1C},
    {0x0E, 0x1C},
    {0x0E, 0x1C},
    {0x0E, 0x1C},
    {0x0E, 0x1C},
    {0x0D, 0x1A},
    {0x0C, 0x18},
    {0x09, 0x12},
    {0x07, 0x0E},
    {0x02, 0x04},
}

local HITBOX_SIZE8 = {
    {0x04, 0x08},
    {0x04, 0x08},
    {0x09, 0x0C},
    {0x0C, 0x18},
    {0x0E, 0x1C},
    {0x10, 0x20},
    {0x11, 0x22},
    {0x13, 0x26},
    {0x13, 0x26},
    {0x14, 0x28},
    {0x16, 0x2C},
    {0x16, 0x2C},
    {0x16, 0x2C},
    {0x16, 0x2C},
    {0x16, 0x2C},
    {0x16, 0x2C},
    {0x16, 0x2C},
    {0x16, 0x2C},
    {0x14, 0x28},
    {0x13, 0x26},
    {0x13, 0x26},
    {0x11, 0x22},
    {0x10, 0x20},
    {0x0E, 0x1C},
    {0x0C, 0x18},
}

local HITBOX_SIZE16 = {
    {0x04, 0x08},
    {0x04, 0x08},
    {0x0A, 0x14},
    {0x0D, 0x1A},
    {0x10, 0x20},
    {0x12, 0x24},
    {0x14, 0x28},
    {0x15, 0x2A},
    {0x16, 0x2C},
    {0x18, 0x30},
    {0x19, 0x32},
    {0x1A, 0x34},
    {0x1B, 0x36},
    {0x1B, 0x36},
    {0x1C, 0x38},
    {0x1C, 0x38},
    {0x1C, 0x38},
    {0x1C, 0x38},
    {0x1C, 0x38},
    {0x1C, 0x38},
    {0x1B, 0x36},
    {0x1B, 0x36},
    {0x1A, 0x34},
    {0x19, 0x32},
    {0x18, 0x30},
    {0x16, 0x2C},
    {0x15, 0x2A},
    {0x14, 0x28},
    {0x12, 0x24},
    {0x10, 0x20},
    {0x0D, 0x1A},
    {0x0A, 0x14},
    {0x04, 0x08},
}

local function drawBalloonHitbox(p)
    local xraw = memory.readbyte(p + 0x09) +
                memory.readbyte(p + 0x0A) * 256 +
                memory.readbyte(p + 0x0B) * 65536
    local x = math.floor(xraw / 256) - 64
    local collisionX = memory.readbyte(p + 0x1B)
    local y = memory.readbyte(p + 0x0D) - 8
    local size = memory.readbyte(p + 0x16)

    local tabla
    local center
    local count

    if size == 1 then
        gui.box(
            x - 2,
            y - 4,
            x + 2,
            y + 3,
            0xFF000080
        )

        -- Dibujando Hitbox contra el jugador
        gui.box(
            x - 0x11 + 0x08,
            y - 0x0C,
            x + 0x08,
            y + (0x1C - 0x0C),
            0x00000000,
            0xFFFF00FF
        )
        return
    elseif size == 2 then
        gui.box(
            x - 4,
            y - 8,
            x + 4,
            y + 7,
            0xFF000080
        )

        -- Dibujando Hitbox contra el jugador
        gui.box(
            x - 0x15 + 0x0A,
            y - 0x0E,
            x + 0x0A,
            y + (0x20 - 0x0E),
            0x00000000,
            0xFF00FFFF
        )
        return
    elseif size == 4 then
        tableData = HITBOX_SIZE4
        center = 8
        count = 17
    elseif size == 8 then
        tableData = HITBOX_SIZE8
        center = 12
        count = 25
    elseif size == 16 then
        tableData = HITBOX_SIZE16
        center = 16
        count = 33
    else
        return
    end

    -- Dibujando casos 4 8 16
    local boxCenterX = collisionX * 2 - 64
    for dx = 0, count - 1 do
        local v1 = tableData[dx + 1][1]
        local v2 = tableData[dx + 1][2]

        local boxX = boxCenterX + ((dx - center) * 2)
        local top = y - v1
        local bottom = y + (v2 - v1)

        gui.box(
            boxX-1,
            top,
            boxX+0,
            bottom,
            0x00000000,
            0xFF000080
        )

    end


    -- Dibujando Hitbox contra el jugador
    if size == 4 then
        gui.box(
            x - 0x1F + 0x0F,
            y - 0x12,
            x + 0x0F,
            y + (0x28 - 0x12),
            0x00000000,
            0xFFFFFFFF
        )
    elseif size == 8 then
        gui.box(
            x - 0x2D + 0x16,
            y - 0x1A,
            x + 0x16,
            y + (0x38 - 0x1A),
            0x00000000,
            0x00FF00FF
        )
    elseif size == 16 then
        gui.box(
            x - 0x1D,
            y - 0x1E,
            x + 0x1C,
            y + (0x40 - 0x1E),
            0x00000000,
            0xFF0000FF
        )
    else
        return
    end

end

local function drawHarpoonHitbox(p)
    local collisionX = memory.readbyte(p + 0x1B)
    local x = collisionX * 2 - 64
    local yCurrent = memory.readbyte(p + 0x0D) - 8
    local yReference = memory.readbyte(p + 0x0E) - 8
    local top = math.min(yCurrent, yReference)
    local bottom = math.max(yCurrent, yReference)

    gui.box(
        x,
        top,
        x ,
        bottom,
        0xFF0000FF
    )
end

local function drawPlayerBalloonHitbox(p)
    local xraw = memory.readbyte(p + 0x09) +
                memory.readbyte(p + 0x0A) * 256 +
                memory.readbyte(p + 0x0B) * 65536
    local x = math.floor(xraw / 256) - 64
    local y = memory.readbyte(p + 0x0D) - 8

    gui.box(
        x - 0x11 + 0x08,
        y - 0x0C,
        x + 0x08,
        y + (0x1C - 0x0C),
        0x00000000,
        0xFFFF00FF
    )

end

local function drawLadderHitbox(p)
    local xraw = memory.readbyte(p + 0x09) +
                memory.readbyte(p + 0x0A) * 256 +
                memory.readbyte(p + 0x0B) * 65536
    local x = math.floor(xraw / 256) - 64
    local y = memory.readbyte(p + 0x0D) - 8

    local ladderY1 = memory.readbyte(p + 0x0C) - 8 - 0x10
    local ladderY2 = memory.readbyte(p + 0x0D) - 8 - 0x10
    local ladderTop = math.min(ladderY1, ladderY2)
    local ladderBottom = math.max(ladderY1, ladderY2)

    gui.box(
        x - 0x9,
        ladderTop,
        x + 0x9,
        ladderBottom,
        0x00000000,
        0xFFFF00FF
    )
end

local function drawExperimentalBox(p)
    local xraw = memory.readbyte(p + 0x09) +
        memory.readbyte(p + 0x0A) * 256 +
        memory.readbyte(p + 0x0B) * 65536
    local x = math.floor(xraw / 256) - 64
    local y = memory.readbyte(p + 0x0D) - 8

    local w = 16
    local h = 16

    local left   = x - math.floor(w / 2)
    local right  = x + math.floor(w / 2)
    local top    = y - math.floor(h / 2)
    local bottom = y + math.floor(h / 2)

    gui.box(
        left,
        top,
        right,
        bottom,
        0xFF000080
    )
end

local function drawLevelCollisionGrid()
    local BASE = 0xC800
    local COLS = 64
    local ROWS = 32
    local CELL = 8

    local ORIGIN_X = -64
    local ORIGIN_Y = -8

    for row = 0, ROWS - 1 do
        for col = 0, COLS - 1 do
            local id = memory.readbyte(BASE + row * 0x40 + col)

            -- id detectados como colisionables
            if id == 0x1F or id == 0x0D then
                local x1 = ORIGIN_X + col * CELL
                local y1 = ORIGIN_Y + row * CELL
                local x2 = x1 + CELL
                local y2 = y1 + CELL

                local color

                if id == 0x1F then
                    color = 0x00A0FF00
                elseif id == 0x0D then
                    color = 0xFF000000
                end

                gui.box(
                    x1,
                    y1,
                    x2,
                    y2,
                    color
                )
            end
        end
    end

end

gui.register(function()

    local ingameplay = memory.readbyte(0xe179) == 1
    local instage = memory.readbyte(0xc041) == 1
    local inending = memory.readbyte(0xe09d) == 1 

    if ingameplay == true and instage == true and inending == false then

        local pointer = 0xE080 -- Inicio puntero de deteccion de objetos

        -- aun una suposicion
        -- E200 ─────────────── jugador
        -- E380 ─────────────── arpón
        -- E780 ─────────────── tabla 8 × 0x10
        -- E800 ─────────────── escalera
        -- E8C0 ─────────────── tabla 4 × 0x20
        -- EA00 ─────────────── otra estructura
        -- F07F ─────────────── fin del rango antiguo

        for i = 0, 255 do

            local p = pointer + i * 0x10 -- 0x10 o 0x20 es posible que la diferencia entre objetos sea dinamico

            local active = memory.readbyte(p + 0x00) == 1

            if active then

                local xraw = memory.readbyte(p + 0x09) +
                            memory.readbyte(p + 0x0A) * 256 +
                            memory.readbyte(p + 0x0B) * 65536
                local x = math.floor(xraw / 256) - 64
                local y = memory.readbyte(p + 0x0D) - 8

                local size = memory.readbyte(p + 0x16)

                -- en pantalla se necesita hacer una correccion xreal-64 y yreal-8 para que el dibujo cuadre con lo que aparece en pantalla, aun se desconoce la razon

                -- Si no es un globo, no dibuja nada
                drawBalloonHitbox(p)

                if p >= 0xE200 and p < 0xE300 then
                    -- Jugador
                    drawPlayerBalloonHitbox(p)
                elseif p >= 0xE380 and p < 0xE440 then
                    -- Arpon
                    drawHarpoonHitbox(p)
                elseif p >= 0xE800 and p < 0xE880 then
                    -- Escalera
                    drawLadderHitbox(p)
                elseif size==0 then
                    -- Otros objetos
                    drawExperimentalBox(p)
                end

                -- Punto central para todos
                gui.box(x, y, x+1, y+1, 0xFFFFFFFF)

            end

        end

        pointer = 0xF900 -- Inicio puntero de tabla secundario para deteccion de items

        for i = 0, 20 do
            local p = pointer + i * 0x20
            local active = memory.readbyte(p + 0x00) == 1

            if active then
                -- aun una suposicion
                local state = memory.readbyte(p + 0x02) -- A0=en caida D3=apoyado FC=parpadeo
                local time = memory.readbyte(p + 0x04) -- B4 primer conteo, 5A segundo conteo

                local xraw = memory.readbyte(p + 0x09) +
                            memory.readbyte(p + 0x0A) * 256 +
                            memory.readbyte(p + 0x0B) * 65536
                local x = math.floor(xraw / 256) - 64
                local y = memory.readbyte(p + 0x0D) - 8

                gui.box(
                    x-0x11,
                    y-0x11,
                    x+0x11,
                    y+0x11,
                    0xFF000080
                )

                local w = 16
                local h = 16

                local top    = y - math.floor(h / 2)
                local bottom = y + math.floor(h / 2)

                gui.box(
                    x,
                    top,
                    x,
                    bottom,
                    0xFFFF00FF
                )

                if state==0xD3 then
                    gui.text(x-(0x11/2), y-0x11-8, time)
                elseif state==0xFC then
                    gui.text(x-(0x11/2), y-0x11-8, time, 0xFF0000FF)
                end

            end

        end

        drawLevelCollisionGrid()

    end

end)