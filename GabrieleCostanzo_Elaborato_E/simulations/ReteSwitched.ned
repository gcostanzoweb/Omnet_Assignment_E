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
    connections:
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
        int multiplier = default(1);
        
        host[0].app[0].sendInterval = multiplier*100ns;
		host[1].app[0].sendInterval = multiplier*200ns;
		host[2].app[0].sendInterval = multiplier*300ns;
		host[3].app[0].sendInterval = multiplier*400ns;
		host[4].app[0].sendInterval = multiplier*500ns;
		host[5].app[0].sendInterval = multiplier*600ns;
		host[6].app[0].sendInterval = multiplier*700ns;
    types:
        channel C extends ThruputMeteringChannel
        {
            delay = 01us;
            datarate = customDatarate * 1Gbps;
        }
    submodules:
    	// Moduli di diagnostica
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

		// Rete effettiva
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
}

