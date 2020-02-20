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


-- Snabb must instantiate an object preemptively for links
Incubator = {}

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

    local o =
    {
        exp_src_ether = src_eth,
        exp_dst_ether = dst_eth,
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
		local dgram = datagram:new(p, ethernet, ipv4, _udp)
		dgram:parse_n(3)
		local eth, _, _ = unpack(dgram:stack())
		local eth_src = tostring(ethernet:ntop(eth:src()))
		local eth_dst = tostring(ethernet:ntop(eth:dst()))
		local eth_type = eth:type()
		print("Sorc: ", eth_src)
		print("Type: ", tostring(eth_type))
		if eth_src == self.exp_src_ether and eth_dst == self.exp_dst_ether and eth_type == 20 then
			print("Responding...")
			local telegram = datagram:new()
			eth:swap()
			telegram:push(eth)
			link.transmit(o, telegram:packet())
		end
	end
end

function show_usage(code)
	print(require("program.MultiDimSnabb.Replica.README_inc"))
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
