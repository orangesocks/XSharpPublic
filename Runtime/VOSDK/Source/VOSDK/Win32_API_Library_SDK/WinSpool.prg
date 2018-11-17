VOSTRUCT _winPRINTER_INFO_1
	MEMBER  Flags AS DWORD
	MEMBER  pDescription AS PSZ
	MEMBER  pName AS PSZ
	MEMBER  pComment AS PSZ


VOSTRUCT _winPRINTER_INFO_2
	MEMBER  pServerName AS PSZ
	MEMBER pPrinterName AS PSZ
	MEMBER pShareName AS PSZ
	MEMBER pPortName AS PSZ
	MEMBER pDriverName AS PSZ
	MEMBER pComment AS PSZ
	MEMBER pLocation AS PSZ
	MEMBER pDevMode AS _winDEVMODE
	MEMBER pSepFile AS PSZ
	MEMBER pPrintProcessor AS PSZ
	MEMBER pDatatype AS PSZ
	MEMBER pParameters AS PSZ
	MEMBER pSecurityDescriptor AS _winSECURITY_DESCRIPTOR
	MEMBER Attributes AS DWORD
	MEMBER Priority AS DWORD
	MEMBER DefaultPriority AS DWORD
	MEMBER StartTime AS DWORD
	MEMBER UntilTime AS DWORD
	MEMBER Status AS DWORD
	MEMBER cJobs AS DWORD
	MEMBER AveragePPM AS DWORD

VOSTRUCT _winPRINTER_INFO_3
	MEMBER pSecurityDescriptor AS _winSECURITY_DESCRIPTOR

VOSTRUCT _winPRINTER_INFO_4
	MEMBER  pPrinterName AS PSZ
	MEMBER  pServerName AS PSZ
	MEMBER  Attributes AS DWORD


VOSTRUCT _winPRINTER_INFO_5
	MEMBER   pPrinterName AS PSZ
	MEMBER  pPortName AS PSZ
	MEMBER  Attributes AS DWORD
	MEMBER  DeviceNotSelectedTimeout AS DWORD
	MEMBER  TransmissionRetryTimeout AS DWORD

VOSTRUCT _winJOB_INFO_1
	MEMBER  JobId  AS DWORD
	MEMBER  pPrinterName AS PSZ
	MEMBER  pMachineName AS PSZ
	MEMBER  pUserName AS PSZ
	MEMBER  pDocument AS PSZ
	MEMBER  pDatatype AS PSZ
	MEMBER  pStatus AS PSZ
	MEMBER  Status AS DWORD
	MEMBER  Priority AS DWORD
	MEMBER  Position AS DWORD
	MEMBER  TotalPages AS DWORD
	MEMBER  PagesPrinted AS DWORD
	MEMBER  Submitted IS _winSYSTEMTIME


VOSTRUCT _winJOB_INFO_2
	MEMBER  JobId AS DWORD
	MEMBER  pPrinterName AS PSZ
	MEMBER  pMachineName AS PSZ
	MEMBER  pUserName AS PSZ
	MEMBER  pDocument AS PSZ
	MEMBER  pNotifyName AS PSZ
	MEMBER  pDatatype AS PSZ
	MEMBER  pPrintProcessor AS PSZ
	MEMBER  pParameters AS PSZ
	MEMBER  pDriverName AS PSZ
	MEMBER  pDevMode AS _winDEVMODE
	MEMBER  pStatus AS PSZ
	MEMBER  pSecurityDescriptor AS _winSECURITY_DESCRIPTOR
	MEMBER  Status AS DWORD
	MEMBER  Priority AS DWORD
	MEMBER  Position AS DWORD
	MEMBER  StartTime AS DWORD
	MEMBER  UntilTime AS DWORD
	MEMBER  TotalPages AS DWORD
	MEMBER  Size AS DWORD
	MEMBER  Submitted IS _winSYSTEMTIME
	MEMBER  Time AS DWORD
	MEMBER  PagesPrinted AS DWORD

VOSTRUCT _winADDJOB_INFO_1
	MEMBER  Path AS PSZ
	MEMBER   JobId AS DWORD

VOSTRUCT _winDRIVER_INFO_1
	MEMBER  pName AS PSZ

VOSTRUCT _winDRIVER_INFO_2
	MEMBER  cVersion AS DWORD
	MEMBER  pName AS PSZ
	MEMBER  pEnvironment AS PSZ
	MEMBER  pDriverPath AS PSZ
	MEMBER  pDataFile AS PSZ
	MEMBER  pConfigFile AS PSZ


VOSTRUCT _winDRIVER_INFO_3
	MEMBER  cVersion AS DWORD
	MEMBER  pName AS PSZ
	MEMBER  pEnvironment AS PSZ
	MEMBER  pDriverPath AS PSZ
	MEMBER  pDataFile AS PSZ
	MEMBER  pConfigFile AS PSZ
	MEMBER  pHelpFile AS PSZ
	MEMBER  pDependentFiles AS PSZ
	MEMBER  pMonitorName AS PSZ
	MEMBER  pDefaultDataType AS PSZ

