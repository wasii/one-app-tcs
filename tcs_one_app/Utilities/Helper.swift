import UIKit
import Foundation

class Helper: NSObject {
    class func convertImageIntoBase64(_ image: UIImage) -> String {
        guard let imageDataa = image.jpegData(compressionQuality: 0.3) else {
            return ""
        }
        return imageDataa.base64EncodedString()
    }
    
    class func convertBase64ToImage(_ base64: String) -> UIImage {
        let dataDecoded:NSData = NSData(base64Encoded: base64, options: NSData.Base64DecodingOptions(rawValue: 0))!
        let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
        
        return decodedimage
        
    }
    
    
    class func topMostController() -> UIViewController {
        var topController : UIViewController?
        if #available(iOS 13.0, *) {
            topController = UIApplication.shared.windows.first {$0.isKeyWindow}?.rootViewController
        } else {
            topController = UIApplication.shared.keyWindow?.rootViewController
        }
        
        topController?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        
        if (topController?.isKind(of: UITabBarController.self))! {
            let tab = topController as! UITabBarController
            topController = tab.viewControllers![tab.selectedIndex]
        }
        
        if (topController?.isKind(of: UINavigationController.self))! {
            let navigation = topController as! UINavigationController
            topController = navigation.visibleViewController
        }
        
        while ((topController?.presentedViewController) != nil) {
            topController = topController?.presentedViewController
            if (topController?.isKind(of: UITabBarController.self))! {
                let tab = topController as! UITabBarController
                topController = tab.viewControllers![tab.selectedIndex]
            }
            
            if (topController?.isKind(of: UINavigationController.self))! {
                let navigation = topController as! UINavigationController
                topController = navigation.visibleViewController
            }
        }
        
        return topController!
    }
    
    
    class func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        
        let date = dateFormatter.string(from: Date())
        
        return date
    }
    
    class func DateIntoYearsMonthDay(date: Date) -> [Int] {
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        
        var array = [Int]()
        
        array.append(year)
        array.append(month)
        array.append(day)
        array.append(hour)
        array.append(minutes)
        array.append(second)
        
        
        
        return array
    }
    
    
    class func updateLastSyncStatus(APIName: String, date: String, skip: Int, take: Int, total_records: Int) {
        let lastSyncStatus = AppDelegate.sharedInstance.db?.readLastSyncStatus(tableName: db_last_sync_status,
                                                   condition: "SYNC_KEY = '\(APIName)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'")
        
        if lastSyncStatus == nil {
            AppDelegate.sharedInstance.db?.insertLastSyncStatus(sync_key: APIName,
                                                                status: 1,
                                                                date: date,
                                                                skip: skip,
                                                                take: take,
                                                                total_records: total_records,
                                                                current_user: CURRENT_USER_LOGGED_IN_ID)
        } else {
            let columns = ["SYNC_KEY", "STATUS", "DATE", "SKIP", "TAKE", "TOTAL_RECORDS", "CURRENT_USER"]
            let values = [APIName, "\(1)", date, "\(skip)", "\(take)", "\(total_records)", CURRENT_USER_LOGGED_IN_ID]
            AppDelegate.sharedInstance.db?.updateTables(tableName: db_last_sync_status, columnName: columns, updateValue: values, onCondition: "SYNC_KEY = '\(APIName)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)'") { _ in }
        }
    }
}
