//
//  BrushPreview.swift
//  BrushChooser
//
//  Created by zef on 2/3/17.
//  Copyright © 2017 zef. All rights reserved.
//

import UIKit

class BrushPreview: UIView {
    
    private var lineColor: UIColor
    private var lineWidth: Float
    private var lineCap: StrokeEndCaps.LINE_CAPS
    private var lineJoin: StrokeJoin.LINE_JOINS
    private let radius: CGFloat = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    private var leftX: CGFloat
    private let scale: CGFloat = UIScreen.main.scale/2.0
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        leftX = abs(UIScreen.main.bounds.width-radius) + 30
        if UIScreen.main.bounds.width>UIScreen.main.bounds.height {
            leftX = 0.0
        }
        lineColor = UIColor.green
        lineWidth = 0.5
        lineCap = StrokeEndCaps.LINE_CAPS.BUTT_CAP
        lineJoin = StrokeJoin.LINE_JOINS.MITER_JOIN
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 1, alpha: 0.0)
    }
    
    override func draw(_ rect: CGRect) {
        let context: CGContext = UIGraphicsGetCurrentContext()!
        //clear context
        context.clear(rect)
        
        context.setLineWidth(CGFloat(lineWidth))
        context.setStrokeColor(lineColor.cgColor)
        
        context.move(to: CGPoint(x:leftX, y:40))
        context.addLine(to: CGPoint(x:leftX + scale*20, y:20))
        context.addLine(to: CGPoint(x:leftX + scale*30, y:37))
        context.addLine(to: CGPoint(x:leftX + scale*50, y:25))
        context.addLine(to: CGPoint(x:leftX + scale*70, y:37))
        context.addLine(to: CGPoint(x:leftX + scale*95, y:28))
        context.addLine(to: CGPoint(x:leftX + scale*120, y:37))
        context.addLine(to: CGPoint(x:leftX + scale*150, y:30))
        context.addLine(to: CGPoint(x:leftX + scale*160, y:37))
        switch lineCap {
        case .BUTT_CAP:
            context.setLineCap(CGLineCap.butt)
        case .ROUND_CAP:
            context.setLineCap(CGLineCap.round)
        case .PROJECTING_SQUARE_CAP:
            context.setLineCap(CGLineCap.square)
        }
        switch lineJoin {
        case .MITER_JOIN:
            context.setLineJoin(CGLineJoin.miter)
        case .ROUND_JOIN:
            context.setLineJoin(CGLineJoin.round)
        case .BEVEL_JOIN:
            context.setLineJoin(CGLineJoin.bevel)
        }
        
        context.strokePath()
    }
    
    func updateColor(color: UIColor) {
        lineColor = color
        setNeedsDisplay()
    }
    
    func updateStrokeEndCap(cap: StrokeEndCaps.LINE_CAPS) {
        lineCap = cap
        setNeedsDisplay()
    }
    
    func updateStrokeJoin(join: StrokeJoin.LINE_JOINS) {
        lineJoin = join
        setNeedsDisplay()
    }
    
    func updateStrokeWidth(width: Float) {
        lineWidth = width
        setNeedsDisplay()
    }
    
    
}
