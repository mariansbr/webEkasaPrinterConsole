unit Elcomm_TLB_3_0;

// ************************************************************************ //
// WARNING
// -------
// The types declared in this file were generated from data read from a
// Type Library. If this type library is explicitly or indirectly (via
// another type library referring to this type library) re-imported, or the
// 'Refresh' command of the Type Library Editor activated while editing the
// Type Library, the contents of this file will be regenerated and all
// manual modifications will be lost.
// ************************************************************************ //

// $Rev: 34747 $
// File generated on 4.11.2020 10:09:23 from Type Library described below.

// ************************************************************************  //
// Type Lib: c:\mrpwin\fiskal\ekasa\elcomm.tlb (1)
// LIBID: {B009C486-97B8-402F-A34A-B699AC920D7D}
// LCID: 0
// Helpfile:
// HelpString: Cash register communication library
// DepndLst:
// (1) v2.0 stdole, (C:\Windows\system32\stdole2.tlb)
// (2) v2.4 mscorlib, (C:\Windows\Microsoft.NET\Framework\v4.0.30319\mscorlib.tlb)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers.
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
{$ALIGN 4}

interface

uses Windows, ActiveX, Classes, Graphics, {mscorlib_TLB,} OleServer, StdVCL,
  Variants;

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:
// Type Libraries     : LIBID_xxxx
// CoClasses          : CLASS_xxxx
// DISPInterfaces     : DIID_xxxx
// Non-DISP interfaces: IID_xxxx
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  ElcommMajorVersion = 3;
  ElcommMinorVersion = 0;

  LIBID_Elcomm: TGUID = '{B009C486-97B8-402F-A34A-B699AC920D7D}';

  IID_ICommLib: TGUID = '{3FB2F51F-4891-3679-9F65-54EA3D9EAE57}';
  CLASS_CCommLib: TGUID = '{7EAA3E8B-B7BD-338A-B5F2-7BC820D5A04A}';
  IID__StaticExport: TGUID = '{6FC46EE2-5F84-32A1-8947-6625FE1CC512}';
  CLASS_StaticExport: TGUID = '{58636363-FDD1-3EE7-8261-DBB4EDEC9A3D}';

  // *********************************************************************//
  // Declaration of Enumerations defined in Type Library
  // *********************************************************************//
  // Constants for enum eCashRegisterUID
type
  eCashRegisterUID = TOleEnum;

const
  eCashRegisterUID_NotSupported = $00000000;
  eCashRegisterUID_Euro50T = $00000149;
  eCashRegisterUID_Euro50TE = $0000014A;
  eCashRegisterUID_Euro50TX = $0000014B;
  eCashRegisterUID_Euro50FP = $0000014C;
  eCashRegisterUID_Euro50MEDI = $0000014D;
  eCashRegisterUID_Euro50SMART = $0000014E;
  eCashRegisterUID_Euro50TEi = $00000152;
  eCashRegisterUID_Euro50iFP = $00000154;
  eCashRegisterUID_Euro150T = $00000169;
  eCashRegisterUID_Euro150TE = $0000016A;
  eCashRegisterUID_Euro150TX = $0000016B;
  eCashRegisterUID_Euro150FP = $0000016C;
  eCashRegisterUID_Euro150TEi = $0000016E;
  eCashRegisterUID_Euro155T = $00000179;
  eCashRegisterUID_Euro155TE = $0000017A;
  eCashRegisterUID_Euro155TX = $0000017B;
  eCashRegisterUID_Euro155FP = $0000017C;
  eCashRegisterUID_Euro155TEi = $0000017E;
  eCashRegisterUID_Euro80A = $00000189;
  eCashRegisterUID_Euro80B = $0000018A;
  eCashRegisterUID_Euro80L = $0000018B;
  eCashRegisterUID_Euro80W = $0000018C;
  eCashRegisterUID_Euro2100i = $000001A9;

  // Constants for enum eClearRecord
type
  eClearRecord = TOleEnum;

const
  eClearRecord_StandardMode = $00000000;
  eClearRecord_PrefferImmediately = $00000001;
  eClearRecord_OrderImmediately = $00000002;
  eClearRecord_PrefferDelayed = $00000003;
  eClearRecord_StartRequest = $00000004;
  eClearRecord_StartOrder = $00000005;
  eClearRecord_DeleteItemsToClearList = $00000006;

  // Constants for enum eErrLevel
type
  eErrLevel = TOleEnum;

const
  eErrLevel_AllOk = $00000000;
  eErrLevel_Warning_DataChange = $00000001;
  eErrLevel_Warning_NotSupported = $00000002;
  eErrLevel_NoData = $00000003;
  eErrLevel_Warning_NotFullSupport = $00000004;
  eErrLevel_DataError = $00000005;
  eErrLevel_ErrorSend = $00000006;
  eErrLevel_CrititalError = $00000007;
  eErrLevel_UnknownError = $00000008;
  eErrLevel_UnknownWarning = $00000009;
  eErrLevel_UnknownExeption = $0000000A;

  // Constants for enum eErrTypes
type
  eErrTypes = TOleEnum;

const
  eErrTypes_AllOk = $00000000;
  eErrTypes_Warning = $00000001;
  eErrTypes_DataError = $00000002;
  eErrTypes_CriticalError = $00000003;
  eErrTypes_Unknown = $00000004;

  // Constants for enum eGRetVal
