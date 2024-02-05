---use-luvit

local BitBuffer = require './bitbuffer'
local ffi = require 'ffi'
local bit = require 'bit'

-- 00000111 00000110 00000000

local NAMES = {
    [0] = "None",
    [1] = "ByteProperty",
    [2] = "IntProperty",
    [3] = "BoolProperty",
    [4] = "FloatProperty",
    [5] = "ObjectProperty",
    [6] = "NameProperty",
    [7] = "DelegateProperty",
    [8] = "DoubleProperty",
    [9] = "ArrayProperty",
    [10] = "StructProperty",
    [11] = "VectorProperty",
    [12] = "RotatorProperty",
    [13] = "StrProperty",
    [14] = "TextProperty",
    [15] = "InterfaceProperty",
    [16] = "MulticastDelegateProperty",
    [18] = "LazyObjectProperty",
    [19] = "SoftObjectProperty",
    [20] = "Int64Property",
    [21] = "Int32Property",
    [22] = "Int16Property",
    [23] = "Int8Property",
    [24] = "UInt64Property",
    [25] = "UInt32Property",
    [26] = "UInt16Property",
    [28] = "MapProperty",
    [29] = "SetProperty",
    [30] = "Core",
    [31] = "Engine",
    [32] = "Editor",
    [33] = "CoreUObject",
    [34] = "EnumProperty",
    [50] = "Cylinder",
    [51] = "BoxSphereBounds",
    [52] = "Sphere",
    [53] = "Box",
    [54] = "Vector2D",
    [55] = "IntRect",
    [56] = "IntPoint",
    [57] = "Vector4",
    [58] = "Name",
    [59] = "Vector",
    [60] = "Rotator",
    [61] = "SHVector",
    [62] = "Color",
    [63] = "Plane",
    [64] = "Matrix",
    [65] = "LinearColor",
    [66] = "AdvanceFrame",
    [67] = "Pointer",
    [68] = "Double",
    [69] = "Quat",
    [70] = "Self",
    [71] = "Transform",
    [100] = "Object",
    [101] = "Camera",
    [102] = "Actor",
    [103] = "ObjectRedirector",
    [104] = "ObjectArchetype",
    [105] = "Class",
    [106] = "ScriptStruct",
    [107] = "Function",
    [108] = "Pawn",
    [200] = "State",
    [201] = "TRUE",
    [202] = "FALSE",
    [203] = "Enum",
    [204] = "Default",
    [205] = "Skip",
    [206] = "Input",
    [207] = "Package",
    [208] = "Groups",
    [209] = "Interface",
    [210] = "Components",
    [211] = "Global",
    [212] = "Super",
    [213] = "Outer",
    [214] = "Map",
    [215] = "Role",
    [216] = "RemoteRole",
    [217] = "PersistentLevel",
    [218] = "TheWorld",
    [219] = "PackageMetaData",
    [220] = "InitialState",
    [221] = "Game",
    [222] = "SelectionColor",
    [223] = "UI",
    [224] = "ExecuteUbergraph",
    [225] = "DeviceID",
    [226] = "RootStat",
    [227] = "MoveActor",
    [230] = "All", 
    [231] = "MeshEmitterVertexColor",
    [232] = "TextureOffsetParameter",
    [233] = "TextureScaleParameter",
    [234] = "ImpactVel",
    [235] = "SlideVel",
    [236] = "TextureOffset1Parameter",
    [237] = "MeshEmitterDynamicParameter",
    [238] = "ExpressionInput",
    [239] = "Untitled",
    [240] = "Timer",
    [241] = "Team",
    [242] = "Low",
    [243] = "High",
    [244] = "NetworkGUID",
    [245] = "GameThread",
    [246] = "RenderThread",
    [247] = "OtherChildren",
    [248] = "Location",
    [249] = "Rotation",
    [250] = "BSP",
    [251] = "EditorSettings",
    [252] = "AudioThread",
    [253] = "ID",
    [254] = "UserDefinedEnum",
    [255] = "Control",
    [256] = "Voice",
    [257] = "Zlib",
    [258] = "Gzip",
    [259] = "LZ4",
    [260] = "Mobile",
    [280] = "DGram",
    [281] = "Stream",
    [282] = "GameNetDriver",
    [283] = "PendingNetDriver",
    [284] = "BeaconNetDriver",
    [285] = "FlushNetDormancy",
    [286] = "DemoNetDriver",
    [287] = "GameSession",
    [288] = "PartySession",
    [289] = "GamePort",
    [290] = "BeaconPort",
    [291] = "MeshPort",
    [292] = "MeshNetDriver",
    [293] = "LiveStreamVoice",
    [294] = "LiveStreamAnimation",
    [300] = "Linear",
    [301] = "Point",
    [302] = "Aniso",
    [303] = "LightMapResolution",
    [311] = "UnGrouped",
    [312] = "VoiceChat",
    [320] = "Playing",
    [322] = "Spectating",
    [325] = "Inactive",
    [350] = "PerfWarning",
    [351] = "Info",
    [352] = "Init",
    [353] = "Exit",
    [354] = "Cmd",
    [355] = "Warning",
    [356] = "Error",
    [400] = "FontCharacter",
    [401] = "InitChild2StartBone",
    [402] = "SoundCueLocalized",
    [403] = "SoundCue",
    [404] = "RawDistributionFloat",
    [405] = "RawDistributionVector",
    [406] = "InterpCurveFloat",
    [407] = "InterpCurveVector2D",
    [408] = "InterpCurveVector",
    [409] = "InterpCurveTwoVectors",
    [410] = "InterpCurveQuat",
    [450] = "AI",
    [451] = "NavMesh",
    [500] = "PerformanceCapture",
    [600] = "EditorLayout",
    [601] = "EditorKeyBindings",
    [602] = "GameUserSettings",
    [700] = "Filename",
    [701] = "Lerp",
    [702] = "Root",
}


