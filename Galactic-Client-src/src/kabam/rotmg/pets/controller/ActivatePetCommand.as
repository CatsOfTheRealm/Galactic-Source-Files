﻿package kabam.rotmg.pets.controller {
import kabam.lib.net.api.MessageProvider;
import kabam.lib.net.impl.SocketServer;
import kabam.rotmg.messaging.impl.GameServerConnection;
import kabam.rotmg.messaging.impl.outgoing.ActivePetUpdateRequest;
import kabam.rotmg.pets.util.PetsConstants;

import robotlegs.bender.bundles.mvcs.Command;

public class ActivatePetCommand extends Command {

    [Inject]
    public var instanceID:uint;
    [Inject]
    public var messages:MessageProvider;
    [Inject]
    public var server:SocketServer;


    override public function execute():void {
        var _local1:ActivePetUpdateRequest = (this.messages.require(GameServerConnection.ACTIVE_PET_UPDATE_REQUEST) as ActivePetUpdateRequest);
        _local1.instanceid = this.instanceID;
        _local1.commandtype = PetsConstants.INTERACTING;
        this.server.queueMessage(_local1);
    }


}
}