VOSTRUCT _winDOC_INFO_1
	MEMBER    pDocName AS PSZ
	MEMBER    pOutputFile AS PSZ
	MEMBER     pDatatype AS PSZ

VOSTRUCT _winFORM_INFO_1
	MEMBER  Flags AS DWORD
	MEMBER    pName AS PSZ
	MEMBER   Size IS _winSIZE
	MEMBER  ImageableArea IS _winRECTL

VOSTRUCT _winDOC_INFO_2
	MEMBER  pDocName AS PSZ
	MEMBER pOutputFile AS PSZ
	MEMBER pDatatype AS PSZ
	MEMBER dwMode AS DWORD
	MEMBER JobId AS DWORD

VOSTRUCT _winPRINTPROCESSOR_INFO_1
	MEMBER  pName AS PSZ

VOSTRUCT _winPORT_INFO_1
	MEMBER  pName AS PSZ


VOSTRUCT _winPORT_INFO_2
	MEMBER  pPortName AS PSZ
	MEMBER  pMonitorName AS PSZ
	MEMBER  pDescription AS PSZ
	MEMBER  fPortType AS DWORD
	MEMBER  Reserved AS DWORD

VOSTRUCT _winMONITOR_INFO_1
	MEMBER pName AS PSZ

VOSTRUCT _winMONITOR_INFO_2
	MEMBER  pName AS PSZ
	MEMBER pEnvironment AS PSZ
	MEMBER pDLLName AS PSZ

VOSTRUCT _winDATATYPES_INFO_1
	MEMBER  pName AS PSZ

VOSTRUCT _winPRINTER_DEFAULTS
	MEMBER  pDatatype AS PSZ
	MEMBER pDevMode AS _winDEVMODE
	MEMBER DesiredAccess AS DWORD


VOSTRUCT _winPRINTER_NOTIFY_OPTIONS_TYPE
	MEMBER Type AS WORD
	MEMBER Reserved0 AS WORD
	MEMBER Reserved1 AS DWORD
	MEMBER Reserved2 AS DWORD
	MEMBER Count AS DWORD
	MEMBER pFields AS WORD PTR


VOSTRUCT _winPRINTER_NOTIFY_OPTIONS
	MEMBER Version AS DWORD
	MEMBER Flags AS DWORD
	MEMBER Count AS DWORD
	MEMBER pTypes AS _winPRINTER_NOTIFY_OPTIONS_TYPE

VOSTRUCT Data_win
	MEMBER  cbBuf AS DWORD
	MEMBER   pBuf AS PTR

VOSTRUCT _winPRINTER_NOTIFY_INFO_DATA
	MEMBER Type AS WORD
	MEMBER _Field AS WORD
	MEMBER Reserved AS DWORD
	MEMBER Id AS DWORD
	MEMBER  NotifyData IS NotifyData_win

VOSTRUCT _winPRINTER_NOTIFY_INFO
	MEMBER Version AS DWORD
	MEMBER Flags AS DWORD
	MEMBER Count AS WORD
	MEMBER DIM aData[1] IS _winPRINTER_NOTIFY_INFO_DATA


VOSTRUCT _winPROVIDOR_INFO_1
	MEMBER pName AS PSZ
	MEMBER pEnvironment AS PSZ
	MEMBER pDLLName AS PSZ


_DLL FUNC EnumPrinters(Flags AS DWORD, Name AS PSZ, Level AS DWORD, pPrinterEnum AS BYTE PTR,;
	cbBuf AS DWORD, pcbNeeded AS DWORD PTR, pcReturned AS DWORD PTR);
	AS LOGIC PASCAL:WINSPOOL.DRV.EnumPrintersA


_DLL FUNC OpenPrinter(pPrinterName AS PSZ, phPrinter AS PTR, pDefault AS _winPRINTER_DEFAULTS);
	AS LOGIC PASCAL:WINSPOOL.DRV.OpenPrinterA


//this function can not be found in any DLL file
_DLL FUNC ResetPrinter(hPrinter AS PTR, pDefault AS _winPRINTER_DEFAULTS);
	AS LOGIC PASCAL:WINSPOOL.DRV.ResetPrinterA



_DLL FUNC SetJob(hPrinter AS PTR, JobId AS DWORD, Level AS DWORD, pJob AS BYTE PTR,;
	Command AS DWORD) AS LOGIC PASCAL:WINSPOOL.DRV.SetJobA


_DLL FUNC GetJobA(hPrinter AS PTR, JobId AS DWORD, Level AS DWORD, pJob AS BYTE PTR,;
	cbBuf AS DWORD, pcbNeeded AS DWORD PTR) AS LOGIC PASCAL:WINSPOOL.DRV.GetJobA


_DLL FUNC EnumJobs(hPrinter AS PTR, FirstJob AS DWORD, NoJobs AS DWORD, Level AS DWORD,;
	pJob AS BYTE PTR, cbBuf AS DWORD, pcbNeeded AS DWORD PTR, pcbReturen AS DWORD PTR);
	AS LOGIC PASCAL:WINSPOOL.DRV.EnumJobsA


