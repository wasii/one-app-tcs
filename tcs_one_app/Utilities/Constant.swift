import Foundation
import UIKit

//APP CONSTANTS
var DEVICEID: String?
var FIREBASETOKEN :String?
let USER_ACCESS_TOKEN       = "UserAccessToken"
var CURRENT_USER_LOGGED_IN_ID = ""
var CONSTANT_MODULE_ID        = -1
let ACTIVE                  = "ACTIVE"
let BACKGROUND              = "BACKGROUND"
let INACTIVE                = "INACTIVE"
let API_KEY                 = "5E4D0F6D8E12D8EC5EA3BBB11B63B2F88E39A7561F25EC67CCB440F782FD0360"
let CLIENTSECRET            = "Tcs@wallet3001"
var BEARER_TOKEN            = ""
let BROADCAST_KEY           = "broadcastiosdev"
//let BROADCAST_KEY           = "broadcastiosqa"
//let BROADCAST_KEY           = "broadcastios"

let IS_NEW_DATABASE: Bool   = true
var NOTIFICATION_COUNT      = 0

var RECORD_ID               = 0
//API ENDPOINTS

//PRODUCTION
//let ENDPOINT                = "https://prodapi.tcscourier.com/core/api/main/"
//let UPLOADFILESURL          = "https://oneappapi.tcscourier.com/api/file-upload"

//DEV
let WALLET_ENDPOINT         = "https://sandbox.tcscourier.com/"
let ENDPOINT                = "https://devapi.tcscourier.com/core/api/main"
let UPLOADFILESURL          = "https://pwaqaapi.tcscourier.com/api/file-upload"

let LOGIN                   = "oneapp.login"
let PIN_VALIDATE            = "oneapp.pinvalidate"
let SETUP                   = "oneapp.setup"
let GET_HR_REQUEST          = "oneapp.gethrrequests"
let GET_HR_NOTIFICATION     = "oneapp.gethrnotification"
let SERACH_EMPLOYEE         = "oneapp.empsearch"
//let REQUEST_LOGS            = "oneapp.requestlogs"
let REQUEST_LOGS            = "oneapp.addrequesthelpdesk"
//let UPDATE_REQUEST_LOGS     = "oneapp.requestlogupdate"
let UPDATE_REQUEST_LOGS     = "oneapp.updaterequesthelpdesk"
let READ_NOTIFICATION       = "oneapp.readnotification"
let ADDREQUESTGREV          = "oneapp.addrequestgrev"
let UPDATEREQUESTGREV       = "oneapp.updaterequestgrev"

//IMS
let IMSSETUP                = "oneapp.imssetup"
let PROCCONSIGNMENTVALIDATE = "oneapp.procconsignmentvalidate"
let ADDREQUESTIMS           = "oneapp.addrequestims"
let IMSUPDATE               = "oneapp.imsupdate"

//LEADERSHIP AWAZ
let ADDAWAZTICKET           = "oneapp.addawazticket"
let UPDATEAWAZTICKET        = "oneapp.updawazticket"

//ATTENDANCE
let GETLOCATIONS            = "oneapp.getlocation"
let FETCHATTENDANCE         = "oneapp.fetchattendance"
let MARKATTENDANCE          = "oneapp.markattendance"

//FULFILMENT
let GETORDERFULFILMET       = "oneapp.getorderfullfilment"
let UPDATEORDERFULFILMENT   = "oneapp.updateorderfullfilment"

let WALLET_SETUP            = WALLET_ENDPOINT + "dev/v1/wallet/setup"
let WALLET_GET_TOKEN        = WALLET_ENDPOINT + "dev/v1/wallet/token?clientSecret=\(CLIENTSECRET)"
let WALLET_POINTS           = WALLET_ENDPOINT + "dev/v1/wallet/points"
let S_WALLET_POINTS         = "WALLET.POINTS"
//API BACKEND KEYS
let eAI_MESSAGE             = "eAI_MESSAGE"
let eAI_BODY                = "eAI_BODY"
let eAI_REPLY               = "eAI_REPLY"
let returnStatus            = "returnStatus"

let _code                   = "code"
let _access_token_id        = "acess_token_id"
let _module                 = "module"
let _page                   = "page"
let _permision              = "permision"
let _emp_info               = "emp_info"

