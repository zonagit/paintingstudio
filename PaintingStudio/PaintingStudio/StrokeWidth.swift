//
//  StrokeWidth.swift
//  BrushChooser
//
//  Created by zef on 2/4/17.
//  Copyright © 2017 zef. All rights reserved.
//

import UIKit

protocol StrokeWidthDelegate: class {
    func chooseStrokeWidth(strokeWidth: StrokeWidth, newWidth width: Float)
}

class StrokeWidth: UIView {
    
    private var mLabel: UILabel
    private var mValue: Float = 0.5
    private var mWidthSlider: UISlider?
    weak var delegate: StrokeWidthDelegate? = nil
    
    override init(frame: CGRect) {
        mLabel = UILabel()
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 1, alpha: 0.0)
    }
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        mWidthSlider = getStrokeWidthSlider()
        mWidthSlider?.value = mValue
        self.addSubview(mWidthSlider!)
        mLabel = UILabel(frame: CGRect(x:self.frame.width/2, y:20, width:60, height:30))
        
        mLabel.text = "\(mValue)"
        mLabel.backgroundColor = UIColor.white
        self.addSubview(mLabel)
    }
    
    
    func getStrokeWidthSlider()-> UISlider {
        let widthSlider: UISlider = UISlider(frame: CGRect(x:10,y:10,width:self.frame.width-20,height:10))
        widthSlider.minimumValue = 0.5
        widthSlider.maximumValue = 50.0
        
        widthSlider.addTarget(self, action: #selector(onChangeStrokeWidthSlider), for: UIControlEvents.valueChanged)
        
        return widthSlider
    }
    
    func onChangeStrokeWidthSlider(sender: UISlider) {
        mLabel.text = "\(sender.value)"
        delegate?.chooseStrokeWidth(strokeWidth: self, newWidth: sender.value)
    }
    
    var value: Float {
        get{return mValue}
        set{
            mValue = newValue
        }
    }
    
    
}

