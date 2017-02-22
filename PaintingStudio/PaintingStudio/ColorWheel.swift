//
//  ColorWheel.swift
//  BrushChooser
//
//  Created by zef on 2/3/17.
//  Copyright © 2017 zef. All rights reserved.
//

import UIKit

typealias RGB = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
typealias HSV = (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat)

protocol ColorWheelDelegate: class {
    func chooseColor(_ hue: CGFloat, saturation: CGFloat)
}

class ColorWheel: UIView {
    var color: UIColor!
    // layer for the wheel
    var wheelLayer: CALayer!
    let scale: CGFloat = UIScreen.main.scale
    
    // layer for the wheel border
    var borderLayer: CAShapeLayer!
    var borderWidth: CGFloat = 2.0
    
    // Layer for the indicator
    var indicatorLayer: CAShapeLayer!
    var touchPoint: CGPoint!
    var indicatorCircleRadius: CGFloat = 12.0
    let indicatorColor: CGColor = UIColor.lightGray.cgColor
    let indicatorBorderWidth: CGFloat = 2.0
    
    weak var delegate: ColorWheelDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    init(frame: CGRect, color: UIColor!) {
        super.init(frame: frame)
        
        self.color = color
        
        // Layer for the Hue/Saturation wheel
        wheelLayer = CALayer()
        wheelLayer.frame = CGRect(x: 20, y: 20, width: self.frame.width-40, height: self.frame.height-40)
        wheelLayer.contents = getColorWheelImage(wheelLayer.frame.size)
        self.layer.addSublayer(wheelLayer)
        
        // wheel border
        borderLayer = CAShapeLayer()
        borderLayer.strokeColor = UIColor.gray.cgColor
        borderLayer.lineWidth = borderWidth
        borderLayer.fillColor = nil
        self.layer.addSublayer(borderLayer)
        
        let wheelDiameter: CGFloat = min(wheelLayer.frame.width, wheelLayer.frame.height)
        borderLayer.path = UIBezierPath(roundedRect: CGRect(x: 20, y: 20, width: wheelDiameter, height: wheelDiameter), cornerRadius: wheelDiameter/2.0).cgPath
        
        
        // Layer for the indicator
        indicatorLayer = CAShapeLayer()
        indicatorLayer.strokeColor = indicatorColor
        indicatorLayer.lineWidth = indicatorBorderWidth
        indicatorLayer.fillColor = nil
        
        self.layer.addSublayer(indicatorLayer)
        self.backgroundColor = UIColor(white: 1, alpha: 0.0)
        
        setInitialColor(color)
        
    }
    
    func drawIndicator() {
        if (touchPoint != nil) {
            indicatorLayer.path = UIBezierPath(roundedRect: CGRect(x: touchPoint.x-indicatorCircleRadius, y: touchPoint.y-indicatorCircleRadius, width: indicatorCircleRadius*2, height: indicatorCircleRadius*2), cornerRadius: indicatorCircleRadius).cgPath
            
            indicatorLayer.fillColor = self.color.cgColor
        }
    }
    
    func setInitialColor(_ color: UIColor!) {
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        let ok: Bool = color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        if (!ok) {
            print("The initial color provided can not be converted to a HSV color")
        }
        self.color = color
        touchPoint = getPositionFromHueAndSaturation(hue, saturation: saturation)
        drawIndicator()
    }
    
    // Get the position in the wheel for the given hue and saturation
    func getPositionFromHueAndSaturation(_ hue: CGFloat, saturation: CGFloat) -> CGPoint {
        let wheelDiameter: CGFloat = min(wheelLayer.frame.width, wheelLayer.frame.height)
        let wheelRadius: CGFloat = saturation * wheelDiameter / 2
        let x = wheelDiameter / 2 + wheelRadius * cos(hue * CGFloat(M_PI) * 2) + 20;
        let y = wheelDiameter / 2 + wheelRadius * sin(hue * CGFloat(M_PI) * 2) + 20;
        return CGPoint(x: x, y: y)
    }
    
