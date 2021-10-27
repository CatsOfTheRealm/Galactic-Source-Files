package com.company.assembleegameclient.game {
import com.company.assembleegameclient.parameters.Parameters;

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

import kabam.rotmg.chat.model.ChatMessage;
import kabam.rotmg.core.StaticInjectorContext;
import kabam.rotmg.game.signals.AddTextLineSignal;

public class IdleWatcher {

    private static const MINUTE_IN_MS:int = 60 * 1000;//60000
    private static const FIRST_WARNING_MINUTES:int = 4;
    private static const KICK_MINUTES:int = 5;

    public var gs_:GameSprite = null;
    public var idleTime_:int = 0;
    private var addTextLine:AddTextLineSignal;

    public function IdleWatcher() {
        this.addTextLine = StaticInjectorContext.getInjector().getInstance(AddTextLineSignal);
    }

    public function update(elapsedMS:int):Boolean {
        var idleTime:int = this.idleTime_;
        this.idleTime_ = this.idleTime_ + elapsedMS;
        if (this.idleTime_ < FIRST_WARNING_MINUTES * MINUTE_IN_MS) {
            return false;
        }
        if (this.idleTime_ >= FIRST_WARNING_MINUTES * MINUTE_IN_MS && idleTime < FIRST_WARNING_MINUTES * MINUTE_IN_MS) {
            this.addTextLine.dispatch(this.makeFirstWarning());
            return false;
        }
        if (this.idleTime_ >= KICK_MINUTES * MINUTE_IN_MS && idleTime < KICK_MINUTES * MINUTE_IN_MS) {
            this.addTextLine.dispatch(this.makeFinalWarning());
            return true;
        }
        return false;
    }

    private function makeFirstWarning():ChatMessage {
        var msg:ChatMessage = new ChatMessage();
        msg.name = Parameters.ERROR_CHAT_NAME;
        msg.text =
                "You have been idle for " + FIRST_WARNING_MINUTES +
                " minutes, you will be disconnected if you are idle for " +
                "more than " + KICK_MINUTES + " minutes.";
        return msg;
    }

    private function makeFinalWarning():ChatMessage {
        var msg:ChatMessage = new ChatMessage();
        msg.name = Parameters.ERROR_CHAT_NAME;
        msg.text = "You have been idle for " + KICK_MINUTES + " minutes, disconnecting.";
        return msg;
    }


}
}
