/*
 *  Custom Snitch built for MultiDimMonitor
 *
 *  Q: Why so many directories to get here?
 *  A: It's just how Maven finds files ¯\_(ツ)_/¯
*/

package io.custom;

import java.io.BufferedWriter;
import java.io.FileWriter;
//import java.io.IOException;
import java.net.InetAddress;
import java.util.List;

import org.apache.cassandra.locator.AbstractEndpointSnitch;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CustomSnitch extends AbstractEndpointSnitch
{

        // For debug purposes
        protected static final Logger logger = LoggerFactory.getLogger(CustomSnitch.class);

        public CustomSnitch()
        {
            logger.info("CustomSnabb Snitch Loaded Successfully.");
        }

        public String getRack(InetAddress endpoint)
        {
            return "rack1";
        }

        public String getDatacenter(InetAddress endpoint)
        {
            return "datacenter1";
        }

        @Override
        public void sortByProximity(final InetAddress address, List<InetAddress> addresses)
        {
            return;
        }

        @Override
        public int compareEndpoints(InetAddress target, InetAddress rep1, InetAddress rep2)
        {
            // Making all endpoints equal ensures we won't change the original ordering (since
            // Collections.sort is guaranteed to be stable)
            return 0;
        }
}
