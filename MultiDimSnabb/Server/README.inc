Usage: MultiDimSnabb Server <IF> <Src> <Cli> <Dsts>

  IF  : Network Interface
  Src : Source MAC Address
  Cli : Client MAC Address
  Dsts: File Containing Destination MAC Addresses

Example:
  ./snabb MultiDimSnabb Server eth0 00:01:02:03:04:05 00:06:07:08:09:10 dsts.txt

dsts.txt:
  3   <-- Number of Nodes to Send to
  00:09:08:07:06:05   <-- First Node MAC Address
  00:04:03:02:01:00   <-- Second Node MAC Address
  00:09:03:08:04:07   <-- Third Node MAC Address