let _remarks                = "remarks"
let _query_matrix           = "query_matrix"
let _master_query           = "master_query"
let _detail_query           = "detail_query"
let _search_keyword         = "search_keyword"
let _app_request_mode       = "app_request_mode"
let _hr_requests            = "hr_requests"
let _notification_requests  = "notification_requests"
let _search_result          = "search_result"
let _tickets_logs           = "tickets_logs"
let _count                  = "count"
let _sync_date              = "sync_date"
let _data                   = "data"

//FILES KEY
let _hr_logs                = "hr_logs"
let _hr_files               = "hr_files"

//IMS KEY
let _lov_master             = "lov_master"
let _lov_detail             = "lov_detail"
let _lov_subdetail          = "lov_subdetail"
let _area                   = "area"
let _city                   = "city"
let _area_security          = "area_security"
let _department             = "department"
let _incident_type          = "incident_type"
let _classification         = "classification"
let _recovery_type          = "recovery_type"
let _hr_status              = "hr_status"
let _control_category       = "control_category"
let _risk_type              = "risk_type"
let _control_type           = "control_type"

//Leadership Awaz Keys
let _ad_group               = "ad_group"
let _login_count            = "login_count"

//Attendance Keys
let _attn_out               = "attn_out"

//Fulfilment Keys
let _scan_prefix            = "scan_prefix"
let _orders                 = "orders"

//Wallet_Keys
let _walletSetupData        = "walletSetupData"
let _walletHistoryPoints    = "walletHistoryPoints"
let _walletPointsData       = "walletPointsData"
let _pointsSummary          = "PointsSummary"
let _pointSummaryDetails    = "DETAILS"
let _token                  = "token"

//Local Storage (Database) tablename keys
let db_user_module          = "USER_MODULE"
let db_user_page            = "USER_PAGE"
let db_user_permission      = "USER_PERMISSION"
let db_user_profile         = "USER_PROFILE"
//SETUP API
let db_remarks              = "REMARKS"
let db_query_matrix         = "QUERY_MATRIX"
let db_master_query         = "MASTER_QUERY"
let db_detail_query         = "DETAIL_QUERY"
let db_search_keywords      = "SEARCH_KEYWORDS"
let db_request_modes        = "REQUEST_MODES"
//HR_REQUEST API
let db_hr_request           = "REQUEST_LOGS"
//HR_NOTIFICATION API
let db_hr_notifications     = "NOTIFICATION_LOGS"
let db_last_sync_status     = "LAST_SYNC_STATUS"

let db_files                = "FILES_TABLE"
let db_grievance_remarks    = "GRIEVANCE_REMARKS_TABLE"

let db_login_count          = "LOGIN_COUNT"
let db_la_ad_group          = "LA_AdGROUP"

// Attendance
let db_att_locations        = "ATT_LOCATIONS"
let db_att_userAttendance   = "ATT_USER_ATTENDANCE"

//Fulfilment
let db_scan_prefix          = "SCAN_PREFIX"
let db_fulfilment_orders    = "FULFILMENT_ORDERS"
let db_fulfilment_orders_temp = "FULFILLMENT_ORDERS_TEMP"

// IMS
let db_lov_master           = "IMS_LOV_MASTER_TABLE"
let db_lov_detail           = "IMS_LOV_DETAIL_TABLE"
let db_lov_sub_detail       = "IMS_LOV_SUBDETAIL_TABLE"
let db_lov_area             = "IMS_AREA_TABLE"
let db_lov_city             = "IMS_CITY_TABLE"
let db_lov_area_security    = "IMS_AREA_SECURITY_TABLE"
let db_lov_department       = "IMS_DEPARTMENT_TABLE"
let db_lov_incident_type    = "IMS_INCIDENT_TYPE_TABLE"
let db_lov_classification   = "IMS_CLASSIFICATION_TABLE"
let db_lov_recovery_type    = "IMS_RECOVERY_TYPE_TABLE"
let db_lov_hr_status        = "IMS_HR_STATUS_TABLE"
let db_lov_control_category = "IMS_CONTROL_CATEGORY_TABLE"
let db_lov_risk_type        = "IMS_RISK_TABLE"
let db_lov_control_type     = "IMS_CONTROL_TYPE_TABLE"

