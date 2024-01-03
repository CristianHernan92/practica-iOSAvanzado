import UIKit

final class HerosListCell: UITableViewCell {
    @IBOutlet private weak var heroDescription: UITextView!
    @IBOutlet private weak var heroTitle: UILabel!
    @IBOutlet private weak var heroImage: UIImageView!
    
    override func prepareForReuse() {
        heroImage.image = UIImage()
        heroTitle.text = ""
        heroDescription.text = ""
        selectionStyle = .none
    }
}

extension HerosListCell{
    func updateView(heroImage:UIImage,heroTitle:String,heroDescription:String) {
        DispatchQueue.main.async {
            self.heroImage.image = heroImage
            self.heroTitle.text = heroTitle
            self.heroDescription.text = heroDescription
        }
    }
}
