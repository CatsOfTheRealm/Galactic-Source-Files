package
{
import ToolForge.Mediators.ToolForgeMediatorConfiguration;

import com.company.assembleegameclient.map.Camera;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.util.AssetLoader;
import com.company.assembleegameclient.util.StageProxy;

import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;

import kabam.lib.net.NetConfig;
import kabam.rotmg.account.AccountConfig;
import kabam.rotmg.appengine.AppEngineConfig;
import kabam.rotmg.application.ApplicationConfig;
import kabam.rotmg.application.ApplicationSpecificConfig;
import kabam.rotmg.application.EnvironmentConfig;
import kabam.rotmg.assets.AssetsConfig;
import kabam.rotmg.build.BuildConfig;
import kabam.rotmg.characters.CharactersConfig;
import kabam.rotmg.classes.ClassesConfig;
import kabam.rotmg.core.CoreConfig;
import kabam.rotmg.core.StaticInjectorContext;
import kabam.rotmg.dailyLogin.config.DailyLoginConfig;
import kabam.rotmg.death.DeathConfig;
import kabam.rotmg.dialogs.DialogsConfig;
import kabam.rotmg.editor.EditorConfig;
import kabam.rotmg.external.ExternalConfig;
import kabam.rotmg.fame.FameConfig;
import kabam.rotmg.fortune.FortuneConfig;
import kabam.rotmg.game.GameConfig;
import kabam.rotmg.language.LanguageConfig;
import kabam.rotmg.legends.LegendsConfig;
import kabam.rotmg.maploading.MapLoadingConfig;
import kabam.rotmg.marketUI.MarketConfig;
import kabam.rotmg.minimap.MiniMapConfig;
import kabam.rotmg.mysterybox.MysteryBoxConfig;
import kabam.rotmg.protip.ProTipConfig;
import kabam.rotmg.queue.QueueConfig;
import kabam.rotmg.servers.ServersConfig;
import kabam.rotmg.stage3D.Stage3DConfig;
import kabam.rotmg.startup.StartupConfig;
import kabam.rotmg.startup.control.StartupSignal;
import kabam.rotmg.text.TextConfig;
import kabam.rotmg.tooltips.TooltipsConfig;
import kabam.rotmg.ui.UIConfig;
import kabam.rotmg.ui.UIUtils;
import robotlegs.bender.bundles.mvcs.MVCSBundle;
import robotlegs.bender.extensions.signalCommandMap.SignalCommandMapExtension;
import robotlegs.bender.framework.api.IContext;
import robotlegs.bender.framework.api.LogLevel;
import com.demonsters.debugger.MonsterDebugger;
import flash.display.Sprite;
[SWF(frameRate="120", backgroundColor="#000000", width="800", height="600")]
public class WebMain extends Sprite {

    public static var ENV:String;
    public static var STAGE:Stage;
    public static var serverIP:String = "127.0.0.1";
    public static var sWidth:Number = 800;
    public static var sHeight:Number = 600;
    protected var context:IContext;

    public function WebMain() {
        //MonsterDebugger.initialize(this);
        //MonsterDebugger.trace(this, "Hello World!");
            try {
                if (stage) {
                    stage.addEventListener("resize", this.onStageResize);

                    this.setup();
                } else {
                    addEventListener("addedToStage", this.onAddedToStage);
                }
            }
            catch (error:Error) {}
        }

    private function onAddedToStage(_arg1:Event):void {
        stage.addEventListener(Event.RESIZE, this.onStageResize, false, 0, true);
        removeEventListener("addedToStage", this.onAddedToStage);
        this.setup();
    }

    public function onStageResize(_arg_1:Event):void {
        this.scaleX = 1;
        this.scaleY = 1;
        this.x = (800 - stage.stageWidth) >> 1;
        this.y = (600 - stage.stageHeight) >> 1;


        sWidth = stage.stageWidth;
        sHeight = stage.stageHeight;
        Camera.resetDimensions();
        Stage3DConfig.resetDimensions();
    }

    private function setup():void {
        this.initFlashVars();
        this.setEnvironment();
        this.hackParameters();
        this.createContext();
        new AssetLoader().load();
        stage.scaleMode = "noScale";
        stage.quality = "low";
        this.context.injector.getInstance(StartupSignal).dispatch();
        STAGE = stage;
        UIUtils.toggleQuality(Parameters.data_.uiQuality);
        if (Parameters.data_.FPS == undefined) {
            Parameters.data_.FPS = "120";
        }
        Parameters.data_.GPURender = false;
        Parameters.HWAcceleration = Parameters.data_.HWAcceleration;
        stage.frameRate = 120;
    }

    private function setEnvironment():void {
        ENV = stage.loaderInfo.parameters["env"];
        ENV = "production";
    }

    private function initFlashVars():void
    {
        serverIP = stage.loaderInfo.parameters["Host"];
        if (serverIP == null)
            serverIP = "127.0.0.1";
    }

    private function hackParameters():void {
        Parameters.root = stage.root;
    }

    private function createContext():void {
        this.context = new StaticInjectorContext();
        this.context.injector.map(LoaderInfo).toValue(root.stage.root.loaderInfo);
        var _local1:StageProxy = new StageProxy(this);
        this.context.injector.map(StageProxy).toValue(_local1);
        this.context
                .extend(MVCSBundle)
                .extend(SignalCommandMapExtension)
                .configure(BuildConfig)
                .configure(StartupConfig)
                .configure(NetConfig)
                .configure(DialogsConfig)
                .configure(EnvironmentConfig)
                .configure(ApplicationConfig)
                .configure(LanguageConfig)
                .configure(TextConfig)
                .configure(AppEngineConfig)
                .configure(AccountConfig)
                .configure(CoreConfig)
                .configure(ApplicationSpecificConfig)
                .configure(AssetsConfig)
                .configure(DeathConfig)
                .configure(CharactersConfig)
                .configure(ServersConfig)
                .configure(GameConfig)
                .configure(EditorConfig)
                .configure(UIConfig)
                .configure(MarketConfig)
                .configure(MiniMapConfig)
                .configure(LegendsConfig)
                .configure(FameConfig)
                .configure(TooltipsConfig)
                .configure(ProTipConfig)
                .configure(MapLoadingConfig)
                .configure(ClassesConfig)
                .configure(DailyLoginConfig)
                .configure(Stage3DConfig)
                .configure(ExternalConfig)
                .configure(MysteryBoxConfig)
                .configure(FortuneConfig)
                .configure(QueueConfig)
                .configure(ToolForgeMediatorConfiguration)
                .configure(this);
        this.context.logLevel = LogLevel.DEBUG;
    }


}
}