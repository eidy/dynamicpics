 

-- Base picture node
minetest.register_node("dynamicpics:picture", {
	description = "Picture",
	drawtype = "signlike",
	tiles = {"wool_white.png"},
	visual_scale = 3.0,
	inventory_image = "dynamicpics_node.png",
	wield_image = "dynamicpics_node.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = "wallmounted",
	},
	groups = {choppy=2, dig_immediate=3, oddly_breakable_by_hand=3}, 
    on_construct = function(pos)
		dynamicpics.construct_sign(pos)
	end,
	on_destruct = function(pos)
		dynamicpics.destruct_sign(pos)
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		dynamicpics.receive_fields(pos, formname, fields, sender)
	end,
	on_punch = function(pos, node, puncher)
		dynamicpics.update(pos)
	end,
 

})


local function set_obj_picture(obj, texturename)
 if obj.textures == nil or #obj.textures < 1 or obj.textures[1] ~= texturename then
	    obj:set_properties({
		    textures={texturename},
		    visual_size = {x=3, y=3},
     })
 end

end

dynamicpics_on_activate = function(self)
	local meta = minetest.get_meta(self.object:getpos())
	local texturename = meta:get_string("texturename")
 
	if texturename then
	 
		set_obj_picture(self.object,texturename)
	end
end

minetest.register_entity("dynamicpics:piccontent", {
    collisionbox = { 0, 0, 0, 0, 0, 0 },
    visual = "upright_sprite",
    textures = {},

	on_activate = dynamicpics_on_activate,
})

minetest.register_abm({
	nodenames = {"dynamicpics:picture"},
	interval = 15,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		dynamicpics.update(pos)
	end
})


dynamicpics = {}
dynamicpics.construct_sign = function(pos)
    local meta = minetest.get_meta(pos)
	meta:set_string(
		"formspec",
		"size[6,4]"..
		"field[1,1;3.5,3;texturename;Texture Name;${texturename}]"..
		"button_exit[2,3.4;2,1;ok;Write]") 
	    meta:set_string("texturename", "")
end

function dynamicpics.receive_fields(pos, formname, fields, sender, lock)
 
	 
	if fields and fields.texturename and fields.ok then
--		minetest.log("action", S("%s wrote \"%s\" to "..lockstr.."sign at %s"):format(
--			(sender:get_player_name() or ""),
--			fields.text,
--			minetest.pos_to_string(pos)
--		))
		 
	  local meta = minetest.get_meta(pos)
	  meta:set_string("texturename", fields.texturename)	
      dynamicpics.update(pos) 
	end
end


dynamicpics.destruct_sign = function(pos)
    local objects = minetest.get_objects_inside_radius(pos, 0.5)
    for _, v in ipairs(objects) do
		local e = v:get_luaentity()
        if e and e.name == "dynamicpics:piccontent" then
            v:remove()
        end
    end
end

dynamicpics.model = {
	nodebox = {
		type = "wallmounted",
		wall_side =   { -0.5,    -0.25,   -0.4375, -0.4375,  0.375,  0.4375 },
		wall_bottom = { -0.4375, -0.5,    -0.25,    0.4375, -0.4375, 0.375 },
		wall_top =    { -0.4375,  0.4375, -0.375,   0.4375,  0.5,    0.25 }
	},
--	picpos = {
--		nil,
--		nil,
--		{delta = {x =  0.43,  y = 0.07, z =  0     }, yaw = math.pi / -2},
--		{delta = {x = -0.43,  y = 0.07, z =  0     }, yaw = math.pi / 2},
--		{delta = {x =  0,     y = 0.07, z =  0.43  }, yaw = 0},
--		{delta = {x =  0,     y = 0.07, z = -0.43  }, yaw = math.pi},
--	}
 	picpos = {
		nil,
		nil,
		{delta = {x =  0.43,  y = 0, z =  0     }, yaw = math.pi / -2},
		{delta = {x = -0.43,  y = 0, z =  0     }, yaw = math.pi / 2},
		{delta = {x =  0,     y = 0, z =  0.43  }, yaw = 0},
		{delta = {x =  0,     y = 0, z = -0.43  }, yaw = math.pi},
	}
 
}


dynamicpics.update = function(pos)
    local meta = minetest.get_meta(pos)
	local texturename = meta:get_string("texturename")
    local objects = minetest.get_objects_inside_radius(pos, 0.5)

	local found
	for _, v in ipairs(objects) do
		local e = v:get_luaentity()
		if e and e.name == "dynamicpics:piccontent" then
			if found then
				v:remove()
			else
				set_obj_picture(v, texturename)
				found = true
			end
		end
	end

    if found then
		return
	end

	-- if there is no entity

	local sign_info
	 
	sign_info = dynamicpics.model.picpos[minetest.get_node(pos).param2 + 1]
		 
	--		sign_info = signs_lib.metal_wall_sign_model.textpos[minetest.get_node(pos).param2 + 1]
	 
	if sign_info == nil then
		return
	end

	local pic = minetest.add_entity({x = pos.x + sign_info.delta.x,
										y = pos.y + sign_info.delta.y,
										z = pos.z + sign_info.delta.z}, "dynamicpics:piccontent")
	pic:setyaw(sign_info.yaw)
 
end 
