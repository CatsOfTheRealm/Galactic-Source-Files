﻿package com.company.assembleegameclient.screens {
import com.company.assembleegameclient.appengine.CharacterStats;
import com.company.assembleegameclient.appengine.SavedCharacter;
import com.company.assembleegameclient.ui.tooltip.ClassToolTip;
import com.company.assembleegameclient.ui.tooltip.ToolTip;
import com.company.assembleegameclient.util.AnimatedChar;
import com.company.assembleegameclient.util.Currency;
import com.company.assembleegameclient.util.FameUtil;
import com.company.rotmg.graphics.FullCharBoxGraphic;
import com.company.rotmg.graphics.LockedCharBoxGraphic;
import com.company.rotmg.graphics.StarGraphic;
import com.company.util.AssetLibrary;
import com.gskinner.motion.GTween;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.geom.ColorTransform;
import flash.text.TextFieldAutoSize;

import io.decagames.rotmg.ui.sliceScaling.SliceScalingBitmap;

import io.decagames.rotmg.ui.texture.TextureParser;

import kabam.rotmg.core.model.PlayerModel;
import kabam.rotmg.text.model.TextKey;
import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.util.components.LegacyBuyButton;

import org.osflash.signals.natives.NativeSignal;

public class CharacterBox extends Sprite {

    public static const DELETE_CHAR:String = "DELETE_CHAR";
    public static const ENTER_NAME:String = "ENTER_NAME";
    private static const fullCT:ColorTransform = new ColorTransform(0.8, 0.8, 0.8);
    private static const emptyCT:ColorTransform = new ColorTransform(0.2, 0.2, 0.2);

    private var SaleTag:Class;
    public var playerXML_:XML = null;
    public var charStats_:CharacterStats;
    public var model:PlayerModel;
    public var available_:Boolean;
    private var graphicContainer_:Sprite;
    private var graphic_:SliceScalingBitmap;
    private var bitmap_:Bitmap;
    private var statusText_:TextFieldDisplayConcrete;
    private var classNameText_:TextFieldDisplayConcrete;
    private var buyButton_:LegacyBuyButton;
    private var cost:int = 0;
    private var lock_:Bitmap;
    private var saleText_:TextFieldDisplayConcrete;
    private var unlockedText_:TextFieldDisplayConcrete;
    private var saleTag_;
    public var buyButtonClicked_:NativeSignal;
    public var characterSelectClicked_:NativeSignal;

    public function CharacterBox(_arg1:XML, _arg2:CharacterStats, _arg3:PlayerModel, _arg4:Boolean = false) {
        var _local5:Sprite;
        this.SaleTag = CharacterBox_SaleTag;
        super();
        this.model = _arg3;
        this.playerXML_ = _arg1;
        this.charStats_ = _arg2;
        this.available_ = ((_arg4) || (_arg3.isLevelRequirementsMet(this.objectType())));
        if (!this.available_) {
            this.graphic_ = TextureParser.instance.getSliceScalingBitmap("UI","popup_content_inset");
            this.cost = this.playerXML_.UnlockCost;
        }
        else {
            this.graphic_ = TextureParser.instance.getSliceScalingBitmap("UI","popup_content_inset");
        }
        this.graphic_.width = 100;
        this.graphic_.height = 100;
        this.graphicContainer_ = new Sprite();
        addChild(this.graphicContainer_);
        this.graphicContainer_.addChild(this.graphic_);
        this.characterSelectClicked_ = new NativeSignal(this.graphicContainer_, MouseEvent.CLICK, MouseEvent);
        this.bitmap_ = new Bitmap(null);
        this.setImage(2,0, 0);
        this.bitmap_.x = this.graphic_.x + this.bitmap_.width / 2 - 12;
        this.bitmap_.y = this.graphic_.y;
        addChild(this.bitmap_);
        this.classNameText_ = new TextFieldDisplayConcrete().setSize(14).setColor(0xFFFFFF).setAutoSize(TextFieldAutoSize.CENTER).setTextWidth(this.graphic_.width).setBold(true);
        this.classNameText_.setStringBuilder(new LineBuilder().setParams(ClassToolTip.getDisplayId(this.playerXML_)));
        this.classNameText_.filters = [new DropShadowFilter(0, 0, 0, 1, 4, 4)];
        addChild(this.classNameText_);
        this.setBuyButton();
        this.setStatusButton();
        if (this.available_) {
            _local5 = this.getStars(FameUtil.numStars(_arg3.getBestFame(this.objectType())), FameUtil.STARS.length);
            _local5.y = 60;
            _local5.x = ((this.graphic_.width / 2) - (_local5.width / 2));
            _local5.filters = [new DropShadowFilter(0, 0, 0, 1, 4, 4)];
            this.graphicContainer_.addChild(_local5);
            this.classNameText_.y = 74;
        }
        else {
            addChild(this.buyButton_);
            this.lock_ = new Bitmap(AssetLibrary.getImageFromSet("lofiInterface2", 5));
            this.lock_.scaleX = 2;
            this.lock_.scaleY = 2;
            this.lock_.x = 4;
            this.lock_.y = 8;
            addChild(this.lock_);
            addChild(this.statusText_);
            this.classNameText_.y = 78;
        }
    }

    public function objectType():int {
        return (int(this.playerXML_.@type));
    }

    public function unlock():void {
        var _local1:Sprite;
        var _local2:GTween;
        if (!this.available_) {
            this.available_ = true;
            this.graphicContainer_.removeChild(this.graphic_);
            this.graphic_ = TextureParser.instance.getSliceScalingBitmap("UI","popup_content_inset");
            this.graphic_.width = 100;
            this.graphic_.height = 100;
            this.graphicContainer_.addChild(this.graphic_);
            this.setImage(2,0, 0);
            this.bitmap_.x = this.graphic_.x + this.bitmap_.width / 2 - 12;
            this.bitmap_.y = this.graphic_.y;
            addChild(this.bitmap_);
            this.classNameText_.x = this.graphic_.x + this.classNameText_.width / 2;
            this.classNameText_.y = this.graphic_.y + 90;
            addChild(this.classNameText_);
            if (contains(this.statusText_)) {
                removeChild(this.statusText_);
            }
            if (contains(this.buyButton_)) {
                removeChild(this.buyButton_);
            }
            if (((this.lock_) && (contains(this.lock_)))) {
                removeChild(this.lock_);
            }
            if (((this.saleTag_) && (contains(this.saleTag_)))) {
                removeChild(this.saleTag_);
            }
            if (((this.saleText_) && (contains(this.saleText_)))) {
                removeChild(this.saleText_);
            }
            _local1 = this.getStars(FameUtil.numStars(this.model.getBestFame(this.objectType())), FameUtil.STARS.length);
            _local1.y = 60;
            _local1.x = ((this.graphic_.width / 2) - (_local1.width / 2));
            _local1.filters = [new DropShadowFilter(0, 0, 0, 1, 4, 4)];
            addChild(_local1);
            this.classNameText_.y = 74;
            if (!this.unlockedText_) {
                this.getCharacterUnlockText();
            }
            addChild(this.unlockedText_);
            _local2 = new GTween(this.unlockedText_, 2.5, {
                "alpha": 0,
                "y": -30
            });
            _local2.onComplete = this.removeUnlockText;
        }
    }

    private function removeUnlockText(_arg1:GTween):void {
        removeChild(this.unlockedText_);
    }

    public function getTooltip():ToolTip {
        return (new ClassToolTip(this.playerXML_, this.model, this.charStats_));
    }

    public function setOver(_arg1:Boolean):void {
        if (!this.available_) {
            return;
        }
        if (_arg1) {
            transform.colorTransform = new ColorTransform(1.2, 1.2, 1.2);
        }
        else {
            transform.colorTransform = new ColorTransform(1, 1, 1);
        }
    }

    private function setImage(_arg1:int, _arg2:int, _arg3:Number):void {
        this.bitmap_.bitmapData = SavedCharacter.getImage(null, this.playerXML_, _arg1, _arg2, _arg3, this.available_, false);
        this.bitmap_.x = ((this.graphic_.width / 2) - (this.bitmap_.bitmapData.width / 2));
    }

    private function getStars(_arg1:int, _arg2:int):Sprite {
        var _local5:Sprite;
        var _local3:Sprite = new Sprite();
        var _local4:int;
        var _local6:int;
        while (_local4 < _arg1) {
            _local5 = new StarGraphic();
            _local5.x = _local6;
            _local5.transform.colorTransform = fullCT;
            _local3.addChild(_local5);
            _local6 = (_local6 + _local5.width);
            _local4++;
        }
        while (_local4 < _arg2) {
            _local5 = new StarGraphic();
            _local5.x = _local6;
            _local5.transform.colorTransform = emptyCT;
            _local3.addChild(_local5);
            _local6 = (_local6 + _local5.width);
            _local4++;
        }
        return (_local3);
    }

    public function setSale(_arg1:int):void {
        if (!this.saleTag_) {
            this.saleTag_ = new this.SaleTag();
            this.saleTag_.x = 38;
            this.saleTag_.y = 8;
            addChild(this.saleTag_);
        }
        if (!this.saleText_) {
            this.setSaleText();
            addChild(this.saleText_);
        }
        this.saleText_.setStringBuilder(new LineBuilder().setParams(TextKey.PERCENT_OFF, {"percent": String(_arg1)}));
    }

    private function setBuyButton():void {
        this.buyButton_ = new LegacyBuyButton(TextKey.BUY_FOR, 13, this.cost, Currency.GOLD);
        this.buyButton_.y = (this.buyButton_.y + this.graphic_.height);
        this.buyButton_.setWidth(this.graphic_.width);
        this.buyButtonClicked_ = new NativeSignal(this.buyButton_, MouseEvent.CLICK, MouseEvent);
    }

    private function setStatusButton():void {
        this.statusText_ = new TextFieldDisplayConcrete().setSize(14).setColor(0xFF0000).setAutoSize(TextFieldAutoSize.CENTER).setBold(true).setTextWidth(this.graphic_.width);
        this.statusText_.setStringBuilder(new LineBuilder().setParams(TextKey.LOCKED));
        this.statusText_.filters = [new DropShadowFilter(0, 0, 0, 1, 4, 4)];
        this.statusText_.y = 58;
    }

    private function setSaleText():void {
        this.saleText_ = new TextFieldDisplayConcrete().setSize(14).setColor(0xFFFFFF).setAutoSize(TextFieldAutoSize.CENTER).setBold(true).setTextHeight(this.saleTag_.height).setTextWidth(this.saleTag_.width);
        this.saleText_.x = 42;
        this.saleText_.y = 12;
    }

    private function getCharacterUnlockText():void {
        this.unlockedText_ = new TextFieldDisplayConcrete().setSize(14).setColor(0xFF00).setBold(true).setAutoSize(TextFieldAutoSize.CENTER);
        this.unlockedText_.filters = [new DropShadowFilter(0, 0, 0, 1, 4, 4)];
        this.unlockedText_.setStringBuilder(new LineBuilder().setParams(TextKey.UNLOCK_CLASS));
        this.unlockedText_.y = -20;
    }

    public function setIsBuyButtonEnabled(_arg1:Boolean):void {
        this.buyButton_.setEnabled(_arg1);
    }


}
}
