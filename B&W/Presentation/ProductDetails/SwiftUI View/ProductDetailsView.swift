//
//  ProductDetailsView.swift
//  B&W
//
//  Created by Tsz-Lung on 04/04/2024.
//

import SwiftUI

struct ProductDetailsView: View {
    let price: String
    let description: String
    let image: UIImage?
    
    var body: some View {
        VStack(spacing: 8) {
            Image(uiImage: image ?? UIImage())
                .resizable()
                .scaledToFit()
                .frame(height: 200)

            Text(price)
                .font(.title) // iOS 13 not support title2.
                .padding(.horizontal, 12)
                
            Text(description)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 14))
                .padding(.horizontal, 12)
            
            Spacer()
        }
    }
}

#Preview {
    NavigationView {
        ProductDetailsView(price: "£38.00", description: "some description", image: UIImage.make(withColor: .gray))
    }
}

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