// Wallet
let db_w_query_master       = "WALLET_MASTER_DETAILS"
let db_w_query_detail       = "WALLET_QUERY_DETAILS"
let db_w_pointtypes         = "WALLET_POINTTYPES"
let db_w_setup_redemption   = "WALLET_REDEMPTION_SETUP"
let db_w_pointSummary       = "WALLET_POINTS_SUMMARY"
let db_w_history_point      = "WALLET_HISTORY_POINTS"
let db_w_pointSumDetails    = "WALLET_POINT_SUMMARY_DETAILS"

//ERROR MESSAGES
let NOINTERNETCONNECTION    = "Connect your device with internet first."
let SOMETHINGWENTWRONG      = "There is something went wrong. Please try again!"
let REVERTBACK              = "REVERTBACK"

public enum Model : String {
    
    //Simulator
    case simulator     = "simulator/sandbox",
         
         //iPhone
         iPhone4            = "iPhone 4",
         iPhone4S           = "iPhone 4S",
         iPhone5            = "iPhone 5",
         iPhone5S           = "iPhone 5S",
         iPhone5C           = "iPhone 5C",
         iPhone6            = "iPhone 6",
         iPhone6Plus        = "iPhone 6 Plus",
         iPhone6S           = "iPhone 6S",
         iPhone6SPlus       = "iPhone 6S Plus",
         iPhoneSE           = "iPhone SE",
         iPhone7            = "iPhone 7",
         iPhone7Plus        = "iPhone 7 Plus",
         iPhone8            = "iPhone 8",
         iPhone8Plus        = "iPhone 8 Plus",
         iPhoneX            = "iPhone X",
         iPhoneXS           = "iPhone XS",
         iPhoneXSMax        = "iPhone XS Max",
         iPhoneXR           = "iPhone XR",
         iPhone11           = "iPhone 11",
         iPhone11Pro        = "iPhone 11 Pro",
         iPhone11ProMax     = "iPhone 11 Pro Max",
         iPhoneSE2          = "iPhone SE 2nd gen",
         iPhone12Mini       = "iPhone 12 Mini",
         iPhone12           = "iPhone 12",
         iPhone12Pro        = "iPhone 12 Pro",
         iPhone12ProMax     = "iPhone 12 Pro Max",
         
         //unrecognized
         unrecognized       = "?unrecognized?"
}





let GET_REQUEST_HR_GRAPH = "TCS.ONE.ALL.REQUEST.GRAPH";
let GET_REQUEST_ISSUES_LOV = "TCS.ONE.QUERY.ISSUES.LOV";
let GET_SUB_QUERY_LIST = "TCS.ONE.REQUEST.SUB.GRAPH";
let UPDATE_FIREBASE_TOKEN = "TCS.ONE.UPDATE.APP.TOKEN";
let GET_USER_NOTIFICATION_LIST = "oneapp.gethrnotification";
let GET_USER_QUERY_DETAILS = "TCS.ONE.GET.TICKET.NOTIFY";
let GET_DASHBOARD_GRAPHS = "TCS.ONE.DASHBOARD.GRAPH.HOME";
let GET_REMARKS_LIST = "TCS.ONE.REMARKS.LIST";
let GET_GRIVANCES_QUERY_STATUS = "TCS.ONE.GREV.TYPE";
let CERTIFICATE_PASSWORD_PROD = "W3bsph3r3sandbox";
let CERTIFICATE_PASSWORD_DEBUG = "W3bsph3r3sandbox";
let CERTIFICATE_PASSWORD = CERTIFICATE_PASSWORD_DEBUG;

//let CERTIFICATE = R.raw.sandboxcert;

let USER_DETAILS = "userDetails";
let IS_USER_LOGGED_IN = "isUserLoggedIn";
let IS_USER_MANAGER = "isUserManager";
let IS_SYNC_DATA = "isSyncData";
let USER_ID = "USER_ID";
let OBJECT_ID = "OBJECT_ID";
let Ref_ID = "Ref_ID";
let HR_MODULE = "hr-help-desk";
let ADMIN_MODULE = "Admin Portal";
let GRIEVANCE_MODULE = "Grievance";
let SALES_MODULE = "Sales Portal";
let LOGIN_SCREEN_FLAG = "login Screen Flag";
let LOGOUT = "Logout";
let PENDING = "Pending";
let APPROVED = "Approved";
let REJECTED = "Rejected";
let NOT_PROVIDED = "Not Provided";
let DATE_FORMAT = "yyyy-MM-dd";
let DAY_MONTH_DATE_FORMAT = "dd MMM";
let DATE_FORMAT_24_HOURS = "yyyy-MM-dd HH:mm:ss";
let DATE_FORMAT_24_HOURS_NEW = "yyyy-MM-dd'T'HH:mm:ss";
let DATE_FORMAT_12_HOURS = "yyyy-MM-dd hh:mm:ss a";
let DATE_FORMAT_12_HOURS_NEW = "dd/MM/yyyy hh:mm:ss a";
let DATE_FORMAT_SERVER = "yyyyMM";
let DATE_FORMAT_SERVER_1 = "MMyyyy";
let OBJECT_DETAILS = "Object_Details";
let REQUEST_LIST = "REQUEST_LIST";
let VIEW = 2;
let EDIT = 1;
let USER_COMING_FOR = "user_coming_for";
let ADD = 0;
let ITEM_INDEX = "item_index";
let BAR_CHART = "barChart";
let PIE_CHART = "PIE";
let FIREBASE_KEY = "firebase_key";

