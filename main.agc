// Project: Chilly Willy Updater for AGK2
// Created: 20-03-17

// show all errors
SetErrorMode(2)

// set window properties
SetWindowTitle( "Chilly Willy Updater" )
SetWindowSize( 1024, 768, 0 )
SetWindowAllowResize( 0 ) // allow the user to resize the window
SetClearColor(255, 255, 255)

// set display properties
SetVirtualResolution( 1024, 768 ) // doesn't have to match the window
SetOrientationAllowed( 1, 1, 1, 1 ) // allow both portrait and landscape on mobile devices
SetSyncRate( 30, 0 ) // 30fps instead of 60 to save battery
SetScissor( 0,0,0,0 ) // use the maximum available screen space, no black borders

UseNewDefaultFonts( 1 )
SetPrintSize ( 18 ) 
SetPrintColor(0,0,0)
SetPrintSpacing(0.5)

//[IDEGUIADD],header,Chilly Willy Updater 
//[IDEGUIADD],message, Update files from a remote server
//[IDEGUIADD],separator,

//#import_plugin FileExplore

#constant _STATE_STOP = 0
#constant _STATE_UPDATE = 1
#constant _STATE_PAUSE = 2
#constant _STATE_START = 3
#constant _STATE_END = 4

#constant _EVENT_INFO = 5
#constant _EVENT_MUSIC = 6

#constant STATE_STOPPED = 0
#constant STATE_UPDATING = 1
#constant STATE_PAUSED = 2
#constant STATE_STARTED = 3

#constant TYPE_FILE$ = "a"
#constant TYPE_FOLDER$ = "d"

#constant SPRITE_BACKGROUND = 1
#constant SPRITE_UPDATE = 2

#constant IMAGE_BACKGROUND = 1
#constant IMAGE_COLOR = 2

#constant TEXT_UPDATE = 1
#constant TEXT_CHANGELOG = 2

#constant CRLF$ = chr(13) + chr(10)

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

type tConfig
	server as string
	background as string 
	remote_port as integer
	remote_folder as string
	remote_subfolder as string
	status_file as string 
	changelog_file as string
	music as string
	music_volume as integer
	info_url as string
	version_file as string
    executable_file as string
endtype

global server$ as string 
global port$ as integer 
global folder$ as string 
global subfolder$ as string
global status_file$ as string 
global changelog_file$ as string 

global music$ as string 
global music_volume as integer 
global info_url$ as string 

global config_file$ as string 
global version_file$ as string 
global executable_file$ as string 
global current_file_type$ as string
global mp3_outro as integer

global current_state as integer = 0 //[IDEGUIADD],integer,Current State
global paused as integer = 0 //[IDEGUIADD],integer,Paused

global music_enabled as integer = 31 //[IDEGUIADD],integer, Music enabled
global spritex as integer = 280 //[IDEGUIADD],integer,X
global spritey as integer = 700 //[IDEGUIADD],integer,Y
global sprite_width as integer = 20 //[IDEGUIADD],integer,Width
global sprite_height as integer = 20 //[IDEGUIADD],integer,Height
global scale# as integer = 1 //[IDEGUIADD],float,Scale
global image$ as string 

global color as vec4 //[IDEGUIADD],vec4color,Color

color.x = 1.000000 //[IDEGUIADD],variable,Color
color.y = 0.957365 //[IDEGUIADD],variable,Color
color.z = 0.000000 //[IDEGUIADD],variable,Color
color.w = 1.000000 //[IDEGUIADD],variable,Color

global config as tConfig

global json$ as string
json$ = Updater_JSON_Load("config.json")
config.fromJson(json$)

server$ = config.server
port = config.remote_port 
folder$ = config.remote_folder 
subfolder$ = config.remote_subfolder 
status_file$ = config.status_file
changelog_file$ = config.changelog_file 
music$ = config.music 
music_volume = config.music_volume 
info_url$ = config.info_url 
version_file$ = config.version_file 
executable_file$ = config.executable_file
image$ = config.background

http = CreateHTTPConnection()
SetHTTPHost( http, server$, 0 )

//~szPath as string

//~szPath = "raw:c:\line"
//~MakeFolder(szPath) 

// OpenToWrite( 1 , "raw:c:\temp\myFile.txt" )

// Exists the remote config file it overrides any local configuration

GetHTTPFile( http, folder$ + config_file$, changelog_file$ )
while GetHTTPFileComplete(http) = 0
	// custom_config_file = 1
    Sync()