type
  eGRetVal = TOleEnum;

const
  eGRetVal_AllOk = $00000000;
  eGRetVal_CommandAccepted = $00000001;
  eGRetVal_NoMoreDataToRead = $00001000;
  eGRetVal_TableIsReadOnly = $00001001;
  eGRetVal_TableOpenReadAllWriteNone = $000010F0;
  eGRetVal_TableOpenReadOneWriteNone = $00001010;
  eGRetVal_TableOpenReadBlockWriteNone = $00001020;
  eGRetVal_TableOpenReadNoneWriteOne = $00001100;
  eGRetVal_TableOpenReadAllWriteOne = $000011F0;
  eGRetVal_TableOpenReadOneWriteOne = $00001110;
  eGRetVal_TableOpenReadBlockWriteOne = $00001120;
  eGRetVal_TableOpenReadNoneWriteBlock = $00001200;
  eGRetVal_TableOpenReadAllWriteBlock = $000012F0;
  eGRetVal_TableOpenReadOneWriteBlock = $00001210;
  eGRetVal_TableOpenReadBlockWriteBlock = $00001220;
  eGRetVal_TableOpenReadNoneWriteAll = $00001F00;
  eGRetVal_TableOpenReadAllWriteAll = $00001FF0;
  eGRetVal_TableOpenReadOneWriteAll = $00001F10;
  eGRetVal_TableOpenReadBlockWriteAll = $00001F20;
  eGRetVal_IdenticalNewValues = $04601001;
  eGRetVal_IdenticalNewValues_NoChangeInFM = $04601002;
  eGRetVal_IdenticalNewTextLogo_NoChangeInFM = $04601003;
  eGRetVal_IdenticalNewTaxValues_NoChangeInFM = $04601004;
  eGRetVal_UnknownSomeHeaderItems = $20001001;
  eGRetVal_FilterNotSupportNZeroSale = $20001002;
  eGRetVal_FilterNotSupportRangeNZeroSale = $20001003;
  eGRetVal_FilterOutOfRange = $21101000;
  eGRetVal_RestartRequiredToApplyChanges = $24025001;
  eGRetVal_CertificateExpired = $20140001;
  eGRetVal_CertificateValidInFuture = $20140002;
  eGRetVal_JournalFullWarning_80_percent = $24070001;
  eGRetVal_JournalFullWarning_95_percent = $24070002;
  eGRetVal_TextJournalFullWarning_80_percent = $24070003;
  eGRetVal_TextJournalFullWarning_95_percent = $24070004;
  eGRetVal_DataJournalFullWarning_80_percent = $24070005;
  eGRetVal_DataJournalFullWarning_95_percent = $24070006;
  eGRetVal_JournalFullWarning_MakeReport = $24070007;
  eGRetVal_DataJournalFullWarning_MakeReport = $24070008;
  eGRetVal_TextJournalFullWarning_MakeReport = $24070009;
  eGRetVal_JournalFullWarning_DocCountLimitNear = $2407000A;
  eGRetVal_JournalFullWarning_TextDocCountLimitNear = $2407000B;
  eGRetVal_JournalFullWarning_DataDocCountLimitNear = $2407000C;
  eGRetVal_JournalFullWarning_LastDocument = $2407000D;
  eGRetVal_JournalFullWarning_LastTextDocument = $2407000E;
  eGRetVal_JournalFullWarning_LastDataDocument = $2407000F;
  eGRetVal_ProtectedStorageUsedCapacityReached80Percent = $27000001;
  eGRetVal_ProtectedStorageUsedCapacityReached95Percent = $27000002;
  eGRetVal_ReceiptModeIsIgnored = $21102001;
  eGRetVal_DescriptionTextNotFound = $23400001;
  eGRetVal_ServiceIntervalPassed = $24600001;
  eGRetVal_NewFirmwareAvailable_Update = $24600002;
  eGRetVal_FM_Warning_AlmostFull = $24604001;
  eGRetVal_TaxServerConnectionTestRequired = $24605001;
  eGRetVal_UnsendRegisteredReceiptsFound = $24660001;
  eGRetVal_NetworkInitialisationFailedWarning = $25000001;
  eGRetVal_InvalidInputZeroDataWarning = $21140001;
  eGRetVal_IntValueOutOfRangeWarning = $21140002;
  eGRetVal_InvalidInputValueWarning = $21140003;
  eGRetVal_DataValueOutOfRangeWarning = $21140004;
  eGRetVal_InvalidValueEcrWarning = $24140003;
  eGRetVal_FilterNotSupported = $40001002;
  eGRetVal_TableRecordIsReadOnly = $40001003;
  eGRetVal_NotSupportedValue = $40005001;
  eGRetVal_InternalErrorTableInfo = $40090001;
  eGRetVal_CountryListNotInitialized = $40300001;
  eGRetVal_EcrNotInitialised = $40300002;
  eGRetVal_NotConnected = $40300101;
  eGRetVal_CanNotApplyCommand_DisconnectFirst = $40300102;
  eGRetVal_CanNotDisconnect = $40300103;
  eGRetVal_AlreadyConnected = $40300104;
  eGRetVal_CommunicationInProgress = $40300105;
  eGRetVal_IncorrectEcrState = $40300106;
  eGRetVal_CanNotSaveFileNotOpen = $40300201;
  eGRetVal_InvalidCallOrder = $40300301;
  eGRetVal_Disposed = $40300302;
  eGRetVal_ReceiptIsOpen = $40302001;
  eGRetVal_ReceiptIsNotOpen = $40302002;
  eGRetVal_TableIsOpen = $40301001;
  eGRetVal_TableNotOpen = $40301002;
  eGRetVal_TableOpenedAsReadOnly = $40301003;
  eGRetVal_HeaderNotSet = $40301004;
  eGRetVal_ReadNextBeforeReadFirst = $40301005;
  eGRetVal_InvalidInputMissingData = $41140001;
  eGRetVal_InvalidInputZeroData = $41140002;
  eGRetVal_IntValueOutOfRange = $41140003;
  eGRetVal_InvalidValue = $41140004;
  eGRetVal_InvalidInputDataValue = $41140005;
  eGRetVal_InvalidInputDataType = $41140006;
  eGRetVal_InvalidInputTooMuchData = $41140007;
  eGRetVal_InvalidInputDuplicateData = $41140008;
  eGRetVal_ItemIndexValueOutOfRange = $41140009;
  eGRetVal_DataValueOutOfRange = $4114000A;
  eGRetVal_ConfigValueOutOfRange = $4114000B;
  eGRetVal_ReceiptModeNotGiven = $41102001;
  eGRetVal_Unknown_or_NA_Record = $40140001;
  eGRetVal_InvalidVatNo = $40140002;
  eGRetVal_BadPrivateKey = $40140003;
  eGRetVal_BadCertificate = $40140004;
  eGRetVal_CertificateNotValid = $40140005;
  eGRetVal_DayOpenedMoreThan_24_hours = $44660001;
  eGRetVal_ReceiptError_UnfinishedEuroStep = $44660002;
  eGRetVal_NotAllowedInServiceMode = $44660003;
  eGRetVal_TimeSpanBetweenReportsExceeded = $44660004;
  eGRetVal_OpenDay = $44660005;
  eGRetVal_CloseDay = $44660006;
  eGRetVal_PersonalisationRequired = $44660007;
  eGRetVal_DayIsClosed = $44660008;
  eGRetVal_EuroTransitionMissing = $44660009;
  eGRetVal_EuroTransition = $4466000A;
  eGRetVal_NewFirmwareAvailable_UpgradeNeeded = $4466000B;
  eGRetVal_FM_Initialised = $4466000C;
  eGRetVal_RegisteredReceiptsNeedsToBeSendFirst = $4466000D;
  eGRetVal_CashRegisterExecutingCancelled = $44700001;
  eGRetVal_FCU_IsBusy = $47660001;
  eGRetVal_FCU_TimeOut = $47660002;
  eGRetVal_RCU_IsBusy = $47660003;
  eGRetVal_FCU_LockedBy_NAV_server = $47660004;
  eGRetVal_FCU_LockedDueInternalError = $47660005;
  eGRetVal_InternalModuleCommunicationTimeOut = $47660006;
  eGRetVal_ProtectedStorageCapacityExhausted = $47663001;
  eGRetVal_NotImplementedFunction = $44480001;
  eGRetVal_UnknownCommand = $44480002;
  eGRetVal_IncorrectParameters = $44480003;
  eGRetVal_EmptyNIP = $40145001;
  eGRetVal_IvalidDateOrTime = $40145002;
  eGRetVal_InactiveVatLevel = $40145003;
  eGRetVal_InvalidVatRegistrationNumber = $40145004;
  eGRetVal_EmptyTPN = $40145005;
  eGRetVal_EmptyTPN_chD = $40145006;
  eGRetVal_InvalidOrInsupportOperationOrValue = $40180001;
  eGRetVal_CanNotSetReadOnlyValue = $41150001;
  eGRetVal_UnknownVariable = $41400001;
  eGRetVal_UnknownHeaderItem = $41401001;
  eGRetVal_InvalidInputDataMismatch = $41240001;
  eGRetVal_InvalidInputNothingToSend = $41240002;
  eGRetVal_InvalidInputValueOutOfRange = $41240003;
  eGRetVal_UnknownConnectingError = $42000001;
  eGRetVal_PortOpeningError = $42000002;
  eGRetVal_PortInitalisationError = $42000003;
  eGRetVal_TimeOut = $42000004;
  eGRetVal_ConnectionTimeOut = $42000005;
  eGRetVal_CommunicationTimeOut = $42000006;
  eGRetVal_ConnectionLost = $42000007;
  eGRetVal_CommunicationAborted = $42000008;
  eGRetVal_HostConnectingError = $42000009;
  eGRetVal_WrongEcrTypeConnected = $40050001;
  eGRetVal_DisabledEcrProtocolVersion = $40050002;
  eGRetVal_ErrorOpeningFile = $43000000;
  eGRetVal_FileSaveError = $43000001;
  eGRetVal_FileReadError = $43000002;
  eGRetVal_FileFormatError = $43000003;
  eGRetVal_ConfigFileNotFound = $43000004;
  eGRetVal_ConfigDataError = $43000005;
  eGRetVal_ErrorSavingDataFile = $43000006;
  eGRetVal_ConfigFileVersionError_OldVersion = $43000007;
  eGRetVal_ConfigFileVersionError_NewerVersion = $43000008;
  eGRetVal_ConfigFileVersionError_DataMismatch = $43000009;
  eGRetVal_RawFileCanNotBeOverwritten = $4300000A;
  eGRetVal_IntReqValueOutOfRange = $43100001;
  eGRetVal_LicenceExpired = $43095001;
  eGRetVal_CanNotSetValue_ROorNoChangeCondtition = $44000001;
  eGRetVal_CanNotChangeAfterFiscalization = $44000002;
  eGRetVal_EcrOperationConditionError = $44000003;
  eGRetVal_CanNotSetValue_DuplicateBarCode = $44000004;
  eGRetVal_NoGraphicsLogo = $44000005;
  eGRetVal_EcrIsBusy = $44000006;
  eGRetVal_NotSupportedEcrOperation = $44000007;
  eGRetVal_OperationNotPossibleInServiceMode = $44000008;
  eGRetVal_CanNotSetValue_DuplicateName = $44000009;
  eGRetVal_CanNotSetValue_DuplicateValue = $4400000A;
  eGRetVal_CanNotSetValue_ActiveService = $4400000B;
  eGRetVal_CanNotSetValue_DuplicateUniqueValue = $4400000C;
  eGRetVal_CanNotSetValue = $4400000D;
  eGRetVal_CanNotSetValue_TaxGroupIsNotEmpty = $4400000E;
  eGRetVal_CanNotBeChangedInNonPayerMode = $4400000F;
  eGRetVal_EcrIsBusy_DownloadingUpdate = $44000010;
  eGRetVal_NotPossibleInCurrentState = $44060001;
  eGRetVal_EcrResponse_MissingDataSignKey = $44060002;
  eGRetVal_EcrResponse_ExpiredCertificate = $44060003;
  eGRetVal_EcrResponse_MissingSerialNumber = $44060004;
  eGRetVal_EcrResponse_MissingTaxIdentifier = $44060005;
  eGRetVal_EcrResponse_MissingCashRegisterCode = $44060006;
  eGRetVal_EcrResponse_MissingCompanyName = $44060007;
  eGRetVal_EcrResponse_MissingAddress = $44060008;
  eGRetVal_JournalMemoryFull = $40673001;
  eGRetVal_ReceiptError_Rejected = $40702001;
  eGRetVal_AfterMidnight_MakeReport = $40660001;
  eGRetVal_FinancialReportRequired = $40660002;
  eGRetVal_UnblockReportRequired = $40660003;
  eGRetVal_InvalidInputMissingDataEcr = $44140001;
  eGRetVal_InvalidInputRecordIndexOutOfRange = $44140002;
  eGRetVal_InvalidValueEcrError = $44140003;
  eGRetVal_CurrencyAutoOperationNotPossible_ParamNotSet = $44361001;
  eGRetVal_ZeroDailyReportNotPossible = $44364001;
  eGRetVal_MonthlyReportBeforeDailyReport = $44364002;
  eGRetVal_ZeroMonthlyReportNotPossible = $44364003;
  eGRetVal_TwoReportsInOneDayAreNoAllowed = $44364004;
  eGRetVal_MonthlyDrawerReportBeforeDailyReport = $44364005;
  eGRetVal_CanNotSetFiscalMemoryFull = $44665001;
  eGRetVal_CanNotSetValue_ValueIsInConflict = $44065001;
  eGRetVal_ReceiptError_NoSuchItem = $44142001;
  eGRetVal_ReceiptError_SaleImpossibleInactivePLU = $44142002;
  eGRetVal_ReceiptError_ValueAdjustmentLimit = $44142003;
  eGRetVal_ReceiptError_PercentAdjustmentLimit = $44142004;
  eGRetVal_ReceiptError_MakeFinalPayment = $44142005;
  eGRetVal_ReceiptError_ChangeTooLarge = $44142006;
  eGRetVal_ReceiptError_Quantity_1_OutOfRange = $44142007;
  eGRetVal_ReceiptError_Quantity_2_OutOfRange = $44142008;
  eGRetVal_ReceiptError_TotalQuantityOutOfRange = $44142009;
  eGRetVal_ReceiptError_UnitPriceOutOfRange = $4414200A;
  eGRetVal_ReceiptError_ItemNotFound = $4414200B;
  eGRetVal_ReceiptError_ZeroPluTotalPrice = $4414200C;
  eGRetVal_ReceiptError_IllegalTenderType = $4414200D;
  eGRetVal_ReceiptError_DescriptiveItemSaleNotAllowed = $4414200E;
  eGRetVal_ReceiptError_BadTenderValue = $4414200F;
  eGRetVal_ReceiptError_InvalidQuantity1_value = $44142010;
  eGRetVal_ReceiptError_InvalidQuantity2_value = $44142011;
  eGRetVal_ReceiptError_InvalidPaymentValue = $44142012;
  eGRetVal_ReceiptError_PaymentValueOutOfRange = $44142013;
  eGRetVal_ReceiptError_InvalidQuantity = $44142014;
  eGRetVal_ReceiptError_InvalidUnitPrice = $44142015;
  eGRetVal_ReceiptError_CanNotUseForeignCurrencyState = $44142016;
  eGRetVal_ReceiptError_SaleImpossibleInactiveDPT = $44142017;
  eGRetVal_ReceiptError_InactiveCurrency = $44142018;
  eGRetVal_ReceiptError_ItemLimit = $44142019;
  eGRetVal_ReceiptError_BillLimit = $4414201A;
  eGRetVal_ReceiptError_DailyLimit = $4414201B;
  eGRetVal_ReceiptError_NotEnoughCurrency = $44662001;
  eGRetVal_ReceiptError_NotEnoughForeignCurrency = $44662002;
  eGRetVal_ReceiptError_NotEnoughCheck = $44662003;
  eGRetVal_ReceiptError_NoInvoiceVat = $44662004;
  eGRetVal_ReceiptError_InvalidItemTax = $44662005;
  eGRetVal_InsufficientCashierRights = $44662006;
  eGRetVal_EuroDateMissing = $44662007;
  eGRetVal_EuroRateMissing = $44662008;
  eGRetVal_ReceiptError_PayOutIsNotAllowed = $44662009;
  eGRetVal_SalePositionNotSet = $4466200A;
  eGRetVal_ReceiptError_SurchargeNotSupported = $40082001;
  eGRetVal_ReceiptError_DiscountNotSupported = $40082002;
  eGRetVal_ReceiptError_ReceiptTotalOverflow = $44062001;
  eGRetVal_ReceiptError_DuplicatePriceAdjustment = $44302001;
  eGRetVal_ReceiptError_NotAdjustableItem = $44302002;
  eGRetVal_ReceiptError_NoSaleItems = $44302003;
  eGRetVal_ReceiptError_NegativePurchaseTotalValue = $44302004;
  eGRetVal_ReceiptError_NegativePurchaseTaxValue = $44302005;
  eGRetVal_ReceiptError_InvalidValueForPriceAdjustment = $44302006;
  eGRetVal_ReceiptError_VoidOfDescriptiveItem = $44262001;
  eGRetVal_ReceiptError_OperationNotPossible = $44362001;
  eGRetVal_ReceiptError_VoidAfterSbtAdjustment = $44362002;
  eGRetVal_ReceiptError_PurchaseInPayment = $44362003;
  eGRetVal_ReceiptError_NoItemInPurchase = $44362004;
  eGRetVal_ReceiptError_PurchaseFullEndReceipt = $44362005;
  eGRetVal_ReceiptError_UnitPriceChangeNotAllowed = $44162001;
  eGRetVal_ReceiptError_NotReturnableContainer = $44162002;
  eGRetVal_RequestRejected = $44300001;
  eGRetVal_IncorrectEcrReply = $44500001;
  eGRetVal_InvalidJournalCheckSumm = $44070001;
  eGRetVal_JournalFull_80_percent = $44070002;
  eGRetVal_JournalFull_95_percent = $44070003;
  eGRetVal_JournalFull_MakeReport = $44070004;
  eGRetVal_JournalFull = $44070005;
  eGRetVal_JournalAutoExportError = $44070006;
  eGRetVal_TextJournalAutoExportError = $44070007;
  eGRetVal_DataJournalAutoExportError = $44070008;
  eGRetVal_TextJournalFull_80_percent = $44070009;
  eGRetVal_TextJournalFull_95_percent = $4407000A;
  eGRetVal_TextJournalFull_MakeReport = $4407000B;
  eGRetVal_TextJournalFull = $4407000C;
  eGRetVal_DataJournalFull_80_percent = $4407000D;
  eGRetVal_DataJournalFull_95_percent = $4407000E;
  eGRetVal_DataJournalFull_MakeReport = $4407000F;
  eGRetVal_DataJournalFull = $44070010;
  eGRetVal_JournalLocked = $44070011;
  eGRetVal_DataJournalLocked = $44070012;
  eGRetVal_TextJournalLocked = $44070013;
  eGRetVal_JournalDayLimitReached = $44070014;
  eGRetVal_TextJournalDayLimitReached = $44070015;
  eGRetVal_DataJournalDayLimitReached = $44070016;
  eGRetVal_JournalDocumentCountLimitReached = $44070017;
  eGRetVal_TextJournalDocumentCountLimitReached = $44070018;
  eGRetVal_DataJournalDocumentCountLimitReached = $44070019;
  eGRetVal_JournalDocumentCorrupted = $4407001A;
  eGRetVal_TextJournalDocumentCorrupted = $4407001B;
  eGRetVal_DataJournalDocumentCorrupted = $4407001C;
  eGRetVal_JoudnalCorruptedMakeRepair = $4407001D;
  eGRetVal_TextJoudnalCorruptedMakeRepair = $4407001E;
  eGRetVal_DataJoudnalCorruptedMakeRepair = $4407001F;
  eGRetVal_DataMedium_Corrupted = $44070020;
  eGRetVal_DataMedium_WriteError = $44070021;
  eGRetVal_JournalDocumentDoesNotExist = $44070022;
  eGRetVal_JournalDocumentIsOpened = $44070023;
  eGRetVal_AuditMemryNotClaimed = $44070024;
  eGRetVal_ValueNotSet_MakeDay_and_MonthFinReport = $44360001;
  eGRetVal_ValueNotSet_MakeDailyFinReport = $44360002;
  eGRetVal_ValueNotSet_MakeMonthlyFinReport = $44360003;
  eGRetVal_ValueNotSet_MakeDrawerReport = $44360004;
  eGRetVal_EcrResponse_NotInitialized = $44360005;
  eGRetVal_FullFM_TaxChangeArea = $44661001;
  eGRetVal_HW_Error_HeadIsUp = $45000001;
  eGRetVal_HW_Error_NoPaper = $45000002;
  eGRetVal_HW_Error_NoPaperJournal = $45000003;
  eGRetVal_HW_Error_NoPaperReceipt = $45000004;
  eGRetVal_DischargedBattery_ConnectAdapter = $45000005;
  eGRetVal_PrinterLostPower = $45000006;
  eGRetVal_NetworkInitialisationFailed = $45000007;
  eGRetVal_GPRS_modem_TimeOut = $46000001;
  eGRetVal_GPRS_modem_IsBusy = $46000002;
  eGRetVal_GPRS_modem_ReceiveError = $46000003;
  eGRetVal_GPRS_modem_TransmitionFailed = $46000004;
  eGRetVal_GPRS_modem_IMEI_mismatch = $46000005;
  eGRetVal_GPRS_modem_ICCID_mismatch = $46000006;
  eGRetVal_GPRS_modem_NotInstalled = $46000007;
  eGRetVal_JournalMemoryDataMediumError = $46000008;
  eGRetVal_NotSupportedCountry = $60000001;
  eGRetVal_NotSupportedOperation = $60000002;
  eGRetVal_NotSupportedOperationParam = $60000003;
  eGRetVal_NotSupportedForCurrentSettings = $60000004;
  eGRetVal_NotSupportedTable = $60001001;
  eGRetVal_UnknownAllHeaderItems = $60001002;
  eGRetVal_TableClearNotPossible = $60001003;
  eGRetVal_TableClearOutOfRange = $60001004;
  eGRetVal_UnknownRecordAttribute = $60001005;
  eGRetVal_ReceiptNotSupported = $60002001;
  eGRetVal_NotSupportedReceiptMode = $60002002;
  eGRetVal_NotSupportedReceiptType = $60002003;
  eGRetVal_NotSupportedReceiptCommand = $60002004;
  eGRetVal_ReportNotSupported = $60004001;
  eGRetVal_NotSupportedReportParams = $60004002;
  eGRetVal_NotSupportedEcrProtocolVersion = $60050001;
  eGRetVal_NotSupportedEcrType = $60050002;
  eGRetVal_NotSupportedLinkProctocolSetting = $61005001;
  eGRetVal_NotSupportedLinkProctocolType = $61005002;
  eGRetVal_NotSupportedLinkProctocolParams = $61005003;
  eGRetVal_AnyError = $40000000;
  eGRetVal_AnyWarning = $20000000;
  eGRetVal_AnyNotSupported = $60000000;
  eGRetVal_MainResultTypeMask = $70000000;
  eGRetVal_UnknownWarning = $2FFFFFFF;
  eGRetVal_UnknownError = $4FFFFFFF;

