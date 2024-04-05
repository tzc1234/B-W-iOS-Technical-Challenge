import Foundation

struct Product: Equatable, Identifiable {
    typealias Identifier = String
    
    let id: Identifier
    let name: String?
    let description: String?
    let price: String?
    let imagePath: URL? // Change from String? to URL?, no need an extra conversion.
}

struct Products: Equatable {
    let products: [Product]
}
