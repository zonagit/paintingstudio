//
//  PaintingListViewController.swift
//  PaintingStudio
//
//  Created by zef on 2/13/17.
//  Copyright © 2017 zef. All rights reserved.
//

import UIKit

class PaintingListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PaintingViewControllerDelegate, PaintingCollectionDelegate {
    
    private var mPaintingCollection: PaintingCollection?
    private var mPaintingCollectionViewLayout:UICollectionViewFlowLayout?
    
    var paintingCollectionView: UICollectionView {
        return view as! UICollectionView
    }
    
    override func loadView() {
        super.loadView()
        
        mPaintingCollectionViewLayout = UICollectionViewFlowLayout()

        view = UICollectionView(frame: CGRect.zero, collectionViewLayout: mPaintingCollectionViewLayout!)
    }
    
    override func viewDidLoad() {
        
        mPaintingCollection = PaintingCollection()
        mPaintingCollection?.paintingCollectionDelegate = self
        
        let addPaintingButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(PaintingListViewController.addPainting))
        navigationItem.rightBarButtonItem = addPaintingButton
        self.navigationController?.navigationBar.barStyle = UIBarStyle.blackTranslucent
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 1, green: 90/255, blue: 122/255, alpha: 1)]
        
        paintingCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(UICollectionViewCell.self))
        paintingCollectionView.backgroundColor = UIColor.lightGray
        paintingCollectionView.dataSource = self
        paintingCollectionView.delegate = self
        
        paintingCollectionView.reloadData()
    }
    
//    override func viewWillLayoutSubviews() {
//        paintingCollectionView.collectionViewLayout.invalidateLayout()
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("number of paintings \(mPaintingCollection?.count)")
    }
    
    func addPainting(sender: UIButton) {
        // add the painting to the list collection
        mPaintingCollection!.addPainting(painting: Painting())
        
        // and load its image in his own view for drawing
        let paintingViewController: PaintingViewController = PaintingViewController()
        paintingViewController.title = "Paint"
        let lastPaintingIndex: Int = (mPaintingCollection?.count)!-1
        paintingViewController.paintingIndex = lastPaintingIndex
        paintingViewController.paintingImage = mPaintingCollection!.getPaintingImage(index: lastPaintingIndex)
        paintingViewController.paintingViewControllerDelegate = self
        navigationController?.pushViewController(paintingViewController, animated: true)
        paintingCollectionView.reloadData()
    }
    
   
    
    // MARK: - List management methods
    // how many items/cells in the list
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mPaintingCollection!.count
    }
    
    // place painting at indexPath in cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let painting: Painting = mPaintingCollection!.getPainting(index: indexPath.item)
        let cell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(UICollectionViewCell.self), for: indexPath as IndexPath)
        let cellView: UIImageView = UIImageView(image: painting.image)
     //   cell.frame = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width:100, height:200)
        
        cellView.frame = cell.bounds
        
        cell.contentView.addSubview(cellView)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let painting: Painting = mPaintingCollection!.getPainting(index: indexPath.item)
        if painting.width != nil {
            paintingCollectionView.collectionViewLayout.invalidateLayout()
            return CGSize(width:CGFloat(100*painting.width!/painting.height!), height: CGFloat(100))
            
        }
        
        let frameSize: CGSize? = paintingCollectionView.frame.size// case of first update on a new image
        let ratio: Float = Float((frameSize?.width)!)/Float((frameSize?.height)!)
        paintingCollectionView.collectionViewLayout.invalidateLayout()
        return CGSize(width:CGFloat(100*ratio), height: CGFloat(100))
        
       
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
       
    // called when a cell is selected. This is similar to addPainting above
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let paintingViewController: PaintingViewController = PaintingViewController()
        paintingViewController.title = "Paint"
        paintingViewController.paintingIndex = indexPath.item
        paintingViewController.paintingImage = mPaintingCollection!.getPaintingImage(index: indexPath.item)
        let painting = mPaintingCollection!.getPainting(index: indexPath.item)
        if painting.lineCap != nil {
            paintingViewController.paintingView.lineCap = (painting.lineCap)!
            paintingViewController.paintingView.lineJoin = (painting.lineJoin)!
            paintingViewController.paintingView.lineWidth = (painting.lineWidth)!
            paintingViewController.paintingView.strokeColor = (painting.strokeColor)!
            paintingViewController.paintingView.doneStrokes = (painting.doneStrokes)!
            paintingViewController.paintingView.undoneStrokes = (painting.undoneStrokes)!
            paintingViewController.paintingView.originalWidth = (painting.width)!
            paintingViewController.paintingView.originalHeight = (painting.height)!
            paintingViewController.paintingView.strokes = (painting.strokes)
        }
        paintingViewController.paintingViewControllerDelegate = self
        navigationController?.pushViewController(paintingViewController, animated: true)
    }
    
    
    
    // layout for each cell in the list view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 25, bottom: 20, right: 25)
    }
    
    func updatePreviewPainting(paintingView: PaintingView, index: Int, newImage: UIImage) {
        mPaintingCollection?.setPaintingImage(index: index, image: newImage)
        mPaintingCollection?.getPainting(index: index).lineCap = paintingView.lineCap
        mPaintingCollection?.getPainting(index: index).lineJoin = paintingView.lineJoin
        mPaintingCollection?.getPainting(index: index).lineWidth = paintingView.lineWidth
        mPaintingCollection?.getPainting(index: index).strokeColor = paintingView.strokeColor
        mPaintingCollection?.getPainting(index: index).doneStrokes = paintingView.doneStrokes
        mPaintingCollection?.getPainting(index: index).undoneStrokes = paintingView.undoneStrokes
        mPaintingCollection?.getPainting(index: index).strokes = paintingView.strokes
        if mPaintingCollection?.getPainting(index: index).width == nil {// only set the aspect ratio on the first update
            mPaintingCollection?.getPainting(index: index).width = (paintingView.window?.frame.width)!
            mPaintingCollection?.getPainting(index: index).height = (paintingView.window?.frame.height)!
        }
        paintingCollectionView.reloadData()
    }
    
    func deletePainting(index: Int) {
        // delete from the collection
        mPaintingCollection?.deletePainting(index: index)
//               if ((mPaintingCollection?.count)!>0) {
//            let indexPath: NSIndexPath = NSIndexPath(row: index, section: 0)
//            paintingCollectionView.performBatchUpdates({
//            
//            self.paintingCollectionView.deleteItems(at: NSArray(object: indexPath) as [AnyObject] as [AnyObject] as! [IndexPath])
//            
//            }, completion: {
//            (finished: Bool) in
//            
//            self.paintingCollectionView.reloadItems(at: self.paintingCollectionView.indexPathsForVisibleItems)
//            
//            })
//        }
       
       paintingCollectionView.reloadData()
    }
    
    func collection(index: Int) {
        paintingCollectionView.reloadData()
    }
}
