import UIKit

protocol LoginViewControllerDelegate:AnyObject {
    func hideNavigationBar()
    func navitateToHeroList()
}

final class LoginViewController:UIViewController{

    var viewModel:LoginViewModelProtocol? = nil
    
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var emailTextField: UITextField!
    
    @IBAction private func loginButtonTouchUpInside(_ sender: UIButton) {
        viewModel?.onLoginButtonClicked(email: emailTextField.text, password: passwordTextField.text)
    }
    
    override func viewDidLoad() {
        viewModel?.onViewDidLoad()
    }
}

extension LoginViewController: LoginViewControllerDelegate{
    func hideNavigationBar(){
        DispatchQueue.main.async {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    func navitateToHeroList(){
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
