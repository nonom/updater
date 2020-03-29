// Project: Updater 
// Created: 20-03-17

// show all errors
SetErrorMode(2)

// set window properties
SetWindowTitle( "Updater" )
SetWindowSize( 1024, 768, 0 )
SetWindowAllowResize( 1 ) // allow the user to resize the window

// set display properties
SetVirtualResolution( 1024, 768 ) // doesn't have to match the window
SetOrientationAllowed( 1, 1, 1, 1 ) // allow both portrait and landscape on mobile devices
SetSyncRate( 30, 0 ) // 30fps instead of 60 to save battery
SetScissor( 0,0,0,0 ) // use the maximum available screen space, no black borders
UseNewDefaultFonts( 1 )
SetPrintSize ( 18 ) 

//[IDEGUIADD],header,Updater
//[IDEGUIADD],message,Update files from a remote server
//[IDEGUIADD],separator,

#constant _STATE_STOP = 0
#constant _STATE_UPDATE = 1
#constant _STATE_PAUSE = 2
#constant _STATE_START = 3
#constant _STATE_END = 4
#constant _STATE_INFO = 5

#constant STATE_STOPPED = 0
#constant STATE_UPDATING = 1
#constant STATE_PAUSED = 2
#constant STATE_STARTED = 3

#constant TYPE_FILE$ = "a"
#constant TYPE_FOLDER$ = "d"


global server$ as string = "portalidea.com" //[IDEGUIADD],string,Remote Server
global folder$ as string = "downloads" //[IDEGUIADD],string,Remote Folder
global version_file$ as string = "VERSION" //[IDEGUIADD],string,Version File
global status_file$ as string = "status.txt" //[IDEGUIADD],string,Status File
global current_state as integer = 0 //[IDEGUIADD],integer,Current State
global paused as integer = 0 //[IDEGUIADD],integer,Paused

global current_file_type$ as string = ""

type tFile
	_type$ as string
	_status$ as string
	_path$ as string
endtype

global files as tFile[]

type vec4
	x as float
	y as float
	z as float
	w as float
endtype

global spritex = 197 //[IDEGUIADD],integer,X
global spritey = 200 //[IDEGUIADD],integer,Y
global sprite_width = 20 //[IDEGUIADD],integer,Width
global sprite_height = 20 //[IDEGUIADD],integer,Height
global scale# = 1 //[IDEGUIADD],float,Scale
global image$ = "" //[IDEGUIADD],selectfile,Background

global color as vec4 //[IDEGUIADD],vec4color,Color

color.x = 1.000000 //[IDEGUIADD],variable,Color
color.y = 0.957365 //[IDEGUIADD],variable,Color
color.z = 0.000000 //[IDEGUIADD],variable,Color
color.w = 1.000000 //[IDEGUIADD],variable,Color

CreateImageColor( 1, color.x * 255, color.y * 255, color.z * 255, color.w * 255 )

// LoadImage(1, image$)
CreateSprite(1,1)
SetSpriteSize(1, 50, 10)

http = CreateHTTPConnection()
SetHTTPHost( http, server$, 0 )

GetHTTPFile( http, folder$ + "/version.txt", version_file$ )
while GetHTTPFileComplete(http) = 0
    Print( "Downloading " + str(GetHTTPFileProgress(http)) )
    Sync()
endwhile

GetHTTPFile( http, folder$ + "/status.txt_old", status_file$ )
while GetHTTPFileComplete(http) = 0
    Print( "Syncing " + str(GetHTTPFileProgress(http)) )
    Sync()
endwhile

AddVirtualButton ( _STATE_UPDATE, 150, 150, 50 )
AddVirtualButton ( _STATE_PAUSE, 150, 200, 50 )
AddVirtualButton ( _STATE_START, 150, 250, 50 )
AddVirtualButton ( _STATE_END, 150, 300, 50 )
AddVirtualButton ( _STATE_INFO, 150, 350, 50 )

SetVirtualButtonText ( _STATE_UPDATE, "Update" )
SetVirtualButtonText ( _STATE_PAUSE, "Pause" )
SetVirtualButtonText ( _STATE_START, "Start" )
SetVirtualButtonText ( _STATE_END, "End" )
SetVirtualButtonText ( _STATE_INFO, "Info" )

