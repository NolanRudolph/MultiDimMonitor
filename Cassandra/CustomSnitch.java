/*
 *  Custom Snitch built for MultiDimMonitor
*/

package org.apache.cassandra.locator;

public class SimpleSnitch extends AbstractNetworkTopologySnitch
{
        public String getRack(InetAddressAndPort endpoint)
        {
            return "rack1";
        }

        public String getDatacenter(InetAddressAndPort endpoint)
        {
            return "datacenter1";
        }

        @Override
        public <C extends ReplicaCollection<? extends C>> C sortedByProximity(final InetAddressAndPort address, C unsortedAddress)
        {
            // Optimization to avoid walking the list
            System.out.println("Returning " + unsortedAddress);
            return unsortedAddress;
        }

        @Override
        public int compareEndpoints(InetAddressAndPort target, Replica r1, Replica r2)
        {
            // Making all endpoints equal ensures we won't change the original ordering (since
            // Collections.sort is guaranteed to be stable)
            return 0;
        }
}
