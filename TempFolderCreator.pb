;{- Code Header
; ==- Basic Info -================================
;         Name: TempFolderCreator.pb
;      Version: 1.0.0
;       Author: Herwin Bozet
;  Create date: ‎‎19 June 2019, 13:03:36
; 
;  Description: ???
; 
; ==- Compatibility -=============================
;  Compiler version: PureBasic 5.60-5.62 (x64) (Other versions untested)
;  Operating system: Windows (Other platforms untested)
; 
; ==- Links & License -===========================
;   Github: https://github.com/aziascreations/PB-Temp-Folder-Creator
;  License: Apache V2
;
;  Documentation: https://docs.microsoft.com/en-us/windows/desktop/api/winbase/nf-winbase-movefileexa
;}

;- Compiler directives

;XIncludeFile "./IsUserAnAdmin.pbi"

EnableExplicit


;- Prototypes, constants & Globals

#USABLECHARSET$ = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_"

#MOVEFILE_REPLACE_EXISTING = $1
#MOVEFILE_COPY_ALLOWED = $2
#MOVEFILE_DELAY_UNTIL_REBOOT = $4
#MOVEFILE_WRITE_THROUGH = $8
#MOVEFILE_CREATE_HARDLINK = $10
#MOVEFILE_FAIL_IF_NOT_TRACKABLE = $20

; BOOL MoveFileExA(
;   LPCSTR lpExistingFileName,
;   LPCSTR lpNewFileName,
;   DWORD  dwFlags
; );
Prototype.w MoveFileExW_(*lpExistingFileName, *lpNewFileName, dwFlags.l)

Define MoveFileExW_.MoveFileExW_
Define FolderPath$, i.i


;- Code

; Preparing stuff...

; If Not OpenConsole("Temporary Folder Creator")
; 	End 1
; EndIf

; If Not IsUserAnAdmin_()
; 	MessageRequester("Error", "This program needs to be run with administrative rights to mark folder for deletion !", #PB_MessageRequester_Ok | #PB_MessageRequester_Error)
; 	End 9
; EndIf

If Not OpenLibrary(0, "Kernel32.dll")
	MessageRequester("Error", "Failed to open Kernel32.dll !", #PB_MessageRequester_Ok | #PB_MessageRequester_Error)
	End 2
EndIf

MoveFileExW_ = GetFunction(0, "MoveFileExW")

If Not MoveFileExW_
	MessageRequester("Error", "Failed to load MoveFileExW() !", #PB_MessageRequester_Ok | #PB_MessageRequester_Error)
	CloseLibrary(0)
	End 3
EndIf


; Creating the temporary folder...

FolderPath$ = GetTemporaryDirectory() + "TMP_DIR_"

For i=0 To 16
	FolderPath$ = FolderPath$ + Mid(#USABLECHARSET$, Random(Len(#USABLECHARSET$), 1), 1)
Next

;FolderPath$ = FolderPath$ + "\"

Debug "Using "+#DQUOTE$+FolderPath$+#DQUOTE$+" as the temporary directory."

If FileSize(FolderPath$) <> -1
	MessageRequester("Error", "The folder already exists or is a file !", #PB_MessageRequester_Ok | #PB_MessageRequester_Error)
	CloseLibrary(0)
	End 4
EndIf

If Not CreateDirectory(FolderPath$)
	MessageRequester("Error", "Failed to create the directory !", #PB_MessageRequester_Ok | #PB_MessageRequester_Error)
	CloseLibrary(0)
	End 5
EndIf


; Marking it for deletion...

If Not MoveFileExW_(@FolderPath$, #Null, #MOVEFILE_DELAY_UNTIL_REBOOT)
	CloseLibrary(0)
	
	If DeleteDirectory(FolderPath$, "", #PB_FileSystem_Force)
		MessageRequester("Error", "Failed to mark the directory for deletion !"+#CRLF$+"It was removed.", #PB_MessageRequester_Ok | #PB_MessageRequester_Error)
		End 6
	Else
		MessageRequester("Error", "Failed to mark the directory for deletion !"+#CRLF$+
		                          "It couldn't be removed !"+#CRLF$+#CRLF$+
		                          "> "+FolderPath$, #PB_MessageRequester_Ok | #PB_MessageRequester_Error)
		End 7
	EndIf
EndIf


; Finishing up...

RunProgram("explorer.exe", FolderPath$, FolderPath$)

CloseLibrary(0)

End 0

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 103
; FirstLine = 42
; Folding = -
; EnableAdmin
; Executable = TempFolderCreator-x64.exe