_DLL FUNC AddPrinter(pName AS PSZ, Level AS DWORD, pPrinter AS BYTE PTR) AS PTR PASCAL:WINSPOOL.DRV.AddPrinterA



_DLL FUNC DeletePrinter( hPrinter AS PTR) AS LOGIC PASCAL:WINSPOOL.DRV.DeletePrinter


_DLL FUNC SetPrinter(hPrinter AS PTR, Level AS DWORD, pPrinter AS BYTE PTR, Command AS DWORD);
	AS LOGIC PASCAL:WINSPOOL.DRV.SetPrinterA



_DLL FUNC GetPrinter(hPrinter AS PTR, Level AS DWORD, pPrinter AS DWORD PTR, cbBuf AS DWORD,;
	pcbNeeded AS DWORD PTR) AS LOGIC PASCAL:WINSPOOL.DRV.GetPrinterA


_DLL FUNC AddPrinterDriver(pName AS PSZ, Level AS DWORD, pDriverInfo AS BYTE PTR);
	AS LOGIC PASCAL:WINSPOOL.DRV.AddPrinterDriverA


_DLL FUNC EnumPrinterDrivers(pName AS PSZ, pEnvironment AS PSZ, Level AS DWORD,;
	pDriverInfo AS BYTE PTR, cbBuf AS DWORD, pcbNeeded AS DWORD PTR,;
	pcReturned AS DWORD PTR) AS LOGIC PASCAL:WINSPOOL.DRV.EnumPrinterDriversA


_DLL FUNC GetPrinterDriver(hPerinter AS PTR, pEnvironment AS PSZ, Level AS DWORD,;
	pDriverInfo AS BYTE PTR, cbBuf AS DWORD, pcbNeeded AS DWORD PTR);
	AS LOGIC PASCAL:WINSPOOL.DRV.GetPrinterDriverA


_DLL FUNC GetPrinterDriverDirectory(pName AS PSZ, pEnvironment AS PSZ, Level AS DWORD,;
	pDriverDirectory AS BYTE PTR, cbBuf AS DWORD,;
	pcbNeeded AS DWORD PTR) AS LOGIC PASCAL:WINSPOOL.DRV.GetPrinterDriverDirectoryA


_DLL FUNC DeletePrinterDriver(pName AS PSZ, pEnvironMent AS PSZ, pDriverName AS PSZ);
	AS LOGIC PASCAL:WINSPOOL.DRV.DeletePrinterDriverA



_DLL FUNC AddPrintProcessor(pName AS PSZ, penvironment AS PSZ, pPathName AS PSZ,;
	pPrintProcessorName AS PSZ) AS LOGIC PASCAL:WINSPOOL.DRV.AddPrintProcessorA


_DLL FUNC EnumPrintProcessors(pName AS PSZ, pEnvironment AS PSZ, Level AS DWORD,;
	pPrintProcessorInfo AS BYTE PTR, cbBuf AS DWORD, pcbNeeded AS DWORD PTR,;
	pcReturned AS DWORD PTR) AS LOGIC PASCAL:WINSPOOL.DRV.EnumPrintProcessorsA



_DLL FUNC GetPrintProcessorDirectory(pName AS PSZ, pEnvironment AS PSZ, Level AS DWORD,;
	pPrinterProcessorInfo AS BYTE PTR, cbBuf AS DWORD,;
	pcbNeeded AS DWORD PTR) AS LOGIC PASCAL:WINSPOOL.DRV.GetPrintProcessorDirectoryA


_DLL FUNC EnumPrintProcessorDatatypes(pName AS PSZ, pPrinterProcessorName AS PSZ,;
	Level AS DWORD, pDatatyps AS BYTE PTR, cbBuf AS DWORD,;
	pcbNeeded AS DWORD PTR, pcReturned AS DWORD PTR) AS LOGIC PASCAL:WINSPOOL.DRV.EnumPrintProcessorDatatypesA



_DLL FUNC DeletePrintProcessor(pName AS PSZ, pEnvironment AS PSZ, pPrinterProcessorName AS PSZ);
	AS LOGIC PASCAL:WINSPOOL.DRV.DeletePrintProcessorA


_DLL FUNC StartDocPrinter(hPrinter AS PTR, Level AS DWORD, pDocInfo AS BYTE PTR);
	AS DWORD PASCAL:WINSPOOL.DRV.StartDocPrinterA



_DLL FUNC StartPagePrinter(hPrinter AS PTR) AS LOGIC PASCAL:WINSPOOL.DRV.StartPagePrinter


_DLL FUNC WritePrinter(hPrinter AS PTR, pBuf AS PTR, cbBuf AS DWORD, pcWritten AS DWORD PTR);
	AS LOGIC PASCAL:WINSPOOL.DRV.WritePrinter

_DLL FUNC EndPagePrinter(hPrinter AS PTR) AS LOGIC PASCAL:WINSPOOL.DRV.EndPagePrinter


