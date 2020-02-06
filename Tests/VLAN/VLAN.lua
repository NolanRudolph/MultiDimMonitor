module(..., package.seeall)

-- Config and utility requirements
local config     = require("core.config")
local lib        = require("core.lib")

-- App association requirements
local app        = require("core.app")
local link       = require("core.link")
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
		src = ethernet:pton("02:bf:b5:b8:0e:28"),
		dst = ethernet:pton("02:ee:8b:8b:0c:46"),
		type = 0x8100
	})

	local ip = ipv4:new(
	{
		src = ipv4:pton("10.10.1.1"),
		dst = ipv4:pton("10.10.1.2"),
		ihl = 0x4500,
		dscp = 1,
		ttl = 255,
		protocol = 17
	})

	local udp = _udp:new(
	{
		src_port = 1313,
		dst_port = 1515
	})

	local p = datagram:new()
	p:push(udp)
	p:push(ip)
	p:push(ether)

	local o = 
	{ 
		p = p:packet()
	}
	

	return setmetatable(o, {__index = Generator})
end

function Generator:pull()
	print("Pinging...")
	link.transmit(self.output.output, packet.clone(self.p))
	return
end

function run(args)
	local c = config.new()

	config.app(c, "generator", Generator)

	local RawSocket = raw_sock
	config.app(c, "server", RawSocket, "vlan916")

	config.link(c, "generator.output -> server.rx")

	engine.busywait = true
	engine.configure(c)
	engine.main({duration = 5, report = {showlinks = true}})
	
	print("Completed.")
end