let PATH_FOR_DOWNLOAD = "PATH_FOR_DOWNLOAD";
//let MAIN_DIR_PATH = Environment.getExternalStorageDirectory().getAbsolutePath() + "/TCSONEAPP/";
let FOLDER = "downloads/";

// Notification Types
let NOTIFICATION_HR = "HR";
let IS_COMING_FROM_NOTIFICATION = "isNotification";

//let NOTIFICATION_COUNT = "notification_count";
let TICKET_STATUS = "TICKET_STATUS";
let MASTER_QUERY_NAME = "MASTER_QUERY_NAME";
let DETAIL_QUERY_NAME = "DETAIL_QUERY_NAME";
let REQUEST_TYPE = "REQUEST_TYPE";


//FILTER CONSTANTS FOR HR USER POSTED REQUESTS
let ALL = "All";
let SELF = "Self";
let OTHERS = "Others";
let REQUEST_MODE = "requestModes";
let QUERY_TYPE = "queryTypes";
let USER_REMARKS = "userRemarks";
let HR_REMARKS = "hrRemarks";
let SUB_QUERY_TYPE = "subQueryTypes";
let GRIEVANCE_QUERY_TYPE = "grivanceQueryTypes";
let GRIEVANCE_SUB_QUERY_TYPE = "grivanceSubQueryTypes";
let WEEKLY = "Weekly";
let FIFTEEN_DAYS = "15 days";
let MONTHLY = "Monthly";
let CUSTOM_DATES = "Custom Selection";
let SUCCESS = "0200";
let FAIL = "0400";
let UNAUTHORIZED = "0403";

let HR_LOGS_LAST_SYNCED_DATE = "sync_date";
let SYNCED_DATE_FORMAT = "dd/MM/yyyy HH:mm:ss";
let Area_HOF = "HOF";
let MONTH_NAME = "MONTH_NAME";
let GRAPH_TYPE = "GRAPH_TYPE";
let ALL_REQUEST = "ALL_REQUEST";
let TAT_BREACHED = "TAT_BREACHED";
let MASTER_QUERY = "MASTER_QUERY";
let DETAIL_QUERY = "DETAIL_QUERY";

let WITH_IN_TAT = "WITH_IN_TAT";
let TAG_HR_LISTING = "hr-listing";
let TAG_DASHBOARD = "dashboard";
let TAG_ADD_REQUEST = "hr-add-request";
let TAG_MANAGEMENT_GRAPH = "management-graph";
let TAG_RESPONSIBLE_LISTING = "hr-responsible-listing";
let TAG_VIEW_EDIT_REQUEST = "hr-view-edit-request";
let TAG_MANAGMENT_GRAPH_DETAIL = "management-graph-detail";
let TAG_NOTIFICATION_LISTING = "notification-listing";

let MODULE_TAG_HR = "hr-help-desk";
let MODULE_TAG_GRIEVANCE = "Grievance";
let MODULE_TAG_IMS = "IMS"
let MODULE_TAG_LEADERSHIPAWAZ = "AWAZ"
let MODULE_TAG_FULFILMENT = "FULFILMENT"
let MODULE_TAG_ATTENDANCE = "ATTENDANCE"
let MODULE_TAG_CLS = "CLS"
let MODULE_TAG_TRACK = "TRACK"

let DOC = "application/msword";
let DOCX = "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
let IMAGE = "image/*";
let AUDIO = "audio/*";
let TEXT = "text/*";
let PDF = "application/pdf";
let XLS = "application/vnd.ms-excel";


