hexagonal = {}

function hexagonal.get_defs(name, def)
	if not def then
		return
	end

	def = table.copy(def)

	def.on_place = nil
	def.paramtype2 = nil
	def.paramtype = "light"
	def.sunlight_propagates = true
	def.name = nil
	def.type = nil
	def.mod_origin = nil
	def.groups = def.groups or {}
	def.groups.spreading_dirt_type = nil

	local odef = table.copy(def)

	def.after_place_node = hexagonal.place_node
	def.drawtype = "mesh"
	def.mesh = "hexagonal_hexagon.obj"

	odef.groups = odef.groups or {}
	odef.groups.not_in_creative_inventory = 1
	odef.drawtype = "mesh"
	odef.mesh = "hexagonal_hexagon_offset.obj"
	odef.drop = name.."_hexagonal"
	odef.description = def.description.." (Offset)"
	odef.selection_box = {
		type = "fixed",
		fixed = {-1,-0.5,-0.5,0,0.5,0.5},
	}
	odef.collision_box = {
		type = "fixed",
		fixed = {-1,-0.5,-1,0,0.5,0},
	}
	return def, odef
end

function hexagonal.register_node(name, def)
	local ndef, odef = hexagonal.get_defs(name, def)
	minetest.register_node(name.."_hexagonal", ndef)
	minetest.register_node(name.."_hexagonal_offset", odef)
end

function hexagonal.override(name)
	local def, odef = hexagonal.get_defs(name, minetest.registered_nodes[name])
	minetest.override_item(name, def)
	minetest.register_node(":"..name.."_offset", odef)
end

function hexagonal.place_node(pos, placer, itemstack, pointed_thing)
	local facepos = minetest.pointed_thing_to_face_pos(placer, pointed_thing), 0.5
	if pos.z % 2 == 0 then
		if not (facepos.x % 2 > 0.5 and facepos.x % 2 < 1) and not (facepos.x % 2 > 1.5) then
			minetest.set_node(pos, {name="air"})
			pos.x = pos.x + 1
		end
		local name = itemstack:get_name()
		return minetest.set_node(pos, {name = name.."_offset"})
	end
end

hexagonal.register_node("hexagonal:dirt", minetest.registered_nodes["default:dirt"])
hexagonal.register_node("hexagonal:sand", minetest.registered_nodes["default:sand"])
hexagonal.register_node("hexagonal:dirt_with_snow", minetest.registered_nodes["default:dirt_with_snow"])
hexagonal.register_node("hexagonal:dirt_with_grass", minetest.registered_nodes["default:dirt_with_grass"])
hexagonal.register_node("hexagonal:stone", minetest.registered_nodes["default:stone"])
hexagonal.register_node("hexagonal:cobble", minetest.registered_nodes["default:cobble"])
hexagonal.register_node("hexagonal:tree", minetest.registered_nodes["default:tree"])
hexagonal.register_node("hexagonal:leaves", minetest.registered_nodes["default:leaves"])
hexagonal.register_node("hexagonal:glass", minetest.registered_nodes["default:glass"])
hexagonal.register_node("hexagonal:wood", minetest.registered_nodes["default:wood"])
hexagonal.register_node("hexagonal:brick", minetest.registered_nodes["default:brick"])
