package com.company.assembleegameclient.game {
import com.company.assembleegameclient.game.events.MoneyChangedEvent;
import com.company.assembleegameclient.map.Map;
import com.company.assembleegameclient.objects.GameObject;
import com.company.assembleegameclient.objects.IInteractiveObject;
import com.company.assembleegameclient.objects.ObjectLibrary;
import com.company.assembleegameclient.objects.Pet;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.objects.Projectile;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.tutorial.Tutorial;
import com.company.assembleegameclient.ui.GuildText;
import com.company.assembleegameclient.ui.RankText;
import com.company.assembleegameclient.ui.menu.PlayerMenu;
import com.company.assembleegameclient.util.TextureRedrawer;
import com.company.assembleegameclient.util.TierUtil;
import com.company.assembleegameclient.util.TileRedrawer;
import com.company.assembleegameclient.util.redrawers.GlowRedrawer;

import kabam.rotmg.messaging.impl.GameServerConnection;

import com.company.ui.BaseSimpleText;
import com.company.util.CachingColorTransformer;
import com.company.util.MoreColorUtil;
import com.company.util.PointUtil;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.ColorMatrixFilter;
import flash.filters.DropShadowFilter;
import flash.system.System;
import flash.utils.ByteArray;
import flash.utils.getTimer;

import kabam.lib.loopedprocs.LoopedCallback;
import kabam.lib.loopedprocs.LoopedProcess;
import kabam.rotmg.arena.view.ArenaTimer;
import kabam.rotmg.arena.view.ArenaWaveCounter;
import kabam.rotmg.chat.view.Chat;
import kabam.rotmg.constants.GeneralConstants;
import kabam.rotmg.core.StaticInjectorContext;
import kabam.rotmg.core.model.MapModel;
import kabam.rotmg.core.model.PlayerModel;
import kabam.rotmg.core.view.Layers;
import kabam.rotmg.dailyLogin.signal.ShowDailyCalendarPopupSignal;
import kabam.rotmg.dialogs.control.AddPopupToStartupQueueSignal;
import kabam.rotmg.dialogs.control.FlushPopupStartupQueueSignal;
import kabam.rotmg.dialogs.control.OpenDialogSignal;
import kabam.rotmg.dialogs.model.DialogsModel;
import kabam.rotmg.dialogs.model.PopupNamesConfig;
import kabam.rotmg.game.view.CreditDisplay;
import kabam.rotmg.game.view.GiftStatusDisplay;
import kabam.rotmg.game.view.NewsModalButton;
import kabam.rotmg.maploading.signals.HideMapLoadingSignal;
import kabam.rotmg.maploading.signals.MapLoadedSignal;
import kabam.rotmg.messaging.impl.GameServerConnectionConcrete;
import kabam.rotmg.messaging.impl.incoming.MapInfo;
import kabam.rotmg.news.model.NewsModel;
import kabam.rotmg.news.view.NewsTicker;
import kabam.rotmg.news.view.NewsTicker2;
import kabam.rotmg.packages.services.PackageModel;
import kabam.rotmg.packages.view.PackageButton;
import kabam.rotmg.questrewards.view.QuestRewardsPanel;
import kabam.rotmg.servers.api.Server;
import kabam.rotmg.stage3D.Renderer;
import kabam.rotmg.ui.UIUtils;
import kabam.rotmg.ui.view.HUDView;

import org.osflash.signals.Signal;

public class GameSprite extends AGameSprite {

    protected static const PAUSED_FILTER:ColorMatrixFilter = new ColorMatrixFilter(MoreColorUtil.greyscaleFilterMatrix);

    public const modelInitialized:Signal = new Signal();
    public const drawCharacterWindow:Signal = new Signal(Player);

    public var chatBox_:Chat;
    public var isNexus_:Boolean = false;
    public var idleWatcher_:IdleWatcher;
    public var rankText_:RankText;
    public var guildText_:GuildText;
    public var creditDisplay_:CreditDisplay;
    public var giftStatusDisplay:GiftStatusDisplay;
    public var newsModalButton:NewsModalButton;
    public var newsTicker:NewsTicker;
    public var newsTicker2:NewsTicker2;
    public var arenaTimer:ArenaTimer;
    public var arenaWaveCounter:ArenaWaveCounter;
    public var mapModel:MapModel;
    public var dialogsModel:DialogsModel;
    public var openDailyCalendarPopupSignal:ShowDailyCalendarPopupSignal;
    public var openDialog:OpenDialogSignal;
    public var showPackage:Signal;
    public var packageModel:PackageModel;
    public var addToQueueSignal:AddPopupToStartupQueueSignal;
    public var flushQueueSignal:FlushPopupStartupQueueSignal;
    public var focus:GameObject;
    private var isGameStarted:Boolean;
    private var displaysPosY:uint = 4;
    private var currentPackage:DisplayObject;
    private var packageY:Number;
    public var chatPlayerMenu:PlayerMenu;
    public var serverDisconnect:Boolean;

    public function GameSprite(_arg1:Server, _arg2:int, _arg3:Boolean, _arg4:int, _arg5:int, _arg6:ByteArray, _arg7:PlayerModel, _arg8:String, _arg9:Boolean) {
        this.showPackage = new Signal();
        this.currentPackage = new Sprite();
        super();
        this.model = _arg7;
        map = new Map(this);
        addChild(map);
        this.gsc_ = GameServerConnection.instance != null ? GameServerConnection.instance : new GameServerConnectionConcrete(_arg1);
        this.gsc_.update(this, _arg2, _arg3, _arg4, _arg5, _arg6, _arg8, _arg9);
        mui_ = new MapUserInput(this);
        this.chatBox_ = new Chat();
        this.chatBox_.list.addEventListener(MouseEvent.MOUSE_DOWN, this.onChatDown);
        this.chatBox_.list.addEventListener(MouseEvent.MOUSE_UP, this.onChatUp);
        addChild(this.chatBox_);
        this.idleWatcher_ = new IdleWatcher();
    }


    public static function dispatchMapLoaded(_arg1:MapInfo):void {
        var _local2:MapLoadedSignal = StaticInjectorContext.getInjector().getInstance(MapLoadedSignal);
        ((_local2) && (_local2.dispatch(_arg1)));
    }

    private static function hidePreloader():void {
        var _local1:HideMapLoadingSignal = StaticInjectorContext.getInjector().getInstance(HideMapLoadingSignal);
        ((_local1) && (_local1.dispatch()));
    }


    public function onChatDown(_arg1:MouseEvent):void {
        if (this.chatPlayerMenu != null) {
            this.removeChatPlayerMenu();
        }
        mui_.onMouseDown(_arg1);
    }

    public function onChatUp(_arg1:MouseEvent):void {
        mui_.onMouseUp(_arg1);
    }

    override public function setFocus(_arg1:GameObject):void {
        _arg1 = ((_arg1) || (map.player_));
        this.focus = _arg1;
    }

    public function addChatPlayerMenu(_arg1:Player, _arg2:Number, _arg3:Number, _arg4:String = null, _arg5:Boolean = false, _arg6:Boolean = false):void {
        this.removeChatPlayerMenu();
        this.chatPlayerMenu = new PlayerMenu();
        if (_arg4 == null) {
            this.chatPlayerMenu.init(this, _arg1);
        } else {
            if (_arg6) {
                this.chatPlayerMenu.initDifferentServer(this, _arg4, _arg5, _arg6);
            } else {
                if ((((_arg4.length > 0)) && ((((((_arg4.charAt(0) == "#")) || ((_arg4.charAt(0) == "*")))) || ((_arg4.charAt(0) == "@")))))) {
                    return;
                }
                this.chatPlayerMenu.initDifferentServer(this, _arg4, _arg5);
            }
        }
        addChild(this.chatPlayerMenu);
        this.chatPlayerMenu.x = _arg2;
        this.chatPlayerMenu.y = (_arg3 - this.chatPlayerMenu.height);
    }

    public function removeChatPlayerMenu():void {
        if (((!((this.chatPlayerMenu == null))) && (!((this.chatPlayerMenu.parent == null))))) {
            removeChild(this.chatPlayerMenu);
            this.chatPlayerMenu = null;
        }
    }

    override public function applyMapInfo(_arg1:MapInfo):void {
        map.setProps(_arg1.width_, _arg1.height_, _arg1.name_, _arg1.background_, _arg1.allowPlayerTeleport_, _arg1.showDisplays_, _arg1.currentDatetime_);
        dispatchMapLoaded(_arg1);
    }

    public function hudModelInitialized():void {
        hudView = new HUDView();
        hudView.x = 600;
        addChild(hudView);
    }

    override public function initialize():void {
        var yeetus:Boolean = true;
        map.initialize();
        this.modelInitialized.dispatch();
        if (this.evalIsNotInCombatMapArea()) {
            this.showSafeAreaDisplays();
        }
        if (map.name_ == "Arena") {
            this.showTimer();
            this.showWaveCounter();
        }
        if (map.name_ == Map.NEXUS) {
            this.addToQueueSignal.dispatch(PopupNamesConfig.DAILY_LOGIN_POPUP, this.openDailyCalendarPopupSignal, -1, null);
            this.addToQueueSignal.dispatch(PopupNamesConfig.PACKAGES_OFFER_POPUP, this.showPackage, 1, null);
            this.flushQueueSignal.dispatch();
        }
        this.isNexus_ = map.name_ == Map.NEXUS;
        if (this.isNexus_ || map.name_ == Map.DAILY_QUEST_ROOM || map.name_ == Map.VAULT || Parameters.data_.HackInfo) {
            this.creditDisplay_ = new CreditDisplay(this, true, true);
            this.creditDisplay_.x = 594;
            this.creditDisplay_.y = 0;
            addChild(this.creditDisplay_);
        }
        if (map.name_ == "Daily Quest Room") {
            QuestRewardsPanel.checkQuests();
        }
        if (this.parent.parent as Layers)
            this.parent.parent.setChildIndex((this.parent.parent as Layers).top, 2);
        hidePreloader();
    }

    private function showSafeAreaDisplays():void {
        this.showRankText();
        this.showGuildText();
        this.setYAndPositionPackage();
        this.showGiftStatusDisplay();
        this.showNewsUpdate();
        this.showNewsTicker();
        this.showNewsTicker2();
    }

    private function showTimer():void {
        this.arenaTimer = new ArenaTimer();
        this.arenaTimer.y = 5;
        addChild(this.arenaTimer);
    }

    private function showWaveCounter():void {
        this.arenaWaveCounter = new ArenaWaveCounter();
        this.arenaWaveCounter.y = 5;
        this.arenaWaveCounter.x = 5;
        addChild(this.arenaWaveCounter);
    }

    private function showNewsTicker():void {
        this.newsTicker = new NewsTicker();
        this.newsTicker.x = (300 - (this.newsTicker.width / 2));
        this.newsTicker.y = (5 + UIUtils.NOTIFICATION_SPACE);
        addChild(this.newsTicker);
    }

    private function showNewsTicker2():void {
        this.newsTicker2 = new NewsTicker2();
        this.newsTicker2.x = (300 - (this.newsTicker.width / 2));
        this.newsTicker2.y = (5 + UIUtils.NOTIFICATION_SPACE);
        addChild(this.newsTicker2);
    }

    private function showGiftStatusDisplay():void {
        this.giftStatusDisplay = new GiftStatusDisplay();
        this.giftStatusDisplay.x = 6;
        this.giftStatusDisplay.y = (this.displaysPosY + 2);
        this.displaysPosY = (this.displaysPosY + UIUtils.NOTIFICATION_SPACE);
        addChild(this.giftStatusDisplay);
    }

    private function showNewsUpdate(_arg1:Boolean = true):void {
        var _local4:NewsModalButton;
        var _local3:NewsModel = StaticInjectorContext.getInjector().getInstance(NewsModel);
        if (_local3.hasValidModalNews()) {
            _local4 = new NewsModalButton();
            _local4.x = 6;
            _local4.y = 92;
            if (_arg1) {
                this.displaysPosY = (this.displaysPosY + UIUtils.NOTIFICATION_SPACE);
            }
            if (this.newsModalButton != null) {
                removeChild(this.newsModalButton);
            }
            this.newsModalButton = _local4;
            addChild(this.newsModalButton);
        }
    }
    private function setYAndPositionPackage():void {
        this.packageY = (this.displaysPosY + 2);
        this.displaysPosY = (this.displaysPosY + UIUtils.NOTIFICATION_SPACE);
        this.positionPackage();
    }

    private function positionPackage():void {
        this.currentPackage.x = 6;
        this.currentPackage.y = this.packageY;
    }

    public function showPackageButtonIfSafe():void {
        if (this.evalIsNotInCombatMapArea()) {
            this.addAndPositionPackage(new PackageButton());
        }
    }

    private function addAndPositionPackage(_arg1:DisplayObject):void {
        this.currentPackage = _arg1;
        addChild(this.currentPackage);
        this.positionPackage();
    }

    private function showGuildText():void {
        this.guildText_ = new GuildText("", -1);
        this.guildText_.x = 64;
        this.guildText_.y = 6;
        addChild(this.guildText_);
    }

    private function showRankText():void {
        this.rankText_ = new RankText(-1, true, false);
        this.rankText_.x = 8;
        this.rankText_.y = this.displaysPosY;
        this.displaysPosY = (this.displaysPosY + UIUtils.NOTIFICATION_SPACE);
        addChild(this.rankText_);
    }

    private function updateNearestInteractive():void {
        var _local4:Number;
        var _local7:GameObject;
        var _local8:IInteractiveObject;
        //checkScaleMode();
        if (((!(map)) || (!(map.player_)))) {
            return;
        }
        var _local1:Player = map.player_;
        var _local2:Number = GeneralConstants.MAXIMUM_INTERACTION_DISTANCE;
        var _local3:IInteractiveObject;
        var _local5:Number = _local1.x_;
        var _local6:Number = _local1.y_;
        for each (_local7 in map.goDict_) {
            _local8 = (_local7 as IInteractiveObject);
            if (((_local8) && (((!((_local8 is Pet))) || (this.map.isPetYard))))) {
                if ((((Math.abs((_local5 - _local7.x_)) < GeneralConstants.MAXIMUM_INTERACTION_DISTANCE)) || ((Math.abs((_local6 - _local7.y_)) < GeneralConstants.MAXIMUM_INTERACTION_DISTANCE)))) {
                    _local4 = PointUtil.distanceXY(_local7.x_, _local7.y_, _local5, _local6);
                    if ((((_local4 < GeneralConstants.MAXIMUM_INTERACTION_DISTANCE)) && ((_local4 < _local2)))) {
                        _local2 = _local4;
                        _local3 = _local8;
                    }
                }
            }
        }
        this.mapModel.currentInteractiveTarget = _local3;
    }

    public function onScreenResize(_arg_1:Event):void {
        var _local_5:Number;
        var _local_2:Boolean = Parameters.data_.uiscale; //Parameters.data_["uiscale"]
        var _local_3:Number = (800 / stage.stageWidth);
        var _local_6:Number = (600 / stage.stageHeight);
        var _local_7:Number = (_local_3 / _local_6);
        if (this.hudView != null) {
            if (_local_2) {
                this.hudView.scaleX = _local_7;
                this.hudView.scaleY = 1;
                this.hudView.y = 0;
            } else {
                this.hudView.scaleX = _local_3;
                this.hudView.scaleY = _local_6;
                this.hudView.y = (300 * (1 - _local_6));
            }
            this.hudView.x = (800 - (200 * this.hudView.scaleX));
            if (this.creditDisplay_ != null) {
                this.creditDisplay_.x = (this.hudView.x - (6 * this.creditDisplay_.scaleX));
            }
        }
        if (this.map) {
            this.map.scaleX = (_local_3);
            this.map.scaleY = (_local_6);
        }
        if (this.chatBox_ != null) {

            this.chatBox_.scaleX = _local_7 * Parameters.data_.ScaleChat;
            this.chatBox_.scaleY = 1 * Parameters.data_.ScaleChat;
            this.chatBox_.y = (300 + (300 * (1 - this.chatBox_.scaleY)));
        }
        if (this.rankText_ != null) {
            if (_local_2) {
                this.rankText_.scaleX = _local_7;
                this.rankText_.scaleY = 1;
            } else {
                this.rankText_.scaleX = _local_3;
                this.rankText_.scaleY = _local_6;
            }
            this.rankText_.x = (8 * this.rankText_.scaleX);
            this.rankText_.y = (2 * this.rankText_.scaleY);
        }
        if (this.guildText_ != null) {
            if (_local_2) {
                this.guildText_.scaleX = _local_7;
                this.guildText_.scaleY = 1;
            } else {
                this.guildText_.scaleX = _local_3;
                this.guildText_.scaleY = _local_6;
            }
            this.guildText_.x = (64 * this.guildText_.scaleX);
            this.guildText_.y = (2 * this.guildText_.scaleY);
        }
        if (this.creditDisplay_ != null) {
            if (_local_2) {
                this.creditDisplay_.scaleX = _local_7;
                this.creditDisplay_.scaleY = 1;
            } else {
                this.creditDisplay_.scaleX = _local_3;
                this.creditDisplay_.scaleY = _local_6;
            }
        }
        if (this.giftStatusDisplay != null) {
            if (_local_2) {
                this.giftStatusDisplay.scaleX = _local_7;
                this.giftStatusDisplay.scaleY = 1;
            } else {
                this.giftStatusDisplay.scaleX = _local_3;
                this.giftStatusDisplay.scaleY = _local_6;
            }
            this.giftStatusDisplay.x = (6 * this.giftStatusDisplay.scaleX);
            this.giftStatusDisplay.y = (66 * this.giftStatusDisplay.scaleY);
        }
        var _local_4:int = 98;
        if (this.newsModalButton != null) {
            if (_local_2) {
                this.newsModalButton.scaleX = _local_7;
                this.newsModalButton.scaleY = 1;
            } else {
                this.newsModalButton.scaleX = _local_3;
                this.newsModalButton.scaleY = _local_6;
            }
            this.newsModalButton.x = (6 * this.newsModalButton.scaleX);
            this.newsModalButton.y = (_local_4 * this.newsModalButton.scaleY);
            _local_4 = 130;
        }
    }

    public function connect():void {
        if (!this.isGameStarted) {
            this.serverDisconnect = false;
            this.isGameStarted = true;
            Renderer.inGame = true;
            if (!this.gsc_.connected)
                this.gsc_.connect();
            else
                this.gsc_.sendHello();
            this.idleWatcher_.start(this);
            lastUpdate_ = getTimer();
            stage.addEventListener("MONEY_CHANGED", this.onMoneyChanged);
            stage.addEventListener("enterFrame", this.onEnterFrame);
            if (this.parent.parent as Layers)
                this.parent.parent.setChildIndex((this.parent.parent as Layers).top, 0);
            if (Parameters.data_["stageScale"] == undefined) {
                Parameters.data_["stageScale"] = StageScaleMode.NO_SCALE;
                Parameters.save();
            }
            this.parent.parent.setChildIndex((this.parent.parent as Layers).top, 0);
            stage.scaleMode = "noScale";
            stage.addEventListener("resize", this.onScreenResize);
            stage.dispatchEvent(new Event("resize"));
            LoopedProcess.addProcess(new LoopedCallback(100, this.updateNearestInteractive));
        }
    }


    public function disconnect():void {
        if (this.isGameStarted) {
            this.isGameStarted = false;
            Renderer.inGame = false;
            this.idleWatcher_.stop();
            if (this.serverDisconnect)
                this.gsc_.disconnect();
            NewsTicker2.dispose();
            stage.removeEventListener("MONEY_CHANGED", this.onMoneyChanged);
            stage.removeEventListener("enterFrame", this.onEnterFrame);
            stage.removeEventListener("resize", this.onScreenResize);
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.dispatchEvent(new Event("resize"));
            LoopedProcess.destroyAll();
            ((contains(map)) && (removeChild(map)));
            map.dispose();
            CachingColorTransformer.clear();
            TextureRedrawer.clearCache();
            Projectile.dispose();
            System.gc();
            System.gc();
            System.pauseForGCIfCollectionImminent(0);
        }
    }

    private function onMoneyChanged(_arg1:Event):void {
        gsc_.checkCredits();
    }

    override public function evalIsNotInCombatMapArea():Boolean {
        return ((((((((((((map.name_ == Map.NEXUS)) || ((map.name_ == Map.VAULT)))) || ((map.name_ == Map.GUILD_HALL)))) || ((map.name_ == Map.CLOTH_BAZAAR)))) || ((map.name_ == Map.NEXUS_EXPLANATION)))) || ((map.name_ == Map.DAILY_QUEST_ROOM))));
    }

    private function onEnterFrame(_arg1:Event):void {
        stage.dispatchEvent(new Event("resize"));
        var _local2:int = getTimer();
        var _local3:int = (_local2 - lastUpdate_);
        if (this.idleWatcher_.update(_local3)) {
            closed.dispatch();
            return;
        }
        LoopedProcess.runProcesses(_local2);
        map.update(_local2, _local3);
        camera_.update(_local3);
        var player:Player = map.player_;
        if (this.focus)
        {
            camera_.configureCamera(this.focus, player ? player.isHallucinating() : false);
            map.draw(camera_, _local2);
        }
        if (player != null) {
            this.drawCharacterWindow.dispatch(player);
            if (this.evalIsNotInCombatMapArea()) {
                this.creditDisplay_.draw(player.credits_, player.fame_, player.tokens_);
                this.rankText_.draw(player.numStars_, player.rank_, player.admin_);
                this.guildText_.draw(player.guildName_, player.guildRank_);
                this.guildText_.x = this.rankText_.width + 16;
            }
            if (player.isPaused() && this.map.player_.commune == null) {
                hudView.filters = [PAUSED_FILTER];
                map.mouseEnabled = false;
                map.mouseChildren = false;
                hudView.mouseEnabled = false;
                hudView.mouseChildren = false;
            }
            else {
                if (hudView.filters.length > 0) {
                    hudView.filters = [];
                    map.mouseEnabled = true;
                    map.mouseChildren = true;
                    hudView.mouseEnabled = true;
                    hudView.mouseChildren = true;
                }
            }
        }
        lastUpdate_ = _local2;
    }

}
}
