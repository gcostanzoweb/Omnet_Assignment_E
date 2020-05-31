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
import inet.networklayer.diffserv.BehaviorAggregateClassifier;
import inet.queueing.queue.PacketQueue;
import inet.queueing.queue.CompoundPacketQueue;
import inet.queueing.scheduler.PriorityScheduler;
import inet.visualizer.integrated.IntegratedMultiVisualizer;
import inet.networklayer.ipv4.RoutingTableRecorder;
import inet.physicallayer.ieee80211.packetlevel.Ieee80211ScalarRadioMedium;
import inet.common.misc.ThruputMeteringChannel;

module CompoundPriorityQueue extends CompoundPacketQueue
{
    parameters:
        @class(::inet::queueing::CompoundPacketQueue);
    submodules:
        classifier: BehaviorAggregateClassifier {
            @display("p=100,500");
        }
        defQueue: PacketQueue {
            @display("p=325,100");
        }
        queue[7]: PacketQueue {
            @display("p=325,250,c,125");
        }
        scheduler: PriorityScheduler {
            @display("p=550,500");
        }
    connections allowunconnected:
        in --> { @display("m=w"); } --> classifier.in;
        classifier.defaultOut --> defQueue.in;
        defQueue.out --> scheduler.in++;
        for i=0..6 {
            classifier.out++ --> queue[i].in;
            queue[i].out --> scheduler.in++;
        }
        scheduler.out --> { @display("m=e"); } --> out;
}

network ReteSwitched
{
    parameters:
        @display("bgb=1230.762,856.138");
        int customDatarate = default(1);
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


        switch: EtherSwitch {
            parameters:
                @display("p=545,400");
            gates:
                ethg[8];
        }

        host[7]: StandardHost {
            @display("p=345,240,ri,200,200");
            gates:
                ethg[1];
        }

        sinkHost: StandardHost {
            @display("p=110,400");
            gates:
                ethg[1];
        }

    connections:
        for i=0..6 {
            switch.ethg[i] <--> C <--> host[i].ethg[0];
        }
        switch.ethg[7] <--> C <--> sinkHost.ethg[0];

        //switch.ethg[0] <--> C <--> host1.ethg[0];
}

