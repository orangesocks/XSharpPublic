﻿//
// Copyright (c) XSharp B.V.  All Rights Reserved.  
// Licensed under the Apache License, Version 2.0.  
// See License.txt in the project root for license information.
//
using XSharp
using System.IO
/// <summary>
/// Return the last DOS error code  (Exit code) and set a new code.
/// </summary>
/// <param name="nSet">New value for the DOS eror code </param>
/// <returns>
/// </returns>
function DosError(nSet as dword) as dword
	local nOld as int
	nOld := System.Environment.ExitCode
	System.Environment.ExitCode := unchecked((int) nSet)
	return UNCHECKED((DWORD) nOld)

/// <summary>
/// Return the last DOS error code  (Exit code). use GetDosError() to fetch the error from the Last Win32 call.
/// </summary>
/// <param name="nSet"></param>
/// <returns>
/// </returns>
function DosError() as dword
	local nOld as int
	nOld := System.Environment.ExitCode
	return UNCHECKED((DWORD) nOld)



/// <summary>
/// Return the DOS error code from any application.
/// </summary>
/// <returns>
/// </returns>
function GetDosError() as dword
	return unchecked((dword) System.Runtime.InteropServices.Marshal.GetLastWin32Error())
	
/// <summary>
/// Retrieve the contents of a DOS environment variable.
/// </summary>
/// <param name="c"></param>
/// <returns>
/// </returns>
function GetEnv(cVar as string) as string
	return System.Environment.GetEnvironmentVariable(cVar)


/// <summary>
/// Update or replace the contents of a DOS environment variable.
/// </summary>
/// <param name="cVar"></param>
/// <param name="cValue"></param>
/// <param name="lAppend"></param>
/// <returns>
/// </returns>
function SetEnv(cVar as string,cValue as string,lAppend as logic) as logic
	local result as logic
	try
		if lAppend
			local cOldValue as string
			cOldValue := System.Environment.GetEnvironmentVariable(cVar)
			IF ! String.IsNullOrEmpty( cOldValue )
				cOldValue += ";"
			endif
			cValue := cOldValue + cValue
		endif
		System.Environment.SetEnvironmentVariable(cVar, cValue)
		result := System.Environment.GetEnvironmentVariable(cVar) == cValue
	catch
		result := false
	END TRY
	RETURN FALSE   



/// <summary>
/// Identify the current workstation.
/// </summary>
/// <returns>The workstation ID as a string.</returns>
function NetName() as string
	return System.Environment.MachineName


/// <summary>
/// Return the current Windows directory.
/// </summary>
/// <param name="cDisk"></param>
/// <returns>
/// </returns>
function CurDir (cDisk as string) as STRING
	return CurDir()

/// <summary>
/// Return the current Windows directory.
/// </summary>
/// <returns>
/// </returns>
function CurDir() as string
	local cDir as string
	local index as int
	cDir := System.Environment.CurrentDirectory
	index := cDir:Indexof(Path.VolumeSeparatorChar)
	if index > 0
		cDir := cDir:Substring(index+1)
	endif
	if cDir[0] == Path.DirectorySeparatorChar
		cDir := cDir:Substring(1)
	endif
	if cDir[cDir:Length-1]  == Path.DirectorySeparatorChar
		cDir := cDir:Substring(0, cDir:Length-1)
	endif
	return cDir

/// <summary>
/// Return the current Windows drive.
/// </summary>
/// <returns>
/// Return the letter of the current drive without colon
/// </returns>
function CurDrive() as string
	local currentDirectory := System.IO.Directory.GetCurrentDirectory() as string
	local drive := "" as string
	local position as int
	
	position := currentDirectory:IndexOf(System.IO.Path.VolumeSeparatorChar)
	if position > 0
		drive := currentDirectory:Substring(0,position)
	endif
	return drive
	

/// <summary>
/// Return the currently selected working directory.
/// </summary>
/// <returns>
/// </returns>
function WorkDir() as string
	local cPath as string
	local asm   as System.Reflection.Assembly
	asm := System.Reflection.Assembly.GetCallingAssembly()
	cPath := asm:ManifestModule:FullyQualifiedName
	cPath := Path.GetDirectoryName(cPath)
	if cPath[cPath:Length-1] !=  Path.DirectorySeparatorChar
		cPath += Path.DirectorySeparatorChar:ToString()
	endif
	return cPath

/// <summary>
/// Return the space available on the current disk drive.
/// </summary>
/// <param name="cDisk"></param>
/// <returns>
/// </returns>
function DiskFree() as Int64
	return DiskFree(CurDrive())


