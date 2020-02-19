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
	local disktype = args["disktype"]

	local access_time = 0
	-- Disk access time
	if disktype == "HDD" then
		access_time = 0.005
	elseif disktype == "SSD" then
		access_time = 0.0000001
	else
		print("Unknown disk type.")
		main.exit(1)
	end

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
		exp_ether = src_eth,
		p = ret_gram:packet(),
		access_time = access_time
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
		os.execute("sleep " .. self.access_time)
		local dgram = datagram:new(p, ethernet)
		dgram:parse_n(3)
		local eth, ip, udp = unpack(dgram:stack())
		local eth_src = tostring(ethernet:ntop(eth:src()))
		if (eth_src == self.exp_ether) then
			link.transmit(o, packet.clone(self.p))
		end
	end
end

function show_usage(code)
	print(require("program.MultiDimSnabb.Client.README_inc"))
	main.exit(code)
end

function run(args)
	if #args ~= 4 then show_usage(1) end
	local c = config.new()

	local src_eth  = args[1]
	local dst_eth  = args[2]
	local IF       = args[3]
	local disktype = args[4]

	local RawSocket = raw_sock.RawSocket
	config.app(c, "socket", RawSocket, IF)

	config.app(c, "incubator", Incubator, 
	{
		src_eth = src_eth,
		dst_eth = dst_eth,
		disktype = disktype
	})

	config.link(c, "socket.tx -> incubator.input")
	config.link(c, "incubator.output -> socket.rx")

	engine.busywait = true
	engine.configure(c)
	engine.main({report = {showlinks = true}})
	
end
