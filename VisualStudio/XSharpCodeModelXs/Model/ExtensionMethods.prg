//
// Copyright (c) XSharp B.V.  All Rights Reserved.  
// Licensed under the Apache License, Version 2.0.  
// See License.txt in the project root for license information.
//

USING System
USING System.Linq
USING System.Collections.Generic
USING LanguageService.CodeAnalysis.XSharp


BEGIN NAMESPACE XSharpModel
	
	STATIC CLASS ExtensionMethods
		
		STATIC METHOD IsEmpty( SELF cType AS CompletionType) AS LOGIC
			RETURN cType == NULL .OR. ! cType:IsInitialized
		
		STATIC METHOD AddUnique<TKey, TValue>( SELF dict AS Dictionary<TKey, TValue>, key AS TKey, VALUE AS TValue) AS TValue 
			IF dict != NULL .AND. key != NULL
				IF ! dict:ContainsKey(key)
					dict:Add(key, VALUE)
					RETURN VALUE
				ENDIF
				RETURN dict:Item[key]
			ENDIF
			RETURN DEFAULT (TValue)
		
		
		STATIC METHOD DisplayName( SELF elementKind AS Kind) AS STRING
			SWITCH elementKind
				CASE Kind.VOGlobal
					RETURN "GLOBAL"
				CASE Kind.VODefine
					RETURN "DEFINE"
				CASE Kind.EnumMember
					RETURN "MEMBER"
			END SWITCH
			RETURN elementKind:ToString():ToUpper()
		
		STATIC METHOD HasParameters( SELF elementKind AS Kind) AS LOGIC
			SWITCH elementKind
				CASE Kind.Constructor 
				CASE Kind.Method 
				CASE Kind.Assign 
				CASE Kind.Access
				CASE Kind.Function 
				CASE Kind.Procedure 
				CASE Kind.Event 
				CASE Kind.Operator 
				CASE Kind.Delegate 
				CASE Kind.VODLL 
					//
					RETURN TRUE
			END SWITCH
			RETURN FALSE
		
		STATIC METHOD HasReturnType( SELF elementKind AS Kind ) AS LOGIC
			SWITCH elementKind
				CASE Kind.Method 
				CASE Kind.Access 
				CASE Kind.Property 
				CASE Kind.Function 
				CASE Kind.Field 
				CASE Kind.Local 
				CASE Kind.Parameter 
				CASE Kind.Operator 
				CASE Kind.Delegate 
				CASE Kind.VOGlobal 
				CASE Kind.VODefine 
					RETURN TRUE
			END SWITCH
			RETURN FALSE

		STATIC METHOD HasReturnType( SELF elementKind AS Kind, inDialect AS XSharpDialect) AS LOGIC
         IF inDialect == XSharpDialect.FoxPro .and. elementKind == Kind.Procedure
   			RETURN TRUE
			ENDIF
			RETURN HasReturnType(elementKind)
		
      STATIC METHOD IsGlobalType(SELF elementKind AS Kind) AS LOGIC
         SWITCH elementKind
         CASE Kind.VOGlobal
         CASE Kind.VODefine
         CASE Kind.Function
         CASE Kind.Procedure
         CASE Kind.VODLL
            RETURN TRUE
         END SWITCH
         RETURN FALSE
         
      
		STATIC METHOD IsClassMember( SELF elementKind AS Kind, inDialect AS XSharpDialect ) AS LOGIC
			SWITCH elementKind
				CASE Kind.Constructor 
				CASE Kind.Destructor 
				CASE Kind.Method 
				CASE Kind.Access 
				CASE Kind.Assign 
				CASE Kind.Property 
				CASE Kind.Event 
				CASE Kind.Operator 
					RETURN TRUE
				OTHERWISE
					IF ( inDialect == XSharpDialect.FoxPro )
						SWITCH elementKind
							CASE Kind.Function
							CASE Kind.Procedure
								RETURN TRUE
						END SWITCH
					ENDIF
			END SWITCH
			RETURN FALSE

		STATIC METHOD IsClassMethod( SELF elementKind AS Kind, inDialect AS XSharpDialect ) AS LOGIC
			SWITCH elementKind
				CASE Kind.Method 
					RETURN TRUE
				OTHERWISE
					IF ( inDialect == XSharpDialect.FoxPro )
						SWITCH elementKind
							CASE Kind.Function
							CASE Kind.Procedure
								RETURN TRUE
						END SWITCH
					ENDIF
			END SWITCH
			RETURN FALSE
		
		STATIC METHOD IsField( SELF elementKind AS Kind) AS LOGIC
			SWITCH elementKind
				CASE Kind.Field 
				CASE Kind.VOGlobal 
				CASE Kind.VODefine 
				CASE Kind.EnumMember
					RETURN TRUE
			END SWITCH
			RETURN FALSE
		
		STATIC METHOD IsType( SELF elementKind AS Kind) AS LOGIC
			SWITCH elementKind
				CASE Kind.Class 
				CASE Kind.Structure 
				CASE Kind.Interface 
				CASE Kind.Delegate 
				CASE Kind.Enum 
				CASE Kind.VOStruct 
				CASE Kind.Union 
					RETURN TRUE
			END SWITCH
			RETURN FALSE
         
		STATIC METHOD HasBody( SELF elementKind AS Kind) AS LOGIC
			SWITCH elementKind
				CASE Kind.Function
				CASE Kind.Procedure
				CASE Kind.Method
				CASE Kind.Access
				CASE Kind.Assign
				CASE Kind.Property
				CASE Kind.Event
				CASE Kind.Operator
				CASE Kind.Constructor
				CASE Kind.Destructor
					RETURN TRUE
			END SWITCH
			RETURN FALSE

        STATIC METHOD HasChildren(SELF eKind AS Kind) AS LOGIC
            SWITCH eKind
            CASE Kind.Namespace
            CASE Kind.Class
            CASE Kind.Structure
            CASE Kind.Interface
            CASE Kind.Enum
            CASE Kind.VOStruct
            CASE Kind.Union
                RETURN TRUE

            CASE Kind.Constructor
            CASE Kind.Destructor
            CASE Kind.Method
            CASE Kind.Access
            CASE Kind.Assign
            CASE Kind.Property
            CASE Kind.Function
            CASE Kind.Procedure
            CASE Kind.Field
            CASE Kind.Local
            CASE Kind.Parameter
            CASE Kind.Event
            CASE Kind.Operator
            CASE Kind.Delegate
            CASE Kind.EnumMember
            CASE Kind.Keyword
            CASE Kind.Using
            CASE Kind.VODefine
            CASE Kind.VODLL
            CASE Kind.VOGlobal
            CASE Kind.Unknown
            OTHERWISE
                RETURN FALSE
        END SWITCH                

            
		
   	//list exstensions
			STATIC METHOD AddUnique( SELF list AS List<STRING>, item AS STRING) AS VOID
			IF !list:Contains(item, System.StringComparer.OrdinalIgnoreCase)
				list:Add(item)
			ENDIF
		
		STATIC METHOD Expanded( SELF source AS IEnumerable<STRING>) AS IReadOnlyList<STRING>
			LOCAL list AS List<STRING>
			LOCAL item AS STRING
			list := List<STRING>{}
			list:AddRange(source)
			FOREACH str AS STRING IN source
				item := str
				WHILE (item:Contains("."))
					item := item:Substring(0, item:LastIndexOf("."))
					IF (! list:Contains(item))
						list:Add(item)
					ENDIF
				ENDDO
			NEXT
			RETURN list:AsReadOnly() 
		
         STATIC METHOD GetGlyph( SELF kind as Kind, visibility as Modifiers) AS LONG
      
				
				VAR imgK := ImageListKind.Class
				VAR imgO := ImageListOverlay.Public
				SWITCH kind
					CASE Kind.Class
						imgK := ImageListKind.Class
					CASE  Kind.Constructor 
					CASE Kind.Destructor 
					CASE Kind.Method 
					CASE Kind.Function 
					CASE Kind.Procedure 
						imgK := ImageListKind.Method
				CASE Kind.Structure
					CASE Kind.VOStruct 
					CASE Kind.Union 
						imgK := ImageListKind.Structure
					CASE Kind.Access 
					CASE Kind.Assign 
					CASE Kind.Property 
						imgK := ImageListKind.Property
					CASE Kind.Event
						imgK := ImageListKind.Event
					CASE Kind.Delegate
						
						imgK := ImageListKind.Delegate
					CASE Kind.Operator
						imgK := ImageListKind.Operator
					CASE Kind.VODefine
						imgK := ImageListKind.Const
					CASE Kind.Enum
						imgK := ImageListKind.Enum
					CASE Kind.EnumMember
						
						imgK := ImageListKind.EnumValue
					CASE Kind.Interface
						imgK := ImageListKind.Interface
					CASE Kind.Namespace
						imgK := ImageListKind.Namespace
					CASE Kind.VOGlobal 
					CASE Kind.Field 
						imgK := ImageListKind.Field
					CASE Kind.Parameter 
					CASE Kind.Local 
						imgK := ImageListKind.Local
					END SWITCH
				SWITCH visibility
					CASE Modifiers.Public
						imgO := ImageListOverlay.Public
					CASE Modifiers.Protected
						imgO := ImageListOverlay.Protected
					CASE Modifiers.Private
						imgO := ImageListOverlay.Private
					CASE Modifiers.Internal
						imgO := ImageListOverlay.Internal
					CASE Modifiers.ProtectedInternal
						imgO := ImageListOverlay.ProtectedInternal
							
				END SWITCH
				RETURN GetImageListIndex(imgK, imgO)
      
      		PRIVATE STATIC METHOD GetImageListIndex(kind AS ImageListKind, overlay AS ImageListOverlay) AS LONG
			         RETURN (LONG)((kind * ImageListKind.Unknown1) + (ImageListKind)(LONG)overlay  ) 
       

            
	END CLASS
END NAMESPACE 



