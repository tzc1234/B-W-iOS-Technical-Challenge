import Foundation

// The name, ProductQuery, is quite technical. An Entity should represent business logic/rules.
// I prefer a more "business" naming which business people will understand.
// I guess "query" is the filtering of products.
// Maybe rename it to "Refinement", because the Bloom & Wild app is using "refine".
struct ProductQuery: Equatable {
    let query: String
}
