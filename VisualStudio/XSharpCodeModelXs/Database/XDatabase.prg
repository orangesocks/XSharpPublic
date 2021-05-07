﻿//
// Copyright (c) XSharp B.V.  All Rights Reserved.  
// Licensed under the Apache License, Version 2.0.  
// See License.txt in the project root for license information.
//

USING System.Data.SQLite
USING System.IO
USING System.Data
USING System.Linq
USING System.Data.Common
USING System.Collections.Generic
USING System.ComponentModel

BEGIN NAMESPACE XSharpModel
	STATIC CLASS XDatabase
	STATIC PRIVATE oConn   AS SQLiteConnection     // In memory database !
	STATIC PRIVATE lastWritten := DateTime.MinValue AS DateTime
	STATIC PRIVATE currentFile AS STRING
	PRIVATE CONST CurrentDbVersion := 0.6 AS System.Double
		
		STATIC METHOD CreateOrOpenDatabase(cFileName AS STRING) AS VOID
			LOCAL lValid := FALSE AS LOGIC
			LOCAL oDiskDb AS SQLiteConnection
			currentFile := cFileName
			IF System.IO.File.Exists(cFileName)
				oDiskDb := OpenFile(cFileName)
				IF ! ValidateSchema(oDiskDb)
						oDiskDb:Close()
						oDiskDb:Dispose()
					System.IO.File.Delete(cFileName)
				ELSE
					lValid := TRUE
				ENDIF
			ENDIF
			oConn := SQLiteConnection{"Data source=:Memory:"}
			oConn:Open()
			SetPragmas(oConn)
			IF ! lValid
					CreateSchema(oConn)
				SaveToDisk(oConn,cFileName )
			ELSE
				RestoreFromDisk(oDiskDb, oConn)
				oDiskDb:Close()
			ENDIF
		RETURN 
		
		STATIC METHOD SaveDatabase(cFile AS STRING) AS LOGIC
			IF IsDbOpen
				SaveToDisk(oConn, cFile)
				RETURN TRUE
			ENDIF
		RETURN FALSE
		
		STATIC METHOD CloseDatabase(cFile AS STRING) AS LOGIC
			IF IsDbOpen
				SaveToDisk(oConn, cFile)
				oConn:Close()
				RETURN TRUE
			ENDIF
			oConn := NULL
		RETURN FALSE
		
		STATIC METHOD SetPragmas(oConn AS SQLiteConnection) AS VOID
			IF ! IsDbOpen
				RETURN
			ENDIF
			BEGIN LOCK oConn
				USING VAR oCmd := SQLiteCommand{"PRAGMA foreign_keys = ON", oConn}
				oCmd:ExecuteNonQuery()
				oCmd:CommandText := "VACUUM"
				oCmd:ExecuteNonQuery()
			END LOCK
		RETURN
		
		STATIC METHOD OpenFile(cFile AS STRING) AS SQLiteConnection
			VAR db := SQLiteConnection{"Data Source="+cFile+";Version=3;"}
			db:Open()    
			SetPragmas(db)
		RETURN db
		
		STATIC METHOD SaveToDisk(oConn AS SQLiteConnection, cFile AS STRING) AS VOID
			IF ! IsDbOpen
				RETURN
			ENDIF
			IF System.IO.File.Exists(cFile)
				System.IO.File.SetAttributes(cFile, FileAttributes.Normal)
				System.IO.File.Delete(cFile)
			ENDIF
			VAR diskdb := OpenFile(cFile)
			oConn:BackupDatabase(diskdb, "main", "main", -1, NULL, 0)
			USING VAR oCmd := SQLiteCommand{"VACUUM", diskdb}
			oCmd:ExecuteNonQuery()
			diskdb:Close()
			lastWritten := DateTime.Now
		RETURN         
		
		STATIC METHOD RestoreFromDisk(oDiskDb AS SQLiteConnection, oConn AS SQLiteConnection) AS VOID
			IF ! IsDbOpen
				RETURN
			ENDIF
			oDiskDb:BackupDatabase(oConn, "main", "main", -1, NULL, 0)
			lastWritten := DateTime.Now
		RETURN         
		
		STATIC METHOD CommitWhenNeeded() AS VOID
			VAR ts := DateTime.Now - lastWritten
			// Save to disk every 5 minutes
			Log(i"Time since last backup {ts}")
			IF ts:Minutes >= 5 .OR. ts:Hours > 0
				LOCAL oBW AS BackgroundWorker    
				oBW := BackgroundWorker{}
				oBW:DoWork += BackupInBackground
				oBW:RunWorkerAsync()
				
		ENDIF
		
		STATIC METHOD BackupInBackground(sender AS OBJECT , args AS DoWorkEventArgs ) AS VOID
			IF ! IsDbOpen
				RETURN
			ENDIF
			BEGIN LOCK oConn
				TRY
						//XSolution.SetStatusBarText("Backing up intellisense database...")
						//XSolution.SetStatusBarAnimation(TRUE, 2)
						Log("Starting backup to "+currentFile)
						SaveToDisk(oConn, currentFile )
				CATCH e AS Exception
					Log("Exception: "+e:ToString())
				FINALLY
					//XSolution.SetStatusBarText("")
					//XSolution.SetStatusBarAnimation(FALSE, 2)
               NOP
				END TRY
			END LOCK
    		Log("Completed backup to "+currentFile)
		RETURN
		
		STATIC METHOD CreateSchema(connection AS SQLiteConnection) AS VOID
			BEGIN LOCK connection
				VAR cmd := SQLiteCommand{"SELECT 1",connection}
				Log("Creating new database schema")
				#region Drop Existing Tables
				cmd:CommandText := "DROP TABLE IF EXISTS Projects ;"
				cmd:CommandText += "DROP TABLE IF EXISTS FilesPerProject ;"
				cmd:CommandText += "DROP TABLE IF EXISTS Files ;"
				cmd:CommandText += "DROP TABLE IF EXISTS Types ;"
				cmd:CommandText += "DROP TABLE IF EXISTS Members ;"
				cmd:CommandText += "DROP TABLE IF EXISTS Assemblies ;"
				cmd:CommandText += "DROP TABLE IF EXISTS ReferencedTypes ;"
				cmd:CommandText += "DROP TABLE IF EXISTS CommentTasks ;"
				cmd:ExecuteNonQuery()		
				#endregion
				#region Table Projects
				VAR stmt	:= "Create Table Projects ("
				stmt     	+= " Id integer NOT NULL PRIMARY KEY, ProjectFileName text NOT NULL COLLATE NOCASE "
				stmt		+= " ) ;"
                stmt	    += "CREATE UNIQUE INDEX Projects_Pk ON Projects (Id) ;"
				stmt	    += "CREATE INDEX Projects_Name      ON Projects (ProjectFileName) "
				cmd:CommandText := stmt
				cmd:ExecuteNonQuery()				
				#endregion
				#region Table Files
				stmt  		:= "CREATE TABLE Files ("
				stmt     	+= " Id integer NOT NULL PRIMARY KEY, FileName text NOT NULL COLLATE NOCASE,  "
				stmt     	+= " FileType integer NOT NULL, LastChanged DateTime NOT NULL, Size integer, Usings text, StaticUsings text"
				stmt		+= " ) ;"
                stmt	    += "CREATE UNIQUE INDEX Files_Pk    ON Files (Id) ;"
				stmt	    += "CREATE INDEX Files_Name         ON Files (FileName) "
				cmd:CommandText := stmt
				cmd:ExecuteNonQuery()				
				#endregion
				#region Table FilesPerProject
				
				stmt    := "CREATE TABLE FilesPerProject ("
				stmt	+= " idFile integer NOT NULL, idProject integer NOT NULL, " 
				stmt    += " PRIMARY KEY (idFile, idProject), " 
				stmt	+= " FOREIGN KEY (idFile) 	  REFERENCES Files (Id)    ON DELETE CASCADE ON UPDATE CASCADE, " 
				stmt    += " FOREIGN KEY (idProject) REFERENCES Projects (Id) ON DELETE CASCADE ON UPDATE CASCADE "
				stmt	+= " ) ;"
				stmt	+= "CREATE UNIQUE INDEX FilesPerProject_Pk  ON FilesPerProject (idFile, idProject); "
				stmt	+= "CREATE INDEX FilesPerProject_File       ON FilesPerProject (idFile) ;"
				stmt	+= "CREATE INDEX FilesPerProject_Project    ON FilesPerProject (idProject) "
				cmd:CommandText := stmt
				cmd:ExecuteNonQuery()				

				#endregion
				#region Table Types
				
				stmt  	:= "CREATE TABLE Types ("
				stmt	+= " Id integer NOT NULL PRIMARY KEY, idFile integer NOT NULL, Name text NOT NULL COLLATE NOCASE, Namespace text NOT NULL COLLATE NOCASE, "
				stmt    += " Kind integer NOT NULL, BaseTypeName text COLLATE NOCASE, Attributes integer NOT NULL, "
				stmt    += " StartLine integer , StartColumn integer, EndLine integer , EndColumn integer, Start integer , Stop integer,  "
				stmt	+= " Sourcecode text , XmlComments text, ClassType integer NOT NULL, "
				stmt    += " FOREIGN KEY (idFile) REFERENCES Files (Id) ON DELETE CASCADE ON UPDATE CASCADE"
				stmt	+= ") ;"
				stmt	+= "CREATE UNIQUE INDEX Types_Pk    ON Types (Id); "
				stmt	+= "CREATE INDEX Types_Name         ON Types (Name); "
				stmt	+= "CREATE INDEX Types_BaseTypeName ON Types (BaseTypeName); "
				stmt	+= "CREATE INDEX Types_Kind         ON Types (Kind) "
				cmd:CommandText := stmt
				cmd:ExecuteNonQuery()				
				
				#endregion
				#region Table Members
				
				stmt    := "CREATE TABLE Members ("
				stmt	+= " Id integer NOT NULL PRIMARY KEY, IdType integer NOT NULL , IdFile integer NOT NULL, "
				stmt	+= " Name text COLLATE NOCASE, Kind integer, Attributes integer NOT NULL, StartLine integer , StartColumn integer ,  "
				stmt	+= " EndLine integer , EndColumn integer , Start integer , Stop integer , Sourcecode text , XmlComments text,"
				stmt	+= " FOREIGN KEY (idType) REFERENCES Types (Id) ON DELETE CASCADE ON UPDATE CASCADE, " 
				stmt    += " FOREIGN KEY (idFile) REFERENCES Files (Id) ON DELETE CASCADE ON UPDATE CASCADE"
				stmt	+= ");"
				stmt	+= "CREATE UNIQUE INDEX Members_Pk  ON Members (Id); "
				stmt	+= "CREATE INDEX Members_Name       ON Members (Name); "
				stmt	+= "CREATE INDEX Members_Type       ON Members (idType); "
				stmt	+= "CREATE INDEX Members_File       ON Members (idFile); "
				stmt	+= "CREATE INDEX Members_Kind       ON Members (Kind) "
				cmd:CommandText := stmt
				cmd:ExecuteNonQuery()		
				
				#endregion
				
				
				#region Table Assemblies
				stmt  	:= "CREATE TABLE Assemblies ("
				stmt	+= " Id integer NOT NULL PRIMARY KEY, Name text NOT NULL COLLATE NOCASE, AssemblyFileName text NOT NULL COLLATE NOCASE, "
				stmt    += " LastChanged DateTime NOT NULL, Size integer "
				stmt	+= ") ;"
				stmt	+= "CREATE UNIQUE INDEX Assemblies_Pk   ON Assemblies (Id);"
				stmt	+= "CREATE INDEX Assemblies_Name        ON Assemblies (Name);"
				stmt	+= "CREATE INDEX Assemblies_FileName    ON Assemblies (AssemblyFileName) "
				cmd:CommandText := stmt
				cmd:ExecuteNonQuery()				
				
				#endregion
				#region Table ReferencedTypes
				stmt  	:= "CREATE TABLE ReferencedTypes ("
				stmt	+= " Id integer NOT NULL PRIMARY KEY, idAssembly integer NOT NULL, Name text NOT NULL COLLATE NOCASE, Namespace text NOT NULL COLLATE NOCASE, "
				stmt    += " FullName text NOT NULL, Kind integer NOT NULL, BaseTypeName text COLLATE NOCASE, Attributes integer NOT NULL, "
				stmt    += " FOREIGN KEY (idAssembly) REFERENCES Assemblies (Id) ON DELETE CASCADE ON UPDATE CASCADE"
				stmt	+= ") ;"
				stmt	+= "CREATE UNIQUE INDEX ReferencedTypes_Pk      ON ReferencedTypes (Id); "
				stmt	+= "CREATE INDEX ReferencedTypes_Name           ON ReferencedTypes (Name); "
				stmt	+= "CREATE INDEX ReferencedTypes_BaseTypeName   ON ReferencedTypes (BaseTypeName); "
				stmt	+= "CREATE INDEX ReferencedTypes_FullName       ON ReferencedTypes (FullName); "
				stmt	+= "CREATE INDEX ReferencedTypes_Kind           ON ReferencedTypes (Kind); "
				cmd:CommandText := stmt
				cmd:ExecuteNonQuery()		         
				#endregion
				
				#region Table CommentTasks
				stmt  	:=  "CREATE TABLE CommentTasks ("
				stmt	+=  " Id integer NOT NULL PRIMARY KEY, idFile integer NOT NULL, Line integer, Column integer, Priority integer,  "
				stmt    +=  " Comment text NOT NULL, "
				stmt    +=  " FOREIGN KEY (idFile) REFERENCES Files (Id) ON DELETE CASCADE ON UPDATE CASCADE"
				stmt	+= ") ;"
				stmt	+= "CREATE UNIQUE INDEX CommentTasks_Pk ON ReferencedTypes (Id); "
                stmt	+= "CREATE INDEX CommentTasks_File      ON CommentTasks (idFile) "
				cmd:CommandText := stmt
				cmd:ExecuteNonQuery()				
				
				
				#endregion
				cmd:Parameters:Clear()
				
				#region views
				stmt := " CREATE VIEW ProjectFiles AS SELECT fp.IdFile, f.FileName, f.FileType, f.LastChanged, f.Size, fp.IdProject, p.ProjectFileName " + ;
				" FROM Files f JOIN FilesPerProject fp ON f.Id = fp.IdFile JOIN Projects p ON fp.IdProject = P.Id"
				cmd:CommandText := stmt
				cmd:ExecuteNonQuery()		
				
				stmt := "CREATE VIEW TypeMembers AS SELECT m.*, t.Name AS TypeName, t.Namespace, t.BaseTypeName, t.ClassType " + ;
				"FROM members m JOIN Types t ON m.IdType = t.Id"
				cmd:CommandText := stmt
				cmd:ExecuteNonQuery()		
				
				stmt := "CREATE VIEW ProjectTypes AS SELECT t.*, p.IdProject, p.FileName, p.ProjectFileName " +;
				" FROM Types t  JOIN ProjectFiles p ON t.IdFile = p.IdFile "
				cmd:CommandText := stmt
				cmd:ExecuteNonQuery()		
				
				
				stmt := "CREATE VIEW ProjectMembers AS SELECT m.*, p.IdProject, p.FileName, p.ProjectFileName " +;
				" FROM TypeMembers m  JOIN ProjectFiles p ON m.IdFile = p.IdFile "
				cmd:CommandText := stmt
				cmd:ExecuteNonQuery()		
				
				stmt := "CREATE VIEW AssemblyTypes AS SELECT t.*, t.IdAssembly, a.AssemblyFileName " +;
				" FROM ReferencedTypes t  JOIN Assemblies a ON t.IdAssembly = a.Id "
				cmd:CommandText := stmt
				cmd:ExecuteNonQuery()		
				
				stmt := " CREATE VIEW ProjectCommentTasks AS SELECT c.*, pf.IdProject, pf.ProjectFileName, pf.FileName FROM CommentTasks c" + ;
				" JOIN ProjectFiles pf ON c.IdFile = pf.IdFile JOIN Projects p ON pf.IdProject = p.Id" 
				cmd:CommandText := stmt
				cmd:ExecuteNonQuery()		
				
				#endregion
				
				#region Table DB_Version
				stmt  	:= 	"CREATE TABLE Db_Version ("
				stmt	   += 	" Id integer NOT NULL PRIMARY KEY, Version REAL"
				stmt	   +=  ")"
				cmd:CommandText := stmt
				cmd:ExecuteNonQuery()		
				
				stmt	:=  "INSERT INTO Db_version(Version) values ($version)"
				cmd:CommandText := stmt
				cmd:Parameters:Clear()
				cmd:Parameters:AddWithValue("$version",CurrentDbVersion)
				cmd:ExecuteNonQuery()		
				#endregion
				
			END LOCK
		RETURN
		
		STATIC METHOD ValidateSchema( connection AS SQLiteConnection) AS LOGIC
			LOCAL lOk AS LOGIC
			lOk := TRUE
			BEGIN LOCK connection
				DO WHILE lOk
					USING VAR cmd  := SQLiteCommand{"SELECT 1", connection}
					VAR stmt := "SELECT count(name) from sqlite_master WHERE type='table' AND name=$table"
					cmd:CommandText := stmt
					VAR tables := <STRING> {"Projects","FilesPerProject","Files", "Types", "Members", "Db_Version","Assemblies","ReferencedTypes","CommentTasks"}
					FOREACH VAR table IN tables    
						cmd:Parameters:Clear()
						cmd:Parameters:AddWithValue("$table",table)
						VAR num := (INT64) cmd:ExecuteScalar()
						IF num != 1
							lOk := FALSE
							EXIT
						ENDIF
                      NEXT
                      IF lOk
						       cmd:CommandText := "SELECT Max(Version) from Db_version"
                         var vers := (System.Double) 0.0 
                         TRY
						          vers := (System.Double) cmd:ExecuteScalar()
                         CATCH  as Exception
                            vers := (System.Double) 0.0 
                         END TRY
						       IF vers != CurrentDbVersion
							       lOk := FALSE
                         ENDIF			
                      ENDIF
					EXIT
				ENDDO		
			END LOCK
			Log(i"Validate database schema: {lOk}")
		RETURN lOk	         
		
		
		
		STATIC METHOD GetProjectNames() AS List<STRING>
			VAR result := List<STRING>{}
			IF IsDbOpen
				BEGIN LOCK oConn
					USING VAR cmd := SQLiteCommand{"SELECT ProjectFileName from Projects", oConn}
					USING VAR rdr := cmd:ExecuteReader()
					DO WHILE rdr:Read()
						VAR name := rdr:GetString(0)
						result:Add(name)
					ENDDO
				END LOCK  
			ENDIF
			Log(i"GetProjectNames returned {result.Count} names")
			RETURN result
			
		#region CRUD projects      
		STATIC METHOD Read(oProject AS XProject) AS VOID
			IF ! IsDbOpen .OR. String.IsNullOrEmpty(oProject:FileName)  
				RETURN
			ENDIF
			VAR file    := oProject:FileName
			VAR lUpdated := FALSE
			Log(i"Read Project info for project {file}")
			BEGIN LOCK oConn
				USING VAR cmd := SQLiteCommand{"", oConn}
				cmd:CommandText := "SELECT Id, ProjectFileName from Projects WHERE ProjectFileName = $file"
				cmd:Parameters:AddWithValue("$file",file)
				VAR lOk := FALSE 
				BEGIN USING VAR rdr := cmd:ExecuteReader()
				    IF rdr:Read()
					    oProject:Id := rdr:GetInt64(0)
					    lOk := TRUE
                    ENDIF
                END USING
				IF ! lOk
					cmd:CommandText := "INSERT INTO Projects( ProjectFileName ) values ($file); SELECT last_insert_rowid() "
					VAR id := (INT64) cmd:ExecuteScalar()
					oProject:Id := id
					lUpdated := TRUE
				ENDIF
			END LOCK
			IF lUpdated
				CommitWhenNeeded()
			ENDIF
		RETURN
		
		STATIC METHOD DeleteProject(cFileName AS STRING) AS VOID
			IF ! IsDbOpen .OR. String.IsNullOrEmpty(cFileName)  
				RETURN
			ENDIF
			VAR file := cFileName
			BEGIN LOCK oConn
				USING VAR cmd := SQLiteCommand{"", oConn}
				cmd:CommandText := "delete from Projects where ProjectFileName = $file" 
				cmd:Parameters:AddWithValue("$file",file)
				cmd:ExecuteNonQuery()
			END LOCK
			CommitWhenNeeded()
		#endregion        
		
		#region CRUD files
		
		STATIC METHOD DeleteFile(cFileName AS STRING) AS VOID
			IF ! IsDbOpen .OR. String.IsNullOrEmpty(cFileName)
				RETURN
			ENDIF
			VAR file    := cFileName
			Log(i"Delete Project info for project {cFileName}")
			BEGIN LOCK oConn
				USING VAR cmd := SQLiteCommand{"", oConn}
				cmd:CommandText := "DELETE FROM Files WHERE FileName = $file" 
				cmd:Parameters:AddWithValue("$file",file)
				cmd:ExecuteNonQuery()
			END LOCK
		CommitWhenNeeded()
		
		STATIC METHOD Read(oFile AS XFile) AS VOID
			IF ! IsDbOpen .OR. String.IsNullOrEmpty(oFile:FullPath)
				RETURN
			ENDIF
			VAR file    := oFile:FullPath
			Log(i"Read File info for file {file}")
		/*
		"Create Table Files ("
		" Id integer NOT NULL PRIMARY KEY, FileName text NOT NULL COLLATE NOCASE "
		" FileType integer NOT NULL, LastChanged DateTime NOT NULL, Size integer, Usings text, StaticUsings text"
		" )"
		
		"Create Table FilesPerProject ("
		" idFile integer NOT NULL, idProject integer NOT NULL, " 
		" PRIMARY KEY (idFile, idProject), " 
		" FOREIGN KEY (idFile) 	  REFERENCES Files (Id)    ON DELETE CASCADE ON UPDATE CASCADE, " 
		" FOREIGN KEY (idProject) REFERENCES Projects (Id) ON DELETE CASCADE ON UPDATE CASCADE "
		" )"
		
		
		*/
		LOCAL lUpdated := FALSE AS LOGIC
		BEGIN LOCK oConn
			TRY
				USING VAR cmd := SQLiteCommand{"", oConn}
				cmd:CommandText := "SELECT Id, LastChanged, Size, Usings,StaticUsings FROM Files WHERE FileName = $file"
				cmd:Parameters:AddWithValue("$file",file)
				VAR lOk := FALSE 
				BEGIN USING VAR rdr := cmd:ExecuteReader()
					IF rdr:Read()
						oFile:Id                := rdr:GetInt64(0)
						oFile:LastChanged       := rdr:GetDateTime(1)
                        // these can be NULL
						oFile:Size              := DbToInt(rdr[2])
						oFile:UsingsStr         := DbToString(rdr[3])
						oFile:StaticUsingsStr := DbToString(rdr[4])
						lOk := TRUE
                    ENDIF
                END USING
				IF ! lOk
					cmd:Parameters:AddWithValue("$type",(INT) oFile:XFileType)
					cmd:Parameters:AddWithValue("$last", DateTime.MinValue)
					cmd:CommandText := "INSERT INTO Files( FileName, FileType, LastChanged, Size ) VALUES ( $file, $type, $last, 0); "+ ;
					"SELECT last_insert_rowid() "
					VAR id := (INT64) cmd:ExecuteScalar()
					oFile:Id := id
					oFile:LastChanged := DateTime.MinValue
					oFile:Size        := 0
					lUpdated := TRUE
                ENDIF
				cmd:CommandText := "SELECT count(idFile) FROM FilesPerProject WHERE idFile = $idFile and idProject = $idProject"
				cmd:Parameters:Clear()
				cmd:Parameters:AddWithValue("$idFile",oFile:Id)
				cmd:Parameters:AddWithValue("$idProject",oFile:Project:Id)
				VAR count := (INT64) cmd:ExecuteScalar()
				IF (count == 0)
					cmd:CommandText := "INSERT INTO FilesPerProject(idFile, idProject) VALUES ($idFile, $idProject)"
					cmd:ExecuteNonQuery()
				ENDIF
			CATCH e AS Exception
				Log("Exception: "+e:ToString())
				Log("File   : "+oFile:FullPath+" "+oFile:Id:ToString())
				
			END TRY
		END LOCK
		IF lUpdated
			CommitWhenNeeded()
		ENDIF
		RETURN
		
		STATIC PRIVATE METHOD UpdateFileData(oFile AS XFile) AS VOID
			IF ! IsDbOpen
				RETURN
			ENDIF
			Log(i"Update File info for file {oFile.FullPath}")
			BEGIN LOCK oConn
				TRY
               IF System.IO.File.Exists(oFile:FullPath)  // for files from SCC the physical file does not always exist
					USING VAR oCmd := SQLiteCommand{"SELECT 1", oConn}
					oCmd:CommandText := "UPDATE Files SET LastChanged = $last, Size = $size, Usings = $usings, StaticUsings = $staticUsings WHERE id = "+oFile:Id:ToString()
					VAR fi            := FileInfo{oFile:FullPath}
					oFile:LastChanged := fi:LastWriteTime
					oFile:Size        := fi:Length
					oCmd:Parameters:Clear()
					oCmd:Parameters:AddWithValue("$last", oFile:LastChanged)
					oCmd:Parameters:AddWithValue("$size", oFile:Size)
					oCmd:Parameters:AddWithValue("$usings", oFile:UsingsStr)
					oCmd:Parameters:AddWithValue("$staticUsings", oFile:StaticUsingsStr)
					oCmd:ExecuteNonQuery()
               ENDIF
				CATCH e AS Exception
					Log("Exception: "+e:ToString())
					Log("File   : "+oFile:FullPath+" "+oFile:Id:ToString())
				END TRY
			END LOCK
		RETURN
		
		STATIC METHOD Update(oFile AS XFile) AS VOID
			// No need to do this in the background.
			// It is called on a background thread while editing
			// and also called on a background thread when scanning at startup
			IF ! IsDbOpen
				RETURN
			ENDIF
			IF oFile:Id == -1
				XDatabase.Read(oFile)
			ENDIF
			IF oFile:IsSource
				UpdateFileContents(oFile)
			ENDIF
			UpdateFileData(oFile)
			CommitWhenNeeded()
		RETURN
		
		
		STATIC PRIVATE METHOD UpdateFileContents(oFile AS XFile) AS VOID
			/*
			"Create Table Types ("
			" Id integer NOT NULL PRIMARY KEY, idFile integer NOT NULL, Name text NOT NULL COLLATE NOCASE, Namespace text NOT NULL COLLATE NOCASE, "
			" Kind integer NOT NULL, BaseTypeName text COLLATE NOCASE, Attributes integer NOT NULL, "
			" Sourcecode text , XmlComments text"
			" StartLine integer , StartColumn integer, EndLine integer , EndColumn integer,   "
			" Start integer , Stop integer,  ClassType integer NOT NULL, "
			" FOREIGN KEY (idFile) REFERENCES Files (Id) ON DELETE CASCADE ON UPDATE CASCADE"
			")"
			*/
			IF ! IsDbOpen
				RETURN
			ENDIF
			Log(i"Update File contents for file {oFile.FullPath}")
			BEGIN LOCK oConn
				TRY
						USING VAR oCmd := SQLiteCommand{"DELETE FROM Members WHERE IdFile = "+oFile:Id:ToString(), oConn}
							oCmd:ExecuteNonQuery()
							
							oCmd:CommandText  := "DELETE FROM CommentTasks WHERE IdFile = "+oFile:Id:ToString()
							oCmd:ExecuteNonQuery() 
							
							oCmd:CommandText  := "DELETE FROM Types WHERE IdFile = "+oFile:Id:ToString()
							oCmd:ExecuteNonQuery()
							
							oCmd:CommandText := "INSERT INTO Types (Name, IdFile, Namespace, Kind,  BaseTypeName, Attributes,  Sourcecode, XmlComments, " + ;
							"                 StartLine,  StartColumn,  EndLine,  EndColumn,  Start,  Stop, ClassType) " +;
							" VALUES ($name, $file, $namespace, $kind, $baseTypeName,  $attributes, $sourcecode, $xmlcomments, " +;
							"           $startline, $startcolumn, $endline, $endcolumn, $start, $stop, $classtype) ;" +;
							" SELECT last_insert_rowid()"
							VAR pars := List<SQLiteParameter>{} { ;
							oCmd:Parameters:AddWithValue("$name", ""),;
							oCmd:Parameters:AddWithValue("$file", 0),;
							oCmd:Parameters:AddWithValue("$namespace", ""),;
							oCmd:Parameters:AddWithValue("$kind", 0),;
							oCmd:Parameters:AddWithValue("$baseTypeName", ""),;
							oCmd:Parameters:AddWithValue("$attributes", 0),;
							oCmd:Parameters:AddWithValue("$sourcecode", ""),;
							oCmd:Parameters:AddWithValue("$xmlcomments", ""),;
							oCmd:Parameters:AddWithValue("$startline", 0),;
							oCmd:Parameters:AddWithValue("$startcolumn", 0),;
							oCmd:Parameters:AddWithValue("$endline", 0),;
							oCmd:Parameters:AddWithValue("$endcolumn", 0),;
							oCmd:Parameters:AddWithValue("$start", 0),;
							oCmd:Parameters:AddWithValue("$stop", 0),;
							oCmd:Parameters:AddWithValue("$classtype", 0)}
							VAR types := oFile:TypeList:Values:Where({ t=> t.Kind != Kind.Namespace .AND. ;
							(t:Name != XLiterals.GlobalName .OR. t:Members:Count > 0 )})
							FOREACH VAR typedef IN types
								TRY
										pars[0]:Value := typedef:Name
										pars[1]:Value := oFile:Id
										pars[2]:Value := typedef:Namespace
										pars[3]:Value := (INT) typedef:Kind
										pars[4]:Value := typedef:BaseType
										pars[5]:Value := (INT) typedef:Attributes
										pars[6]:Value := typedef:SourceCode
										pars[7]:Value := typedef:XmlComments
										pars[8]:Value := typedef:Range:StartLine
										pars[9]:Value := typedef:Range:StartColumn
										pars[10]:Value := typedef:Range:EndLine
										pars[11]:Value := typedef:Range:EndColumn
										pars[12]:Value := typedef:Interval:Start
										pars[13]:Value := typedef:Interval:Stop
										pars[14]:Value := (INT) typedef:ClassType
										VAR id := (INT64) oCmd:ExecuteScalar()
									typedef:Id := id
								CATCH e AS Exception
									Log("Exception: "+e:ToString())
									Log("File   : "+oFile:FullPath+" "+oFile:Id:ToString())
									Log("Typedef: "+typedef:Name)
									Log("Kind   : "+typedef:Kind:ToString())
								END TRY
							NEXT
						/*
						"Create Table Members ("
						" Id integer NOT NULL PRIMARY KEY, IdType integer NOT NULL , IdFile integer NOT NULL, "
						" Name text COLLATE NOCASE, Kind integer , Attributes integer , "
						" SourceCode text, XmlComments text, StartLine integer , StartColumn integer ,  "
						" EndLine integer , EndColumn integer , Start integer , Stop integer , "
						" FOREIGN KEY (idType) REFERENCES Types (Id) ON DELETE CASCADE ON UPDATE CASCADE, " 
						" FOREIGN KEY (idFile) REFERENCES Files (Id) ON DELETE CASCADE ON UPDATE CASCADE"
						")"
						*/
						oCmd:CommandText := "INSERT INTO Members (idFile, idType, Name, Kind, Attributes, Sourcecode , XMLComments, " + ;
						" StartLine, StartColumn, EndLine, EndColumn, Start, Stop) " +;
						" VALUES ($file, $type, $name, $kind, $attributes,$sourcecode, $xmlcomments," + ;
						"           $startline, $startcolumn, $endline, $endcolumn, $start, $stop) ;" +;
						" SELECT last_insert_rowid()"
						oCmd:Parameters:Clear()
						pars := List<SQLiteParameter>{} { ;
						oCmd:Parameters:AddWithValue("$file", oFile:Id),;
						oCmd:Parameters:AddWithValue("$type", 0),;                      
						oCmd:Parameters:AddWithValue("$name", ""),;
						oCmd:Parameters:AddWithValue("$kind", 0),;
						oCmd:Parameters:AddWithValue("$attributes", 0),;
						oCmd:Parameters:AddWithValue("$startline", 0),;
						oCmd:Parameters:AddWithValue("$startcolumn", 0),;
						oCmd:Parameters:AddWithValue("$endline", 0),;
						oCmd:Parameters:AddWithValue("$endcolumn", 0),;
						oCmd:Parameters:AddWithValue("$start", 0),;
						oCmd:Parameters:AddWithValue("$stop", 0),;
						oCmd:Parameters:AddWithValue("$sourcecode", ""),;
						oCmd:Parameters:AddWithValue("$xmlcomments", "")}
						FOREACH VAR typedef IN types
							FOREACH VAR xmember IN typedef:XMembers
								TRY
										// file is constant
										pars[ 0]:Value := oFile:Id
										pars[ 1]:Value := typedef:Id
										pars[ 2]:Value := xmember:Name
										pars[ 3]:Value := (INT) xmember:Kind
										pars[ 4]:Value := (INT) xmember:Attributes
										pars[ 5]:Value := xmember:Range:StartLine
										pars[ 6]:Value := xmember:Range:StartColumn
										pars[ 7]:Value := xmember:Range:EndLine
										pars[ 8]:Value := xmember:Range:EndColumn
										pars[ 9]:Value := xmember:Interval:Start
										pars[10]:Value := xmember:Interval:Stop
										pars[11]:Value := xmember:SourceCode
										pars[12]:Value := xmember:XmlComments
										VAR id := (INT64) oCmd:ExecuteScalar()
									xmember:Id := id
								CATCH e AS Exception
									Log("Exception: "+e:ToString())
									Log("File   : "+oFile:FullPath+" "+oFile:Id:ToString())
									Log("Typedef: "+typedef:Name+" "+typedef:Id:ToString())
									Log("Member : "+xmember:Name)
									Log("Kind   : "+xmember:Kind:ToString())
									Log("Line :   "+xmember:Range:StartLine:ToString())
									Log("Column : "+xmember:Range:StartColumn:ToString())
								END TRY
							NEXT
                  NEXT
                  // Save local functions and procedure
                  FOREACH xmember as XSourceMemberSymbol in oFile:EntityList:Where ( {m => m.Kind.IsLocal() } )
					TRY
							// file is constant
							pars[ 0]:Value := oFile:Id
							pars[ 1]:Value := ((XSourceTypeSymbol) xmember:ParentType):Id
							pars[ 2]:Value := xmember:Name
							pars[ 3]:Value := (INT) xmember:Kind
							pars[ 4]:Value := (INT) xmember:Attributes
							pars[ 5]:Value := xmember:Range:StartLine
							pars[ 6]:Value := xmember:Range:StartColumn
							pars[ 7]:Value := xmember:Range:EndLine
							pars[ 8]:Value := xmember:Range:EndColumn
							pars[ 9]:Value := xmember:Interval:Start
							pars[10]:Value := xmember:Interval:Stop
							pars[11]:Value := xmember:SourceCode
							pars[12]:Value := xmember:XmlComments
							VAR id := (INT64) oCmd:ExecuteScalar()
						xmember:Id := id
					CATCH e AS Exception
						Log("Exception: "+e:ToString())
						Log("File   : "+oFile:FullPath+" "+oFile:Id:ToString())
						Log("Member : "+xmember:Name)
						Log("Kind   : "+xmember:Kind:ToString())
						Log("Line :   "+xmember:Range:StartLine:ToString())
						Log("Column : "+xmember:Range:StartColumn:ToString())
					END TRY
                  NEXT
                  
						oCmd:CommandText := "INSERT INTO CommentTasks (idFile, Line, Column, Priority,Comment) " +;
						" VALUES ($file, $line, $column, $priority, $comment) ;" +;
						" SELECT last_insert_rowid()"
						oCmd:Parameters:Clear()
						pars := List<SQLiteParameter>{} { ;
						oCmd:Parameters:AddWithValue("$file", oFile:Id),;
						oCmd:Parameters:AddWithValue("$line", 0),;
						oCmd:Parameters:AddWithValue("$column", 0),;
						oCmd:Parameters:AddWithValue("$priority", 0),;
						oCmd:Parameters:AddWithValue("$comment", "")}
						FOREACH task AS XCommentTask IN oFile:CommentTasks
							pars[ 0]:Value := oFile:Id
							pars[ 1]:Value := task:Line
							pars[ 2]:Value := task:Column
							pars[ 3]:Value := task:Priority
							pars[ 4]:Value := task:Comment
							oCmd:ExecuteScalar()
						NEXT
				CATCH e AS Exception
					Log("Exception: "+e:ToString())
					Log("File   : "+oFile:FullPath+" "+oFile:Id:ToString())
				END TRY
				
			END LOCK
			RETURN
			
		#endregion
		
		
		#region CRUD Assemblies
		STATIC METHOD Read(oAssembly AS XAssembly) AS VOID
			IF ! IsDbOpen .OR. String.IsNullOrEmpty(oAssembly:FullName) .OR. String.IsNullOrEmpty(oAssembly:FileName)
				RETURN
			ENDIF
		/*
		stmt  	:=  "Create Table Assemblies ("
		stmt	   +=  " Id integer NOT NULL PRIMARY KEY, Name text NOT NULL COLLATE NOCASE, FileName text NOT NULL COLLATE NOCASE, "
		stmt     +=  " LastChanged DateTime NOT NULL, Size integer "
		stmt	   += ")"
		*/
		Log(i"Read Assembly info for assembly {oAssembly.FileName}")
		VAR file    := oAssembly:FileName
		VAR name    := oAssembly:FullName
		VAR lUpdated := FALSE
		BEGIN LOCK oConn
			TRY
				USING VAR cmd := SQLiteCommand{"", oConn}
				cmd:CommandText := "SELECT Id, Name, AssemblyFileName, LastChanged, Size from Assemblies where  AssemblyFileName = $file"
				cmd:Parameters:AddWithValue("$file",file)
				VAR lOk := FALSE 
				BEGIN USING VAR rdr := cmd:ExecuteReader()
				    IF rdr:Read()
					    oAssembly:Id            := rdr:GetInt64(0)
					    oAssembly:LastChanged   := rdr:GetDateTime(3)
					    oAssembly:Size          := rdr:GetInt64(4)
					    lOk := TRUE
                    ENDIF
                END USING
				IF ! lOk
					cmd:CommandText := "INSERT INTO Assemblies(Name, AssemblyFileName,LastChanged, Size ) values ($name, $file,$last,0); SELECT last_insert_rowid() "
					cmd:Parameters:AddWithValue("$name",name)
					cmd:Parameters:AddWithValue("$last", DateTime.MinValue)
					VAR id := (INT64) cmd:ExecuteScalar()
					oAssembly:Id := id
					lUpdated := TRUE
				ENDIF
			CATCH e AS Exception
				Log("Exception: "+e:ToString())
				Log("Assembly : "+oAssembly:FileName+" "+oAssembly:Id:ToString())
			END TRY
			
		END LOCK
		IF lUpdated
			CommitWhenNeeded()
		ENDIF
		RETURN
		
		STATIC METHOD Update(oAssembly AS XAssembly) AS VOID
			IF ! IsDbOpen .OR. String.IsNullOrEmpty(oAssembly:FullName) .OR. String.IsNullOrEmpty(oAssembly:FileName)
				RETURN
			ENDIF   
			Log(i"Update Assembly info for assembly {oAssembly.FileName}")
			BEGIN LOCK oConn
				TRY
					USING VAR oCmd := SQLiteCommand{"SELECT 1", oConn}
					// Updated TypeReferences
					//	   "Create Table ReferencedTypes ("
					//	   " Id integer NOT NULL PRIMARY KEY, idAssembly integer NOT NULL, Name text NOT NULL COLLATE NOCASE, Namespace text NOT NULL COLLATE NOCASE, "
					//	   " FullName text NOT NULL COLLATE NOCASE, Kind integer NOT NULL, BaseTypeName text COLLATE NOCASE, Attributes integer NOT NULL, "
					//	   " FOREIGN KEY (idAssembly) REFERENCES Assemblies (Id) ON DELETE CASCADE ON UPDATE CASCADE"
					//	  ")"
					oCmd:CommandText := "INSERT INTO ReferencedTypes (idAssembly, Name, Namespace, Kind, BaseTypeName, Attributes,FullName) " + ;
					" values ($id, $name, $namespace, $kind, $basetypename, $attributes,$fullname) "
					oCmd:Parameters:Clear()
					VAR pars := List<SQLiteParameter>{} { ;
					oCmd:Parameters:AddWithValue("$id", 0),;
					oCmd:Parameters:AddWithValue("$name", ""),;
					oCmd:Parameters:AddWithValue("$namespace", ""),;
					oCmd:Parameters:AddWithValue("$fullname", ""),;
					oCmd:Parameters:AddWithValue("$kind", 0),;
					oCmd:Parameters:AddWithValue("$basetypename", ""),;
					oCmd:Parameters:AddWithValue("$attributes",0)}
					FOREACH VAR typeref IN oAssembly:Types:Values
						pars[0]:Value := oAssembly:Id
						pars[1]:Value := typeref:Name
						pars[2]:Value := typeref:Namespace
						pars[3]:Value := typeref:FullName
						pars[4]:Value := (INT) typeref:Kind
						pars[5]:Value := typeref:BaseType
						pars[6]:Value := (INT) typeref:Attributes
						oCmd:ExecuteNonQuery()
					NEXT
							
					oCmd:CommandText := "Update Assemblies set LastChanged = $last, Size = $size where id = "+oAssembly:Id:ToString()
					VAR fi            := FileInfo{oAssembly:FileName}
					oAssembly:LastChanged := fi:LastWriteTime
					oAssembly:Size        := fi:Length
					oCmd:Parameters:Clear()
					oCmd:Parameters:AddWithValue("$last", oAssembly:LastChanged)
					oCmd:Parameters:AddWithValue("$size", oAssembly:Size)
					oCmd:ExecuteNonQuery()
				CATCH e AS Exception
					Log("Exception: "+e:ToString())
					Log("Assembly : "+oAssembly:FileName+" "+oAssembly:Id:ToString())
				END TRY
				
			END LOCK         
			RETURN
		#endregion
		
		STATIC METHOD FindFunction(sName AS STRING, sProjectIds AS STRING) AS IList<XDbResult>
			// search class members in the Types list
			VAR result := List<XDbResult>{}
			IF IsDbOpen
				BEGIN LOCK oConn
					TRY
						USING VAR oCmd := SQLiteCommand{"SELECT 1", oConn}
						oCmd:CommandText := "SELECT * FROM ProjectMembers WHERE name = $name AND TypeName = $typename " + ;
						" AND Kind in ($kind1, $kind2, $kind3, $kind4,$kind5,$kind6) AND IdProject in ("+sProjectIds+")"
						oCmd:Parameters:AddWithValue("$name", sName)
						oCmd:Parameters:AddWithValue("$kind1", (INT) Kind.Function)
						oCmd:Parameters:AddWithValue("$kind2", (INT) Kind.Procedure)
						oCmd:Parameters:AddWithValue("$kind3", (INT) Kind.Method)
						oCmd:Parameters:AddWithValue("$kind4", (INT) Kind.VODLL)
						oCmd:Parameters:AddWithValue("$kind5", (INT) Kind.LocalFunc)
						oCmd:Parameters:AddWithValue("$kind6", (INT) Kind.LocalProc)
						oCmd:Parameters:AddWithValue("$typename", XLiterals.GlobalName)
						USING VAR rdr := oCmd:ExecuteReader()
						DO WHILE rdr:Read()
							result:Add(CreateMemberInfo(rdr))
						ENDDO
					CATCH e AS Exception
						Log("Exception: "+e:ToString())
					END TRY            
				END LOCK
			ENDIF
			Log(i"FindFunction '{sName}' returns {result.Count} matches")
		RETURN result
		
		STATIC METHOD FindGlobalOrDefine(sName AS STRING, sProjectIds AS STRING) AS IList<XDbResult>
			// search class members in the Types list
			VAR result := List<XDbResult>{}
			IF IsDbOpen
				BEGIN LOCK oConn
					TRY
					    USING VAR oCmd := SQLiteCommand{"SELECT 1", oConn}
					    oCmd:CommandText := "SELECT * FROM ProjectMembers WHERE name = $name AND TypeName = $typename " + ;
					    " AND Kind in ($kind1, $kind2) AND IdProject in ("+sProjectIds+")"
					    oCmd:Parameters:AddWithValue("$name", sName)
					    oCmd:Parameters:AddWithValue("$kind1", (INT) Kind.VOGlobal)
					    oCmd:Parameters:AddWithValue("$kind2", (INT) Kind.VODefine)
					    oCmd:Parameters:AddWithValue("$typename", XLiterals.GlobalName)
					    USING VAR rdr := oCmd:ExecuteReader()
					    DO WHILE rdr:Read()
						    result:Add(CreateMemberInfo(rdr))
					    ENDDO
					CATCH e AS Exception
						Log("Exception: "+e:ToString())
					END TRY            
				END LOCK
			ENDIF
			Log(i"FindGlobalOrDefine '{sName}' returns {result.Count} matches")
		RETURN result      
		
		STATIC METHOD GetTypes(sName AS STRING, sProjectIds AS STRING) AS IList<XDbResult>
			VAR stmt := "Select * from ProjectTypes where name = $name AND IdProject in ("+sProjectIds+")"
			VAR result := List<XDbResult>{}
			IF IsDbOpen
				BEGIN LOCK oConn
					TRY
					    USING VAR oCmd := SQLiteCommand{stmt, oConn}
						oCmd:Parameters:AddWithValue("$name", sName)
						USING VAR rdr := oCmd:ExecuteReader()
						DO WHILE rdr:Read()
							result:Add(CreateTypeInfo(rdr))
						ENDDO
					CATCH e AS Exception
						Log("Exception: "+e:ToString())
					END TRY            
				END LOCK
			ENDIF
			Log(i"GetTypes '{sName}' returns {result.Count} matches")
		RETURN result   
		
		STATIC METHOD GetTypesLike(sName AS STRING, sProjectIds AS STRING) AS IList<XDbResult>
			VAR stmt := "Select * from ProjectTypes where name like $name AND IdProject in ("+sProjectIds+")"
			VAR result := List<XDbResult>{}
			sName += "%"
			IF IsDbOpen
				BEGIN LOCK oConn
					TRY
						USING VAR oCmd := SQLiteCommand{stmt, oConn}
						oCmd:Parameters:AddWithValue("$name", sName)
						USING VAR rdr := oCmd:ExecuteReader()
						DO WHILE rdr:Read()
							result:Add(CreateTypeInfo(rdr))
						ENDDO
					CATCH e AS Exception
						Log("Exception: "+e:ToString())
					END TRY            
				END LOCK
			ENDIF
			Log(i"GetTypesLike '{sName}' returns {result.Count} matches")
		RETURN result   
		
		STATIC METHOD GetCommentTasks(sProjectIds AS STRING) AS IList<XDbResult>
			VAR stmt := "Select Line, Column, Priority, Comment, FileName from " + ;
			" ProjectCommentTasks where IdProject in ("+sProjectIds+") Order BY IdProject, IdFile "
			VAR result := List<XDbResult>{}
			IF IsDbOpen
				BEGIN LOCK oConn
					TRY
						USING VAR oCmd := SQLiteCommand{stmt, oConn}
						USING VAR rdr := oCmd:ExecuteReader()
					    DO WHILE rdr:Read()
						    result:Add(CreateCommentTask(rdr))
					    ENDDO
					CATCH e AS Exception
						Log("Exception: "+e:ToString())
					END TRY            
				END LOCK
			ENDIF
			Log(i"GetCommentTasks returns {result.Count} matches")
		RETURN result     
		
      STATIC METHOD GetFilesOfType(type as XFileType, sProjectIds as STRING) AS IList<STRING>
         VAR stmt := "Select distinct FileName from ProjectFiles where FileType = $type AND IdProject in ("+sProjectIds+")"
         VAR result := List<String>{}
			IF IsDbOpen
				BEGIN LOCK oConn
					TRY
						USING VAR oCmd := SQLiteCommand{stmt, oConn}
                        oCmd:Parameters:AddWithValue("$type",(INT) type)
						USING VAR rdr := oCmd:ExecuteReader()
						DO WHILE rdr:Read()
                              result:Add(DbToString(rdr[0]))
						ENDDO
					CATCH e AS Exception
						Log("Exception: "+e:ToString())
					END TRY            
				END LOCK
			ENDIF         
         RETURN result
		
		STATIC METHOD GetNamespaces(sProjectIds AS STRING) AS IList<XDbResult>
			VAR stmt := "Select distinct Namespace from ProjectTypes where Namespace is not null and IdProject in ("+sProjectIds+")"
			VAR result := List<XDbResult>{}
			IF IsDbOpen
				BEGIN LOCK oConn
					TRY
						USING VAR oCmd := SQLiteCommand{stmt, oConn}
						USING VAR rdr := oCmd:ExecuteReader()
						DO WHILE rdr:Read()
							VAR res := XDbResult{}
							res:Namespace    := DbToString(rdr[0])
							res:TypeName     := res:Namespace
							IF ! String.IsNullOrEmpty(res:Namespace)
								result:Add(res)
							ENDIF
						ENDDO
					CATCH e AS Exception
						Log("Exception: "+e:ToString())
					END TRY            
				END LOCK
			ENDIF
			Log(i"GetNameSpaces returns {result.Count} matches")
		RETURN result     
		
		STATIC METHOD GetNamespacesInFile(sFileId AS STRING) AS IList<XDbResult>
		RETURN GetNamespacesInFile( sFileId, FALSE )
		
		STATIC METHOD GetNamespacesInFile(sFileId AS STRING, keepEmptyName AS LOGIC ) AS IList<XDbResult>
			VAR stmt := "Select distinct Namespace from ProjectTypes where Namespace is not null and IdFile = "+sFileId
			VAR result := List<XDbResult>{}
			IF IsDbOpen
				BEGIN LOCK oConn
					TRY
						USING VAR oCmd := SQLiteCommand{stmt, oConn}
						USING VAR rdr := oCmd:ExecuteReader()
						DO WHILE rdr:Read()
							VAR res := XDbResult{}
							IF rdr[0] != DBNull.Value
								res:Kind         := Kind.Namespace
								res:Namespace    := DbToString(rdr[0])
								res:TypeName     := res:Namespace							
								IF !String.IsNullOrEmpty(res:Namespace) .OR. keepEmptyName
									result:Add(res)
								ENDIF
							ENDIF
						ENDDO
					CATCH e AS Exception
						Log("Exception: "+e:ToString())
					END TRY            
				END LOCK
			ENDIF
			Log(i"GetNamespacesInFile returns {result.Count} matches")
		RETURN result  			
		
		STATIC METHOD GetTypesInFile(sFileId AS STRING) AS IList<XDbResult>
			VAR stmt := "Select * from ProjectTypes where IdFile = "+sFileId
			VAR result := List<XDbResult>{}
			IF IsDbOpen
				BEGIN LOCK oConn
					TRY
						USING VAR oCmd := SQLiteCommand{stmt, oConn}
						USING VAR rdr := oCmd:ExecuteReader()
						DO WHILE rdr:Read()
							result:Add(CreateTypeInfo(rdr))
						ENDDO
					CATCH e AS Exception
						Log("Exception: "+e:ToString())
					END TRY            
				END LOCK
			ENDIF
			Log(i"GetTypesInFile returns {result.Count} matches")
		RETURN result
		
		STATIC METHOD GetReferenceTypes(sName AS STRING, sAssemblyIds AS STRING) AS IList<XDbResult>
			VAR stmt := "Select * from AssemblyTypes where (name like $name or fullname like  $name) AND idAssembly in ("+sAssemblyIds+")"
			VAR result := List<XDbResult>{}
			IF IsDbOpen
				BEGIN LOCK oConn
					TRY
					    USING VAR oCmd := SQLiteCommand{stmt, oConn}
					    oCmd:Parameters:AddWithValue("$name", sName+"%")
					    USING VAR rdr := oCmd:ExecuteReader()
					    DO WHILE rdr:Read()
					        result:Add(CreateRefTypeInfo(rdr))
					    ENDDO
					
					CATCH e AS Exception
						Log("Exception: "+e:ToString())
					END TRY            
				END LOCK
			ENDIF
			Log(i"GetReferenceTypes '{sName}' returns {result.Count} matches")
		RETURN result         
		
		STATIC METHOD GetMembers(idType AS INT64) AS IList<XDbResult>
			VAR stmt := "Select * from ProjectMembers where IdType ="+idType:ToString()
			stmt     += " order by idFile, idType" 
			VAR result := List<XDbResult>{}
			IF IsDbOpen
				BEGIN LOCK oConn
					TRY
					    USING VAR oCmd := SQLiteCommand{stmt, oConn}
						USING VAR rdr := oCmd:ExecuteReader()
						DO WHILE rdr:Read()
							result:Add(CreateMemberInfo(rdr))
						ENDDO
					CATCH e AS Exception
						Log("Exception: "+e:ToString())
					END TRY            
					
				END LOCK
			ENDIF
			Log(i"GetMembers '{idType}' returns {result.Count} matches")
		RETURN result  

        STATIC METHOD GetStartupClasses(projectFile as string) AS List<String>
            var result := List<String>{}
			IF IsDbOpen
				BEGIN LOCK oConn
					TRY
                        var stmt := "select TypeName, Name, Attributes, Kind from ProjectMembers where Name like 'Start%' and ProjectFileName like '%" +projectFile+"'"
						USING VAR oCmd := SQLiteCommand{stmt, oConn}
						USING VAR rdr := oCmd:ExecuteReader()
						DO WHILE rdr:Read()
                            var atts := (Modifiers) (INT64) rdr["Attributes"]
                            var kind := (Kind) (INT64) rdr["Kind"]
                            var m := rdr["Name"]:ToString()
                            if m:Trim():ToLower() == "start" .and. atts:HasFlag(Modifiers.Static) .and. kind:HasFlag(Kind.Method)
    							result:Add(rdr["TypeName"]:ToString())
                            endif
						ENDDO
					CATCH e AS Exception
						Log("Exception: "+e:ToString())
					END TRY            
					
				END LOCK
			ENDIF
            return result

		STATIC METHOD GetMembers(idTypes AS STRING) AS IList<XDbResult>
			VAR stmt := "Select * from ProjectMembers where IdType IN ("+idTypes+") "
			stmt     += " order by idFile, idType" 
			VAR result := List<XDbResult>{}
			IF IsDbOpen
				BEGIN LOCK oConn
					TRY
						USING VAR oCmd := SQLiteCommand{stmt, oConn}
						USING VAR rdr := oCmd:ExecuteReader()
						DO WHILE rdr:Read()
							result:Add(CreateMemberInfo(rdr))
						ENDDO
					CATCH e AS Exception
						Log("Exception: "+e:ToString())
					END TRY            
					
				END LOCK
			ENDIF
			Log(i"GetMembers '{idTypes}' returns {result.Count} matches")
		RETURN result  


		STATIC METHOD GetFunctions( sFileId AS STRING) AS IList<XDbResult>
			// 
			VAR result := List<XDbResult>{}
			IF IsDbOpen
				BEGIN LOCK oConn
					TRY
    					USING VAR oCmd := SQLiteCommand{"SELECT 1", oConn}
						oCmd:CommandText := "SELECT * FROM ProjectMembers WHERE IdFile = $idfile AND TypeName = $typename " + ;
						" AND Kind in ($kind1, $kind2, $kind3, $kind4, $kind5)"
						oCmd:Parameters:AddWithValue("$idfile", sFileId)
						oCmd:Parameters:AddWithValue("$kind1", (INT) Kind.Function)
						oCmd:Parameters:AddWithValue("$kind2", (INT) Kind.Procedure)
						oCmd:Parameters:AddWithValue("$kind3", (INT) Kind.VODLL)
						oCmd:Parameters:AddWithValue("$kind4", (INT) Kind.VOGlobal)
						oCmd:Parameters:AddWithValue("$kind5", (INT) Kind.VODefine)
						oCmd:Parameters:AddWithValue("$typename", XLiterals.GlobalName)
						USING VAR rdr := oCmd:ExecuteReader()
						DO WHILE rdr:Read()
							result:Add(CreateMemberInfo(rdr))
						ENDDO
					CATCH e AS Exception
						Log("Exception: "+e:ToString())
					END TRY            
				END LOCK
			ENDIF
			Log(i"GetFunctions returns {result.Count} matches")
		RETURN result			

		STATIC METHOD CreateTypeInfo(rdr AS SQLiteDataReader) AS XDbResult
			VAR res := XDbResult{}
			res:TypeName     := DbToString(rdr["Name"])
			res:Namespace    := DbToString(rdr["NameSpace"])
			res:BaseTypeName := DbToString(rdr["BaseTypeName"])
			res:Kind         := (Kind) (INT64) rdr["Kind"]
			res:ClassType    := DbToInt( rdr["ClassType"])
			res:Attributes   := (Modifiers) (INT64) rdr["Attributes"]
			res:FileName     := DbToString(rdr["FileName"])
			res:Project      := DbToString(rdr["ProjectFileName"])
			res:StartLine    := DbToInt(rdr["StartLine"])
			res:StartColumn  := DbToInt(rdr["StartColumn"])
			res:EndLine      := DbToInt(rdr["EndLine"])
			res:EndColumn    := DbToInt(rdr["EndColumn"])
			res:Start        := DbToInt(rdr["Start"])
			res:Stop         := DbToInt(rdr["Stop"])
			res:SourceCode   := DbToString(rdr["SourceCode"])
			res:XmlComments  := DbToString(rdr["XmlComments"])
			res:IdType       := (INT64) rdr["Id"]
			res:IdFile       := (INT64) rdr["IdFile"]
			res:IdProject    := (INT64) rdr["IdProject"]
		RETURN res
		
		STATIC METHOD CreateRefTypeInfo(rdr AS SQLiteDataReader) AS XDbResult
			VAR res := XDbResult{}
			res:TypeName     := DbToString(rdr["Name"])
			res:Namespace    := DbToString(rdr["NameSpace"])
			res:Kind         := (Kind) (INT64) rdr["Kind"]
			res:Attributes   := (Modifiers) (INT64) rdr["Attributes"]
			res:FullName     := DbToString(rdr["FullName"])
			res:Assembly     := DbToString(rdr["AssemblyFileName"])
			res:IdType       := (INT64) rdr["Id"]
			res:IdAssembly   := (INT64) rdr["IdAssembly"]
		RETURN res
		
		STATIC METHOD CreateCommentTask(rdr AS SQLiteDataReader) AS XDbResult
			VAR res := XDbResult{}
			res:Line         := DbToInt(rdr["Line"])
			res:Column       := DbToInt(rdr["Column"])
			res:Priority     := DbToInt(rdr["Priority"])
			res:Comment      := DbToString(rdr["Comment"])
			res:FileName     := DbToString(rdr["FileName"])
		RETURN res
		
		
		STATIC METHOD CreateMemberInfo(rdr AS SQLiteDataReader) AS XDbResult
			VAR res := XDbResult{}
			res:TypeName     := DbToString(rdr["TypeName"])
			res:MemberName   := DbToString(rdr["Name"])
			res:ClassType    := DbToInt( rdr["ClassType"])
			res:Kind         := (Kind) (INT64) rdr["Kind"]
			res:Attributes   := (Modifiers) (INT64) rdr["Attributes"]
			res:FileName     := DbToString(rdr["FileName"])
			res:Project      := DbToString(rdr["ProjectFileName"])
			res:StartLine    := DbToInt(rdr["StartLine"])
			res:StartColumn  := DbToInt(rdr["StartColumn"])
			res:EndLine      := DbToInt(rdr["EndLine"])
			res:EndColumn    := DbToInt(rdr["EndColumn"])
			res:Start        := DbToInt(rdr["Start"])
			res:Stop         := DbToInt(rdr["Stop"])
			res:SourceCode   := DbToString(rdr["SourceCode"])
			res:XmlComments  := DbToString(rdr["XmlComments"])
			res:IdType       := (INT64) rdr["IdType"]
			res:IdFile       := (INT64) rdr["IdFile"]
			res:IdProject    := (INT64) rdr["IdProject"] 
		RETURN res
		STATIC METHOD DbToString(oValue AS OBJECT) AS STRING
			IF oValue == DBNull.Value
				RETURN ""
			ENDIF
			IF oValue IS STRING
				RETURN (STRING) oValue
			ENDIF
		RETURN ""
		STATIC METHOD DbToInt(oValue AS OBJECT) AS LONG
			IF oValue == DBNull.Value
				RETURN 0
			ENDIF
			IF oValue IS INT64 VAR i64
				RETURN (INT) i64
			ENDIF
			IF oValue IS LONG VAR l
				RETURN l
			ENDIF
		RETURN 0
		
		
		STATIC PROPERTY IsDbOpen AS LOGIC GET oConn != NULL_OBJECT .AND.  oConn:State == ConnectionState.Open
		
		STATIC METHOD Log(cMessage AS STRING) AS VOID
			IF XSettings.EnableDatabaseLog .AND. XSettings.EnableLogging
				XSolution.WriteOutputMessage("XDatabase: "+cMessage)
			ENDIF
			RETURN
			
		END CLASS
		
END NAMESPACE   
