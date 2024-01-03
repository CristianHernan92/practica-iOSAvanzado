import UIKit

protocol LoginViewControllerDelegate:AnyObject {
    func navitateToHeroList()
}

final class LoginViewController:UIViewController{

    var viewModel:LoginViewModelProtocol? = nil
    
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBAction private func loginButtonTouchUpInside(_ sender: UIButton) {
        guard let email=self.emailTextField.text,!email.isEmpty,let password=self.passwordTextField.text,!password.isEmpty else {
            return
        }
        viewModel?.onLoginButtonClicked(email: email, password: password)
    }
    
    override func viewDidLoad() {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}

extension LoginViewController: LoginViewControllerDelegate{
    func navitateToHeroList(){
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