internal function DiskNo2DiskName(nDisk as INT) as string
	return ('A'+ (nDisk-1)):ToString()

/// <summary>
/// Return the space available on a specified disk.
/// </summary>
/// <param name="cDrive">The drivename to get the free space from.</param>
/// <returns>
/// The free space on the specified disk drive.
/// </returns>	   
function DiskFree(cDrive as STRING) as INT64
	return DriveInfo{cDrive}:TotalFreeSpace


/// <summary>
/// Return the space available on a specified disk.
/// </summary>
/// <param name="nDrive">The drive number (1 = A, 2 = B etc)
/// <returns>
/// The free space on the specified disk drive.
/// </returns>	   
function DiskFree(nDrive as INT) as int64
	local cDrive as string
	cDrive := DiskNo2DiskName(nDrive)
	return DiskFree(cDrive)


/// <summary>
/// Return the capacity of the current disk.
/// </summary>
/// <returns>
/// The capacity of the current disk.
/// </returns>
function DiskSpace() as int64
	return DiskSpace(CurDrive())


/// <summary>
/// Return the capacity of the specified disk.
/// </summary>
/// <param name="nDisk"></param>
/// <returns>
/// </returns>
function DiskSpace(nDisk as INT) as int64
	local cDisk as string
	cDisk := DiskNo2DiskName(nDisk)
	return DiskSpace(cDisk)

/// <summary>
/// Return the capacity of the specified disk.
/// </summary>
/// <param name="cDisk"></param>
/// <returns>
/// </returns>
function DiskSpace(cDisk as STRING) as int64
	return DriveInfo{cDisk}:TotalSize

/// <summary>
/// Detect a concurrency conflict.
/// </summary>
/// <returns>
/// </returns>
FUNCTION NetErr() AS LOGIC STRICT
    RETURN RuntimeState.NetErr
    
/// <summary>
/// Detect a concurrency conflict.
/// </summary>
/// <param name="lSet"></param>
/// <returns>
/// </returns>
FUNCTION NetErr( lValue AS LOGIC ) AS LOGIC
    LOCAL curvalue := RuntimeState.NetErr AS LOGIC
    RuntimeState.NetErr := lValue
    RETURN curvalue




/// <summary>
/// </summary>
/// <param name="n"></param>
/// <returns>
/// </returns>
function LockTries() as int
	return RuntimeState.LockTries

/// <summary>
/// </summary>
/// <param name="n"></param>
/// <returns>
/// </returns>
function LockTries(nValue as int) as int
	local nResult as int
	nResult := RuntimeState.LockTries
	RuntimeState.LockTries := nValue
	return nValue



/// <summary>
/// Change the current Windows directory.
/// </summary>
/// <param name="pszDir"></param>
/// <returns>
/// </returns>
function DirChange(cDir as STRING) as int
	local result as int
	try
		if !Directory.Exists(cDir)
			Directory.SetCurrentDirectory(cDir)
			result := 0
		else
			result := -1
		endif
	catch 
		result := System.Runtime.InteropServices.Marshal.GetLastWin32Error()
	end try
	return result
	
/// <summary>
/// Create a directory.
/// </summary>
/// <param name="pszDir"></param>
/// <returns>
/// </returns>
function DirMake(cDir as STRING) as int
	local result as int
	try
		if !Directory.Exists(cDir)
			Directory.CreateDirectory(cDir)
			result := 0
		else
			result := -1
		endif
	catch 
		result := System.Runtime.InteropServices.Marshal.GetLastWin32Error()
	end try
	return result
	
/// <summary>
/// Remove a directory.
/// </summary>
/// <param name="pszDir"></param>
/// <returns>
/// </returns>
function DirRemove(cDir as string) as int
	local result as int
	try
		if Directory.Exists(cDir)
			Directory.Delete(cDir,false)
			result := 0
		else
			result := -1
		endif
	catch 
		result := System.Runtime.InteropServices.Marshal.GetLastWin32Error()
	end try
	return result


/// <summary>
/// Change the current disk drive.
/// </summary>
/// <param name="pszDisk"></param>
/// <returns>
/// </returns>

function DiskChange(c as string) as logic
	if String.IsNullOrEmpty(c)
		return false
	endif
	c := c:Substring(0,1)+Path.VolumeSeparatorChar:ToString()+Path.DirectorySeparatorChar:ToString()
	return DirChange(c) == 0