// HR Permissions
let PERMISSION_HR_VIEW_HR_GRAPH_DASHBOARD = "View HR Graph Dashboard";
let PERMISSION_HR_GRAPH_DETAIL_DASHBOARD = "HR Graph Detail Dashboard";
let PERMISSION_HR_LISTING_ALL_FILTER = "HR Listing All Filter";
let PERMISSION_HR_LISTING_RESPONSIBLE_BAR = "HR Listing Responsible Bar";
let PERMISSION_HR_LISTING_MANAGEMENT_BAR = "HR Listing Management Bar";
let PERMISSION_HR_ADD_REQUEST_MODE = "HR Add Request Mode";

// Grievance Permission
let PERMISSION_VIEW_GRIEVENCE_GRAPH_DASHBOARD = "View Grievance Graph Dashboard";
let PERMISSION_GRIEVANCE_GRAPH_DETAIL_DASHBOARD = "Grievance Graph Detail Dashboard";

let PERMISSION_GRIEVENCE_LISTING_ALL_FILTER = "Grievance Listing All Filter";
let PERMISSION_GRIEVENCE_LISTING_RESPONSIBLE_BAR = "Grievance Listing Responsible Bar";
let PERMISSION_GRIEVENCE_LISTING_MANAGEMENT_BAR = "Grievance Listing Management Bar";

let PERMISSION_GRIEVENCE_ADD_REQUEST_MODE = "Grievance Add Request Mode";

let PERMISSION_GRIEVENCE_ALL_REQUEST_STATUS = "Grievance All Request Status";
let PERMISSION_GRIEVENCE_ALL_REQUEST_STATUS_TAT = "Grievance All Request Status TAT";
let PERMISSION_GRIEVENCE_ALL_REQUEST_STATUS_TAT_BREACHED = "Grievance All Request Status TAT Breached";
let PERMISSION_GRIEVENCE_QUERY_SUB_QUERY_REQUEST_STATUS = "Grievance Query Sub Query Request Status";

let PERMISSION_GRIEVANCE_HISTORY = "Grievance History";
let PERMISSION_GRIEVANCE_MEMO = "Grievance Memo";

let PERMISSION_INPROGRESS_ER = "Grievance InProgress-ER";
let PERMISSION_INVESTIGATING = "Grievance Investigating";
let PERMISSION_GRIEVANCE_SUBMITTED = "Grievance Submitted";
let PERMISSION_GRIEVANCE_RESPONDED = "Grievance Responded";
let PERMISSION_INPROGRESS_S = "Grievance InProgress-S";

let PERMISSION_GRIEVANCE_CLOSE = "Grievance Closed";
let INREVIEW = "In-Review";

let PERMISSION_GRIEVANCE_INEQUIRY_DONE        = "Grievance inquiry done"
let PERMISSION_GRIEVANCE_VIEW_INREVIEW_STATUS = "Grievance View In Review Status"// View In Review Status

let PERMISSION_Grievance_initiator_files = "Grievance initiator files"
let PERMISSION_Grievance_initiator_remarks = "Grievance initiator remarks"

let PERMISSION_Grievance_ermanager_remarks = "Grievance ermanager remarks"
let PERMISSION_Grievance_ermanager_files = "Grievance ermanager files"

let PERMISSION_Grievance_erofficerr_remarks = "Grievance erofficerr remarks"
let PERMISSION_Grievance_erofficerr_files = "Grievance erofficerr files"

let PERMISSION_Grievance_security_files = "Grievance security files"
let PERMISSION_Grievance_security_remarks = "Grievance security remarks"

let PERMISSION_Grievance_hrbp_remarks = "Grievance hrbp remarks"
let PERMISSION_Grievance_hrbp_files = "Grievance hrbp files"

let PERMISSION_Grievance_srhrbp_files = "Grievance srhrbp files"
let PERMISSION_Grievance_srhrbp_remarks = "Grievance srhrbp remarks"

let PERMISSION_Grievance_ceo_files = "Grievance ceo files"
let PERMISSION_Grievance_ceo_remarks = "Grievance ceo remarks"












