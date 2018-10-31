﻿// TestDbfNtx.prg
// Created by    : fabri
// Creation Date : 9/16/2018 4:17:53 PM
// Created for   : 
// WorkStation   : FABPORTABLE


USING System
USING System.Collections.Generic
USING System.Text
USING Xunit
USING XSharp.RDD
USING XSharp.Rdd.Support
USING System.Diagnostics
USING Xsharp.Core

BEGIN NAMESPACE XSharp.RDD.Tests

	/// <summary>
	/// The TestDbfNtx class.
	/// </summary>
	CLASS TestDbfNtx
	
		[Fact, Trait("DbfNtx", "Create")];
		METHOD CreateDBFNtx() AS VOID
			LOCAL fieldDefs := "ID,N,5,0;NAME,C,20,0;MAN,L,1,0;BIRTHDAY,D,8,0" AS STRING
			LOCAL fields := fieldDefs:Split( ';' ) AS STRING[]
			VAR dbInfo := DbOpenInfo{ "TestNtx1.DBF", "TestNtx1", 1, FALSE, FALSE }
			//
			LOCAL myDBF AS DbfNtx
			LOCAL fieldInfo AS STRING[]
			LOCAL rddInfo AS RddFieldInfo[]
			rddInfo := RddFieldInfo[]{fields:Length}
			FOR VAR i := __ARRAYBASE__ TO fields:Length - (1-__ARRAYBASE__)
				// 
				LOCAL currentField AS RddFieldInfo
				fieldInfo := fields[i]:Split( ',' )
				currentField := RddFieldInfo{ fieldInfo[DBS_NAME], fieldInfo[DBS_TYPE], Convert.ToInt32(fieldInfo[DBS_LEN]), Convert.ToInt32(fieldInfo[DBS_DEC]) }
				rddInfo[i] := currentField
			NEXT
			//
			myDBF := DbfNtx{}
			myDBF:SetFieldExtent( fields:Length )
			myDBF:CreateFields( rddInfo )
			// WE HAVE TO SET THE WORKAREA INFO !!!!
			dbInfo:WorkArea  := RuntimeState.Workareas:FindEmptyArea(TRUE)
			RuntimeState.Workareas:SetArea(dbInfo:WorkArea, myDBF)
			// Now Check
			Assert.Equal( TRUE, myDBF:Create( dbInfo ) )
			
			//
			LOCAL ntxInfo AS DbOrderCreateInfo
			ntxInfo := DbOrderCreateInfo{}
			ntxInfo:BagName := "TestNtx1"
			ntxInfo:Order := "TestNtx1"
			ntxInfo:Expression := "_FIELD->ID"
			//
			Assert.Equal( TRUE, myDBF:OrderCreate( ntxInfo ) )
			//
			myDBF:Close()
			RETURN
			
		[Fact, Trait("DbfNtx", "Open")];
		METHOD OpenDBFNtx() AS VOID
			// ID,N,5,0;NAME,C,20,0
			VAR dbInfo := DbOpenInfo{ "TestNTX2.DBF", "customer", 1, FALSE, FALSE }
			//
			LOCAL myDBF AS DbfNtx
			myDBF := DbfNtx{}
			// WE HAVE TO SET THE WORKAREA INFO !!!!
			LOCAL area  := 0    AS DWORD
			area  := RuntimeState.Workareas:FindEmptyArea(TRUE)
			RuntimeState.Workareas:SetArea(area, myDBF)
			RuntimeState.Workareas:CurrentWorkAreaNO := area
			dbInfo:WorkArea := area

			Assert.Equal( TRUE, myDBF:Open( dbInfo ) )
			//
			LOCAL ntxInfo AS DbOrderInfo
			ntxInfo := DbOrderInfo{}
			ntxInfo:BagName := "TestNTX2"
			ntxInfo:Order := "TestNTX2"
			// FilePath NullOrEmpty => Will get the FilePath of the DBF
			Assert.Equal( TRUE, myDBF:OrderListAdd( ntxInfo, "" ) )
			//
			myDBF:Close()
			RETURN
			
		[Fact, Trait("DbfNtx", "Read")];
		METHOD ReadDBFNtx() AS VOID
			//
			SELF:CheckOrder( "TestNTX2" )
			RETURN
			

        [Fact, Trait("DbfNtx", "CreateAppend")];
        METHOD CreateAppend() AS VOID
            LOCAL fieldDefs := "ID,N,5,0;NAME,C,20,0;MAN,L,1,0;BIRTHDAY,D,8,0" AS STRING
            LOCAL fields := fieldDefs:Split( ';' ) AS STRING[]
            VAR dbInfo := DbOpenInfo{ "XMenTest.DBF", "XMenTest", 1, FALSE, FALSE }
            //
            LOCAL myDBF AS DbfNtx
            LOCAL fieldInfo AS STRING[]
            LOCAL rddInfo AS RddFieldInfo[]
            rddInfo := RddFieldInfo[]{fields:Length}
            FOR VAR i := __ARRAYBASE__ TO fields:Length - (1-__ARRAYBASE__)
                // 
                LOCAL currentField AS RddFieldInfo
                fieldInfo := fields[i]:Split( ',' )
                currentField := RddFieldInfo{ fieldInfo[DBS_NAME], fieldInfo[DBS_TYPE], Convert.ToInt32(fieldInfo[DBS_LEN]), Convert.ToInt32(fieldInfo[DBS_DEC]) }
                rddInfo[i] := currentField
            NEXT
            //
			myDBF := DbfNtx{}
            myDBF:SetFieldExtent( fields:Length )
            myDBF:CreateFields( rddInfo )
			// WE HAVE TO SET THE WORKAREA INFO !!!!
			dbInfo:WorkArea  := RuntimeState.Workareas:FindEmptyArea(TRUE)
			RuntimeState.Workareas:SetArea(dbInfo:WorkArea, myDBF)
			// Now Check
			Assert.Equal( TRUE, myDBF:Create( dbInfo ) )
			
			//
			LOCAL ntxInfo AS DbOrderCreateInfo
			ntxInfo := DbOrderCreateInfo{}
			ntxInfo:BagName := "XMenTest"
			ntxInfo:Order := "XMenTest"
			ntxInfo:Expression := "ID"
			//
			Assert.Equal( TRUE, myDBF:OrderCreate( ntxInfo ) )
			//
            // Now, Add some Data
            //"ID,N,5,0;NAME,C,20,0;MAN,L,1,0;BIRTHDAY,D,8,0"
            LOCAL datas := "5,Diablo,T;2,Wolverine,T;4,Cyclops,T;3,Tornade,F;1,Professor Xavier,T" AS STRING
            LOCAL data := datas:Split( ';' ) AS STRING[]
            //
            FOR VAR i := __ARRAYBASE__ TO data:Length - (1-__ARRAYBASE__)
                // 
                LOCAL elt := data[i]:Split( ',' ) AS STRING[]
                myDBF:Append( FALSE )
                myDBF:PutValue( 1, Convert.ToInt32(elt[__ARRAYBASE__] ))
                myDBF:PutValue( 2, elt[__ARRAYBASE__+1])
                myDBF:PutValue( 3, String.Compare(elt[__ARRAYBASE__+2],"T",TRUE)==0 )
                myDBF:PutValue( 4, DateTime.Now )
            NEXT
			myDBF:Close()
			RuntimeState.Workareas:CloseArea( dbInfo:WorkArea )
            // Now, Verify
			SELF:CheckOrder( "XMenTest" )
            RETURN

		// Read a DBF/NTX who's first Field is a Number used as Index Key
		METHOD CheckOrder( baseFileName AS STRING ) AS VOID
			// 
			VAR dbInfo := DbOpenInfo{ baseFileName, "customer", 1, FALSE, FALSE }
			//
			LOCAL myDBF AS DbfNtx
			myDBF := DbfNtx{}
			// WE HAVE TO SET THE WORKAREA INFO !!!!
			LOCAL area  := 0    AS DWORD
			area  := RuntimeState.Workareas:FindEmptyArea(TRUE)
			RuntimeState.Workareas:SetArea(area, myDBF)
			RuntimeState.Workareas:CurrentWorkAreaNO := area
			dbInfo:WorkArea := area
			VAR success := myDBF:Open( dbInfo ) 
			Assert.Equal( TRUE, success )
			//
			//FieldPos( "ID" )
			LOCAL ntxInfo AS DbOrderInfo
			ntxInfo := DbOrderInfo{}
			ntxInfo:BagName := baseFileName
			ntxInfo:Order := baseFileName
			// FilePath NullOrEmpty => Will get the FilePath of the DBF
			Assert.Equal( TRUE, myDBF:OrderListAdd( ntxInfo, "" ) )
			myDBF:GoTop()
			//
			LOCAL idList AS List<INT>
			idList := List<INT>{}
			WHILE ! myDBF:EoF
//				Debug.Write( "---===---" + Environment.NewLine )
//				FOR VAR i := 1 TO myDBF:FIELDCount
//					// 
//					LOCAL oData AS OBJECT
//					oData := myDBF:GetValue( i )
//					LOCAL str AS STRING
//					str := oData:ToString()
//					Debug.Write( str +" - " )
//				NEXT
//				Debug.Write( Environment.NewLine )
				LOCAL oData AS OBJECT
				// Field 1 == ID
				oData := myDBF:GetValue( 1 )
				idList:Add( (INT)oData )
				myDBF:Skip(1)
			ENDDO
			// Check that the ID are sorted by value
			FOR VAR i := 0 TO (idList:Count-2)
				Assert.Equal( TRUE, idList[i] <= idList[i+1] )
			NEXT
			//
			RuntimeState.Workareas:CloseArea( area )
			//myDBF:Close()
			RETURN


	END CLASS
END NAMESPACE // XSharp.RDD.Tests