package com.company.assembleegameclient.map {
import com.company.assembleegameclient.background.Background;
import com.company.assembleegameclient.game.AGameSprite;
import com.company.assembleegameclient.map.mapoverlay.MapOverlay;
import com.company.assembleegameclient.map.partyoverlay.PartyOverlay;
import com.company.assembleegameclient.objects.BasicObject;
import com.company.assembleegameclient.objects.GameObject;
import com.company.assembleegameclient.objects.Party;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.objects.particles.ParticleEffect;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.util.ConditionEffect;
import com.company.assembleegameclient.game.GameSprite;

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.GraphicsBitmapFill;
import flash.display.GraphicsSolidFill;
import flash.display.IGraphicsData;
import flash.display3D.Context3D;
import flash.filters.BlurFilter;
import flash.filters.ColorMatrixFilter;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import kabam.rotmg.assets.EmbeddedAssets;
import kabam.rotmg.core.StaticInjectorContext;
import kabam.rotmg.game.logging.RollingMeanLoopMonitor;
import kabam.rotmg.game.model.GameModel;
import kabam.rotmg.stage3D.GraphicsFillExtra;
import kabam.rotmg.stage3D.Object3D.Object3DStage3D;
import kabam.rotmg.stage3D.Render3D;
import kabam.rotmg.stage3D.Renderer;
import kabam.rotmg.stage3D.Stage3DConfig;
import kabam.rotmg.stage3D.graphic3D.Program3DFactory;
import kabam.rotmg.stage3D.graphic3D.TextureFactory;
import WeatherStuff.AtmosphereHandler;
import com.gskinner.motion.GTween;
import WeatherStuff.AtmosphereHandler;

import org.osflash.signals.Signal;


public class Map extends AbstractMap {

    private static const VISIBLE_SORT_FIELDS:Array = ["sortVal_","objectId_"];
    private static const VISIBLE_SORT_PARAMS:Array = [Array.NUMERIC,Array.NUMERIC];
    protected static const BLIND_FILTER:ColorMatrixFilter = new ColorMatrixFilter([0.05,0.05,0.05,0,0,0.05,0.05,0.05,0,0,0.05,0.05,0.05,0,0,0.05,0.05,0.05,1,0]);
    protected static var BREATH_CT:ColorTransform = new ColorTransform(255 / 255,55 / 255,0 / 255,0);

    public static const CLOTH_BAZAAR:String = "Cloth Bazaar";
    public static const NEXUS:String = "Nexus";
    public static const DAILY_QUEST_ROOM:String = "Daily Quest Room";
    public static const GUILD_HALL:String = "Guild Hall";
    public static const NEXUS_EXPLANATION:String = "Nexus_Explanation";
    public static const VAULT:String = "Vault";
    public static var forceSoftwareRender:Boolean = false;
    public static var texture:BitmapData;

    private var inUpdate_:Boolean = false;
    private var objsToAdd_:Vector.<BasicObject>;
    private var idsToRemove_:Vector.<int>;
    private var forceSoftwareMap:Dictionary;
    private var lastSoftwareClear:Boolean = false;
    private var darkness:DisplayObject;
    private var graphicsData_:Vector.<IGraphicsData>;
    private var graphicsDataStageSoftware_:Vector.<IGraphicsData>;
    private var graphicsData3d_:Vector.<Object3DStage3D>;
    public var visible_:Array;
    public var visibleUnder_:Array;
    public var visibleSquares_:Vector.<Square>;
    public var topSquares_:Vector.<Square>;

    public function Map(gs:AGameSprite) {

        this.objsToAdd_ = new Vector.<BasicObject>();
        this.forceSoftwareMap = new Dictionary();
        this.darkness = new EmbeddedAssets.DarknessBackground();
        this.atmosphere_ = new AtmosphereHandler(this.gs_, this);
        this.idsToRemove_ = new Vector.<int>();
        this.graphicsData_ = new Vector.<IGraphicsData>();
        this.graphicsDataStageSoftware_ = new Vector.<IGraphicsData>();
        this.graphicsData3d_ = new Vector.<Object3DStage3D>();
        this.visible_ = new Array();
        this.visibleUnder_ = new Array();
        this.visibleSquares_ = new Vector.<Square>();
        this.topSquares_ = new Vector.<Square>();
        super();
        gs_ = gs;
        this.hurtOverlay_ = new HurtOverlay();
        this.gradientOverlay_ = new GradientOverlay();
        this.mapOverlay_ = new MapOverlay();
        this.partyOverlay_ = new PartyOverlay(this);
        this.party_ = new Party(this);
        this.quest_ = new Quest(this);
        this.signalRenderSwitch = new Signal();
        StaticInjectorContext.getInjector().getInstance(GameModel).gameObjects = goDict_;
        wasLastFrameGpu = Parameters.HWAcceleration;
    }



    override public function setProps(_arg1:int, _arg2:int, _arg3:String, _arg4:int, _arg5:Boolean, _arg6:Boolean, _arg9:int):void {
        this.width_ = _arg1;
        this.height_ = _arg2;
        this.name_ = _arg3;
        this.back_ = _arg4;
        this.allowPlayerTeleport_ = _arg5;
        this.showDisplays_ = _arg6;
        this.atmosphere_.init(_arg9);
        this.forceSoftwareRenderCheck(name_);
    }

    private function forceSoftwareRenderCheck(_arg1:String):void {
        forceSoftwareRender = this.forceSoftwareMap[_arg1] != null || WebMain.STAGE != null && WebMain.STAGE.stage3Ds[0].context3D == null;
    }

    override public function initialize() : void
    {
        this.squares_.length = this.width_ * this.height_;
        this.background_ = Background.getBackground(this.back_);
        if (this.background_ != null) {
            addChild(this.background_);
        }
        addChild(this.map_);
        addChild(this.atmosphere_);
        addChild(this.hurtOverlay_);
        addChild(this.gradientOverlay_);
        addChild(this.mapOverlay_);
        addChild(this.partyOverlay_);
    }

    override public function dispose() : void
    {
        var square:Square = null;
        var go:GameObject = null;
        var bo:BasicObject = null;
        this.gs_ = null;
        this.background_ = null;
        this.map_ = null;
        this.hurtOverlay_ = null;
        this.gradientOverlay_ = null;
        this.mapOverlay_ = null;
        this.partyOverlay_ = null;
        for each(square in this.squareList_)
        {
            square.dispose();
        }
        this.squareList_.length = 0;
        this.squareList_ = null;
        this.squares_.length = 0;
        this.squares_ = null;
        for each(go in this.goDict_)
        {
            go.dispose();
        }
        this.goDict_ = null;
        for each(bo in this.boDict_)
        {
            bo.dispose();
        }
        this.boDict_ = null;
        this.merchLookup_ = null;
        this.player_ = null;
        this.party_ = null;
        this.quest_ = null;
        this.objsToAdd_ = null;
        this.idsToRemove_ = null;
        this.atmosphere_ = null;
        TextureFactory.disposeTextures();
        GraphicsFillExtra.dispose();
        Program3DFactory.getInstance().dispose();
    }


    override public function update(time:int, dt:int) : void
    {
        var bo:BasicObject = null;
        var go:GameObject = null;
        var objId:int = 0;
        this.inUpdate_ = true;

        for each(go in this.goDict_)
        {
            if(!go.update(time,dt))
            {
                this.idsToRemove_.push(go.objectId_);
            }
        }

        for each(bo in this.boDict_)
        {
            if(!bo.update(time,dt))
            {
                this.idsToRemove_.push(bo.objectId_);
            }
        }

        this.inUpdate_ = false;
        for each(bo in this.objsToAdd_)
        {
            this.internalAddObj(bo);
        }

        this.objsToAdd_.length = 0;
        for each(objId in this.idsToRemove_)
        {
            this.internalRemoveObj(objId);
        }

        this.idsToRemove_.length = 0;
        this.party_.update(time,dt);
        atmosphere_.update();
    }

    override public function pSTopW(xS:Number, yS:Number) : Point
    {
        var square:Square = null;
        var p:Point = null;
        for each(square in this.visibleSquares_)
        {
            if(square.faces_.length != 0 && square.faces_[0].face_.contains(xS,yS))
            {
                return new Point(square.center_.x,square.center_.y);
            }
        }
        return null;
    }


    override public function setGroundTile(x:int, y:int, tileType:uint) : void
    {
        var yi:int = 0;
        var ind:int = 0;
        var n:Square = null;
        var square:Square = this.getSquare(x,y);
        square.setTileType(tileType);
        var xend:int = x < this.width_ - 1? x + 1 : x;
        var yend:int = y < this.height_ - 1? y + 1 : y;
        for(var xi:int = x > 0 ? x - 1: x; xi <= xend; xi++)
        {
            for(yi = y > 0? y - 1 : y; yi <= yend; yi++)
            {
                ind = xi + yi * this.width_;
                n = this.squares_[ind];
                if(n != null && (n.props_.hasEdge_ || n.tileType_ != tileType))
                {
                    n.faces_.length = 0;
                }
            }
        }
    }


    override public function addObj(bo:BasicObject, posX:Number, posY:Number) : void
    {
        bo.x_ = posX;
        bo.y_ = posY;
        if(this.inUpdate_)
        {
            this.objsToAdd_.push(bo);
        }
        else
        {
            this.internalAddObj(bo);
        }
    }


    public function internalAddObj(bo:BasicObject) : void
    {
        if(!bo.addTo(this,bo.x_,bo.y_))
        {
            trace("ERROR: adding: " + bo);
            return;
        }
        var dict:Dictionary = bo is GameObject?this.goDict_:this.boDict_;
        if(dict[bo.objectId_] != null)
        {
            trace("ERROR: duplicate add: " + bo + " would replace: " + dict[bo.objectId_]);
            return;
        }
        dict[bo.objectId_] = bo;
    }
    override  public function removeObj(objectId:int) : void
    {
        if(this.inUpdate_)
        {
            this.idsToRemove_.push(objectId);
        }
        else
        {
            this.internalRemoveObj(objectId);
        }
    }

    public function internalRemoveObj(objectId:int) : void
    {
        var dict:Dictionary = this.goDict_;
        var bo:BasicObject = dict[objectId];
        if(bo == null)
        {
            dict = this.boDict_;
            bo = dict[objectId];
            if(bo == null)
            {
                return;
            }
        }
        bo.removeFromMap();
        delete dict[objectId];
    }

    public function getSquare(posX:Number, posY:Number) : Square
    {
        if(posX < 0 || posX >= this.width_ || posY < 0 || posY >= this.height_)
        {
            return null;
        }
        var ind:int = int(posX) + int(posY) * this.width_;
        var square:Square = this.squares_[ind];
        if(square == null)
        {
            square = new Square(this,int(posX),int(posY));
            this.squares_[ind] = square;
            this.squareList_.push(square);
        }
        return square;
    }

    public function lookupSquare(x:int, y:int) : Square
    {
        if(x < 0 || x >= this.width_ || y < 0 || y >= this.height_)
        {
            return null;
        }
        return this.squares_[x + y * this.width_];
    }

    override public function draw(camera:Camera, time:int) : void
    {
        var isGpuRender:Boolean = Parameters.isGpuRender(); // cache result for faster access
        Parameters.HWAcceleration= isGpuRender;
        if (wasLastFrameGpu != isGpuRender) {
            var context:Context3D = WebMain.STAGE.stage3Ds[0].context3D;
            if (wasLastFrameGpu && context != null &&
                    context.driverInfo.toLowerCase().indexOf("disposed") == -1) {
                context.clear();
                context.present();
            }
            else {
                map_.graphics.clear();
            }
            signalRenderSwitch.dispatch(wasLastFrameGpu);
            wasLastFrameGpu = isGpuRender;
        }

        var filter:uint = 0;
        var render3D:Render3D = null;
        var i:int = 0;
        var square:Square = null;
        var go:GameObject = null;
        var bo:BasicObject = null;
        var yi:int = 0;
        var dX:Number = NaN;
        var dY:Number = NaN;
        var distSq:Number = NaN;
        var b:Number = NaN;
        var t:Number = NaN;
        var d:Number = NaN;
        var screenRect:Rectangle = camera.clipRect_;
        x = -screenRect.x;
        y = -screenRect.y;
        var distW:Number = (-screenRect.y - screenRect.height / 2) / 50;
        var screenCenterW:Point = new Point(camera.x_ + distW * Math.cos(camera.angleRad_ - Math.PI / 2),camera.y_ + distW * Math.sin(camera.angleRad_ - Math.PI / 2));
        if(this.background_ != null)
        {
            this.background_.draw(camera,time);
        }

        this.visible_.length = 0;
        this.visibleUnder_.length = 0;
        this.visibleSquares_.length = 0;
        this.topSquares_.length = 0;

        var delta:int = camera.maxDist_;
        var xStart:int = Math.max(0,screenCenterW.x - delta);
        var xEnd:int = Math.min(this.width_ - 1,screenCenterW.x + delta);
        var yStart:int = Math.max(0,screenCenterW.y - delta);
        var yEnd:int = Math.min(this.height_ - 1,screenCenterW.y + delta);

        this.graphicsData_.length = 0;
        this.graphicsDataStageSoftware_.length = 0;
        this.graphicsData3d_.length = 0;

        // visible tiles
        for(var xi:int = xStart; xi <= xEnd; xi++)
        {
            for(yi = yStart; yi <= yEnd; yi++)
            {
                square = this.squares_[xi + yi * this.width_];
                if(square != null)
                {
                    dX = screenCenterW.x - square.center_.x;
                    dY = screenCenterW.y - square.center_.y;
                    distSq = dX * dX + dY * dY;
                    if(distSq <= camera.maxDistSq_)
                    {
                        square.lastVisible_ = time;
                        square.draw(this.graphicsData_,camera,time);
                        this.visibleSquares_.push(square);
                        if(square.topFace_ != null)
                        {
                            this.topSquares_.push(square);
                        }
                    }
                }
            }
        }

        // visible game objects
        for each(go in this.goDict_)
        {
            go.drawn_ = false;
            square = go.square_;
            if(!(square == null || square.lastVisible_ != time))
            {
                go.drawn_ = true;
                go.computeSortVal(camera);
                if(go.props_.drawUnder_)
                {
                    if(go.props_.drawOnGround_)
                    {
                        go.draw(this.graphicsData_,camera,time);
                    }
                    else
                    {
                        this.visibleUnder_.push(go);
                    }
                }
                else
                {
                    this.visible_.push(go);
                }
            }
        }

        // visible basic objects (projectiles, particles and such)
        for each(bo in this.boDict_)
        {
            bo.drawn_ = false;
            square = bo.square_;
            if(!(square == null || square.lastVisible_ != time))
            {
                bo.drawn_ = true;
                bo.computeSortVal(camera);
                this.visible_.push(bo);
            }
        }

        // draw visible under
        if(this.visibleUnder_.length > 0)
        {
            this.visibleUnder_.sortOn(VISIBLE_SORT_FIELDS,VISIBLE_SORT_PARAMS);
            for each(bo in this.visibleUnder_)
            {
                bo.draw(this.graphicsData_,camera,time);
            }
        }

        // draw shadows
        this.visible_.sortOn(VISIBLE_SORT_FIELDS,VISIBLE_SORT_PARAMS);
        if(Parameters.data_.drawShadows)
        {
            for each(bo in this.visible_)
            {
                if(bo.hasShadow_)
                {
                    bo.drawShadow(this.graphicsData_,camera,time);
                }
            }
        }

        // draw visible
        for each(bo in this.visible_)
        {
            bo.draw(this.graphicsData_,camera,time);
            if (isGpuRender) {
                bo.draw3d(this.graphicsData3d_);
            }
        }

        // draw top squares
        if(this.topSquares_.length > 0)
        {
            for each(square in this.topSquares_)
            {
                square.drawTop(this.graphicsData_,camera,time);
            }
        }

        // draw breath overlay
        if(this.player_ != null && this.player_.breath_ >= 0 && this.player_.breath_ < Parameters.BREATH_THRESH)
        {
            b = (Parameters.BREATH_THRESH - this.player_.breath_) / Parameters.BREATH_THRESH;
            t = Math.abs(Math.sin(time / 300)) * 0.75;
            BREATH_CT.alphaMultiplier = b * t;
            this.hurtOverlay_.transform.colorTransform = BREATH_CT;
            this.hurtOverlay_.visible = true;
            this.hurtOverlay_.x = screenRect.left;
            this.hurtOverlay_.y = screenRect.top;
        }
        else
        {
            this.hurtOverlay_.visible = false;
        }

        // draw side bar gradient
        if(this.player_ != null)
        {
            this.gradientOverlay_.visible = true;
            this.gradientOverlay_.x = screenRect.right - 10;
            this.gradientOverlay_.y = screenRect.top;
        }
        else
        {
            this.gradientOverlay_.visible = false;
        }

        // draw hw capable screen filters
        if(isGpuRender && Renderer.inGame)
        {
            filter = this.getFilterIndex();
            render3D = StaticInjectorContext.getInjector().getInstance(Render3D);
            render3D.dispatch(this.graphicsData_,this.graphicsData3d_,width_,height_,camera,filter);
            for(i = 0; i < this.graphicsData_.length; i++)
            {
                if(this.graphicsData_[i] is GraphicsBitmapFill && GraphicsFillExtra.isSoftwareDraw(GraphicsBitmapFill(this.graphicsData_[i])))
                {
                    this.graphicsDataStageSoftware_.push(this.graphicsData_[i]);
                    this.graphicsDataStageSoftware_.push(this.graphicsData_[i + 1]);
                    this.graphicsDataStageSoftware_.push(this.graphicsData_[i + 2]);
                }
                else if(this.graphicsData_[i] is GraphicsSolidFill && GraphicsFillExtra.isSoftwareDrawSolid(GraphicsSolidFill(this.graphicsData_[i])))
                {
                    this.graphicsDataStageSoftware_.push(this.graphicsData_[i]);
                    this.graphicsDataStageSoftware_.push(this.graphicsData_[i + 1]);
                    this.graphicsDataStageSoftware_.push(this.graphicsData_[i + 2]);
                }
            }
            if(this.graphicsDataStageSoftware_.length > 0)
            {
                map_.graphics.clear();
                map_.graphics.drawGraphicsData(this.graphicsDataStageSoftware_);
                if(this.lastSoftwareClear)
                {
                    this.lastSoftwareClear = false;
                }
            }
            else if(!this.lastSoftwareClear)
            {
                map_.graphics.clear();
                this.lastSoftwareClear = true;
            }
            if(time % 149 == 0)
            {
                GraphicsFillExtra.manageSize();
            }
        }
        else
        {
            map_.graphics.clear();
            map_.graphics.drawGraphicsData(this.graphicsData_);
        }

        // draw filters
        this.map_.filters.length = 0;
        if(this.player_ != null)
        {
            var filters:Array = [];
            if(this.player_.isDrunk())
            {
                d = 20 + 10 * Math.sin(time / 1000);
                filters.push(new BlurFilter(d,d));
            }
            if(this.player_.isBlind())
            {
                filters.push(BLIND_FILTER);
            }
            this.map_.filters = filters;
        }
        else if(this.map_.filters.length > 0)
        {
            this.map_.filters = [];
        }

        this.mapOverlay_.draw(camera,time);
        this.partyOverlay_.draw(camera,time);
    }


    private function getFilterIndex() : uint
    {
        var filterIndex:uint = 0;
        if(player_ != null)
        {
            if(player_.isBlind())
            {
                filterIndex = Renderer.STAGE3D_FILTER_BLIND;
            }
            else if(player_.isDrunk())
            {
                filterIndex = Renderer.STAGE3D_FILTER_DRUNK;
            }
        }
        return filterIndex;
    }


}
}