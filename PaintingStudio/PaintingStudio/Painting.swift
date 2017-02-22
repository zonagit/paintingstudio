//
//  Painting.swift
//  PaintingStudio
//
//  Created by zef on 2/17/17.
//  Copyright © 2017 zef. All rights reserved.
//

import UIKit

class Painting {
    var mStrokes: [Stroke]?
    var mImage: UIImage?
    var lineCap: CGLineCap?
    var lineJoin: CGLineJoin?
    var lineWidth: CGFloat?
    var strokeColor: UIColor?
    var doneStrokes: [UIImage]?
    var undoneStrokes: [UIImage]?
    var width: CGFloat?
    var height: CGFloat?
        
    init() {
        mStrokes = []
        mImage = UIImage()
    }
    
    func getStroke(index: Int) -> Stroke {
        return mStrokes![index]
    }
    
    func addStroke(index: Int, stroke: Stroke) {
        mStrokes!.append(stroke)
    }
    
    // get/set painting image
    var image: UIImage {
        get {
            return mImage!
        }
        set {
            mImage = newValue
        }
    }
    
    var strokes: [Stroke] {
        get {
            return mStrokes!
        }
        set {
            mStrokes = newValue
        }
    }
    
}