_DLL FUNC AbortPrinter(hPrinter AS PTR) AS LOGIC PASCAL:WINSPOOL.DRV.AbortPrinter


_DLL FUNC ReadPrinter(hPrinter AS PTR, pBuf AS PTR, cbBuf AS DWORD, pNoBytesRead AS DWORD PTR);
	AS LOGIC PASCAL:WINSPOOL.DRV.ReadPrinter

_DLL FUNC EndDocPrinter(hPrinter AS PTR) AS PTR PASCAL:WINSPOOL.DRV.EndDocPrinter


_DLL FUNC AddJob(hPrinter AS PTR, Level AS DWORD, pData AS BYTE PTR, cbBuf AS DWORD,;
	pcbNeeded AS DWORD PTR) AS LOGIC PASCAL:WINSPOOL.DRV.AddJobA


_DLL FUNC ScheduleJob(hPrinter AS PTR, JobId AS DWORD) AS LOGIC PASCAL:WINSPOOL.DRV.ScheduleJob

_DLL FUNC PrinterProperties(hWnd AS PTR, hPrinter AS PTR) AS LOGIC PASCAL:WINSPOOL.DRV.PrinterProperties


_DLL FUNC DocumentProperties(hWnd AS PTR, pPrinter AS PTR, pDevicename AS PSZ,;
	pDevModeOutput AS _winDEVMODE, pDevModeInput AS _winDEVMODE,;
	fMode AS DWORD) AS LONG PASCAL:WINSPOOL.DRV.DocumentPropertiesA

_DLL FUNC AdvancedDocumentProperties(hWnd AS PTR, pPrinter AS PTR, pDevicename AS PSZ,;
	pDevModeOutput AS _winDEVMODE, pDevModeInput AS _winDEVMODE);
	AS LONG PASCAL:WINSPOOL.DRV.AdvancedDocumentPropertiesA

_DLL FUNC GetPrinterData(hPrinter AS PTR, pValueName AS PSZ, pType AS DWORD PTR, pData AS BYTE PTR, nSize AS DWORD,;
	pcbNeeded AS DWORD PTR) AS DWORD PASCAL:WINSPOOL.DRV.GetPrinterDataA

_DLL FUNC SetPrinterData(hPrinter AS PTR, pValueName AS PSZ, Type AS DWORD, pData AS BYTE PTR, cbData AS DWORD);
	AS DWORD PASCAL:WINSPOOL.DRV.SetPrinterDataA

UNION  NotifyData_win
	MEMBER DIM adwData[2] AS DWORD
	MEMBER Data IS dATA_WIN

_DLL FUNC WaitForPrinterChange(hPrinter AS PTR, Flags AS DWORD) AS DWORD PASCAL:WINSPOOL.DRV.WaitForPrinterChange

_DLL FUNC FindFirstPrinterChangeNotification(hPrinter AS PTR, fdwFlags AS DWORD,;
	fdwOptions AS DWORD, pPrinterNotifyOptions AS PTR);
	AS PTR PASCAL:WINSPOOL.DRV.FindFirstPrinterChangeNotification

_DLL FUNC FindNextPrinterChangeNotification(hChange AS PTR, pdwChange AS DWORD PTR,;
	pvReserved AS PTR, ppPrinterNotifyInfo AS PTR);
	AS LOGIC PASCAL:WINSPOOL.DRV.FindNextPrinterChangeNotification

_DLL FUNC FreePrinterNotifyInfo(pPrinterNotifyINfo AS _winPRINTER_NOTIFY_INFO);
	AS LOGIC PASCAL:WINSPOOL.DRV.FreePrinterNotifyInfo

_DLL FUNC FindClosePrinterChangeNotification(hChange AS PTR) AS LOGIC PASCAL:WINSPOOL.DRV.FindClosePrinterChangeNotification

_DLL FUNC PrinterMessageBox(hPrinter AS PTR, Error AS DWORD, hWnd AS PTR, pText AS PSZ, pCaption AS PSZ, DWTYPE AS DWORD);
	AS DWORD PASCAL:WINSPOOL.DRV.PrinterMessageBoxA


_DLL FUNC ClosePrinter(hPrinter AS PTR) AS LOGIC PASCAL:WINSPOOL.DRV.ClosePrinter

_DLL FUNC EnumMonitors(pName AS PSZ, Level AS DWORD, pMonitors AS BYTE PTR, cbBuf AS DWORD, pcbNeeded AS DWORD PTR,;
	pcReturned AS DWORD PTR) AS LOGIC PASCAL:WINSPOOL.DRV.EnumMonitorsA

_DLL FUNC AddMonitor(pName AS PSZ, Level AS DWORD, pMonitors AS BYTE PTR) AS LOGIC PASCAL:WINSPOOL.DRV.AddMonitorA

_DLL FUNC DeleteMonitor(pName AS PSZ, pEnvironment AS PSZ, pMonitorName AS PSZ) AS LOGIC PASCAL:WINSPOOL.DRV.DeleteMonitorA

