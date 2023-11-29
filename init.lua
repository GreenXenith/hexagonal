local hexagonal = {}
hexagonal.offset_cache = {}

function hexagonal.generate_def(name, src_def)
	if not src_def then
		return
	end

	local hex_def = table.copy(src_def)
    hex_def.name = nil
    hex_def.type = nil

    local after_place_node = src_def.after_place_node or function() end
	hex_def.after_place_node = function(...) hexagonal.after_place_node(...) return after_place_node(...) end
	hex_def.drawtype = "mesh"
	hex_def.mesh = "hexagonal_hexagon.obj"

	local hex_off_def = table.copy(hex_def)

	hex_off_def.groups = hex_off_def.groups or {}
	hex_off_def.groups.not_in_creative_inventory = 1

	hex_off_def.mesh = "hexagonal_hexagon_offset.obj"
	hex_off_def.drop = name .. "_hexagonal"
    if hex_def.description then
        hex_off_def.description = hex_def.description .. " (Offset)"
    end

	hex_off_def.selection_box = {
		type = "fixed",
		fixed = {-1,-0.5,-0.5,0,0.5,0.5},
	}

	hex_off_def.collision_box = {
		type = "fixed",
		fixed = {-1,-0.5,-1,0,0.5,0},
	}

	return hex_def, hex_off_def
end

function hexagonal.register_node(name, def)
	local hex_def, hex_off_def = hexagonal.generate_def(name, def)
	minetest.register_node(name .. "_hexagonal", hex_def)
	minetest.register_node(name .. "_hexagonal_offset", hex_off_def)

    hexagonal.offset_cache[minetest.get_content_id(name .. "_hexagonal")] = minetest.get_content_id(name .. "_hexagonal_offset")
end

function hexagonal.override(name)
	local hex_def, hex_off_def = hexagonal.generate_def(name, minetest.registered_nodes[name])
	minetest.override_item(name, hex_def)
	minetest.register_node(":" .. name .. "_offset", hex_off_def)

    hexagonal.offset_cache[minetest.get_content_id(name)] = minetest.get_content_id(name .. "_offset")
end

function hexagonal.after_place_node(pos, placer, itemstack, pointed_thing)
	local facepos = minetest.pointed_thing_to_face_pos(placer, pointed_thing)
	if pos.z % 2 == 0 then
		if not (facepos.x % 2 > 0.5 and facepos.x % 2 < 1) and not (facepos.x % 2 > 1.5) then
			minetest.set_node(pos, {name = "air"})
			pos.x = pos.x + 1
		end
		local name = itemstack:get_name()
		minetest.set_node(pos, {name = name .. "_offset"})
	end
end

local vbuffer = {}
local cache = hexagonal.offset_cache

minetest.register_on_generated(function()
    local vmanip, minp, maxp = minetest.get_mapgen_object("voxelmanip")
    local varea = VoxelArea(minp, maxp)
    local data = vmanip:get_data(vbuffer)
    local index = varea.index

    for z = minp.z, maxp.z, 2 do
        for y = minp.y, maxp.y do
            for x = minp.x, maxp.x do
                local idx = index(varea, x, y, z)
                local cid = data[idx]
                if cache[cid] then
                    data[idx] = cache[cid]
                end
            end
        end
    end

    vmanip:set_data(data)
    vmanip:write_to_map()
end)

minetest.register_on_joinplayer(function(player)
    player:set_sun({
        texture = "hexagonal_sun.png",
        sunrise_visible = true,
    })
end)

minetest.register_on_mods_loaded(function()
    for name, def in pairs(minetest.registered_nodes) do
        if ({normal = true, glasslike = true, allfaces = true, allfaces_optional = true})[def.drawtype] then
            hexagonal.override(name)
        end
    end
end)
