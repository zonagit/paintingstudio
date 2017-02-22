//
//  PaintingCollection.swift
//  PaintingStudio
//
//  Created by zef on 2/17/17.
//  Copyright © 2017 zef. All rights reserved.
//

import UIKit

protocol PaintingCollectionDelegate: class{
    func collection(index: Int)
}

class PaintingCollection {
    
    private var mPaintingListViewController: PaintingListViewController?
    private var mPaintings: [Painting] = []
   
    
    weak var paintingCollectionDelegate: PaintingCollectionDelegate? = nil
    
    var count: Int {
        return mPaintings.count
    }
    
    func getPainting(index: Int) -> Painting {
        return mPaintings[index]
    }
    
    func getPaintingImage(index: Int) -> UIImage {
        return mPaintings[index].image
    }
    
    func setPaintingImage(index: Int, image: UIImage) {
        mPaintings[index].image = image
        paintingCollectionDelegate?.collection(index: index)
    }
    
    func setPaintingStrokes(index: Int, strokes: [Stroke]) {
        mPaintings[index].strokes = strokes
    }
    
    func addPainting(painting: Painting) {
        mPaintings.append(painting)
    }
    
    func deletePainting(index: Int) {
        mPaintings.remove(at: index)
       // paintingCollectionDelegate?.collection(index: index)
    }
}
