//
//  RequestManager.swift
//  tcs_one_app
//
//  Created by ibs on 21/10/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class RequestManager {
    let productionDomain = "devapi.tcscourier.com"
//    let productionDomain = "api.myappprod.com"
    let certificateFilename = "KEYSTORE"
    let certificateExtension = "der"
    let useSSL = true
    var manager: SessionManager!
    var serverTrustPolicies: [String : ServerTrustPolicy] = [String:ServerTrustPolicy]()
    static let sharedManager = RequestManager()
    
    
    init(){
        manager = initSafeManager()
    }
    
    func initSafeManager() -> SessionManager {
        setServerTrustPolicies()

        manager = SessionManager(configuration: URLSessionConfiguration.default, delegate: SessionDelegate(), serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))

        return manager
    }
    
    
    func setServerTrustPolicies() {
        serverTrustPolicies = [
            productionDomain: .pinCertificates(
                certificates: ServerTrustPolicy.certificates(in: Bundle.main),
                validateCertificateChain: true,
                validateHost: true
            )
        ]
        
//        let pathToCert = Bundle.main.path(forResource: certificateFilename, ofType: certificateExtension)
//        let localCertificate:Data = try! Data(contentsOf: URL(fileURLWithPath: pathToCert!))
//        var secIdentity: SecIdentity?
//        do {
//            secIdentity = try identity(named: certificateFilename, password: "W3bsph3r3sandbox")
//        } catch let err {
//            print(err.localizedDescription)
//        }
        
//        let serverTrustPolicies: [String: ServerTrustPolicy] = [
//            productionDomain: .pinCertificates(
//                certificates: [SecCertificateCreateWithData(nil, localCertificate as CFData)!],
//
//                validateCertificateChain: true,
//                validateHost: true
//            ),
//            productionDomain: .disableEvaluation
//        ]

//        self.serverTrustPolicies = serverTrustPolicies
    }
    
    func identity(named name: String, password: String) throws -> SecIdentity {
        let url = Bundle.main.url(forResource: name, withExtension: "der")!
        let data = try Data(contentsOf: url)
        var importResult: CFArray? = nil
        let err = SecPKCS12Import(
            data as NSData,
            [kSecImportExportPassphrase as String: password] as NSDictionary,
            &importResult
        )
        guard err == errSecSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(err), userInfo: nil)
        }
        let identityDictionaries = importResult as! [[String:Any]]
        return identityDictionaries[0][kSecImportItemIdentity as String] as! SecIdentity
        
        
    }
}
