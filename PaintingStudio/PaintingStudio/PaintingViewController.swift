//
//  PaintingViewController.swift
//  PaintingStudio
//
//  Created by u0082100 on 2/13/17.
//  Copyright © 2017 zef. All rights reserved.
//

import UIKit

// for updating image in parent controller in this case the paintinglistviewcontroller
// we need to tell the parent which index in the list we are updating and send it the new image
// The chain of events is: Whenever the paintingview is updated (new stroke, new painting) it tells/updates
// this controller which just passes along the image by telling/updating the list controller
// In short all these delegates are just a nested way for each painting to communicate with the list
// and update the previewPainting in the list view
protocol PaintingViewControllerDelegate: class {
    func updatePreviewPainting(paintingView: PaintingView,index: Int, newImage: UIImage)
    func deletePainting(index: Int)
}

class PaintingViewController: UIViewController, ColorWheelDelegate, StrokeEndCapsDelegate, StrokeJoinDelegate, StrokeWidthDelegate, PaintingViewDelegate {
    
    private var mPaintingView = PaintingView()
    private var mPaintingImage: UIImage = UIImage() // the painting image from the list at index given by mPaintingIndex
    private var mPaintingIndex: Int? // index of this painting in the list view
    private var mBrushViewController: UIViewController?
    private var mBrushPreview: BrushPreview?
    var paintingView: PaintingView {
        return view as! PaintingView
    }
    
    weak var paintingViewControllerDelegate: PaintingViewControllerDelegate? = nil
    
