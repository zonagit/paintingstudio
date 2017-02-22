//
//  Stroke.swift
//  PaintingStudio
//
//  Created by zef on 2/17/17.
//  Copyright © 2017 zef. All rights reserved.
//

import UIKit

struct Stroke {
    var color: UIColor?
    var points: [CGPoint] = []
    var cap: CGLineCap?
    var join: CGLineJoin?
    var width: CGFloat?
}
