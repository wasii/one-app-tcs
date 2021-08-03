import Foundation
import UIKit
import NaturalLanguage
import MapKit

extension UIColor {
    class func nativeRedColor() -> UIColor {
        return UIColor.init(red: 222.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1)
    }
    
    class func approvedColor() -> UIColor {
        return UIColor.init(red: 21.0/255.0, green: 152.0/255.0, blue: 30.0/255.0, alpha: 1)
    }
    
    class func pendingColor() -> UIColor {
        return UIColor.init(red: 252.0/255.0, green: 132.0/255.0, blue: 36.0/255.0, alpha: 1)
    }
    
    class func rejectedColor() -> UIColor {
        return UIColor.init(red: 222.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1)
    }
    
    class func inprocessColor() -> UIColor {
        return UIColor.init(red: 19.0/255.0, green: 156.0/255.0, blue: 225.0/255.0, alpha: 1)
    }
    
    class func riderlistingBgColor() -> UIColor {
        return UIColor(red: 221.0/255, green: 255.0/255.0, blue: 215.0/255.0, alpha: 1)
    }
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
    class func gradientColorLayer(color1: String, color2: String) -> CAGradientLayer {
        let colorTop =  UIColor.init(hexString: color1).cgColor
        let colorBottom = UIColor.init(hexString: color2).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        
        return gradientLayer
    }
}

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

extension UIImage {
    func compressTo(_ expectedSizeInMb:Int) -> UIImage? {
        let sizeInBytes = expectedSizeInMb * 1024 * 1024
        var needCompress:Bool = true
        var imgData:Data?
        var compressingValue:CGFloat = 1.0
        while (needCompress && compressingValue > 0.0) {
            if let data:Data = self.jpegData(compressionQuality: compressingValue) {
                if data.count < sizeInBytes {
                    needCompress = false
                    imgData = data
                } else {
                    compressingValue -= 0.1
                }
            }
        }
        
        if let data = imgData {
            if (data.count < sizeInBytes) {
                return UIImage(data: data)
            }
        }
        return nil
    }
    
    func compressTo1(_ expectedSizeInMb:Int, _ handler: @escaping(_ image: UIImage) -> Void) {
        let sizeInBytes = expectedSizeInMb * 1024 * 1024
        var needCompress:Bool = true
        var imgData:Data?
        var compressingValue:CGFloat = 1.0
        while (needCompress && compressingValue > 0.0) {
            if let data:Data = self.jpegData(compressionQuality: compressingValue) {
                if data.count < sizeInBytes {
                    needCompress = false
                    imgData = data
                } else {
                    compressingValue -= 0.1
                }
            }
        }
        
        if let data = imgData {
            if (data.count < sizeInBytes) {
                handler(UIImage(data: data)!)
//                return UIImage(data: data)
            }
        }
    }
}
extension FileManager {
    func clearTmpDirectory() {
        do {
            let tmpDirURL = FileManager.default.temporaryDirectory
            let tmpDirectory = try contentsOfDirectory(atPath: tmpDirURL.path)
            try tmpDirectory.forEach { file in
                let fileUrl = tmpDirURL.appendingPathComponent(file)
                try removeItem(atPath: fileUrl.path)
            }
        } catch let err {
            print("Removing Temp Files: \(err.localizedDescription)")
        }
    }
}

extension UIImageView {
    func roundedImage() {
        self.layer.cornerRadius = (self.frame.width) / 2
        self.layer.masksToBounds = true
    }
    func borderedImage() {
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.darkGray.cgColor
    }
}

extension UIButton {
    func roundedButton(color: UIColor) {
        self.backgroundColor = color
        self.layer.cornerRadius = (self.frame.height) / 2
        self.layer.masksToBounds = true
    }
    
    func borderedButton(color: UIColor) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = 0.5
    }
}