    override func loadView() {
        mPaintingView.pathsImage = mPaintingImage
       
        
        view = mPaintingView
        mPaintingView.paintingViewDelegate = self
        
        // navigation bar buttons: brush chooser, delete current painting and undo and redo strokes and back button
        // (this one by default)
        let brushButton: UIBarButtonItem = UIBarButtonItem(title: "Brush", style: UIBarButtonItemStyle.plain, target: self, action: #selector(PaintingViewController.chooseBrush))
        let deleteButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.trash, target: self, action: #selector(PaintingViewController.deletePainting))
        deleteButton.tintColor = UIColor.red
        let undoStrokeButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.rewind, target: self, action: #selector(PaintingViewController.undoStroke))
        let redoStrokeButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fastForward, target: self, action: #selector(PaintingViewController.redoStroke))

        navigationItem.rightBarButtonItem = deleteButton
        navigationItem.rightBarButtonItems?.append(brushButton)
        navigationItem.rightBarButtonItems?.append(redoStrokeButton)
        navigationItem.rightBarButtonItems?.append(undoStrokeButton)
    }
    
    override func viewDidLoad() {
         super.viewDidLoad()
         paintingView.backgroundColor = UIColor.black
    }
    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        coordinator.animate(alongsideTransition: nil, completion: {
//            _ in
//            let orient = UIApplication.shared.statusBarOrientation
//            switch orient {
//            case .portrait:
//                print("Portrait")
//            // Do something
//            default:
//                print("Anything But Portrait")
//                // Do something else
//            }
//             self.chooseBrush(sender: UIButton())
//            self.mBrushViewController?.view.setNeedsDisplay()
//
//        })
//               }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.view.setNeedsDisplay()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (self.isMovingFromParentViewController) {
            //if the 
        }
    }
    
    func deletePainting(sender: UIButton) {
        paintingViewControllerDelegate?.deletePainting(index: mPaintingIndex!)
        // go back to the list view
        navigationController!.popViewController(animated: true)
    }
    
    func undoStroke(sender: UIButton) {
        if mPaintingView.doneStrokes.count >= 1 {
            let lastDone: UIImage = mPaintingView.doneStrokes.popLast()!
            mPaintingView.undoneStrokes.append(lastDone)
            if mPaintingView.doneStrokes.count == 0 {
                mPaintingView.pathsImage = UIImage()
            }
            else {
                mPaintingView.pathsImage = mPaintingView.doneStrokes.last!
            }
        }
    }
    
    func redoStroke(sender: UIButton) {
        if(mPaintingView.undoneStrokes.count > 0) {
            let lastUndone: UIImage = mPaintingView.undoneStrokes.popLast()!
            mPaintingView.doneStrokes.append(lastUndone)
            mPaintingView.pathsImage = lastUndone
        }
    }
    
    
    func chooseBrush(sender: UIButton) {
        mBrushViewController = UIViewController()
        mBrushViewController?.view.backgroundColor = UIColor.black
        
        let radius: CGFloat = min(self.view.frame.width, self.view.frame.height-self.navigationController!.navigationBar.frame.height)
        let rest: CGFloat = abs(self.view.frame.width-self.view.frame.height + self.navigationController!.navigationBar.frame.height)
        let leftX = (self.view.frame.width - radius)/2.0
        let topY = (self.view.frame.height - radius)/2.0
        
        var colorWheelView: ColorWheel = ColorWheel(frame: CGRect(x: leftX, y:self.navigationController!.navigationBar.frame.height, width: radius, height: radius), color: mPaintingView.strokeColor)
        colorWheelView.contentMode = .redraw
        if (self.view.frame.width > self.view.frame.height) {
            colorWheelView = ColorWheel(frame: CGRect(x: 0, y:topY, width: radius, height: radius), color: mPaintingView.strokeColor)
        }
        colorWheelView.delegate = self
        mBrushViewController?.view.addSubview(colorWheelView)
        
        var strokeEndCapsView: StrokeEndCaps = StrokeEndCaps(frame: CGRect(x:leftX, y: radius + self.navigationController!.navigationBar.frame.height, width: radius, height: rest/4))
        if (self.view.frame.width > self.view.frame.height) {
         
            strokeEndCapsView = StrokeEndCaps(frame: CGRect(x: radius, y: self.navigationController!.navigationBar.frame.height, width: radius, height: rest/4))
        }
        strokeEndCapsView.contentMode = .redraw
        strokeEndCapsView.delegate = self
        strokeEndCapsView.setSelected(lineCap: mPaintingView.lineCap)
        mBrushViewController?.view.addSubview(strokeEndCapsView)
        
        var strokeJoinsView: StrokeJoin = StrokeJoin(frame: CGRect(x:leftX, y: radius + self.navigationController!.navigationBar.frame.height + rest/4, width: radius, height:rest/4))
        if (self.view.frame.width > self.view.frame.height) {
            strokeJoinsView = StrokeJoin(frame: CGRect(x:radius, y: rest/4 + self.navigationController!.navigationBar.frame.height , width: radius, height: rest/4))
        }
        strokeJoinsView.contentMode = .redraw
        strokeJoinsView.delegate = self
        strokeJoinsView.setSelected(lineJoin: mPaintingView.lineJoin)
        mBrushViewController?.view.addSubview(strokeJoinsView)
        
        var strokeWidthView: StrokeWidth = StrokeWidth(frame: CGRect(x: leftX, y: radius + self.navigationController!.navigationBar.frame.height + 2*rest/4, width: radius, height: rest/4))
        if (self.view.frame.width > self.view.frame.height) {
            strokeWidthView = StrokeWidth(frame: CGRect(x:radius, y: self.navigationController!.navigationBar.frame.height + 2*rest/4, width: radius, height: rest/4))
        }
        strokeWidthView.contentMode = .redraw
        strokeWidthView.delegate = self
        strokeWidthView.value = Float(mPaintingView.lineWidth)
        mBrushViewController?.view.addSubview(strokeWidthView)
        
        mBrushPreview = BrushPreview(frame: CGRect(x: leftX, y: radius + self.navigationController!.navigationBar.frame.height + 3*rest/4, width: radius, height: rest/4))
        if (self.view.frame.width > self.view.frame.height) {
            mBrushPreview = BrushPreview(frame: CGRect(x:radius, y: self.navigationController!.navigationBar.frame.height + 3*rest/4, width: radius, height: rest/4))
        }
        mBrushPreview?.contentMode = .redraw
        mBrushPreview?.updateColor(color: mPaintingView.strokeColor)
        switch mPaintingView.lineJoin {
        case .miter:
            mBrushPreview?.updateStrokeJoin(join: .MITER_JOIN)
        case .round:
            mBrushPreview?.updateStrokeJoin(join: .ROUND_JOIN)
        case .bevel:
            mBrushPreview?.updateStrokeJoin(join: .BEVEL_JOIN)
        }
       
        switch mPaintingView.lineCap {
        case .butt:
           mBrushPreview?.updateStrokeEndCap(cap: .BUTT_CAP)
        case .round:
            mBrushPreview?.updateStrokeEndCap(cap: .ROUND_CAP)
        case .square:
            mBrushPreview?.updateStrokeEndCap(cap: .PROJECTING_SQUARE_CAP)
        }
        
        mBrushPreview?.updateStrokeWidth(width: Float(mPaintingView.lineWidth))
        mBrushViewController?.view.addSubview(mBrushPreview!)
        mBrushViewController?.view.contentMode = .redraw
        mBrushViewController?.title = "Brush Chooser"
        navigationController?.pushViewController(mBrushViewController!, animated: true)
    }
    
    func chooseColor(_ hue: CGFloat, saturation: CGFloat) {
        let color: UIColor = UIColor(hue: hue, saturation: saturation, brightness: 1.0, alpha: 1.0)
        mPaintingView.strokeColor = color
        mBrushPreview?.updateColor(color: color)
    }
    
    func chooseStrokeEndCaps(strokeEndCaps: StrokeEndCaps, newEndCap endCap: StrokeEndCaps.LINE_CAPS) {
        switch endCap {
        case .BUTT_CAP:
            mPaintingView.lineCap = CGLineCap.butt
        case .ROUND_CAP:
             mPaintingView.lineCap = CGLineCap.round
        case .PROJECTING_SQUARE_CAP:
             mPaintingView.lineCap = CGLineCap.square
        }
        mBrushPreview?.updateStrokeEndCap(cap: endCap)
    }
    
    func chooseStrokeJoin(strokeJoin: StrokeJoin, newJoin join: StrokeJoin.LINE_JOINS) {
        switch join {
        case .MITER_JOIN:
            mPaintingView.lineJoin = CGLineJoin.miter
        case .ROUND_JOIN:
            mPaintingView.lineJoin = CGLineJoin.round
        case .BEVEL_JOIN:
            mPaintingView.lineJoin = CGLineJoin.bevel
        }
        
        mBrushPreview?.updateStrokeJoin(join: join)
    }
    
    func chooseStrokeWidth(strokeWidth: StrokeWidth, newWidth width: Float) {
        mPaintingView.lineWidth = CGFloat(width)
        mBrushPreview?.updateStrokeWidth(width: width)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [UIInterfaceOrientationMask.all]
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    var paintingIndex: Int {
        get {
            return mPaintingIndex!
        }
        set {
            mPaintingIndex = newValue
        }
    }
    
    var paintingImage: UIImage {
        get {
            return mPaintingImage
        }
        set {
            mPaintingImage = newValue
        }
    }
    
    func updatePainting(paintingView: PaintingView, newImage: UIImage) {
        paintingViewControllerDelegate?.updatePreviewPainting(paintingView: paintingView, index: mPaintingIndex!, newImage: newImage)
    }
}