//IMS PERMISSIONS
let IMS_View_Graph = "IMS View Graph";
let IMS_Listing_All_Filters = "IMS Listing All Filters";
let IMS_Listing_Responsible_Bar = "IMS Listing Responsible Bar";
let IMS_Add_Request_Mode = "IMS Add Request Mode";
let IMS_History_Permission = "IMS History Permission";
let IMS_Reject_Permision = "IMS Reject Permision";

let IMS_Submitted = "IMS Submitted";
let IMS_Inprogress_Rds = "IMS Inprogress-Rds";
let IMS_Inprogress_Ro = "IMS Inprogress-Ro";
let IMS_Inprogress_Rm = "IMS Inprogress-Rm";
let IMS_Inprogress_Hod = "IMS Inprogress-Hod";
let IMS_Inprogress_Cs = "IMS Inprogress-Cs";
let IMS_Inprogress_As = "IMS Inprogress-As";
let IMS_Inprogress_Hs = "IMS Inprogress-Hs";
let IMS_Inprogress_Ds = "IMS Inprogress-Ds";
let IMS_Inprogress_Fs = "IMS Inprogress-Fs";
let IMS_Inprogress_Ins = "IMS Inprogress-Ins";
let IMS_Inprogress_Hr = "IMS Inprogress-Hr";
let IMS_Inprogress_Fi = "IMS Inprogress-Fi";
let IMS_Inprogress_Ca = "IMS Inprogress-Ca";
let IMS_Inprogress_Rhod = "IMS Inprogress-Rhod";

let IMS_Closed = "IMS Closed";
let IMS_Status_Inprogress = "In Progress";

// Initiator EDIT
let IMS_Status_Inprogress_Rm = "Inprogress-Rm";

// Line Manger EDIT
let IMS_Status_Submitted = "Submitted";
let IMS_Status_Inprogress_Ro = "Inprogress-Ro";
let IMS_Status_Inprogress_Rhod = "Inprogress-Rhod";

// HOD EDIT
let IMS_Status_Inprogress_Hod = "Inprogress-Hod";
// Director of Security EDIT
let IMS_Status_Inprogress_Ds = "Inprogress-Ds";

// CS EDIT
let IMS_Status_Inprogress_Cs = "Inprogress-Cs";

// AS EDIT
let IMS_Status_Inprogress_As = "Inprogress-As";

// HS EDIT
let IMS_Status_Inprogress_Hs = "Inprogress-Hs";
let IMS_Status_Inprogress_Rds = "Inprogress-Rds";





// FS EDIT
let IMS_Status_Inprogress_Fs = "Inprogress-Fs";
let IMS_Status_Inprogress_Ins = "Inprogress-Ins";

// HR EDIT
let IMS_Status_Inprogress_Hr = "Inprogress-Hr";

// Finance EDIT
let IMS_Status_Inprogress_Fi = "Inprogress-Fi";

// Controller EDIT
let IMS_Status_Inprogress_Ca = "Inprogress-Ca";

let IMS_Status_Closed = "Closed";

let IMSAllPermissions = [
    IMS_Submitted,
    IMS_Inprogress_Rds,
    IMS_Inprogress_Ro,
    IMS_Inprogress_Rm,
    IMS_Inprogress_Hod,
    IMS_Inprogress_Cs,
    IMS_Inprogress_As,
    IMS_Inprogress_Hs,
    IMS_Inprogress_Ds,
    IMS_Inprogress_Fs,
    IMS_Inprogress_Ins,
    IMS_Inprogress_Hr,
    IMS_Inprogress_Fi,
    IMS_Inprogress_Ca,
    IMS_Inprogress_Rhod,
]

let IMS_View_Investigation_Summary = "IMS View Investigation Summary";
let IMS_View_Closure_Remarks = "IMS View Closure Remarks";

let IMS_Remarks_Initiator = "IMS Remarks Initiator";
let IMS_Remarks_Line_Manager = "IMS Remarks Line Manager";
let IMS_Remarks_Department_Head = "IMS Remarks Department Head";
let IMS_Remarks_Central_Security = "IMS Remarks Central Security";
let IMS_Remarks_Area_Security = "IMS Remarks Area Security";
let IMS_Remarks_Head_Security = "IMS Remarks Head Security";
let IMS_Remarks_Director_Security = "IMS Remarks Director Security";
let IMS_Remarks_Financial_Services = "IMS Remarks Financial Services";
let IMS_Remarks_Finance = "IMS Remarks Finance";
let IMS_Remarks_Human_Resources = "IMS Remarks Human Resources";
let IMS_Remarks_Controller = "IMS Remarks Controller";