extension UIView {
    func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
    func addUnderlines() {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: self.frame.size.height, width: self.frame.size.width, height: 1.0)
        if #available(iOS 13.0, *) {
            bottomLine.backgroundColor = UIColor.separator.cgColor
        } else {
            bottomLine.backgroundColor = UIColor.gray.cgColor
        }
        
        self.layer.addSublayer(bottomLine)
    }
    func roundedView() {
        self.layer.cornerRadius = (self.frame.height) / 2
        self.layer.masksToBounds = true
    }
    func borderedView() {
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 0.5
    }
    
    func showWarning(message: String?) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        view.tag = 1001
        view.backgroundColor = UIColor(white: 0.2, alpha: 0.9)
        let label = UILabel(frame: CGRect(x: 5, y: 0, width: self.frame.size.width - 10, height: self.frame.size.height))
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.text = message ?? ""
        label.numberOfLines = 0
        
        
        view.addSubview(label)
        self.addSubview(view)
    }
    func showLoader(message: String?) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        view.tag = 1000
        view.backgroundColor = UIColor(white: 0.2, alpha: 0.9)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.text = message ?? ""
        
        
        view.addSubview(label)
        self.addSubview(view)
    }
    func hideLoader() {
        self.removeFromSuperview()
    }
    
    func shadowView() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.lightGray.cgColor
        
        if #available(iOS 13, *) {
            layer.shadowColor = UIColor.separator.cgColor
        }
        
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        layer.shadowRadius = 5
    }
    
    func rotate(_ toValue: CGFloat, duration: CFTimeInterval = 0.2) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        
        animation.toValue = toValue
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        //        animation.fillMode = CAMediaTimingFillMode.forwards
        
        self.layer.add(animation, forKey: nil)
    }
    func addDragging(){
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedAction(_ :)))
        self.addGestureRecognizer(panGesture)
    }
    
    @objc private func draggedAction(_ pan:UIPanGestureRecognizer){
        
        let translation = pan.translation(in: self.superview)
        self.center = CGPoint(x: self.center.x + translation.x, y: self.center.y + translation.y)
        pan.setTranslation(CGPoint.zero, in: self.superview)
    }
}

extension UITabBar {
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        super.sizeThatFits(size)
        var sizeThatFits = super.sizeThatFits(size)
        switch UIDevice().type {
        case .iPhoneX, .iPhoneXR, .iPhoneXS, .iPhoneXSMax, .iPhone11, .iPhone11Pro, .iPhone11ProMax:  sizeThatFits.height = 90
            break
        default: sizeThatFits.height = 60
            break
        }
        
        return sizeThatFits
    }
}

extension UINavigationBar {
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        super.sizeThatFits(size)
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = 100
        return sizeThatFits
    }
    
}


extension UIViewController {
    func showAlert(withTitle title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    func hideKeyboardWhenTappedAround(completionHandler: @escaping(_ success: Bool) -> Void) {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        completionHandler(true)
    }
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func getPreviousDays(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: Date())!
    }
    
    func convertDateToTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-ddTHH:mm:ss"
        return formatter.string(from: date)
    }
    
    func convertStringToDate(date: String) -> Date {
        let formatter = DateFormatter()
        return formatter.date(from: date)!
    }
    
    
    
    
    func JSONtoJSONString(param: [[String:String]]) -> String {
        let json: Data? = try? JSONSerialization.data(withJSONObject: param, options: [])
        return String(data: json!, encoding: .utf8)!
    }
    
    func validateEmail(_ checkString: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: checkString)
    }
    
    func getAPIParameter(service_name: String, request_body: [String: Any]) -> [String:Any] {
        let params = [
            "eAI_MESSAGE": [
                "eAI_HEADER": [
                    "serviceName": service_name,
                    "client": "TCS",
                    "clientChannel": "MOB",
                    "referenceNum": "",
                    "securityInfo": [
                        "authentication": [
                            "userId": "",
                            "password": ""
                        ]
                    ]
                ],
                "eAI_BODY": [
                    "eAI_REQUEST": request_body
                ]
            ]
        ]
        return params as [String: Any]
    }
    
    func randomString() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map{ _ in letters.randomElement()! })
    }
    func randomInt() -> Int {
        let numbers = "0123456789"
        let randomIntegers = String((0..<6).map{ _ in numbers.randomElement()! })
        return Int(randomIntegers) ?? 000000
    }
    func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        
        let date = dateFormatter.string(from: Date())
        
        return date
    }
    
    func getLocalCurrentDate() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let date = dateFormatter.string(from: Date())
        
        return date
    }
    func getAttendanceMarkingTime() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        
        let date = dateFormatter.string(from: Date())
        
        return date
    }
}


extension Double {
    func convertFarenheitToCelcius() -> Double {
        return (self - 32) * (5/9)
    }
}


extension UILabel {
    func roundedLabel(color: UIColor) {
        self.backgroundColor = color
        self.layer.cornerRadius = (self.frame.height) / 2
        self.layer.masksToBounds = true
    }
    func borderedLabel() {
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.darkGray.cgColor
    }
}


extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

extension NSAttributedString {
    func rangeOf(string: String) -> Range<String.Index>? {
        return self.string.range(of: string)
    }
}

extension String {
    var timeOnly: String {
        let array = self.split(separator: "T")
        return String(array[1])
    }
    
    var dateOnly: String {
        let array = self.split(separator: "T")
        return String(array[0])
    }
    
    var timeOnlyT: String {
        let array = self.split(separator: "T")
        return String(array[1])
    }
    
    var dateSeperateWithT: String {
        let array = self.split(separator: "T")
        return String("\(array[0]) \(array[1])")
    }
    
    var dateToString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let GregorianDate = dateFormatter.date(from: self)
        
        let islamic = NSCalendar(identifier: NSCalendar.Identifier.islamicCivil)
        dateFormatter.locale = Locale.init(identifier: "en")
        let components = islamic?.components(NSCalendar.Unit(rawValue: UInt.max), from: GregorianDate!)
        
        return "\(components!.year ?? 2020) - \(components!.month ?? 01) - \(components!.day ?? 01)"
    }
    
    var stringToDate: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        return dateFormatter.date(from: self)!
    }
    
    var detectedLanguage: String {
        let length = self.utf16.count
        let languageCode = CFStringTokenizerCopyBestStringLanguage(self as CFString, CFRange(location: 0, length: length)) as String? ?? ""
        
        return languageCode
    }
    
    var getTicketStatus: String {
        return ""
    }
    
    var isSingleEmoji: Bool { count == 1 && containsEmoji }

        var containsEmoji: Bool { contains { $0.isEmoji } }

        var containsOnlyEmoji: Bool { !isEmpty && !contains { !$0.isEmoji } }

        var emojiString: String { emojis.map { String($0) }.reduce("", +) }

        var emojis: [Character] { filter { $0.isEmoji } }

        var emojiScalars: [UnicodeScalar] { filter { $0.isEmoji }.flatMap { $0.unicodeScalars } }
}

extension Date {
    func convertDateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter.string(from: date)
    }
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var startOfMonth: Date {
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: self)
        
        return  calendar.date(from: components)!
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
    }
    
    func isMonday() -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.weekday], from: self)
        return components.weekday == 2
    }
    
    
    func getLast6Month() -> Date? {
        return Calendar.current.date(byAdding: .month, value: -6, to: self)
    }
    
    func getLast3Month() -> Date? {
        return Calendar.current.date(byAdding: .month, value: -3, to: self)
    }
    
    func getYesterday() -> Date? {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)
    }
    
    func getLast7Day() -> Date? {
        return Calendar.current.date(byAdding: .day, value: -7, to: self)
    }
    func getLast30Day() -> Date? {
        return Calendar.current.date(byAdding: .day, value: -30, to: self)
    }
    
    func getPreviousMonth() -> Date? {
        return Calendar.current.date(byAdding: .month, value: -1, to: self)
    }
    
    // This Month Start
    func getThisMonthStart() -> Date? {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components)!
    }
    
    func getThisMonthEnd() -> Date? {
        let components:NSDateComponents = Calendar.current.dateComponents([.year, .month], from: self) as NSDateComponents
        components.month += 1
        components.day = 1
        components.day -= 1
        return Calendar.current.date(from: components as DateComponents)!
    }
    
    //Last Month Start
    func getCurrentMonthStart() -> Date? {
        let components:NSDateComponents = Calendar.current.dateComponents([.year, .month], from: self) as NSDateComponents
        return Calendar.current.date(from: components as DateComponents)!
    }
    
    
    //Last Month Start
    func getLastMonthStart(numberOfMonths: Int) -> Date? {
        let components:NSDateComponents = Calendar.current.dateComponents([.year, .month], from: self) as NSDateComponents
        components.month -= numberOfMonths
        return Calendar.current.date(from: components as DateComponents)!
    }
    
    //Last Month End
    func getLastMonthEnd(numberOfMonths: Int) -> Date? {
        let components:NSDateComponents = Calendar.current.dateComponents([.year, .month], from: self) as NSDateComponents
        components.month = 1
        components.day = -numberOfMonths
        return Calendar.current.date(from: components as DateComponents)!
    }
    
    func monthAsString() -> String {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("MMM")
        return df.string(from: self)
    }
    func monthAsStringAndDay() -> String {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("MMM'-'dd")
        return df.string(from: self)
    }
}
extension Notification.Name {
    static let counterIncrease = Notification.Name.init("CounterIncrease")
    