SetVirtualButtonColor ( _STATE_UPDATE, 255, 155, 255 )
SetVirtualButtonColor ( _STATE_PAUSE, 155, 255, 155 )
SetVirtualButtonColor ( _STATE_START, 115, 215, 155 )
SetVirtualButtonColor ( _STATE_END, 155, 255, 215 )
SetVirtualButtonColor ( _STATE_INFO, 255, 215, 155 )

SetVirtualButtonVisible ( _STATE_UPDATE, 1 )
SetVirtualButtonVisible ( _STATE_PAUSE, 0 )
SetVirtualButtonVisible ( _STATE_START, 0 )
SetVirtualButtonVisible ( _STATE_END, 1 )
SetVirtualButtonVisible ( _STATE_INFO, 1 )

// Updater
SetSpritePosition(1, spritex, spritey)
SetSpriteScale(1, scale#, scale#)

//MakeFolder("raw:C:\LineageII")

global total_time as integer = 0
global add_time as integer = 0

SetVirtualButtonVisible (_STATE_PAUSE, 0)

sf = OpenToRead ( status_file$ )

Print (status_file$)

global file as tFile

do
	if GetVirtualButtonPressed ( _STATE_UPDATE )
		current_state = _STATE_UPDATE
		// MakeFolder("AGK Test Folder")
		Print("Current Folder: "+GetFolder())

		SetVirtualButtonAlpha   ( _STATE_UPDATE, 5 )
		SetVirtualButtonActive  ( _STATE_UPDATE, 0 )
		SetVirtualButtonVisible ( _STATE_PAUSE, 1 )
	endif
	
	if GetVirtualButtonPressed ( _STATE_PAUSE )
		if paused
			paused = 0
			current_state = _STATE_UPDATE
		else
			paused = 1
			current_state = _STATE_PAUSE
		endif
	endif
	
	if GetVirtualButtonPressed ( _STATE_START )
		current_state = _STATE_START
	endif
	
	if GetVirtualButtonPressed( _STATE_END )
		current_state = _STATE_END
	endif
	
	if GetVirtualButtonPressed( _STATE_INFO )
		OpenBrowser ( "https://isleofprayer.org" )
	endif
	
	
		select current_state
			case _STATE_UPDATE
				if not paused
					if FileEOF ( sf ) <= 0
					   	line$ = ReadLine ( sf )
						file._type$   = GetStringToken ( line$, "|", 1 )
						file._status$ = GetStringToken ( line$, "|", 2 )
						file._path$   = GetStringToken ( line$, "|", 3 )
						files.insert ( file )
						current_file_type$ = file._type$
					    //Sync()
					else
						current_state = _STATE_START
					endif
					select current_file_type$
						case TYPE_FOLDER$
							if not GetFileExists(file._path$)
								Print ( "Folder" + file._path$ )
								MakeFolder ( file._path$ )
							endif
						endcase
						case TYPE_FILE$
							Print (file._path$)
							needs_update = 1
							if GetFileExists(file._path$)
								temp_file = OpenToRead(file._path$)
								//if GetFileSize(temp_file) < file._size$)
								needs_update = 0
								//else
									//needs_update = 0
								//endif
								CloseFile(temp_file)
							endif
							if needs_update
								GetHTTPFile( http, folder$ + "/Install/" + file._path$, file._path$ )
								while GetHTTPFileComplete(http) = 0
									Print (file._path$)
									Print( "Downloading " + str(GetHTTPFileProgress(http)) )
									SetSpriteSize(1, GetHTTPFileProgress(http) * 5, 10)
									Sync()
								endwhile
							endif
							ShowStats()
						endcase
					endselect
				endif
			endcase
			case _STATE_START
				Print ( "START" )
			endcase
			case _STATE_PAUSE
				Print( "PAUSED" )
			endcase
			case _STATE_END
				CloseHTTPConnection  ( http )
				DeleteHTTPConnection ( http )
				CloseFile ( sf )
				End
			endcase
		endselect
	
	
	ShowStats()
    
	Sync()
loop

CloseHTTPConnection  ( http )
DeleteHTTPConnection ( http )
CloseFile ( sf )
				
function ShowStats()
	Print ( current_state )
    Print ( Str( total_time ) )
	Print ( Str( add_time ) )
    Print( ScreenFPS() )
    Print ( Str( Timer() ) )
endfunction