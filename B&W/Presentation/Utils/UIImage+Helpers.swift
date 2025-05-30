//
//  UIImage+Helpers.swift
//  B&W
//
//  Created by Tsz-Lung on 04/04/2024.
//

import UIKit

extension UIImage {
    static func make(withColor color: UIColor, rect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1

        return UIGraphicsImageRenderer(size: rect.size, format: format).image { rendererContext in
            color.setFill()
            rendererContext.fill(rect)
        }
    }
}