    static let revertBack = Notification.Name.init("RevertBack")
    
    static let updateHRRequests = Notification.Name.init("UpdateHRRequests")
    
    static let logoutUser = Notification.Name.init("LogOutUser")
    
    static let navigateThroughNotification = Notification.Name.init("NavigateThroughNotification")
    
    static let networkRefreshed = Notification.Name.init("NetworkRefreshed")
    static let networkOff = Notification.Name.init("NetworkOff")
    static let refreshedViews = Notification.Name.init("RefreshedViews")
}


public extension NSLayoutConstraint {
    
    func changeMultiplier(multiplier: CGFloat) -> NSLayoutConstraint {
        let newConstraint = NSLayoutConstraint(
            item: firstItem,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        newConstraint.priority = priority
        
        NSLayoutConstraint.deactivate([self])
        NSLayoutConstraint.activate([newConstraint])
        
        return newConstraint
    }
    
}

extension UITextField {
    func addUnderline() {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: self.frame.size.height, width: self.frame.size.width, height: 1.0)
        if #available(iOS 13.0, *) {
            bottomLine.backgroundColor = UIColor.separator.cgColor
        } else {
            bottomLine.backgroundColor = UIColor.gray.cgColor
        }
        self.borderStyle = UITextField.BorderStyle.none
        self.layer.addSublayer(bottomLine)
    }
    
    func changeBorderColor() {
        
    }
    
    func addPurpleUnderline() {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: self.frame.size.height, width: self.frame.size.width, height: 2.0)
        
        bottomLine.backgroundColor = UIColor.nativeRedColor().cgColor
        self.borderStyle = UITextField.BorderStyle.none
        self.layer.addSublayer(bottomLine)
    }
}

public extension UIDevice {
    static var isHapticsSupported : Bool {
        let feedback = UIImpactFeedbackGenerator(style: .heavy)
        feedback.prepare()
        return feedback.description.hasSuffix("Heavy>")
    }
    static func vibrate() {
        //        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    var type: Model {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
        
        let modelMap : [String: Model] = [
            
            //Simulator
            "i386"      : .simulator,
            "x86_64"    : .simulator,
            
            //iPhone
            "iPhone3,1" : .iPhone4,
            "iPhone3,2" : .iPhone4,
            "iPhone3,3" : .iPhone4,
            "iPhone4,1" : .iPhone4S,
            "iPhone5,1" : .iPhone5,
            "iPhone5,2" : .iPhone5,
            "iPhone5,3" : .iPhone5C,
            "iPhone5,4" : .iPhone5C,
            "iPhone6,1" : .iPhone5S,
            "iPhone6,2" : .iPhone5S,
            "iPhone7,1" : .iPhone6Plus,
            "iPhone7,2" : .iPhone6,
            "iPhone8,1" : .iPhone6S,
            "iPhone8,2" : .iPhone6SPlus,
            "iPhone8,4" : .iPhoneSE,
            "iPhone9,1" : .iPhone7,
            "iPhone9,3" : .iPhone7,
            "iPhone9,2" : .iPhone7Plus,
            "iPhone9,4" : .iPhone7Plus,
            "iPhone10,1" : .iPhone8,
            "iPhone10,4" : .iPhone8,
            "iPhone10,2" : .iPhone8Plus,
            "iPhone10,5" : .iPhone8Plus,
            "iPhone10,3" : .iPhoneX,
            "iPhone10,6" : .iPhoneX,
            "iPhone11,2" : .iPhoneXS,
            "iPhone11,4" : .iPhoneXSMax,
            "iPhone11,6" : .iPhoneXSMax,
            "iPhone11,8" : .iPhoneXR,
            "iPhone12,1" : .iPhone11,
            "iPhone12,3" : .iPhone11Pro,
            "iPhone12,5" : .iPhone11ProMax,
            "iPhone12,8" : .iPhoneSE2,
            "iPhone13,1" : .iPhone12Mini,
            "iPhone13,2" : .iPhone12,
            "iPhone13,3" : .iPhone12Pro,
            "iPhone13,4" : .iPhone12ProMax
        ]
        
        if let model = modelMap[String.init(validatingUTF8: modelCode!)!] {
            if model == .simulator {
                if let simModelCode = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
                    if let simModel = modelMap[String.init(validatingUTF8: simModelCode)!] {
                        return simModel
                    }
                }
            }
            return model
        }
        return Model.unrecognized
    }
}
extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}


