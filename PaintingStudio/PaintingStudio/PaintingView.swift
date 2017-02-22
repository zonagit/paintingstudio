//
//  PaintingView.swift
//  PaintingStudio
//
//  Created by zef on 2/12/17.
//  Copyright © 2017 zef. All rights reserved.
//

import UIKit

// update image in the painting view controller whenever the mPathsImage below is updated
// i.e. when one stroke is added in touchesended, whenever the painting is initialized or whenever a
// painting is sent from the list to create a PaintingView
protocol PaintingViewDelegate: class {
    func updatePainting(paintingView: PaintingView, newImage: UIImage)
}

class PaintingView: UIView {
    // path/paths
    private var mPathsImage: UIImage?   // all paintings
    private let mPath = UIBezierPath() // one painting
    private var mPoints = [CGPoint]() // points in one stroke
    private var mUndoneStrokes: [UIImage] = [] // the set of undone images to let us do redo
    private var mDoneStrokes: [UIImage] = [] // images so that we can perform undo
    var originalWidth: CGFloat? = nil
    var originalHeight: CGFloat? = nil
    var currentWidth: CGFloat? = nil
    var currentHeight: CGFloat? = nil
    private var mStrokes: [Stroke] = [] // aall strokes in the painting for rotation redraw
    
    // path stroke properties
    private var mLineCap: CGLineCap = .butt
    private var mLineJoin: CGLineJoin = .miter
    private var mLineWidth: CGFloat = 0.5
    private var mColor: UIColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
    
    weak var paintingViewDelegate: PaintingViewDelegate? = nil
    
    override init(frame: CGRect) {
       super.init(frame: frame)
        
      
        
       mPathsImage = UIGraphicsGetImageFromCurrentImageContext()
       paintingViewDelegate?.updatePainting(paintingView: self,newImage: mPathsImage!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setStrokeProperties() {
        mPath.lineWidth = lineWidth
        mPath.lineCapStyle = lineCap
        mPath.lineJoinStyle = lineJoin
        
        mColor.setStroke()
        mPath.removeAllPoints()
    }
    
    override func didMoveToWindow() {
        // if the aspect ratio of the original screen is different than the current screen resize
        currentWidth = frame.width
        currentHeight = frame.height
        if originalWidth == nil {
            originalWidth = currentWidth
            originalHeight = currentHeight
        }
        if ceilf(Float(currentWidth!)) != ceilf(Float(originalWidth!)) || ceilf(Float(currentHeight!)) != ceilf(Float(originalHeight!)) {
               UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
             for stroke in mStrokes {
                mPath.lineWidth = stroke.width!
                mPath.lineCapStyle = stroke.cap!
                mPath.lineJoinStyle = stroke.join!
                mColor = stroke.color!
                mColor.setStroke()
                mPath.removeAllPoints()
                if !stroke.points.isEmpty {
                    var point = stroke.points.first
                    point?.x = (point?.x)!/currentWidth! * originalWidth!
                    point?.y = (point?.y)!/currentHeight! * originalHeight!
                    mPath.move(to: point!)
                    for index in 0...(stroke.points.count-1) {
                        point = stroke.points[index]
                        point?.x = (point?.x)!/currentWidth! * originalWidth!
                        point?.y = (point?.y)!/currentHeight! * originalHeight!
                        mPath.addLine(to: point!)
                    }
                  
                    mPath.stroke()
                }

            }
         
           mPathsImage = UIGraphicsGetImageFromCurrentImageContext()
           UIGraphicsEndImageContext()
            
        }
    }
    
    override func draw(_ rect: CGRect) {
       
        let context = UIGraphicsGetCurrentContext()
        context!.setAllowsAntialiasing(true)
        context!.setShouldAntialias(true)
        // draw all previous paths
        if mPathsImage != nil {
            mPathsImage!.draw(in: rect)
        }
        // draw the latest stroke
        drawPainting()
    }
    
    func drawPainting() {
        setStrokeProperties()
        
        if !mPoints.isEmpty {
            var point = mPoints.first
//            point?.x = (point?.x)!/currentWidth! * originalWidth!
//            point?.y = (point?.y)!/currentHeight! * originalHeight!
            mPath.move(to: point!)
            for index in 0...(mPoints.count-1) {
                point = mPoints[index]
//                point?.x = (point?.x)!/currentWidth! * originalWidth!
//                point?.y = (point?.y)!/currentHeight! * originalHeight!
                mPath.addLine(to: point!)
            }
            //mPath.addLine(to: mPoints.last!)
            mPath.stroke()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let position = touch.location(in: self)
        mPoints.append(position)
        setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        for coalescedTouch in event!.coalescedTouches(for: touch)! {
            mPoints.append(coalescedTouch.location(in: self))
        }
        
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // draw all paths and add stroke to all paths, clear the points array for the next stroke
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        drawHierarchy(in: bounds, afterScreenUpdates: false)
        mPathsImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        var stroke: Stroke = Stroke()
        stroke.cap = lineCap
        stroke.join = lineJoin
        stroke.width = lineWidth
        stroke.color = strokeColor
        stroke.points = mPoints
        mStrokes.append(stroke)
        
        mPoints.removeAll()
        
        // add image to done and clear undone
        mDoneStrokes.append(mPathsImage!)
        mUndoneStrokes = []

        // message the controller that a stroke was added
        paintingViewDelegate?.updatePainting(paintingView: self, newImage: mPathsImage!)
    }
    
    // get/set image of all paths
    var pathsImage: UIImage {
        get {
            return mPathsImage!
        }
        set {
            mPathsImage = newValue
            paintingViewDelegate?.updatePainting(paintingView: self, newImage: mPathsImage!)
            
            setNeedsDisplay()
        }
    }
    // get/set for stroke properties; these will be updated from the brush chooser
    var lineCap: CGLineCap {
        get{
            return mLineCap
        }
        set {
            mLineCap = newValue
            setNeedsDisplay()
        }
    }
    
    var lineJoin: CGLineJoin {
        get{
            return mLineJoin
        }
        set {
            mLineJoin = newValue
            setNeedsDisplay()
        }
    }
    
    var lineWidth: CGFloat {
        get{
            return mLineWidth
        }
        set {
            mLineWidth = newValue
            setNeedsDisplay()
        }
    }
    
    var strokeColor: UIColor {
        get {
            return mColor
        }
        set {
            mColor = newValue
            setNeedsDisplay()
        }
    }
    
    
    
    //get/set of done/undone
    var doneStrokes : [UIImage] {
        get {
            return mDoneStrokes
        }
        set {
            mDoneStrokes = newValue
            setNeedsDisplay()
        }
    }
    
    var undoneStrokes: [UIImage] {
        get {
            return mUndoneStrokes
        }
        set {
            mUndoneStrokes = newValue
            setNeedsDisplay()
        }
    }
    
    var strokes: [Stroke] {
        get {
            return mStrokes
        }
        set {
            mStrokes = newValue
            
        }
    }
}
