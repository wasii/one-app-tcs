import UIKit
@IBDesignable class CustomView: UIView {
    
    @IBInspectable var bgColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            backgroundColor = uiColor
        }
        get {
            guard let color = backgroundColor else { return nil }
            return color
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
    @IBInspectable var shadowColor : UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.shadowColor = uiColor.cgColor
        }
        get {
            guard let color = layer.shadowColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
    @IBInspectable var shadowOffSet : CGSize {
        set {
            layer.shadowOffset = CGSize(width: newValue.width, height: newValue.height)
        }
        get {
            return layer.shadowOffset
        }
    }
    @IBInspectable var shadowRadius : CGFloat {
        set {
            layer.shadowRadius = newValue
        }
        get {
            return layer.shadowRadius
        }
    }
    @IBInspectable var shadowOpacity : Float {
        set {
            layer.shadowOpacity = newValue
        }
        get {
            return layer.shadowOpacity
        }
    }
}


@IBDesignable class CustomTextView: UITextView {
    
    @IBInspectable var bgColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            backgroundColor = uiColor
        }
        get {
            guard let color = backgroundColor else { return nil }
            return color
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
    @IBInspectable var shadowColor : UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.shadowColor = uiColor.cgColor
        }
        get {
            guard let color = layer.shadowColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
    @IBInspectable var shadowOffSet : CGSize {
        set {
            layer.shadowOffset = CGSize(width: newValue.width, height: newValue.height)
        }
        get {
            return layer.shadowOffset
        }
    }
    @IBInspectable var shadowRadius : CGFloat {
        set {
            layer.shadowRadius = newValue
        }
        get {
            return layer.shadowRadius
        }
    }
    @IBInspectable var shadowOpacity : Float {
        set {
            layer.shadowOpacity = newValue
        }
        get {
            return layer.shadowOpacity
        }
    }
}


@IBDesignable class CustomButton: UIButton {
    @IBInspectable var buttonImage: UIImage? = nil {
        didSet {
            setImage()
        }
    }
    
    func setImage () {
        if let leftImg = buttonImage {
            let tintedImage = leftImg.withRenderingMode(.alwaysTemplate)
            self.setImage(tintedImage, for: .normal)
            self.tintColor = .white
        }
    }
    
    @IBInspectable var bgColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            backgroundColor = uiColor
        }
        get {
            guard let color = backgroundColor else { return nil }
            return color
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue//(frame.height) / 2
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
    @IBInspectable var shadowColor : UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.shadowColor = uiColor.cgColor
        }
        get {
            guard let color = layer.shadowColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
    @IBInspectable var shadowOffSet : CGSize {
        set {
            layer.shadowOffset = CGSize(width: newValue.width, height: newValue.height)
        }
        get {
            return layer.shadowOffset
        }
    }
    @IBInspectable var shadowRadius : CGFloat {
        set {
            layer.shadowRadius = newValue
        }
        get {
            return layer.shadowRadius
        }
    }
    @IBInspectable var shadowOpacity : Float {
        set {
            layer.shadowOpacity = newValue
        }
        get {
            return layer.shadowOpacity
        }
    }
}

