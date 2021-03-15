//
//  User.swift
//  tcs_one_app
//
//  Created by ibs on 22/10/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import Foundation

// MARK: - Welcome
struct User: Codable {
    let empid: Int?
    let empName, fatherName, gender, cnicNo: String?
    let disableStatus: String?
    let currPhone01, currAddress, currCity: String?
    let currPostalCode: Int?
    let dateOfBirth, permanentAddress, permanentCity: String?
    let permanentPostalCode: Int?
    let birthPlace, nativePlace: String?
    let permanentPhone, currPhone02: String?
    let permanentPhone02: String?
    let empCell1, empCell2, confirmationDate, appointmentDate: String?
    let gradeCode, gradeDesc, pfEmp, pfEmployer: String?
    let empStatus: String?
    let taxNo, eobiSubOffice: String?
    let cashierBank, subDept, unitCode, unit: String?
    let locCatCode: Int?
    let locCat, locSubCat, locSubCatDES: String?
    let locCode: Int?
    let loc: String?
    let workingDesigCode: Int?
    let workingDesig: String?
    let desigCode: Int?
    let desig, leavingDate, retirementDate: String?
    let locCityCode: Int?
    let locCity: String?
    let empTypeCode: Int?
    let empType: String?
    let deptCode: Int?
    let dept: String?
    let costCenterCode: Int?
    let costCenterDES: String?
    let costLOCCode, costLOCDES: String?
    let subDeptCode, divisionCode: Int?
    let division: String?
    let probationPeriod: Int?
    let maritialStatus, dateOfMarriage, nationality, religion: String?
    let emergencyContactName, emergencyPhoneNumber, domicile, spouse: String?
    let relation: String?
    let officialEmailID: String?
    let personalEmailID, bloodGroup, passportNo: String?
    let passportExpiryDate, groupGrpCode, groupGrp, productPdtCode: String?
    let productPdt, projectPrjCode, projectPrj, userid: String?
    let userPass, areaCode, stationCode, hubCode: String?
    let region: String?
    let highness: String?
    

    enum CodingKeys: String, CodingKey {
        case empid = "EMPID"
        case empName = "EMP_NAME"
        case fatherName = "FATHER_NAME"
        case gender = "GENDER"
        case cnicNo = "CNIC_NO"
        case disableStatus = "DISABLE_STATUS"
        case currPhone01 = "CURR_PHONE_01"
        case currAddress = "CURR_ADDRESS"
        case currCity = "CURR_CITY"
        case currPostalCode = "CURR_POSTAL_CODE"
        case dateOfBirth = "DATE_OF_BIRTH"
        case permanentAddress = "PERMANENT_ADDRESS"
        case permanentCity = "PERMANENT_CITY"
        case permanentPostalCode = "PERMANENT_POSTAL_CODE"
        case birthPlace = "BIRTH_PLACE"
        case nativePlace = "NATIVE_PLACE"
        case permanentPhone = "PERMANENT_PHONE"
        case currPhone02 = "CURR_PHONE_02"
        case permanentPhone02 = "PERMANENT_PHONE_02"
        case empCell1 = "EMP_CELL#1"
        case empCell2 = "EMP_CELL#2"
        case confirmationDate = "CONFIRMATION_DATE"
        case appointmentDate = "APPOINTMENT_DATE"
        case gradeCode = "GRADE_CODE"
        case gradeDesc = "GRADE_DESC"
        case pfEmp = "PF_EMP"
        case pfEmployer = "PF_EMPLOYER"
        case empStatus = "EMP_STATUS"
        case taxNo = "TAX_NO"
        case eobiSubOffice = "EOBI_SUB_OFFICE"
        case cashierBank = "CASHIER_BANK"
        case subDept = "SUB_DEPT"
        case unitCode = "UNIT_CODE"
        case unit = "UNIT"
        case locCatCode = "LOC_CAT_CODE"
        case locCat = "LOC_CAT"
        case locSubCat = "LOC_SUB_CAT"
        case locSubCatDES = "LOC_SUB_CAT_DES"
        case locCode = "LOC_CODE"
        case loc = "LOC"
        case workingDesigCode = "WORKING_DESIG_CODE"
        case workingDesig = "WORKING_DESIG"
        case desigCode = "DESIG_CODE"
        case desig = "DESIG"
        case leavingDate = "LEAVING_DATE"
        case retirementDate = "RETIREMENT_DATE"
        case locCityCode = "LOC_CITY_CODE"
        case locCity = "LOC_CITY"
        case empTypeCode = "EMP_TYPE_CODE"
        case empType = "EMP_TYPE"
        case deptCode = "DEPT_CODE"
        case dept = "DEPT"
        case costCenterCode = "COST_CENTER_CODE"
        case costCenterDES = "COST_CENTER_DES"
        case costLOCCode = "COST_LOC_CODE"
        case costLOCDES = "COST_LOC_DES"
        case subDeptCode = "SUB_DEPT_CODE"
        case divisionCode = "DIVISION_CODE"
        case division = "DIVISION"
        case probationPeriod = "PROBATION_PERIOD"
        case maritialStatus = "MARITIAL_STATUS"
        case dateOfMarriage = "DATE_OF_MARRIAGE"
        case nationality = "NATIONALITY"
        case religion = "RELIGION"
        case emergencyContactName = "EMERGENCY_CONTACT_NAME"
        case emergencyPhoneNumber = "EMERGENCY_PHONE_NUMBER"
        case domicile = "DOMICILE"
        case spouse = "SPOUSE"
        case relation = "RELATION"
        case officialEmailID = "OFFICIAL_EMAIL_ID"
        case personalEmailID = "PERSONAL_EMAIL_ID"
        case bloodGroup = "BLOOD_GROUP"
        case passportNo = "PASSPORT_NO"
        case passportExpiryDate = "PASSPORT_EXPIRY_DATE"
        case groupGrpCode = "GROUP_GRP_CODE"
        case groupGrp = "GROUP_GRP"
        case productPdtCode = "PRODUCT_PDT_CODE"
        case productPdt = "PRODUCT_PDT"
        case projectPrjCode = "PROJECT_PRJ_CODE"
        case projectPrj = "PROJECT_PRJ"
        case userid = "USERID"
        case userPass = "USER_PASS"
        case areaCode = "AREA_CODE"
        case stationCode = "STATION_CODE"
        case hubCode = "HUB_CODE"
        case region = "REGION"
        case highness = "HIGHNESS"
    }
}



struct AttLocations: Codable {
    let locCode, locName, latitude, longitude: String

    enum CodingKeys: String, CodingKey {
        case locCode = "LOC_CODE"
        case locName = "LOC_NAME"
        case latitude = "LATITUDE"
        case longitude = "LONGITUDE"
    }
}

struct AttUserAttendance: Codable {
    let date: String
    let timeIn, timeOut: String?
    let days, status: String

    enum CodingKeys: String, CodingKey {
        case date = "DATE"
        case timeIn = "TIMEIN"
        case timeOut = "TIMEOUT"
        case days = "DAYS"
        case status = "STATUS"
    }
}
