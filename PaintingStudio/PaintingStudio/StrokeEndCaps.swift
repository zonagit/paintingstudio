//
//  StrokeEndCaps.swift
//  BrushChooser
//
//  Created by zef on 2/4/17.
//  Copyright © 2017 zef. All rights reserved.
//

import UIKit

protocol StrokeEndCapsDelegate: class {
    func chooseStrokeEndCaps(strokeEndCaps: StrokeEndCaps, newEndCap endCap: StrokeEndCaps.LINE_CAPS)
}

class StrokeEndCaps: UIView {
    enum LINE_CAPS {
        case BUTT_CAP
        case ROUND_CAP
        case PROJECTING_SQUARE_CAP
    }
    
    weak var delegate: StrokeEndCapsDelegate? = nil
    private var mXGap: CGFloat
    private var buttSelected: Bool = true
    private var roundSelected: Bool = false
    private var squareSelected: Bool = false
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
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        setNeedsDisplay()
//    }
    
    override func draw(_ rect: CGRect) {
        mXGap = CGFloat(bounds.size.width/3.0)
//        if (bounds.size.width>bounds.size.height) {
//            mXGap = CGFloat(bounds.size.width/20.0)
//
//        }
        let buttCapButton: UIButton = getButtCapButton()
        self.addSubview(buttCapButton)
        let roundCapButton: UIButton = getRoundCapButton()
        self.addSubview(roundCapButton)
        let squareCapButton: UIButton = getSquareCapButton()
        self.addSubview(squareCapButton)
    }
    
    func drawImage(lineCap: LINE_CAPS, xGap: CGFloat, selected: Bool) -> UIImage {
        let context: CGContext = UIGraphicsGetCurrentContext()!
        
        UIGraphicsBeginImageContext(frame.size)
        
        context.setLineWidth(6.0)
        if selected {
            context.setStrokeColor(UIColor.yellow.cgColor)
        }
        else {
            context.setStrokeColor(UIColor.blue.cgColor)
        }
        context.move(to: CGPoint(x:leftX + xGap, y:10))
        context.addLine(to: CGPoint(x:leftX + 30 + xGap, y:10))
        
        switch lineCap {
        case .BUTT_CAP:
            context.setLineCap(CGLineCap.butt)
        case .ROUND_CAP:
            context.setLineCap(CGLineCap.round)
        case .PROJECTING_SQUARE_CAP:
            context.setLineCap(CGLineCap.square)        }
        context.strokePath()
        context.setLineWidth(1.0)
        context.setStrokeColor(UIColor.darkGray.cgColor)
        context.move(to: CGPoint(x:leftX + xGap, y:10))
        context.addLine(to: CGPoint(x: leftX + 30 + xGap, y:10))
        context.strokePath()
        
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return resultImage!
    }
    
    func getButtCapButton()-> UIButton {
        let buttCapImage: UIImage = drawImage(lineCap: LINE_CAPS.BUTT_CAP, xGap: 0.0, selected: buttSelected)
        let buttCapButton: UIButton = UIButton()
        buttCapButton.frame = CGRect(x:leftX,y:5,width:35,height:15)
        buttCapButton.setImage(buttCapImage, for: UIControlState.normal)
        
        buttCapButton.tag = 1
        buttCapButton.addTarget(self,action:#selector(capButtonClicked), for: UIControlEvents.touchUpInside)
        
        return buttCapButton
        
    }
    
    func getRoundCapButton()-> UIButton {
        let roundCapImage: UIImage = drawImage(lineCap: LINE_CAPS.ROUND_CAP, xGap: mXGap, selected: roundSelected)
        let roundCapButton: UIButton = UIButton()
        roundCapButton.frame = CGRect(x:leftX + mXGap,y:5,width:35,height:15)
        roundCapButton.setImage(roundCapImage, for: UIControlState.normal)
        
        roundCapButton.tag = 2
        roundCapButton.addTarget(self,action:#selector(capButtonClicked), for: UIControlEvents.touchUpInside)
        return roundCapButton
    }
    
    func getSquareCapButton()-> UIButton {
        let squareCapImage: UIImage = drawImage(lineCap: LINE_CAPS.PROJECTING_SQUARE_CAP, xGap: 2*mXGap, selected: squareSelected)
        let squareCapButton: UIButton = UIButton()
        squareCapButton.frame = CGRect(x:leftX + 2*mXGap,y:5,width:35,height:15)
        squareCapButton.setImage(squareCapImage, for: UIControlState.normal)
        squareCapButton.tag = 3
        
        squareCapButton.addTarget(self,action:#selector(capButtonClicked), for: UIControlEvents.touchUpInside)
        return squareCapButton
    }
    
    func capButtonClicked(sender: UIButton) {
        switch sender.tag {
        case 1:
            buttSelected = true
            roundSelected = false
            squareSelected = false
            setNeedsDisplay()
            delegate?.chooseStrokeEndCaps(strokeEndCaps: self, newEndCap: LINE_CAPS.BUTT_CAP)
            
        case 2:
            roundSelected = true
            buttSelected = false
            squareSelected = false
            setNeedsDisplay()
            delegate?.chooseStrokeEndCaps(strokeEndCaps: self, newEndCap: LINE_CAPS.ROUND_CAP)
        case 3:
            squareSelected = true
            roundSelected = false
            buttSelected = false
            setNeedsDisplay()
            delegate?.chooseStrokeEndCaps(strokeEndCaps: self, newEndCap: LINE_CAPS.PROJECTING_SQUARE_CAP)
        default:
            break
        }
    }
    
    func setSelected(lineCap: CGLineCap) {
        switch lineCap {
        case .butt:
            buttSelected = true
            roundSelected = false
            squareSelected = false
        case .round:
            roundSelected = true
            buttSelected = false
            squareSelected = false
        case .square:
            squareSelected = true
            roundSelected = false
            buttSelected = false
        }
    }
}

