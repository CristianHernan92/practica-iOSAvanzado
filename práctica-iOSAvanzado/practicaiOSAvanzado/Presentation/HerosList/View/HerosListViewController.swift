import UIKit
import MapKit

protocol HerosListViewControllerDelegate:AnyObject{
    func navigateToLogin()
    func updateTable()
}

final class HerosListViewController:UIViewController,UITableViewDelegate,UITableViewDataSource{
    @IBOutlet weak var mapKit: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    var delegate:HerosListViewModelProtocol? = nil
    
    override func viewDidLoad() {
        navigationController?.navigationBar.backItem?.backBarButtonItem?.isEnabled = false
        initTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        delegate?.on(.ready)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "HerosListToLoginSegue",
              let loginViewController=segue.destination as? LoginViewController
        else {return}
        let loginViewModel = delegate?.getLoginViewModel
        loginViewModel?.viewController = loginViewController
        loginViewController.viewModel = loginViewModel
    }
    
    func initTable(){
        tableView.register(UINib(nibName: "HerosListCell", bundle: nil), forCellReuseIdentifier: "HerosListCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func heightCell() -> CGFloat{
        142
    }
    
    private func cell(_ indexPath: IndexPath) -> UITableViewCell{
        guard let herosListTableViewCell = tableView.dequeueReusableCell(withIdentifier: "HerosListCell") as? HerosListCell else{
            return HerosListCell()
        }
        let heroData = delegate?.getHero(index: indexPath.row)
        if let heroImageUrl = heroData?.photo{
            let task = URLSession.shared.dataTask(with: URLRequest(url: heroImageUrl)) { (data, response, error) in
                guard error == nil else {
                    print("Error: \(String(describing: error))")
                    return
                }
                guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                    print("Response Error: \(String(describing: response))")
                    return
                }
                guard let data else {
                    print("No data error: \(String(describing: "El dato no es correcto"))")
                    return
                }
                herosListTableViewCell.updateView(
                    heroImage: UIImage(data: data) ?? UIImage(),
                    heroTitle: heroData?.name ?? "",
                    heroDescription: heroData?.description ?? ""
                )
            }
            task.resume()
        }
        return herosListTableViewCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate?.getHerosCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cell(indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        heightCell()
    }
}

extension HerosListViewController:HerosListViewControllerDelegate{
    func navigateToLogin() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "HerosListToLoginSegue", sender: (self))
        }
    }
    func updateTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
