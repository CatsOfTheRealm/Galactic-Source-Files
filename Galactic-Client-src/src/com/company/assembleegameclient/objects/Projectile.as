package com.company.assembleegameclient.objects
{
    import com.company.assembleegameclient.engine3d.Point3D;
    import com.company.assembleegameclient.map.Camera;
    import com.company.assembleegameclient.map.Map;
    import com.company.assembleegameclient.map.Square;
    import com.company.assembleegameclient.objects.particles.HitEffect;
    import com.company.assembleegameclient.objects.particles.SparkParticle;
    import com.company.assembleegameclient.parameters.Parameters;
    import com.company.assembleegameclient.tutorial.Tutorial;
    import com.company.assembleegameclient.tutorial.doneAction;
    import com.company.assembleegameclient.util.BloodComposition;
    import com.company.assembleegameclient.util.FreeList;
    import com.company.assembleegameclient.util.RandomUtil;
    import com.company.assembleegameclient.util.TextureRedrawer;
import com.company.assembleegameclient.util.TextureRedrawer_textureShaderEmbed_;
import com.company.util.GraphicsUtil;
    import com.company.util.Trig;
import com.hurlant.util.asn1.parser.boolean;

import flash.display.BitmapData;
import flash.display.GradientType;
import flash.display.GraphicsGradientFill;
    import flash.display.GraphicsPath;
    import flash.display.IGraphicsData;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Vector3D;
    import flash.utils.Dictionary;

    public class Projectile extends BasicObject
    {
        private static var objBullIdToObjId_:Dictionary = new Dictionary();
        public var props_:ObjectProperties;
        public var containerProps_:ObjectProperties;
        public var projProps_:ProjectileProperties;
        public var texture_:BitmapData;
        public var bulletId_:uint;
        public var ownerId_:int;
        public var containerType_:int;
        public var bulletType_:uint;
        public var damagesEnemies_:Boolean;
        public var damagesPlayers_:Boolean;
        public var damage_:int;
        public var _isCrit:Number = 1;
        public var sound_:String;
        public var startX_:Number;
        public var startY_:Number;
        public var startTime_:int;
        public var angle_:Number = 0;
        public var multiHitDict_:Dictionary;
        public var p_:Point3D;
        private var staticPoint_:Point;
        private var staticVector3D_:Vector3D;
        protected var shadowGradientFill_:GraphicsGradientFill;
        protected var shadowPath_:GraphicsPath;
        private var ProjSize:Number;

        public function Projectile()
        {
            this.p_ = new Point3D(100);
            this.staticPoint_ = new Point();
            this.staticVector3D_ = new Vector3D();
            this.shadowGradientFill_ = new GraphicsGradientFill(GradientType.RADIAL,[0,0],[0.5,0],null,new Matrix());
            this.shadowPath_ = new GraphicsPath(GraphicsUtil.QUAD_COMMANDS,new Vector.<Number>());
            super();
        }
        public static function findObjId(_arg1:int, _arg2:uint) : int
        {
            return objBullIdToObjId_[_arg2 << 24 | _arg1];
        }

        public static function getNewObjId(_arg1:int, _arg2:uint):int
        {
            var _local3:int = getNextFakeObjectId();
            objBullIdToObjId_[_arg2 << 24 | _arg1] = _local3;
            return _local3;
        }

        public static function removeObjId(_arg1:int, _arg2:uint):void
        {
            delete objBullIdToObjId_[_arg2 << 24 | _arg1];
        }

        public static function dispose():void
        {
            objBullIdToObjId_ = new Dictionary();
        }


        public function reset(containerType:int, bulletType:int, ownerId:int, bulletId:int, angle:Number, startTime:int) : void
        {
            ProjSize = 0;
            clear();
            this.containerType_ = containerType;
            this.bulletType_ = bulletType;
            this.bulletId_ = bulletId;
            this.ownerId_ = ownerId;
            this.angle_ = Trig.boundToPI(angle);
            this.startTime_ = startTime;
            objectId_ = getNextFakeObjectId();
            z_ = 0.5;
            this.containerProps_ = ObjectLibrary.propsLibrary_[this.containerType_];
            this.projProps_ = this.containerProps_.projectiles_[bulletType];
            this.props_ = ObjectLibrary.getPropsFromId(this.projProps_.objectId_);
            hasShadow_ = this.props_.shadowSize_ > 0;
            var textureData:TextureData = ObjectLibrary.typeToTextureData_[this.props_.type_];
            this.texture_ = textureData.getTexture(objectId_);
            this.damagesPlayers_ = this.containerProps_.isEnemy_;
            this.damagesEnemies_ = !this.damagesPlayers_;
            this.sound_ = this.containerProps_.oldSound_;
            this.multiHitDict_ = this.projProps_.multiHit_ ? new Dictionary() : null;
            if(this.projProps_.size_ >= 0)
            {
                ProjSize = this.projProps_.size_;
            }
            else
            {
                ProjSize = ObjectLibrary.getSizeFromType(this.containerType_);
            }
            this.p_.setSize(8 * (ProjSize / 100));
            this.damage_ = 0;
        }



        public function setDamage(_arg1:int, _arg2:Number = 1):void {
            this._isCrit = _arg2;
            this.damage_ = _arg1 * _isCrit;
        }

        override public function addTo(map:Map, x:Number, y:Number) : Boolean
        {
            var player:Player = null;
            this.startX_ = x;
            this.startY_ = y;
            if(!super.addTo(map,x,y))
            {
                return false;
            }
            if(!this.containerProps_.flying_ && square_.sink_)
            {
                if (square_.obj_ && square_.obj_.props_.protectFromSink_)
                {
                    z_ = 0.5;
                }
                else
                {
                    z_ = 0.1;
                }
            }
            else
            {
                player = map.goDict_[this.ownerId_] as Player;
                if(player != null && player.sinkLevel_ > 0)
                {
                    z_ = (0.5 - (0.4 * (player.sinkLevel_ / Parameters.MAX_SINK_LEVEL)));
                }
            }
            return true;
        }

        public function moveTo(x:Number, y:Number) : Boolean
        {
            var square:Square = map_.getSquare(x,y);
            if(square == null)
            {
                return false;
            }
            x_ = x;
            y_ = y;
            square_ = square;
            return true;
        }

        override public function removeFromMap():void {
            super.removeFromMap();
            removeObjId(this.ownerId_, this.bulletId_);
            this.multiHitDict_ = null;
            FreeList.deleteObject(this);
        }

        private function positionAt(elapsed:int, p:Point) : void
        {
            var periodFactor:Number = NaN;
            var amplitudeFactor:Number = NaN;
            var theta:Number = NaN;
            var t:Number = NaN;
            var x:Number = NaN;
            var y:Number = NaN;
            var sin:Number = NaN;
            var cos:Number = NaN;
            var halfway:Number = NaN;
            var deflection:Number = NaN;
            p.x = this.startX_;
            p.y = this.startY_;
            var _local13:Number;
            var _local14:Number;
            var speed:Number = this.projProps_.speed_;
            var dist:Number = (elapsed * (speed / 10000));
            var phase:Number = this.bulletId_ % 2 == 0?Number(0):Number(Math.PI);
            if(this.projProps_.wavy_)
            {
                periodFactor = 6 * Math.PI;
                amplitudeFactor = Math.PI / 64;
                theta = this.angle_ + amplitudeFactor * Math.sin(phase + periodFactor * elapsed / 1000);
                p.x = p.x + dist * Math.cos(theta);
                p.y = p.y + dist * Math.sin(theta);
            }
            else if(this.projProps_.parametric_)
            {
                t = elapsed / this.projProps_.lifetime_ * 2 * Math.PI;
                x = Math.sin(t) * (Boolean(this.bulletId_ % 2)?1:-1);
                y = Math.sin(2 * t) * (this.bulletId_ % 4 < 2?1:-1);
                sin = Math.sin(this.angle_);
                cos = Math.cos(this.angle_);
                p.x = p.x + (x * cos - y * sin) * this.projProps_.magnitude_;
                p.y = p.y + (x * sin + y * cos) * this.projProps_.magnitude_;
            }
            else {
                if (this.projProps_.boomerang_) {
                    _local13 = ((this.projProps_.lifetime_ * (this.projProps_.speed_ / 10000)) / 2);
                    if (dist > _local13) {
                        dist = (_local13 - (dist - _local13));
                    }
                }
                else if(this.projProps_.blazingBoomerang_){
                    _local13 = ((this.projProps_.lifetime_ * (this.projProps_.speed_ / 10000)) / 1.25);
                    if (dist > _local13) {
                        dist = (_local13 - (dist - _local13));
                    }
                    this.angle_ += dist / 500;
                }
                else if(this.projProps_.vargoSpellBoomerang_){
                    var xVal:Number = ((this.projProps_.lifetime_ * (this.projProps_.speed_ / 10000)) / 4);
                    if(dist > 2 * xVal)
                        dist -=  2 * xVal;
                    else if(dist > xVal)
                        dist = xVal - (dist - xVal);
                    this.angle_ += dist / 5;
                }
                p.x = (p.x + (dist * Math.cos(this.angle_)));
                p.y = (p.y + (dist * Math.sin(this.angle_)));
                if (this.projProps_.amplitude_ != 0) {
                    _local14 = (this.projProps_.amplitude_ * Math.sin((phase + ((((elapsed / this.projProps_.lifetime_) * this.projProps_.frequency_) * 2) * Math.PI))));
                    p.x = (p.x + (_local14 * Math.cos((this.angle_ + (Math.PI / 2)))));
                    p.y = (p.y + (_local14 * Math.sin((this.angle_ + (Math.PI / 2)))));
                }
            }
        }

        override public function update(time:int, dt:int) : Boolean
        {
            var colors:Vector.<uint> = null;
            var player:Player = null;
            var isPlayer:Boolean = false;
            var isTargetAnEnemy:Boolean = false;
            var sendMessage:Boolean = false;
            var d:int = 0;
            var elapsed:int = time - this.startTime_;
            if(elapsed > this.projProps_.lifetime_)
            {
                return false;
            }

            var p:Point = this.staticPoint_;
            this.positionAt(elapsed,p);
            if(!this.moveTo(p.x,p.y) || square_.tileType_ == 255)
            {
                if(this.damagesPlayers_)
                {
                    map_.gs_.gsc_.squareHit(time, this.bulletId_, this.ownerId_);
                }
                else if(square_.obj_ != null)
                {
                    if (Parameters.data_.eyeCandyParticles) {//eyeCandyParticles Parameters.data_.particles
                        colors = BloodComposition.getColors(this.texture_);
                        map_.addObj(new HitEffect(colors, 100, 3, this.angle_, this.projProps_.speed_), p.x, p.y);
                    }
                }
                return false;
            }
            if (square_.obj_ != null && (!square_.obj_.props_.isEnemy_ || !this.damagesEnemies_) && (square_.obj_.props_.enemyOccupySquare_ || !this.projProps_.passesCover_ && square_.obj_.props_.occupySquare_)) {
                if (this.damagesPlayers_) {
                    map_.gs_.gsc_.squareHit(time, this.bulletId_, this.ownerId_);
                }
                else {
                    if (Parameters.data_.eyeCandyParticles) {
                        colors = BloodComposition.getColors(this.texture_);
                        map_.addObj(new HitEffect(colors, 100, 3, this.angle_, this.projProps_.speed_), p.x, p.y);
                    }
                }
                return false;
            }

            var target:GameObject = this.getHit(p.x,p.y);
            if(target != null)
            {
                player = map_.player_;
                isPlayer = player != null;
                isTargetAnEnemy = target.props_.isEnemy_;
                sendMessage = isPlayer && (this.damagesPlayers_ || isTargetAnEnemy && this.ownerId_ == player.objectId_);
                if(sendMessage)
                {
                    d = GameObject.damageWithDefense(this.damage_,target.defense_,this.projProps_.armorPiercing_,target.condition_);
                    if(target == player)
                    {
                        map_.gs_.gsc_.playerHit(this.bulletId_, this.ownerId_);
                        target.damage(d, this.projProps_.effects_, this);
                    }
                    else if(target.props_.isEnemy_)
                    {
                        map_.gs_.gsc_.enemyHit(time,this.bulletId_,target.objectId_, false);
                        target.damage(d,this.projProps_.effects_,this);
                    }
                }
                if(this.projProps_.multiHit_)
                {
                    this.multiHitDict_[target] = true;
                }
                else
                {
                    return false;
                }
            }
            return true;
        }


        public function getHit(pX:Number, pY:Number) : GameObject
        {
            var go:GameObject = null;
            var xDiff:Number = NaN;
            var yDiff:Number = NaN;
            var dist:Number = NaN;
            var minDist:Number = Number.MAX_VALUE;
            var minGO:GameObject = null;

            if (damagesEnemies_)
            {
                for each(go in map_.goDict_)
                {
                    xDiff = go.x_ > pX?Number(go.x_ - pX):Number(pX - go.x_);
                    yDiff = go.y_ > pY?Number(go.y_ - pY):Number(pY - go.y_);
                    if(!(xDiff > go.radius_ || yDiff >  go.radius_))
                    {
                        if(!(this.projProps_.multiHit_ && this.multiHitDict_[go] != null))
                        {
                            dist = Math.sqrt(xDiff * xDiff + yDiff * yDiff);
                            if(dist < minDist)
                            {
                                minDist = dist;
                                minGO = go;
                            }
                        }
                    }
                }
            }
            else if (damagesPlayers_)
            {
                go = map_.player_;
                if (go.isTargetable())
                {
                    xDiff = go.x_ > pX ? Number(go.x_ - pX) : Number(pX - go.x_);
                    yDiff = go.y_ > pY ? Number(go.y_ - pY) : Number(pY - go.y_);
                    if (!(xDiff > go.radius_ || yDiff >  go.radius_)) {
                        if (!(this.projProps_.multiHit_ && this.multiHitDict_[go] != null)) {
                            return go;
                        }
                    }
                }
            }
            return minGO;
        }

        override public function draw(graphicsData:Vector.<IGraphicsData>, camera:Camera, time:int) : void
        {

            var texture:BitmapData = this.texture_;
            var r:Number = this.props_.rotation_ == 0?Number(0):Number(time / this.props_.rotation_);
            this.staticVector3D_.x = x_;
            this.staticVector3D_.y = y_;
            this.staticVector3D_.z = z_;
            var _loc6_:Number = !Parameters.data_.smartProjectiles?Number(this.angle_):Number(this.getDirectionAngle(time));
            var _loc7_:Number = _loc6_ - camera.angleRad_ + this.props_.angleCorrection_ + r;
            this.p_.draw(graphicsData,this.staticVector3D_,_loc7_,camera.wToS_,camera,texture);
            if(this.projProps_.particleTrail_ && Parameters.data_.eyeCandyParticles)
            {
                map_.addObj(new SparkParticle(100, 16711935, 600, 0.5, RandomUtil.plusMinus(3), RandomUtil.plusMinus(3)), x_, y_);
                map_.addObj(new SparkParticle(100, 16711935, 600, 0.5, RandomUtil.plusMinus(3), RandomUtil.plusMinus(3)), x_, y_);
                map_.addObj(new SparkParticle(100, 16711935, 600, 0.5, RandomUtil.plusMinus(3), RandomUtil.plusMinus(3)), x_, y_);
            }
        }

        private function getDirectionAngle(param1:int) : Number
        {
            var _loc2_:int = param1 - this.startTime_;
            var _loc3_:Point = new Point();
            this.positionAt(_loc2_ + 16,_loc3_);
            var _loc4_:Number = _loc3_.x - x_;
            var _loc5_:Number = _loc3_.y - y_;
            return Math.atan2(_loc5_,_loc4_);
        }


        override public function drawShadow(_arg1:Vector.<IGraphicsData>, _arg2:Camera, _arg3:int):void {
            if (!Parameters.drawProj_) {
                return;
            }
            var _local4:Number = (this.props_.shadowSize_ / 400);
            var _local5:Number = (30 * _local4);
            var _local6:Number = (15 * _local4);
            this.shadowGradientFill_.matrix.createGradientBox((_local5 * 2), (_local6 * 2), 0, (posS_[0] - _local5), (posS_[1] - _local6));
            _arg1.push(this.shadowGradientFill_);
            this.shadowPath_.data.length = 0;
            Vector.<Number>(this.shadowPath_.data).push((posS_[0] - _local5), (posS_[1] - _local6), (posS_[0] + _local5), (posS_[1] - _local6), (posS_[0] + _local5), (posS_[1] + _local6), (posS_[0] - _local5), (posS_[1] + _local6));
            _arg1.push(this.shadowPath_);
        }
    }
}