    func getColorWheelImage(_ size: CGSize) -> CGImage {
        // Creates a bitmap of the Hue Saturation wheel
        let diameter: CGFloat = min(size.width*scale, size.height*scale)
        let bufferLength: Int = Int(diameter * diameter * 4)
        
        let bitmapData: CFMutableData = CFDataCreateMutable(nil, 0)
        CFDataSetLength(bitmapData, CFIndex(bufferLength))
        let bitmap = CFDataGetMutableBytePtr(bitmapData)
        
        for y in stride(from: CGFloat(0), to: diameter, by: CGFloat(1)) {
            for x in stride(from: CGFloat(0), to: diameter, by: CGFloat(1)) {
                var hsv: HSV = (hue: 0, saturation: 0, brightness: 0, alpha: 0)
                var rgb: RGB = (red: 0, green: 0, blue: 0, alpha: 0)
                
                let color = getHueAndSaturationFromPoint(CGPoint(x: x, y: y))
                let hue = color.hue
                let saturation = color.saturation
                var alpha: CGFloat = 0.0
                if (saturation < 1.0) {
                    // Antialias the edge of the circle.
                    if (saturation > 0.99) {
                        alpha = (1.0 - saturation) * 100
                    } else {
                        alpha = 1.0;
                    }
                    
                    hsv.hue = hue
                    hsv.saturation = saturation
                    hsv.brightness = 1.0
                    hsv.alpha = alpha
                    rgb = hsv2rgb(hsv)
                }
                let offset = Int(4 * (x + y * diameter))
                bitmap?[offset] = UInt8(rgb.red*255)
                bitmap?[offset + 1] = UInt8(rgb.green*255)
                bitmap?[offset + 2] = UInt8(rgb.blue*255)
                bitmap?[offset + 3] = UInt8(rgb.alpha*255)
            }
        }
        
        // Convert the bitmap to a CGImage
        let colorSpace: CGColorSpace? = CGColorSpaceCreateDeviceRGB()
        let dataProvider: CGDataProvider? = CGDataProvider(data: bitmapData)
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo().rawValue | CGImageAlphaInfo.last.rawValue)
        let imageRef: CGImage? = CGImage(width: Int(diameter), height: Int(diameter), bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: Int(diameter) * 4, space: colorSpace!, bitmapInfo: bitmapInfo, provider: dataProvider!, decode: nil, shouldInterpolate: false, intent: CGColorRenderingIntent.defaultIntent)
        return imageRef!
    }
    
    // get the hue and saturation given a point in the wheel
    func getHueAndSaturationFromPoint(_ position: CGPoint) -> (hue: CGFloat, saturation: CGFloat) {
        let c = wheelLayer.frame.width * scale / 2
        let dx = CGFloat(position.x - c) / c
        let dy = CGFloat(position.y - c) / c
        let radius = sqrt(CGFloat (dx * dx + dy * dy))
        
        let saturation: CGFloat = radius
        
        var hue: CGFloat
        if (radius == 0) {
            hue = 0;
        } else {
            hue = acos(dx/radius) / CGFloat(M_PI) / 2.0
            if (dy < 0) {
                hue = 1.0 - hue
            }
        }
        return (hue, saturation)
    }
    
    // see
    // http://stackoverflow.com/questions/3018313/algorithm-to-convert-rgb-to-hsv-and-hsv-to-rgb-in-range-0-255-for-both
    // for algorithm to convert from hsv to rgb
    func hsv2rgb(_ hsv: HSV) -> RGB {
        var rgb: RGB = (red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        var red: CGFloat
        var green: CGFloat
        var blue: CGFloat
        
        let i = Int(hsv.hue * 6)
        let f = hsv.hue * 6 - CGFloat(i)
        let p = hsv.brightness * (1 - hsv.saturation)
        let q = hsv.brightness * (1 - f * hsv.saturation)
        let t = hsv.brightness * (1 - (1 - f) * hsv.saturation)
        switch (i % 6) {
        case 0:
            red = hsv.brightness
            green = t
            blue = p
        case 1:
            red = q
            green = hsv.brightness
            blue = p
        case 2:
            red = p
            green = hsv.brightness
            blue = t
        case 3:
            red = p
            green = q
            blue = hsv.brightness
        case 4:
            red = t
            green = p
            blue = hsv.brightness
        case 5:
            red = hsv.brightness
            green = p
            blue = q
        default:
            red = hsv.brightness
            green = t
            blue = p;
        }
        
        rgb.red = red
        rgb.green = green
        rgb.blue = blue
        rgb.alpha = hsv.alpha
        return rgb
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        indicatorCircleRadius = 18.0
        touchHandler(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchHandler(touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        indicatorCircleRadius = 12.0
        touchHandler(touches)
    }
    
    func touchHandler(_ touches: Set<UITouch>) {
        if let touch = touches.first {
            touchPoint = touch.location(in: self)
        }
        
        let indicator = getIndicatorPosition(touchPoint)
        touchPoint = indicator.point
        var color = (hue: CGFloat(0), saturation: CGFloat(0))
        if !indicator.isCenter  {
            color = getHueAndSaturationFromPoint(CGPoint(x: touchPoint.x*scale, y: touchPoint.y*scale))
        }
        
        self.color = UIColor(hue: color.hue, saturation: color.saturation, brightness: 1.0, alpha: 1.0)
        
        delegate?.chooseColor(color.hue, saturation: color.saturation)
        
        drawIndicator()
    }
    
    func getIndicatorPosition(_ coord: CGPoint) -> (point: CGPoint, isCenter: Bool) {
        let radius: CGFloat = min(wheelLayer.frame.width, wheelLayer.frame.height)/2
        let wheelLayerCenter: CGPoint = CGPoint(x: wheelLayer.frame.origin.x + radius, y: wheelLayer.frame.origin.y + radius)
        
        let dx: CGFloat = coord.x - wheelLayerCenter.x
        let dy: CGFloat = coord.y - wheelLayerCenter.y
        let distance: CGFloat = sqrt(dx*dx + dy*dy)
        var outputCoord: CGPoint = coord
        
        // If the touch position is outside the wheel, move it to the edge of the wheel
        if (distance > radius) {
            let theta: CGFloat = atan2(dy, dx)
            outputCoord.x = radius * cos(theta) + wheelLayerCenter.x
            outputCoord.y = radius * sin(theta) + wheelLayerCenter.y
        }
        
        // If the touch position is close to the center of the wheel, move it to the center and set the color to white
        let whiteThreshold: CGFloat = 10
        var isCenter = false
        if (distance < whiteThreshold) {
            outputCoord.x = wheelLayerCenter.x
            outputCoord.y = wheelLayerCenter.y
            isCenter = true
        }
        return (outputCoord, isCenter)
    }
    
    
}
