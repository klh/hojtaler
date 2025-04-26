-- 90-default-eq-sink.lua
-- /usr/share/wireplumber/main.lua.d/
--
-- • Picks the first node whose description contains “EQ Sink”.
-- • Sets it as the default playback device.
-- • Caps its volume at 80 %.

Core.require_api ("metadata")

local MAX_VOLUME = 0.80   -- 80 %

local om = ObjectManager {
  Interest {
    type = "node",
    Constraint { "media.class", "equals", "Audio/Sink" },
  }
}

local function set_volume_80 (node)
  local v = node:get_volume ()        -- returns a Wp.Volume
  if v then
    v:scale (MAX_VOLUME)
    node:set_volume (v)
  end
end

om:connect ("object-added", function (_, node)
  local desc = node.properties["node.description"] or ""
  if desc:find ("EQ Sink") then
    Core.get_global ("metadata")
        :set (0, "default.audio.sink", "Spa:String",
              node.properties["object.path"])
    set_volume_80 (node)
    Log.info (node, "→ EQ Sink set as default, volume capped at 80 %")
  end
end)

om:activate ()