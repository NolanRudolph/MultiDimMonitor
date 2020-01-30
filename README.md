Simple UDP packet generator for sending and receiving small bits of data. Created with the Snabb framework.

**Requirements** 
1. Snabb binary file 
2. Snabb compatible NIC
3. Apache Cassandra

(1) One can easily create this requirement by following the "How do I get started?" section from Snabb's GitHub: https://github.com/snabbco/snabb.git.  
(2) The list of compatible NICs is provided by this link: https://github.com/snabbco/snabb/blob/master/src/lib/hardware/pci.lua, line 61.
(3) See number 5. in **Setup**

**Setup**
1. Begin in your home directory 
2. Clone this repository: https://github.com/NolanRudolph/MultiDimSnabb.git
3. Clone the snabb repository: https://github.com/snabbco/snabb.git
4. cd MultiDimMonitor
5. (If debian) bash debian_install_cassandra.sh, otherwise follow http://cassandra.apache.org/download/
6. bash automake.sh
7. A binary executable named "snabb" can be found in ~/snabb/src. Call ```~/snabb/src/snabb MultiDimSnabb``` to acquire instructions on how to run my program

**Client**  
For client nodes looking to spam a server with UDP packets, make sure to run ```~/snabb/src/snabb MultiDimSnabb Client --help``` for more information.

**Server**  
For server nodes looking to receive said spam provided by clients, make sure to run ```~/snabb/src/snabb MultiDimSnabb Server --help``` for more information.

All personal user space tests were ran on a pair of c220g2 nodes (Intel X520 10Gb NIC) on CloudLab, using profile ConTools/Snabb: https://www.cloudlab.us/p/3ea481ea-db43-11e9-b1eb-e4434b2381fc.