let IMS_Files_Initiator = "IMS Files Initiator";
let IMS_Files_Line_Manager = "IMS Files Line Manager";
let IMS_Files_Department_Head = "IMS Files Department Head";
let IMS_Files_Central_Security = "IMS Files Central Security";
let IMS_Files_Area_Security = "IMS Files Area Security";
let IMS_Files_Head_Security = "IMS Files Head Security";
let IMS_Files_Director_Security = "IMS Files Director Security";
let IMS_Files_Financial_Services = "IMS Files Financial Services";
let IMS_Files_Finance = "IMS Files Finance";
let IMS_Files_Human_Resources = "IMS Files Human Resources";
let IMS_Files_Controller = "IMS Files Controller";

let IMS_View_Detailed_Investigation = "View Detailed Investigation";
let IMS_View_Prosecution_Narrative = "View Prosecution Narrative";
let IMS_View_Defense_Narrative = "View Defense Narrative";
let IMS_View_Challenges = "View Challenges";
let IMS_View_Facts = "View Facts";
let IMS_View_Findings = "View Findings";
let IMS_View_Opinions = "View Opinions";
let IMS_Area_View_Reference = "View Reference"
let IMS_Area_View_Title = "View Title"
let IMS_HS_View_Reference = "View HS Reference"
let IMS_HS_View_Title = "View HS Title"
let IMS_View_Executive_Summary = "View Executive Summary";
let IMS_View_HS_Recommendation = "View HS Recommendation";
let IMS_View_Endorsement = "View Endorsement";
let IMS_View_DS_Recommendation = "View DS Recommendation";
let IMS_View_Risk = "View Risk";


let IMS_Download_Permission = "IMS Download Permission";

let IMS_Add_Remarks_Line_Manager = "IMS Add Remarks Line Manager";
let IMS_IMS_Add_Files_Line_Manager = "IMS Add Files Line Manager";

let IMS_Add_Files_Department_Head = "IMS Add Files Department Head";
let IMS_Add_Remarks_Department_Head = "IMS Add Remarks Department Head";

let IMS_Add_Remarks_Central_Security = "IMS Add Remarks Central Security";
let IMS_Add_Files_Central_Security = "IMS Add Files Central Security";

let IMS_Add_Remarks_Area_Security = "IMS Add Remarks Area Security";
let IMS_Add_Files_Area_Security = "IMS Add Files Area Security";

let IMS_Add_Remarks_Head_Security = "IMS Add Remarks Head Security";
let IMS_Add_Files_Head_Security = "IMS Add Files Head Security";

let IMS_Add_Files_Director_Security = "IMS Add Files Director Security";
let IMS_Add_Remarks_Director_Security = "IMS Add Remarks Director Security";

let IMS_Add_Files_Financial_Services = "IMS Add Files Financial Services";
let IMS_Add_Remarks_Financial_Services = "IMS Add Remarks Financial Services";

let IMS_Add_Remarks_Human_Resources = "IMS Add Remarks Human Resources";
let IMS_Add_Files_Human_Resources = "IMS Add Files Human Resources";

let IMS_Add_Remarks_Finance = "IMS Add Remarks Finance";
let IMS_Add_Files_Finance = "IMS Add Files Finance";

let IMS_Add_Remarks_Controller = "IMS Add Remarks Controller";
let IMS_Add_Files_Controller = "IMS Add Files Controller";
//IMS Download Constants
let Download_Using_RemarksId = "Download Remarks ID";
let Download_Using_TicketId = "Download Ticket ID";
let Download_Using_RefId = "Download Ref Id";

let DateAdapter = "date_adapter";
let WithoutDateAdapter = "without_date_adapter";

//IMS Input By Remarks
let IMS_InputBy_Initiator = "Initiator";
let IMS_InputBy_LineManager = "Line Manager";
let IMS_InputBy_Hod = "Department Head";
let IMS_InputBy_CentralSecurity = "Central Security";
let IMS_InputBy_AreaSecurity = "Area Security";
let IMS_InputBy_HeadSecurity = "Head Security";
let IMS_InputBy_DirectorSecurity = "Director Security";
let IMS_InputBy_FinancialService = "Financial Services";
let IMS_InputBy_HumanResource = "Human Resources";
let IMS_InputBy_Finance = "Finance";
let IMS_InputBy_Controller = "Controller";



