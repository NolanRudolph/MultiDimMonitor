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

-- Temp req
local raw_sock = require("apps.socket.raw")


Incubator = {}

dataset = {}

function Incubator:new(args)
	local src_eth = args["src_eth"]
        local dst_eth = args["dst_eth"]
	local latency = tonumber(args["latency"])
	local disktype = args["disktype"]

	-- Latency will be x2 b/c A -> B + B -> A
	latency = latency * 2

	-- Disk access time
	if disktype == "HDD" then
		latency = latency + 0.005
	elseif disktype == "SSD" then
		latency = latency + 0.0000001
	else
		print("Unknown disk type.")
		main.exit(1)
	end

	print("My latency is " .. tostring(latency))

	--[[ TEMPORARY UNTIL IEEE 802.1Q IS FIXED ]]--
	local ether = ethernet:new(
        {
                src = ethernet:pton(dst_eth),
		dst = ethernet:pton(src_eth),
                -- VLAN Ethernet Type
                type = 0x8100
        })

        local ip = ipv4:new(
        {
                ihl = 0x4500,
                dscp = 1,
                ttl = 255,
                protocol = 17
        })

        local udp = _udp:new(
        {
                src_port = 123,
                dst_port = 456
        })

	local ret_gram = datagram:new()
	ret_gram:push(udp)
	ret_gram:push(ip)
	ret_gram:push(ether)

        local o =
        {
                eth = ether,
                ip = ip,
                udp = udp,
		p = ret_gram:packet(),
                dgram = datagram:new(),
		latency = latency
        }

	return setmetatable(o, {__index = Incubator})
end

function Incubator:pull()
	assert(self.output.output, "Could not locate output port.")
	assert(self.input.input, "Could not locate input port.")
	local i = self.input.input
	local o = self.output.output
	while not link.empty(i) do
		local p = link.receive(i)
		link.transmit(o, packet.clone(self.p))
	end
end

function show_usage(code)
	print(require("program.MultiDimSnabb.Client.README_inc"))
	main.exit(code)
end

function run(args)
	if #args ~= 5 then show_usage(1) end
	local c = config.new()

	local src_eth  = args[1]
	local dst_eth  = args[2]
	local IF       = args[3]
	local latency  = args[4]
	local disktype = args[5]

	local RawSocket = raw_sock.RawSocket
	config.app(c, "socket", RawSocket, IF)

	config.app(c, "incubator", Incubator, 
	{
		src_eth = src_eth,
		dst_eth = dst_eth,
		latency = latency,
		disktype = disktype
	})

	config.link(c, "socket.tx -> incubator.input")
	config.link(c, "incubator.output -> socket.rx")

	print("Config 1")
	engine.busywait = true
	print("Config 2")
	engine.configure(c)
	print("Config 3")
	engine.main({report = {showlinks = true}})
	print("Config 4")
	
end
