//
//  NetworkCalls.swift
//  tcs_one_app
//
//  Created by ibs on 21/10/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class NetworkCalls: NSObject {
    
    class func login(params: [String:Any], handler: @escaping(_ granted: Bool,_ response: Any) -> Void) {
        let Url = String(format: ENDPOINT)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return
        }
        request.httpBody = httpBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let json = JSON(data)
                if let success = json.dictionary?[eAI_MESSAGE]?.dictionary?[eAI_BODY]?.dictionary?[eAI_REPLY]?.dictionary?[returnStatus] {
                    if success.dictionary?[_code] == "0200" {
                        handler(true, "true")
                    } else {
                        handler(false, "false")
                    }
                } else {
                    handler(false, "false")
                }
            } else {
                handler(false, SOMETHINGWENTWRONG)
            }
        }.resume()
    }
    
    class func pin_validate(params: [String:Any], handler: @escaping(_ granted: Bool,_ response: Any) -> Void) {
        let Url = String(format: ENDPOINT)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return
        }
        request.httpBody = httpBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let json = JSON(data)
                if let success = json.dictionary?[returnStatus] {
                    if success.dictionary?[_code] == "0200" {

                        DispatchQueue.main.async {
                            var module = [Module]()
                            let access_token = json.dictionary?[_access_token_id]?.string ?? ""
                            if let data = json.dictionary?[_module] {
                                do {
                                    if let array = data.array {
                                        for json in array {
                                            let dictionary = try json.rawData()
                                            module.append(try JSONDecoder().decode(Module.self, from: dictionary))
                                        }
                                        
                                        CONSTANT_MODULE_ID = module.first?.moduleid ?? 0
                                        
                                        AppDelegate.sharedInstance.db?.deleteAll(tableName: db_user_module) { success in
                                            if success {
                                                for mod in module {
                                                    AppDelegate.sharedInstance.db?.insert_tbl_UserModule(usermodule: mod)
                                                }
                                            }
                                        }
                                    }
                                    
                                } catch let err {
                                    print(err.localizedDescription)
                                }
                            }
                            var page = [Page]()
                            if let data = json.dictionary?[_page] {
                                do {
                                    if let array = data.array {
                                        for json in array {
                                            let dictionary = try json.rawData()
                                            page.append(try JSONDecoder().decode(Page.self, from: dictionary))
                                        }
                                        AppDelegate.sharedInstance.db?.deleteAll(tableName: db_user_page) { success in
                                            if success {
                                                for pge in page {
                                                    AppDelegate.sharedInstance.db?.insert_tbl_UserPage(userpage: pge)
                                                }
                                            }
                                        }
                                    }
                                    
                                } catch let err {
                                    print(err.localizedDescription)
                                }
                            }
                            var permission = [Permission]()
                            if let data = json.dictionary?[_permision] {
                                do {
                                    if let array = data.array {
                                        for json in array {
                                            let dictionary = try json.rawData()
                                            permission.append(try JSONDecoder().decode(Permission.self, from: dictionary))
                                        }
                                        AppDelegate.sharedInstance.db?.deleteAll(tableName: db_user_permission) { (success) in
                                            if success {
                                                for perm in permission {
                                                    AppDelegate.sharedInstance.db?.insert_tbl_UserPermission(userpermission: perm)
                                                }
                                            }
                                        }
                                    }
                                } catch let err {
                                    print(err.localizedDescription)
                                }
                            }
                            if let data = json.dictionary?[_emp_info] {
                                do {
                                    UserDefaults.standard.setValue(data.array?.first?["EMP_NAME"].string ?? "", forKey: "name")
                                    UserDefaults.standard.setValue(data.array?.first?["GRADE_DESC"].string ?? "", forKey: "grade")
                                    UserDefaults.standard.setValue(data.array?.first?["DESIG"].string ?? "", forKey: "designation")
                                    UserDefaults.standard.setValue(data.array?.first?["DEPT"].string ?? "", forKey: "department")
                                    UserDefaults.standard.setValue(data.array?.first?["LINE_MANAGER1"].int ?? 0, forKey: "reported_by")

                                    let dictionary = try data.array!.first?.rawData()
                                    let user = try JSONDecoder().decode(User.self, from: dictionary!)
                                    AppDelegate.sharedInstance.db?.deleteAll(tableName: db_user_profile) { success in
                                        if success {
                                            AppDelegate.sharedInstance.db?.insert_tbl_UserProfile(user: user)
                                        }
                                    }
                                } catch let DecodingError.dataCorrupted(context) {
                                    print(context)
                                } catch let DecodingError.keyNotFound(key, context) {
                                    print("Key '\(key)' not found:", context.debugDescription)
                                    print("codingPath:", context.codingPath)
                                } catch let DecodingError.valueNotFound(value, context) {
                                    print("Value '\(value)' not found:", context.debugDescription)
                                    print("codingPath:", context.codingPath)
                                } catch let DecodingError.typeMismatch(type, context)  {
                                    print("Type '\(type)' mismatch:", context.debugDescription)
                                    print("codingPath:", context.codingPath)
                                } catch {
                                    print("error: ", error)
                                }
                            }
                            UserDefaults.standard.set(access_token, forKey: USER_ACCESS_TOKEN)
                        }
                        handler(true, "true")
                    } else {
                        handler(false, "false")
                    }
                }
            } else {
                handler(false, SOMETHINGWENTWRONG)
            }
        }.resume()
    }
    
    class func setup(params: [String:Any], handler: @escaping(_ granted: Bool,_ response: Any) -> Void) {
        let Url = String(format: ENDPOINT)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return
        }
        request.httpBody = httpBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let json = JSON(data)
                if let success = json.dictionary?[returnStatus] {
                    if success.dictionary?[_code] == "0200" {
                        var remark = [Remarks]()
                        if let data = json.dictionary?[_remarks] {
                            do {
                                for json in data.array! {
                                    let dictionary = try json.rawData()
                                    remark.append(try JSONDecoder().decode(Remarks.self, from: dictionary))
                                }
                                DispatchQueue.main.async {
                                    AppDelegate.sharedInstance.db?.deleteAll(tableName: db_remarks) { success in
                                        if success {
                                            for rm in remark {
                                                AppDelegate.sharedInstance.db?.insert_tbl_Remarks(remarks: rm)
                                            }
                                        }
                                    }
                                }
                                
                            } catch let err {
                                print(err.localizedDescription)
                            }
                        }
                        
                        var querymatrix = [QueryMatrix]()
                        if let data = json.dictionary?[_query_matrix] {
                            do {
                                if let _ = data.array {
                                    for json in data.array! {
                                        let dictionary = try json.rawData()
                                        querymatrix.append(try JSONDecoder().decode(QueryMatrix.self, from: dictionary))
                                    }
                                    DispatchQueue.main.async {
                                        AppDelegate.sharedInstance.db?.deleteAll(tableName: db_query_matrix) { success in
                                            if success {
                                                for qm in querymatrix {
                                                    AppDelegate.sharedInstance.db?.insert_tbl_queryMatrix(querymatrix: qm)
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                
                            } catch let err {
                                print(err.localizedDescription)
                            }
                        }
                        var masterquery = [MasterQuery]()
                        if let data = json.dictionary?[_master_query] {
                            if let _ = data.array {
                                do {
                                    for json in data.array! {
                                        let dictionary = try json.rawData()
                                        masterquery.append(try JSONDecoder().decode(MasterQuery.self, from: dictionary))
                                    }
                                    DispatchQueue.main.async {
                                        AppDelegate.sharedInstance.db?.deleteAll(tableName: db_master_query) { success in
                                            if success {
                                                for mq in masterquery {
                                                    AppDelegate.sharedInstance.db?.insert_tbl_masterQuery(masterquery: mq)
                                                }
                                            }
                                        }
                                    }
                                    
                                } catch let err {
                                    print(err.localizedDescription)
                                }
                            }
                        }
                        var detailquery = [DetailQuery]()
                        if let data = json.dictionary?[_detail_query] {
                            if let _ = data.array {
                                do {
                                    for json in data.array! {
                                        let dictionary = try json.rawData()
                                        detailquery.append(try JSONDecoder().decode(DetailQuery.self, from: dictionary))
                                    }
                                    DispatchQueue.main.async {
                                        AppDelegate.sharedInstance.db?.deleteAll(tableName: db_detail_query) { success in
                                            if success {
                                                for dq in detailquery {
                                                    AppDelegate.sharedInstance.db?.insert_tbl_detailQuery(detailquery: dq)
                                                }
                                            }
                                        }
                                    }
                                    
                                } catch let err {
                                    print(err.localizedDescription)
                                }
                            }
                        }
                        var searchkeywords = [SearchKeyword]()
                        if let data = json.dictionary?[_search_keyword] {
                            if let _ = data.array {
                                do {
                                    for json in data.array! {
                                        let dictionary = try json.rawData()
                                        searchkeywords.append(try JSONDecoder().decode(SearchKeyword.self, from: dictionary))
                                    }
                                    DispatchQueue.main.async {
                                        AppDelegate.sharedInstance.db?.deleteAll(tableName: db_search_keywords) { success in
                                            if success {
                                                for sk in searchkeywords {
                                                    AppDelegate.sharedInstance.db?.insert_tbl_serachKeywords(searchkeywords: sk)
                                                }
                                            }
                                        }
                                    }
                                    
                                } catch let err {
                                    print(err.localizedDescription)
                                }
                            }
                        }
                        var apprequestmode = [AppRequestMode]()
                        if let data = json.dictionary?[_app_request_mode] {
                            if let _ = data.array {
                                do {
                                    for json in data.array! {
                                        let dictionary = try json.rawData()
                                        apprequestmode.append(try JSONDecoder().decode(AppRequestMode.self, from: dictionary))
                                    }
                                    DispatchQueue.main.async {
                                        AppDelegate.sharedInstance.db?.deleteAll(tableName: db_request_modes) { success in
                                            if success {
                                                for arm in apprequestmode {
                                                    AppDelegate.sharedInstance.db?.insert_tbl_requestModes(apprequestmode: arm)
                                                }
                                            }
                                        }
                                    }
                                    
                                } catch let err {
                                    print(err.localizedDescription)
                                }
                            }
                        }
                        var login_count = [LoginCount]()
                        if let data = json.dictionary?[_login_count] {
                            do {
                                if let array = data.array {
                                    for json in array {
                                        let dictionary = try json.rawData()
                                        login_count.append(try JSONDecoder().decode(LoginCount.self, from: dictionary))
                                    }
                                    AppDelegate.sharedInstance.db?.deleteAll(tableName: db_login_count, handler: { _ in
                                        for count in login_count {
                                            AppDelegate.sharedInstance.db?.insert_tbl_login_count(login_count: count)
                                        }
                                    })
                                }
                            }catch let DecodingError.dataCorrupted(context) {
                                print(context)
                            } catch let DecodingError.keyNotFound(key, context) {
                                print("Key '\(key)' not found:", context.debugDescription)
                                print("codingPath:", context.codingPath)
                            } catch let DecodingError.valueNotFound(value, context) {
                                print("Value '\(value)' not found:", context.debugDescription)
                                print("codingPath:", context.codingPath)
                            } catch let DecodingError.typeMismatch(type, context)  {
                                print("Type '\(type)' mismatch:", context.debugDescription)
                                print("codingPath:", context.codingPath)
                            } catch {
                                print("error: ", error)
                            }
                        }
                        var ad_group = [LeadershipAwazAdGroup]()
                        if let data = json.dictionary?[_ad_group] {
                            do {
                                if let array = data.array {
                                    for json in array {
                                        let dictionary = try json.rawData()
                                        ad_group.append(try JSONDecoder().decode(LeadershipAwazAdGroup.self, from: dictionary))
                                    }
                                    AppDelegate.sharedInstance.db?.deleteAll(tableName: db_la_ad_group) { _ in
                                        for la_adGroup in ad_group {
                                            AppDelegate.sharedInstance.db?.insert_tbl_la_ad_group(la_adGroup: la_adGroup)
                                        }
                                    }
                                }
                            }catch let DecodingError.dataCorrupted(context) {
                                print(context)
                            } catch let DecodingError.keyNotFound(key, context) {
                                print("Key '\(key)' not found:", context.debugDescription)
                                print("codingPath:", context.codingPath)
                            } catch let DecodingError.valueNotFound(value, context) {
                                print("Value '\(value)' not found:", context.debugDescription)
                                print("codingPath:", context.codingPath)
                            } catch let DecodingError.typeMismatch(type, context)  {
                                print("Type '\(type)' mismatch:", context.debugDescription)
                                print("codingPath:", context.codingPath)
                            } catch {
                                print("error: ", error)
                            }
                        }
                        var scan_prefix = [ScanPrefix]()
                        if let data = json.dictionary?[_scan_prefix] {
                            do {
                                if let array = data.array {
                                    for json in array {
                                        let dictionary = try json.rawData()
                                        scan_prefix.append(try JSONDecoder().decode(ScanPrefix.self, from: dictionary))
                                    }
                                    AppDelegate.sharedInstance.db?.deleteAll(tableName: db_scan_prefix) { _ in
                                        for prefix in scan_prefix {
                                            AppDelegate.sharedInstance.db?.insert_tbl_scan_prefix(scan_prefix: prefix)
                                        }
                                    }
                                }
                            }catch let DecodingError.dataCorrupted(context) {
                                print(context)
                            } catch let DecodingError.keyNotFound(key, context) {
                                print("Key '\(key)' not found:", context.debugDescription)
                                print("codingPath:", context.codingPath)
                            } catch let DecodingError.valueNotFound(value, context) {
                                print("Value '\(value)' not found:", context.debugDescription)
                                print("codingPath:", context.codingPath)
                            } catch let DecodingError.typeMismatch(type, context)  {
                                print("Type '\(type)' mismatch:", context.debugDescription)
                                print("codingPath:", context.codingPath)
                            } catch {
                                print("error: ", error)
                            }
                        }
                        handler(true, "SUCCESS")
                    } else {
                        //Session Expired
                        handler(false, REVERTBACK)
                    }
                } else {
                    //API Issue
                    handler(false, REVERTBACK)
                }
            } else {
                //Network Issue
                handler(false, REVERTBACK)
            }
        }.resume()
    }
    
    class func hr_request(params: [String:Any], handler: @escaping(_ granted: Bool,_ response: Any) -> Void) {
        let Url = String(format: ENDPOINT)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return
        }
        request.httpBody = httpBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let json = JSON(data)
                if let success = json.dictionary?[returnStatus] {
                    //SUCCESS
                    if success.dictionary?[_code] == "0200" {
                        var hr_request: JSON?
                        var hr_logs:    JSON?
                        var hr_files:   JSON?
                        if let data = json.dictionary?[_hr_requests] {
                            hr_request = data
                        }
                        if let data = json.dictionary?[_hr_files] {
                            hr_files = data
                        }
                        if let data = json.dictionary?[_hr_logs] {
                            hr_logs = data
                        }
                        handler(true, [_hr_requests:hr_request,
                                       _hr_files: hr_files,
                                       _hr_logs: hr_logs,
                                       _count: json.dictionary?[_count],
                                       _sync_date: json.dictionary?[_sync_date]])
                    }
                    //FAILED
                    if success.dictionary?[_code] == "0400" || success.dictionary?[_code] == "0403" {
                        handler(false, REVERTBACK)
                    }
                }
            } else {
                handler(false, SOMETHINGWENTWRONG)
            }
        }.resume()
    }
    class func hr_notification(params: [String:Any], handler: @escaping(_ granted: Bool,_ response: Any) -> Void) {
        let Url = String(format: ENDPOINT)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return
        }
        request.httpBody = httpBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let json = JSON(data)
                if let success = json.dictionary?[returnStatus] {
                    //SUCCESS
                    if success.dictionary?[_code] == "0200" {
                        if let data = json.dictionary?[_notification_requests] {
                            handler(true, [_notification_requests: data, _count: json.dictionary?[_count], _sync_date: json.dictionary?[_sync_date]])
                            return
                        }
                        handler(true, data)
                    }
                    //FAILED
                    if success.dictionary?[_code] == "0400" || success.dictionary?[_code] == "0403" {
                        handler(false, REVERTBACK)
                    }
                }
            } else {
                handler(false, SOMETHINGWENTWRONG)
            }
        }.resume()
    }
    
    class func search_empoloyee(params: [String:Any], handler: @escaping(_ granted: Bool,_ response: Any) -> Void) {
        let Url = String(format: ENDPOINT)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return
        }
        request.httpBody = httpBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let json = JSON(data)
                if let success = json.dictionary?[returnStatus] {
                    //SUCCESS
                    if success.dictionary?[_code] == "0200" {
                        if let search_result = json.dictionary?[_search_result] {
                            handler(true, search_result)
                            return
                        }
                        handler(true, data)
                    }
                    //FAILED
                    if success.dictionary?[_code] == "0400" ||
                       success.dictionary?[_code] == "0403" ||
                       success.dictionary?[_code] == "0404" {
                        handler(false, "Employee not found.")
                    }
                }
            } else {
                handler(false, SOMETHINGWENTWRONG)
            }
        }.resume()
    }
    
    class func request_logs(params: [String:Any], handler: @escaping(_ granted: Bool,_ response: Any) -> Void) {
        let Url = String(format: ENDPOINT)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return
        }
        request.httpBody = httpBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let json = JSON(data)
                if let success = json.dictionary?[returnStatus] {
                    //SUCCESS
                    if success.dictionary?[_code] == "0200" {
//                        if let ticket_logs = json.dictionary?[_tickets_logs] {
//                            handler(true, ticket_logs)
//                            return
//                        }
                        if let _ = json.dictionary {
                            handler(true, json.dictionary)
                            return
                        }
                        handler(true, data)
                    }
                    //FAILED
                    if success.dictionary?[_code] == "0400" {
                        handler(false, "")
                    }
                    
                    if success.dictionary?[_code] == "0403" {
                        handler(false, "")
                    }
                    if success.dictionary?[_code] == "0404" {
                        handler(false, "")
                    }
                }
            } else {
                handler(false, SOMETHINGWENTWRONG)
            }
        }.resume()
    }
    
    class func update_request_logs(params: [String:Any], handler: @escaping(_ granted: Bool,_ response: Any) -> Void) {
        let Url = String(format: ENDPOINT)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return
        }
        request.httpBody = httpBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let json = JSON(data)
                if let success = json.dictionary?[returnStatus] {
                    //SUCCESS
                    if success.dictionary?[_code] == "0200" {
                        if let _ = json.dictionary {
                            handler(true, json.dictionary)
                            return
                        }
//                        handler(true, data)
                    }
                    //FAILED
                    if success.dictionary?[_code] == "0400" {
                        handler(false, "Employee not found.")
                    }
                    
                    if success.dictionary?[_code] == "0403" {
                        handler(false, "Employee not found.")
                    }
                    if success.dictionary?[_code] == "0404" {
                        handler(false, "Employee not found.")
                    }
                }
            } else {
                handler(false, SOMETHINGWENTWRONG)
            }
        }.resume()
    }
    
    class func read_notification(params: [String:Any], handler: @escaping(_ granted: Bool,_ response: Any) -> Void) {
        let Url = String(format: ENDPOINT)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return
        }
        request.httpBody = httpBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let json = JSON(data)
                if let success = json.dictionary?[returnStatus] {
                    //SUCCESS
                    if success.dictionary?[_code] == "0200" {
                        if let search_result = json.dictionary?[_search_result] {
                            handler(true, search_result)
                            return
                        }
                        handler(true, data)
                    }
                    //FAILED
                    if success.dictionary?[_code] == "0400" ||
                       success.dictionary?[_code] == "0403" ||
                       success.dictionary?[_code] == "0403" {
                        handler(false, "No Ticket Found.")
                    }
                }
            } else {
                handler(false, SOMETHINGWENTWRONG)
            }
        }.resume()
    }
    //MARK: ADD Grievance Ticket
    class func addrequestgrev(params: [String:Any], handler: @escaping(_ granted: Bool,_ response: Any) -> Void) {
        let Url = String(format: ENDPOINT)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let json = JSON(data)
                if let success = json.dictionary?[returnStatus] {
                    //SUCCESS
                    if success.dictionary?[_code] == "0200" {
                        if let _ = json.dictionary {
                            handler(true, json.dictionary)
                            return
                        }
                        handler(true, data)
                    }
                    //FAILED
                    if success.dictionary?[_code] == "0400" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                    
                    if success.dictionary?[_code] == "0403" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                    if success.dictionary?[_code] == "0404" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                }
            } else {
                handler(false, SOMETHINGWENTWRONG)
            }
        }.resume()
    }
    class func updaterequestgrev(params: [String:Any], handler: @escaping(_ granted: Bool,_ response: Any) -> Void) {
        let Url = String(format: ENDPOINT)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let json = JSON(data)
                if let success = json.dictionary?[returnStatus] {
                    //SUCCESS
                    if success.dictionary?[_code] == "0200" || success.dictionary?[_code] == "0208" {
                        if let _ = json.dictionary {
                            handler(true, json.dictionary)
                            return
                        }
                        handler(true, data)
                    }
                    //FAILED
                    
                    if success.dictionary?[_code] == "0400" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                    
                    if success.dictionary?[_code] == "0403" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                    if success.dictionary?[_code] == "0404" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                }
            } else {
                handler(false, SOMETHINGWENTWRONG)
            }
        }.resume()
    }
    
    //MARK: IMS
    
    //SETUP API
    class func ims_setup(params:[String:Any], handler: @escaping(_ granted: Bool, _ response: Any) -> Void) {
        let url = String(format: ENDPOINT)
        guard let serverUrl = URL(string: url) else { return }
        var request = URLRequest(url: serverUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return
        }
        request.httpBody = httpBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let json = JSON(data)
                if let success = json.dictionary?[returnStatus] {
                    if success.dictionary?[_code] == "0200" {
                        handler(true, json)
                    } else {
                        handler(false, "NO DATA")
                    }
                }
            }
        }.resume()
    }
    //Verify Consignment Number
    class func procconsignmentverify(params:[String:Any], handler: @escaping(_ granted: Bool, _ response: Any) -> Void) {
        let url = String(format: ENDPOINT)
        guard let serverUrl = URL(string: url) else { return }
        var request = URLRequest(url: serverUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return
        }
        request.httpBody = httpBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let json = JSON(data)
                if let success = json.dictionary?[returnStatus] {
                    if success.dictionary?[_code] == "0200" {
                        handler(true, json)
                    } else {
                        handler(false, "NOT VALID")
                    }
                }
            }
        }.resume()
    }
    
    //add new ticket
    class func addrequestims(params: [String:Any], handler: @escaping(_ granted: Bool,_ response: Any) -> Void) {
        let Url = String(format: ENDPOINT)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let json = JSON(data)
                if let success = json.dictionary?[returnStatus] {
                    //SUCCESS
                    if success.dictionary?[_code] == "0200" {
                        if let _ = json.dictionary {
                            handler(true, json.dictionary)
                            return
                        }
                        handler(true, data)
                    }
                    //FAILED
                    if success.dictionary?[_code] == "0400" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                    
                    if success.dictionary?[_code] == "0403" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                    if success.dictionary?[_code] == "0404" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                }
            } else {
                handler(false, SOMETHINGWENTWRONG)
            }
        }.resume()
    }
    class func updaterequestims(params: [String:Any], handler: @escaping(_ granted: Bool,_ response: Any) -> Void) {
        let Url = String(format: ENDPOINT)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let json = JSON(data)
                if let success = json.dictionary?[returnStatus] {
                    //SUCCESS
                    if success.dictionary?[_code] == "0200" {
                        if let _ = json.dictionary {
                            handler(true, json.dictionary)
                            return
                        }
                        handler(true, data)
                    }
                    //FAILED
                    if success.dictionary?[_code] == "0400" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                    
                    if success.dictionary?[_code] == "0403" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                    if success.dictionary?[_code] == "0404" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                    if success.dictionary?[_code] == "0208" {
                        handler(false, "Already Reported.")
                    }
                }
            } else {
                handler(false, SOMETHINGWENTWRONG)
            }
        }.resume()
    }
    class func getbookingdetails(params: [String:Any], handler: @escaping(_ granted: Bool,_ response: Any) -> Void) {
        let Url = String(format: "https://prodapi.tcscourier.com/core/api/main")
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return
        }
        request.httpBody = httpBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let json = JSON(data)
                if let success = json.dictionary?[returnStatus] {
                    if success.dictionary?[_code] == "200" {
                        handler(true, json.dictionary?["consignment"]?.dictionary?["track"])
                    }
                } else {
                    handler(false, SOMETHINGWENTWRONG)
                }
            } else {
                handler(false, SOMETHINGWENTWRONG)
            }
        }.resume()
    }
    
    //Leadership Awaz
    class func addawazrequest(params: [String:Any], handler: @escaping(_ granted: Bool,_ response: Any) -> Void) {
        let Url = String(format: ENDPOINT)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let json = JSON(data)
                if let success = json.dictionary?[returnStatus] {
                    //SUCCESS
                    if success.dictionary?[_code] == "0200" {
                        if let _ = json.dictionary {
                            handler(true, json.dictionary)
                            return
                        }
                        handler(true, data)
                    }
                    //FAILED
                    if success.dictionary?[_code] == "0400" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                    
                    if success.dictionary?[_code] == "0403" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                    if success.dictionary?[_code] == "0404" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                }
            } else {
                handler(false, SOMETHINGWENTWRONG)
            }
        }.resume()
    }
    class func updateawazrequest(params: [String:Any], handler: @escaping(_ granted: Bool,_ response: Any) -> Void) {
        let Url = String(format: ENDPOINT)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let json = JSON(data)
                if let success = json.dictionary?[returnStatus] {
                    //SUCCESS
                    if success.dictionary?[_code] == "0200" {
                        if let _ = json.dictionary {
                            handler(true, json.dictionary)
                            return
                        }
                        handler(true, data)
                    }
                    //FAILED
                    if success.dictionary?[_code] == "0400" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                    
                    if success.dictionary?[_code] == "0403" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                    if success.dictionary?[_code] == "0404" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                    if success.dictionary?[_code] == "0208" {
                        handler(false, "Already Reported.")
                    }
                }
            } else {
                handler(false, SOMETHINGWENTWRONG)
            }
        }.resume()
    }
    
    //MARK: Attendance
    class func get_tcs_location(params: [String:Any], handler: @escaping(_ granted: Bool,_ response: Any) -> Void) {
        let Url = String(format: ENDPOINT)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return
        }
        request.httpBody = httpBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let json = JSON(data)
                if let success = json.dictionary?[returnStatus] {
                    //SUCCESS
                    if success.dictionary?[_code] == "0200" {
                        if let attn_out = json.dictionary?[_attn_out]?.array {
                            handler(true, attn_out)
                        } else {
                            handler(false, SOMETHINGWENTWRONG)
                        }
                    }
                    //FAILED
                    if success.dictionary?[_code] == "0400" || success.dictionary?[_code] == "0403" {
                        handler(false, REVERTBACK)
                    }
                }
            } else {
                handler(false, SOMETHINGWENTWRONG)
            }
        }.resume()
    }
    class func fetch_attendance(params: [String:Any], handler: @escaping(_ granted: Bool,_ response: Any) -> Void) {
        let Url = String(format: ENDPOINT)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return
        }
        request.httpBody = httpBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let json = JSON(data)
                if let success = json.dictionary?[returnStatus] {
                    //SUCCESS
                    if success.dictionary?[_code] == "0200" {
                        if let attn_out = json.dictionary?[_attn_out]?.array {
                            handler(true, attn_out)
                        } else {
                            handler(false, SOMETHINGWENTWRONG)
                        }
                    }
                    //FAILED
                    if success.dictionary?[_code] == "0400" || success.dictionary?[_code] == "0403" {
                        handler(false, REVERTBACK)
                    }
                }
            } else {
                handler(false, SOMETHINGWENTWRONG)
            }
        }.resume()
    }
    class func mark_attendance(params: [String:Any], handler: @escaping(_ granted: Bool,_ response: Any) -> Void) {
        let Url = String(format: ENDPOINT)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return
        }
        request.httpBody = httpBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let json = JSON(data)
                if let success = json.dictionary?[returnStatus] {
                    //SUCCESS
                    if success.dictionary?[_code] == "0200" {
                        if let attn_out = json.dictionary?[_attn_out]?.array {
                            handler(true, attn_out)
                        } else {
                            handler(false, SOMETHINGWENTWRONG)
                        }
                    }
                    //FAILED
                    if success.dictionary?[_code] == "0400" || success.dictionary?[_code] == "0403" {
                        handler(false, REVERTBACK)
                    }
                }
            } else {
                handler(false, SOMETHINGWENTWRONG)
            }
        }.resume()
    }
    
    //MARK: FULFILMENT
    class func getorderfulfilment(params: [String:Any], handler: @escaping(_ granted: Bool,_ response: Any) -> Void) {
        let Url = String(format: ENDPOINT)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return
        }
        request.httpBody = httpBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let json = JSON(data)
                if let success = json.dictionary?[returnStatus] {
                    //SUCCESS
                    if success.dictionary?[_code] == "0200" {
                        if let data = json.dictionary?[_orders] {
                            handler(true, [_orders: data, _count: json.dictionary?[_count], _sync_date: json.dictionary?[_sync_date]])
                            return
                        }
                        handler(true, data)
                    }
                    //FAILED
                    if success.dictionary?[_code] == "0400" || success.dictionary?[_code] == "0403" {
                        handler(false, REVERTBACK)
                    }
                }
            } else {
                handler(false, SOMETHINGWENTWRONG)
            }
        }.resume()
    }
    
    class func updatefulfillmentorder(params: [String:Any], handler: @escaping(_ granted: Bool,_ response: Any) -> Void) {
        let Url = String(format: ENDPOINT)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let json = JSON(data)
                if let success = json.dictionary?[returnStatus] {
                    //SUCCESS
                    if success.dictionary?[_code] == "0200" {
                        if let o = json.dictionary?[_orders] {
                            handler(true, o)
                            return
                        }
                        handler(true, data)
                    }
                    //FAILED
                    if success.dictionary?[_code] == "0400" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                    
                    if success.dictionary?[_code] == "0403" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                    if success.dictionary?[_code] == "0404" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                    if success.dictionary?[_code] == "0208" {
                        handler(false, "Already Reported.")
                    }
                }
            } else {
                handler(false, SOMETHINGWENTWRONG)
            }
        }.resume()
    }
    
    //MARK: Wallet
    class func getwallettoken(_ handler: @escaping(Bool)->Void) {
        let Url = String(format: WALLET_GET_TOKEN)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        let params = ["clientSecret": CLIENTSECRET]
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return
        }
        request.httpBody = httpBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let json = JSON(data)
                if let bearer_token = json.dictionary?[_token]?.string {
                    BEARER_TOKEN = bearer_token
                    handler(true)
                    return
                } else {
                    handler(false)
                }
            } else {
                handler(false)
            }
        }.resume()
    }
    class func setupwallet(params: [String:Any], _ handler: @escaping(_ granted: Bool,_ response: Any) -> Void) {
        let Url = String(format: WALLET_SETUP)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.setValue("Bearer \(BEARER_TOKEN)", forHTTPHeaderField: "Authorization")
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return
        }
        request.httpBody = httpBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let json = JSON(data)
                if let success = json.dictionary?[returnStatus] {
                    //SUCCESS
                    if success.dictionary?[_code] == "0200" {
                        handler(true, data)
                        return
                    }
                    //FAILED
                    if success.dictionary?[_code] == "0400" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                    if success.dictionary?[_code] == "0403" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                    if success.dictionary?[_code] == "0404" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                    if success.dictionary?[_code] == "0208" {
                        handler(false, "Already Reported.")
                    }
                }
            } else {
                handler(false, SOMETHINGWENTWRONG)
            }
        }.resume()
    }
    class func getwalletsummarypoints(params: [String:Any], _ handler: @escaping(_ granted: Bool,_ response: Any) -> Void) {

        let Url = String(format: WALLET_SUMMARY_POINT)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Bearer \(BEARER_TOKEN)", forHTTPHeaderField: "Authorization")
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return
        }
        request.httpBody = httpBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let json = JSON(data)
                if let success = json.dictionary?[returnStatus] {
                    //SUCCESS
                    if success.dictionary?[_code] == "0200" {
                        handler(true, data)
                        return
                    }
                    //FAILED
                    if success.dictionary?[_code] == "0400" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                    if success.dictionary?[_code] == "0403" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                    if success.dictionary?[_code] == "0404" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                    if success.dictionary?[_code] == "0208" {
                        handler(false, "Already Reported.")
                    }
                }
            } else {
                handler(false, SOMETHINGWENTWRONG)
            }
        }.resume()
    }
    class func getwallethistorypoints(params: [String:Any], _ handler: @escaping(_ granted: Bool,_ response: Any) -> Void) {
        let Url = String(format: WALLET_HISTORY_POINT)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Bearer \(BEARER_TOKEN)", forHTTPHeaderField: "Authorization")
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return
        }
        request.httpBody = httpBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let json = JSON(data)
                if let success = json.dictionary?[returnStatus] {
                    //SUCCESS
                    if success.dictionary?[_code] == "0200" {
                        handler(true, data)
                        return
                    }
                    //FAILED
                    if success.dictionary?[_code] == "0400" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                    if success.dictionary?[_code] == "0403" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                    if success.dictionary?[_code] == "0404" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                    if success.dictionary?[_code] == "0208" {
                        handler(false, "Already Reported.")
                    }
                }
            } else {
                handler(false, SOMETHINGWENTWRONG)
            }
        }.resume()
    }
    class func getwalletdetailpoints(params: [String:Any], _ handler: @escaping(_ granted: Bool,_ response: Any) -> Void) {
        let Url = String(format: WALLET_DETAIL_POINTS)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Bearer \(BEARER_TOKEN)", forHTTPHeaderField: "Authorization")
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return
        }
        request.httpBody = httpBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let json = JSON(data)
                if let success = json.dictionary?[returnStatus] {
                    //SUCCESS
                    if success.dictionary?[_code] == "0200" {
                        handler(true, data)
                        return
                    }
                    //FAILED
                    if success.dictionary?[_code] == "0400" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                    if success.dictionary?[_code] == "0403" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                    if success.dictionary?[_code] == "0404" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                    if success.dictionary?[_code] == "0208" {
                        handler(false, "Already Reported.")
                    }
                }
            } else {
                handler(false, SOMETHINGWENTWRONG)
            }
        }.resume()
    }
    class func getwalletpin(params: [String:Any], _ handler: @escaping(Bool) -> Void) {
        let Url = String(format: WALLET_PIN_GENERATION)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Bearer \(BEARER_TOKEN)", forHTTPHeaderField: "Authorization")
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return
        }
        request.httpBody = httpBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let json = JSON(data)
                if let success = json.dictionary?[returnStatus] {
                    //SUCCESS
                    if success.dictionary?[_code] == "0200" {
                        handler(true)
                        return
                    } else {
                        handler(false)
                    }
                } else {
                    handler(false)
                }
            } else {
                handler(false)
            }
        }.resume()
    }
    class func addwalletbeneficiaries(params: [String:Any], _ handler: @escaping(_ granted: Bool,_ response: Any) -> Void) {
        let Url = String(format: WALLET_ADD_BENEFICIARY)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Bearer \(BEARER_TOKEN)", forHTTPHeaderField: "Authorization")
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return
        }
        request.httpBody = httpBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let json = JSON(data)
                if let success = json.dictionary?[returnStatus] {
                    //SUCCESS
                    if success.dictionary?[_code] == "0200" {
                        handler(true, data)
                        return
                    }
                    //FAILED
                    if success.dictionary?[_code] == "0400" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                    if success.dictionary?[_code] == "0403" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                    if success.dictionary?[_code] == "0404" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                    if success.dictionary?[_code] == "0208" {
                        handler(false, "Already Reported.")
                    }
                }
            } else {
                handler(false, SOMETHINGWENTWRONG)
            }
        }.resume()
    }
    class func getwalletbeneficiary(params: [String:Any], _ handler: @escaping(_ granted: Bool,_ response: Any) -> Void) {
        let Url = String(format: WALLET_GET_BENEFICIARY)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Bearer \(BEARER_TOKEN)", forHTTPHeaderField: "Authorization")
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return
        }
        request.httpBody = httpBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let json = JSON(data)
                if let success = json.dictionary?[returnStatus] {
                    //SUCCESS
                    if success.dictionary?[_code] == "0200" {
                        handler(true, data)
                        return
                    }
                    //FAILED
                    if success.dictionary?[_code] == "0400" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                    if success.dictionary?[_code] == "0403" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                    if success.dictionary?[_code] == "0404" {
                        handler(false, SOMETHINGWENTWRONG)
                    }
                    if success.dictionary?[_code] == "0208" {
                        handler(false, "Already Reported.")
                    }
                }
            } else {
                handler(false, SOMETHINGWENTWRONG)
            }
        }.resume()
    }
}





//@available(iOS 12.0, *)
class NSURLSessionPinningDelegate: NSObject, URLSessionDelegate {

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {

        // Adapted from OWASP https://www.owasp.org/index.php/Certificate_and_Public_Key_Pinning#iOS

        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                var secresult = SecTrustResultType.invalid
                let status = SecTrustEvaluate(serverTrust, &secresult)

                if(errSecSuccess == status) {
                    if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
                        let serverCertificateData = SecCertificateCopyData(serverCertificate)
                        let data = CFDataGetBytePtr(serverCertificateData);
                        let size = CFDataGetLength(serverCertificateData);
                        let cert1 = NSData(bytes: data, length: size)
                        let file_der = Bundle.main.path(forResource: "KEYSTORE", ofType: "der")

                        if let file = file_der {
                            if let cert2 = NSData(contentsOfFile: file) {
                                if cert1.isEqual(to: cert2 as Data) {
                                    completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust:serverTrust))
                                    return
                                }
                            }
                        }
                    }
                }
            }
        }

        // Pinning failed
        completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
    }
}
