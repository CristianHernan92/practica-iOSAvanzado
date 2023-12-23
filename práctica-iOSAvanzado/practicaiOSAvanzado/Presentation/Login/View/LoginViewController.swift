import UIKit

protocol LoginViewControllerProtocol:AnyObject {
    func navitateToHeroListViewController()
}

final class LoginViewController:UIViewController{

    var viewModel:LoginViewModelProtocol? = nil
    
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBAction private func loginButtonTouchUpInside(_ sender: UIButton) {
        guard let email=self.emailTextField.text,let password=self.passwordTextField.text else {
            return
        }
        viewModel?.onLoginButtonClicked(email: email, password: password)
    }
    
}

extension LoginViewController: LoginViewControllerProtocol{
    func navitateToHeroListViewController(){
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "LoginToHerosListSegue", sender: nil)
        }
    }
}
