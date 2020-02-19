module(..., package.seeall)

-- Config and utility requirements
local config     = require("core.config")
local lib        = require("core.lib")

-- App association requirements
local app        = require("core.app")
local link       = require("core.link")
local Intel82599 = require("apps.intel_mp.intel_mp").Intel82599
local LoadGen    = require("apps.intel_mp.loadgen").LoadGen
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

net_eths = {}

Generator = {}

function Generator:new(args)
	--[[ Node Stuff ]]--
	dst_file = args["dst_file"]
	local f = io.open(dst_file, "r")
	io.input(f)

	-- Check to see if file exists
	if f == nil then
		print("File does not exist.")
		main.exit(1)
	end

	local num_nodes = tonumber(io.read())

	local dst_eths = {}
	for i = 1, num_nodes do
		local rec = io.read()
		table.insert(dst_eths, ethernet:pton(rec))
		net_eths[rec] = 0
	end

	--[[ Packet Stuff ]]--
	local src_eth = args["src_eth"]

    local ether = ethernet:new(
    {
        src = ethernet:pton(src_eth),
		-- VLAN Ethernet Type
        type = 0x8100
    })

	local ip = ipv4:new(
	{
		ihl = 0x4500,
        src = ipv4:ntop("192.168.1.1"),
        dst = ipv4:ntop("192.168.1.4"),
		--dscp = 1,
		ttl = 255,
		--protocol = 17
	})

--[[
	local udp = _udp:new(
	{
		src_port = 7000,
		dst_port = 7000
	})
--]]

	local o = 
	{ 
		eth = ether,
		ip = ip,
		--udp = udp,
		nodes = dst_eths,
		num_nodes = num_nodes,
		cur_node = 1,
		wait = 0
	}

	return setmetatable(o, {__index = Generator})
end

function Generator:gen_packet()
	local addr = self.nodes[self.cur_node]
	print("Pinging Node " .. tostring(self.cur_node) .. " | Addr: " .. ethernet:ntop(addr))

	self.eth:dst(addr)
    local dgram = datagram:new()
	--self.dgram:push(self.udp)
	dgram:push(self.ip)
    dgram:push(self.eth)

    local p = dgram:packet()
    -- Start timer right before transmitting packet
	net_eths[ethernet:ntop(addr)] = os.clock()
	link.transmit(self.output.output, p)
	
	if self.cur_node == self.num_nodes then
		self.cur_node = 1
	else
		self.cur_node = self.cur_node + 1
	end
	
	return
end

function Generator:pull()
	if self.wait == 400000 then
		self.wait = 0
		i = 0
		best_i = 0
		best = 100
		print("\n------- TIMES --------")
		for _, t in pairs(net_eths) do
			i = i + 1
			if t < best then
				best_i = i
				best = t
			end	
            if t > 1 then
                print("Replica" .. i .. " : OFFLINE")
            else
                print("Replica" .. i .. " : " .. t)
            end
		end
		print("----------------------")
		print("BEST NODE: Replica" .. best_i)
		print("----------------------\n")
	elseif self.wait % 100000 == 0 then
		self.wait = self.wait + 1
		self:gen_packet()
	else
		self.wait = self.wait + 1
	end
end

function Generator:push()
	assert(self.input.input, "Could not locate input port.")
	local i = self.input.input
	while not link.empty(i) do
		local temp_time = os.clock()
		local p = link.receive(i)

		local dgram = datagram:new(p, ethernet)
		dgram:parse_n(1)

		local eth = unpack(dgram:stack())
		local eth_src = tostring(ethernet:ntop(eth:src()))
        local eth_type = eth:type()
        print("Type is " .. tostring(eth_type))
        for key, _ in pairs(net_eths) do
            if key == eth_src and eth_type == 20 then
                -- Get the net time the request took
                print("Eth: " .. eth_src .. " (" .. net_eths[eth_src] .. ", " .. temp_time .. ")")
                net_eths[eth_src] = temp_time - net_eths[eth_src]
            end
        end

		packet.free(p)
	end
end

function show_usage(code)
	print(require("program.MultiDimSnabb.Server.README_inc"))
	main.exit(code)
end

function run(args)
	x = os.clock()
	if #args ~= 3 then show_usage(1) end
	local c = config.new()

	local IF       = args[1]
	local src_eth  = args[2]
	local dst_file = args[3]

	config.app(c, "generator", Generator, 
	{
		src_eth = src_eth,
		dst_file = dst_file
	})

	local RawSocket = raw_sock.RawSocket
	config.app(c, "server", RawSocket, IF)

	config.link(c, "generator.output -> server.rx")
	config.link(c, "server.tx -> generator.input")

	engine.busywait = true
	engine.configure(c)
	engine.main({duration = 100})
	
	print("Completed 100s.")
end
