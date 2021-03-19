//
//  DBHelper.swift
//  tcs_one_app
//
//  Created by ibs on 22/10/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import Foundation
import UIKit
import SQLite3


class DBHelper {
    init(databaseName: String)
    {
        db = openDatabase(databaseName: databaseName)
    }
    
    var db:OpaquePointer?
    
    func databaseURL(databaseName: String) -> URL? {

        let path = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).last! as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("\(databaseName).db") {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                let new_db = UserDefaults.standard.bool(forKey: "NEWDB")
                if new_db {
                    do {
                        try fileManager.removeItem(at: pathComponent)
                        try fileManager.removeItem(at: url.appendingPathComponent("\(databaseName).db-shm")!)
                        try fileManager.removeItem(at: url.appendingPathComponent("\(databaseName).db-wal")!)
                        UserDefaults.standard.removeObject(forKey: "CurrentUser")
                        UserDefaults.standard.removeObject(forKey: USER_ACCESS_TOKEN)
                        UserDefaults.standard.set(false, forKey: "NEWDB")
                        return self.copy_database(databaseName: databaseName, pathComponent: pathComponent)

                    } catch let err {
                        print(err.localizedDescription)
                    }
                }
                print(pathComponent)
                return pathComponent
            } else {
                UserDefaults.standard.set(false, forKey: "NEWDB")
                return self.copy_database(databaseName: databaseName, pathComponent: pathComponent)
            }
        } else {
            print("FILE PATH NOT AVAILABLE")
        }
        return nil
    }
    
    private func copy_database(databaseName: String, pathComponent: URL) -> URL? {
        if let bundleURL = Bundle.main.url(forResource: databaseName, withExtension: "db") {
            do {
//                let filePath = pathComponent.path
                let fileManager = FileManager.default
                try fileManager.copyItem(at: bundleURL, to: pathComponent)
                return pathComponent
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            
        }
        return nil
    }
    func openDatabase(databaseName: String) -> OpaquePointer?
    {
        var fileURL : URL?
        fileURL = databaseURL(databaseName: databaseName)
        var db: OpaquePointer? = nil
        if sqlite3_open_v2(fileURL!.path, &db, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX, nil) == SQLITE_OK {
            print("Successfully opened connection to database at \(databaseName)")
            return db
        }
        else {
            print("error opening database")
            return nil
        }
    }
    
    func closeDatabase() {
        sqlite3_close(db)
    }
    
    
    private func modify_tables() {
        var createTableStatement: OpaquePointer?
        let create_la_ad_group = "CREATE TABLE LA_AdGROUP (ID INTEGER PRIMARY KEY AUTOINCREMENT, SERVER_ID_PK    INTEGER, AD_GROUP_NAME TEXT, AD_GROUP_EMAIL_ID TEXT, STATUS TEXT, CREATED_DATE TEXT, CREATED_BY TEXT, UPDATED_DATE TEXT, UPDATED_BY TEXT)"
        if sqlite3_prepare_v2(db, create_la_ad_group, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("\nLeadership-Awaz AD_GROUP table created.")
            } else {
                print("\nLeadership-Awaz AD_GROUP table is not created.")
            }
        } else {
            print("\nCREATE TABLE statement is not prepared.")
        }
        sqlite3_finalize(createTableStatement)
        
    }
    
    //MARK: GLOBAL METHODs
    func deleteAllWithCondition(tableName: String, columnName: String, value: String, handler: @escaping(_ success: Bool) -> Void) {
        let deleteStatementStirng = "DELETE FROM \(tableName) WHERE \(columnName) = '\(value)';"
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
//                print("\(tableName): Successfully deleted...")
                handler(true)
            } else {
                print("\(tableName): Couldn't delete.")
                handler(false)
            }
        } else {
            print("\(tableName): DELETE statement could not be prepared")
            handler(false)
        }
        sqlite3_finalize(deleteStatement)
    }
    func deleteAll(tableName: String, handler: @escaping(_ success: Bool) -> Void) {
        let deleteStatementStirng = "DELETE FROM \(tableName);"
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
//                print("\(tableName): Successfully deleted...")
                handler(true)
            } else {
                print("\(tableName): Couldn't delete.")
                handler(false)
            }
        } else {
            print("\(tableName): DELETE statement could not be prepared")
            handler(false)
        }
        sqlite3_finalize(deleteStatement)
    }
    
    func deleteRow(tableName: String, column: String, ref_id: String, handler: @escaping(_ success: Bool) -> Void) {
        let deleteStatementStirng = "DELETE FROM \(tableName) WHERE \(column) = '\(ref_id)';"
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
//                print("\(tableName): \(column)->\(ref_id): Successfully deleted...")
                handler(true)
            } else {
                print("\(tableName): Couldn't delete.")
                handler(false)
            }
        } else {
            print("\(tableName): DELETE statement could not be prepared")
            handler(false)
        }
        sqlite3_finalize(deleteStatement)
    }
    
    func deleteRowWithMultipleConditions(tbl: String, conditions: String, _ handler: @escaping(_ success: Bool)->Void) {
        let deleteStatementString = "DELETE FROM \(tbl) WHERE \(conditions);"
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                handler(true)
            } else {
                print("\(tbl): Couldn't delete.")
                handler(false)
            }
        } else {
            print("\(tbl): DELETE statement could not be prepared")
            handler(false)
        }
        sqlite3_finalize(deleteStatement)
    }
    
    func updateTables(tableName: String, columnName: [String], updateValue: [String], onCondition: String, _ handler: @escaping(_ success: Bool)->Void) {
        var updateStatementString = ""
        for (i,(c,u)) in zip(columnName, updateValue).enumerated() {
            if i == 0 {
                updateStatementString = "UPDATE \(tableName) SET \(c) = '\(u)'"
            } else {
                let temp = ", \(c) = '\(u)'"
                updateStatementString += temp
            }
        }
        updateStatementString += " WHERE \(onCondition)"
        var updateStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("\(tableName): Successfully updated row.")
                handler(true)
            } else {
                print("\(tableName): Could not update row.")
                handler(false)
            }
        } else {
            print("\(tableName): UPDATE statement could not be prepared")
            handler(false)
        }
        sqlite3_finalize(updateStatement)
    }
    func read_column(query: String) -> Any {
        let queryStatementString = query// "SELECT * FROM \(db_files) WHERE TICKET_ID = '\(ticketId)'"
        var queryStatement: OpaquePointer? = nil
        
        var ref_id = ""
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                ref_id = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
            }
        } else {
            print("SELECT statement 'read_column' could not be prepared")
        }
        return ref_id
    }
    
    func readTables(tableName: String, condition: String) -> Bool {
        let queryStatementString = "SELECT * FROM \(tableName) WHERE \(condition);"
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                return true
            } else {
                return false
            }
        } else {
            print("SELECT statement \(db_user_page) could not be prepared")
        }
        return false
    }
    func read_tbl_UserPermission() -> [tbl_UserPermission]{
        let queryStatementString = "SELECT * FROM \(db_user_permission);"
        var queryStatement: OpaquePointer? = nil
        var tbl_userpermission: [tbl_UserPermission] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let server_id_pk = Int(sqlite3_column_int(queryStatement, 1))
                let page_id = Int(sqlite3_column_int(queryStatement, 2))
                let permission = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                let is_active = Int(sqlite3_column_int(queryStatement, 4))
                
                tbl_userpermission.append(tbl_UserPermission(ID: id, SERVER_ID_PK: server_id_pk, PAGEID: page_id, PERMISSION: permission, ISACTIVE: is_active))
            }
        } else {
            print("\(db_user_permission): SELECT statement could not be prepared")
        }
        return tbl_userpermission
    }
    
    func readLastSyncStatus(tableName: String, condition: String) -> tbl_last_sync_status? {
        let queryStatementString = "SELECT * FROM \(tableName) WHERE \(condition);"
        var queryStatement: OpaquePointer? = nil
        var last_sync: tbl_last_sync_status?
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let sync_key = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let status = Int(sqlite3_column_int(queryStatement, 2))
                let date = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                let skip = Int(sqlite3_column_int(queryStatement, 4))
                let take = Int(sqlite3_column_int(queryStatement, 5))
                let total_records = Int(sqlite3_column_int(queryStatement, 6))
                let current_user = String(describing: String(cString: sqlite3_column_text(queryStatement, 7)))
                
                last_sync = tbl_last_sync_status(ID: id,
                                                 SYNC_KEY: sync_key,
                                                 STATUS: status,
                                                 DATE: date,
                                                 SKIP: skip,
                                                 TAKE: take,
                                                 TOTAL_RECORDS: total_records,
                                                 CURRENT_USER: current_user)
                return last_sync
            } else {
                return nil
            }
        } else {
            print("SELECT statement \(tableName) could not be prepared")
        }
        return last_sync
    }
    
    func readAllServerPkId(tableName: String) -> [Int] {
//        let queryStatementString = "SELECT SERVER_ID_PK FROM \(tableName) WHERE CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)';"
        let queryStatementString = "SELECT SERVER_ID_PK FROM \(tableName);"
        var queryStatement: OpaquePointer? = nil
        var ids: [Int] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                ids.append(id)
            }
        } else {
            print("SELECT statement \(tableName) could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return ids
    }
    
    func insertLastSyncStatus(sync_key: String, status: Int, date: String, skip: Int, take: Int, total_records: Int, current_user: String) {
        let insertStatementString = "INSERT INTO \(db_last_sync_status)(SYNC_KEY, STATUS, DATE, SKIP, TAKE, TOTAL_RECORDS, CURRENT_USER) VALUES (?, ?, ?, ?, ?, ?, ?);"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (sync_key as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 2, Int32(status))
            sqlite3_bind_text(insertStatement, 3, (date as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 4, Int32(skip))
            sqlite3_bind_int(insertStatement, 5, Int32(take))
            sqlite3_bind_int(insertStatement, 6, Int32(total_records))
            sqlite3_bind_text(insertStatement, 7, (current_user as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                //print("\(db_last_sync_status): Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    
    //MARK: USER MODULE
    func insert_tbl_UserModule(usermodule: Module) {
        let insertStatementString = "INSERT INTO \(db_user_module)(SERVER_ID_PK, MODULENAME, ISACTIVE, MODULEORDER, MODULEICON, PARENTID, TAGNAME) VALUES (?, ?, ?, ?, ?, ?, ?);"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(insertStatement, 1, Int32(usermodule.moduleid ?? -1))
            sqlite3_bind_text(insertStatement, 2, ((usermodule.modulename ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 3, Int32(usermodule.isactive ?? -1))
            sqlite3_bind_int(insertStatement, 4, Int32(usermodule.moduleorder ?? -1))
            sqlite3_bind_text(insertStatement, 5, ((usermodule.moduleicon ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 6, Int32(usermodule.parentid ?? -1))
            sqlite3_bind_text(insertStatement, 7, ((usermodule.tagname ?? "") as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                //print("USER_MODULE: Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    func read_tbl_UserModule(query: String) -> [tbl_UserModule]{
        let queryStatementString = query
        var queryStatement: OpaquePointer? = nil
        var tbl_usermodule: [tbl_UserModule] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let server_id_pk = Int(sqlite3_column_int(queryStatement, 1))
                let modulename = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let isactive = Int(sqlite3_column_int(queryStatement, 3))
                let moduleorder = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                let moduleicon = String(describing: String(cString: sqlite3_column_text(queryStatement, 5)))
                let parentid = Int(sqlite3_column_int(queryStatement, 6))
                let tagname = String(describing: String(cString: sqlite3_column_text(queryStatement, 7)))
                
                
                tbl_usermodule.append(tbl_UserModule(ID: id, SERVER_ID_PK: server_id_pk, MODULENAME: modulename, ISACTIVE: isactive, MODULEORDER: moduleorder, MODULEICON: moduleicon, PARENTID: parentid, TAGNAME: tagname))
            }
        } else {
            print("SELECT statement (tbl_UserModule) could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return tbl_usermodule
    }
    
    //MARK: USER_PAGE
    func insert_tbl_UserPage(userpage: Page) {
        let insertStatementString = "INSERT INTO \(db_user_page)(SERVER_ID_PK, MODULEID, PAGENAME, PAGEURL, ISACTIVE, TAGNAME) VALUES (?, ?, ?, ?, ?, ?);"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(insertStatement, 1, Int32(userpage.pageid ?? -1))
            sqlite3_bind_int(insertStatement, 2, Int32(userpage.moduleid ?? -1))
            sqlite3_bind_text(insertStatement, 3, ((userpage.pagename ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, ((userpage.pageurl ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 5, Int32(userpage.isactive ?? -1))
            sqlite3_bind_text(insertStatement, 6, ((userpage.tagname ?? "") as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                //print("\(db_user_page): Successfully inserted row.")
            } else {
                print("\(db_user_page): Could not insert row.")
            }
        } else {
            print("\(db_user_page): INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    func read_tbl_UserPage() -> [tbl_UserPage]{
        let queryStatementString = "SELECT * FROM \(db_user_page);"
        var queryStatement: OpaquePointer? = nil
        var tbl_userpage: [tbl_UserPage] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let server_id_pk = Int(sqlite3_column_int(queryStatement, 1))
                let module_id = Int(sqlite3_column_int(queryStatement, 2))
                let page_name = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                let page_url = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                let is_active = Int(sqlite3_column_int(queryStatement, 5))
                let tag_name = String(describing: String(cString: sqlite3_column_text(queryStatement, 6)))
                tbl_userpage.append(tbl_UserPage(ID: id, SERVER_ID_PK: server_id_pk, MODULEID: module_id, PAGENAME: page_name, PAGEURL: page_url, ISACTIVE: is_active, TAGNAME: tag_name))
            }
        } else {
            print("SELECT statement \(db_user_page) could not be prepared")
        }
        
        return tbl_userpage
    }
    
    //MARK: USER_PERMISSION
//    func insert_tbl_UserPermission(server_id_pk: Int, page_id: Int, permission: String, is_active: Int) {
    func insert_tbl_UserPermission(userpermission: Permission) {
        let insertStatementString = "INSERT INTO \(db_user_permission)(SERVER_ID_PK, PAGEID, PERMISSION, ISACTIVE) VALUES (?, ?, ?, ?);"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_int(insertStatement, 1, Int32(userpermission.permissionid ?? -1))
            sqlite3_bind_int(insertStatement, 2, Int32(userpermission.pageid ?? -1))
            sqlite3_bind_text(insertStatement, 3, ((userpermission.permission ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 4, Int32(userpermission.isactive ?? -1))
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                //print("\(db_user_permission): Successfully inserted row.")
            } else {
                print("\(db_user_permission): Could not insert row.")
            }
        } else {
            print("\(db_user_permission): INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    func read_tbl_UserPermission(permission: String) -> [tbl_UserPermission]{
        let queryStatementString = "SELECT * FROM \(db_user_permission) WHERE PERMISSION = '\(permission)';"
        var queryStatement: OpaquePointer? = nil
        var tbl_userpermission: [tbl_UserPermission] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let server_id_pk = Int(sqlite3_column_int(queryStatement, 1))
                let page_id = Int(sqlite3_column_int(queryStatement, 2))
                let permission = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                let is_active = Int(sqlite3_column_int(queryStatement, 4))
                
                tbl_userpermission.append(tbl_UserPermission(ID: id, SERVER_ID_PK: server_id_pk, PAGEID: page_id, PERMISSION: permission, ISACTIVE: is_active))
            }
        } else {
            print("\(db_user_permission): SELECT statement could not be prepared")
        }
        return tbl_userpermission
    }
    //MARK: USER_PROFILE
    func insert_tbl_UserProfile(user: User) {
        let insertStatementString = "INSERT INTO \(db_user_profile)(SERVER_ID_PK,EMP_NAME,GENDER,CNIC_NO,DISABLE_STATUS,CURR_CITY,EMP_CELL_1,EMP_CELL_2,GRADE_CODE,EMP_STATUS,UNIT_CODE,WORKING_DESIG_CODE,DESIG_CODE,DEPT_CODE,SUB_DEPT_CODE,USERID,AREA_CODE,STATION_CODE,HUB_CODE,ACCESSTOKEN, HIGHNESS) VALUES (?, ?, ?, ?,?, ?, ?, ?,?, ?, ?, ?,?, ?, ?, ?,?, ?, ?, ?, ?);"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_int(insertStatement, 1, Int32(user.empid ?? -1))
            sqlite3_bind_text(insertStatement, 2, ((user.empName ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, ((user.gender ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, ((user.cnicNo ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 5, ((user.disableStatus ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 6, ((user.currCity ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 7, ((user.empCell1 ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 8, ((user.empCell2 ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 9, ((user.gradeCode ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 10, ((user.empStatus ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 11, ((user.unitCode ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 12, ((user.workingDesig ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 13, Int32(user.deptCode ?? -1))
            sqlite3_bind_int(insertStatement, 14, Int32(user.deptCode ?? -1))
            sqlite3_bind_int(insertStatement, 15, Int32(user.subDeptCode ?? -1))
            sqlite3_bind_text(insertStatement, 16, ((user.userid ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 17, ((user.areaCode ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 18, ((user.stationCode ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 19, ((user.hubCode ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 20, ((UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN) ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 21, ((user.highness ?? "") as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                //print("\(db_user_profile): Successfully inserted row.")
            } else {
                print("\(db_user_profile): Could not insert row.")
            }
        } else {
            print("\(db_user_profile): INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    
    func read_tbl_UserProfile() -> [tbl_UserProfile]{
        let queryStatementString = "SELECT * FROM \(db_user_profile);"
        var queryStatement: OpaquePointer? = nil
        var tbl_userprofile: [tbl_UserProfile] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let server_id_pk = Int(sqlite3_column_int(queryStatement, 1))
                let emp_name = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let gender = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                let cnic_no = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                let disable_status = String(describing: String(cString: sqlite3_column_text(queryStatement, 5)))
                let curr_city = String(describing: String(cString: sqlite3_column_text(queryStatement, 6)))
                let emp_cell_1 = String(describing: String(cString: sqlite3_column_text(queryStatement, 7)))
                let emp_cell_2 = String(describing: String(cString: sqlite3_column_text(queryStatement, 8)))
                let grade_code = String(describing: String(cString: sqlite3_column_text(queryStatement, 9)))
                let emp_status = String(describing: String(cString: sqlite3_column_text(queryStatement, 10)))
                let unit_code = String(describing: String(cString: sqlite3_column_text(queryStatement, 11)))
                let working_desig_code = String(describing: String(cString: sqlite3_column_text(queryStatement, 12)))
                let desig_code = Int(sqlite3_column_int(queryStatement, 13))
                let dept_code = Int(sqlite3_column_int(queryStatement, 14))
                let sub_dept_code = Int(sqlite3_column_int(queryStatement, 15))
                let user_id = String(describing: String(cString: sqlite3_column_text(queryStatement, 16)))
                let area_code = String(describing: String(cString: sqlite3_column_text(queryStatement, 17)))
                let station_code = String(describing: String(cString: sqlite3_column_text(queryStatement, 18)))
                let hub_code = String(describing: String(cString: sqlite3_column_text(queryStatement, 19)))
                let access_token = String(describing: String(cString: sqlite3_column_text(queryStatement, 20)))
                let highness = String(describing: String(cString: sqlite3_column_text(queryStatement, 21)))
                
                tbl_userprofile.append(tbl_UserProfile(ID: id, SERVER_ID_PK: server_id_pk, EMP_NAME: emp_name, GENDER: gender, CNIC_NO: cnic_no, DISABLE_STATUS: disable_status, CURR_CITY: curr_city, EMP_CELL_1: emp_cell_1, EMP_CELL_2: emp_cell_2, GRADE_CODE: grade_code, EMP_STATUS: emp_status, UNIT_CODE: unit_code, WORKING_DESIG_CODE: working_desig_code, DESIG_CODE: desig_code, DEPT_CODE: dept_code, SUB_DEPT_CODE: sub_dept_code, USERID: user_id, AREA_CODE: area_code, STATION_CODE: station_code, HUB_CODE: hub_code, ACCESSTOKEN: access_token, HIGHNESS: highness))
            }
        } else {
            print("\(db_user_profile): SELECT statement could not be prepared")
        }
        return tbl_userprofile
    }
    
    
    //MARK: REMARKS
    func insert_tbl_Remarks(remarks: Remarks) {
        let insertStatementString = "INSERT INTO \(db_remarks)(SERVER_ID_PK, SQ_ID, HR_REMARKS, CREATED_DATE, CREATED_BY, MQ_ID, DQ_ID, MODULE_ID, REMARKS_TYPE, SYNC_DATE) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {

            sqlite3_bind_int(insertStatement, 1, Int32(remarks.remID ?? -1))
            sqlite3_bind_int(insertStatement, 2, Int32(remarks.sqID ?? -1))
            sqlite3_bind_text(insertStatement, 3, ((remarks.hrRemarks ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, ((remarks.createdDate ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 5, ((remarks.createdBy ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 6, Int32(remarks.mqID ?? -1))
            sqlite3_bind_int(insertStatement, 7, Int32(remarks.dqID ?? -1))
            sqlite3_bind_int(insertStatement, 8, Int32(remarks.moduleID ?? -1))
            sqlite3_bind_text(insertStatement, 9, ((remarks.remarksType ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 10, ((remarks.syncDate ?? "") as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                //print("\(db_remarks): Successfully inserted row.")
            } else {
                print("\(db_remarks): Could not insert row.")
            }
        } else {
            print("\(db_remarks): INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    func read_tbl_Remarks(mq_id: Int, dq_id: Int, remarks_type: String) -> [tbl_Remarks]{
        let queryStatementString = "SELECT * FROM \(db_remarks) WHERE MQ_ID = '\(mq_id)' AND DQ_ID = '\(dq_id)' AND REMARKS_TYPE = '\(remarks_type)';"
        var queryStatement: OpaquePointer? = nil
        var tbl_remarks: [tbl_Remarks] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let server_id_pk = Int(sqlite3_column_int(queryStatement, 1))
                let sq_id = Int(sqlite3_column_int(queryStatement, 2))
                let hr_remarks = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                let created_date = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                let created_by = String(describing: String(cString: sqlite3_column_text(queryStatement, 5)))
                let mq_id = Int(sqlite3_column_int(queryStatement, 6))
                let dq_id = Int(sqlite3_column_int(queryStatement, 7))
                let module_id = Int(sqlite3_column_int(queryStatement, 8))
                let remarks_type = String(describing: String(cString: sqlite3_column_text(queryStatement, 9)))
                let sync_date = String(describing: String(cString: sqlite3_column_text(queryStatement, 9)))
                
                tbl_remarks.append(tbl_Remarks(ID: id, SERVER_ID_PK: server_id_pk, SQ_ID: sq_id, HR_REMARKS: hr_remarks, CREATED_DATE: created_date, CREATED_BY: created_by, MQ_ID: mq_id, DQ_ID: dq_id, MODULE_ID: module_id, REMARKS_TYPE: remarks_type, SYNC_DATE: sync_date))
            }
        } else {
            print("SELECT statement \(db_remarks) could not be prepared")
        }
        return tbl_remarks
    }
    
    
    //MARK: QueryMatrix
    func insert_tbl_queryMatrix(querymatrix: QueryMatrix) {
        
        let insertStatementString = "INSERT INTO \(db_query_matrix)(SERVER_ID_PK, REGION, MASTER_QUERY, DETAIL_QUERY,PERSON_DESIG,LINE_MANAGER_DESIG,HEAD_DESIG,RESPONSIBILITY,LINE_MANAGER,HEAD,MQ_ID,DQ_ID,CREATED_BY,CREATED_DATE,ESCLATE_DAY,RESPONSIBLE_EMPNO,MANAGER_EMPNO,HEAD_EMPNO,DIRECTOR_EMPNO,COLOUR_CODE,AREA,MODULE_ID,SYNC_DATE) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(insertStatement, 1, Int32(querymatrix.matID ?? -1))
            sqlite3_bind_text(insertStatement, 2, ((querymatrix.region ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, ((querymatrix.masterQuery ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, ((querymatrix.detailQuery ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 5, ((querymatrix.personDesig ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 6, ((querymatrix.lineManagerDesig ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 7, ((querymatrix.headDesig ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 8, ((querymatrix.responsibility ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 9, ((querymatrix.lineManager ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 10, ((querymatrix.head ?? "") as NSString).utf8String, -1, nil)
            
            sqlite3_bind_int(insertStatement, 11, Int32(querymatrix.mqID ?? -1))
            sqlite3_bind_int(insertStatement, 12, Int32(querymatrix.dqID ?? -1))
            sqlite3_bind_text(insertStatement, 13, ((querymatrix.createdBy ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 14, ((querymatrix.createdDate ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 15, Int32(querymatrix.esclateDay ?? -1))
            sqlite3_bind_int(insertStatement, 16, Int32(querymatrix.responsibleEmpno ?? -1))
            sqlite3_bind_int(insertStatement, 17, Int32(querymatrix.managerEmpno ?? -1))
            sqlite3_bind_int(insertStatement, 18, Int32(querymatrix.headEmpno ?? -1))
            sqlite3_bind_int(insertStatement, 19, Int32(querymatrix.directorEmpno ?? -1))
            sqlite3_bind_text(insertStatement, 20, ((querymatrix.colourCode ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 21, ((querymatrix.area ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 22, Int32(querymatrix.moduleID ?? -1))
            sqlite3_bind_text(insertStatement, 23, ((querymatrix.syncDate ?? "") as NSString).utf8String, -1, nil)
            
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                //print("\(db_query_matrix): Successfully inserted row.")
            } else {
                print("\(db_query_matrix): Could not insert row.")
            }
        } else {
            print("\(db_query_matrix): INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    func read_tbl_queryMatrix(mq_id: Int, dq_id: Int, area: String?) -> [tbl_QueryMatrix]{
        var queryStatementString = ""
        if area == nil {
            queryStatementString = "SELECT * FROM \(db_query_matrix) WHERE MQ_ID = '\(mq_id)' AND DQ_ID = '\(dq_id)';"
        } else {
            queryStatementString = "SELECT * FROM \(db_query_matrix) WHERE MQ_ID = '\(mq_id)' AND DQ_ID = '\(dq_id)' AND AREA = '\(area!)';"
        }
        var queryStatement: OpaquePointer? = nil
        var tbl_querymatrix: [tbl_QueryMatrix] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let server_id_pk = Int(sqlite3_column_int(queryStatement, 1))
                let region = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))//String,
                let master_query = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))//String,
                let detail_query = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))//String,
                let person_design = String(describing: String(cString: sqlite3_column_text(queryStatement, 5)))//String,
                let line_manager_desig = String(describing: String(cString: sqlite3_column_text(queryStatement, 6)))//String,
                let head_desig = String(describing: String(cString: sqlite3_column_text(queryStatement, 7)))//String,
                let responsibility = String(describing: String(cString: sqlite3_column_text(queryStatement, 8)))//String,
                let line_manager = String(describing: String(cString: sqlite3_column_text(queryStatement, 9)))//String,
                let head = String(describing: String(cString: sqlite3_column_text(queryStatement, 10)))//String,
                let mq_id = Int(sqlite3_column_int(queryStatement, 11))//Int,
                let dq_id = Int(sqlite3_column_int(queryStatement, 12))//Int,
                let created_by = String(describing: String(cString: sqlite3_column_text(queryStatement, 13)))//String,
                let created_date = String(describing: String(cString: sqlite3_column_text(queryStatement, 14)))//String,
                let escalate_day = Int(sqlite3_column_int(queryStatement, 15))//Int,
                let responsible_empno = Int(sqlite3_column_int(queryStatement, 16))//Int,
                let manager_empno = Int(sqlite3_column_int(queryStatement, 17))//Int,
                let head_empno = Int(sqlite3_column_int(queryStatement, 18))//Int,
                let director_empno = Int(sqlite3_column_int(queryStatement, 19))//Int,
                let colour_code = String(describing: String(cString: sqlite3_column_text(queryStatement, 20)))//String,
                let area = String(describing: String(cString: sqlite3_column_text(queryStatement, 21)))//String,
                let module_id = Int(sqlite3_column_int(queryStatement, 22))//Int,
                let sync_date = String(describing: String(cString: sqlite3_column_text(queryStatement, 23)))//String
                
                
                tbl_querymatrix.append(tbl_QueryMatrix(ID: id, SERVER_ID_PK: server_id_pk, REGION: region, MASTER_QUERY: master_query, DETAIL_QUERY: detail_query, PERSON_DESIG: person_design, LINE_MANAGER_DESIG: line_manager_desig, HEAD_DESIG: head_desig, RESPONSIBILITY: responsibility, LINE_MANAGER: line_manager, HEAD: head, MQ_ID: mq_id, DQ_ID: dq_id, CREATED_BY: created_by, CREATED_DATE: created_date, ESCLATE_DAY: escalate_day, RESPONSIBLE_EMPNO: responsible_empno, MANAGER_EMPNO: manager_empno, HEAD_EMPNO: head_empno, DIRECTOR_EMPNO: director_empno, COLOUR_CODE: colour_code, AREA: area, MODULE_ID: module_id, SYNC_DATE: sync_date))
            }
        } else {
            print("SELECT statement \(db_query_matrix) could not be prepared")
        }
        return tbl_querymatrix
    }
    
    //MARK: Master_Query
    func insert_tbl_masterQuery(masterquery: MasterQuery) {
        let insertStatementString = "INSERT INTO \(db_master_query)(SERVER_ID_PK, MQ_DESC, CREATED_BY, CREATED_DATE, COLOR_CODE, MODULE_ID, SYNC_DATE) VALUES (?,?,?,?,?,?,?);"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(insertStatement, 1, Int32(masterquery.mqID ?? -1))
            sqlite3_bind_text(insertStatement, 2, ((masterquery.mqDesc ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, ((masterquery.createdBy ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, ((masterquery.createdDate ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 5, ((masterquery.colorCode ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 6, Int32(masterquery.moduleID ?? -1))
            sqlite3_bind_text(insertStatement, 7, ((masterquery.syncDate ?? "") as NSString).utf8String, -1, nil)
            
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                //print("\(db_master_query): Successfully inserted row.")
            } else {
                print("\(db_master_query): Could not insert row.")
            }
        } else {
            print("\(db_master_query): INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    func read_tbl_masterQuery(module_id: Int) -> [tbl_MasterQuery]{
        let queryStatementString = "select * from \(db_master_query) where module_id = '\(module_id)'"// ORDER BY server_id_pk DESC"
        var queryStatement: OpaquePointer? = nil
        var tbl_masterquery: [tbl_MasterQuery] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let server_id_pk = Int(sqlite3_column_int(queryStatement, 1))
                let mq_desc = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))//String,
                let created_by = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))//String,
                let created_date = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))//String,
                let color_code = String(describing: String(cString: sqlite3_column_text(queryStatement, 5)))//String,
                let module_id = Int(sqlite3_column_int(queryStatement, 6))//Int,
                let sync_date = String(describing: String(cString: sqlite3_column_text(queryStatement, 7)))//String
                
                tbl_masterquery.append(tbl_MasterQuery(ID: id, SERVER_ID_PK: server_id_pk, MQ_DESC: mq_desc, CREATED_BY: created_by, CREATED_DATE: created_date, COLOUR_CODE: color_code, MODULE_ID: module_id, SYNC_DATE: sync_date))
            }
        } else {
            print("SELECT statement \(db_master_query) could not be prepared")
        }
        return tbl_masterquery
    }
    
    
    //MARK: Detail Query
    func insert_tbl_detailQuery(detailquery: DetailQuery) {
        let insertStatementString = "INSERT INTO \(db_detail_query)(SERVER_ID_PK, MQ_ID, DQ_DESC, CREATED_BY, CREATED_DATE, COLOR_CODE, ESCLATE_DAY, SYNC_DATE, DQ_UNIQ_ID) VALUES (?,?,?,?,?,?,?,?,?);"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_int(insertStatement, 1, Int32(detailquery.dqUniqID ?? -1))
            sqlite3_bind_int(insertStatement, 2, Int32(detailquery.mqID ?? -1))
            sqlite3_bind_text(insertStatement, 3, ((detailquery.dqDesc ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, ((detailquery.createdBy ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 5, ((detailquery.createDate ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 6, ((detailquery.colorCode ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 7, Int32(detailquery.esclateDay ?? -1))
            sqlite3_bind_text(insertStatement, 8, ((detailquery.syncDate ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 9, Int32(detailquery.dqID ?? -1))
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                //print("\(db_detail_query): Successfully inserted row.")
            } else {
                print("\(db_detail_query): Could not insert row.")
            }
        } else {
            print("\(db_detail_query): INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    func read_tbl_detailQuery(master_query_id: Int) -> [tbl_DetailQuery]{
        let queryStatementString = "SELECT * FROM \(db_detail_query) WHERE mq_id = '\(master_query_id)'" //ORDER BY server_id_pk desc ;"
        var queryStatement: OpaquePointer? = nil
        var tbl_detailquery: [tbl_DetailQuery] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let server_id_pk = Int(sqlite3_column_int(queryStatement, 1))
                let mq_id = Int(sqlite3_column_int(queryStatement, 2))
                let dq_desc = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                let created_by = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                let created_date = String(describing: String(cString: sqlite3_column_text(queryStatement, 5)))
                let color_code = String(describing: String(cString: sqlite3_column_text(queryStatement, 6)))
                let esclate_date = Int(sqlite3_column_int(queryStatement, 7))
                let sync_date = String(describing: String(cString: sqlite3_column_text(queryStatement, 8)))
                let dq_uniq_id = Int(sqlite3_column_int(queryStatement, 9))
                
                tbl_detailquery.append(tbl_DetailQuery(ID: id, SERVER_ID_PK: server_id_pk, MQ_ID: mq_id, DQ_DESC: dq_desc, CREATED_BY: created_by, CREATED_DATE: created_date, COLOUR_CODE: color_code, ESCLATE_DAY: esclate_date, SYNC_DATE: sync_date, DQ_UNIQ_ID: dq_uniq_id))
            }
        } else {
            print("SELECT statement \(db_detail_query) could not be prepared")
        }
        return tbl_detailquery
    }
    
    //MARK: Search Keywords
//    func insert_tbl_serachKeywords(server_id_pk: Int, keyword: String, page_id: Int, module_id: Int, sync_date: String) {
    func insert_tbl_serachKeywords(searchkeywords: SearchKeyword) {
        
        let insertStatementString = "INSERT INTO \(db_search_keywords)(SERVER_ID_PK, KEYWORD, PAGE_ID, MODULE_ID, SYNC_DATE) VALUES (?,?,?,?,?);"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(insertStatement, 1, Int32(searchkeywords.keywordID ?? -1))
            sqlite3_bind_text(insertStatement, 2, ((searchkeywords.keyword ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 3, Int32(searchkeywords.pageID ?? -1))
            sqlite3_bind_int(insertStatement, 4, Int32(searchkeywords.moduleID ?? -1))
            sqlite3_bind_text(insertStatement, 5, ((searchkeywords.syncDate ?? "") as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                //print("\(db_search_keywords): Successfully inserted row.")
            } else {
                print("\(db_search_keywords): Could not insert row.")
            }
        } else {
            print("\(db_search_keywords): INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    func read_tbl_searchKeywords() -> [tbl_SearchKeywords]{
        let queryStatementString = "SELECT * FROM \(db_search_keywords);"
        var queryStatement: OpaquePointer? = nil
        var tbl_searchkeywords: [tbl_SearchKeywords] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let server_id_pk = Int(sqlite3_column_int(queryStatement, 1))
                let keyword = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let page_id = Int(sqlite3_column_int(queryStatement, 3))
                let module_id = Int(sqlite3_column_int(queryStatement, 4))
                let sync_date = String(describing: String(cString: sqlite3_column_text(queryStatement, 5)))
                
                
                tbl_searchkeywords.append(tbl_SearchKeywords(ID: id, SERVER_ID_PK: server_id_pk, KEYWORD: keyword, PAGE_ID: page_id, MODULE_ID: module_id, SYNC_DATE: sync_date))
            }
        } else {
            print("SELECT statement \(db_search_keywords) could not be prepared")
        }
        return tbl_searchkeywords
    }
    
    //MARK: Request Modes
    func insert_tbl_requestModes(apprequestmode: AppRequestMode) {
        
        let insertStatementString = "INSERT INTO \(db_request_modes)(SERVER_ID_PK, REQ_MODE_DESC, CREATED_BY, CREATED_DATE, MODULE_ID) VALUES (?,?,?,?,?);"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(insertStatement, 1, Int32(apprequestmode.reqModeID ?? -1))
            sqlite3_bind_text(insertStatement, 2, ((apprequestmode.reqModeDesc ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, ((apprequestmode.createdBy ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, ((apprequestmode.createdDate ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 5, Int32(apprequestmode.moduleid ?? -1))
            
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                //print("\(db_request_modes): Successfully inserted row.")
            } else {
                print("\(db_request_modes): Could not insert row.")
            }
        } else {
            print("\(db_request_modes): INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    func read_tbl_requestModes(module_id: Int) -> [tbl_RequestModes]{
        let queryStatementString = "SELECT * FROM \(db_request_modes) where module_id = '\(module_id)';"
        var queryStatement: OpaquePointer? = nil
        var tbl_requestmodes: [tbl_RequestModes] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let server_id_pk = Int(sqlite3_column_int(queryStatement, 1))
                let req_mode_desc = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let created_by = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                let created_date = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                let module_id = Int(sqlite3_column_int(queryStatement, 5))
                
                tbl_requestmodes.append(tbl_RequestModes(ID: id, SERVER_ID_PK: server_id_pk, REQ_MODE_DESC: req_mode_desc, CREATED_BY: created_by, CREATED_DATE: created_date, MODULE_ID: module_id))
            }
        } else {
            print("SELECT statement \(db_request_modes) could not be prepared")
        }
        return tbl_requestmodes
    }
    
    
    func update_tbl_hr_request(H: HrRequest,  _ handler: @escaping(_ success: Bool) -> Void) {
        let updateStatementString = "UPDATE \(db_hr_request) SET TICKET_STATUS = '\(H.ticketStatus!)', REQUEST_LOGS_SYNC_STATUS = '\(1)'  WHERE SERVER_ID_PK = '\(H.ticketID!)';"
        var updateStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("\(db_hr_request): Successfully updated row.")
                handler(true)
            } else {
                handler(false)
                print("\(db_hr_request): Could not update row.")
            }
        } else {
            handler(false)
            print("\(db_hr_request): UPDATE statement could not be prepared")
        }
        sqlite3_finalize(updateStatement)
    }
    func insert_tbl_hr_request(hrrequests: HrRequest, _ handler: @escaping(_ success: Bool) -> Void) {
        let insertStatementString = "INSERT INTO \(db_hr_request)(SERVER_ID_PK, TICKET_DATE, LOGIN_ID, REQ_ID, REQ_MODE, MAT_ID, MQ_ID, DQ_ID, TICKET_STATUS, CREATED_DATE, CREATED_BY, REQ_REMAKS, HR_REMARKS, UPDATED_DATE, UPDATED_BY, REQ_EMAIL_LOG, REQ_EMAIL_LOG_TIME, REQ_EMAIL_STATUS, REQ_EMAIL_STATUS_TIME, TAT_DAYS, REM_TAT_STATUS, REM_TAT_STATUS_TIME, ASSIGNED_TO, REF_ID, AREA_CODE, STATION_CODE, HUB_CODE, EMP_NAME, RESPONSIBILITY, RESPONSIBLE_EMPNO, CURR_PHONE_01, PERSON_DESIG, MASTER_QUERY, DETAIL_QUERY, ESCALATE_DAYS, REQUEST_LOGS_SYNC_STATUS, REQ_MODE_DESC, REQUEST_LOGS_LATITUDE, MODULE_ID, HRBP_EXISTS, REQUEST_LOGS_LONGITUDE, CURRENT_USER, REQ_CASE_DESC, HR_CASE_DESC, INCIDENT_TYPE, CNSGNO, CLASSIFICATION, CITY, AREA, INCIDENT_DATE, DEPARTMENT, IS_FINANCIAL, AMOUNT, LOV_MASTER, LOV_DETAIL, LOV_SUBDETAIL, IS_EMP_RELATED , RECOVERY_TYPE, AREA_SEC_EMP_NO, DETAILED_INVESTIGATION, PROSECUTION_NARRATIVE, DEFENSE_NARRATIVE, CHALLENGES, FACTS, FINDINGS, OPINION, HO_SEC_SUMMARY, HO_SEC_RECOM, DIR_SEC_ENDOR, DIR_SEC_RECOM, IS_INS_CLAIMABLE, INS_CLAIM_REFNO, IS_INS_CLAIM_PROCESS, INS_CLAIMED_AMOUNT, HR_REF_NO, HR_STATUS, FINANCE_GL_NO, IS_CONTROL_DEFINED, RISK_REMARKS, RISK_TYPE, CONTROL_CATEGORY, CONTROL_TYPE, LINE_MANAGER1, LINE_MANAGER2, DIR_NOTIFY_EMAILS, SEC_AREA, IS_INVESTIGATION, CONTROLLER_RECOM, PREVIOUS_TICKET_STATUS, VIEW_COUNT, DESIG_NAME) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(insertStatement, 1, Int32(hrrequests.ticketID ?? -1))
            
            sqlite3_bind_text(insertStatement, 2, ((hrrequests.ticketDate ?? "") as NSString).utf8String, -1, nil)
            
            sqlite3_bind_int(insertStatement, 3, Int32(hrrequests.loginID ?? -1))
            sqlite3_bind_int(insertStatement, 4, Int32(hrrequests.reqID ?? -1))
            sqlite3_bind_int(insertStatement, 5, Int32(hrrequests.reqMode ?? -1))
            sqlite3_bind_int(insertStatement, 6, Int32(hrrequests.matID ?? -1))
            sqlite3_bind_int(insertStatement, 7, Int32(hrrequests.mqID ?? -1))
            sqlite3_bind_int(insertStatement, 8, Int32(hrrequests.dqID ?? -1))
            
            sqlite3_bind_text(insertStatement, 9, ((hrrequests.ticketStatus ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 10, ((hrrequests.createdDate ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 11, ((hrrequests.createdBy ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 12, ((hrrequests.reqRemaks ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 13, ((hrrequests.hrRemarks ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 14, ((hrrequests.updatedDate ?? "") as NSString).utf8String, -1, nil)
            
            sqlite3_bind_int(insertStatement, 15, Int32(hrrequests.updatedBy ?? -1))
            
            sqlite3_bind_text(insertStatement, 16, ((hrrequests.reqEmailLog ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 17, ((hrrequests.reqEmailLogTime ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 18, ((hrrequests.reqEmailStatus ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 19, ((hrrequests.reqEmailStatusTime ?? "") as NSString).utf8String, -1, nil)
            
            sqlite3_bind_int(insertStatement, 20, Int32(hrrequests.tatDays ?? -1))
            
            sqlite3_bind_text(insertStatement, 21, ((hrrequests.remTatStatus ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 22, ((hrrequests.remTatStatusTime ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 23, Int32(hrrequests.assignedTo ?? -1))
            sqlite3_bind_text(insertStatement, 24, ((hrrequests.refID ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 25, ((hrrequests.areaCode ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 26, ((hrrequests.stationCode ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 27, ((hrrequests.hubCode ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 28, ((hrrequests.requesterName ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 29, ((hrrequests.responsibleName ?? "") as NSString).utf8String, -1, nil)
            
            sqlite3_bind_int(insertStatement, 30, Int32(hrrequests.responsibleEmpno ?? -1))
            
            sqlite3_bind_text(insertStatement, 31, ((hrrequests.requesterPhone ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 32, ((hrrequests.responsibleDesig ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 33, ((hrrequests.masterQuery ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 34, ((hrrequests.detailQuery ?? "") as NSString).utf8String, -1, nil)
            
            sqlite3_bind_int(insertStatement, 35, Int32(hrrequests.escalateDays ?? -1))
            sqlite3_bind_int(insertStatement, 36, Int32(1))//sync date
            
            sqlite3_bind_text(insertStatement, 37, ((hrrequests.reqModeDesc ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 38, ((hrrequests.latitude ?? "") as NSString).utf8String, -1, nil)
            
            sqlite3_bind_int(insertStatement, 39, Int32(hrrequests.moduleID ?? -1))
            
            sqlite3_bind_int(insertStatement, 40, Int32(hrrequests.hrbpExist ?? -1)) //HRBP Exist
            sqlite3_bind_text(insertStatement, 41, ((hrrequests.longitude ?? "") as NSString).utf8String, -1, nil)
            
            sqlite3_bind_int(insertStatement, 42, Int32(Int(CURRENT_USER_LOGGED_IN_ID) ?? 0))//CURRENT USER
            sqlite3_bind_text(insertStatement, 43, ((hrrequests.reqCaseDesc ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 44, ((hrrequests.hrCaseDesc ?? "") as NSString).utf8String, -1, nil)
            
            //IMS FIELDS
            sqlite3_bind_text(insertStatement, 45, ((hrrequests.incidentType ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 46, ((hrrequests.cnsgNo ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 47, ((hrrequests.classification ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 48, ((hrrequests.city ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 49, ((hrrequests.area ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 50, ((hrrequests.incidentDate ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 51, ((hrrequests.department ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 52, Int32(hrrequests.isFinancial ?? -1))
            
            let amount = String(hrrequests.amount ?? 0.0)
            sqlite3_bind_text(insertStatement, 53, (amount as NSString).utf8String, -1, nil)
            
            sqlite3_bind_int(insertStatement, 54, Int32(hrrequests.lovMasterVal ?? -1))
            sqlite3_bind_int(insertStatement, 55, Int32(hrrequests.lovDetailVal ?? -1))
            sqlite3_bind_int(insertStatement, 56, Int32(hrrequests.lovSubdetailVal ?? -1))
            sqlite3_bind_int(insertStatement, 57, Int32(hrrequests.isEmpRelated ?? -1))
            
            sqlite3_bind_text(insertStatement, 58, ((hrrequests.recoveryType ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 59, Int32(hrrequests.areaSECEmpno ?? -1))
            sqlite3_bind_text(insertStatement, 60, ((hrrequests.detailedInvestigation ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 61, ((hrrequests.prosecutionNarrative ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 62, ((hrrequests.defenseNarrative ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 63, ((hrrequests.challenges ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 64, ((hrrequests.facts ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 65, ((hrrequests.findings ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 66, ((hrrequests.opinion ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 67, ((hrrequests.hoSECSummary ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 68, ((hrrequests.hoSECRecom ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 69, ((hrrequests.dirSECEndors ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 70, ((hrrequests.dirSECRecom ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 71, Int32(hrrequests.isInsClaimable ?? -1))
            sqlite3_bind_text(insertStatement, 72, ((hrrequests.insClaimRefNo ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 73, Int32(hrrequests.isInsClaimProcess ?? -1))
            
            let insClaimedAmount = String(hrrequests.insClaimedAmt ?? 0.0)
            sqlite3_bind_text(insertStatement, 74, ((insClaimedAmount) as NSString).utf8String, -1, nil)
            
            sqlite3_bind_text(insertStatement, 75, ((hrrequests.hrRefNo ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 76, ((hrrequests.hrStatus ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 77, ((hrrequests.financeGlNo ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 78, Int32(hrrequests.isControlDefined ?? -1))
            sqlite3_bind_text(insertStatement, 79, ((hrrequests.riskRemarks ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 80, ((hrrequests.riskType ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 81, ((hrrequests.controlCategory ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 82, ((hrrequests.controlType ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 83, Int32(hrrequests.lineManager1 ?? -1))
            sqlite3_bind_int(insertStatement, 84, Int32(hrrequests.lineManager2 ?? -1))
            sqlite3_bind_text(insertStatement, 85, ((hrrequests.dirNotifyEmails ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 86, ((hrrequests.secArea ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 87, Int32(hrrequests.isInvestigation ?? -1))
            sqlite3_bind_text(insertStatement, 88, ("" as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 89, ("" as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 90, Int32(hrrequests.viewCount ?? -1))
            sqlite3_bind_text(insertStatement, 91, ((hrrequests.desigName ?? "") as NSString).utf8String, -1, nil)
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                handler(true)
            } else {
                print("\(db_hr_request): Could not insert row.")
                handler(false)
            }
        } else {
            handler(false)
            print("\(db_hr_request): INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    func read_tbl_hr_request(ticketId: Int) -> [tbl_Hr_Request_Logs]{
        let queryStatementString = "SELECT * FROM \(db_hr_request) WHERE SERVER_ID_PK = '\(ticketId)';"
        var queryStatement: OpaquePointer? = nil
        var tbl_hr_request_logs: [tbl_Hr_Request_Logs] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let server_id_pk = Int(sqlite3_column_int(queryStatement, 1))
                
                let ticket_date = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                
                let login_id = Int(sqlite3_column_int(queryStatement, 3))
                let req_id = Int(sqlite3_column_int(queryStatement, 4))
                let req_mode = Int(sqlite3_column_int(queryStatement, 5))
                let mat_id = Int(sqlite3_column_int(queryStatement, 6))
                let mq_id = Int(sqlite3_column_int(queryStatement, 7))
                let dq_id = Int(sqlite3_column_int(queryStatement, 8))
                
                let ticket_status = String(describing: String(cString: sqlite3_column_text(queryStatement, 9)))
                let created_date = String(describing: String(cString: sqlite3_column_text(queryStatement, 10)))
                let created_by = String(describing: String(cString: sqlite3_column_text(queryStatement, 11)))
                let req_remakes = String(describing: String(cString: sqlite3_column_text(queryStatement, 12)))
                let hr_remarks = String(describing: String(cString: sqlite3_column_text(queryStatement, 13)))
                let updated_date = String(describing: String(cString: sqlite3_column_text(queryStatement, 14)))
                
                let update_by = Int(sqlite3_column_int(queryStatement, 15))
                
                let req_email_log = String(describing: String(cString: sqlite3_column_text(queryStatement, 16)))
                let req_email_log_time = String(describing: String(cString: sqlite3_column_text(queryStatement, 17)))
                let req_email_status = String(describing: String(cString: sqlite3_column_text(queryStatement, 18)))
                let req_email_status_time = String(describing: String(cString: sqlite3_column_text(queryStatement, 19)))
                
                let tat_day = Int(sqlite3_column_int(queryStatement, 20))
                
                
                let rem_tat_status = String(describing: String(cString: sqlite3_column_text(queryStatement, 21)))
                let rem_tat_status_time = String(describing: String(cString: sqlite3_column_text(queryStatement, 22)))
                let assigne_to = Int(sqlite3_column_int(queryStatement, 23))
                let ref_id = String(describing: String(cString: sqlite3_column_text(queryStatement, 24)))
                let area_code = String(describing: String(cString: sqlite3_column_text(queryStatement, 25)))
                let station_code = String(describing: String(cString: sqlite3_column_text(queryStatement, 26)))
                let hub_code = String(describing: String(cString: sqlite3_column_text(queryStatement, 27)))
                let requester_name = String(describing: String(cString: sqlite3_column_text(queryStatement, 28)))
                let responsible_name = String(describing: String(cString: sqlite3_column_text(queryStatement, 29)))
                
                let responsible_empno = Int(sqlite3_column_int(queryStatement, 30))
                
                let requester_phone = String(describing: String(cString: sqlite3_column_text(queryStatement, 31)))
                let responsible_desig = String(describing: String(cString: sqlite3_column_text(queryStatement, 32)))
                let master_query = String(describing: String(cString: sqlite3_column_text(queryStatement, 33)))
                let detail_query = String(describing: String(cString: sqlite3_column_text(queryStatement, 34)))
                
                let escalate_days = Int(sqlite3_column_int(queryStatement, 35))
                let sync_date = Int(sqlite3_column_int(queryStatement, 36))
                
                let req_mode_desc = String(describing: String(cString: sqlite3_column_text(queryStatement, 37)))
                let latitude = String(describing: String(cString: sqlite3_column_text(queryStatement, 38)))
                
                let module_id = Int(sqlite3_column_int(queryStatement, 39))
                
                let hrbp_exist = Int(sqlite3_column_int(queryStatement, 40)) //String(describing: String(cString: sqlite3_column_text(queryStatement, 40)))//
                let longitude = String(describing: String(cString: sqlite3_column_text(queryStatement, 41)))
                
                let current_user = Int(CURRENT_USER_LOGGED_IN_ID)!
                
                let req_case_desc = String(describing: String(cString: sqlite3_column_text(queryStatement, 43)))
                
                let hr_case_desc = String(describing: String(cString: sqlite3_column_text(queryStatement, 44)))
                
                //IMS KEYS
                let incident_type = String(describing: String(cString: sqlite3_column_text(queryStatement, 45)))
                let cnsgno = String(describing: String(cString: sqlite3_column_text(queryStatement, 46)))
                let classification = String(describing: String(cString: sqlite3_column_text(queryStatement, 47)))
                let city = String(describing: String(cString: sqlite3_column_text(queryStatement, 48)))
                let area = String(describing: String(cString: sqlite3_column_text(queryStatement, 49)))
                let incident_date = String(describing: String(cString: sqlite3_column_text(queryStatement, 50)))
                let department = String(describing: String(cString: sqlite3_column_text(queryStatement, 51)))
                
                let is_financial = Int(sqlite3_column_int(queryStatement, 52))
                
                let loss_amount = String(describing: String(cString: sqlite3_column_text(queryStatement, 53)))
                
                let lov_master = Int(sqlite3_column_int(queryStatement, 54))
                let lov_detail = Int(sqlite3_column_int(queryStatement, 55))
                let lov_subdetail = Int(sqlite3_column_int(queryStatement, 56))
                let is_emp_related = Int(sqlite3_column_int(queryStatement, 57))
                
                let recovery_type = String(describing: String(cString: sqlite3_column_text(queryStatement, 58)))
                let area_sec_emp_no = Int(sqlite3_column_int(queryStatement, 59))
                
                let detailed_investigation = String(describing: String(cString: sqlite3_column_text(queryStatement, 60)))
                let prosecution_narrative = String(describing: String(cString: sqlite3_column_text(queryStatement, 61)))
                let defense_narrative = String(describing: String(cString: sqlite3_column_text(queryStatement, 62)))
                let challenges = String(describing: String(cString: sqlite3_column_text(queryStatement, 63)))
                let facts = String(describing: String(cString: sqlite3_column_text(queryStatement, 64)))
                let findings = String(describing: String(cString: sqlite3_column_text(queryStatement, 65)))
                let opinion = String(describing: String(cString: sqlite3_column_text(queryStatement, 66)))
                let ho_sec_summary = String(describing: String(cString: sqlite3_column_text(queryStatement, 67)))
                let ho_sec_recom = String(describing: String(cString: sqlite3_column_text(queryStatement, 68)))
                let dir_sec_endor = String(describing: String(cString: sqlite3_column_text(queryStatement, 69)))
                let dir_sec_recom = String(describing: String(cString: sqlite3_column_text(queryStatement, 70)))
                
                let is_ins_claimable = Int(sqlite3_column_int(queryStatement, 71))
                let ins_claim_refno = String(describing: String(cString: sqlite3_column_text(queryStatement, 72)))
                let is_ins_claim_process = Int(sqlite3_column_int(queryStatement, 73))
                let ins_claimed_amout = String(describing: String(cString: sqlite3_column_text(queryStatement, 74)))
                let hr_ref_no = String(describing: String(cString: sqlite3_column_text(queryStatement, 75)))
                let hr_status = String(describing: String(cString: sqlite3_column_text(queryStatement, 76)))
                let finance_gl_no = String(describing: String(cString: sqlite3_column_text(queryStatement, 77)))
                let is_control_defined = Int(sqlite3_column_int(queryStatement, 78))
                
                let risk_remarks = String(describing: String(cString: sqlite3_column_text(queryStatement, 79)))
                let risk_type = String(describing: String(cString: sqlite3_column_text(queryStatement, 80)))
                let control_category = String(describing: String(cString: sqlite3_column_text(queryStatement, 81)))
                let control_type = String(describing: String(cString: sqlite3_column_text(queryStatement, 82)))
                let line_manager_1 = Int(sqlite3_column_int(queryStatement, 83))
                let line_manager_2 = Int(sqlite3_column_int(queryStatement, 84))
                let dir_notify_emails = String(describing: String(cString: sqlite3_column_text(queryStatement, 85)))
                let sec_area = String(describing: String(cString: sqlite3_column_text(queryStatement, 86)))
                let is_investigation = Int(sqlite3_column_int(queryStatement, 87))
                _ = String(describing: String(cString: sqlite3_column_text(queryStatement, 88)))
                _ = String(describing: String(cString: sqlite3_column_text(queryStatement, 89)))
                let view_count = Int(sqlite3_column_int(queryStatement, 90))
                let desig_name = String(describing: String(cString: sqlite3_column_text(queryStatement, 91)))
                
                tbl_hr_request_logs.append(tbl_Hr_Request_Logs(ID: id, SERVER_ID_PK: server_id_pk, TICKET_DATE: ticket_date, LOGIN_ID: login_id, REQ_ID: req_id, REQ_MODE: req_mode, MAT_ID: mat_id, MQ_ID: mq_id, DQ_ID: dq_id, TICKET_STATUS: ticket_status, CREATED_DATE: created_date, CREATED_BY: created_by, REQ_REMARKS: req_remakes, HR_REMARKS: hr_remarks, UPDATED_DATE: updated_date, UPDATED_BY: String(update_by), REQ_EMAIL_LOG: req_email_log, REQ_EMAIL_LOG_TIME: req_email_log_time, REQ_EMAIL_STATUS: req_email_status, REQ_EMAIL_STATUS_TIME: req_email_status_time, TAT_DAYS: tat_day, REM_TAT_STATUS: rem_tat_status, REM_TAT_STATUS_TIME: rem_tat_status_time, ASSIGNED_TO: assigne_to, REF_ID: ref_id, AREA_CODE: area_code, STATION_CODE: station_code, HUB_CODE: hub_code, EMP_NAME: requester_name, RESPONSIBILITY: responsible_name, RESPONSIBLE_EMPNO: responsible_empno, CURR_PHONE_01: requester_phone, PERSON_DESIG: responsible_desig, MASTER_QUERY: master_query, DETAIL_QUERY: detail_query, ESCALATE_DAYS: escalate_days, REQUEST_LOGS_SYNC_STATUS: sync_date, REQ_MODE_DESC: req_mode_desc, REQUEST_LOGS_LATITUDE: latitude, MODULE_ID: module_id, HRBP_EXISTS: hrbp_exist, REQUEST_LOGS_LONGITUDE: longitude, CURRENT_USER: String(current_user), REQ_CASE_DESC: req_case_desc, HR_CASE_DESC: hr_case_desc, INCIDENT_TYPE: incident_type, CNSGNO: cnsgno, CLASSIFICATION: classification, CITY: city, AREA: area, INCIDENT_DATE: incident_date, DEPARTMENT: department, IS_FINANCIAL: is_financial, AMOUNT: Double(loss_amount), LOV_MASTER: lov_master, LOV_DETAIL: lov_detail, LOV_SUBDETAIL: lov_subdetail, IS_EMP_RELATED: is_emp_related, RECOVERY_TYPE: recovery_type, AREA_SEC_EMP_NO: area_sec_emp_no, DETAILED_INVESTIGATION: detailed_investigation, PROSECUTION_NARRATIVE: prosecution_narrative, DEFENSE_NARRATIVE: defense_narrative, CHALLENGES: challenges, FACTS: facts, FINDINGS: findings, OPINION: opinion, HO_SEC_SUMMARY: ho_sec_summary, HO_SEC_RECOM: ho_sec_recom, DIR_SEC_ENDOR: dir_sec_endor, DIR_SEC_RECOM: dir_sec_recom, IS_INS_CLAIMABLE: is_ins_claimable, INS_CLAIM_REFNO: ins_claim_refno, IS_INS_CLAIM_PROCESS: is_ins_claim_process, INS_CLAIMED_AMOUNT: Double(ins_claimed_amout), HR_REF_NO: hr_ref_no, HR_STATUS: hr_status, FINANCE_GL_NO: finance_gl_no, IS_CONTROL_DEFINED: is_control_defined, RISK_REMARKS: risk_remarks, RISK_TYPE: risk_type, CONTROL_CATEGORY: control_category, CONTROL_TYPE: control_type, LINE_MANAGER1: line_manager_1, LINE_MANAGER2: line_manager_2, DIR_NOTIFY_EMAILS: dir_notify_emails, SEC_AREA: sec_area, IS_INVESTIGATION: is_investigation, VIEW_COUNT: view_count,DESIG_NAME: desig_name))
            }
        } else {
            print("SELECT statement \(db_hr_request) could not be prepared")
        }
        return tbl_hr_request_logs
    }
    
    func read_tbl_hr_request(query: String) -> [tbl_Hr_Request_Logs]{
        let queryStatementString = query
        var queryStatement: OpaquePointer? = nil
        var tbl_hr_request_logs: [tbl_Hr_Request_Logs] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let server_id_pk = Int(sqlite3_column_int(queryStatement, 1))
                
                let ticket_date = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                
                let login_id = Int(sqlite3_column_int(queryStatement, 3))
                let req_id = Int(sqlite3_column_int(queryStatement, 4))
                let req_mode = Int(sqlite3_column_int(queryStatement, 5))
                let mat_id = Int(sqlite3_column_int(queryStatement, 6))
                let mq_id = Int(sqlite3_column_int(queryStatement, 7))
                let dq_id = Int(sqlite3_column_int(queryStatement, 8))
                
                let ticket_status = String(describing: String(cString: sqlite3_column_text(queryStatement, 9)))
                let created_date = String(describing: String(cString: sqlite3_column_text(queryStatement, 10)))
                let created_by = String(describing: String(cString: sqlite3_column_text(queryStatement, 11)))
                let req_remakes = String(describing: String(cString: sqlite3_column_text(queryStatement, 12)))
                let hr_remarks = String(describing: String(cString: sqlite3_column_text(queryStatement, 13)))
                let updated_date = String(describing: String(cString: sqlite3_column_text(queryStatement, 14)))
                
                let update_by = Int(sqlite3_column_int(queryStatement, 15))
                
                let req_email_log = String(describing: String(cString: sqlite3_column_text(queryStatement, 16)))
                let req_email_log_time = String(describing: String(cString: sqlite3_column_text(queryStatement, 17)))
                let req_email_status = String(describing: String(cString: sqlite3_column_text(queryStatement, 18)))
                let req_email_status_time = String(describing: String(cString: sqlite3_column_text(queryStatement, 19)))
                
                let tat_day = Int(sqlite3_column_int(queryStatement, 20))
                
                
                let rem_tat_status = String(describing: String(cString: sqlite3_column_text(queryStatement, 21)))
                let rem_tat_status_time = String(describing: String(cString: sqlite3_column_text(queryStatement, 22)))
                let assigne_to = Int(sqlite3_column_int(queryStatement, 23))
                let ref_id = String(describing: String(cString: sqlite3_column_text(queryStatement, 24)))
                let area_code = String(describing: String(cString: sqlite3_column_text(queryStatement, 25)))
                let station_code = String(describing: String(cString: sqlite3_column_text(queryStatement, 26)))
                let hub_code = String(describing: String(cString: sqlite3_column_text(queryStatement, 27)))
                let requester_name = String(describing: String(cString: sqlite3_column_text(queryStatement, 28)))
                let responsible_name = String(describing: String(cString: sqlite3_column_text(queryStatement, 29)))
                
                let responsible_empno = Int(sqlite3_column_int(queryStatement, 30))
                
                let requester_phone = String(describing: String(cString: sqlite3_column_text(queryStatement, 31)))
                let responsible_desig = String(describing: String(cString: sqlite3_column_text(queryStatement, 32)))
                let master_query = String(describing: String(cString: sqlite3_column_text(queryStatement, 33)))
                let detail_query = String(describing: String(cString: sqlite3_column_text(queryStatement, 34)))
                
                let escalate_days = Int(sqlite3_column_int(queryStatement, 35))
                let sync_date = Int(sqlite3_column_int(queryStatement, 36))
                
                let req_mode_desc = String(describing: String(cString: sqlite3_column_text(queryStatement, 37)))
                let latitude = String(describing: String(cString: sqlite3_column_text(queryStatement, 38)))
                
                let module_id = Int(sqlite3_column_int(queryStatement, 39))
                
                let hrbp_exist = Int(sqlite3_column_int(queryStatement, 40)) //String(describing: String(cString: sqlite3_column_text(queryStatement, 40)))//
                let longitude = String(describing: String(cString: sqlite3_column_text(queryStatement, 41)))
                
                let current_user = Int(CURRENT_USER_LOGGED_IN_ID)!
                
                let req_case_desc = String(describing: String(cString: sqlite3_column_text(queryStatement, 43)))
                
                let hr_case_desc = String(describing: String(cString: sqlite3_column_text(queryStatement, 44)))
                
                //IMS KEYS
                let incident_type = String(describing: String(cString: sqlite3_column_text(queryStatement, 45)))
                let cnsgno = String(describing: String(cString: sqlite3_column_text(queryStatement, 46)))
                let classification = String(describing: String(cString: sqlite3_column_text(queryStatement, 47)))
                let city = String(describing: String(cString: sqlite3_column_text(queryStatement, 48)))
                let area = String(describing: String(cString: sqlite3_column_text(queryStatement, 49)))
                let incident_date = String(describing: String(cString: sqlite3_column_text(queryStatement, 50)))
                let department = String(describing: String(cString: sqlite3_column_text(queryStatement, 51)))
                
                let is_financial = Int(sqlite3_column_int(queryStatement, 52))
                
                let loss_amount = String(describing: String(cString: sqlite3_column_text(queryStatement, 53)))
                
                let lov_master = Int(sqlite3_column_int(queryStatement, 54))
                let lov_detail = Int(sqlite3_column_int(queryStatement, 55))
                let lov_subdetail = Int(sqlite3_column_int(queryStatement, 56))
                let is_emp_related = Int(sqlite3_column_int(queryStatement, 57))
                
                let recovery_type = String(describing: String(cString: sqlite3_column_text(queryStatement, 58)))
                let area_sec_emp_no = Int(sqlite3_column_int(queryStatement, 59))
                
                let detailed_investigation = String(describing: String(cString: sqlite3_column_text(queryStatement, 60)))
                let prosecution_narrative = String(describing: String(cString: sqlite3_column_text(queryStatement, 61)))
                let defense_narrative = String(describing: String(cString: sqlite3_column_text(queryStatement, 62)))
                let challenges = String(describing: String(cString: sqlite3_column_text(queryStatement, 63)))
                let facts = String(describing: String(cString: sqlite3_column_text(queryStatement, 64)))
                let findings = String(describing: String(cString: sqlite3_column_text(queryStatement, 65)))
                let opinion = String(describing: String(cString: sqlite3_column_text(queryStatement, 66)))
                let ho_sec_summary = String(describing: String(cString: sqlite3_column_text(queryStatement, 67)))
                let ho_sec_recom = String(describing: String(cString: sqlite3_column_text(queryStatement, 68)))
                let dir_sec_endor = String(describing: String(cString: sqlite3_column_text(queryStatement, 69)))
                let dir_sec_recom = String(describing: String(cString: sqlite3_column_text(queryStatement, 70)))
                
                let is_ins_claimable = Int(sqlite3_column_int(queryStatement, 71))
                let ins_claim_refno = String(describing: String(cString: sqlite3_column_text(queryStatement, 72)))
                let is_ins_claim_process = Int(sqlite3_column_int(queryStatement, 73))
                let ins_claimed_amout = String(describing: String(cString: sqlite3_column_text(queryStatement, 74)))
                let hr_ref_no = String(describing: String(cString: sqlite3_column_text(queryStatement, 75)))
                let hr_status = String(describing: String(cString: sqlite3_column_text(queryStatement, 76)))
                let finance_gl_no = String(describing: String(cString: sqlite3_column_text(queryStatement, 77)))
                let is_control_defined = Int(sqlite3_column_int(queryStatement, 78))
                
                let risk_remarks = String(describing: String(cString: sqlite3_column_text(queryStatement, 79)))
                let risk_type = String(describing: String(cString: sqlite3_column_text(queryStatement, 80)))
                let control_category = String(describing: String(cString: sqlite3_column_text(queryStatement, 81)))
                let control_type = String(describing: String(cString: sqlite3_column_text(queryStatement, 82)))
                let line_manager_1 = Int(sqlite3_column_int(queryStatement, 83))
                let line_manager_2 = Int(sqlite3_column_int(queryStatement, 84))
                let dir_notify_emails = String(describing: String(cString: sqlite3_column_text(queryStatement, 85)))
                let sec_area = String(describing: String(cString: sqlite3_column_text(queryStatement, 86)))
                let is_investigation = Int(sqlite3_column_int(queryStatement, 87))
                _ = String(describing: String(cString: sqlite3_column_text(queryStatement, 88)))
                _ = String(describing: String(cString: sqlite3_column_text(queryStatement, 89)))
                let view_count = Int(sqlite3_column_int(queryStatement, 90))
                let desig_name = String(describing: String(cString: sqlite3_column_text(queryStatement, 91)))
                
                tbl_hr_request_logs.append(tbl_Hr_Request_Logs(ID: id, SERVER_ID_PK: server_id_pk, TICKET_DATE: ticket_date, LOGIN_ID: login_id, REQ_ID: req_id, REQ_MODE: req_mode, MAT_ID: mat_id, MQ_ID: mq_id, DQ_ID: dq_id, TICKET_STATUS: ticket_status, CREATED_DATE: created_date, CREATED_BY: created_by, REQ_REMARKS: req_remakes, HR_REMARKS: hr_remarks, UPDATED_DATE: updated_date, UPDATED_BY: String(update_by), REQ_EMAIL_LOG: req_email_log, REQ_EMAIL_LOG_TIME: req_email_log_time, REQ_EMAIL_STATUS: req_email_status, REQ_EMAIL_STATUS_TIME: req_email_status_time, TAT_DAYS: tat_day, REM_TAT_STATUS: rem_tat_status, REM_TAT_STATUS_TIME: rem_tat_status_time, ASSIGNED_TO: assigne_to, REF_ID: ref_id, AREA_CODE: area_code, STATION_CODE: station_code, HUB_CODE: hub_code, EMP_NAME: requester_name, RESPONSIBILITY: responsible_name, RESPONSIBLE_EMPNO: responsible_empno, CURR_PHONE_01: requester_phone, PERSON_DESIG: responsible_desig, MASTER_QUERY: master_query, DETAIL_QUERY: detail_query, ESCALATE_DAYS: escalate_days, REQUEST_LOGS_SYNC_STATUS: sync_date, REQ_MODE_DESC: req_mode_desc, REQUEST_LOGS_LATITUDE: latitude, MODULE_ID: module_id, HRBP_EXISTS: hrbp_exist, REQUEST_LOGS_LONGITUDE: longitude, CURRENT_USER: String(current_user), REQ_CASE_DESC: req_case_desc, HR_CASE_DESC: hr_case_desc, INCIDENT_TYPE: incident_type, CNSGNO: cnsgno, CLASSIFICATION: classification, CITY: city, AREA: area, INCIDENT_DATE: incident_date, DEPARTMENT: department, IS_FINANCIAL: is_financial, AMOUNT: Double(loss_amount), LOV_MASTER: lov_master, LOV_DETAIL: lov_detail, LOV_SUBDETAIL: lov_subdetail, IS_EMP_RELATED: is_emp_related, RECOVERY_TYPE: recovery_type, AREA_SEC_EMP_NO: area_sec_emp_no, DETAILED_INVESTIGATION: detailed_investigation, PROSECUTION_NARRATIVE: prosecution_narrative, DEFENSE_NARRATIVE: defense_narrative, CHALLENGES: challenges, FACTS: facts, FINDINGS: findings, OPINION: opinion, HO_SEC_SUMMARY: ho_sec_summary, HO_SEC_RECOM: ho_sec_recom, DIR_SEC_ENDOR: dir_sec_endor, DIR_SEC_RECOM: dir_sec_recom, IS_INS_CLAIMABLE: is_ins_claimable, INS_CLAIM_REFNO: ins_claim_refno, IS_INS_CLAIM_PROCESS: is_ins_claim_process, INS_CLAIMED_AMOUNT: Double(ins_claimed_amout), HR_REF_NO: hr_ref_no, HR_STATUS: hr_status, FINANCE_GL_NO: finance_gl_no, IS_CONTROL_DEFINED: is_control_defined, RISK_REMARKS: risk_remarks, RISK_TYPE: risk_type, CONTROL_CATEGORY: control_category, CONTROL_TYPE: control_type, LINE_MANAGER1: line_manager_1, LINE_MANAGER2: line_manager_2, DIR_NOTIFY_EMAILS: dir_notify_emails, SEC_AREA: sec_area, IS_INVESTIGATION: is_investigation, VIEW_COUNT: view_count,DESIG_NAME: desig_name))
            }
        } else {
            print("SELECT statement \(db_hr_request) could not be prepared")
        }
        return tbl_hr_request_logs
    }
    
    
    func insert_tbl_HR_Notification_Request(hnr: HRNotificationRequest, _ handler: @escaping(_ success: Bool) -> Void) {
        let insertStatementString = "INSERT INTO \(db_hr_notifications)(SERVER_ID_PK, NOTIFY_TYPE, NOTIFY_TITLE, TITLE_MESSAGE, CREATED_DATE, READ_STATUS, SENDING_STATUS, SEND_TO, MODULE_DSCRP, DESCRIPTION, MODULE_ID, READ_STATUS_DTTM, DEVICE_READ_DTTM, TICKET_ID, SR_NO, TICKET_STATUS, SYNC_STATUS, RECORD_ID) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_int(insertStatement, 1, Int32(hnr.ticketID ?? -1))
            sqlite3_bind_text(insertStatement, 2, ((hnr.notifyType ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, ((hnr.notifyTitle ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, ((hnr.titleMessage ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 5, ((hnr.createdDate ?? "") as NSString).utf8String, -1, nil)

            sqlite3_bind_int(insertStatement, 6, Int32(hnr.readStatus ?? -1))
            sqlite3_bind_int(insertStatement, 7, Int32(hnr.sendingStatus ?? -1))
            sqlite3_bind_int(insertStatement, 8, Int32(hnr.sendTo ?? -1))

            sqlite3_bind_text(insertStatement, 9, ((hnr.moduleDscrp ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 10, ((hnr.notificationRequestDESCRIPTION ?? "") as NSString).utf8String, -1, nil)

            sqlite3_bind_int(insertStatement, 11, Int32(hnr.moduleid ?? -1))

            sqlite3_bind_text(insertStatement, 12, ((hnr.readStatusDttm ?? "a") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 13, ((hnr.deviceReadDttm ?? "") as NSString).utf8String, -1, nil)

            sqlite3_bind_int(insertStatement, 14, Int32(hnr.ticketID ?? -1))
            sqlite3_bind_int(insertStatement, 15, Int32(hnr.srNo ?? -1))

            sqlite3_bind_text(insertStatement, 16, (("Not Provided") as NSString).utf8String, -1, nil)

            sqlite3_bind_int(insertStatement, 17, Int32(1))
            sqlite3_bind_int(insertStatement, 18, Int32(hnr.recordID ?? -1))
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                //print("\(db_hr_notifications): Successfully inserted row.")
                handler(true)
            } else {
                print("\(db_hr_notifications): Could not insert row.")
                handler(false)
            }
        } else {
            print("\(db_hr_notifications): INSERT statement could not be prepared.")
            handler(false)
        }
        sqlite3_finalize(insertStatement)
        
    }
    
    func read_tbl_hr_notification_request(query: String) -> [tbl_HR_Notification_Request]{
        let queryStatementString = query
        var queryStatement: OpaquePointer? = nil
        var tbl_hrnotificationrequest: [tbl_HR_Notification_Request] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let server_id_pk = Int(sqlite3_column_int(queryStatement, 1))
                
                let notify_type = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let notify_title = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                let title_message = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                let created_date = String(describing: String(cString: sqlite3_column_text(queryStatement, 5)))
                
                let read_status = Int(sqlite3_column_int(queryStatement, 6))
                let sending_status = Int(sqlite3_column_int(queryStatement, 7))
                let send_to = Int(sqlite3_column_int(queryStatement, 8))
                
                let model_desc = String(describing: String(cString: sqlite3_column_text(queryStatement, 9)))
                let noticiation_request_desc = String(describing: String(cString: sqlite3_column_text(queryStatement, 10)))
                
                let module_id = Int(sqlite3_column_int(queryStatement, 11))
                
                let read_status_dttm = String(describing: String(cString: sqlite3_column_text(queryStatement, 12)))
                let device_read_dttm = String(describing: String(cString: sqlite3_column_text(queryStatement, 13)))
                
                let ticket_id = Int(sqlite3_column_int(queryStatement, 14))
                let sr_no = Int(sqlite3_column_int(queryStatement, 15))
                
//                let ticket_status = String(describing: String(cString: sqlite3_column_text(queryStatement, 28)))
                
                let sync_status = Int(sqlite3_column_int(queryStatement, 17))
                let record_id = Int(sqlite3_column_int(queryStatement, 18))
    let ticket_status = String(describing: String(cString: sqlite3_column_text(queryStatement, 19)))
                let request_log = self.read_tbl_hr_request(query: "SELECT * FROM \(db_hr_request) WHERE CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)' AND SERVER_ID_PK = '\(server_id_pk)'")
                
                tbl_hrnotificationrequest.append(tbl_HR_Notification_Request(ID: id,
                                                                             SERVER_ID_PK: server_id_pk,
                                                                             NOTIFY_TYPE: notify_type,
                                                                             NOTIFY_TITLE: notify_title,
                                                                             TITLE_MESSAGE: title_message,
                                                                             CREATED_DATE: created_date,
                                                                             READ_STATUS: read_status,
                                                                             SENDING_STATUS: sending_status,
                                                                             SEND_TO: send_to,
                                                                             MODULE_DSCRP: model_desc,
                                                                             DESCRIPTION: noticiation_request_desc,
                                                                             MODULE_ID: module_id,
                                                                             READ_STATUS_DTTM: read_status_dttm,
                                                                             DEVICE_READ_DTTM: device_read_dttm,
                                                                             TICKET_ID: ticket_id,
                                                                             SR_NO: sr_no,
                                                                             TICKET_STATUS: ticket_status,
                                                                             SYNC_STATUS: sync_status,
                                                                             RECORD_ID: record_id,
                                                                             REQUEST_LOG: request_log))
            }
        } else {
            print("SELECT statement \(db_hr_notifications) could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return tbl_hrnotificationrequest
    }
    
    
    //MARK: GRAPH COUNTS...
    func getCounts(query: String) -> [GraphTotalCount]{
        let queryStatementString = query
        var queryStatement: OpaquePointer? = nil
        var graphTotalCount = [GraphTotalCount]()
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let ticket_status = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
                let ticket_total = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let ticket_date = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                
                graphTotalCount.append(GraphTotalCount(ticket_status: ticket_status ,
                                                       ticket_total: ticket_total ,
                                                       ticket_date: ticket_date))
            }
        } else {
            print("SELECT statement \(db_hr_request) could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return graphTotalCount
    }
    
    
    func getThreeMonthGraphs(startDate: String, endDate: String) -> [MultipleGraph]{
        let queryStatementString = "select TICKET_STATUS, count(ID) as ticketTotal, TICKET_DATE, ESCALATE_DAYS, UPDATED_DATE, CREATED_DATE from \(db_hr_request) WHERE module_id = '\(CONSTANT_MODULE_ID)' AND Created_Date >= '\(startDate)' AND Created_Date <= '\(endDate)' AND CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)' GROUP BY TICKET_STATUS;"
        var queryStatement: OpaquePointer? = nil
        var multipleGraphs = [MultipleGraph]()
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let ticket_status = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
                let ticket_total = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let ticket_date = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let escalate_days = Int(sqlite3_column_int(queryStatement, 3))
                let updated_date = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                let created_date = String(describing: String(cString: sqlite3_column_text(queryStatement, 5)))
                
                multipleGraphs.append(MultipleGraph(ticket_status: ticket_status,
                                                    ticket_total: ticket_total,
                                                    ticket_date: ticket_date,
                                                    escalate_days: escalate_days,
                                                    upated_date: updated_date,
                                                    created_date: created_date))
            }
        } else {
            print("SELECT statement \(db_hr_request) could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return multipleGraphs
    }
    
    func getDates(query: String) -> [String] {
        let queryStatementString = query
        var queryStatement: OpaquePointer? = nil
        var dates = [String]()
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let date = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
                dates.append(date)
            }
        } else {
            print("SELECT statement \(db_hr_request) could not be prepared")
        }
        
        sqlite3_finalize(queryStatement)
        return dates
    }
    
    func getTickets(query: String) -> [NSMutableDictionary] {
        let queryStatementString = query
        var queryStatement: OpaquePointer? = nil
        var tickets = [NSMutableDictionary]()
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let ticket = NSMutableDictionary()
                ticket.setValue(String(describing: String(cString: sqlite3_column_text(queryStatement, 0))), forKey: "TicketStatus")
                ticket.setValue("\(Int(sqlite3_column_int(queryStatement, 1)))", forKey: "TotalCount")
                ticket.setValue(String(describing: String(cString: sqlite3_column_text(queryStatement, 2))), forKey: "Date")
                
                tickets.append(ticket)
            }
        } else {
            print("SELECT statement \(db_hr_request) could not be prepared")
        }
        
        sqlite3_finalize(queryStatement)
        return tickets
    }
    
    
    
    func getBarGraphCounts(query: String) -> [GraphTotalCount]{
        let queryStatementString = query
        var queryStatement: OpaquePointer? = nil
        var graphTotalCount = [GraphTotalCount]()
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let ticket_status = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
                let ticket_total = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let ticket_date = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                
                graphTotalCount.append(GraphTotalCount(ticket_status: ticket_status ,
                                                       ticket_total: ticket_total ,
                                                       ticket_date: ticket_date))
            }
        } else {
            print("SELECT statement \(db_hr_request) could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return graphTotalCount
    }
    
    
    
    
    //MARK: Add New Request Query List
    func getRequestModeList(module_id: Int) -> [RequestModes]{
        let queryStatementString = "select * from \(db_request_modes) where module_id = \(module_id);"
        var queryStatement: OpaquePointer? = nil
        var requestmodes = [RequestModes]()
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
            
                let ID = Int(sqlite3_column_int(queryStatement, 0))
                let SERVER_ID_PK = Int(sqlite3_column_int(queryStatement, 1))
                let REQ_MODE_DESC = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let CREATED_BY = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                let CREATED_DATE = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                let MODULE_ID = Int(sqlite3_column_int(queryStatement, 5))
                
                requestmodes.append(RequestModes(ID: ID,
                                                 SERVER_ID_PK: SERVER_ID_PK,
                                                 REQ_MODE_DESC: REQ_MODE_DESC,
                                                 CREATED_BY: CREATED_BY,
                                                 CREATED_DATE: CREATED_DATE,
                                                 MODULE_ID: MODULE_ID))
            }
        } else {
            print("SELECT statement \(db_request_modes) could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return requestmodes
    }
    func dump_data_HRRequest(hrrequests: tbl_Hr_Request_Logs, _ handler: @escaping(_ success: Bool) -> Void) {
        let insertStatementString = "INSERT INTO \(db_hr_request)(SERVER_ID_PK, TICKET_DATE, LOGIN_ID, REQ_ID, REQ_MODE, MAT_ID, MQ_ID, DQ_ID, TICKET_STATUS, CREATED_DATE, CREATED_BY, REQ_REMAKS, HR_REMARKS, UPDATED_DATE, UPDATED_BY, REQ_EMAIL_LOG, REQ_EMAIL_LOG_TIME, REQ_EMAIL_STATUS, REQ_EMAIL_STATUS_TIME, TAT_DAYS, REM_TAT_STATUS, REM_TAT_STATUS_TIME, ASSIGNED_TO, REF_ID, AREA_CODE, STATION_CODE, HUB_CODE, EMP_NAME, RESPONSIBILITY, RESPONSIBLE_EMPNO, CURR_PHONE_01, PERSON_DESIG, MASTER_QUERY, DETAIL_QUERY, ESCALATE_DAYS, REQUEST_LOGS_SYNC_STATUS, REQ_MODE_DESC, REQUEST_LOGS_LATITUDE, MODULE_ID, HRBP_EXISTS, REQUEST_LOGS_LONGITUDE, CURRENT_USER, REQ_CASE_DESC, HR_CASE_DESC, INCIDENT_TYPE, CNSGNO, CLASSIFICATION, CITY, AREA, INCIDENT_DATE, DEPARTMENT, IS_FINANCIAL, AMOUNT, LOV_MASTER, LOV_DETAIL, LOV_SUBDETAIL, IS_EMP_RELATED , RECOVERY_TYPE, AREA_SEC_EMP_NO, DETAILED_INVESTIGATION, PROSECUTION_NARRATIVE, DEFENSE_NARRATIVE, CHALLENGES, FACTS, FINDINGS, OPINION, HO_SEC_SUMMARY, HO_SEC_RECOM, DIR_SEC_ENDOR, DIR_SEC_RECOM, IS_INS_CLAIMABLE, INS_CLAIM_REFNO, IS_INS_CLAIM_PROCESS, INS_CLAIMED_AMOUNT, HR_REF_NO, HR_STATUS, FINANCE_GL_NO, IS_CONTROL_DEFINED, RISK_REMARKS, RISK_TYPE, CONTROL_CATEGORY, CONTROL_TYPE, LINE_MANAGER1, LINE_MANAGER2, DIR_NOTIFY_EMAILS, SEC_AREA, IS_INVESTIGATION, CONTROLLER_RECOM, PREVIOUS_TICKET_STATUS, VIEW_COUNT, DESIG_NAME) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(insertStatement, 1, Int32(hrrequests.SERVER_ID_PK ?? -1))
            
            sqlite3_bind_text(insertStatement, 2, ((hrrequests.TICKET_DATE ?? "") as NSString).utf8String, -1, nil)
            
            sqlite3_bind_int(insertStatement, 3, Int32(hrrequests.LOGIN_ID ?? -1))
            sqlite3_bind_int(insertStatement, 4, Int32(hrrequests.REQ_ID ?? -1))
            sqlite3_bind_int(insertStatement, 5, Int32(hrrequests.REQ_MODE ?? -1))
            sqlite3_bind_int(insertStatement, 6, Int32(hrrequests.MAT_ID ?? -1))
            sqlite3_bind_int(insertStatement, 7, Int32(hrrequests.MQ_ID ?? -1))
            sqlite3_bind_int(insertStatement, 8, Int32(hrrequests.DQ_ID ?? -1))
            
            sqlite3_bind_text(insertStatement, 9, ((hrrequests.TICKET_STATUS ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 10, ((hrrequests.CREATED_DATE ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 11, ((hrrequests.CREATED_BY ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 12, ((hrrequests.REQ_REMARKS ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 13, ((hrrequests.HR_REMARKS ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 14, ((hrrequests.UPDATED_DATE ?? "") as NSString).utf8String, -1, nil)
            
            sqlite3_bind_text(insertStatement, 15, ((hrrequests.UPDATED_BY ?? "") as NSString).utf8String, -1, nil)
            
            sqlite3_bind_text(insertStatement, 16, ((hrrequests.REQ_EMAIL_LOG ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 17, ((hrrequests.REQ_EMAIL_LOG_TIME ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 18, ((hrrequests.REQ_EMAIL_STATUS ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 19, ((hrrequests.REQ_EMAIL_STATUS_TIME ?? "") as NSString).utf8String, -1, nil)
            
            sqlite3_bind_int(insertStatement, 20, Int32(hrrequests.TAT_DAYS ?? -1))
            
            sqlite3_bind_text(insertStatement, 21, ((hrrequests.REM_TAT_STATUS ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 22, ((hrrequests.REM_TAT_STATUS_TIME ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 23, Int32(hrrequests.ASSIGNED_TO ?? -1))
            sqlite3_bind_text(insertStatement, 24, ((hrrequests.REF_ID ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 25, ((hrrequests.AREA_CODE ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 26, ((hrrequests.STATION_CODE ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 27, ((hrrequests.HUB_CODE ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 28, ((hrrequests.EMP_NAME ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 29, ((hrrequests.RESPONSIBILITY ?? "") as NSString).utf8String, -1, nil)
            
            sqlite3_bind_int(insertStatement, 30, Int32(hrrequests.RESPONSIBLE_EMPNO ?? -1))
            
            sqlite3_bind_text(insertStatement, 31, ((hrrequests.CURR_PHONE_01 ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 32, ((hrrequests.PERSON_DESIG ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 33, ((hrrequests.MASTER_QUERY ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 34, ((hrrequests.DETAIL_QUERY ?? "") as NSString).utf8String, -1, nil)
            
            sqlite3_bind_int(insertStatement, 35, Int32(hrrequests.ESCALATE_DAYS ?? -1))
            sqlite3_bind_int(insertStatement, 36, Int32(hrrequests.REQUEST_LOGS_SYNC_STATUS ?? 0))//sync date
            
            sqlite3_bind_text(insertStatement, 37, ((hrrequests.REQ_MODE_DESC ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 38, ((hrrequests.REQUEST_LOGS_LATITUDE ?? "") as NSString).utf8String, -1, nil)
            
            sqlite3_bind_int(insertStatement, 39, Int32(hrrequests.MODULE_ID ?? -1))
            
            sqlite3_bind_int(insertStatement, 40, Int32(0)) //HRBP Exist
            sqlite3_bind_text(insertStatement, 41, ((hrrequests.REQUEST_LOGS_LONGITUDE ?? "") as NSString).utf8String, -1, nil)
            
            sqlite3_bind_int(insertStatement, 42, Int32(Int(CURRENT_USER_LOGGED_IN_ID) ?? 0))//CURRENT USER
            sqlite3_bind_text(insertStatement, 43, ((hrrequests.REQ_CASE_DESC ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 44, ((hrrequests.HR_CASE_DESC ?? "") as NSString).utf8String, -1, nil)
            
            sqlite3_bind_text(insertStatement, 45, ((hrrequests.INCIDENT_TYPE ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 46, ((hrrequests.CNSGNO ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 47, ((hrrequests.CLASSIFICATION ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 48, ((hrrequests.CITY ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 49, ((hrrequests.AREA ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 50, ((hrrequests.INCIDENT_DATE ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 51, ((hrrequests.DEPARTMENT ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 52, Int32(hrrequests.IS_FINANCIAL ?? -1))
            
            let amount = String(hrrequests.AMOUNT ?? 0.0)
            sqlite3_bind_text(insertStatement, 53, (amount as NSString).utf8String, -1, nil)
            
            sqlite3_bind_int(insertStatement, 54, Int32(hrrequests.LOV_MASTER ?? -1))
            sqlite3_bind_int(insertStatement, 55, Int32(hrrequests.LOV_DETAIL ?? -1))
            sqlite3_bind_int(insertStatement, 56, Int32(hrrequests.LOV_SUBDETAIL ?? -1))
            sqlite3_bind_int(insertStatement, 57, Int32(hrrequests.IS_EMP_RELATED ?? -1))
            
            sqlite3_bind_text(insertStatement, 58, ((hrrequests.RECOVERY_TYPE ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 59, Int32(hrrequests.AREA_SEC_EMP_NO ?? -1))
            sqlite3_bind_text(insertStatement, 60, ((hrrequests.DETAILED_INVESTIGATION ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 61, ((hrrequests.PROSECUTION_NARRATIVE ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 62, ((hrrequests.DEFENSE_NARRATIVE ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 63, ((hrrequests.CHALLENGES ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 64, ((hrrequests.FACTS ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 65, ((hrrequests.FINDINGS ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 66, ((hrrequests.OPINION ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 67, ((hrrequests.HO_SEC_SUMMARY ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 68, ((hrrequests.HO_SEC_RECOM ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 69, ((hrrequests.DIR_SEC_ENDOR ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 70, ((hrrequests.DIR_SEC_RECOM ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 71, Int32(hrrequests.IS_INS_CLAIMABLE ?? -1))
            sqlite3_bind_text(insertStatement, 72, ((hrrequests.INS_CLAIM_REFNO ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 73, Int32(hrrequests.IS_INS_CLAIM_PROCESS ?? -1))
            
            let insClaimedAmount = String(hrrequests.INS_CLAIMED_AMOUNT ?? 0.0)
            sqlite3_bind_text(insertStatement, 74, ((insClaimedAmount) as NSString).utf8String, -1, nil)
            
            sqlite3_bind_text(insertStatement, 75, ((hrrequests.HR_REF_NO ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 76, ((hrrequests.HR_STATUS ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 77, ((hrrequests.FINANCE_GL_NO ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 78, Int32(hrrequests.IS_CONTROL_DEFINED ?? -1))
            sqlite3_bind_text(insertStatement, 79, ((hrrequests.RISK_REMARKS ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 80, ((hrrequests.RISK_TYPE ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 81, ((hrrequests.CONTROL_CATEGORY ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 82, ((hrrequests.CONTROL_TYPE ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 83, Int32(hrrequests.LINE_MANAGER1 ?? -1))
            sqlite3_bind_int(insertStatement, 84, Int32(hrrequests.LINE_MANAGER2 ?? -1))
            sqlite3_bind_text(insertStatement, 85, ((hrrequests.DIR_NOTIFY_EMAILS ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 86, ((hrrequests.SEC_AREA ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 87, Int32(hrrequests.IS_INVESTIGATION ?? -1))
            sqlite3_bind_text(insertStatement, 88, ("" as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 89, ("" as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 90, Int32(hrrequests.VIEW_COUNT ?? -1))
            sqlite3_bind_text(insertStatement, 91, ((hrrequests.EMP_NAME ?? "") as NSString).utf8String, -1, nil)
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                handler(true)
            } else {
                print("\(db_hr_request): Could not insert row.")
                handler(false)
            }
        } else {
            handler(false)
            print("\(db_hr_request): INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    
    
    func read_graphlisting(query:String) -> [CircularGraphListing]{
        let queryStatementString = query
        var queryStatement: OpaquePointer? = nil
        var circularGraphListing: [CircularGraphListing] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                
                let server_id_pk = Int(sqlite3_column_int(queryStatement, 0))
                let title = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let totalCount = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let colorCode = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                
                circularGraphListing.append(CircularGraphListing(SERVER_ID_PK: server_id_pk, Title: title, TotalCount: totalCount, ColorCode: colorCode))
            }
        } else {
            print("SELECT statement \(db_remarks) could not be prepared")
        }
        return circularGraphListing
    }
    
    func dump_tbl_hr_files(hrfile: tbl_Files_Table) {
        let insertStatementString = "INSERT INTO \(db_files)(SERVER_ID_PK, TICKET_ID, GREM_ID, FILE_URL, REF_ID, CREATED, FILE_EXTENTION, FILE_SIZE_KB, FILES_SYNC) VALUES (?,?,?,?,?,?,?,?,?);"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(insertStatement, 1, Int32(hrfile.SERVER_ID_PK))
            sqlite3_bind_int(insertStatement, 2, Int32(hrfile.TICKET_ID))
            sqlite3_bind_int(insertStatement, 3, Int32(hrfile.GREM_ID))
            sqlite3_bind_text(insertStatement, 4, ((hrfile.FILE_URL) as NSString).utf8String, -1, nil)
            
            if hrfile.REF_ID == "" {
                let ref_id = self.read_column(query: "Select REF_ID FROM \(db_hr_request) WHERE SERVER_ID_PK = '\(hrfile.TICKET_ID)'")
                sqlite3_bind_text(insertStatement, 5, (ref_id as! NSString).utf8String, -1, nil)
            } else {
                sqlite3_bind_text(insertStatement, 5, (hrfile.REF_ID as NSString).utf8String, -1, nil)
            }
            
            
            sqlite3_bind_text(insertStatement, 6, ((hrfile.CREATED) as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 7, ((hrfile.FILE_EXTENTION) as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 8, Int32(hrfile.FILE_SIZE_KB))

            sqlite3_bind_int(insertStatement, 9, Int32(hrfile.FILE_SYNC))
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                //print("\(db_files)-> DUMP: Successfully inserted row.")
            } else {
                print("\(db_files)-> DUMP: Could not insert row.")
            }
        } else {
            print("\(db_files)-> DUMP: INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    func insert_tbl_hr_files(hrfile: HrFiles) {
        let insertStatementString = "INSERT INTO \(db_files)(SERVER_ID_PK, TICKET_ID, GREM_ID, FILE_URL, REF_ID, CREATED, FILE_EXTENTION, FILE_SIZE_KB, FILES_SYNC) VALUES (?,?,?,?,?,?,?,?,?);"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(insertStatement, 1, Int32(hrfile.gimgID ?? -1))
            sqlite3_bind_int(insertStatement, 2, Int32(hrfile.ticketID ?? -1))
            sqlite3_bind_int(insertStatement, 3, Int32(hrfile.gremID ?? -1))
            sqlite3_bind_text(insertStatement, 4, ((hrfile.fileURL ?? "") as NSString).utf8String, -1, nil)
            
            let ref_id = self.read_column(query: "Select REF_ID FROM \(db_hr_request) WHERE SERVER_ID_PK = '\(hrfile.ticketID!)'")
            sqlite3_bind_text(insertStatement, 5, (ref_id as! NSString).utf8String, -1, nil)
            
            sqlite3_bind_text(insertStatement, 6, ((hrfile.created ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 7, ((hrfile.fileExtention ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 8, Int32(hrfile.fileSizeKB ?? -1))
            
            if String(hrfile.ticketID!).count == 7 {
                sqlite3_bind_int(insertStatement, 9, Int32(0))
            } else {
                sqlite3_bind_int(insertStatement, 9, Int32(1))
            }
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                //print("\(db_files)-> TicketId \(hrfile.ticketID!): Successfully inserted row.")
            } else {
                print("\(db_files)-> TicketId \(hrfile.ticketID!) : Could not insert row.")
            }
        } else {
            print("\(db_files)-> TicketId \(hrfile.ticketID!): INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    func read_tbl_hr_files(query: String) -> [tbl_Files_Table] {
        let queryStatementString = query// "SELECT * FROM \(db_files) WHERE TICKET_ID = '\(ticketId)'"
        var queryStatement: OpaquePointer? = nil
        var tbl_file_table: [tbl_Files_Table] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let server_id_pk = Int(sqlite3_column_int(queryStatement, 1))
                let ticket_id = Int(sqlite3_column_int(queryStatement, 2))
                let grem_id = Int(sqlite3_column_int(queryStatement, 3))
                let file_url = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                let ref_id = String(describing: String(cString: sqlite3_column_text(queryStatement, 5)))
                let created  = String(describing: String(cString: sqlite3_column_text(queryStatement, 6)))
                let fileExt  = String(describing: String(cString: sqlite3_column_text(queryStatement, 7)))
                let fileSize = Int(sqlite3_column_int(queryStatement, 8))
                let fileUpload = self.read_column(query: "SELECT REMARKS_INPUT FROM \(db_grievance_remarks) WHERE SERVER_ID_PK = '\(grem_id)'")
                
                tbl_file_table.append(tbl_Files_Table(ID: id, SERVER_ID_PK: server_id_pk, TICKET_ID: ticket_id, GREM_ID: grem_id, FILE_URL: file_url, REF_ID: ref_id, CREATED: created, FILE_EXTENTION: fileExt, FILE_SIZE_KB: fileSize, FILE_UPLOADED_BY: "\(fileUpload)"))
            }
        } else {
            print("SELECT statement \(db_files) could not be prepared")
        }
        return tbl_file_table
    }
    
    func insert_tbl_hr_grievance(hr_log: HrLog) {
        let insertStatementString = "INSERT INTO \(db_grievance_remarks)(SERVER_ID_PK, EMPL_NO, TICKET_ID, REMARKS, REF_ID, CREATED, REMARKS_INPUT, REMARKS_SYNC, REMARKS_TICKET_STATUS) VALUES (?,?,?,?,?,?,?,?,?);"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(insertStatement, 1, Int32(hr_log.gremID))
            sqlite3_bind_int(insertStatement, 2, Int32(hr_log.emplNo))
            sqlite3_bind_int(insertStatement, 3, Int32(hr_log.ticketID))
            sqlite3_bind_text(insertStatement, 4, ((hr_log.remarks ?? "") as NSString).utf8String, -1, nil)

            let ref_id = self.read_column(query: "Select REF_ID FROM \(db_hr_request) WHERE SERVER_ID_PK = '\(hr_log.ticketID)'")
            sqlite3_bind_text(insertStatement, 5, (ref_id as! NSString).utf8String, -1, nil)

            sqlite3_bind_text(insertStatement, 6, ((hr_log.created ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 7, ((hr_log.remarksInput ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 8, Int32(1))
            sqlite3_bind_text(insertStatement, 9, ((hr_log.ticketStatus ?? "") as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
//                print("\(db_grievance_remarks): Successfully inserted row.")
            } else {
                print("\(db_grievance_remarks): Could not insert row.")
            }
        } else {
            print("\(db_grievance_remarks): INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    func read_tbl_hr_grievance(query: String) -> [tbl_Grievance_Remarks] {
        let queryStatementString = query
        var queryStatement: OpaquePointer? = nil
        var tbl_grievance_remarks: [tbl_Grievance_Remarks] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let server_id_pk = Int(sqlite3_column_int(queryStatement, 1))
                let empl_no = Int(sqlite3_column_int(queryStatement, 2))
                let ticket_id = Int(sqlite3_column_int(queryStatement, 3))
                let remarks = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                let ref_id = String(describing: String(cString: sqlite3_column_text(queryStatement, 5)))
                let created = String(describing: String(cString: sqlite3_column_text(queryStatement, 6)))
                let remarks_input = String(describing: String(cString: sqlite3_column_text(queryStatement, 7)))
                let ticket_status = String(describing: String(cString: sqlite3_column_text(queryStatement, 9)))
                tbl_grievance_remarks.append(tbl_Grievance_Remarks(ID: id,
                                                                   SERVER_ID_PK: server_id_pk,
                                                                   EMPL_NO: empl_no,
                                                                   TICKET_ID: ticket_id,
                                                                   REMARKS: remarks,
                                                                   REF_ID: ref_id,
                                                                   CREATED: created,
                                                                   REMARKS_INPUT: remarks_input,
                                                                   REMARKS_SYNC: 1,
                                                                   REMARKS_TICKET_STATUS: ticket_status))
            }
        } else {
            print("SELECT statement \(db_grievance_remarks) could not be prepared")
        }
        return tbl_grievance_remarks
    }
    
    
    
    
    
    
    
    //MARK: Incident Management System (IMS)
    func insert_tbl_lov_master(lov_master: LovMaster) {
        let insertStatementString = "INSERT INTO \(db_lov_master)(SERVER_ID_PK, CODE, NAME) VALUES (?,?,?);"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(insertStatement, 1, Int32(lov_master.lovID))
            sqlite3_bind_text(insertStatement, 2, (lov_master.lovCode as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, (lov_master.lovName as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
//                print("\(db_grievance_remarks): Successfully inserted row.")
            } else {
                print("\(db_lov_master): Could not insert row.")
            }
        } else {
            print("\(db_lov_master): INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    func read_tbl_lov_master(query: String) -> [tbl_lov_master] {
        let queryStatementString = query
        var queryStatement: OpaquePointer? = nil
        var tblLovMaster: [tbl_lov_master] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let server_id_pk = Int(sqlite3_column_int(queryStatement, 1))
                let lov_code = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let lov_name = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                
                tblLovMaster.append(tbl_lov_master(ID: id,
                                                   SERVER_ID_PK: server_id_pk,
                                                   LOV_CODE: lov_code,
                                                   LOV_NAME: lov_name))
            }
        } else {
            print("SELECT statement \(db_lov_master) could not be prepared")
        }
        return tblLovMaster
    }
    func insert_tbl_lov_detail(lov_detail: LovDetail) {
        let insertStatementString = "INSERT INTO \(db_lov_detail)(SERVER_ID_PK, MASTER_ID, CODE, NAME) VALUES (?,?,?,?);"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(insertStatement, 1, Int32(lov_detail.lovDetlID))
            sqlite3_bind_int(insertStatement, 2, Int32(lov_detail.lovID))
            sqlite3_bind_text(insertStatement, 3, (lov_detail.lovDetlCode as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, (lov_detail.lovDetlName as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
//                print("\(db_grievance_remarks): Successfully inserted row.")
            } else {
                print("\(db_lov_detail): Could not insert row.")
            }
        } else {
            print("\(db_lov_detail): INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    func read_tbl_lov_detail(query: String) -> [tbl_lov_detail] {
        let queryStatementString = query
        var queryStatement: OpaquePointer? = nil
        var tblLovDetail: [tbl_lov_detail] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let server_id_pk = Int(sqlite3_column_int(queryStatement, 1))
                let master_id = Int(sqlite3_column_int(queryStatement, 2))
                let detail_code = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                let detail_name = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                
                tblLovDetail.append(tbl_lov_detail(ID: id,
                                                   SERVER_ID_PK: server_id_pk,
                                                   MASTER_ID: master_id,
                                                   CODE: detail_code,
                                                   NAME: detail_name))
            }
        } else {
            print("SELECT statement \(db_lov_detail) could not be prepared")
        }
        return tblLovDetail
    }
    
    func insert_tbl_lov_sub_detail(lov_sub_detail: LovSubdetail) {
        let insertStatementString = "INSERT INTO \(db_lov_sub_detail)(SERVER_ID_PK, MASTER_ID, DETAIL_ID, CODE, NAME) VALUES (?,?,?,?,?);"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(insertStatement, 1, Int32(lov_sub_detail.lovSubdetlID))
            sqlite3_bind_int(insertStatement, 2, Int32(lov_sub_detail.lovID))
            sqlite3_bind_int(insertStatement, 3, Int32(lov_sub_detail.lovDetlID))
            sqlite3_bind_text(insertStatement, 4, (lov_sub_detail.lovSubdetlCode as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 5, (lov_sub_detail.lovSubdetlName as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
//                print("\(db_grievance_remarks): Successfully inserted row.")
            } else {
                print("\(db_lov_sub_detail): Could not insert row.")
            }
        } else {
            print("\(db_lov_sub_detail): INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    func read_tbl_lov_sub_detail(query: String) -> [tbl_lov_sub_detail] {
        let queryStatementString = query
        var queryStatement: OpaquePointer? = nil
        var tblLovSubDetail: [tbl_lov_sub_detail] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let server_id_pk = Int(sqlite3_column_int(queryStatement, 1))
                let master_id = Int(sqlite3_column_int(queryStatement, 2))
                let detail_id = Int(sqlite3_column_int(queryStatement, 3))
                let detail_code = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                let detail_name = String(describing: String(cString: sqlite3_column_text(queryStatement, 5)))
                
                tblLovSubDetail.append(tbl_lov_sub_detail(ID: id,
                                                          LOV_SUBDETL_ID: server_id_pk,
                                                          LOV_DETL_ID: detail_id,
                                                          LOV_ID: master_id,
                                                          LOV_SUBDETL_CODE: detail_code,
                                                          LOV_SUBDETL_NAME: detail_name))
            }
        } else {
            print("SELECT statement \(db_lov_sub_detail) could not be prepared")
        }
        return tblLovSubDetail
    }
    
    func insert_tbl_area(lov_area: Area) {
        let insertStatementString = "INSERT INTO \(db_lov_area)(SERVER_ID_PK, AREA_NAME) VALUES (?,?);"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (lov_area.areaCode as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (lov_area.areaName as NSString).utf8String, -1, nil)
            if sqlite3_step(insertStatement) == SQLITE_DONE {
//                print("\(db_grievance_remarks): Successfully inserted row.")
            } else {
                print("\(db_lov_area): Could not insert row.")
            }
        } else {
            print("\(db_lov_area): INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    func read_tbl_area(query: String) -> [tbl_lov_area] {
        let queryStatementString = query
        var queryStatement: OpaquePointer? = nil
        var tblLovArea: [tbl_lov_area] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                
                let server_id_pk = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let area = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                tblLovArea.append(tbl_lov_area(ID: id,
                                               SERVER_ID_PK: server_id_pk,
                                               AREA_NAME: area))
                
            }
        } else {
            print("SELECT statement \(db_lov_area) could not be prepared")
        }
        return tblLovArea
    }
    func insert_tbl_city(lov_city: City) {
        let insertStatementString = "INSERT INTO \(db_lov_city)(SERVER_ID_PK, AREA_CODE, CITY_NAME) VALUES (?,?,?);"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (lov_city.areaNo as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (lov_city.cityCode as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, (lov_city.cityName as NSString).utf8String, -1, nil)
            if sqlite3_step(insertStatement) == SQLITE_DONE {
//                print("\(db_grievance_remarks): Successfully inserted row.")
            } else {
                print("\(db_lov_city): Could not insert row.")
            }
        } else {
            print("\(db_lov_city): INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    func read_tbl_city(query: String) -> [tbl_lov_city] {
        let queryStatementString = query
        var queryStatement: OpaquePointer? = nil
        var tblLovCity: [tbl_lov_city] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let server_id_pk = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let area_code = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let city_name = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                
                tblLovCity.append(tbl_lov_city(ID: id,
                                               AREA_NO: server_id_pk,
                                               CITY_CODE: area_code,
                                               CITY_NAME: city_name))
            }
        } else {
            print("SELECT statement \(db_lov_city) could not be prepared")
        }
        return tblLovCity
    }
    
    func insert_tbl_area_security(lov_area_security: AreaSecurity) {
        let insertStatementString = "INSERT INTO \(db_lov_area_security)(SERVER_ID_PK, AREA_CODE, SECURITY_PERSON, CREATED, EMPNO) VALUES (?,?,?,?,?);"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(insertStatement, 1, Int32(lov_area_security.secID))
            sqlite3_bind_text(insertStatement, 2, ((lov_area_security.areaCode ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, ((lov_area_security.securityPerson ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, ((lov_area_security.created ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 5, Int32(lov_area_security.empNo))
            if sqlite3_step(insertStatement) == SQLITE_DONE {
//                print("\(db_grievance_remarks): Successfully inserted row.")
            } else {
                print("\(db_lov_area_security): Could not insert row.")
            }
        } else {
            print("\(db_lov_area_security): INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    func read_tbl_area_security(query: String) -> [tbl_lov_area_security] {
        let queryStatementString = query
        var queryStatement: OpaquePointer? = nil
        var tblLovAreaSecurity: [tbl_lov_area_security] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let server_id_pk = Int(sqlite3_column_int(queryStatement, 1))
                let area_code = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let security_person = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                let created = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                let emp_no = Int(sqlite3_column_int(queryStatement, 5))
                
                tblLovAreaSecurity.append(tbl_lov_area_security(ID: id,
                                                                SEC_ID: server_id_pk,
                                                                AREA_CODE: area_code,
                                                                SECURITY_PERSON: security_person,
                                                                CREATED: created,
                                                                EMP_NO: emp_no))
            }
        } else {
            print("SELECT statement \(db_lov_area_security) could not be prepared")
        }
        return tblLovAreaSecurity
    }
    
    func insert_tbl_department(lov_dept: Department) {
        let insertStatementString = "INSERT INTO \(db_lov_department)(SERVER_ID_PK, NAME, CREATED_BY, CREATED) VALUES (?,?,?,?);"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(insertStatement, 1, Int32(lov_dept.deptID))
            sqlite3_bind_text(insertStatement, 2, (lov_dept.depatName as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, ((lov_dept.createdBy ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, (lov_dept.createdDate as NSString).utf8String, -1, nil)
            if sqlite3_step(insertStatement) == SQLITE_DONE {
//                print("\(db_grievance_remarks): Successfully inserted row.")
            } else {
                print("\(db_lov_department): Could not insert row.")
            }
        } else {
            print("\(db_lov_department): INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    func read_tbl_department(query: String) -> [tbl_lov_department] {
        let queryStatementString = query
        var queryStatement: OpaquePointer? = nil
        var tblLovDepartment: [tbl_lov_department] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let server_id_pk = Int(sqlite3_column_int(queryStatement, 1))
                let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let created_by = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                let created_date = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                tblLovDepartment.append(tbl_lov_department(ID: id,
                                                           DEPT_ID: server_id_pk,
                                                           DEPAT_NAME: name,
                                                           CREATED_BY: created_by,
                                                           CREATED_DATE: created_date))
                
            }
        } else {
            print("SELECT statement \(db_lov_area_security) could not be prepared")
        }
        return tblLovDepartment
    }
    
    func insert_tbl_incident_type(incident_type: IncidentType) {
        let insertStatementString = "INSERT INTO \(db_lov_incident_type)(SERVER_ID_PK, NAME) VALUES (?,?);"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (incident_type.lovCode as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (incident_type.lovName as NSString).utf8String, -1, nil)
            if sqlite3_step(insertStatement) == SQLITE_DONE {
//                print("\(db_grievance_remarks): Successfully inserted row.")
            } else {
                print("\(db_lov_incident_type): Could not insert row.")
            }
        } else {
            print("\(db_lov_incident_type): INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    func read_tbl_incident_type(query: String) -> [tbl_lov_incident_type] {
        let queryStatementString = query
        var queryStatement: OpaquePointer? = nil
        var tblLovIncidentType: [tbl_lov_incident_type] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                
                let server_id_pk = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                
                tblLovIncidentType.append(tbl_lov_incident_type(ID: id,
                                                                SERVER_ID_PK: server_id_pk,
                                                                NAME: name))
            }
        } else {
            print("SELECT statement \(db_lov_incident_type) could not be prepared")
        }
        return tblLovIncidentType
    }
    
    func insert_tbl_classification(classification: Classification) {
        let insertStatementString = "INSERT INTO \(db_lov_classification)(SERVER_ID_PK, NAME) VALUES (?,?);"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (classification.lovCode as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (classification.lovName as NSString).utf8String, -1, nil)
            if sqlite3_step(insertStatement) == SQLITE_DONE {
//                print("\(db_grievance_remarks): Successfully inserted row.")
            } else {
                print("\(db_lov_classification): Could not insert row.")
            }
        } else {
            print("\(db_lov_classification): INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    func read_tbl_classification(query: String) -> [tbl_lov_classification] {
        let queryStatementString = query
        var queryStatement: OpaquePointer? = nil
        var tblLovClassification: [tbl_lov_classification] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                
                let server_id_pk = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                
                tblLovClassification.append(tbl_lov_classification(ID: id,
                                                                SERVER_ID_PK: server_id_pk,
                                                                NAME: name))
            }
        } else {
            print("SELECT statement \(db_lov_classification) could not be prepared")
        }
        return tblLovClassification
    }
    
    
    func insert_tbl_recovery_type(recovery_type: RecoveryType) {
        let insertStatementString = "INSERT INTO \(db_lov_recovery_type)(SERVER_ID_PK, NAME) VALUES (?,?);"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (recovery_type.lovCode as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (recovery_type.lovName as NSString).utf8String, -1, nil)
            if sqlite3_step(insertStatement) == SQLITE_DONE {
//                print("\(db_grievance_remarks): Successfully inserted row.")
            } else {
                print("\(db_lov_recovery_type): Could not insert row.")
            }
        } else {
            print("\(db_lov_recovery_type): INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    func read_tbl_recovery_type(query: String) -> [tbl_lov_recovery_type] {
        let queryStatementString = query
        var queryStatement: OpaquePointer? = nil
        var tblLovRecoveryType: [tbl_lov_recovery_type] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                
                let server_id_pk = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                
                tblLovRecoveryType.append(tbl_lov_recovery_type(ID: id,
                                                                SERVER_ID_PK: server_id_pk,
                                                                NAME: name))
            }
        } else {
            print("SELECT statement \(db_lov_recovery_type) could not be prepared")
        }
        return tblLovRecoveryType
    }
    func insert_tbl_hr_status(hrStatus: HrStatus) {
        let insertStatementString = "INSERT INTO \(db_lov_hr_status)(SERVER_ID_PK, NAME) VALUES (?,?);"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (hrStatus.lovCode as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (hrStatus.lovName as NSString).utf8String, -1, nil)
            if sqlite3_step(insertStatement) == SQLITE_DONE {
//                print("\(db_grievance_remarks): Successfully inserted row.")
            } else {
                print("\(db_lov_hr_status): Could not insert row.")
            }
        } else {
            print("\(db_lov_hr_status): INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    func read_tbl_hr_status(query: String) -> [tbl_lov_hr_status] {
        let queryStatementString = query
        var queryStatement: OpaquePointer? = nil
        var tblLovHrStatus: [tbl_lov_hr_status] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                
                let server_id_pk = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                
                tblLovHrStatus.append(tbl_lov_hr_status(ID: id,
                                                                SERVER_ID_PK: server_id_pk,
                                                                NAME: name))
            }
        } else {
            print("SELECT statement \(db_lov_hr_status) could not be prepared")
        }
        return tblLovHrStatus
    }
    func insert_tbl_control_category(control_category: ControlCategory) {
        let insertStatementString = "INSERT INTO \(db_lov_control_category)(SERVER_ID_PK, NAME) VALUES (?,?);"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (control_category.lovCode as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (control_category.lovName as NSString).utf8String, -1, nil)
            if sqlite3_step(insertStatement) == SQLITE_DONE {
//                print("\(db_grievance_remarks): Successfully inserted row.")
            } else {
                print("\(db_lov_control_category): Could not insert row.")
            }
        } else {
            print("\(db_lov_control_category): INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    func read_tbl_control_category(query: String) -> [tbl_lov_control_category] {
        let queryStatementString = query
        var queryStatement: OpaquePointer? = nil
        var tblLovControlCategory: [tbl_lov_control_category] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                
                let server_id_pk = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                
                tblLovControlCategory.append(tbl_lov_control_category(ID: id,
                                                                SERVER_ID_PK: server_id_pk,
                                                                NAME: name))
            }
        } else {
            print("SELECT statement \(db_lov_control_category) could not be prepared")
        }
        return tblLovControlCategory
    }
    func insert_tbl_risk_type(risk_type: RiskType) {
        let insertStatementString = "INSERT INTO \(db_lov_risk_type)(SERVER_ID_PK, NAME) VALUES (?,?);"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (risk_type.lovCode as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (risk_type.lovName as NSString).utf8String, -1, nil)
            if sqlite3_step(insertStatement) == SQLITE_DONE {
//                print("\(db_grievance_remarks): Successfully inserted row.")
            } else {
                print("\(db_lov_risk_type): Could not insert row.")
            }
        } else {
            print("\(db_lov_risk_type): INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    func read_tbl_risk_type(query: String) -> [tbl_lov_risk_type] {
        let queryStatementString = query
        var queryStatement: OpaquePointer? = nil
        var tblLovRiskType: [tbl_lov_risk_type] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                
                let server_id_pk = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                
                tblLovRiskType.append(tbl_lov_risk_type(ID: id,
                                                                SERVER_ID_PK: server_id_pk,
                                                                NAME: name))
            }
        } else {
            print("SELECT statement \(db_lov_risk_type) could not be prepared")
        }
        return tblLovRiskType
    }
    func insert_tbl_control_type(control_type: ControlType) {
        let insertStatementString = "INSERT INTO \(db_lov_control_type)(SERVER_ID_PK, NAME) VALUES (?,?);"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (control_type.lovCode as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (control_type.lovName as NSString).utf8String, -1, nil)
            if sqlite3_step(insertStatement) == SQLITE_DONE {
//                print("\(db_grievance_remarks): Successfully inserted row.")
            } else {
                print("\(db_lov_control_type): Could not insert row.")
            }
        } else {
            print("\(db_lov_control_type): INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    func read_tbl_control_type(query: String) -> [tbl_lov_control_type] {
        let queryStatementString = query
        var queryStatement: OpaquePointer? = nil
        var tblLovControlType: [tbl_lov_control_type] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                
                let server_id_pk = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                
                tblLovControlType.append(tbl_lov_control_type(ID: id,
                                                                SERVER_ID_PK: server_id_pk,
                                                                NAME: name))
            }
        } else {
            print("SELECT statement \(db_lov_control_type) could not be prepared")
        }
        return tblLovControlType
    }
    
    
    func insert_tbl_la_ad_group(la_adGroup: LeadershipAwazAdGroup) {
        let insertStatementString = "INSERT INTO \(db_la_ad_group)(SERVER_ID_PK, AD_GROUP_NAME, AD_GROUP_EMAIL_ID, STATUS, CREATED_DATE, CREATED_BY, UPDATED_DATE, UPDATED_BY) VALUES (?,?,?,?,?,?,?,?);"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(insertStatement, 1, Int32(la_adGroup.adMastID))
            sqlite3_bind_text(insertStatement, 2, ((la_adGroup.adGroupName ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, ((la_adGroup.adGroupEmailID ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, ((la_adGroup.status ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 5, ((la_adGroup.createdDate ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 6, ((la_adGroup.createdBy ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 7, ((la_adGroup.updatedDate ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 8, ((la_adGroup.updatedBy ?? "") as NSString).utf8String, -1, nil)
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("\(db_la_ad_group): Successfully inserted row.")
            } else {
                print("\(db_la_ad_group): Could not insert row.")
            }
        } else {
            print("\(db_la_ad_group): INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    func read_tbl_la_ad_group(query: String) -> [tbl_la_ad_group] {
        let queryStatementString = query
        var queryStatement: OpaquePointer? = nil
        var tblLAAdGroup: [tbl_la_ad_group] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                
                let adMastID = Int(sqlite3_column_int(queryStatement, 1))
                let adGroupName = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let adGroupEmailID = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                let status = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                let createdDate = String(describing: String(cString: sqlite3_column_text(queryStatement, 5)))
                let createdBy = String(describing: String(cString: sqlite3_column_text(queryStatement, 6)))
                let updatedDate = String(describing: String(cString: sqlite3_column_text(queryStatement, 7)))
                let updatedBy = String(describing: String(cString: sqlite3_column_text(queryStatement, 8)))
                
                tblLAAdGroup.append(tbl_la_ad_group(ID: id, SERVER_ID_PK: adMastID, AD_GROUP_NAME: adGroupName, AD_GROUP_EMAIL_ID: adGroupEmailID, STATUS: status, CREATED_DATE: createdDate, CREATED_BY: createdBy, UPDATED_DATE: updatedDate, UPDATED_BY: updatedBy))
            }
        } else {
            print("SELECT statement \(db_la_ad_group) could not be prepared")
        }
        return tblLAAdGroup
    }
    
    func insert_tbl_login_count(login_count: LoginCount) {
        let insertStatementString = "INSERT INTO \(db_login_count)(APPLICATION, COUNT) VALUES (?,?);"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (login_count.application as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 2, Int32(login_count.countXEmpno))
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("\(db_login_count): Successfully inserted row.")
            } else {
                print("\(db_login_count): Could not insert row.")
            }
        } else {
            print("\(db_login_count): INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    func read_tbl_login_count(query: String) -> [LoginCount] {
        let queryStatementString = query
        var queryStatement: OpaquePointer? = nil
        var loginCount: [LoginCount] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                
                let application = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let count = Int(sqlite3_column_int(queryStatement, 2))
                
                loginCount.append(LoginCount(application: application, countXEmpno: count))
            }
        } else {
            print("SELECT statement \(db_login_count) could not be prepared")
        }
        return loginCount
    }
    
    func insert_tbl_att_locations(att_location: AttLocations) {
        let insertStatementString = "INSERT INTO \(db_att_locations)(LOC_CODE, LOC_NAME, LATITUDE, LONGITUDE, RADIUS) VALUES (?,?,?,?,?);"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (att_location.locCode as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (att_location.locName as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, (att_location.latitude as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, (att_location.longitude as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 5, Int32(att_location.radius))
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("\(db_att_locations): Successfully inserted row.")
            } else {
                print("\(db_att_locations): Could not insert row.")
            }
        } else {
            print("\(db_att_locations): INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    func read_tbl_att_locations(query: String) -> [tbl_att_locations] {
        let queryStatementString = query
        var queryStatement: OpaquePointer? = nil
        var attLocations: [tbl_att_locations] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let locCode = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let locName = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let latitude = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                let longitude = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                let radius = Int(sqlite3_column_int(queryStatement, 5))
                attLocations.append(tbl_att_locations(ID: id,
                                                      LOC_CODE: locCode,
                                                      LOC_NAME: locName,
                                                      LATITUDE: latitude,
                                                      LONGITUDE: longitude,
                                                      RADIUS: radius))
            }
        } else {
            print("SELECT statement \(db_att_locations) could not be prepared")
        }
        return attLocations
    }
    func insert_tbl_att_user_attendance(att_location: AttUserAttendance) {
        let insertStatementString = "INSERT INTO \(db_att_userAttendance)(DATE, TIME_IN, TIME_OUT, DAYS, STATUS, CURRENT_USER) VALUES (?,?,?,?,?,?);"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (att_location.date as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (att_location.timeIn as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, (att_location.timeOut as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, (att_location.days as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 5, (att_location.status as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 6, Int32(Int(CURRENT_USER_LOGGED_IN_ID) ?? 0))
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("\(db_att_userAttendance): Successfully inserted row.")
            } else {
                print("\(db_att_userAttendance): Could not insert row.")
            }
        } else {
            print("\(db_att_userAttendance): INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    func read_tbl_att_user_attendance(query: String) -> [tbl_att_user_attendance] {
        let queryStatementString = query
        var queryStatement: OpaquePointer? = nil
        var attUserLocations: [tbl_att_user_attendance] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let date = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let timeIn = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let timeOut = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                let days = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                let status = String(describing: String(cString: sqlite3_column_text(queryStatement, 5)))
                let current_user = Int(sqlite3_column_int(queryStatement, 6))
                attUserLocations.append(tbl_att_user_attendance(ID: id,
                                                                DATE: date,
                                                                TIME_IN: timeIn,
                                                                TIME_OUT: timeOut,
                                                                DAYS: days,
                                                                STATUS: status,
                                                                CURRENT_USER: current_user))
            }
        } else {
            print("SELECT statement \(db_att_userAttendance) could not be prepared")
        }
        return attUserLocations
    }
    func read_tbl_att_user_attendance_for_notification(query: String) -> [tbl_att_user_attendance]? {
        let queryStatementString = query
        var queryStatement: OpaquePointer? = nil
        var attUserLocations: [tbl_att_user_attendance] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let date = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let timeIn = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let timeOut = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                let days = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                let status = String(describing: String(cString: sqlite3_column_text(queryStatement, 5)))
                let current_user = Int(sqlite3_column_int(queryStatement, 6))
                attUserLocations.append(tbl_att_user_attendance(ID: id,
                                                                DATE: date,
                                                                TIME_IN: timeIn,
                                                                TIME_OUT: timeOut,
                                                                DAYS: days,
                                                                STATUS: status,
                                                                CURRENT_USER: current_user))
            }
        } else {
            print("SELECT statement \(db_att_userAttendance) could not be prepared")
        }
        
        if attUserLocations.count > 0 {
            return attUserLocations
        } else {
            return nil
        }
    }
}



//MARK: DATABASE MODELS

//MARK: UserModule Database
struct tbl_UserModule: Encodable, Decodable {
    var ID: Int = -1
    var SERVER_ID_PK: Int = -1
    var MODULENAME: String = ""
    var ISACTIVE: Int = -1
    var MODULEORDER: String = ""
    var MODULEICON: String = ""
    var PARENTID: Int = -1
    var TAGNAME: String = ""
}

//MARK: UserPage Database
struct tbl_UserPage: Encodable, Decodable {
    var ID: Int = -1
    var SERVER_ID_PK: Int = -1
    var MODULEID: Int = -1
    var PAGENAME: String = ""
    var PAGEURL: String = ""
    var ISACTIVE: Int = -1
    var TAGNAME: String = ""
}

//MARK: UserPermission Database
struct tbl_UserPermission: Encodable, Decodable {
    var ID: Int = -1
    var SERVER_ID_PK: Int = -1
    var PAGEID: Int = -1
    var PERMISSION: String = ""
    var ISACTIVE: Int = -1
}

//MARK: UserProfile Database
struct tbl_UserProfile: Encodable, Decodable {
    var ID: Int = -1
    var SERVER_ID_PK: Int = -1
    var EMP_NAME: String = ""
    var GENDER: String = ""
    var CNIC_NO: String = ""
    var DISABLE_STATUS: String = ""
    var CURR_CITY: String = ""
    var EMP_CELL_1: String = ""
    var EMP_CELL_2: String = ""
    var GRADE_CODE: String = ""
    var EMP_STATUS: String = ""
    var UNIT_CODE: String = ""
    var WORKING_DESIG_CODE: String = ""
    var DESIG_CODE: Int = -1
    var DEPT_CODE: Int = -1
    var SUB_DEPT_CODE: Int = -1
    var USERID: String = ""
    var AREA_CODE: String = ""
    var STATION_CODE: String = ""
    var HUB_CODE: String = ""
    var ACCESSTOKEN: String = ""
    var HIGHNESS: String = ""
}

//MARK: SETUP API
struct tbl_Remarks: Encodable, Decodable {
    var ID: Int = -1
    var SERVER_ID_PK: Int = -1
    var SQ_ID: Int = -1
    var HR_REMARKS: String = ""
    var CREATED_DATE: String = ""
    var CREATED_BY: String = ""
    var MQ_ID: Int = -1
    var DQ_ID: Int = -1
    var MODULE_ID: Int = -1
    var REMARKS_TYPE: String = ""
    var SYNC_DATE: String = ""
}

struct tbl_QueryMatrix: Encodable, Decodable {
    var ID: Int = -1
    var SERVER_ID_PK: Int = -1
    var REGION: String = ""
    var MASTER_QUERY: String = ""
    var DETAIL_QUERY: String = ""
    var PERSON_DESIG: String = ""
    var LINE_MANAGER_DESIG: String = ""
    var HEAD_DESIG: String = ""
    var RESPONSIBILITY: String = ""
    var LINE_MANAGER: String = ""
    var HEAD: String = ""
    var MQ_ID: Int = -1//""
    var DQ_ID: Int = -1//""
    var CREATED_BY: String = ""//-1
    var CREATED_DATE: String = ""
    var ESCLATE_DAY: Int = -1
    var RESPONSIBLE_EMPNO: Int = -1
    var MANAGER_EMPNO: Int = -1
    var HEAD_EMPNO: Int = -1
    var DIRECTOR_EMPNO: Int = -1
    var COLOUR_CODE: String = ""
    var AREA: String = ""
    var MODULE_ID: Int = -1
    var SYNC_DATE: String = ""
}


struct tbl_MasterQuery: Encodable, Decodable {
    var ID: Int = -1
    var SERVER_ID_PK: Int = -1
    var MQ_DESC: String = ""
    var CREATED_BY: String = ""
    var CREATED_DATE: String = ""
    var COLOUR_CODE: String = ""
    var MODULE_ID: Int = -1
    var SYNC_DATE: String = ""
    var IsSelected: Bool = false
}

struct tbl_DetailQuery: Encodable, Decodable {
    var ID: Int = -1
    var SERVER_ID_PK: Int = -1
    var MQ_ID: Int = -1
    var DQ_DESC: String = ""
    var CREATED_BY: String = ""
    var CREATED_DATE: String = ""
    var COLOUR_CODE: String = ""
    var ESCLATE_DAY: Int = -1
    var SYNC_DATE: String = ""
    var DQ_UNIQ_ID: Int = -1
}


struct tbl_SearchKeywords: Encodable, Decodable {
    var ID: Int = -1
    var SERVER_ID_PK: Int = -1
    var KEYWORD: String = ""
    var PAGE_ID: Int = -1
    var MODULE_ID: Int = -1
    var SYNC_DATE: String = ""
}


struct tbl_RequestModes: Encodable, Decodable {
    var ID: Int = -1
    var SERVER_ID_PK: Int = -1
    var REQ_MODE_DESC: String = ""
    var CREATED_BY: String = ""
    var CREATED_DATE: String = ""
    var MODULE_ID: Int = -1
}



//MARK: HR_REQUEST_LOG API
struct tbl_Hr_Request_Logs: Encodable, Decodable {
    var ID: Int? // = -1
    var SERVER_ID_PK: Int?// = -1
    var TICKET_DATE: String?// = ""
    var LOGIN_ID: Int? // = -1
    var REQ_ID: Int? // = -1
    var REQ_MODE: Int? // = -1
    var MAT_ID: Int? // = -1
    var MQ_ID: Int? // = -1
    var DQ_ID: Int? // = -1
    var TICKET_STATUS: String? // = ""
    var CREATED_DATE: String? // = ""
    var CREATED_BY: String? // = ""
    var REQ_REMARKS: String? // = ""
    var HR_REMARKS: String? // = ""
    var UPDATED_DATE: String? //?
    var UPDATED_BY: String? // = ""
    var REQ_EMAIL_LOG: String? // = ""
    var REQ_EMAIL_LOG_TIME: String? // = ""
    var REQ_EMAIL_STATUS: String? // = ""
    var REQ_EMAIL_STATUS_TIME: String? // = ""
    var TAT_DAYS: Int? // = -1
    var REM_TAT_STATUS: String? // = ""
    var REM_TAT_STATUS_TIME: String? // = ""
    var ASSIGNED_TO: Int? // = ""
    var REF_ID: String? // = ""
    var AREA_CODE: String? // = ""
    var STATION_CODE: String? // = ""
    var HUB_CODE: String? // = ""
    var EMP_NAME: String? // = ""
    var RESPONSIBILITY: String? // = ""
    var RESPONSIBLE_EMPNO: Int? // = -1
    var CURR_PHONE_01: String? // = ""
    var PERSON_DESIG: String? // = ""
    var MASTER_QUERY: String? // = ""
    var DETAIL_QUERY: String? // = ""
    var ESCALATE_DAYS: Int? // = -1
    var REQUEST_LOGS_SYNC_STATUS: Int? // = -1
    var REQ_MODE_DESC: String? // = ""
    var REQUEST_LOGS_LATITUDE: String? // = ""
    var MODULE_ID: Int? // = -1
    var HRBP_EXISTS: Int? // = -1
    var REQUEST_LOGS_LONGITUDE: String? // = ""
    var CURRENT_USER: String? // = ""
    var REQ_CASE_DESC: String?
    var HR_CASE_DESC: String?
    
    //IMS KEYS
    var INCIDENT_TYPE: String? // = -1
    var CNSGNO: String?// = -1
    var CLASSIFICATION: String?// = ""
    var CITY: String? // = -1
    var AREA: String? // = -1
    var INCIDENT_DATE: String? // = -1
    var DEPARTMENT: String? // = -1
    var IS_FINANCIAL: Int? // = -1
    var AMOUNT: Double? // = -1
    var LOV_MASTER: Int? // = ""
    var LOV_DETAIL: Int? // = ""
    var LOV_SUBDETAIL: Int? // = ""
    var IS_EMP_RELATED: Int? // = ""
    var RECOVERY_TYPE: String? // = ""
    var AREA_SEC_EMP_NO: Int? //?
    var DETAILED_INVESTIGATION: String? // = ""
    var PROSECUTION_NARRATIVE: String? // = ""
    var DEFENSE_NARRATIVE: String? // = ""
    var CHALLENGES: String? // = ""
    var FACTS: String? // = ""
    var FINDINGS: String? // = -1
    var OPINION: String? // = ""
    var HO_SEC_SUMMARY: String? // = ""
    var HO_SEC_RECOM: String? // = ""
    var DIR_SEC_ENDOR: String? // = ""
    var DIR_SEC_RECOM: String? // = ""
    var IS_INS_CLAIMABLE: Int? // = ""
    var INS_CLAIM_REFNO: String? // = ""
    var IS_INS_CLAIM_PROCESS: Int? // = ""
    var INS_CLAIMED_AMOUNT: Double? // = ""
    var HR_REF_NO: String? // = -1
    var HR_STATUS: String? // = ""
    var FINANCE_GL_NO: String? // = ""
    var IS_CONTROL_DEFINED: Int? // = ""
    var RISK_REMARKS: String? // = ""
    var RISK_TYPE: String? // = -1
    var CONTROL_CATEGORY: String? // = -1
    var CONTROL_TYPE: String? // = ""
    var LINE_MANAGER1: Int? // = ""
    var LINE_MANAGER2: Int? // = -1
    var DIR_NOTIFY_EMAILS: String? // = -1
    var SEC_AREA: String? // = ""
    var IS_INVESTIGATION: Int? // = ""
//    var REQ_CASE_DESC: String?
//    var HR_CASE_DESC: String?
    
    //Leadership Awaz
    var VIEW_COUNT: Int?
    var DESIG_NAME: String?
}



//MARK: MULTIPLE Graph Count
struct MultipleGraph {
    var ticket_status: String?
    var ticket_total: String?
    var ticket_date: String?
    var escalate_days: Int?
    var upated_date: String?
    var created_date: String?
}
//MARK: GRAPH COUNT
struct GraphTotalCount {
    var ticket_status: String?
    var ticket_total: String?
    var ticket_date: String?
}


//MARK: Add new request
//(request mode)
struct RequestModes {
    var ID = -1
    var SERVER_ID_PK = -1
    var REQ_MODE_DESC = ""
    var CREATED_BY = ""
    var CREATED_DATE = ""
    var MODULE_ID = -1
}


struct tbl_HR_Notification_Request {
    var ID: Int = -1
    var SERVER_ID_PK: Int = -1
    var NOTIFY_TYPE: String = ""
    var NOTIFY_TITLE: String = ""
    var TITLE_MESSAGE: String = ""
    var CREATED_DATE: String = ""
    var READ_STATUS: Int = -1
    var SENDING_STATUS: Int = -1
    var SEND_TO: Int = -1
    var MODULE_DSCRP: String = ""
    var DESCRIPTION: String = ""
    var MODULE_ID: Int = -1
    var READ_STATUS_DTTM: String = ""
    var DEVICE_READ_DTTM = ""
    var TICKET_ID: Int = -1
    var SR_NO: Int = -1
    var TICKET_STATUS: String = ""
    var SYNC_STATUS: Int = -1
    var RECORD_ID: Int = -1
    var REQUEST_LOG: [tbl_Hr_Request_Logs] = []
}


//MARK:
struct CircularGraphListing {
    var SERVER_ID_PK = -1
    var Title = ""
    var TotalCount = ""
    var ColorCode = ""
}





//GRIEVANCE TABLES
struct tbl_Grievance_Remarks: Hashable, Equatable {
    var ID: Int = -1
    var SERVER_ID_PK: Int = -1
    var EMPL_NO: Int = -1
    var TICKET_ID: Int = -1
    var REMARKS: String = ""
    var REF_ID: String = ""
    var CREATED: String = ""
    var REMARKS_INPUT: String = ""
    var REMARKS_SYNC: Int = -1
    var REMARKS_TICKET_STATUS: String = ""
}
struct tbl_Files_Table {
    var ID: Int = -1
    var SERVER_ID_PK: Int = -1
    var TICKET_ID: Int = -1
    var GREM_ID: Int = -1
    var FILE_URL: String = ""
    var REF_ID: String = ""
    var CREATED: String = ""
    var FILE_EXTENTION: String = ""
    var FILE_SIZE_KB: Int = -1
    var FILE_UPLOADED_BY: String = ""
    var FILE_SYNC: Int = -1
}

//MARK: Incident Management System (IMS) local db
struct tbl_lov_master {
    var ID: Int = -1
    var SERVER_ID_PK: Int = -1
    var LOV_CODE: String = ""
    var LOV_NAME: String = ""
}
struct tbl_lov_detail {
    var ID: Int = -1
    var SERVER_ID_PK: Int = -1
    var MASTER_ID: Int = -1
    var CODE: String = ""
    var NAME: String = ""
}
struct tbl_lov_sub_detail {
    var ID: Int = -1
    var LOV_SUBDETL_ID: Int = -1
    var LOV_DETL_ID: Int = -1// 7,
    var LOV_ID: Int = -1//4,
    var LOV_SUBDETL_CODE: String = ""// "W4S7",
    var LOV_SUBDETL_NAME: String = "" //Wrong statement"
}

struct tbl_lov_area {
    var ID: Int = -1
    var SERVER_ID_PK: String = ""
    var AREA_NAME: String = ""
}
struct tbl_lov_city {
    var ID: Int = -1
    var AREA_NO: String = ""// "PEW",
    var CITY_CODE: String = ""//  "TAL",
    var CITY_NAME: String = ""//"TALL"
}
struct tbl_lov_area_security {
    var ID: Int = -1
    var SEC_ID: Int = -1// 1,
    var AREA_CODE: String = ""//KHI",
    var SECURITY_PERSON: String = ""// "Col Shujat Ullah Khan",
    var CREATED: String = "" //"2020-11-16T14:25:31",
    var EMP_NO: Int = -1 //119667
}
struct tbl_lov_department {
    var ID: Int = -1
    var DEPT_ID: Int = -1// 5000,
    var DEPAT_NAME: String = ""// "ADMINISTRATION & PROJECT",
    var CREATED_BY: String? = "" //null,
    var CREATED_DATE: String = ""//"2020-09-15T17:10:37"
}

struct tbl_lov_incident_type {
    var ID: Int = -1
    var SERVER_ID_PK: String = ""
    var NAME: String = ""
}
struct tbl_lov_classification {
    var ID: Int = -1
    var SERVER_ID_PK: String = ""
    var NAME: String = ""
}
struct tbl_lov_recovery_type {
    var ID: Int = -1
    var SERVER_ID_PK: String = ""
    var NAME: String = ""
}
struct tbl_lov_hr_status {
    var ID: Int = -1
    var SERVER_ID_PK: String = ""
    var NAME: String = ""
}
struct tbl_lov_control_category {
    var ID: Int = -1
    var SERVER_ID_PK: String = ""
    var NAME: String = ""
}
struct tbl_lov_risk_type {
    var ID: Int = -1
    var SERVER_ID_PK: String = ""
    var NAME: String = ""
}
struct tbl_lov_control_type {
    var ID: Int = -1
    var SERVER_ID_PK: String = ""
    var NAME: String = ""
}

struct financial_type {
    var ID: Int = -1
    var TYPE: String = ""
}
struct tbl_last_sync_status {
    var ID: Int = 0
    var SYNC_KEY: String = ""
    var STATUS: Int = 0
    var DATE: String = ""
    var SKIP: Int = 0
    var TAKE: Int = 0
    var TOTAL_RECORDS: Int = 0
    var CURRENT_USER: String = ""
}


struct tbl_la_ad_group {
    var ID: Int = -1
    var SERVER_ID_PK: Int = -1
    var AD_GROUP_NAME: String = ""
    var AD_GROUP_EMAIL_ID: String = ""
    var STATUS: String = ""
    var CREATED_DATE: String = ""
    var CREATED_BY: String = ""
    var UPDATED_DATE: String = ""
    var UPDATED_BY: String = ""
}
struct tbl_login_count {
    var ID: Int = -1
    var APPLICATION: String = ""
    var COUNT: String = ""
}




//MARK: attendance module
struct tbl_att_locations {
    var ID: Int = -1
    var LOC_CODE: String = ""
    var LOC_NAME: String = ""
    var LATITUDE: String = ""
    var LONGITUDE: String = ""
    var RADIUS: Int = -1
}

struct tbl_att_user_attendance {
    var ID: Int = -1
    var DATE: String = ""
    var TIME_IN: String = ""
    var TIME_OUT: String = ""
    var DAYS: String = ""
    var STATUS: String = ""
    var CURRENT_USER: Int = 0
}
