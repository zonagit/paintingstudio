//
//  StrokeJoin.swift
//  BrushChooser
//
//  Created by zef on 2/4/17.
//  Copyright © 2017 zef. All rights reserved.
//

import UIKit

protocol StrokeJoinDelegate: class {
    func chooseStrokeJoin(strokeJoin: StrokeJoin, newJoin join: StrokeJoin.LINE_JOINS)
}

class StrokeJoin: UIView {
    
    enum LINE_JOINS {
        case MITER_JOIN
        case ROUND_JOIN
        case BEVEL_JOIN
    }
    
    weak var delegate: StrokeJoinDelegate? = nil
    private var mXGap: CGFloat
    private var miterSelected: Bool = true
    private var roundSelected: Bool = false
    private var bevelSelected: Bool = false
    private let radius: CGFloat = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    private var leftX: CGFloat
    private let scale: CGFloat = UIScreen.main.scale/2.0
    
    
    
    
    override init(frame: CGRect) {
        mXGap = 0.0
        leftX = abs(UIScreen.main.bounds.width-radius) + 30
        if UIScreen.main.bounds.width>UIScreen.main.bounds.height {
            leftX = 0.0
        }
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 1, alpha: 0.0)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        mXGap = CGFloat(bounds.size.width/3.0)
        let miterJoinButton: UIButton = getMiterJoinButton()
        self.addSubview(miterJoinButton)
        let roundJoinButton: UIButton = getRoundJoinButton()
        self.addSubview(roundJoinButton)
        let bevelJoinButton: UIButton = getBevelJoinButton()
        self.addSubview(bevelJoinButton)
    }
    
    func drawImage(lineJoin: LINE_JOINS, xGap: CGFloat, selected: Bool) -> UIImage {
        let context: CGContext = UIGraphicsGetCurrentContext()!
        
        UIGraphicsBeginImageContext(frame.size)
        
        context.setLineWidth(5.0)
        if selected {
            context.setStrokeColor(UIColor.yellow.cgColor)
        }
        else {
            context.setStrokeColor(UIColor.blue.cgColor)
        }
        context.move(to: CGPoint(x:leftX + xGap, y:40))
        context.addLine(to: CGPoint(x: leftX + 20 + xGap, y:20))
        context.addLine(to: CGPoint(x:leftX + 40 + xGap, y:40))
        
        switch lineJoin {
        case .MITER_JOIN:
            context.setLineJoin(CGLineJoin.miter)
        case .ROUND_JOIN:
            context.setLineJoin(CGLineJoin.round)
        case .BEVEL_JOIN:
            context.setLineJoin(CGLineJoin.bevel)
        }
        context.strokePath()
        
        context.setStrokeColor(UIColor.darkGray.cgColor)
        context.setLineWidth(1.0)
        context.move(to: CGPoint(x:leftX + xGap, y:40))
        context.addLine(to: CGPoint(x:leftX + 20 + xGap, y:20))
        context.addLine(to: CGPoint(x:leftX + 40 + xGap, y:40))
        context.strokePath()
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return resultImage!
    }
    
    func getMiterJoinButton()-> UIButton {
        let miterJoinImage: UIImage = drawImage(lineJoin: LINE_JOINS.MITER_JOIN, xGap: 0.0, selected: miterSelected)
        let miterJoinButton: UIButton = UIButton()
        miterJoinButton.frame = CGRect(x:leftX,y:5,width:40,height:40)
        miterJoinButton.setImage(miterJoinImage, for: UIControlState.normal)
        miterJoinButton.tag = 1
        
        miterJoinButton.addTarget(self,action:#selector(joinButtonClicked), for: UIControlEvents.touchUpInside)
        return miterJoinButton
    }
    
    func getRoundJoinButton()-> UIButton {
        let roundJoinImage: UIImage = drawImage(lineJoin: LINE_JOINS.ROUND_JOIN, xGap: mXGap, selected: roundSelected)
        let roundJoinButton: UIButton = UIButton()
        roundJoinButton.frame = CGRect(x:leftX + mXGap,y:5,width:40,height:40)
        roundJoinButton.setImage(roundJoinImage, for: UIControlState.normal)
        roundJoinButton.tag = 2
        roundJoinButton.addTarget(self,action:#selector(joinButtonClicked), for: UIControlEvents.touchUpInside)
        return roundJoinButton
    }
    
    func getBevelJoinButton()-> UIButton {
        let bevelJoinImage: UIImage = drawImage(lineJoin: LINE_JOINS.BEVEL_JOIN,xGap: 2*mXGap, selected: bevelSelected)
        let bevelJoinButton: UIButton = UIButton()
        bevelJoinButton.frame = CGRect(x:leftX + 2*mXGap,y:5,width:40,height:40)
        bevelJoinButton.setImage(bevelJoinImage, for:UIControlState.normal)
        bevelJoinButton.tag = 3
        bevelJoinButton.addTarget(self,action:#selector(joinButtonClicked), for: UIControlEvents.touchUpInside)
        return bevelJoinButton
    }
    
    func joinButtonClicked(sender: UIButton) {
        switch sender.tag {
        case 1:
            miterSelected = true
            roundSelected = false
            bevelSelected = false
            setNeedsDisplay()
            delegate?.chooseStrokeJoin(strokeJoin: self, newJoin: LINE_JOINS.MITER_JOIN)
            
        case 2:
            roundSelected = true
            miterSelected = false
            bevelSelected = false
            setNeedsDisplay()
            delegate?.chooseStrokeJoin(strokeJoin: self, newJoin: LINE_JOINS.ROUND_JOIN)
        case 3:
            bevelSelected = true
            roundSelected = false
            miterSelected = false
            setNeedsDisplay()
            delegate?.chooseStrokeJoin(strokeJoin: self, newJoin: LINE_JOINS.BEVEL_JOIN)
        default:
            break
        }
        
    }
    
    func setSelected(lineJoin: CGLineJoin) {
        switch lineJoin {
        case .miter:
            miterSelected = true
            roundSelected = false
            bevelSelected = false
        case .round:
            roundSelected = true
            miterSelected = false
            bevelSelected = false
        case .bevel:
            bevelSelected = true
            roundSelected = false
            miterSelected = false
        }
    }

    
}