type

  // *********************************************************************//
  // Forward declaration of types defined in TypeLibrary
  // *********************************************************************//
  ICommLib = interface;
  ICommLibDisp = dispinterface;
  _StaticExport = interface;
  _StaticExportDisp = dispinterface;

  // *********************************************************************//
  // Declaration of CoClasses defined in Type Library
  // (NOTE: Here we map each CoClass to its Default Interface)
  // *********************************************************************//
  CCommLib = ICommLib;
  StaticExport = _StaticExport;

  // *********************************************************************//
  // Interface: ICommLib
  // Flags:     (4416) Dual OleAutomation Dispatchable
  // GUID:      {3FB2F51F-4891-3679-9F65-54EA3D9EAE57}
  // *********************************************************************//
  ICommLib = interface(IDispatch)
    ['{3FB2F51F-4891-3679-9F65-54EA3D9EAE57}']
    function Initialize(const f_CntrCode: WideString): eGRetVal; safecall;
    function GetCashRegisterCount: Integer; safecall;
    function GetCashRegisterName(f_Position: Integer;
      out f_UniqueID: eCashRegisterUID; out f_Name: WideString)
      : eGRetVal; safecall;
    function SetActiveCashRegister(f_UniqueID: eCashRegisterUID)
      : eGRetVal; safecall;
    function GetConfigValue(const f_Name: WideString; out f_Value: WideString)
      : eGRetVal; safecall;
    function ResetConfigValues: eGRetVal; safecall;
    function SetConfigValue(const f_Name: WideString; const f_Value: WideString)
      : eGRetVal; safecall;
    function Connect(const f_Name: WideString; const f_Password: WideString)
      : eGRetVal; safecall;
    function Disconnect: eGRetVal; safecall;
    function Abort: eGRetVal; safecall;
    function ReceiveDeviceInfo(const f_Header: WideString;
      out f_ReceivedData: WideString): eGRetVal; safecall;
    function GetDeviceInfo(const f_PropertyName: WideString;
      out f_PropertyValue: WideString): eGRetVal; safecall;
    function IsTableSupported(const f_TableName: WideString): WordBool;
      safecall;
    function OpenTable(const f_TableName: WideString): eGRetVal; safecall;
    function SetTableParam(const f_Name: WideString; const f_Value: WideString)
      : eGRetVal; safecall;
    function CloseTable: eGRetVal; safecall;
    function FlushRecords: eGRetVal; safecall;
    function ClearTable(const f_TableName: WideString): eGRetVal; safecall;
    function GetTableInfo(const f_PropertyName: WideString;
      out f_PropertyValue: WideString): eGRetVal; safecall;
    function GetHeader(out f_Header: WideString): eGRetVal; safecall;
    function SetHeader(const f_Header: WideString): eGRetVal; safecall;
    function ClearRecords(const f_LowerRecordIndex: WideString;
      const f_UpperRecordIndex: WideString; f_DeleteMode: eClearRecord)
      : eGRetVal; safecall;
    function GetRecordCount: Integer; safecall;
    function SetFilter(const f_LowerIndex: WideString;
      const f_UpperIndex: WideString; f_NonZeroSale: WordBool)
      : eGRetVal; safecall;
    function GetFirstRecord(out f_RecordIndex: WideString;
      out f_RecordData: WideString): eGRetVal; safecall;
    function GetNextRecord(out f_RecordIndex: WideString;
      out f_RecordData: WideString): eGRetVal; safecall;
    function GetRecord(const f_RecordIndex: WideString;
      out f_RecordData: WideString): eGRetVal; safecall;
    function SetRecord(const f_RecordIndex: WideString;
      const f_RecordData: WideString): eGRetVal; safecall;
    function GetErrorLevel(f_ErrorCode: eGRetVal): eErrLevel; safecall;
    function GetErrorType(f_ErrorCode: eGRetVal): eErrTypes; safecall;
    function GetErrorText(f_ErrorCode: eGRetVal; out f_ErrorText: WideString)
      : eGRetVal; safecall;
    function MakeReport(const f_ReportName: WideString;
      const f_Mode: WideString; const f_RangeMin: WideString;
      const f_RangeMax: WideString): eGRetVal; safecall;
    function SupportReport(const f_ReportName: WideString;
      const f_Mode: WideString; const f_RangeMin: WideString;
      const f_RangeMax: WideString): WordBool; safecall;
    function ReceiveGrLogo(const f_LogoType: WideString;
      const f_FileName: WideString): eGRetVal; safecall;
    function SendGrLogo(const f_LogoType: WideString;
      const f_FileName: WideString): eGRetVal; safecall;
    function SetDateTime: eGRetVal; safecall;
    function SupportFunction(const f_FnctName: WideString): WordBool; safecall;
    function OpenReceipt(const f_ReceiptMode: WideString;
      const f_ReceiptType: WideString): eGRetVal; safecall;
    function GetReceiptHeader(const f_Command: WideString;
      out f_Header: WideString): eGRetVal; safecall;
    function ReceiptCommand(const f_Command: WideString;
      const f_Parameters: WideString): eGRetVal; safecall;
    function CloseReceipt: eGRetVal; safecall;
  end;

  // *********************************************************************//
  // DispIntf:  ICommLibDisp
  // Flags:     (4416) Dual OleAutomation Dispatchable
  // GUID:      {3FB2F51F-4891-3679-9F65-54EA3D9EAE57}
  // *********************************************************************//
  ICommLibDisp = dispinterface
    ['{3FB2F51F-4891-3679-9F65-54EA3D9EAE57}']
    function Initialize(const f_CntrCode: WideString): eGRetVal;
      dispid 1610743808;
    function GetCashRegisterCount: Integer; dispid 1610743809;
    function GetCashRegisterName(f_Position: Integer;
      out f_UniqueID: eCashRegisterUID; out f_Name: WideString): eGRetVal;
      dispid 1610743810;
    function SetActiveCashRegister(f_UniqueID: eCashRegisterUID): eGRetVal;
      dispid 1610743811;
    function GetConfigValue(const f_Name: WideString; out f_Value: WideString)
      : eGRetVal; dispid 1610743812;
    function ResetConfigValues: eGRetVal; dispid 1610743813;
    function SetConfigValue(const f_Name: WideString; const f_Value: WideString)
      : eGRetVal; dispid 1610743814;
    function Connect(const f_Name: WideString; const f_Password: WideString)
      : eGRetVal; dispid 1610743815;
    function Disconnect: eGRetVal; dispid 1610743816;
    function Abort: eGRetVal; dispid 1610743817;
    function ReceiveDeviceInfo(const f_Header: WideString;
      out f_ReceivedData: WideString): eGRetVal; dispid 1610743818;
    function GetDeviceInfo(const f_PropertyName: WideString;
      out f_PropertyValue: WideString): eGRetVal; dispid 1610743819;
    function IsTableSupported(const f_TableName: WideString): WordBool;
      dispid 1610743820;
    function OpenTable(const f_TableName: WideString): eGRetVal;
      dispid 1610743821;
    function SetTableParam(const f_Name: WideString; const f_Value: WideString)
      : eGRetVal; dispid 1610743822;
    function CloseTable: eGRetVal; dispid 1610743823;
    function FlushRecords: eGRetVal; dispid 1610743824;
    function ClearTable(const f_TableName: WideString): eGRetVal;
      dispid 1610743825;
    function GetTableInfo(const f_PropertyName: WideString;
      out f_PropertyValue: WideString): eGRetVal; dispid 1610743826;
    function GetHeader(out f_Header: WideString): eGRetVal; dispid 1610743827;
    function SetHeader(const f_Header: WideString): eGRetVal; dispid 1610743828;
    function ClearRecords(const f_LowerRecordIndex: WideString;
      const f_UpperRecordIndex: WideString; f_DeleteMode: eClearRecord)
      : eGRetVal; dispid 1610743829;
    function GetRecordCount: Integer; dispid 1610743830;
    function SetFilter(const f_LowerIndex: WideString;
      const f_UpperIndex: WideString; f_NonZeroSale: WordBool): eGRetVal;
      dispid 1610743831;
    function GetFirstRecord(out f_RecordIndex: WideString;
      out f_RecordData: WideString): eGRetVal; dispid 1610743832;
    function GetNextRecord(out f_RecordIndex: WideString;
      out f_RecordData: WideString): eGRetVal; dispid 1610743833;
    function GetRecord(const f_RecordIndex: WideString;
      out f_RecordData: WideString): eGRetVal; dispid 1610743834;
    function SetRecord(const f_RecordIndex: WideString;
      const f_RecordData: WideString): eGRetVal; dispid 1610743835;
    function GetErrorLevel(f_ErrorCode: eGRetVal): eErrLevel; dispid 1610743836;
    function GetErrorType(f_ErrorCode: eGRetVal): eErrTypes; dispid 1610743837;
    function GetErrorText(f_ErrorCode: eGRetVal; out f_ErrorText: WideString)
      : eGRetVal; dispid 1610743838;
    function MakeReport(const f_ReportName: WideString;
      const f_Mode: WideString; const f_RangeMin: WideString;
      const f_RangeMax: WideString): eGRetVal; dispid 1610743839;
    function SupportReport(const f_ReportName: WideString;
      const f_Mode: WideString; const f_RangeMin: WideString;
      const f_RangeMax: WideString): WordBool; dispid 1610743840;
    function ReceiveGrLogo(const f_LogoType: WideString;
      const f_FileName: WideString): eGRetVal; dispid 1610743841;
    function SendGrLogo(const f_LogoType: WideString;
      const f_FileName: WideString): eGRetVal; dispid 1610743842;
    function SetDateTime: eGRetVal; dispid 1610743843;
    function SupportFunction(const f_FnctName: WideString): WordBool;
      dispid 1610743844;
    function OpenReceipt(const f_ReceiptMode: WideString;
      const f_ReceiptType: WideString): eGRetVal; dispid 1610743845;
    function GetReceiptHeader(const f_Command: WideString;
      out f_Header: WideString): eGRetVal; dispid 1610743846;
    function ReceiptCommand(const f_Command: WideString;
      const f_Parameters: WideString): eGRetVal; dispid 1610743847;
    function CloseReceipt: eGRetVal; dispid 1610743848;
  end;

  // *********************************************************************//
  // Interface: _StaticExport
  // Flags:     (4432) Hidden Dual OleAutomation Dispatchable
  // GUID:      {6FC46EE2-5F84-32A1-8947-6625FE1CC512}
  // *********************************************************************//
  _StaticExport = interface(IDispatch)
    ['{6FC46EE2-5F84-32A1-8947-6625FE1CC512}']
  end;

  // *********************************************************************//
  // DispIntf:  _StaticExportDisp
  // Flags:     (4432) Hidden Dual OleAutomation Dispatchable
  // GUID:      {6FC46EE2-5F84-32A1-8947-6625FE1CC512}
  // *********************************************************************//
  _StaticExportDisp = dispinterface
    ['{6FC46EE2-5F84-32A1-8947-6625FE1CC512}']
  end;

  // *********************************************************************//
  // The Class CoCCommLib provides a Create and CreateRemote method to
  // create instances of the default interface ICommLib exposed by
  // the CoClass CCommLib. The functions are intended to be used by
  // clients wishing to automate the CoClass objects exposed by the
  // server of this typelibrary.
  // *********************************************************************//
  CoCCommLib = class
    class function Create: ICommLib;
    class function CreateRemote(const MachineName: string): ICommLib;
  end;

  // *********************************************************************//
  // The Class CoStaticExport provides a Create and CreateRemote method to
  // create instances of the default interface _StaticExport exposed by
  // the CoClass StaticExport. The functions are intended to be used by
  // clients wishing to automate the CoClass objects exposed by the
  // server of this typelibrary.
  // *********************************************************************//
  CoStaticExport = class
    class function Create: _StaticExport;
    class function CreateRemote(const MachineName: string): _StaticExport;
  end;

implementation

uses ComObj;

class function CoCCommLib.Create: ICommLib;
begin
  Result := CreateComObject(CLASS_CCommLib) as ICommLib;
end;

class function CoCCommLib.CreateRemote(const MachineName: string): ICommLib;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_CCommLib) as ICommLib;
end;

class function CoStaticExport.Create: _StaticExport;
begin
  Result := CreateComObject(CLASS_StaticExport) as _StaticExport;
end;

class function CoStaticExport.CreateRemote(const MachineName: string)
  : _StaticExport;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_StaticExport)
    as _StaticExport;
end;

end.
