module(..., package.seeall)

-- Config and utility requirements
local config     = require("core.config")
local lib        = require("core.lib")

-- App association requirements
local app        = require("core.app")
local link       = require("core.link")
local raw_sock   = require("apps.socket.raw")

-- Packet creation requirements
local packet     = require("core.packet")
local datagram   = require("lib.protocol.datagram")
local ethernet   = require("lib.protocol.ethernet")
local ipv4       = require("lib.protocol.ipv4")
local _udp       = require("lib.protocol.udp")

-- C function requirements
local ffi = require("ffi")
local C = ffi.c


-- This is used to determine if our program has finished
req_complete = false

-- Snabb must instantiate an object preemptively for links
Requester = {}

function Requester:new(args)
    local src_eth = args["src_eth"]
    local dst_eth = args["dst_eth"]
    local req_key = args["req_key"]

    local ether = ethernet:new(
    {
        src = ethernet:pton(src_eth),
        dst = ethernet:pton(dst_eth),
		-- VLAN Ethernet Type
        type = 0x0800
    })

    local ip = ipv4:new(
    {
        ihl = 0x4500,
        src = ipv4:ntop("192.168.1.0"),
        dst = ipv4:ntop("192.168.1.1"),
        ttl = 255,
        protocol = 17
    })

    local udp = _udp:new(
    {
        src_port = 7000,
        dst_port = 7000
    })

    local dgram = datagram:new()
    dgram:push(udp)
    dgram:push(ip)
    dgram:push(ether)
    -- Include message to server
    payload = "key" .. req_key
    dgram:payload(payload, 3 + string.len(req_key))

    local o =
    { 
        exp_eth_src = dst_eth,
        exp_eth_dst = src_eth,
        p = dgram:packet()
    }

    return setmetatable(o, {__index = Requester})
end

function Requester:pull()
    assert(self.output.output, "Could not locate output port.")
    print("Sending packet...")
    link.transmit(self.output.output, packet.clone(self.p))
    os.execute("sleep 2")
end

function Requester:push()
    assert(self.output.output, "Could not locate output port.")
    assert(self.input.input, "Could not locate input port.")
    local i = self.input.input
    local o = self.output.output
    while not link.empty(i) do
        local p = link.receive(i)

        local dgram = datagram:new(p, ethernet)
        dgram:parse_n(3)

        -- Get Payload
        local payload, _ = dgram:payload()
        payload = ffi.string(payload)
        local sig = string.sub(payload, 1, 3)

        -- Get Ethernet Source
        local eth = unpack(dgram:stack())
        local eth_src = tostring(ethernet:ntop(eth:src()))
        local eth_dst = tostring(ethernet:ntop(eth:dst()))
        if eth_src == self.exp_eth_src and eth_dst == self.exp_eth_dst and sig == "val" then
            print("Received packet")
            print("Value is " .. string.sub(payload, 4, -1))
        end
    end
end

temp_time = os.clock()

function is_done()
    if req_complete then
        return true
    elseif os.clock() - temp_time > 10 then
        return false
    else
        return false
    end
end

function show_usage(code)
    print(require("program.MultiDimSnabb.Client.README_inc"))
    main.exit(code)
end

function run(args)
    if #args ~= 4 then 
	show_usage(1) 
    end

    local c = config.new()

    local IF       = args[1]
    local src_eth  = args[2]
    local dst_eth  = args[3]
    local key      = args[4]

    config.app(c, "requester", Requester, 
    {
        src_eth = src_eth,
        dst_eth = dst_eth,
        req_key = key
    })

    local RawSocket = raw_sock.RawSocket
    config.app(c, "server", RawSocket, IF)

    config.link(c, "requester.output -> server.rx")
    config.link(c, "server.tx -> requester.input")

    engine.busywait = true
    engine.configure(c)
    engine.main({duration = 10})

    print("Completed 10s.")
end