_DLL FUNC EnumPorts (pName AS PSZ, Level AS DWORD, pPorts AS BYTE PTR, cbBuf AS DWORD, pcbNeeded AS DWORD PTR,;
	pcReturned AS DWORD PTR) AS LOGIC PASCAL:WINSPOOL.DRV.EnumPortsA

_DLL FUNC AddPort(pName AS PSZ, hWnd AS PTR, pMonitorName AS PSZ) AS LOGIC PASCAL:WINSPOOL.DRV.AddPortA

_DLL FUNC ConfigurePort(pName AS PSZ, hWnd AS PTR, pPortName AS PSZ) AS LOGIC PASCAL:WINSPOOL.DRV.ConfigurePortA

_DLL FUNC DeletePort(pName AS PSZ, hWnd AS PTR, pPortName AS PSZ) AS LOGIC PASCAL:WINSPOOL.DRV.DeletePortA

_DLL FUNC AddPrinterConnection(pName AS PSZ) AS LOGIC PASCAL:WINSPOOL.DRV.AddPrinterConnectionA

_DLL FUNC DeletePrinterConnection(pName AS PSZ) AS LOGIC PASCAL:WINSPOOL.DRV.DeletePrinterConnectionA

_DLL FUNC ConnectToPrinterDlg(hwnd AS PTR, Flags AS DWORD) AS PTR PASCAL:WINSPOOL.DRV.ConnectToPrinterDlg

_DLL FUNC AddPrintProvidor(pName AS PSZ, level AS DWORD, pProvidorInfo AS BYTE PTR) AS LOGIC PASCAL:WINSPOOL.DRV.AddPrintProvidorA

_DLL FUNC DeletePrintProvidor(pName AS PSZ, pEnvironment AS PSZ,pPrintProvidorName AS PSZ) AS LOGIC PASCAL:WINSPOOL.DRV.DeletePrintProvidorA



