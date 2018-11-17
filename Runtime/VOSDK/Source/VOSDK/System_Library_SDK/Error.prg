DEFINE SE_ABORT             := 0
DEFINE SE_IGNORE            := 1
DEFINE SE_RETRY             := 2
DEFINE SE_CANCEL            := 3
DEFINE SE_OK                := 4
DEFINE SE_YES               := 5
DEFINE SE_NO                := 6
DEFINE SE_CLOSE             := 7
DEFINE SE_DEFAULT           := 0x80000000
DEFINE E_DEFAULT            := FALSE
DEFINE E_RETRY              := TRUE
//	UH 10/09/1998
//	DEFINE E_EXCEPTION		:= 0x00001234
DEFINE E_EXCEPTION          := 5333L
// RvdH 04/16/2003 Added separate defines for various error conditions
DEFINE E_ACCESSVIOLATION		:= (5333L)
DEFINE E_DATATYPE_MISALIGNMENT 	:= (5334L)
DEFINE E_SINGLE_STEP			:= (5335L)
DEFINE E_ARRAY_BOUNDS_EXCEEDED	:= (5336L)
DEFINE E_FLT_DENORMAL_OPERAND	:= (5337L)
DEFINE E_FLT_DIVIDE_BY_ZERO		:= (5338L)
DEFINE E_FLT_INEXACT_RESULT		:= (5339L)
DEFINE E_FLT_INVALID_OPERATION	:= (5340L)
DEFINE E_FLT_OVERFLOW			:= (5341L)
DEFINE E_FLT_STACK_CHECK		:= (5342L)
DEFINE E_FLT_UNDERFLOW			:= (5343L)
DEFINE E_INT_DIVIDE_BY_ZERO		:= (5344L)
DEFINE E_INT_OVERFLOW			:= (5345L)
DEFINE E_PRIV_INSTRUCTION		:= (5346L)
DEFINE E_ILLEGAL_INSTRUCTION	:= (5347L)
DEFINE E_NONCONTINUABLE_EXCEPTION:= (5348L)
DEFINE E_STACK_OVERFLOW			:= (5349L)
DEFINE E_INVALID_DISPOSITION	:= (5350L)
DEFINE E_GUARD_PAGE				:= (5351L)
DEFINE EC_ALERT             := 0
DEFINE EC_IGNORE            := 1
DEFINE EC_RETRY             := 2
DEFINE EC_BREAK             := 3
DEFINE EG_APPENDLOCK        := 40
DEFINE EG_ARG               := 1
DEFINE EG_BADALIAS          := 17
DEFINE EG_BADPAGEFAULT      := 52
DEFINE EG_BADPTR            := 51
DEFINE EG_BOUND             := 2
DEFINE EG_CLOSE             := 22
DEFINE EG_COMPLEXITY        := 8
DEFINE EG_CORRUPTION        := 32
DEFINE EG_CREATE            := 20
DEFINE EG_DATATYPE          := 33
DEFINE EG_DATAWIDTH         := 34
DEFINE EG_DUPALIAS          := 18
DEFINE EG_DYNPTR            := 54
DEFINE EG_ERRORBLOCK        := 49
DEFINE EG_ERRORBUILD        := 53
DEFINE EG_EVALSTACK         := 48
DEFINE EG_LIMIT             := 31
DEFINE EG_LOCK              := 41
DEFINE EG_LOCK_ERROR        := 45
DEFINE EG_LOCK_TIMEOUT      := 46
DEFINE EG_MEM               := 11
DEFINE EG_MEMOVERFLOW       := 9
DEFINE EG_NOALIAS           := 15
DEFINE EG_NOATOM            := 26
DEFINE EG_NOCLASS           := 27
DEFINE EG_NOFUNC            := 12
DEFINE EG_NOMETHOD          := 13
DEFINE EG_NOORDER           := 36
DEFINE EG_NOTABLE           := 35
DEFINE EG_NOVAR             := 14
DEFINE EG_NOVARMETHOD       := 16
DEFINE EG_NUMERR            := 6
DEFINE EG_NUMOVERFLOW       := 4
DEFINE EG_OPEN              := 21
DEFINE EG_PRINT             := 25
DEFINE EG_PROTECTION        := 50
DEFINE EG_READ              := 23
DEFINE EG_READONLY          := 39
DEFINE EG_REFERENCE         := 29
DEFINE EG_SEQUENCE          := 10
DEFINE EG_SHARED            := 37
DEFINE EG_STACK             := 47
DEFINE EG_STROVERFLOW       := 3
DEFINE EG_SYNTAX            := 7
DEFINE EG_UNLOCKED          := 38
DEFINE EG_UNSUPPORTED       := 30
DEFINE EG_WRITE             := 24
DEFINE EG_WRONGCLASS        := 28
DEFINE EG_ZERODIV           := 5
DEFINE ES_CATASTROPHIC      := 3
DEFINE ES_ERROR             := 2
DEFINE ES_WARNING        := 1
DEFINE ES_WHOCARES       := 0
