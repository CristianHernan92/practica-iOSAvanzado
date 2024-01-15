import Foundation
import UIKit.UIView

protocol HeroDetailViewControllerProtocol:AnyObject{
    func fillData(heroDetail: String, heroTitle: String, heroImage: UIImage)
}

final class HeroDetailViewController:UIViewController{
    var viewModel: HeroDetailViewModelProtocol? = nil
    
    @IBOutlet weak var heroDetail: UITextView!
    @IBOutlet weak var heroTitle: UILabel!
    @IBOutlet weak var heroImage: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel?.viewReady()
    }
}

extension HeroDetailViewController:HeroDetailViewControllerProtocol{
    func fillData(heroDetail: String, heroTitle: String, heroImage: UIImage) {
        self.heroDetail.text = heroDetail
        self.heroTitle.text = heroTitle
        self.heroImage.image = heroImage
    }
}
