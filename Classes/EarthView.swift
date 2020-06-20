//
//  EarthView.swift
//  Earth
//
//  Created by Anastasia Myropolska on 20.06.20.
//  Copyright © 2020 Home. All rights reserved.
//

import UIKit

typealias PointOnSphere = (la: CGFloat, lo: CGFloat)

class EarthView: UIView {
    
    private let earthImage = UIImage.init(named: "Miller-projection1000.jpg")
    
    private lazy var pointsOnSphere: [[PointOnSphere?]] = { // rename to Coordinate 2. should these be int? do we draw between pixels?
        var tmp = [[PointOnSphere?]]()
        for x in 0...D { // ??? D*screen scale?
            for y in 0...D {
                let coordinate = coordinateFromPoint(x: x, y: y)
                tmp[x][y] = coordinate
            }
        }
        return tmp
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
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * D
        let bitsPerComponent = 8

        let byteCount = (bytesPerRow * D)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let pixels = UnsafeMutablePointer<UInt8>.allocate(capacity: byteCount)
        var offset: Int = 0
        for i in 0...(D-1)*(D-1) {
            (pixels+offset).pointee = 1
            (pixels+offset+1).pointee = 255
            (pixels+offset+2).pointee = 0
            (pixels+offset+3).pointee = 0
            offset += 4
        }
        
        let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue

        let context = CGContext(data: pixels, width: D, height: D, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        
        return context
    }()
    
    // to each point on the view find this point's (la;lo) coordinate if the point is inside the circle
    private func coordinateFromPoint(x: Int, y: Int) -> PointOnSphere? {
        let R = D / 2
        let x_3d = x - R
        let z_3d = -(y) - R
        let distanceToPoint = R * R - (x_3d * x_3d + z_3d * z_3d)
        if distanceToPoint < 0 {
            return nil
        } else {
            let y_3d = sqrt(CGFloat(distanceToPoint))
            let la = acos(CGFloat(z_3d) / CGFloat(R))
            let lo = atan2(CGFloat(x_3d), CGFloat(y_3d))
            return (la, lo)
        }
    }
    
    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            //context.clear(rect)

            //let newImage = imageFromBitmap()
            let imageRect = CGRect(x: 0, y: 0, width: D, height: D)
//            if let img = UIImage(named: "Miller-projection1000") {
//                img.draw(in: imageRect)
//            }
                
            if let newImage = bitmapContext?.makeImage() {
                context.draw(newImage, in: imageRect)
            }
        }

    }
}

