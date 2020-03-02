/*
 *  Custom Snitch built for MultiDimMonitor
 *
 *  Q: Why so many directories to get here?
 *  A: It's just how Maven finds files ¯\_(ツ)_/¯
*/

package io.custom;

import java.net.InetAddress;
import java.util.List;

import org.apache.cassandra.locator.AbstractEndpointSnitch;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CustomSnitch extends AbstractEndpointSnitch
{

        // All debug appended to /var/log/cassandra/system.log
        protected static final Logger logger = LoggerFactory.getLogger(CustomSnitch.class);

        public CustomSnitch()
        {
            logger.info("Custom Snitch Loaded Successfully.");
        }

        @Override
        public String getRack(InetAddress endpoint)
        {
            logger.info("Got rack request for " + endpoint.toString());
            return "rack1";
        }

        public String getDatacenter(InetAddress endpoint)
        {
            logger.info("Got datacenter request for " + endpoint.toString());
            return "datacenter1";
        }

        @Override
        public void sortByProximity(final InetAddress address, List<InetAddress> addresses)
        {
            logger.info("Got proximity request for " + address.toString());
            for (int i = 0; i < addresses.size(); i++)
            {
                logger.info(addresses.get(i).toString());
            }
            return;
        }

        @Override
        public int compareEndpoints(InetAddress target, InetAddress rep1, InetAddress rep2)
        {
            logger.info("Does this even get called?");
            // Making all endpoints equal ensures we won't change the original ordering (since
            // Collections.sort is guaranteed to be stable)
            return 0;
        }
}