local consts = {
    MAX_PACKETID = 16384,
    MAX_CHANNELS = 10240,
    MAX_CHSEQUENCE = 1024,
    MAX_CHTYPE = 8,
    MAX_BUNCH_DATA_BITS = 8192,
}


local function hexToBin(str)
    local bin = {}
    for hex in str:gmatch('%x%x') do
        bin[#bin+1] = string.char(tonumber(hex,16))
    end

    return table.concat(bin)
end

---@param b BitBuffer
local function readInt(b, maxValue)
    local mask = 1
    local ret = 0ULL
    while ret+mask < maxValue do
        if b:read_bool() then
            ret = ret + mask
        end
        mask = bit.lshift(mask, 1)
    end

    return ret
end

---@param b BitBuffer
local function readIntPacked(b)
    local ret = 0
    local count = 0
    local hasNext = 1
    while (hasNext > 0) do
        local byte = b:read_u8()
        hasNext = byte % 2
        ret = bit.bor(ret, bit.lshift(bit.rshift(0ULL+byte, 1), 7ULL*count))
        count = count + 1
        if (count >= 4) then break end
    end

    return tonumber(ffi.cast('uint32_t', ret))
end

---@param b BitBuffer
local function readIntPackedOld(b)
    local ret = 0
    local count = 0
    local hasNext = 1
    pcall(function()
        while (hasNext > 0) do
            local byte = b:read_u8()
            hasNext = byte % 2
            ret = bit.bor(ret, bit.lshift(bit.rshift(0ULL+byte, 1), 7ULL*count))
            count = count + 1
        end
    end)
    return tonumber(ffi.cast('int32_t', ret))
end


---@param b BitBuffer
local function SerializePackedVector(b, scale, maxBitsPerComp)
    local bits = readInt(b, maxBitsPerComp)

    local bias = tonumber(bit.lshift(1, bits+1))
    local max = bit.lshift(1, bits+2)

    local dx = tonumber(readInt(b, max))
    local dy = tonumber(readInt(b, max))
    local dz = tonumber(readInt(b, max))

    return {
        (dx - bias) / scale,
        (dy - bias) / scale,
        (dz - bias) / scale,
    }
end

---@param b BitBuffer
local function ConditionallySerializeQuantizedVector(bunch, b, default)
    local bWasSerialized = b:read_bool()
    if not bWasSerialized then return default end

    local bShouldQuantize = b:read_bool()
    if bShouldQuantize then
        p('ser')
        return SerializePackedVector(b, 10, 24)
    end

    return error("FVector<< UNIMPLEMENTED")
end

--- pitch yaw roll
---@param b BitBuffer
local function RotatorSerializeCompressedShort(b)
    local pitch, yaw, roll = 0,0,0
    if b:read_bool() then
        p('ser1')
        pitch = tonumber(b:read_u16())
    end
    if b:read_bool() then
        p('ser2')
        yaw = tonumber(b:read_u16())
    end
    if b:read_bool() then
        p('ser3')
        roll = tonumber(b:read_u16())
    end

    return {
        pitch * 360. / 65536.,
        yaw * 360. / 65536.,
        roll * 360. / 65536.,
    }
end

-- dummy
---@param b BitBuffer
local function serializeObject(b)
    -- SerializeObject
    local netGuid = readIntPacked(b)
    if netGuid == 1 then
        local bHasPath = b:read_bool()
        local bNoLoad = b:read_bool()
        local bHasNetworkChecksum = b:read_bool()
        b:read_bits(5)

        if bHasPath then error("TODO: PARSE PATH NEEDED 4") end
    end

    return netGuid
end


-- bNetInitial = bSpawnedNewActor
-- bNetOwner = sometimes?
-- bIgnoreRPCs = bunch.bIgnoreRPCs
-- 
---@param b BitBuffer
local function receiveReplicationBunch(bunch, b)
    -- ReceiveProperties
    local bDoChecksum = b:read_bool()

    -- ReadPropertyHandle
    local readHandle = readIntPacked(b)
    p('=======================================readHandle',readHandle)
    if bDoChecksum then
        local cs = b:read_u32()
        print(bit.tohex(cs, 8))
        assert(cs == 0xABADF00D, "WRONG CHECKSUM")
    end

end



local actors = {}

-- dummy
---@param b BitBuffer
local function readActorContentBlockHeader(bunch, b)
    bunch.bHasRepLayout = b:read_bool()
    local bIsActor = b:read_bool()
    if bIsActor then return actors[bunch.chIndex] end

    serializeObject(b)

    if bunch._isServer then return {} end

    local bStablyNamed = b:read_bool()
    if bStablyNamed then return {} end

    serializeObject(b)

    return nil
end


---@param b BitBuffer
local function readActorChunk(bunch, b)
    -- ReadContentBlockPayload
    local data = nil
    local s, err = pcall(function()
        local obj = readActorContentBlockHeader(bunch, b)

        local NumPayloadBits = readIntPacked(b)

        data = b:read_bytes(math.floor(NumPayloadBits / 8))
        p('NumPayloadBits', NumPayloadBits)
        if NumPayloadBits % 8 > 0 then
            data = data .. string.char(tonumber(b:read_bits(NumPayloadBits % 8)))
        end
        p('remain', b.length-b.pos)
    end)
    if not s then print(err) end

    return data
end



---@param b BitBuffer
local function receiveActorBunch(bunch, b)
    if bunch.bHasMustBeMappedGUIDs then
        local NumMustBeMappedGUIDs = b:read_u16()
        for i = 1,NumMustBeMappedGUIDs do
            local netGuid = readIntPacked(b)
        end
    end

    -- ...

    -- UActorChannel::ProcessBunch
    local bSpawnedNewActor = false
    local actor = nil
    if actors[bunch.chIndex] == nil then    -- if Actor == nil
        if not bunch.bOpen then error("New actor ch but not open channel") end

        -- UPackageMapClient::SerializeNewActor
        do
            local netGuid = serializeObject(b)

            if netGuid > 0 and netGuid%2 == 0 then  -- IsDynamic and bunch.atEnd
                if bunch.bClose then
                    goto SerializeNewActor_end
                end
            end

            -- actor assigned here
            actor = {}

            if netGuid > 0 and netGuid%2 == 0 then  -- IsDynamic
                serializeObject(b)
                serializeObject(b)

                actor.loc = ConditionallySerializeQuantizedVector(bunch, b, {0,0,0})

                actor.rot = {0,0,0}
                local bSerializeRotation = b:read_bool()
                if bSerializeRotation then
                    actor.rot = RotatorSerializeCompressedShort(b)
                end

                actor.scale = ConditionallySerializeQuantizedVector(bunch, b, {1,1,1})

                actor.vel = ConditionallySerializeQuantizedVector(bunch, b, {0,0,0})

                p(actor)
                bSpawnedNewActor = true
            else
                print('not dynamic')
            end
        end
        ::SerializeNewActor_end::

        if actor == nil then
            if not bSpawnedNewActor and bunch.bReliable and bunch.bClose then -- and bunch.atEnd
                actors[bunch.chIndex] = nil
            else
                error("Failed to find/spawn actor!")
            end
            return
        end

        actors[bunch.chIndex] = actor

        -- NotifyActorChannelOpen -> APlayerController::OnActorChannelOpen
        local playerIndex = b:read_u8()  -- ONLY IF actor is player controller
    end

    -- Read chunks of actor content
    local i = 0
    while b.pos < b.length-1 do
        i=i+1
        p('loop '..i)
        local data = readActorChunk(bunch, b)
        if data and #data > 0 then
            if bunch.bHasRepLayout then
                if bunch._isServer then error("Server received RepLayout props.") end
                receiveReplicationBunch(bunch, b)
            end
        end
    end
end

local channels = {}

---@param b BitBuffer
local function receiveBunch(bunch, b, chType)
    if b.length == 0 then return '' end

    if bunch.bHasPackageMapExports then
        -- ReceiveNetGUIDBunch
        local bHasRepLayoutExport = b:read_bool()
        if bHasRepLayoutExport then error("HAS OLD") end

        local NumGUIDsInBunch = b:read_i32()
        if NumGUIDsInBunch > 2048 then error("NumGUIDsInBunch > MAX_GUID_COUNT") end
        for i = 1,tonumber(NumGUIDsInBunch) do
            local netGuid = readIntPacked(b)
            if netGuid == 1 then
                local bHasPath = b:read_bool()
                local bNoLoad = b:read_bool()
                local bHasNetworkChecksum = b:read_bool()
                b:read_bits(5)

                if bHasPath then error("TODO: PARSE PATH NEEDED 1") end
            end
        end
    end

    -- end

    local data
    if chType == 'Actor' then
        -- if actors[bunch.chIndex] == nil then
            local bSpawnedNewActor = receiveActorBunch(bunch, b)
        -- end
        if b.length == b.pos then return '' end

        data = b:read_bytes(b.length-b.pos-1)
        -- if b.bitpos > 0 then
        data = data .. string.char(tonumber(b:read_bits(8-b.bitpos)))
    else
        data = b:read_bytes(b.length-b.pos-1)
        -- if b.bitpos > 0 then
        data = data .. string.char(tonumber(b:read_bits(8-b.bitpos)))
    end

    return data
end


local parse1
---@param pkt string
local function parse(isServer, pkt)

    -- print("\n\nPKT")
    -- for i=3,3 do
    --     local b = BitBuffer.from(pkt)
    --     for _=1,i do
    --         b:read_bool()
    --     end
    --     local str = b:read_bytes(b.length-1)
    --     str = str .. string.char(tonumber(b:read_bits(8-3)))
    --     local hex = ''
    --     for j=1,#str do
    --         hex = hex..(bit.tohex(str:byte(j), 2)).." "
    --     end
    --     print(hex)
    -- end


    -- 2128-2160
    -- do
    --     local i = 118-32-64

    --     local b = BitBuffer.from(pkt)
    --     for _=1,i do
    --         b:read_bool()
    --     end

    --     -- local a = readInt(b, 8)
    --     -- print('chtype', a)

    --     p(b:read_bytes(12))

    --     -- before: 011 111 111 101 000 000
    --     local bitlen = tonumber( readInt(b, 8192))
    --     p(bit.tohex(bitlen))
    --     print(i, bitlen)

    --     local str = b:read_bytes((bitlen/8))

    --     p(str)
    -- end
    -- do return {} end

    -- for i=0,128 do
    --     print("\nSHIFT "..i)
    --     local b = BitBuffer.from(pkt)

    --     for _=1,i do
    --         b:read_bool()
    --     end

    --     local succ, a = pcall(parse1, isOut, b)
    --     if succ then
    --         succ = false
    --         if a.bunches then
    --             for _,v in ipairs(a.bunches) do if v.data and #v.data > 0 then succ=true break end end
    --         end
    --         if succ then p(i,a) end
    --     else print(' ', a) end
    -- end

    local s,r = xpcall(parse1, debug.traceback, isServer, BitBuffer.from(pkt))

    if s then
        if not r.bunches or not r.bunches[1] then
            if r.header and r.header.bHasPacketInfoPayload then
                print("Jitter", tonumber(r.header.PacketJitterClockTimeMS))
            elseif not r.IsHandshake then
                p(r)
            end
            return {}
        end
        for i,v in ipairs(r.bunches or {}) do
            if v.chIndex then
                if not channels[v.chIndex] then channels[v.chIndex] = {names = {}, datas = {}, } end
                local t = channels[v.chIndex]
                t.names[#t.names+1] = v.ChName.name
                t.datas[#t.datas+1] = {
                    seq = v.chSeq,
                    data = v.data
                }
                -- p(i, v.ChName.name, v.bHasPackageMapExports, v.data)
                if v.data:find('$:\022p\146\026\133p\fDHD') then -- game specific
                    p('\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
                end
                p(i, v.ChName.name, receiveBunch(v, BitBuffer.from(v.data), v.ChName.name))
            end
        end
        return r.bunches
    end
    print(("???: #%d at %d: %s"):format(#pkt, r:match("parse.lua:(%d+): in function 'fn'"), r))
    return {}

    -- return {}
end

local IsInternalAck = false -- 0
local deltaNonZero = true

---@param b BitBuffer
parse1 = function(isServer, b)
    local t = {}

    t.IsHandshake = b:read_bool()
    -- TODO handle: StatelessConnectHandlerComponent::Incoming
    if t.IsHandshake then
        print('[TODO: Handshake]')
        return t
    end

    -- TODO last '1' bit in buffer is the buffer's end
    local last = 0ULL + b[b.length-1]


    -- t.packetId = readInt(b, consts.MAX_PACKETID)

    if not IsInternalAck then
        t.header = {}
        -- PacketNotify.ReadHeader
        local packedHeader = b:read_u32()
        t.header.Seq = tonumber(bit.band( bit.rshift(packedHeader, (4+14)), 0x3FFF ))
        t.header.AckedSeq = tonumber(bit.band( bit.rshift(packedHeader, 4), 0x3FFF ))
        t.header.HistoryWordCount = tonumber(bit.band(packedHeader, 0x0F)) + 1

        -- Data.History.Read
        local n = math.min(t.header.HistoryWordCount, 8)
        t.header.History = {}
        for i = 1,n do
            t.header.History[i] = tonumber(b:read_u32())
        end

        t.header.bHasPacketInfoPayload = b:read_bool()
        if (t.header.bHasPacketInfoPayload) then
            t.header.PacketJitterClockTimeMS = readInt(b, 1024)
        end

        if deltaNonZero then
            -- ReadPacketInfo
            if t.header.bHasPacketInfoPayload then
                local bHasServerFrameTime = b:read_bool()
                if bHasServerFrameTime then
                    t.header.ServerFrameTime = b:read_u8()
                end
            end
        end

    end

    t.bunches = {}

    while (b.pos < b.length-1) do
        -- print("  DAT")
        local x = {}
        t.bunches[#t.bunches+1] = x
        x._isServer = isServer

        -- x.isAck = b:read_bool()
        -- if x.isAck then
        --     x.ackPacketId = readInt(b, consts.MAX_PACKETID)
        --     x.bHasServerFrameTime = b:read_bool()
        --     x.remoteInKBytesPerSecond = readIntPacked(b)
        -- else
            x.bControl = b:read_bool()
            if x.bControl then
                x.bOpen = b:read_bool()
                x.bClose = b:read_bool()
                if x.bClose then
                    -- error("CLOSE SEEN, HANDLE THIS")
                    -- x.bDormant = b:read_bool()
                    x.closeReason = readInt(b,15)
                    assert(x.closeReason < 6, "Invalid close reason")
                end
            end

            x.bIsReplicationPaused = b:read_bool()
            x.bReliable = b:read_bool()
            -- x.chIndex = readInt(b, consts.MAX_CHANNELS)
            -- if (isOut) then x.chIndex = x.chIndex + 10240 end
            local s, chIndex = pcall(readIntPacked, b)
            if not s then return t end
            x.chIndex = chIndex
            if (x.chIndex >= 32767) then error("Bunch channel index exceeds channel limit") end
            -- TODO bAllowExistingChannelIndex
            --b:read_bool() --?
            x.bHasPackageMapExports = b:read_bool()
            x.bHasMustBeMappedGUIDs = b:read_bool()
            x.bPartial = b:read_bool()

            if x.bReliable then
                x.chSeq = tonumber(readInt(b, consts.MAX_CHSEQUENCE))
                -- x.chSeq = 0
            elseif x.bPartial then
                x.chSeq = t.packetId
            else
                x.chSeq = 0
            end

            if x.bPartial then
                x.bPartialInitial = b:read_bool()
                x.bPartialFinal = b:read_bool()
            end

            -- p(x)
            if x.bReliable or x.bOpen then
                -- UPackageMap::StaticSerializeName
                local bHardcoded = b:read_bool()

                if bHardcoded then
                    local nameIndex = readIntPacked(b)
                    -- if (nameIndex > 702) then error("Hardcoded name out of bounds") end
                    if (not NAMES[nameIndex]) then error("Hardcoded name out of bounds") end
                    x.ChName = {
                        name = NAMES[nameIndex]
                    }
                else
                    local strlen = b:read_i32()
                    if (strlen < 0) then error("TODO: UTF16 UNSUPPORTED YET") end
                    local str = b:read_bytes(strlen)
                    local num = tonumber(b:read_i32())
                    x.ChName = {
                        name = str,
                        index = num
                    }
                end
            else
                x.ChName = {
                    name = "None"
                }
            end

            x.bunchDataBits = tonumber(readInt(b, consts.MAX_BUNCH_DATA_BITS))

            -- if x.chType > 4 then
            --     print("WARNING: Unknown chType "..tonumber(x.chType))
            --     return t
            -- end
            -- if x.chType > 2 then
            --     b:read_bytes(math.floor(x.bunchDataBits / 8))
            --     b:read_bits(x.bunchDataBits % 8)
            -- elseif x.chType == 1 and not isOut then
            --     b:read_bytes(math.floor(x.bunchDataBits / 8))
            --     b:read_bits(x.bunchDataBits % 8)
            -- else
                local succ, err = pcall(function()
                    x.data = b:read_bytes(math.floor(x.bunchDataBits / 8))
                    if x.bunchDataBits % 8 > 0 then
                        x.data = x.data .. string.char(tonumber(b:read_bits(x.bunchDataBits % 8)))
                    end
                end)
                if not succ then
                    -- print(err)
                    return t
                end
            -- end
            -- p(x)
        -- end
    end
    return t
end


-- p(parse(true, hexToBin "a0cb6c2401000000fe6f02c091ff0250002080245c981300000060"))
-- p(parse(true, hexToBin "a0cb7424010000006661"))
-- p(parse(false, hexToBin "8091f43201000000fe8f00f8f2bf001c184800000088892912ca8181a90118"))
-- p(parse(false, hexToBin "a091fc32030000000c"))

local fs = require 'fs'

local s = assert(fs.readFileSync('in2.txt'))

local i = 1
for src, dst, hex in s:gmatch("(%d+)%s+(%d+)%s+([0-9A-Fa-f]+)\r?\n") do
    src = tonumber(src)

    -- packet to be read by client?
    local isClient = (src >= 30000 and src < 32768)
    print("\n===== PACKET NUM : "..i..' : '..(isClient and "<-- CLIENT READ" or "--> SERVER READ"))
    parse(not isClient, hexToBin(hex))
    i=i+1
end


-- p(channels)

--[[
local function parse(isOut, pkt)
    print("PKT")
    local b = BitBuffer.from(pkt)
    local t = {}

    t.IsHandshake = b:read_bool()
    -- TODO handle: StatelessConnectHandlerComponent::Incoming
    if t.IsHandshake then return t end

    -- t.IsEncrypted = b:read_bool()
    if t.IsHandshake then
        print("WARNING: encrypted packet, ending")
        return t
    end


    -- TODO last '1' bit in buffer is the buffer's end
    local last = 0ULL + b[b.length-1]



    t.packetId = readInt(b, consts.MAX_PACKETID)
    t.bunches = {}

    while (b.pos < b.length-1) do
        print("  DAT")
        local x = {}
        t.bunches[#t.bunches+1] = x

        x.isAck = b:read_bool()
        if x.isAck then
            x.ackPacketId = readInt(b, consts.MAX_PACKETID)
            x.bHasServerFrameTime = b:read_bool()
            x.remoteInKBytesPerSecond = readIntPacked(b)
        else
            x.bControl = b:read_bool()
            if x.bControl then
                x.bOpen = b:read_bool()
                x.bClose = b:read_bool()
                if x.bClose then
                    x.bDormant = b:read_bool()
                end
            end

            x.bIsReplicationPaused = b:read_bool()
            x.bReliable = b:read_bool()
            x.chIndex = readInt(b, consts.MAX_CHANNELS)
            if (isOut) then x.chIndex = x.chIndex + 10240 end
            --b:read_bool() --?
            x.bHasPackageMapExports = b:read_bool()
            x.bHasMustBeMappedGUIDs = b:read_bool()
            x.bPartial = b:read_bool()

            if x.bReliable then
                x.chSeq = readInt(b, consts.MAX_CHSEQUENCE)
            elseif x.bPartial then
                x.chSeq = t.packetId
            end

            -- if x.bPartial then
            --     x.bPartialInitial = b:read_bool()
            --     x.bPartialFinal = b:read_bool()
            -- end

            if x.bReliable or x.bOpen then
                x.chType = readInt(b, consts.MAX_CHTYPE)
            else
                x.chType = 0ULL
            end

            x.bunchDataBits = tonumber(readInt(b, consts.MAX_BUNCH_DATA_BITS))
            print(x.bunchDataBits)

            if x.chType > 4 then
                print("WARNING: Unknown chType "..tonumber(x.chType))
                return t
            end
            if x.chType > 2 then
                b:read_bytes(math.floor(x.bunchDataBits / 8))
                b:read_bits(x.bunchDataBits % 8)
            elseif x.chType == 1 and not isOut then
                b:read_bytes(math.floor(x.bunchDataBits / 8))
                b:read_bits(x.bunchDataBits % 8)
            else
                local succ, err = pcall(function() 
                    print(b.pos, b.bitpos, b.length-b.pos)
                    x.data = b:read_bytes(math.floor(x.bunchDataBits / 8))
                    if x.bunchDataBits % 8 > 0 then
                        x.data = x.data .. string.char(tonumber(b:read_bits(x.bunchDataBits % 8)))
                    end
                end)
                if not succ then
                    print(err)
                    return t
                end
            end
        end
    end
    return t
end

]]