let INPROGRESS_INITIATOR    = IMS_Status_Inprogress + "-Initiator"
let INPROGRESS_LINEMANAGER  = IMS_Status_Inprogress + "-Line Manager"
let INPROGRESS_HOD          = IMS_Status_Inprogress + "-HOD"
let INPROGRESS_CS           = IMS_Status_Inprogress + "-Central Security"
let INPROGRESS_AS           = IMS_Status_Inprogress + "-Area Security"
let INPROGRESS_HS           = IMS_Status_Inprogress + "-Head Security"
let INPROGRESS_DS           = IMS_Status_Inprogress + "-Director Security"
let INPROGRESS_FS           = IMS_Status_Inprogress + "-Financial Services"
let INPROGRESS_HR           = IMS_Status_Inprogress + "-Human Resources"
let INPROGRESS_FI           = IMS_Status_Inprogress + "-Finance"
let INPROGRESS_CA           = IMS_Status_Inprogress + "-Controller"

let CLASSIFICATION_TAG = 1
let INCIDENT_LEVEL_1_TAG = 2
let INCIDENT_LEVEL_2_TAG = 3
let INCIDENT_LEVEL_3_TAG = 4
let LOSS_TYPE_TAG = 5
let RECOVERY_TYPE_TAG = 6

let AREA_TAG = 7
let ASSIGNED_TO_TAG = 8

let HR_STATUS = 9

let RISK_TYPE = 10
let CATEGORY_CONTROL = 11
let TYPE_CONTROL = 12

let HR_REF_NUMBER = 13

let LOSS_AMOUNT_TAG = 14



let ENTER_REMARKS_TAG = 1
let ENTER_REMARKS = "Enter Remarks"

let ENTER_DETAIL_INVESTIGATION_TAG = 2
let ENTER_DETAIL_INVESTIGATION = "Enter Detail Investigation"

let ENTER_PROCECUSTION_NARRATIVE_TAG = 3
let ENTER_PROCECUSTION_NARRATIVE = "Enter Prosecution Narrative"

let ENTER_DEFENSE_NARRATIVE_TAG = 4
let ENTER_DEFENSE_NARRATIVE = "Enter Defense Narrative"

let ENTER_CHALLENGES_TAG = 5
let ENTER_CHALLENGES = "Enter Challenges"

let ENTER_FACTS_TAG = 6
let ENTER_FACTS = "Enter Facts"

let ENTER_FINDINGS_TAG = 7
let ENTER_FINDINGS = "Enter Findings"


let ENTER_OPINIONS_TAG = 8
let ENTER_OPINIONS = "Enter Opinions"

let ENTER_EXECUTIVE_SUMMARY_TAG = 9
let ENTER_EXECUTIVE_SUMMARY = "Enter Executive Summary"

let ENTER_RECOMMENDATIONS_TAG = 10
let ENTER_DS_RECOMMENDATIONS_TAG = 15
let ENTER_RECOMMENDATIONS = "Enter Recommendations"



let ENTER_ENDORESSEMENT_TAG = 11
let ENTER_ENDORESSEMENT = "Enter Endoresment"


let ENTER_RISK_REMARKS_TAG = 12
let ENTER_RISK_REMARKS = "Enter Risk Remarks"

let ENTER_CONTROLLER_RECOMMENDATIONS_TAG = 13
let ENTER_CONTROLLER_RECOMMENDATION = "Enter Remarks"

//changes
let ENTER_REFERENCE_TAG = 16
let ENTER_REFERENCE_NUM = "Enter Reference #"

let ENTER_INVESTIGATION_TITLE_TAG = 17
let ENTER_INVESTIGATION_TITLE = "Enter Investigation Title"


let ENTER_EMAILS_TAG = 14
let ENTER_EMAILS = "Enter Emails  (Semi Colon Seperated)"



//MARK: LEADERSHIP AWAZ
let PERMISSION_ViewBroadcastMode = "View Broadcast Mode"

//MARK: FULFILMENT
let PERMISSION_FulfilmentModule = "Fulfilment Module"

let FILTERDATA = [
    "Weekly",
    "15 Days",
    "Monthly",
    "Custom Selection"
]

let REQUESTFILTERDATA = [
    "All",
    "Self",
    "Others"
]

let FULFILLMENTFILTERDATA = [
    "Pending",
    "In Process",
    "Ready to Deliver"
]
