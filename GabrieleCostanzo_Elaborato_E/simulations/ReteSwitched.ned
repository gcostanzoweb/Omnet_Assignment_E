//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/.
// 

package gabrielecostanzo_elaborato_e.simulations;

import inet.networklayer.configurator.ipv4.Ipv4NetworkConfigurator;
import inet.node.ethernet.EtherSwitch;
import inet.node.inet.StandardHost;
import inet.queueing.classifier.WrrClassifier;
import inet.queueing.classifier.PriorityClassifier;
import inet.queueing.queue.PacketQueue;
import inet.queueing.queue.CompoundPacketQueue;
import inet.queueing.queue.PriorityQueue;
import inet.queueing.scheduler.PriorityScheduler;
import inet.visualizer.integrated.IntegratedMultiVisualizer;
import inet.networklayer.ipv4.RoutingTableRecorder;
import inet.physicallayer.ieee80211.packetlevel.Ieee80211ScalarRadioMedium;
import inet.common.misc.ThruputMeteringChannel;

// Taken from inet/tutorials/queueing
module CompoundPriorityQueue extends CompoundPacketQueue
{
    parameters:
        @class(::inet::queueing::CompoundPacketQueue);
    submodules:
        classifier: WrrClassifier {
            @display("p=100,100");
        }
        queue1: PacketQueue {
            @display("p=325,100");
        }
        queue2: PacketQueue {
            @display("p=325,225");
        }
        queue3: PacketQueue {
            @display("p=475,350");
        }          
        scheduler: PriorityScheduler {
            @display("p=550,100");
        }
    connections:
        in --> { @display("m=w"); } --> classifier.in;
        classifier.out++ --> queue1.in;
        classifier.out++ --> queue2.in;
        classifier.out++ --> queue3.in;
        queue1.out --> scheduler.in++;
        queue2.out --> scheduler.in++;
        queue3.out --> scheduler.in++;
        scheduler.out --> { @display("m=e"); } --> out;
}

network ReteSwitched
{
    parameters:
        @display("bgb=1230.762,856.138");
        int customDatarate;
        int numQ;
    types:
        channel C extends ThruputMeteringChannel
        {
            delay = 01us;
            datarate = customDatarate * 1Gbps;
        }
    submodules:
        radioMedium: Ieee80211ScalarRadioMedium {
            @display("p=1081.88,211.56001");
        }
        visualizer: IntegratedMultiVisualizer {
            @display("p=1081.88,342.28");
        }
        routingTableRecorder: RoutingTableRecorder {
            parameters:
                @display("p=1081.88,457.52002;is=s");
        }
        configurator: Ipv4NetworkConfigurator {
            @display("p=1081.88,106.64001");
        }
        host1: StandardHost {
            @display("p=485.04,96.32");
            gates:
                ethg[1];
        }
        host2: StandardHost {
            @display("p=632.96,94.600006");
            gates:
                ethg[1];
        }
        host3: StandardHost {
            @display("p=765.4,213.28001");
            gates:
                ethg[1];
        }
        host4: StandardHost {
            @display("p=784.32,431.72");
            gates:
                ethg[1];
        }
        host5: StandardHost {
            @display("p=485.04,753.36005");
            gates:
                ethg[1];
        }
        host6: StandardHost {
            @display("p=717.24005,734.44");
            gates:
                ethg[1];
        }
        host7: StandardHost {
            @display("p=784.32,583.08");
            gates:
                ethg[1];
        }
        host8: StandardHost {
            @display("p=111.8,431.72");
            gates:
                ethg[1];
        }
        switch: EtherSwitch {
            parameters:
                @display("p=485.04,431.72");
            gates:
                ethg[8];
        }
        //queue: PriorityQueue {
        //    parameters:
        //        @display("p=325,100,column,125");
        //        numQueues = numQ;
	    //        scheduler: PriorityScheduler {
		//            parameters:
		//                @display("p=550,100");
	    //    	}
	    //    	classifier: PriorityClassifier {
		//            parameters:
		//                @display("p=100,100");
		//        }
		//}
		
		cQueue: CompoundPriorityQueue {
			parameters:
				@display("p=100,100");
		}
        
        
    connections:
        switch.ethg[0] <--> C <--> host1.ethg[0];
        switch.ethg[1] <--> C <--> host2.ethg[0];
        switch.ethg[2] <--> C <--> host3.ethg[0];
        switch.ethg[3] <--> C <--> host4.ethg[0];
        switch.ethg[4] <--> C <--> host5.ethg[0];
        switch.ethg[5] <--> C <--> host6.ethg[0];
        switch.ethg[6] <--> C <--> host7.ethg[0];
        switch.ethg$i[7] <-- C <-- host8.ethg$o[0];
        //switch.ethg$o[7] --> C --> classifier.in;
        //classifier.out++ --> queue.in;
        //queue.out --> scheduler.in++;
        //scheduler.out --> C --> host8.ethg$i[0];
        switch.ethg$o[7] --> C --> cQueue.in;
        cQueue.out --> C --> host8.ethg$i[0];
}