endwhile

CreateText(TEXT_UPDATE, "")
SetTextColor(TEXT_UPDATE, 0, 0, 0, 255 )
SetTextPosition(TEXT_UPDATE, 280, 680)
SetTextSize(TEXT_UPDATE, 18)

mp3_outro = LoadMusic(music$)
SetMusicFileVolume(mp3_outro, music_volume)
PlayMusic (mp3_outro, 1)

GetHTTPFile( http, folder$ + "/changelog.txt", changelog_file$ )
while GetHTTPFileComplete(http) = 0
    Sync()
endwhile

cf = OpenToRead ( changelog_file$ )

global temp_text$ as string = ""

CreateEditBox( TEXT_CHANGELOG )
SetEditBoxMultiLine(TEXT_CHANGELOG, 1)

temp_text$ = ReadLine ( cf )

while not FileEOF ( cf )
   	temp_text$ = temp_text$ + CRLF$ + ReadLine ( cf )
endwhile

SetEditBoxText(TEXT_CHANGELOG, temp_text$)
SetEditBoxBorderSize(TEXT_CHANGELOG, 0)
SetEditBoxMaxLines(TEXT_CHANGELOG, 6)
SetEditBoxTextColor(TEXT_CHANGELOG, 0, 0, 0 )
SetEditBoxPosition(TEXT_CHANGELOG, 800, 220)
SetEditBoxTextSize(TEXT_CHANGELOG, 18)
SetEditBoxSize(TEXT_CHANGELOG, 200, 200)
SetEditBoxActive(TEXT_CHANGELOG, 0)
CloseFile ( cf )

GetHTTPFile( http, folder$ + "/version.txt", version_file$ )
while GetHTTPFileComplete(http) = 0
    Sync()
endwhile

GetHTTPFile( http, folder$ + "/l2.txt", executable_file$ )
while GetHTTPFileComplete(http) = 0
    Sync()
endwhile

GetHTTPFile( http, folder$ + "/" + status_file$, status_file$ )
while GetHTTPFileComplete(http) = 0
    Sync()
endwhile

sf = OpenToRead ( status_file$ )

LoadImage(SPRITE_BACKGROUND, image$)
CreateSprite(IMAGE_BACKGROUND, SPRITE_BACKGROUND)
SetSpriteSize(IMAGE_BACKGROUND, 1024, 768)
SetSpritePosition(IMAGE_BACKGROUND, 0, 0)

CreateImageColor(IMAGE_COLOR, color.x * 255, color.y * 255, color.z * 255, color.w * 255 )
CreateSprite(SPRITE_UPDATE, IMAGE_COLOR)
SetSpriteSize(SPRITE_UPDATE, 0, 10)

AddVirtualButton ( _STATE_UPDATE, 150, 150, 50 )
AddVirtualButton ( _STATE_PAUSE, 150, 200, 50 )
AddVirtualButton ( _STATE_START, 150, 250, 50 )
AddVirtualButton ( _STATE_END, 150, 300, 50 )
AddVirtualButton ( 99 , 300, 300, 50 )
AddVirtualButton ( _EVENT_INFO, 150, 350, 50 )
AddVirtualButton ( _EVENT_MUSIC, 150, 400, 50 )

SetVirtualButtonText ( _STATE_UPDATE, "Update" )
SetVirtualButtonText ( _STATE_PAUSE, "Pause" )
SetVirtualButtonText ( _STATE_START, "Start" )
SetVirtualButtonText ( _STATE_END, "End" )

SetVirtualButtonText ( _EVENT_INFO, "Info" )
SetVirtualButtonText ( _EVENT_MUSIC, "Music" )

SetVirtualButtonColor ( _STATE_UPDATE, 255, 155, 255 )
SetVirtualButtonColor ( _STATE_PAUSE, 155, 255, 155 )
SetVirtualButtonColor ( _STATE_START, 115, 215, 155 )
SetVirtualButtonColor ( _STATE_END, 155, 255, 215 )

SetVirtualButtonColor ( _EVENT_INFO, 255, 215, 155 )
SetVirtualButtonColor ( _EVENT_MUSIC, 255, 115, 215 )

SetVirtualButtonVisible ( _STATE_UPDATE, 1 )
SetVirtualButtonVisible ( _STATE_PAUSE, 0 )
SetVirtualButtonVisible ( _STATE_START, 1 )
SetVirtualButtonVisible ( _STATE_END, 1 )

