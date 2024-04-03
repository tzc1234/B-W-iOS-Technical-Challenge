import Foundation

struct Product: Equatable, Identifiable {
    typealias Identifier = String
    let id: Identifier
    let name: String?
    let description: String?
    let price: String?
    let imagePath: String?
}

struct Products: Equatable {
    let products: [Product]
}