#region defines
DEFINE PRINTER_CONTROL_PAUSE            := 1
DEFINE PRINTER_CONTROL_RESUME           := 2
DEFINE PRINTER_CONTROL_PURGE            := 3
DEFINE PRINTER_CONTROL_SET_STATUS       := 4
DEFINE PRINTER_STATUS_PAUSED            := 0x00000001
DEFINE PRINTER_STATUS_ERROR             := 0x00000002
DEFINE PRINTER_STATUS_PENDING_DELETION  := 0x00000004
DEFINE PRINTER_STATUS_PAPER_JAM         := 0x00000008
DEFINE PRINTER_STATUS_PAPER_OUT         := 0x00000010
DEFINE PRINTER_STATUS_MANUAL_FEED       := 0x00000020
DEFINE PRINTER_STATUS_PAPER_PROBLEM     := 0x00000040
DEFINE PRINTER_STATUS_OFFLINE           := 0x00000080
DEFINE PRINTER_STATUS_IO_ACTIVE         := 0x00000100
DEFINE PRINTER_STATUS_BUSY              := 0x00000200
DEFINE PRINTER_STATUS_PRINTING          := 0x00000400
DEFINE PRINTER_STATUS_OUTPUT_BIN_FULL   := 0x00000800
DEFINE PRINTER_STATUS_NOT_AVAILABLE     := 0x00001000
DEFINE PRINTER_STATUS_WAITING           := 0x00002000
DEFINE PRINTER_STATUS_PROCESSING        := 0x00004000
DEFINE PRINTER_STATUS_INITIALIZING      := 0x00008000
DEFINE PRINTER_STATUS_WARMING_UP        := 0x00010000
DEFINE PRINTER_STATUS_TONER_LOW         := 0x00020000
DEFINE PRINTER_STATUS_NO_TONER          := 0x00040000
DEFINE PRINTER_STATUS_PAGE_PUNT         := 0x00080000
DEFINE PRINTER_STATUS_USER_INTERVENTION := 0x00100000
DEFINE PRINTER_STATUS_OUT_OF_MEMORY     := 0x00200000
DEFINE PRINTER_STATUS_DOOR_OPEN         := 0x00400000
DEFINE PRINTER_STATUS_SERVER_UNKNOWN    := 0x00800000
DEFINE PRINTER_STATUS_POWER_SAVE        := 0x01000000
DEFINE PRINTER_ATTRIBUTE_QUEUED        :=  0x00000001
DEFINE PRINTER_ATTRIBUTE_DIRECT        :=  0x00000002
DEFINE PRINTER_ATTRIBUTE_DEFAULT       :=  0x00000004
DEFINE PRINTER_ATTRIBUTE_SHARED        :=  0x00000008
DEFINE PRINTER_ATTRIBUTE_NETWORK       :=  0x00000010
DEFINE PRINTER_ATTRIBUTE_HIDDEN        :=  0x00000020
DEFINE PRINTER_ATTRIBUTE_LOCAL         :=  0x00000040
DEFINE PRINTER_ATTRIBUTE_ENABLE_DEVQ       := 0x00000080
DEFINE PRINTER_ATTRIBUTE_KEEPPRINTEDJOBS   := 0x00000100
DEFINE PRINTER_ATTRIBUTE_DO_COMPLETE_FIRST := 0x00000200
DEFINE PRINTER_ATTRIBUTE_WORK_OFFLINE   := 0x00000400
DEFINE PRINTER_ATTRIBUTE_ENABLE_BIDI    := 0x00000800
DEFINE PRINTER_ATTRIBUTE_RAW_ONLY       := 0x00001000
DEFINE PRINTER_ATTRIBUTE_PUBLISHED      := 0x00002000
DEFINE PRINTER_ATTRIBUTE_FAX            := 0x00004000
DEFINE PRINTER_ATTRIBUTE_TS             := 0x00008000
DEFINE NO_PRIORITY   := 0
DEFINE MAX_PRIORITY  := 99
DEFINE MIN_PRIORITY  := 1
DEFINE DEF_PRIORITY  := 1
DEFINE JOB_CONTROL_PAUSE              := 1
DEFINE JOB_CONTROL_RESUME             := 2
DEFINE JOB_CONTROL_CANCEL             := 3
DEFINE JOB_CONTROL_RESTART            := 4
DEFINE JOB_CONTROL_DELETE             := 5
DEFINE JOB_CONTROL_SENT_TO_PRINTER    := 6
DEFINE JOB_CONTROL_LAST_PAGE_EJECTED  := 7
DEFINE JOB_STATUS_PAUSED       := 0x00000001
DEFINE JOB_STATUS_ERROR        := 0x00000002
DEFINE JOB_STATUS_DELETING     := 0x00000004
DEFINE JOB_STATUS_SPOOLING     := 0x00000008
DEFINE JOB_STATUS_PRINTING     := 0x00000010
DEFINE JOB_STATUS_OFFLINE      := 0x00000020
DEFINE JOB_STATUS_PAPEROUT     := 0x00000040
DEFINE JOB_STATUS_PRINTED      := 0x00000080
DEFINE JOB_STATUS_DELETED      := 0x00000100
DEFINE JOB_STATUS_BLOCKED_DEVQ := 0x00000200
DEFINE JOB_STATUS_USER_INTERVENTION   := 0x00000400
DEFINE JOB_STATUS_RESTART              := 0x00000800
DEFINE JOB_STATUS_COMPLETE             := 0x00001000
DEFINE JOB_POSITION_UNSPECIFIED       := 0
DEFINE DI_CHANNEL              := 1
DEFINE DI_CHANNEL_WRITE        := 2
DEFINE DI_READ_SPOOL_JOB       := 3
DEFINE FORM_BUILTIN    := 0x00000001
DEFINE PORT_TYPE_WRITE         := 0x0001
DEFINE PORT_TYPE_READ          := 0x0002
DEFINE PORT_TYPE_REDIRECTED    := 0x0004
DEFINE PORT_TYPE_NET_ATTACHED  := 0x0008
DEFINE PORT_STATUS_TYPE_ERROR      := 1
DEFINE PORT_STATUS_TYPE_WARNING    := 2
DEFINE PORT_STATUS_TYPE_INFO       := 3
DEFINE     PORT_STATUS_OFFLINE                 := 1
DEFINE     PORT_STATUS_PAPER_JAM               := 2
DEFINE     PORT_STATUS_PAPER_OUT               := 3
DEFINE     PORT_STATUS_OUTPUT_BIN_FULL         := 4
DEFINE     PORT_STATUS_PAPER_PROBLEM           := 5
DEFINE     PORT_STATUS_NO_TONER                := 6
DEFINE     PORT_STATUS_DOOR_OPEN               := 7
DEFINE     PORT_STATUS_USER_INTERVENTION       := 8
DEFINE     PORT_STATUS_OUT_OF_MEMORY           := 9
DEFINE     PORT_STATUS_TONER_LOW              := 10
DEFINE     PORT_STATUS_WARMING_UP             := 11
DEFINE     PORT_STATUS_POWER_SAVE             := 12
DEFINE PRINTER_ENUM_DEFAULT     := 0x00000001
DEFINE PRINTER_ENUM_LOCAL       := 0x00000002
DEFINE PRINTER_ENUM_CONNECTIONS := 0x00000004
DEFINE PRINTER_ENUM_FAVORITE    := 0x00000004
DEFINE PRINTER_ENUM_NAME        := 0x00000008
DEFINE PRINTER_ENUM_REMOTE      := 0x00000010
DEFINE PRINTER_ENUM_SHARED      := 0x00000020
DEFINE PRINTER_ENUM_NETWORK     := 0x00000040
DEFINE PRINTER_ENUM_EXPAND      := 0x00004000
DEFINE PRINTER_ENUM_CONTAINER   := 0x00008000
DEFINE PRINTER_ENUM_ICONMASK    := 0x00ff0000
DEFINE PRINTER_ENUM_ICON1       := 0x00010000
DEFINE PRINTER_ENUM_ICON2       := 0x00020000
DEFINE PRINTER_ENUM_ICON3       := 0x00040000
DEFINE PRINTER_ENUM_ICON4       := 0x00080000
DEFINE PRINTER_ENUM_ICON5       := 0x00100000
DEFINE PRINTER_ENUM_ICON6       := 0x00200000
DEFINE PRINTER_ENUM_ICON7       := 0x00400000
DEFINE PRINTER_ENUM_ICON8       := 0x00800000
DEFINE PRINTER_ENUM_HIDE        := 0x01000000
DEFINE SPOOL_FILE_PERSISTENT    := 0x00000001
DEFINE SPOOL_FILE_TEMPORARY     := 0x00000002
DEFINE PRINTER_NOTIFY_TYPE := 0x00
DEFINE JOB_NOTIFY_TYPE     := 0x01
DEFINE PRINTER_NOTIFY_FIELD_SERVER_NAME             := 0x00
DEFINE PRINTER_NOTIFY_FIELD_PRINTER_NAME            := 0x01
DEFINE PRINTER_NOTIFY_FIELD_SHARE_NAME              := 0x02
DEFINE PRINTER_NOTIFY_FIELD_PORT_NAME               := 0x03
DEFINE PRINTER_NOTIFY_FIELD_DRIVER_NAME             := 0x04
DEFINE PRINTER_NOTIFY_FIELD_COMMENT                 := 0x05
DEFINE PRINTER_NOTIFY_FIELD_LOCATION                := 0x06
DEFINE PRINTER_NOTIFY_FIELD_DEVMODE                 := 0x07
DEFINE PRINTER_NOTIFY_FIELD_SEPFILE                 := 0x08
DEFINE PRINTER_NOTIFY_FIELD_PRINT_PROCESSOR         := 0x09
DEFINE PRINTER_NOTIFY_FIELD_PARAMETERS              := 0x0A
DEFINE PRINTER_NOTIFY_FIELD_DATATYPE                := 0x0B
DEFINE PRINTER_NOTIFY_FIELD_SECURITY_DESCRIPTOR     := 0x0C
DEFINE PRINTER_NOTIFY_FIELD_ATTRIBUTES              := 0x0D
DEFINE PRINTER_NOTIFY_FIELD_PRIORITY                := 0x0E
DEFINE PRINTER_NOTIFY_FIELD_DEFAULT_PRIORITY        := 0x0F
DEFINE PRINTER_NOTIFY_FIELD_START_TIME              := 0x10
DEFINE PRINTER_NOTIFY_FIELD_UNTIL_TIME              := 0x11
DEFINE PRINTER_NOTIFY_FIELD_STATUS                  := 0x12
DEFINE PRINTER_NOTIFY_FIELD_STATUS_STRING           := 0x13
DEFINE PRINTER_NOTIFY_FIELD_CJOBS                   := 0x14
DEFINE PRINTER_NOTIFY_FIELD_AVERAGE_PPM             := 0x15
DEFINE PRINTER_NOTIFY_FIELD_TOTAL_PAGES             := 0x16
DEFINE PRINTER_NOTIFY_FIELD_PAGES_PRINTED           := 0x17
DEFINE PRINTER_NOTIFY_FIELD_TOTAL_BYTES             := 0x18
DEFINE PRINTER_NOTIFY_FIELD_BYTES_PRINTED           := 0x19
DEFINE PRINTER_NOTIFY_FIELD_OBJECT_GUID             := 0x1A
DEFINE JOB_NOTIFY_FIELD_PRINTER_NAME                := 0x00
DEFINE JOB_NOTIFY_FIELD_MACHINE_NAME                := 0x01
DEFINE JOB_NOTIFY_FIELD_PORT_NAME                   := 0x02
DEFINE JOB_NOTIFY_FIELD_USER_NAME                   := 0x03
DEFINE JOB_NOTIFY_FIELD_NOTIFY_NAME                 := 0x04
DEFINE JOB_NOTIFY_FIELD_DATATYPE                    := 0x05
DEFINE JOB_NOTIFY_FIELD_PRINT_PROCESSOR             := 0x06
DEFINE JOB_NOTIFY_FIELD_PARAMETERS                  := 0x07
DEFINE JOB_NOTIFY_FIELD_DRIVER_NAME                 := 0x08
DEFINE JOB_NOTIFY_FIELD_DEVMODE                     := 0x09
DEFINE JOB_NOTIFY_FIELD_STATUS                      := 0x0A
DEFINE JOB_NOTIFY_FIELD_STATUS_STRING               := 0x0B
DEFINE JOB_NOTIFY_FIELD_SECURITY_DESCRIPTOR         := 0x0C
DEFINE JOB_NOTIFY_FIELD_DOCUMENT                    := 0x0D
DEFINE JOB_NOTIFY_FIELD_PRIORITY                    := 0x0E
DEFINE JOB_NOTIFY_FIELD_POSITION                    := 0x0F
DEFINE JOB_NOTIFY_FIELD_SUBMITTED                   := 0x10
DEFINE JOB_NOTIFY_FIELD_START_TIME                  := 0x11
DEFINE JOB_NOTIFY_FIELD_UNTIL_TIME                  := 0x12
DEFINE JOB_NOTIFY_FIELD_TIME                        := 0x13
DEFINE JOB_NOTIFY_FIELD_TOTAL_PAGES                 := 0x14
DEFINE JOB_NOTIFY_FIELD_PAGES_PRINTED               := 0x15
DEFINE JOB_NOTIFY_FIELD_TOTAL_BYTES                 := 0x16
DEFINE JOB_NOTIFY_FIELD_BYTES_PRINTED               := 0x17
DEFINE PRINTER_NOTIFY_OPTIONS_REFRESH  := 0x01
DEFINE PRINTER_NOTIFY_INFO_DISCARDED       := 0x01
DEFINE PRINTER_CHANGE_ADD_PRINTER                  := 0x00000001
DEFINE PRINTER_CHANGE_SET_PRINTER                  := 0x00000002
DEFINE PRINTER_CHANGE_DELETE_PRINTER               := 0x00000004
DEFINE PRINTER_CHANGE_FAILED_CONNECTION_PRINTER    := 0x00000008
DEFINE PRINTER_CHANGE_PRINTER                      := 0x000000FF
DEFINE PRINTER_CHANGE_ADD_JOB                      := 0x00000100
DEFINE PRINTER_CHANGE_SET_JOB                      := 0x00000200
DEFINE PRINTER_CHANGE_DELETE_JOB               := 0x00000400
DEFINE PRINTER_CHANGE_WRITE_JOB                := 0x00000800
DEFINE PRINTER_CHANGE_JOB                      := 0x0000FF00
DEFINE PRINTER_CHANGE_ADD_FORM                 := 0x00010000
DEFINE PRINTER_CHANGE_SET_FORM                 := 0x00020000
DEFINE PRINTER_CHANGE_DELETE_FORM              := 0x00040000
DEFINE PRINTER_CHANGE_FORM                     := 0x00070000
DEFINE PRINTER_CHANGE_ADD_PORT                 := 0x00100000
DEFINE PRINTER_CHANGE_CONFIGURE_PORT           := 0x00200000
DEFINE PRINTER_CHANGE_DELETE_PORT              := 0x00400000
DEFINE PRINTER_CHANGE_PORT                     := 0x00700000
DEFINE PRINTER_CHANGE_ADD_PRINT_PROCESSOR      := 0x01000000
DEFINE PRINTER_CHANGE_DELETE_PRINT_PROCESSOR   := 0x04000000
DEFINE PRINTER_CHANGE_PRINT_PROCESSOR          := 0x07000000
DEFINE PRINTER_CHANGE_ADD_PRINTER_DRIVER       := 0x10000000
DEFINE PRINTER_CHANGE_SET_PRINTER_DRIVER       := 0x20000000
DEFINE PRINTER_CHANGE_DELETE_PRINTER_DRIVER    := 0x40000000
DEFINE PRINTER_CHANGE_PRINTER_DRIVER           := 0x70000000
DEFINE PRINTER_CHANGE_TIMEOUT                  := 0x80000000
DEFINE PRINTER_CHANGE_ALL                      := 0x7777FFFF
DEFINE PRINTER_ERROR_INFORMATION   := 0x80000000
DEFINE PRINTER_ERROR_WARNING       := 0x40000000
DEFINE PRINTER_ERROR_SEVERE        := 0x20000000
DEFINE PRINTER_ERROR_OUTOFPAPER    :=  0x00000001
DEFINE PRINTER_ERROR_JAM           :=  0x00000002
DEFINE PRINTER_ERROR_OUTOFTONER    :=  0x00000004
DEFINE SERVER_ACCESS_ADMINISTER    := 0x00000001
DEFINE SERVER_ACCESS_ENUMERATE     := 0x00000002
DEFINE PRINTER_ACCESS_ADMINISTER   := 0x00000004
DEFINE PRINTER_ACCESS_USE          := 0x00000008
DEFINE JOB_ACCESS_ADMINISTER       := 0x00000010
DEFINE JOB_ACCESS_READ             := 0x00000020
/*
 * Access rights for print servers
 */
DEFINE SERVER_ALL_ACCESS    := 0x000f0003
DEFINE SERVER_READ          := 0x00020002
DEFINE SERVER_WRITE         :=0x00020003
DEFINE SERVER_EXECUTE       := 0x00020002
/*
 * Access rights for printers
 */
DEFINE PRINTER_ALL_ACCESS    := 0x000f000c
DEFINE PRINTER_READ          := 0x00020008
DEFINE PRINTER_WRITE         := 0x00020008
DEFINE PRINTER_EXECUTE       := 0x00020008
/*
 * Access rights for jobs
 */
DEFINE JOB_ALL_ACCESS         := 0x000f0010
DEFINE JOB_READ               := 0x00020010
DEFINE JOB_WRITE              := 0x00020010
DEFINE JOB_EXECUTE            := 0x00020010
#endregion