extension NSAttributedString.Key {
    static let attributeTag = NSAttributedString.Key(rawValue: "MyCustomAttribute")
}



extension URL {
    var attributes: [FileAttributeKey : Any]? {
        do {
            return try FileManager.default.attributesOfItem(atPath: path)
        } catch let error as NSError {
            print("FileAttribute error: \(error)")
        }
        return nil
    }
    
    var fileSize: UInt64 {
        return attributes?[.size] as? UInt64 ?? UInt64(0)
    }
    
    var fileSizeString: String {
        return ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
    }
    
    var creationDate: Date? {
        return attributes?[.creationDate] as? Date
    }
}


extension CAShapeLayer {
    func drawCircleAtLocation(location: CGPoint, withRadius radius: CGFloat, andColor color: UIColor, filled: Bool) {
        fillColor = filled ? color.cgColor : UIColor.white.cgColor
        strokeColor = color.cgColor
        let origin = CGPoint(x: location.x + 30, y: location.y - radius)
        path = UIBezierPath(ovalIn: CGRect(origin: origin, size: CGSize(width: radius * 2, height: radius * 2))).cgPath
    }
}


private var handle: UInt8 = 0;
extension UIBarButtonItem {
    
    private var badgeLayer: CAShapeLayer? {
        if let b = objc_getAssociatedObject(self, &handle)  {
            return b as? CAShapeLayer
        } else {
            return nil
        }
    }
    
    func addBadge(num number: Int, withOffset offset: CGPoint = CGPoint.zero, andColor color: UIColor = UIColor.nativeRedColor(), andFilled filled: Bool = true) {
        guard let view = self.value(forKey: "view") as? UIView else { return }
        
        badgeLayer?.removeFromSuperlayer()
        
        // Initialize Badge
        let badge = CAShapeLayer()
        let radius = CGFloat(10)
        let location = CGPoint(x: view.frame.width - (radius + offset.x), y: (radius + offset.y))
        badge.drawCircleAtLocation(location: location, withRadius: radius, andColor: color, filled: filled)
        view.layer.addSublayer(badge)
        
        
        // Initialiaze Badge's label
        let label = CATextLayer()
        label.string = "\(number)"
        label.alignmentMode = CATextLayerAlignmentMode.center
        label.fontSize = 11
        label.frame = CGRect(origin: CGPoint(x: location.x + 31, y: offset.y + 2), size: CGSize(width: 19, height: 11))
        label.foregroundColor = filled ? UIColor.white.cgColor : color.cgColor
        label.backgroundColor = UIColor.clear.cgColor
        label.contentsScale = UIScreen.main.scale
        badge.addSublayer(label)
        
        // Save Badge as UIBarButtonItem property
        objc_setAssociatedObject(self, &handle, badge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func updateBadge(num number: Int) {
        if let text = badgeLayer?.sublayers?.filter({ $0 is CATextLayer }).first as? CATextLayer {
            text.string = "\(number)"
        }
    }
    
    func removeBadge() {
        badgeLayer?.removeFromSuperlayer()
    }
}


extension Character {
    var isSimpleEmoji: Bool {
        guard let firstScalar = unicodeScalars.first else { return false }
        return firstScalar.properties.isEmoji && firstScalar.value > 0x238C
    }

    var isCombinedIntoEmoji: Bool { unicodeScalars.count > 1 && unicodeScalars.first?.properties.isEmoji ?? false }

    var isEmoji: Bool { isSimpleEmoji || isCombinedIntoEmoji }
}

extension MKMapView {
  func zoomToLocation(_ location: CLLocation?) {
    guard let coordinate = location?.coordinate else { return }
    let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10_000, longitudinalMeters: 10_000)
    setRegion(region, animated: true)
  }
}


extension tbl_HR_Notification_Request: Equatable {
  static func ==(lhs: tbl_HR_Notification_Request, rhs: tbl_HR_Notification_Request) -> Bool {
    return lhs.TICKET_ID == rhs.TICKET_ID && lhs.TICKET_ID == rhs.TICKET_ID
  }
}
extension Array where Element: Equatable {
  func uniqueElements() -> [Element] {
    var out = [Element]()

    for element in self {
      if !out.contains(element) {
        out.append(element)
      }
    }

    return out
  }
}