SetVirtualButtonVisible ( _EVENT_INFO, 1 )
SetVirtualButtonVisible ( _EVENT_MUSIC, 1 )

// Updater
SetSpritePosition(SPRITE_UPDATE, spritex, spritey)
SetSpriteScale(SPRITE_UPDATE, scale#, scale#)

global total_time as integer = 0
global add_time as integer = 0

global file as tFile
global fold$ as string

//~if(GetFileExists('CONFIG'))
//	config.fromJSON('CONFIG');
//~endif

//Validation server

do	
	CheckButtons()

	select current_state
		case _STATE_UPDATE
			SetVirtualButtonVisible ( _STATE_START, 0 )
			if not paused
				if FileEOF ( sf ) <= 0
				   	line$ = ReadLine ( sf )
					file._type$   = GetStringToken ( line$, "|", 1 )
					file._status$ = GetStringToken ( line$, "|", 2 )
					file._path$   = GetStringToken ( line$, "|", 3 )
					files.insert ( file )
					current_file_type$ = file._type$
				else
					current_state = _STATE_START
				endif
				needs_update = 1
				select current_file_type$
					case TYPE_FOLDER$
						if not GetFileExists(file._path$)
							MakeFolder ( file._path$ )
						endif
					endcase
					case TYPE_FILE$
						if GetFileExists(file._path$)
							needs_update = 0
						endif
						if needs_update and GetHTTPStatusCode(http) = 200
							destination$ = file._path$
							if destination$ = "L2"
								destination$ = destination$ + ".bat"
							endif
							GetHTTPFile( http, folder$ + "/" + subfolder$ + "/" + file._path$, destination$ )
							while GetHTTPFileComplete(http) = 0
								CheckButtons()
								SetTextString (TEXT_UPDATE, file._path$ + " " + str(GetHTTPFileProgress(http)))
							    SetSpriteSize(SPRITE_UPDATE, GetHTTPFileProgress(http) * 5, 10)
								Sync()
							endwhile
						else
							SetTextString(TEXT_UPDATE, file._path$)
						endif
					endcase
				endselect
			endif
		endcase
		
		case _STATE_START
			SetVirtualButtonActive  ( _STATE_UPDATE, 0 )
			SetVirtualButtonActive  ( _STATE_PAUSE, 0 )
			SetVirtualButtonVisible  ( _STATE_UPDATE, 0 )
			SetVirtualButtonVisible  ( _STATE_PAUSE, 0 )
			SetVirtualButtonActive  ( _STATE_START, 1 )
			SetVirtualButtonVisible  ( _STATE_START, 1 )
			SetTextString (TEXT_UPDATE, "START")
		endcase
		
		case _STATE_PAUSE
			SetTextString (TEXT_UPDATE, "PAUSED")
		endcase
		
		case _STATE_END
			Exit
		endcase
		
	endselect
	 
	Sync()
loop

function CheckButtons()
	
//~	if GetVirtualButtonPressed ( 99 )
//~		fold$ = FileExplore.ChooseFolderDialog("Title", "")
//~	endif

	Print(fold$)
	if GetVirtualButtonPressed ( _STATE_UPDATE )
		current_state = _STATE_UPDATE
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
		RunApp(executable_file$, "")
	endif
	
	if GetVirtualButtonPressed( _STATE_END )
		current_state = _STATE_END
	endif
	
	if GetVirtualButtonPressed( _EVENT_INFO )
		OpenBrowser ( info_url$ )
	endif
	
	if GetVirtualButtonPressed( _EVENT_MUSIC )
		if music_enabled
			StopMusic()
			music_enabled = 0
		else
			PlayMusic (mp3_outro, 1)
			music_enabled = 1
		endif
	endif
endfunction

CloseHTTPConnection  ( http )
DeleteHTTPConnection ( http )
CloseFile ( sf )


/*
 * Load a JSON file
 */
function Updater_JSON_Load(filename$)
	JSON$ as string = ""
	memBlock as integer
	memBlock = CreateMemblockFromFile(filename$)
	JSON$ = GetMemblockString(Memblock, 0, GetMemblockSize(memBlock))
	DeleteMemblock(memBlock)
endfunction JSON$

/*
 * Save a string into a JSON file
 */
function Updater_JSON_Save(string$, filename$)
    OpenToWrite(1,filename$,0) 
    WriteString(1,string$)
    CloseFile(1)
endfunction