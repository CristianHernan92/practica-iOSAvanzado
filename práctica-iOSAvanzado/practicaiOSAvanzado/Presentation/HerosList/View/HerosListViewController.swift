import UIKit
import MapKit

protocol HerosListViewControllerDelegate:AnyObject{
    func showNavigationBar()
    func navigateToLogin()
    func navigateToHeroDetail(cellHeroData: CellHeroData)
}

final class HerosListViewController:UIViewController{
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel:HerosListViewModelProtocol? = nil
    
    override func viewDidLoad() {
        createAndAddLogOutIconButton()
        initView()
        addObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel?.onViewWillApear()
    }
    
    func initView(){
        tableView.register(UINib(nibName: "HerosListCell", bundle: nil), forCellReuseIdentifier: "HerosListCell")
        tableView.delegate = self
        tableView.dataSource = self
        mapView.delegate = self
    }
    
    func createAndAddLogOutIconButton(){
        if let iconImage = UIImage(systemName: "power.circle.fill") {
            let largeSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 30)
            let largeIconImage = iconImage.withConfiguration(largeSymbolConfiguration)
            let iconButton = UIButton(type: .custom)
            iconButton.setImage(largeIconImage, for: .normal)
            iconButton.tintColor = UIColor.red
            iconButton.frame = CGRect(x: 0, y: 0, width: 10, height: 40)
            iconButton.addTarget(self, action: #selector(logoutIconButtonTouchedInside), for: .touchUpInside)
            let iconBarButtonItem = UIBarButtonItem(customView: iconButton)
            navigationItem.rightBarButtonItem = iconBarButtonItem
        }
    }
    
    @objc func logoutIconButtonTouchedInside(){
        viewModel?.logoutIconButonTouched()
    }
    
    //observers
    func addObservers(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateView),
            name: Notifications.UPDATE_VIEW_HERO_LIST.name,
            object: nil)
    }
    @objc func updateView(_ notification: Notification){
        DispatchQueue.main.async {
            self.tableView.reloadData()
            if let herosAnnotations = notification.userInfo?["herosAnnotations"] as? HerosAnnotations{
                    herosAnnotations.forEach{ heroAnnotation in
                        self.mapView.addAnnotation(heroAnnotation)
                    }
            }
        }
    }
    
    func prepareForLoginSegue(segue: UIStoryboardSegue){
        guard let loginViewController=segue.destination as? LoginViewController
        else {return}
        let loginViewModel = viewModel?.getLoginViewModel
        loginViewModel?.viewController = loginViewController
        loginViewController.viewModel = loginViewModel
    }
    func prepareForHeroDetailSegue(segue: UIStoryboardSegue, cellHeroData: CellHeroData){
        guard let heroDetailViewController=segue.destination as? HeroDetailViewController
        else {return}
        let heroDetailViewModel = HeroDetailViewModel(heroTitle: cellHeroData.name, heroDetail: cellHeroData.description, heroImage: cellHeroData.image)
        heroDetailViewModel.viewController = heroDetailViewController
        heroDetailViewController.viewModel = heroDetailViewModel
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier{
        case "HerosListToLoginSegue":
            self.prepareForLoginSegue(segue: segue)
        case "HerosListToHeroDetailSegue":
            self.prepareForHeroDetailSegue(segue: segue, cellHeroData: sender as? CellHeroData ?? CellHeroData(name: "", description: "", image: UIImage()))
        default: return
        }
    }
}

//

//extension for tableview
extension HerosListViewController: UITableViewDelegate,UITableViewDataSource{
    private func heightCell() -> CGFloat{
        142
    }
    
    private func cell(_ indexPath: IndexPath) -> UITableViewCell{
        guard
            let herosListTableViewCell = tableView.dequeueReusableCell(withIdentifier: "HerosListCell") as? HerosListCell,
            let cellHeroData = viewModel?.getCellHeroData(index: indexPath.row)
        else{
            return HerosListCell()
        }
        
        herosListTableViewCell.updateView(
            heroImage: cellHeroData.image,
            heroTitle: cellHeroData.name,
            heroDescription: cellHeroData.description
        )
        
        return herosListTableViewCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.getCellHeroesDataCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell(indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        heightCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.cellDidSelect(indexPath: indexPath.row)
    }
}

//extension for mapview
extension HerosListViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        viewModel?.annotationDidSelect(annotationView: view)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let heroAnnotation = annotation as? HeroAnnotation else {
            return MKAnnotationView()
        }

        let identifier = "HeroAnnotationIdentifier"

        var annotationView: MKAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
            annotationView = dequeuedView
        } else {
            annotationView = MKAnnotationView(annotation: heroAnnotation, reuseIdentifier: identifier)
            annotationView.canShowCallout = true
        }

        let targetSize = CGSize(width: 80, height: 80)
        let resizedImage = resizeImage(heroAnnotation.image, targetSize: targetSize)
        let roundedImage = roundedImage(resizedImage)
        annotationView.image = roundedImage
        
        return annotationView
    }

    func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        let newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }

        let rect = CGRect(origin: .zero, size: newSize)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? UIImage()
    }

    func roundedImage(_ image: UIImage) -> UIImage {
        let rect = CGRect(origin: .zero, size: image.size)
        UIGraphicsBeginImageContextWithOptions(image.size, false, 1.0)
        UIBezierPath(roundedRect: rect, cornerRadius: image.size.width / 1.0).addClip()
        image.draw(in: rect)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return roundedImage ?? UIImage()
    }
}



//

extension HerosListViewController:HerosListViewControllerDelegate{
    func navigateToLogin() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "HerosListToLoginSegue", sender: (self))
        }
    }
    func navigateToHeroDetail(cellHeroData: CellHeroData) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "HerosListToHeroDetailSegue", sender: cellHeroData)
        }
    }
    func showNavigationBar (){
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.isHidden == true ? self.navigationController?.setNavigationBarHidden(false, animated: true) : nil
        }
    }
}
