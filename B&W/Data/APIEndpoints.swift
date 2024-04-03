import Foundation

struct APIEndpoints {

    static func getProducts() -> Endpoint<ProductResponseDTO> {
        return Endpoint(path: "db",
                        method: .get)
    }
}
