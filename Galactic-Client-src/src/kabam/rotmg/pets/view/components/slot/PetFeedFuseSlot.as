﻿package kabam.rotmg.pets.view.components.slot {
import com.company.util.MoreColorUtil;

import flash.events.MouseEvent;
import flash.filters.ColorMatrixFilter;
import flash.geom.ColorTransform;

import kabam.rotmg.pets.data.PetFamilyKeys;
import kabam.rotmg.pets.data.PetVO;
import kabam.rotmg.pets.view.components.PetIcon;
import kabam.rotmg.pets.view.components.PetIconFactory;
import kabam.rotmg.text.model.TextKey;
import kabam.rotmg.text.view.stringBuilder.AppendingLineBuilder;

import org.osflash.signals.Signal;

public class PetFeedFuseSlot extends FeedFuseSlot {

    public const openPetPicker:Signal = new Signal();

    public var showFamily:Boolean = false;
    public var processing:Boolean = false;
    private var petIconFactory:PetIconFactory;
    private var grayscaleMatrix:ColorMatrixFilter;

    public function PetFeedFuseSlot() {
        this.petIconFactory = new PetIconFactory();
        this.grayscaleMatrix = new ColorMatrixFilter(MoreColorUtil.greyscaleFilterMatrix);
        super();
        addEventListener(MouseEvent.CLICK, this.onOpenPetPicker);
        this.updateTitle();
    }

    public function updateTitle():void {
        if (((!(icon)) || (contains(icon)))) {
            setTitle(TextKey.PETORFOODSLOT_FUSE_PET_TITLE, {});
        }
    }

    private function onOpenPetPicker(_arg1:MouseEvent):void {
        if (!this.processing) {
            this.openPetPicker.dispatch();
        }
    }

    public function setPetIcon(_arg1:PetVO):void {
        var _local2:PetIcon = this.petIconFactory.create(_arg1, 48);
        setIcon(_local2);
    }

    public function setPet(_arg1:PetVO):void {
        var _local2:AppendingLineBuilder;
        if (_arg1) {
            this.setPetIcon(_arg1);
            setTitle(TextKey.BLANK, {"data": _arg1.getName()});
            _local2 = new AppendingLineBuilder();
            _local2.pushParams(_arg1.getRarity());
            ((this.showFamily) && (_local2.pushParams(PetFamilyKeys.getTranslationKey(_arg1.getFamily()))));
            setSubtitle(TextKey.BLANK, {"data": _local2});
        }
    }

    public function setProcessing(_arg1:Boolean):void {
        var _local2:ColorTransform;
        if (this.processing != _arg1) {
            this.processing = _arg1;
            icon.filters = ((_arg1) ? [this.grayscaleMatrix] : []);
            _local2 = ((_arg1) ? MoreColorUtil.darkCT : new ColorTransform());
            icon.transform.colorTransform = _local2;
        }
    }


}
}
