//
//  EarthView.swift
//  Earth
//
//  Created by Anastasia Myropolska on 20.06.20.
//  Copyright © 2020 Home. All rights reserved.
//

import UIKit

typealias Coordinate = (lo: CGFloat, la: CGFloat)

class EarthView: UIView {
    
    private lazy var coordinates: [[Coordinate?]] = { // 1. should these be int? do we draw between pixels?
        
        // to each point on the view find this point's (lo;la) coordinate if the point is inside the circle.
        // for the points inside a circle we will find a corresponding color on the map image. Points outside the circle will be just black.
        func coordinateFromPoint(x: Int, y: Int) -> Coordinate? {
            let R = D / 2
            let x_3d = x - R
            let z_3d = -(y - R)
            let distanceToPoint = R * R - (x_3d * x_3d + z_3d * z_3d)
            if distanceToPoint < 0 { // point is not in the circle
                return nil
            } else {
                let y_3d = sqrt(CGFloat(distanceToPoint))
                let la = acos(CGFloat(z_3d) / CGFloat(R))
                let lo = atan2(CGFloat(x_3d), CGFloat(y_3d))
                return (lo, la)
            }
        }
        
        var result = [[Coordinate?]](repeating: [Coordinate?](repeating: (0, 0), count: D ), count: D)
        for x in 0...D-1 { // ??? D*screen scale?
            for y in 0...D-1 {
                let coordinate = coordinateFromPoint(x: x, y: y)
                result[x][y] = coordinate
            }
        }
        return result
    }()
    
    private lazy var D: Int = {
        return Int(self.bounds.size.width)
    }()
    
    private let sphere = Sphere()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    private lazy var bitmapContext: CGContext? = {
        let context = sphere.sphereProvider.createEmptyBitmapContext(width: D, height: D)
        return context
    }()
    
    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            //context.clear(rect)
            
            let imageRect = CGRect(x: 0, y: 0, width: D, height: D)
            if let bitmapContext = bitmapContext, let data = bitmapContext.data {
                let opaquePtr = OpaquePointer(data) // how to convert rawPointer to pointer?
                let pixels = UnsafeMutablePointer<UInt8>(opaquePtr)
                var offset: Int = 0
                // we need inverted Y for drawing, because CGImage's coorinates are upside down
                for y in (0...D-1).reversed() {
                    for x in 0...D-1 {
                        if let coordinate = coordinates[x][y] {
                            let tmpColor = self.sphere.colorOfPoint(withLongitude: coordinate.lo, latitude: coordinate.la)
                            (pixels+offset).pointee = 1
                            (pixels+offset+1).pointee = tmpColor.r
                            (pixels+offset+2).pointee = tmpColor.g
                            (pixels+offset+3).pointee = tmpColor.b
                        } else {
                            (pixels+offset).pointee = 1
                            (pixels+offset+1).pointee = 0
                            (pixels+offset+2).pointee = 255
                            (pixels+offset+3).pointee = 0
                        }
                        offset += 4
                    }
                }
                if let newImage = bitmapContext.makeImage() {
                    context.draw(newImage, in: imageRect)
                }
            }
        }

    }
}

