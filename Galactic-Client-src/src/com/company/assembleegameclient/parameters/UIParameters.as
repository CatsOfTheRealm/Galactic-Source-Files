package com.company.assembleegameclient.parameters {
public class UIParameters {
    private static const defaultWidth:Number = 800;
    private static const defaultHeight:Number = 600;

    public static function left():Number {
        return (defaultWidth - Parameters.gameWidth) / 2;
    }
    public static function right():Number {
        return defaultWidth + (Parameters.gameWidth - defaultWidth) / 2;
    }
    public static function bottom():Number {
        return defaultHeight - (Parameters.gameHeight - defaultHeight) / 2;
    }
    public static function top():Number {
        return (defaultHeight + Parameters.gameHeight) / 2;
    }

    public static function getScale():Number {
        return 1;
    }
}
}
