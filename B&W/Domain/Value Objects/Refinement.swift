import Foundation

// The name, ProductQuery, is quite technical. It should represent business logic/rules.
// I prefer a more "business" naming which business people will understand.
// I guess "query" is the filtering of products.
// Maybe name it to "Refinement", because the Bloom & Wild app is using "Refine".

// Also this should be a value object, which has no identity (Entity have an identity).
struct Refinement: Equatable {
    let query: String
}
