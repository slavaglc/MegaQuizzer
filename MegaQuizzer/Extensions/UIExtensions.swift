import UIKit

extension UIViewController {
    
    func showAlert(title: String, message: String, style: UIAlertController.Style) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        let okAction = UIAlertAction(title: "Ок", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    func showActivityIndicator(target: UIViewController, style: UIActivityIndicatorView.Style = .medium, completion: (UIActivityIndicatorView)->()) {
        let activityIndicator = UIActivityIndicatorView(style: style)
        activityIndicator.center = target.view.center
        if let viewController = navigationController {
            viewController.view.addSubview(activityIndicator)
        } else {
            target.view.addSubview(activityIndicator)
        }
        completion(activityIndicator)
    }
}

extension UIView {
    
    func moveIn() {
        transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
        alpha = 0.0
        isHidden = false
        
        UIView.animate(withDuration: 0.5) {
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.alpha = 1.0
        }
    }
    
    func fadeIn() {
        let targetCenter = center
        center = CGPoint(x: 0, y: targetCenter.y)
        alpha = 0.0
        
        UIView.animate(withDuration: 0.3) {
            self.center = CGPoint(x: targetCenter.x, y: targetCenter.y)
            self.alpha = 1.0
        }
    }
    
    
}

extension UIStackView {
    
        func moveOut() {
            transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
            alpha = 1.0
            
            UIView.animate(withDuration: 0.7) {
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.alpha = 0.0
            } completion: { isFinished in
                self.isHidden = isFinished
            }
    }
    
    func moveNext() {
        transform = CGAffineTransform(scaleX: 0.0, y: 1.0)
        alpha = 0.0
        
        UIView.animate(withDuration: 0.5) {
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.alpha = 1.0
        }
    }
}
