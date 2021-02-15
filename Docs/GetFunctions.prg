USING System.Reflection
USING System.Collections.Generic
USING System.Linq
USING System.Text
FUNCTION Start AS VOID
    //CreateSectionFiles()  
    WriteTopics()
    //CreateFunctionList()

FUNCTION WriteTopics() AS VOID
    VAR aInfo       := ReadFunctionList()
    VAR aCategories := ReadCategories()
    VAR catList     := List<STRING>{}                  
    VAR sPath := "c:\XSharp\DevRt\Docs\Categories\"    
    FOREACH VAR item IN aInfo
        FOREACH VAR cat IN item:Value     
            IF ! String.IsNullOrEmpty(cat:ToLower())
                IF ! catList:Contains(cat:ToLower())
                    catList:Add(cat:ToLower())
                ENDIF              
            ENDIF                
        NEXT
    NEXT
    VAR missing := FALSE         
    catList:Sort()
    FOREACH VAR cat IN catList
        IF ! aCategories:Contains(cat)
            ? "Category "+cat+" is missing"
            missing := TRUE
        ENDIF
    NEXT
    IF missing
        RETURN
    ENDIF
    FOREACH VAR cat IN catList
        ? cat
        VAR sFile := sPath+cat+"_Functions.aml"
        VAR contents := System.IO.File.ReadAllText(sFile)
        VAR left   := contents:Substring(0, contents:IndexOf("<content>")+9)
        VAR right  := contents:Substring(contents:IndexOf("</content>"))
        VAR sb     := StringBuilder{} 
        sb:Append(left)       
        sb:AppendLine("<table><tableHeader>")
        sb:AppendLine("<row><entry><para>Assembly</para></entry>")
        sb:AppendLine("<entry><para>Function</para></entry>")
        sb:AppendLine("</row></tableHeader>")
        FOREACH VAR item IN aInfo  
            VAR match := FALSE
            FOREACH VAR keyword IN item:Value
                IF String.Compare(keyword, cat, TRUE) == 0
                    match := TRUE
                    EXIT
                ENDIF
            NEXT                             
            IF match      
                VAR tokens := item:Key:Split(<Char>{':'})
                VAR assembly := tokens[1]:replace(".DLL","")
                sb:Append("<row><entry><para>"+assembly+"</para></entry>")
                sb:Append("<entry><para><codeEntityReference qualifyHint=""false"" autoUpgrade=""true"">")
                sb:Append("O:")                                               
                sb:Append(Assembly)
                sb:Append(".Functions.")
                sb:Append(tokens[2])
                sb:AppendLine("</codeEntityReference></para></entry></row>")
            ENDIF
        NEXT
        sb:AppendLine("</table>")
        sb:Append(right)
        System.IO.File.WriteAllText(sFile, sb:ToString())
    NEXT
    
    RETURN
                  

FUNCTION CreateSectionFiles AS VOID
    VAR sPath := "c:\XSharp\DevRt\Docs\Categories\"    
    VAR sTemplate := sPath+"template.aml"
    VAR aLines := ReadCategories()
    FOREACH VAR sLine IN aLines              
        ? sLine
        VAR sFile := sPath+sLine+"_Functions.aml"
        IF ! System.IO.File.Exists(sFile)        
            VAR file := System.IO.File.ReadAllText(sTemplate)
            file := file.Replace("id=""default""", "id=""cat-"+sLine+"_Functions""")
            file := file.Replace("title=""default functions""", "title="""+sLine+" Functions""")
            file := file.Replace("<title>default Functions</title>", "<title>"+sLine +" Functions</title>")
            System.IO.File.WriteAllText(sFile, file)
        ENDIF
    NEXT

FUNCTION CreateFunctionList AS VOID
    LOCAL aFiles AS STRING[]               
    LOCAL sPath  AS STRING
    LOCAL aInfo  AS Dictionary<STRING, STRING[]>
    aFiles := <STRING>{"XSharp.Core.DLL", "XSharp.RT.DLL","XSharp.VO.DLL", ;
        "XSharp.Data.DLL","XSharp.VFP.DLL","XSharp.RDD.DLL","XSharp.XPP.DLL","VOSystemClasses.DLL","VORDDClasses.DLL","VOGUIClasses.DLL","VOSQLClasses.DLL","VOInternetClasses.DLL"}
    sPath := "c:\XSharp\DevRt\Binaries\Documentation\"    
    aInfo := ReadFunctionList()
    FOREACH VAR sFile IN aFiles                    
        TRY
        VAR asm   := Assembly.LoadFrom(sPath+sFile)
        VAR types := asm:GetTypes()
        FOREACH type AS System.Type IN types
            IF type:FullName:EndsWith(".Functions")
                VAR functions := type:GetMethods(BindingFlags.Public+BindingFlags.Static)
                FOREACH m AS MethodInfo IN functions      
                    VAR name := m:Name
                    IF (name:StartsWith("$") || name:StartsWith("__")   )
                        LOOP
                    ENDIF
                    IF m:GetCustomAttributes(typeof(ObsoleteAttribute),FALSE):Count() > 0
                        VAR key := sFile+":"+m.Name
                        IF aInfo:ContainsKey(key)
                            aInfo:Remove(key)
                        ENDIF
                        LOOP                        
                    ENDIF
                    TRY      
                        VAR key := sFile+":"+m.Name
                        IF !aInfo:ContainsKey(m.Name)
                            ? m.Name
                            aInfo:Add(key, STRING[]{0})
                        ENDIF
                    CATCH  AS Exception
                        
                    END TRY
                NEXT
            ENDIF
        NEXT
        CATCH e AS ReflectionTypeLoadException
            ? "Failed to load ", sFile
            ? e:ToString()           
            ? 
            Console.ReadLine()
        END TRY
    NEXT                     
    VAR output := System.IO.File.CreateText("RuntimeFunctions.CSV")
    FOREACH VAR item IN aInfo
        VAR sKey := item:Key:Replace(":",",")
        VAR groups := item:Value
        VAR sGroups := ""
        FOREACH VAR sGroup IN groups
            sGroups += ","+sGroup
        NEXT
        output:WriteLine(sKey+sGroups )
    NEXT
    output:Close()
    
    
FUNCTION ReadFunctionList() AS Dictionary<STRING, STRING[]>     
    VAR aInfo := Dictionary<STRING, STRING[]> {}
    IF System.IO.File.Exists("RuntimeFunctions.CSV")
        VAR aLines := System.IO.File.ReadAllLines("RuntimeFunctions.CSV")
        FOREACH VAR line IN aLines
            VAR aElements := line:Split(<char>{','})
            IF aElements:Length >= 2
                VAR cKey := aElements[1]+":"+aElements[2]
                VAR groups := STRING[]{aElements:Length -2}
                FOR VAR i := 1 TO aElements:Length-2
                    groups[i] := aElements[i+2]
                NEXT                           
                aInfo:Add(cKey, groups)
            ENDIF
        NEXT
    ENDIF
    RETURN aInfo                     
    
FUNCTION ReadCategories() AS STRING[]    
    VAR list := List<STRING>{}
    IF System.IO.File.Exists("Categories.CSV")    
        VAR aLines := System.IO.File.ReadAllLines("Categories.CSV")        
        FOREACH VAR sLine IN aLines              
            IF ! String.IsNullOrEmpty(sLine)
                list:Add(sLine:ToLower())
            ENDIF
        NEXT
    ENDIF
    RETURN list:ToArray()
