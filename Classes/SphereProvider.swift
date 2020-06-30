//
//  SphereProvider.swift
//  Earth
//
//  Created by Anastasia Myropolska on 29.06.20.
//

import Foundation
import UIKit

// change to struct
struct SphereProvider {
    // todo: try to use this also in EarthView class
    static func createEmptyBitmapContext(width: Int, height: Int) -> CGContext? {
        
        let bytesPerPixel = 4 // 4 bytes per pixel: 8 bits to alpha, 8 bits to Red, 8 bits to Green, 8 bits to Blue
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8

        let byteCount = (bytesPerRow * height)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let pixels = UnsafeMutablePointer<UInt8>.allocate(capacity: byteCount)
        
        let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue

        let context = CGContext(data: pixels, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        
        return context
    }
    
    private static let mapImage = UIImage(named: "Miller-projection1000.jpg")?.cgImage
    
    public static func pixelsFromMapImage() -> [[ColorInfo]] {
        guard let image = Self.mapImage else { return [[ColorInfo]]() }

        let imageWidth = image.width
        let imageHeight = image.height
        
        var colorPoints = [[ColorInfo]].init(repeating: [ColorInfo].init(repeating: ColorInfo(), count: imageWidth), count: imageHeight)
        
        if let context = createEmptyBitmapContext(width: imageWidth, height: imageHeight) {

            let rect = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)

            context.draw(image, in: rect)

            // fills here
            if let data = context.data {

                /*
                 since the map is encoded as Miller cylindrical projection,
                 we need to remap the value of y, using the formula (2)
                 from http://mathworld.wolfram.com/MillerCylindricalProjection.html
                */

                let ymin = log(tan(CGFloat.pi / 20))
                let ymax = log(tan(9 * CGFloat.pi / 20))
                let yrange = ymax - ymin
                let opaquePtr = OpaquePointer(data) // WTF?
                let pixels = UnsafeMutablePointer<UInt8>(opaquePtr)
                for y in 0...imageHeight - 1 {
                    for x in 0...imageWidth - 1 {
                        let phi = CGFloat(y) / CGFloat(imageHeight) * CGFloat.pi - CGFloat.pi / 2 // [-PI/2; PI/2)
                        let y1 = (log(tan(CGFloat.pi / 4 + 2 * phi / 5)) - ymin) / yrange * CGFloat(imageHeight) // [0..dimY)
                        let offset = 4 * (imageWidth * Int(y1) + x)
                        // int alpha = data[offset]; // commented to avoid warning
                        let red = (pixels+offset+1).pointee
                        let green = (pixels+offset+2).pointee
                        let blue = (pixels+offset+3).pointee

                        var newColor = ColorInfo() // read about defalut struct initializers
                        newColor.r = red
                        newColor.g = green
                        newColor.b = blue

                        colorPoints[y][x] = newColor
                    }
                }
            }
            //CGContextRelease(context)
        }
        return colorPoints
    }

}
