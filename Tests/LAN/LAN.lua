module(..., package.seeall)

-- Config and utility requirements
local config     = require("core.config")
local lib        = require("core.lib")

-- App association requirements
local app        = require("core.app")
local link       = require("core.link")
local Intel82599 = require("apps.intel_mp.intel_mp").Intel82599
local LoadGen    = require("apps.intel_mp.loadgen").LoadGen
local raw_sock   = require("apps.socket.raw").RawSocket

-- Packet creation requirements
local packet     = require("core.packet")
local datagram   = require("lib.protocol.datagram")
local ethernet   = require("lib.protocol.ethernet")
local ipv4       = require("lib.protocol.ipv4")
local _udp       = require("lib.protocol.udp")

-- C function requirements
local ffi = require("ffi")
local C = ffi.c

Generator = {}

function Generator:new(args)
	local ether = ethernet:new(
	{
		src = ethernet:pton("02:ad:a9:c3:e8:76"),
		dst = ethernet:pton("02:4a:db:e1:03:d4"),
		type = 0x800
	})

	local ip = ipv4:new(
	{
		src = ipv4:pton("192.168.3.1"),
		dst = ipv4:pton("192.168.3.2"),
		ihl = 0x4500,
		dscp = 1,
		ttl = 255,
		protocol = 17
	})

	local udp = _udp:new(
	{
		src_port = 1212,
		dst_port = 1313
	})

	local o = 
	{ 
		eth = ether,
		ip = ip,
		udp = udp,
		dgram = datagram:new(),
	}

	return setmetatable(o, {__index = Generator})
end

function Generator:pull()
	print("Pinging...")

	self.dgram = datagram:new()
	self.dgram:push(self.udp)
	self.dgram:push(self.ip)
	self.dgram:push(self.eth)

	link.transmit(self.output.output, self.dgram:packet())
	return
end

function run(args)
	local c = config.new()

	config.app(c, "generator", Generator)

	local RawSocket = raw_sock
	config.app(c, "server", RawSocket, "vlan917")

	config.link(c, "generator.output -> server.rx")

	engine.busywait = true
	engine.configure(c)
	engine.main({duration = 5})
	
	print("Completed.")
end
