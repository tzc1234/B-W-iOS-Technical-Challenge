# Bloom & Wild iOS Technical Challenge
Thank you for your time to go through my code. If you have any problems encountered during running this app, feel free to contact me.
***Xcode 15.3 and iPhone 15(17.4) simulator is used for completing this app.***

## Checklist

- [x] Fix the crash when tapping on a product cell.
- [x] Migrate product details page from UIKit to SwiftUI.
- [x] Improve the image loadings.
- [x] Write unit tests for my changes.
- [x] Comments for the reason of making changes.

## Retrospective
I would like to write down some of my reflections after this technical test.

### About the generic Response type and ResponseDecoder in Endpoint
I think `Endpoint` should not hold the reference of `ResponseDecoder` and also decide the `Response` generic type. It is because `Endpoint` doesn't need them itself. But if I want to move them away, I can find a good place. Putting them into `DataTransferService` is not quite right... Hoping to have a further discussion on this.

### About image caching
If the image received from API is static, I would like to do caching for it, for improving the performance. It is rather easy to implement under clean architecture. Utilise the `decorator pattern`, wrapping my `DefaultLoadImageDataUseCase` class, conform to the same protocol. Then, it can intercept the message before and after the network API call. Check any cache before making an API call, and cache after image data response. The cache itself can be an in-memory one, starting from simple.

### About the ProductsListItemViewModel and ProductListItemCell
Now the `ProductsListItemViewModel` is created by `DefaultProductsListViewModel`. And because of that, `DefaultProductsListViewModel` has to carry the dependency which `ProductsListItemViewModel` needs only. Ideally, the component should only hold dependencies it needs. The root cause is that `ProductListItemCell` is created by `ProductsListViewController`, leading to their view models also being coupled. I've thought of decoupling them, however, due to the time limit, I've given up.

### About unit tests
If I have time, I would write unit tests for ALL components (except SwiftUI view, no official way to do unit test for SwiftUI). I am very satisfied to see more and more lines of code being covered, as an advocate of automated tests.:)
