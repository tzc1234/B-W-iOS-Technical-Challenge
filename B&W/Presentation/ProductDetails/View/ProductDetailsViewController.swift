import SwiftUI

final class ProductDetailsViewController: UIViewController, StoryboardInstantiable {
    private var viewModel: ProductDetailsViewModel!

    static func create(with viewModel: ProductDetailsViewModel) -> ProductDetailsViewController {
        let view = ProductDetailsViewController.instantiateViewController()
        view.viewModel = viewModel
        return view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateView(with: nil)
        bind(to: viewModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.updateImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.cancelImageLoading()
    }

    private func bind(to viewModel: ProductDetailsViewModel) {
        viewModel.image.observe(on: self) { [weak self] in
            self?.updateView(with: $0.flatMap(UIImage.init))
        }
    }
    
    private func updateView(with image: UIImage?) {
        title = viewModel.name
        let productDetailsView = ProductDetailsView(
            price: viewModel.price,
            description: viewModel.description,
            image: image
        )
        
        let hosting = UIHostingController(rootView: productDetailsView)
        addChild(hosting)
        hosting.view.frame = view.frame
        view.addSubview(hosting.view)
        hosting.didMove(toParent: self)
    }
}
