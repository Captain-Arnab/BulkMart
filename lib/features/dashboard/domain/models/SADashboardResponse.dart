import 'dart:convert';

class SADashboardResponse {
  dynamic successMessage;
  String? status;
  String? httpStatusCode;
  dynamic errorMessage;
  String? errorCode;
  List<Application>? applications;

  SADashboardResponse({
    this.successMessage,
    this.status,
    this.httpStatusCode,
    this.errorMessage,
    this.errorCode,
    this.applications,
  });

  factory SADashboardResponse.fromRawJson(String str) => SADashboardResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SADashboardResponse.fromJson(Map<String, dynamic> json) => SADashboardResponse(
    successMessage: json["successMessage"],
    status: json["status"],
    httpStatusCode: json["httpStatusCode"],
    errorMessage: json["errorMessage"],
    errorCode: json["errorCode"],
    applications: json["applications"] == null ? [] : List<Application>.from(json["applications"]!.map((x) => Application.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "successMessage": successMessage,
    "status": status,
    "httpStatusCode": httpStatusCode,
    "errorMessage": errorMessage,
    "errorCode": errorCode,
    "applications": applications == null ? [] : List<dynamic>.from(applications!.map((x) => x.toJson())),
  };
}

class Application {
  dynamic villageName;
  dynamic vehicleInsurance;
  String? utrNumber;
  bool? upfrontProcessingfee;
  dynamic tenure;
  dynamic swimlane;
  String? supplierName;
  dynamic sourceChannel;
  bool? sendToOpsPortal;
  dynamic registrationCost;
  dynamic referToRcm;
  dynamic referToNcm;
  dynamic referToHoc;
  dynamic referToCe;
  dynamic referToBh;
  String? reasonforRejection;
  bool? rcuTriggered;
  String? rcuStatus;
  String? rcuRemark;
  String? rcNumber;
  String? promodescription;
  String? productId;
  dynamic postSanctionTat;
  dynamic podRemark;
  PddDocuments? pddDocuments;
  String? panId;
  String? opsPortalDocStatus;
  dynamic opsPerfiosRemark;
  OpsDocuments? opsDocuments;
  bool? opsApproved;
  dynamic noOfCreditValidityDays;
  bool? noHypoLoan;
  bool? nidFlag;
  String? mobileNumber;
  dynamic mandateSetupTat;
  String? loginDate;
  dynamic localityId;
  String? localApplicationId;
  String? loannboardingdate;
  dynamic loanAmount;
  String? leadsource;
  String? lastUpdateDate;
  bool? isOnline;
  bool? isFlsAssigned;
  bool? isRsaApp;
  dynamic isCiiApp;
  dynamic invoiceAmount;
  dynamic groupId;
  String? flsId;
  dynamic finalEmiAmount;
  dynamic exShowroomPrice;
  dynamic esignTat;
  DateTime? emIduedate;
  dynamic emiAmount;
  dynamic dsaName;
  dynamic disbursementFormTat;
  dynamic disbursedAmount;
  String? deviationType;
  String? deviationPendingId;
  String? derivedRejectReason;
  dynamic dealerTotalRcUnit;
  dynamic dealerTotalRcAmount;
  String? dealerName;
  dynamic dealerAalRcUnit;
  dynamic dealerAalRcAmount;
  String? dealerPortalStatus;
  dynamic customerType;
  dynamic creditApplicationStatus;
  dynamic createAppTat;
  String? assetType;
  String? assetdescription;
  String? assetcost;
  dynamic assetDetailsTat;
  dynamic asmHoldReason;
  String? applicationSubStage;
  String? applicationStatus;
  String? applicationStage;
  String? applicationId;
  String? applicantName;
  dynamic applicantId;
  String? advanceEmi;
  dynamic actionItem;
  dynamic accessoriescost;

  Application({
    this.villageName,
    this.vehicleInsurance,
    this.utrNumber,
    this.upfrontProcessingfee,
    this.tenure,
    this.swimlane,
    this.supplierName,
    this.sourceChannel,
    this.sendToOpsPortal,
    this.registrationCost,
    this.referToRcm,
    this.referToNcm,
    this.referToHoc,
    this.referToCe,
    this.referToBh,
    this.reasonforRejection,
    this.rcuTriggered,
    this.rcuStatus,
    this.rcuRemark,
    this.rcNumber,
    this.promodescription,
    this.productId,
    this.postSanctionTat,
    this.podRemark,
    this.pddDocuments,
    this.panId,
    this.opsPortalDocStatus,
    this.opsPerfiosRemark,
    this.opsDocuments,
    this.opsApproved,
    this.noOfCreditValidityDays,
    this.noHypoLoan,
    this.nidFlag,
    this.mobileNumber,
    this.mandateSetupTat,
    this.loginDate,
    this.localityId,
    this.localApplicationId,
    this.loannboardingdate,
    this.loanAmount,
    this.leadsource,
    this.lastUpdateDate,
    this.isOnline,
    this.isFlsAssigned,
    this.isRsaApp,
    this.isCiiApp,
    this.invoiceAmount,
    this.groupId,
    this.flsId,
    this.finalEmiAmount,
    this.exShowroomPrice,
    this.esignTat,
    this.emIduedate,
    this.emiAmount,
    this.dsaName,
    this.disbursementFormTat,
    this.disbursedAmount,
    this.deviationType,
    this.deviationPendingId,
    this.derivedRejectReason,
    this.dealerTotalRcUnit,
    this.dealerTotalRcAmount,
    this.dealerName,
    this.dealerAalRcUnit,
    this.dealerAalRcAmount,
    this.dealerPortalStatus,
    this.customerType,
    this.creditApplicationStatus,
    this.createAppTat,
    this.assetType,
    this.assetdescription,
    this.assetcost,
    this.assetDetailsTat,
    this.asmHoldReason,
    this.applicationSubStage,
    this.applicationStatus,
    this.applicationStage,
    this.applicationId,
    this.applicantName,
    this.applicantId,
    this.advanceEmi,
    this.actionItem,
    this.accessoriescost,
  });

  factory Application.fromRawJson(String str) => Application.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Application.fromJson(Map<String, dynamic> json) => Application(
    villageName: json["villageName"],
    vehicleInsurance: json["Vehicle_Insurance"],
    utrNumber: json["UTR_Number"],
    upfrontProcessingfee: json["upfrontProcessingfee"],
    tenure: json["tenure"],
    swimlane: json["Swimlane"],
    supplierName: json["SupplierName"],
    sourceChannel: json["SourceChannel"],
    sendToOpsPortal: json["Send_To_Ops_Portal"],
    registrationCost: json["Registration_Cost"],
    referToRcm: json["referToRCM"],
    referToNcm: json["referToNCM"],
    referToHoc: json["referToHOC"],
    referToCe: json["referToCE"],
    referToBh: json["referToBH"],
    reasonforRejection: json["reasonforRejection"],
    rcuTriggered: json["RCU_Triggered"],
    rcuStatus: json["RCU_Status"],
    rcuRemark: json["RCU_Remark"],
    rcNumber: json["rcNumber"],
    promodescription: json["Promodescription"],
    productId: json["productId"],
    postSanctionTat: json["POST_SANCTION_TAT"],
    podRemark: json["podRemark"],
    pddDocuments: json["PDD_Documents"] == null ? null : PddDocuments.fromJson(json["PDD_Documents"]),
    panId: json["PAN_ID"],
    opsPortalDocStatus: json["OPS_Portal_Doc_Status"],
    opsPerfiosRemark: json["Ops_Perfios_Remark"],
    opsDocuments: json["Ops_Documents"] == null ? null : OpsDocuments.fromJson(json["Ops_Documents"]),
    opsApproved: json["Ops_Approved"],
    noOfCreditValidityDays: json["NoOfCreditValidityDays"],
    noHypoLoan: json["No_Hypo_Loan"],
    nidFlag: json["NIDFlag"],
    mobileNumber: json["mobileNumber"],
    mandateSetupTat: json["MANDATE_SETUP_TAT"],
    loginDate: json["loginDate"],
    localityId: json["LocalityId"],
    localApplicationId: json["local_ApplicationId"],
    loannboardingdate: json["Loannboardingdate"],
    loanAmount: json["loanAmount"],
    leadsource: json["leadsource"],
    lastUpdateDate: json["lastUpdateDate"],
    isOnline: json["isOnline"],
    isFlsAssigned: json["IsFLSAssigned"],
    isRsaApp: json["is_RSA_App"],
    isCiiApp: json["Is_CII_App"],
    invoiceAmount: json["InvoiceAmount"],
    groupId: json["groupId"],
    flsId: json["flsId"],
    finalEmiAmount: json["FinalEmiAmount"],
    exShowroomPrice: json["Ex_Showroom_price"],
    esignTat: json["ESIGN_TAT"],
    emIduedate: json["EMIduedate"] == null ? null : DateTime.parse(json["EMIduedate"]),
    emiAmount: json["EmiAmount"],
    dsaName: json["DSAName"],
    disbursementFormTat: json["DISBURSEMENT_FORM_TAT"],
    disbursedAmount: json["Disbursed_Amount"],
    deviationType: json["DeviationType"],
    deviationPendingId: json["DeviationPendingId"],
    derivedRejectReason: json["DerivedRejectReason"],
    dealerTotalRcUnit: json["DealerTotalRcUnit"],
    dealerTotalRcAmount: json["DealerTotalRcAmount"],
    dealerName: json["DealerName"],
    dealerAalRcUnit: json["DealerAalRcUnit"],
    dealerAalRcAmount: json["DealerAalRcAmount"],
    dealerPortalStatus: json["Dealer_Portal_Status"],
    customerType: json["Customer_Type"],
    creditApplicationStatus: json["creditApplicationStatus"],
    createAppTat: json["Create_App_TAT"],
    assetType: json["AssetType"],
    assetdescription: json["Assetdescription"],
    assetcost: json["Assetcost"],
    assetDetailsTat: json["ASSET_DETAILS_TAT"],
    asmHoldReason: json["AsmHoldReason"],
    applicationSubStage: json["applicationSubStage"],
    applicationStatus: json["applicationStatus"],
    applicationStage: json["applicationStage"],
    applicationId: json["applicationId"],
    applicantName: json["applicantName"],
    applicantId: json["applicantId"],
    advanceEmi: json["AdvanceEMI"],
    actionItem: json["actionItem"],
    accessoriescost: json["Accessoriescost"],
  );

  Map<String, dynamic> toJson() => {
    "villageName": villageName,
    "Vehicle_Insurance": vehicleInsurance,
    "UTR_Number": utrNumber,
    "upfrontProcessingfee": upfrontProcessingfee,
    "tenure": tenure,
    "Swimlane": swimlane,
    "SupplierName": supplierName,
    "SourceChannel": sourceChannel,
    "Send_To_Ops_Portal": sendToOpsPortal,
    "Registration_Cost": registrationCost,
    "referToRCM": referToRcm,
    "referToNCM": referToNcm,
    "referToHOC": referToHoc,
    "referToCE": referToCe,
    "referToBH": referToBh,
    "reasonforRejection": reasonforRejection,
    "RCU_Triggered": rcuTriggered,
    "RCU_Status": rcuStatus,
    "RCU_Remark": rcuRemark,
    "rcNumber": rcNumber,
    "Promodescription": promodescription,
    "productId": productId,
    "POST_SANCTION_TAT": postSanctionTat,
    "podRemark": podRemark,
    "PDD_Documents": pddDocuments?.toJson(),
    "PAN_ID": panId,
    "OPS_Portal_Doc_Status": opsPortalDocStatus,
    "Ops_Perfios_Remark": opsPerfiosRemark,
    "Ops_Documents": opsDocuments?.toJson(),
    "Ops_Approved": opsApproved,
    "NoOfCreditValidityDays": noOfCreditValidityDays,
    "No_Hypo_Loan": noHypoLoan,
    "NIDFlag": nidFlag,
    "mobileNumber": mobileNumber,
    "MANDATE_SETUP_TAT": mandateSetupTat,
    "loginDate": loginDate,
    "LocalityId": localityId,
    "local_ApplicationId": localApplicationId,
    "Loannboardingdate": loannboardingdate,
    "loanAmount": loanAmount,
    "leadsource": leadsource,
    "lastUpdateDate": lastUpdateDate,
    "isOnline": isOnline,
    "IsFLSAssigned": isFlsAssigned,
    "is_RSA_App": isRsaApp,
    "Is_CII_App": isCiiApp,
    "InvoiceAmount": invoiceAmount,
    "groupId": groupId,
    "flsId": flsId,
    "FinalEmiAmount": finalEmiAmount,
    "Ex_Showroom_price": exShowroomPrice,
    "ESIGN_TAT": esignTat,
    "EMIduedate": "${emIduedate!.year.toString().padLeft(4, '0')}-${emIduedate!.month.toString().padLeft(2, '0')}-${emIduedate!.day.toString().padLeft(2, '0')}",
    "EmiAmount": emiAmount,
    "DSAName": dsaName,
    "DISBURSEMENT_FORM_TAT": disbursementFormTat,
    "Disbursed_Amount": disbursedAmount,
    "DeviationType": deviationType,
    "DeviationPendingId": deviationPendingId,
    "DerivedRejectReason": derivedRejectReason,
    "DealerTotalRcUnit": dealerTotalRcUnit,
    "DealerTotalRcAmount": dealerTotalRcAmount,
    "DealerName": dealerName,
    "DealerAalRcUnit": dealerAalRcUnit,
    "DealerAalRcAmount": dealerAalRcAmount,
    "Dealer_Portal_Status": dealerPortalStatus,
    "Customer_Type": customerType,
    "creditApplicationStatus": creditApplicationStatus,
    "Create_App_TAT": createAppTat,
    "AssetType": assetType,
    "Assetdescription": assetdescription,
    "Assetcost": assetcost,
    "ASSET_DETAILS_TAT": assetDetailsTat,
    "AsmHoldReason": asmHoldReason,
    "applicationSubStage": applicationSubStage,
    "applicationStatus": applicationStatus,
    "applicationStage": applicationStage,
    "applicationId": applicationId,
    "applicantName": applicantName,
    "applicantId": applicantId,
    "AdvanceEMI": advanceEmi,
    "actionItem": actionItem,
    "Accessoriescost": accessoriescost,
  };
}

class OpsDocuments {
  String? panCardVinodKumar;
  String? panCardSagarSudhirKarande;
  String? drivingLicenseVinodKumar;
  String? kycBackVinodKumar;
  String? customerPhotoVinodKumar;
  String? kycVinodKumar;
  String? voterIdCardVinodKumar;
  String? signatureProofVinodKumar;
  String? form60VinodKumar;
  String? drivingLicenseSagarSudhirKarande;
  String? kycBackSagarSudhirKarande;
  String? customerPhotoSagarSudhirKarande;
  String? kycSagarSudhirKarande;
  String? voterIdCardSagarSudhirKarande;
  String? currentAddressProofSagarSudhirKarande;
  String? signatureProofSagarSudhirKarande;
  String? form60SagarSudhirKarande;
  String? landholdingDetails;
  String? proformaInvoice;
  String? partnershipLlpDeed;
  String? nonKycAdditionalAddressProof;
  String? kfs;
  String? businessImage;
  String? pennyFuzzy;
  String? certificateOfIncorporation;
  String? hufDeclarationCertificate;
  String? llpAgreementDeed;
  String? aoa;
  String? cinDocument;
  String? boardResolution;
  String? authorityLetter;
  String? partnershipDeed;
  String? firmRegistartionCertificate;
  String? dealerCommitmentLetter;
  String? offerLetter2;
  String? deliveryOrder2;
  String? auditCommitteeApproval;
  String? marginMoney2;
  String? taxInvoice2;
  String? performaInvoice2;
  String? harvesterImage4;
  String? harvesterImage3;
  String? harvesterImage2;
  String? harvesterImage1;
  String? officePremises;
  String? moa;
  String? cliOrEmiProtectOrLoanAgreement;
  String? implementImage4;
  String? implementImage3;
  String? implementImage2;
  String? implementImage1;
  String? serialNumber;
  String? assetValuationReport;
  String? orissaSubsidyAgroPermitLetter;
  String? rc;
  String? generalInsurancePolicy;
  String? otherDocument4;
  String? otherDocument3;
  String? otherDocument2;
  String? otherDocument1;
  String? chassisPlateImage;
  String? hmrImage;
  String? generalInsuranceQuotation;
  String? residenceImage;
  String? passbook;
  String? vehicleInspectionReport;
  String? oldRcOrFormBExtractOrFop;
  String? rtoBookletAllPages;
  String? consentLetter;
  String? taxInvoice;
  String? deliveryOrder;
  String? offerLetter;
  String? repaymentScheduleIrrSheet;
  String? rcDocument;
  String? tractorImage4;
  String? tractorImage3;
  String? tractorImage2;
  String? tractorImage1;
  String? pdc;
  String? physicalMandate;
  String? marginMoneyReceipt;
  String? invoice;
  String? panCardMangalParkash;
  String? panCardNareshKumar;
  String? currentAddressProofMangalParkash;
  String? signatureProofMangalParkash;
  String? voterIdCardMangalParkash;
  String? form60MangalParkash;
  String? kycBackMangalParkash;
  String? customerPhotoMangalParkash;
  String? kycMangalParkash;
  String? drivingLicenseMangalParkash;
  String? currentAddressProofNareshKumar;
  String? signatureProofNareshKumar;
  String? voterIdCardNareshKumar;
  String? form60NareshKumar;
  String? kycBackNareshKumar;
  String? customerPhotoNareshKumar;
  String? kycNareshKumar;
  String? drivingLicenseNareshKumar;
  String? panCardParmarKuldipsinh;
  String? panCardAnilKumar;
  String? panCardManojLahuKarale;
  String? drivingLicenseParmarKuldipsinh;
  String? kycBackParmarKuldipsinh;
  String? customerPhotoParmarKuldipsinh;
  String? kycParmarKuldipsinh;
  String? voterIdCardParmarKuldipsinh;
  String? currentAddressProofParmarKuldipsinh;
  String? signatureProofParmarKuldipsinh;
  String? form60ParmarKuldipsinh;
  String? drivingLicenseAnilKumar;
  String? kycBackAnilKumar;
  String? customerPhotoAnilKumar;
  String? kycAnilKumar;
  String? voterIdCardAnilKumar;
  String? currentAddressProofAnilKumar;
  String? signatureProofAnilKumar;
  String? form60AnilKumar;
  String? drivingLicenseManojLahuKarale;
  String? kycBackManojLahuKarale;
  String? customerPhotoManojLahuKarale;
  String? kycManojLahuKarale;
  String? voterIdCardManojLahuKarale;
  String? currentAddressProofManojLahuKarale;
  String? signatureProofManojLahuKarale;
  String? form60ManojLahuKarale;
  String? currentAddressProofVinodKumar;
  String? panCardJadejaDigvijaysinh;
  String? drivingLicenseJadejaDigvijaysinh;
  String? kycBackJadejaDigvijaysinh;
  String? customerPhotoJadejaDigvijaysinh;
  String? kycJadejaDigvijaysinh;
  String? voterIdCardJadejaDigvijaysinh;
  String? signatureProofJadejaDigvijaysinh;
  String? form60JadejaDigvijaysinh;
  String? panCardKunalAgarwal;
  String? drivingLicenseKunalAgarwal;
  String? kycBackKunalAgarwal;
  String? customerPhotoKunalAgarwal;
  String? kycKunalAgarwal;
  String? voterIdCardKunalAgarwal;
  String? currentAddressProofKunalAgarwal;
  String? signatureProofKunalAgarwal;
  String? form60KunalAgarwal;
  String? panCardAjayKumar;
  String? drivingLicenseAjayKumar;
  String? kycBackAjayKumar;
  String? customerPhotoAjayKumar;
  String? kycAjayKumar;
  String? voterIdCardAjayKumar;
  String? currentAddressProofAjayKumar;
  String? signatureProofAjayKumar;
  String? form60AjayKumar;
  String? drivingLicenseAmolCeramicaPrivateLimited;
  String? kycBackAmolCeramicaPrivateLimited;
  String? customerPhotoAmolCeramicaPrivateLimited;
  String? kycAmolCeramicaPrivateLimited;
  String? gstDocumentAmolCeramicaPrivateLimited;
  String? voterIdCardAmolCeramicaPrivateLimited;
  String? panCardAmolCeramicaPrivateLimited;
  String? drivingLicenseVedgangaMilkAndMilkProducts;
  String? kycBackVedgangaMilkAndMilkProducts;
  String? customerPhotoVedgangaMilkAndMilkProducts;
  String? kycVedgangaMilkAndMilkProducts;
  String? gstDocumentVedgangaMilkAndMilkProducts;
  String? voterIdCardVedgangaMilkAndMilkProducts;
  String? panCardVedgangaMilkAndMilkProducts;
  String? drivingLicenseRitvikJain;
  String? kycBackRitvikJain;
  String? customerPhotoRitvikJain;
  String? kycRitvikJain;
  String? voterIdCardRitvikJain;
  String? currentAddressProofRitvikJain;
  String? signatureProofRitvikJain;
  String? form60RitvikJain;
  String? drivingLicenseEcoglobePackagingPrivateLimited;
  String? kycBackEcoglobePackagingPrivateLimited;
  String? customerPhotoEcoglobePackagingPrivateLimited;
  String? kycEcoglobePackagingPrivateLimited;
  String? gstDocumentEcoglobePackagingPrivateLimited;
  String? voterIdCardEcoglobePackagingPrivateLimited;
  String? panCardEcoglobePackagingPrivateLimited;
  String? panCardPramod;
  String? voterIdCardPramod;
  String? kycBackPramod;
  String? customerPhotoPramod;
  String? kycPramod;
  String? drivingLicensePramod;
  String? gstDocumentPramod;
  String? panCardAnilKuma;
  String? drivingLicenseAnilKuma;
  String? kycBackAnilKuma;
  String? customerPhotoAnilKuma;
  String? kycAnilKuma;
  String? voterIdCardAnilKuma;
  String? currentAddressProofAnilKuma;
  String? signatureProofAnilKuma;
  String? form60AnilKuma;
  String? panCardAdilKumar;
  String? drivingLicenseAdilKumar;
  String? kycBackAdilKumar;
  String? customerPhotoAdilKumar;
  String? kycAdilKumar;
  String? voterIdCardAdilKumar;
  String? signatureProofAdilKumar;
  String? form60AdilKumar;
  String? drivingLicenseAnitKumar;
  String? kycBackAnitKumar;
  String? customerPhotoAnitKumar;
  String? kycAnitKumar;
  String? voterIdCardAnitKumar;
  String? currentAddressProofAnitKumar;
  String? signatureProofAnitKumar;
  String? form60AnitKumar;
  String? panCardAniKumar;
  String? currentAddressProofAniKumar;
  String? signatureProofAniKumar;
  String? voterIdCardAniKumar;
  String? form60AniKumar;
  String? kycBackAniKumar;
  String? customerPhotoAniKumar;
  String? kycAniKumar;
  String? drivingLicenseAniKumar;
  String? panCardAmniKumar;
  String? drivingLicenseAmniKumar;
  String? kycBackAmniKumar;
  String? customerPhotoAmniKumar;
  String? kycAmniKumar;
  String? voterIdCardAmniKumar;
  String? currentAddressProofAmniKumar;
  String? signatureProofAmniKumar;
  String? form60AmniKumar;
  String? drivingLicenseManejTahuKarale;
  String? kycBackManejTahuKarale;
  String? customerPhotoManejTahuKarale;
  String? kycManejTahuKarale;
  String? voterIdCardManejTahuKarale;
  String? currentAddressProofManejTahuKarale;
  String? signatureProofManejTahuKarale;
  String? form60ManejTahuKarale;

  OpsDocuments({
    this.panCardVinodKumar,
    this.panCardSagarSudhirKarande,
    this.drivingLicenseVinodKumar,
    this.kycBackVinodKumar,
    this.customerPhotoVinodKumar,
    this.kycVinodKumar,
    this.voterIdCardVinodKumar,
    this.signatureProofVinodKumar,
    this.form60VinodKumar,
    this.drivingLicenseSagarSudhirKarande,
    this.kycBackSagarSudhirKarande,
    this.customerPhotoSagarSudhirKarande,
    this.kycSagarSudhirKarande,
    this.voterIdCardSagarSudhirKarande,
    this.currentAddressProofSagarSudhirKarande,
    this.signatureProofSagarSudhirKarande,
    this.form60SagarSudhirKarande,
    this.landholdingDetails,
    this.proformaInvoice,
    this.partnershipLlpDeed,
    this.nonKycAdditionalAddressProof,
    this.kfs,
    this.businessImage,
    this.pennyFuzzy,
    this.certificateOfIncorporation,
    this.hufDeclarationCertificate,
    this.llpAgreementDeed,
    this.aoa,
    this.cinDocument,
    this.boardResolution,
    this.authorityLetter,
    this.partnershipDeed,
    this.firmRegistartionCertificate,
    this.dealerCommitmentLetter,
    this.offerLetter2,
    this.deliveryOrder2,
    this.auditCommitteeApproval,
    this.marginMoney2,
    this.taxInvoice2,
    this.performaInvoice2,
    this.harvesterImage4,
    this.harvesterImage3,
    this.harvesterImage2,
    this.harvesterImage1,
    this.officePremises,
    this.moa,
    this.cliOrEmiProtectOrLoanAgreement,
    this.implementImage4,
    this.implementImage3,
    this.implementImage2,
    this.implementImage1,
    this.serialNumber,
    this.assetValuationReport,
    this.orissaSubsidyAgroPermitLetter,
    this.rc,
    this.generalInsurancePolicy,
    this.otherDocument4,
    this.otherDocument3,
    this.otherDocument2,
    this.otherDocument1,
    this.chassisPlateImage,
    this.hmrImage,
    this.generalInsuranceQuotation,
    this.residenceImage,
    this.passbook,
    this.vehicleInspectionReport,
    this.oldRcOrFormBExtractOrFop,
    this.rtoBookletAllPages,
    this.consentLetter,
    this.taxInvoice,
    this.deliveryOrder,
    this.offerLetter,
    this.repaymentScheduleIrrSheet,
    this.rcDocument,
    this.tractorImage4,
    this.tractorImage3,
    this.tractorImage2,
    this.tractorImage1,
    this.pdc,
    this.physicalMandate,
    this.marginMoneyReceipt,
    this.invoice,
    this.panCardMangalParkash,
    this.panCardNareshKumar,
    this.currentAddressProofMangalParkash,
    this.signatureProofMangalParkash,
    this.voterIdCardMangalParkash,
    this.form60MangalParkash,
    this.kycBackMangalParkash,
    this.customerPhotoMangalParkash,
    this.kycMangalParkash,
    this.drivingLicenseMangalParkash,
    this.currentAddressProofNareshKumar,
    this.signatureProofNareshKumar,
    this.voterIdCardNareshKumar,
    this.form60NareshKumar,
    this.kycBackNareshKumar,
    this.customerPhotoNareshKumar,
    this.kycNareshKumar,
    this.drivingLicenseNareshKumar,
    this.panCardParmarKuldipsinh,
    this.panCardAnilKumar,
    this.panCardManojLahuKarale,
    this.drivingLicenseParmarKuldipsinh,
    this.kycBackParmarKuldipsinh,
    this.customerPhotoParmarKuldipsinh,
    this.kycParmarKuldipsinh,
    this.voterIdCardParmarKuldipsinh,
    this.currentAddressProofParmarKuldipsinh,
    this.signatureProofParmarKuldipsinh,
    this.form60ParmarKuldipsinh,
    this.drivingLicenseAnilKumar,
    this.kycBackAnilKumar,
    this.customerPhotoAnilKumar,
    this.kycAnilKumar,
    this.voterIdCardAnilKumar,
    this.currentAddressProofAnilKumar,
    this.signatureProofAnilKumar,
    this.form60AnilKumar,
    this.drivingLicenseManojLahuKarale,
    this.kycBackManojLahuKarale,
    this.customerPhotoManojLahuKarale,
    this.kycManojLahuKarale,
    this.voterIdCardManojLahuKarale,
    this.currentAddressProofManojLahuKarale,
    this.signatureProofManojLahuKarale,
    this.form60ManojLahuKarale,
    this.currentAddressProofVinodKumar,
    this.panCardJadejaDigvijaysinh,
    this.drivingLicenseJadejaDigvijaysinh,
    this.kycBackJadejaDigvijaysinh,
    this.customerPhotoJadejaDigvijaysinh,
    this.kycJadejaDigvijaysinh,
    this.voterIdCardJadejaDigvijaysinh,
    this.signatureProofJadejaDigvijaysinh,
    this.form60JadejaDigvijaysinh,
    this.panCardKunalAgarwal,
    this.drivingLicenseKunalAgarwal,
    this.kycBackKunalAgarwal,
    this.customerPhotoKunalAgarwal,
    this.kycKunalAgarwal,
    this.voterIdCardKunalAgarwal,
    this.currentAddressProofKunalAgarwal,
    this.signatureProofKunalAgarwal,
    this.form60KunalAgarwal,
    this.panCardAjayKumar,
    this.drivingLicenseAjayKumar,
    this.kycBackAjayKumar,
    this.customerPhotoAjayKumar,
    this.kycAjayKumar,
    this.voterIdCardAjayKumar,
    this.currentAddressProofAjayKumar,
    this.signatureProofAjayKumar,
    this.form60AjayKumar,
    this.drivingLicenseAmolCeramicaPrivateLimited,
    this.kycBackAmolCeramicaPrivateLimited,
    this.customerPhotoAmolCeramicaPrivateLimited,
    this.kycAmolCeramicaPrivateLimited,
    this.gstDocumentAmolCeramicaPrivateLimited,
    this.voterIdCardAmolCeramicaPrivateLimited,
    this.panCardAmolCeramicaPrivateLimited,
    this.drivingLicenseVedgangaMilkAndMilkProducts,
    this.kycBackVedgangaMilkAndMilkProducts,
    this.customerPhotoVedgangaMilkAndMilkProducts,
    this.kycVedgangaMilkAndMilkProducts,
    this.gstDocumentVedgangaMilkAndMilkProducts,
    this.voterIdCardVedgangaMilkAndMilkProducts,
    this.panCardVedgangaMilkAndMilkProducts,
    this.drivingLicenseRitvikJain,
    this.kycBackRitvikJain,
    this.customerPhotoRitvikJain,
    this.kycRitvikJain,
    this.voterIdCardRitvikJain,
    this.currentAddressProofRitvikJain,
    this.signatureProofRitvikJain,
    this.form60RitvikJain,
    this.drivingLicenseEcoglobePackagingPrivateLimited,
    this.kycBackEcoglobePackagingPrivateLimited,
    this.customerPhotoEcoglobePackagingPrivateLimited,
    this.kycEcoglobePackagingPrivateLimited,
    this.gstDocumentEcoglobePackagingPrivateLimited,
    this.voterIdCardEcoglobePackagingPrivateLimited,
    this.panCardEcoglobePackagingPrivateLimited,
    this.panCardPramod,
    this.voterIdCardPramod,
    this.kycBackPramod,
    this.customerPhotoPramod,
    this.kycPramod,
    this.drivingLicensePramod,
    this.gstDocumentPramod,
    this.panCardAnilKuma,
    this.drivingLicenseAnilKuma,
    this.kycBackAnilKuma,
    this.customerPhotoAnilKuma,
    this.kycAnilKuma,
    this.voterIdCardAnilKuma,
    this.currentAddressProofAnilKuma,
    this.signatureProofAnilKuma,
    this.form60AnilKuma,
    this.panCardAdilKumar,
    this.drivingLicenseAdilKumar,
    this.kycBackAdilKumar,
    this.customerPhotoAdilKumar,
    this.kycAdilKumar,
    this.voterIdCardAdilKumar,
    this.signatureProofAdilKumar,
    this.form60AdilKumar,
    this.drivingLicenseAnitKumar,
    this.kycBackAnitKumar,
    this.customerPhotoAnitKumar,
    this.kycAnitKumar,
    this.voterIdCardAnitKumar,
    this.currentAddressProofAnitKumar,
    this.signatureProofAnitKumar,
    this.form60AnitKumar,
    this.panCardAniKumar,
    this.currentAddressProofAniKumar,
    this.signatureProofAniKumar,
    this.voterIdCardAniKumar,
    this.form60AniKumar,
    this.kycBackAniKumar,
    this.customerPhotoAniKumar,
    this.kycAniKumar,
    this.drivingLicenseAniKumar,
    this.panCardAmniKumar,
    this.drivingLicenseAmniKumar,
    this.kycBackAmniKumar,
    this.customerPhotoAmniKumar,
    this.kycAmniKumar,
    this.voterIdCardAmniKumar,
    this.currentAddressProofAmniKumar,
    this.signatureProofAmniKumar,
    this.form60AmniKumar,
    this.drivingLicenseManejTahuKarale,
    this.kycBackManejTahuKarale,
    this.customerPhotoManejTahuKarale,
    this.kycManejTahuKarale,
    this.voterIdCardManejTahuKarale,
    this.currentAddressProofManejTahuKarale,
    this.signatureProofManejTahuKarale,
    this.form60ManejTahuKarale,
  });

  factory OpsDocuments.fromRawJson(String str) => OpsDocuments.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OpsDocuments.fromJson(Map<String, dynamic> json) => OpsDocuments(
    panCardVinodKumar: json["PAN CARD Vinod Kumar"],
    panCardSagarSudhirKarande: json["PAN CARD Sagar Sudhir Karande"],
    drivingLicenseVinodKumar: json["Driving License Vinod Kumar"],
    kycBackVinodKumar: json["KYC Back Vinod Kumar"],
    customerPhotoVinodKumar: json["Customer Photo Vinod Kumar"],
    kycVinodKumar: json["KYC Vinod Kumar"],
    voterIdCardVinodKumar: json["Voter Id Card Vinod Kumar"],
    signatureProofVinodKumar: json["Signature Proof Vinod Kumar"],
    form60VinodKumar: json["FORM 60 Vinod Kumar"],
    drivingLicenseSagarSudhirKarande: json["Driving License Sagar Sudhir Karande"],
    kycBackSagarSudhirKarande: json["KYC Back Sagar Sudhir Karande"],
    customerPhotoSagarSudhirKarande: json["Customer Photo Sagar Sudhir Karande"],
    kycSagarSudhirKarande: json["KYC Sagar Sudhir Karande"],
    voterIdCardSagarSudhirKarande: json["Voter Id Card Sagar Sudhir Karande"],
    currentAddressProofSagarSudhirKarande: json["Current Address Proof Sagar Sudhir Karande"],
    signatureProofSagarSudhirKarande: json["Signature Proof Sagar Sudhir Karande"],
    form60SagarSudhirKarande: json["FORM 60 Sagar Sudhir Karande"],
    landholdingDetails: json["Landholding Details"],
    proformaInvoice: json["Proforma Invoice"],
    partnershipLlpDeed: json["Partnership-LLP Deed"],
    nonKycAdditionalAddressProof: json["Non KYC Additional Address Proof"],
    kfs: json["KFS"],
    businessImage: json["Business Image"],
    pennyFuzzy: json["Penny Fuzzy"],
    certificateOfIncorporation: json["Certificate of Incorporation"],
    hufDeclarationCertificate: json["HUF Declaration certificate"],
    llpAgreementDeed: json["LLP Agreement Deed"],
    aoa: json["AOA"],
    cinDocument: json["CIN Document"],
    boardResolution: json["Board Resolution"],
    authorityLetter: json["Authority Letter"],
    partnershipDeed: json["Partnership Deed"],
    firmRegistartionCertificate: json["Firm Registartion Certificate"],
    dealerCommitmentLetter: json["Dealer Commitment Letter"],
    offerLetter2: json["Offer Letter 2"],
    deliveryOrder2: json["Delivery Order 2"],
    auditCommitteeApproval: json["Audit Committee Approval"],
    marginMoney2: json["Margin money2"],
    taxInvoice2: json["Tax invoice2"],
    performaInvoice2: json["Performa invoice2"],
    harvesterImage4: json["Harvester Image4"],
    harvesterImage3: json["Harvester Image3"],
    harvesterImage2: json["Harvester Image2"],
    harvesterImage1: json["Harvester Image1"],
    officePremises: json["Office Premises"],
    moa: json["MOA"],
    cliOrEmiProtectOrLoanAgreement: json["CLI OR EMI Protect OR Loan Agreement"],
    implementImage4: json["Implement image4"],
    implementImage3: json["Implement image3"],
    implementImage2: json["Implement image2"],
    implementImage1: json["Implement image1"],
    serialNumber: json["Serial Number"],
    assetValuationReport: json["Asset Valuation Report"],
    orissaSubsidyAgroPermitLetter: json["Orissa Subsidy Agro Permit Letter"],
    rc: json["RC"],
    generalInsurancePolicy: json["General Insurance POLICY"],
    otherDocument4: json["Other Document 4"],
    otherDocument3: json["Other Document 3"],
    otherDocument2: json["Other Document 2"],
    otherDocument1: json["Other Document 1"],
    chassisPlateImage: json["Chassis Plate Image"],
    hmrImage: json["HMR Image"],
    generalInsuranceQuotation: json["General Insurance Quotation"],
    residenceImage: json["Residence Image"],
    passbook: json["Passbook"],
    vehicleInspectionReport: json["Vehicle Inspection Report"],
    oldRcOrFormBExtractOrFop: json["Old RC Or Form B Extract OR FOP"],
    rtoBookletAllPages: json["RTO Booklet All Pages"],
    consentLetter: json["Consent Letter"],
    taxInvoice: json["Tax Invoice"],
    deliveryOrder: json["Delivery Order"],
    offerLetter: json["Offer Letter"],
    repaymentScheduleIrrSheet: json["Repayment Schedule IRR Sheet"],
    rcDocument: json["RC Document"],
    tractorImage4: json["Tractor Image4"],
    tractorImage3: json["Tractor Image3"],
    tractorImage2: json["Tractor Image2"],
    tractorImage1: json["Tractor Image1"],
    pdc: json["PDC"],
    physicalMandate: json["Physical Mandate"],
    marginMoneyReceipt: json["Margin money receipt"],
    invoice: json["Invoice"],
    panCardMangalParkash: json["PAN CARD Mangal Parkash"],
    panCardNareshKumar: json["PAN CARD Naresh Kumar"],
    currentAddressProofMangalParkash: json["Current Address Proof Mangal Parkash"],
    signatureProofMangalParkash: json["Signature Proof Mangal Parkash"],
    voterIdCardMangalParkash: json["Voter Id Card Mangal Parkash"],
    form60MangalParkash: json["FORM 60 Mangal Parkash"],
    kycBackMangalParkash: json["KYC Back Mangal Parkash"],
    customerPhotoMangalParkash: json["Customer Photo Mangal Parkash"],
    kycMangalParkash: json["KYC Mangal Parkash"],
    drivingLicenseMangalParkash: json["Driving License Mangal Parkash"],
    currentAddressProofNareshKumar: json["Current Address Proof Naresh Kumar"],
    signatureProofNareshKumar: json["Signature Proof Naresh Kumar"],
    voterIdCardNareshKumar: json["Voter Id Card Naresh Kumar"],
    form60NareshKumar: json["FORM 60 Naresh Kumar"],
    kycBackNareshKumar: json["KYC Back Naresh Kumar"],
    customerPhotoNareshKumar: json["Customer Photo Naresh Kumar"],
    kycNareshKumar: json["KYC Naresh Kumar"],
    drivingLicenseNareshKumar: json["Driving License Naresh Kumar"],
    panCardParmarKuldipsinh: json["PAN CARD Parmar Kuldipsinh"],
    panCardAnilKumar: json["PAN CARD Anil Kumar"],
    panCardManojLahuKarale: json["PAN CARD Manoj Lahu Karale"],
    drivingLicenseParmarKuldipsinh: json["Driving License Parmar Kuldipsinh"],
    kycBackParmarKuldipsinh: json["KYC Back Parmar Kuldipsinh"],
    customerPhotoParmarKuldipsinh: json["Customer Photo Parmar Kuldipsinh"],
    kycParmarKuldipsinh: json["KYC Parmar Kuldipsinh"],
    voterIdCardParmarKuldipsinh: json["Voter Id Card Parmar Kuldipsinh"],
    currentAddressProofParmarKuldipsinh: json["Current Address Proof Parmar Kuldipsinh"],
    signatureProofParmarKuldipsinh: json["Signature Proof Parmar Kuldipsinh"],
    form60ParmarKuldipsinh: json["FORM 60 Parmar Kuldipsinh"],
    drivingLicenseAnilKumar: json["Driving License Anil Kumar"],
    kycBackAnilKumar: json["KYC Back Anil Kumar"],
    customerPhotoAnilKumar: json["Customer Photo Anil Kumar"],
    kycAnilKumar: json["KYC Anil Kumar"],
    voterIdCardAnilKumar: json["Voter Id Card Anil Kumar"],
    currentAddressProofAnilKumar: json["Current Address Proof Anil Kumar"],
    signatureProofAnilKumar: json["Signature Proof Anil Kumar"],
    form60AnilKumar: json["FORM 60 Anil Kumar"],
    drivingLicenseManojLahuKarale: json["Driving License Manoj Lahu Karale"],
    kycBackManojLahuKarale: json["KYC Back Manoj Lahu Karale"],
    customerPhotoManojLahuKarale: json["Customer Photo Manoj Lahu Karale"],
    kycManojLahuKarale: json["KYC Manoj Lahu Karale"],
    voterIdCardManojLahuKarale: json["Voter Id Card Manoj Lahu Karale"],
    currentAddressProofManojLahuKarale: json["Current Address Proof Manoj Lahu Karale"],
    signatureProofManojLahuKarale: json["Signature Proof Manoj Lahu Karale"],
    form60ManojLahuKarale: json["FORM 60 Manoj Lahu Karale"],
    currentAddressProofVinodKumar: json["Current Address Proof Vinod Kumar"],
    panCardJadejaDigvijaysinh: json["PAN CARD Jadeja Digvijaysinh"],
    drivingLicenseJadejaDigvijaysinh: json["Driving License Jadeja Digvijaysinh"],
    kycBackJadejaDigvijaysinh: json["KYC Back Jadeja Digvijaysinh"],
    customerPhotoJadejaDigvijaysinh: json["Customer Photo Jadeja Digvijaysinh"],
    kycJadejaDigvijaysinh: json["KYC Jadeja Digvijaysinh"],
    voterIdCardJadejaDigvijaysinh: json["Voter Id Card Jadeja Digvijaysinh"],
    signatureProofJadejaDigvijaysinh: json["Signature Proof Jadeja Digvijaysinh"],
    form60JadejaDigvijaysinh: json["FORM 60 Jadeja Digvijaysinh"],
    panCardKunalAgarwal: json["PAN CARD Kunal Agarwal"],
    drivingLicenseKunalAgarwal: json["Driving License Kunal Agarwal"],
    kycBackKunalAgarwal: json["KYC Back Kunal Agarwal"],
    customerPhotoKunalAgarwal: json["Customer Photo Kunal Agarwal"],
    kycKunalAgarwal: json["KYC Kunal Agarwal"],
    voterIdCardKunalAgarwal: json["Voter Id Card Kunal Agarwal"],
    currentAddressProofKunalAgarwal: json["Current Address Proof Kunal Agarwal"],
    signatureProofKunalAgarwal: json["Signature Proof Kunal Agarwal"],
    form60KunalAgarwal: json["FORM 60 Kunal Agarwal"],
    panCardAjayKumar: json["PAN CARD Ajay Kumar"],
    drivingLicenseAjayKumar: json["Driving License Ajay Kumar"],
    kycBackAjayKumar: json["KYC Back Ajay Kumar"],
    customerPhotoAjayKumar: json["Customer Photo Ajay Kumar"],
    kycAjayKumar: json["KYC Ajay Kumar"],
    voterIdCardAjayKumar: json["Voter Id Card Ajay Kumar"],
    currentAddressProofAjayKumar: json["Current Address Proof Ajay Kumar"],
    signatureProofAjayKumar: json["Signature Proof Ajay Kumar"],
    form60AjayKumar: json["FORM 60 Ajay Kumar"],
    drivingLicenseAmolCeramicaPrivateLimited: json["Driving License AMOL CERAMICA PRIVATE LIMITED"],
    kycBackAmolCeramicaPrivateLimited: json["KYC Back AMOL CERAMICA PRIVATE LIMITED"],
    customerPhotoAmolCeramicaPrivateLimited: json["Customer Photo AMOL CERAMICA PRIVATE LIMITED"],
    kycAmolCeramicaPrivateLimited: json["KYC AMOL CERAMICA PRIVATE LIMITED"],
    gstDocumentAmolCeramicaPrivateLimited: json["GST Document AMOL CERAMICA PRIVATE LIMITED"],
    voterIdCardAmolCeramicaPrivateLimited: json["Voter Id Card AMOL CERAMICA PRIVATE LIMITED"],
    panCardAmolCeramicaPrivateLimited: json["PAN CARD AMOL CERAMICA PRIVATE LIMITED"],
    drivingLicenseVedgangaMilkAndMilkProducts: json["Driving License VEDGANGA MILK AND MILK PRODUCTS"],
    kycBackVedgangaMilkAndMilkProducts: json["KYC Back VEDGANGA MILK AND MILK PRODUCTS"],
    customerPhotoVedgangaMilkAndMilkProducts: json["Customer Photo VEDGANGA MILK AND MILK PRODUCTS"],
    kycVedgangaMilkAndMilkProducts: json["KYC VEDGANGA MILK AND MILK PRODUCTS"],
    gstDocumentVedgangaMilkAndMilkProducts: json["GST Document VEDGANGA MILK AND MILK PRODUCTS"],
    voterIdCardVedgangaMilkAndMilkProducts: json["Voter Id Card VEDGANGA MILK AND MILK PRODUCTS"],
    panCardVedgangaMilkAndMilkProducts: json["PAN CARD VEDGANGA MILK AND MILK PRODUCTS"],
    drivingLicenseRitvikJain: json["Driving License Ritvik Jain"],
    kycBackRitvikJain: json["KYC Back Ritvik Jain"],
    customerPhotoRitvikJain: json["Customer Photo Ritvik Jain"],
    kycRitvikJain: json["KYC Ritvik Jain"],
    voterIdCardRitvikJain: json["Voter Id Card Ritvik Jain"],
    currentAddressProofRitvikJain: json["Current Address Proof Ritvik Jain"],
    signatureProofRitvikJain: json["Signature Proof Ritvik Jain"],
    form60RitvikJain: json["FORM 60 Ritvik Jain"],
    drivingLicenseEcoglobePackagingPrivateLimited: json["Driving License ECOGLOBE PACKAGING PRIVATE LIMITED"],
    kycBackEcoglobePackagingPrivateLimited: json["KYC Back ECOGLOBE PACKAGING PRIVATE LIMITED"],
    customerPhotoEcoglobePackagingPrivateLimited: json["Customer Photo ECOGLOBE PACKAGING PRIVATE LIMITED"],
    kycEcoglobePackagingPrivateLimited: json["KYC ECOGLOBE PACKAGING PRIVATE LIMITED"],
    gstDocumentEcoglobePackagingPrivateLimited: json["GST Document ECOGLOBE PACKAGING PRIVATE LIMITED"],
    voterIdCardEcoglobePackagingPrivateLimited: json["Voter Id Card ECOGLOBE PACKAGING PRIVATE LIMITED"],
    panCardEcoglobePackagingPrivateLimited: json["PAN CARD ECOGLOBE PACKAGING PRIVATE LIMITED"],
    panCardPramod: json["PAN CARD pramod"],
    voterIdCardPramod: json["Voter Id Card pramod"],
    kycBackPramod: json["KYC Back pramod ."],
    customerPhotoPramod: json["Customer Photo pramod"],
    kycPramod: json["KYC pramod ."],
    drivingLicensePramod: json["Driving License pramod"],
    gstDocumentPramod: json["GST Document pramod"],
    panCardAnilKuma: json["PAN CARD Anil Kuma"],
    drivingLicenseAnilKuma: json["Driving License Anil Kuma"],
    kycBackAnilKuma: json["KYC Back Anil Kuma"],
    customerPhotoAnilKuma: json["Customer Photo Anil Kuma"],
    kycAnilKuma: json["KYC Anil Kuma"],
    voterIdCardAnilKuma: json["Voter Id Card Anil Kuma"],
    currentAddressProofAnilKuma: json["Current Address Proof Anil Kuma"],
    signatureProofAnilKuma: json["Signature Proof Anil Kuma"],
    form60AnilKuma: json["FORM 60 Anil Kuma"],
    panCardAdilKumar: json["PAN CARD Adil Kumar"],
    drivingLicenseAdilKumar: json["Driving License Adil Kumar"],
    kycBackAdilKumar: json["KYC Back Adil Kumar"],
    customerPhotoAdilKumar: json["Customer Photo Adil Kumar"],
    kycAdilKumar: json["KYC Adil Kumar"],
    voterIdCardAdilKumar: json["Voter Id Card Adil Kumar"],
    signatureProofAdilKumar: json["Signature Proof Adil Kumar"],
    form60AdilKumar: json["FORM 60 Adil Kumar"],
    drivingLicenseAnitKumar: json["Driving License Anit Kumar"],
    kycBackAnitKumar: json["KYC Back Anit Kumar"],
    customerPhotoAnitKumar: json["Customer Photo Anit Kumar"],
    kycAnitKumar: json["KYC Anit Kumar"],
    voterIdCardAnitKumar: json["Voter Id Card Anit Kumar"],
    currentAddressProofAnitKumar: json["Current Address Proof Anit Kumar"],
    signatureProofAnitKumar: json["Signature Proof Anit Kumar"],
    form60AnitKumar: json["FORM 60 Anit Kumar"],
    panCardAniKumar: json["PAN CARD Ani Kumar"],
    currentAddressProofAniKumar: json["Current Address Proof Ani Kumar"],
    signatureProofAniKumar: json["Signature Proof Ani Kumar"],
    voterIdCardAniKumar: json["Voter Id Card Ani Kumar"],
    form60AniKumar: json["FORM 60 Ani Kumar"],
    kycBackAniKumar: json["KYC Back Ani Kumar"],
    customerPhotoAniKumar: json["Customer Photo Ani Kumar"],
    kycAniKumar: json["KYC Ani Kumar"],
    drivingLicenseAniKumar: json["Driving License Ani Kumar"],
    panCardAmniKumar: json["PAN CARD Amni Kumar"],
    drivingLicenseAmniKumar: json["Driving License Amni Kumar"],
    kycBackAmniKumar: json["KYC Back Amni Kumar"],
    customerPhotoAmniKumar: json["Customer Photo Amni Kumar"],
    kycAmniKumar: json["KYC Amni Kumar"],
    voterIdCardAmniKumar: json["Voter Id Card Amni Kumar"],
    currentAddressProofAmniKumar: json["Current Address Proof Amni Kumar"],
    signatureProofAmniKumar: json["Signature Proof Amni Kumar"],
    form60AmniKumar: json["FORM 60 Amni Kumar"],
    drivingLicenseManejTahuKarale: json["Driving License Manej tahu karale"],
    kycBackManejTahuKarale: json["KYC Back Manej tahu karale"],
    customerPhotoManejTahuKarale: json["Customer Photo Manej tahu karale"],
    kycManejTahuKarale: json["KYC Manej tahu karale"],
    voterIdCardManejTahuKarale: json["Voter Id Card Manej tahu karale"],
    currentAddressProofManejTahuKarale: json["Current Address Proof Manej tahu karale"],
    signatureProofManejTahuKarale: json["Signature Proof Manej tahu karale"],
    form60ManejTahuKarale: json["FORM 60 Manej tahu karale"],
  );

  Map<String, dynamic> toJson() => {
    "PAN CARD Vinod Kumar": panCardVinodKumar,
    "PAN CARD Sagar Sudhir Karande": panCardSagarSudhirKarande,
    "Driving License Vinod Kumar": drivingLicenseVinodKumar,
    "KYC Back Vinod Kumar": kycBackVinodKumar,
    "Customer Photo Vinod Kumar": customerPhotoVinodKumar,
    "KYC Vinod Kumar": kycVinodKumar,
    "Voter Id Card Vinod Kumar": voterIdCardVinodKumar,
    "Signature Proof Vinod Kumar": signatureProofVinodKumar,
    "FORM 60 Vinod Kumar": form60VinodKumar,
    "Driving License Sagar Sudhir Karande": drivingLicenseSagarSudhirKarande,
    "KYC Back Sagar Sudhir Karande": kycBackSagarSudhirKarande,
    "Customer Photo Sagar Sudhir Karande": customerPhotoSagarSudhirKarande,
    "KYC Sagar Sudhir Karande": kycSagarSudhirKarande,
    "Voter Id Card Sagar Sudhir Karande": voterIdCardSagarSudhirKarande,
    "Current Address Proof Sagar Sudhir Karande": currentAddressProofSagarSudhirKarande,
    "Signature Proof Sagar Sudhir Karande": signatureProofSagarSudhirKarande,
    "FORM 60 Sagar Sudhir Karande": form60SagarSudhirKarande,
    "Landholding Details": landholdingDetails,
    "Proforma Invoice": proformaInvoice,
    "Partnership-LLP Deed": partnershipLlpDeed,
    "Non KYC Additional Address Proof": nonKycAdditionalAddressProof,
    "KFS": kfs,
    "Business Image": businessImage,
    "Penny Fuzzy": pennyFuzzy,
    "Certificate of Incorporation": certificateOfIncorporation,
    "HUF Declaration certificate": hufDeclarationCertificate,
    "LLP Agreement Deed": llpAgreementDeed,
    "AOA": aoa,
    "CIN Document": cinDocument,
    "Board Resolution": boardResolution,
    "Authority Letter": authorityLetter,
    "Partnership Deed": partnershipDeed,
    "Firm Registartion Certificate": firmRegistartionCertificate,
    "Dealer Commitment Letter": dealerCommitmentLetter,
    "Offer Letter 2": offerLetter2,
    "Delivery Order 2": deliveryOrder2,
    "Audit Committee Approval": auditCommitteeApproval,
    "Margin money2": marginMoney2,
    "Tax invoice2": taxInvoice2,
    "Performa invoice2": performaInvoice2,
    "Harvester Image4": harvesterImage4,
    "Harvester Image3": harvesterImage3,
    "Harvester Image2": harvesterImage2,
    "Harvester Image1": harvesterImage1,
    "Office Premises": officePremises,
    "MOA": moa,
    "CLI OR EMI Protect OR Loan Agreement": cliOrEmiProtectOrLoanAgreement,
    "Implement image4": implementImage4,
    "Implement image3": implementImage3,
    "Implement image2": implementImage2,
    "Implement image1": implementImage1,
    "Serial Number": serialNumber,
    "Asset Valuation Report": assetValuationReport,
    "Orissa Subsidy Agro Permit Letter": orissaSubsidyAgroPermitLetter,
    "RC": rc,
    "General Insurance POLICY": generalInsurancePolicy,
    "Other Document 4": otherDocument4,
    "Other Document 3": otherDocument3,
    "Other Document 2": otherDocument2,
    "Other Document 1": otherDocument1,
    "Chassis Plate Image": chassisPlateImage,
    "HMR Image": hmrImage,
    "General Insurance Quotation": generalInsuranceQuotation,
    "Residence Image": residenceImage,
    "Passbook": passbook,
    "Vehicle Inspection Report": vehicleInspectionReport,
    "Old RC Or Form B Extract OR FOP": oldRcOrFormBExtractOrFop,
    "RTO Booklet All Pages": rtoBookletAllPages,
    "Consent Letter": consentLetter,
    "Tax Invoice": taxInvoice,
    "Delivery Order": deliveryOrder,
    "Offer Letter": offerLetter,
    "Repayment Schedule IRR Sheet": repaymentScheduleIrrSheet,
    "RC Document": rcDocument,
    "Tractor Image4": tractorImage4,
    "Tractor Image3": tractorImage3,
    "Tractor Image2": tractorImage2,
    "Tractor Image1": tractorImage1,
    "PDC": pdc,
    "Physical Mandate": physicalMandate,
    "Margin money receipt": marginMoneyReceipt,
    "Invoice": invoice,
    "PAN CARD Mangal Parkash": panCardMangalParkash,
    "PAN CARD Naresh Kumar": panCardNareshKumar,
    "Current Address Proof Mangal Parkash": currentAddressProofMangalParkash,
    "Signature Proof Mangal Parkash": signatureProofMangalParkash,
    "Voter Id Card Mangal Parkash": voterIdCardMangalParkash,
    "FORM 60 Mangal Parkash": form60MangalParkash,
    "KYC Back Mangal Parkash": kycBackMangalParkash,
    "Customer Photo Mangal Parkash": customerPhotoMangalParkash,
    "KYC Mangal Parkash": kycMangalParkash,
    "Driving License Mangal Parkash": drivingLicenseMangalParkash,
    "Current Address Proof Naresh Kumar": currentAddressProofNareshKumar,
    "Signature Proof Naresh Kumar": signatureProofNareshKumar,
    "Voter Id Card Naresh Kumar": voterIdCardNareshKumar,
    "FORM 60 Naresh Kumar": form60NareshKumar,
    "KYC Back Naresh Kumar": kycBackNareshKumar,
    "Customer Photo Naresh Kumar": customerPhotoNareshKumar,
    "KYC Naresh Kumar": kycNareshKumar,
    "Driving License Naresh Kumar": drivingLicenseNareshKumar,
    "PAN CARD Parmar Kuldipsinh": panCardParmarKuldipsinh,
    "PAN CARD Anil Kumar": panCardAnilKumar,
    "PAN CARD Manoj Lahu Karale": panCardManojLahuKarale,
    "Driving License Parmar Kuldipsinh": drivingLicenseParmarKuldipsinh,
    "KYC Back Parmar Kuldipsinh": kycBackParmarKuldipsinh,
    "Customer Photo Parmar Kuldipsinh": customerPhotoParmarKuldipsinh,
    "KYC Parmar Kuldipsinh": kycParmarKuldipsinh,
    "Voter Id Card Parmar Kuldipsinh": voterIdCardParmarKuldipsinh,
    "Current Address Proof Parmar Kuldipsinh": currentAddressProofParmarKuldipsinh,
    "Signature Proof Parmar Kuldipsinh": signatureProofParmarKuldipsinh,
    "FORM 60 Parmar Kuldipsinh": form60ParmarKuldipsinh,
    "Driving License Anil Kumar": drivingLicenseAnilKumar,
    "KYC Back Anil Kumar": kycBackAnilKumar,
    "Customer Photo Anil Kumar": customerPhotoAnilKumar,
    "KYC Anil Kumar": kycAnilKumar,
    "Voter Id Card Anil Kumar": voterIdCardAnilKumar,
    "Current Address Proof Anil Kumar": currentAddressProofAnilKumar,
    "Signature Proof Anil Kumar": signatureProofAnilKumar,
    "FORM 60 Anil Kumar": form60AnilKumar,
    "Driving License Manoj Lahu Karale": drivingLicenseManojLahuKarale,
    "KYC Back Manoj Lahu Karale": kycBackManojLahuKarale,
    "Customer Photo Manoj Lahu Karale": customerPhotoManojLahuKarale,
    "KYC Manoj Lahu Karale": kycManojLahuKarale,
    "Voter Id Card Manoj Lahu Karale": voterIdCardManojLahuKarale,
    "Current Address Proof Manoj Lahu Karale": currentAddressProofManojLahuKarale,
    "Signature Proof Manoj Lahu Karale": signatureProofManojLahuKarale,
    "FORM 60 Manoj Lahu Karale": form60ManojLahuKarale,
    "Current Address Proof Vinod Kumar": currentAddressProofVinodKumar,
    "PAN CARD Jadeja Digvijaysinh": panCardJadejaDigvijaysinh,
    "Driving License Jadeja Digvijaysinh": drivingLicenseJadejaDigvijaysinh,
    "KYC Back Jadeja Digvijaysinh": kycBackJadejaDigvijaysinh,
    "Customer Photo Jadeja Digvijaysinh": customerPhotoJadejaDigvijaysinh,
    "KYC Jadeja Digvijaysinh": kycJadejaDigvijaysinh,
    "Voter Id Card Jadeja Digvijaysinh": voterIdCardJadejaDigvijaysinh,
    "Signature Proof Jadeja Digvijaysinh": signatureProofJadejaDigvijaysinh,
    "FORM 60 Jadeja Digvijaysinh": form60JadejaDigvijaysinh,
    "PAN CARD Kunal Agarwal": panCardKunalAgarwal,
    "Driving License Kunal Agarwal": drivingLicenseKunalAgarwal,
    "KYC Back Kunal Agarwal": kycBackKunalAgarwal,
    "Customer Photo Kunal Agarwal": customerPhotoKunalAgarwal,
    "KYC Kunal Agarwal": kycKunalAgarwal,
    "Voter Id Card Kunal Agarwal": voterIdCardKunalAgarwal,
    "Current Address Proof Kunal Agarwal": currentAddressProofKunalAgarwal,
    "Signature Proof Kunal Agarwal": signatureProofKunalAgarwal,
    "FORM 60 Kunal Agarwal": form60KunalAgarwal,
    "PAN CARD Ajay Kumar": panCardAjayKumar,
    "Driving License Ajay Kumar": drivingLicenseAjayKumar,
    "KYC Back Ajay Kumar": kycBackAjayKumar,
    "Customer Photo Ajay Kumar": customerPhotoAjayKumar,
    "KYC Ajay Kumar": kycAjayKumar,
    "Voter Id Card Ajay Kumar": voterIdCardAjayKumar,
    "Current Address Proof Ajay Kumar": currentAddressProofAjayKumar,
    "Signature Proof Ajay Kumar": signatureProofAjayKumar,
    "FORM 60 Ajay Kumar": form60AjayKumar,
    "Driving License AMOL CERAMICA PRIVATE LIMITED": drivingLicenseAmolCeramicaPrivateLimited,
    "KYC Back AMOL CERAMICA PRIVATE LIMITED": kycBackAmolCeramicaPrivateLimited,
    "Customer Photo AMOL CERAMICA PRIVATE LIMITED": customerPhotoAmolCeramicaPrivateLimited,
    "KYC AMOL CERAMICA PRIVATE LIMITED": kycAmolCeramicaPrivateLimited,
    "GST Document AMOL CERAMICA PRIVATE LIMITED": gstDocumentAmolCeramicaPrivateLimited,
    "Voter Id Card AMOL CERAMICA PRIVATE LIMITED": voterIdCardAmolCeramicaPrivateLimited,
    "PAN CARD AMOL CERAMICA PRIVATE LIMITED": panCardAmolCeramicaPrivateLimited,
    "Driving License VEDGANGA MILK AND MILK PRODUCTS": drivingLicenseVedgangaMilkAndMilkProducts,
    "KYC Back VEDGANGA MILK AND MILK PRODUCTS": kycBackVedgangaMilkAndMilkProducts,
    "Customer Photo VEDGANGA MILK AND MILK PRODUCTS": customerPhotoVedgangaMilkAndMilkProducts,
    "KYC VEDGANGA MILK AND MILK PRODUCTS": kycVedgangaMilkAndMilkProducts,
    "GST Document VEDGANGA MILK AND MILK PRODUCTS": gstDocumentVedgangaMilkAndMilkProducts,
    "Voter Id Card VEDGANGA MILK AND MILK PRODUCTS": voterIdCardVedgangaMilkAndMilkProducts,
    "PAN CARD VEDGANGA MILK AND MILK PRODUCTS": panCardVedgangaMilkAndMilkProducts,
    "Driving License Ritvik Jain": drivingLicenseRitvikJain,
    "KYC Back Ritvik Jain": kycBackRitvikJain,
    "Customer Photo Ritvik Jain": customerPhotoRitvikJain,
    "KYC Ritvik Jain": kycRitvikJain,
    "Voter Id Card Ritvik Jain": voterIdCardRitvikJain,
    "Current Address Proof Ritvik Jain": currentAddressProofRitvikJain,
    "Signature Proof Ritvik Jain": signatureProofRitvikJain,
    "FORM 60 Ritvik Jain": form60RitvikJain,
    "Driving License ECOGLOBE PACKAGING PRIVATE LIMITED": drivingLicenseEcoglobePackagingPrivateLimited,
    "KYC Back ECOGLOBE PACKAGING PRIVATE LIMITED": kycBackEcoglobePackagingPrivateLimited,
    "Customer Photo ECOGLOBE PACKAGING PRIVATE LIMITED": customerPhotoEcoglobePackagingPrivateLimited,
    "KYC ECOGLOBE PACKAGING PRIVATE LIMITED": kycEcoglobePackagingPrivateLimited,
    "GST Document ECOGLOBE PACKAGING PRIVATE LIMITED": gstDocumentEcoglobePackagingPrivateLimited,
    "Voter Id Card ECOGLOBE PACKAGING PRIVATE LIMITED": voterIdCardEcoglobePackagingPrivateLimited,
    "PAN CARD ECOGLOBE PACKAGING PRIVATE LIMITED": panCardEcoglobePackagingPrivateLimited,
    "PAN CARD pramod": panCardPramod,
    "Voter Id Card pramod": voterIdCardPramod,
    "KYC Back pramod .": kycBackPramod,
    "Customer Photo pramod": customerPhotoPramod,
    "KYC pramod .": kycPramod,
    "Driving License pramod": drivingLicensePramod,
    "GST Document pramod": gstDocumentPramod,
    "PAN CARD Anil Kuma": panCardAnilKuma,
    "Driving License Anil Kuma": drivingLicenseAnilKuma,
    "KYC Back Anil Kuma": kycBackAnilKuma,
    "Customer Photo Anil Kuma": customerPhotoAnilKuma,
    "KYC Anil Kuma": kycAnilKuma,
    "Voter Id Card Anil Kuma": voterIdCardAnilKuma,
    "Current Address Proof Anil Kuma": currentAddressProofAnilKuma,
    "Signature Proof Anil Kuma": signatureProofAnilKuma,
    "FORM 60 Anil Kuma": form60AnilKuma,
    "PAN CARD Adil Kumar": panCardAdilKumar,
    "Driving License Adil Kumar": drivingLicenseAdilKumar,
    "KYC Back Adil Kumar": kycBackAdilKumar,
    "Customer Photo Adil Kumar": customerPhotoAdilKumar,
    "KYC Adil Kumar": kycAdilKumar,
    "Voter Id Card Adil Kumar": voterIdCardAdilKumar,
    "Signature Proof Adil Kumar": signatureProofAdilKumar,
    "FORM 60 Adil Kumar": form60AdilKumar,
    "Driving License Anit Kumar": drivingLicenseAnitKumar,
    "KYC Back Anit Kumar": kycBackAnitKumar,
    "Customer Photo Anit Kumar": customerPhotoAnitKumar,
    "KYC Anit Kumar": kycAnitKumar,
    "Voter Id Card Anit Kumar": voterIdCardAnitKumar,
    "Current Address Proof Anit Kumar": currentAddressProofAnitKumar,
    "Signature Proof Anit Kumar": signatureProofAnitKumar,
    "FORM 60 Anit Kumar": form60AnitKumar,
    "PAN CARD Ani Kumar": panCardAniKumar,
    "Current Address Proof Ani Kumar": currentAddressProofAniKumar,
    "Signature Proof Ani Kumar": signatureProofAniKumar,
    "Voter Id Card Ani Kumar": voterIdCardAniKumar,
    "FORM 60 Ani Kumar": form60AniKumar,
    "KYC Back Ani Kumar": kycBackAniKumar,
    "Customer Photo Ani Kumar": customerPhotoAniKumar,
    "KYC Ani Kumar": kycAniKumar,
    "Driving License Ani Kumar": drivingLicenseAniKumar,
    "PAN CARD Amni Kumar": panCardAmniKumar,
    "Driving License Amni Kumar": drivingLicenseAmniKumar,
    "KYC Back Amni Kumar": kycBackAmniKumar,
    "Customer Photo Amni Kumar": customerPhotoAmniKumar,
    "KYC Amni Kumar": kycAmniKumar,
    "Voter Id Card Amni Kumar": voterIdCardAmniKumar,
    "Current Address Proof Amni Kumar": currentAddressProofAmniKumar,
    "Signature Proof Amni Kumar": signatureProofAmniKumar,
    "FORM 60 Amni Kumar": form60AmniKumar,
    "Driving License Manej tahu karale": drivingLicenseManejTahuKarale,
    "KYC Back Manej tahu karale": kycBackManejTahuKarale,
    "Customer Photo Manej tahu karale": customerPhotoManejTahuKarale,
    "KYC Manej tahu karale": kycManejTahuKarale,
    "Voter Id Card Manej tahu karale": voterIdCardManejTahuKarale,
    "Current Address Proof Manej tahu karale": currentAddressProofManejTahuKarale,
    "Signature Proof Manej tahu karale": signatureProofManejTahuKarale,
    "FORM 60 Manej tahu karale": form60ManejTahuKarale,
  };
}

class PddDocuments {
  PddDocuments();

  factory PddDocuments.fromRawJson(String str) => PddDocuments.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PddDocuments.fromJson(Map<String, dynamic> json) => PddDocuments(
  );

  Map<String, dynamic> toJson() => {
  };
}
