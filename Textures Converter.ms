/*  
[INFO] 

NAME = Textures Converter
VERSION = 1.0.0
AUTHOR = MastaMan
DEV = Visco CG
HELP = 

[INSTALL]

MACRO=TexturesConverter
CAT=VISCO
TEXT=Textures Converter
ICON=#("FileLinkActionItems", 5)

[1.0.0]

* First release =

[ABOUT]

This script helps to quickly convert and relink textures in on format.=

[TEST]

[SCRIPT]
*/	


fn getScriptInfo s releaseInfo: "" =
(		
	if(releaseInfo != "") do
	(
		r = getINISetting s releaseInfo
		return r
	)
	
	v = getINISetting s "INFO" "VERSION"
	a = getINISetting s "INFO" "AUTHOR"
	n = getINISetting s "INFO" "NAME"
	o = getINISetting s "ABOUT"
	c = getINISetting s "INFO" "DEV"
	h = getINISetting s "INFO" "HELP"
	
	r = for i in (getINISetting s) where i != "ABOUT" and i != "SCRIPT" and i != "COPY" collect i
	
	return #(n, a, v, o, r, c, h)
)


fn parseToLine m = 
(
	if(m.count == 0) do return ""
	
	l = ""				
	for i in m do l += i + "\n"
	return l
)

fn useSettings k p w =
(	
	d = getFilenamePath  (getThisScriptFilename())
	n = filenameFromPath (getThisScriptFilename())			
	settingsFile = d + @"ini\" + (sysInfo.username) + "_" + n + ".ini"
	szUser = sysInfo.computername
	case w of
	(
		"r":
		(
			s = getINISetting settingsFile szUser k
			case p of
			(
				"int": return s as integer
				"float": return s as float
				"bool": if s == "true" then true else false
				default: return s
			)
		)
		default: return setINISetting settingsFile szUser k (p as string)
	)
)

global outputPath = ""

rollout  _rTexturesConverter "Settings" 
(
	group "Settings"
	(
		label lblFormat "Format:" across: 2 align: #left		
		dropdownlist ddlFormat "" items: #("JPG", "PNG", "TIFF", "BMP") width: 50 align: #left offset: [-50, -3]	
		spinner spnGamma "Gamma:" range:[1.0,  10.0, 1.0] type: #float align: #left fieldWidth: 35 offset: [0, 4]	
		checkbox cbxRelink "Relink all textures" checked: true tooltip: "Change all paths for textures to selected in New Path For Textures" offset: [0, 4]
	)	
	group "New Path For Textures"
	(
		edittext edtOutput "" readOnly: true height: 24
		button btnBrowse "Browse"
	)
	
	button btnConvert "Convert" width: 220 height: 35 offset: [0, 10] enabled: false
	
	fn ConvertTextures =
	(
		progressStart "Convert Textures..."
		escapeEnable
		
		iCount = 0
		iCountError = 0
		iCountOk = 0
		
		classBitmapTex = getClassInstances BitmapTex 
		
		for b in classBitmapTex do
		(
			progressUpdate (100.0 * iCount / classBitmapTex.count)
			if(getProgressCancel() == true) do exit

			iCount += 1			
			
			if(b.filename == undefined or not doesFileExist b.filename) then
			(
				iCountError	+= 1
				continue
			)
			else
			(
				iCountOk += 1
			)
			
			p = getFilenamePath b.filename
			n = getFilenameFile b.filename
			ext = toLower ddlFormat.selected
			
			f = outputPath + n + "." + ext
						
			btm = b.bitmap
			btm.filename = f
			save btm gamma: spnGamma.value
			
			if(cbxRelink.checked) do b.filename = f
		)
		
		progressEnd()
		
		m = "Converted: " + iCountOk as string + "\nNot converted: " + iCountError as string
		messageBox m title: "Statistic!" beep: false
		shellLaunch outputPath ""
		
		
	)
	
	on btnBrowse pressed do
	(
		p = getSavePath initialDir: outputPath
		
		if(p != undefined) do
		(
			p = p + @"\"
			
			edtOutput.text = p
			useSettings "PATH" p "w"
			
			btnConvert.enabled = true
		)
	)
	
	on _rTexturesConverter open do
	(
		outputPath = useSettings "PATH" "string" "r"	
		edtOutput.text = outputPath
		
		f = useSettings "FORMAT" "int" "r"
		if(f != 0) do ddlFormat.selection = f
		
		r = useSettings "RELINK" "bool" "r"
		cbxRelink.checked = not r
		
		g = useSettings "GAMMA" "float" "r"
		if(g != 0) do spnGamma.value = g
		
		if(outputPath.count > 2) do btnConvert.enabled = true
	)
	
	on ddlFormat selected v do
	(
		useSettings "FORMAT" v "w"
	)
	
	on cbxRelink changed v do
	(
		useSettings "RELINK" (not v) "w"
	)
	
	on btnConvert pressed do
	(
		ConvertTextures()
	)
	
	on spnGamma changed v do
	(
		useSettings "GAMMA" v "w"
	)
)


rollout _rAbout "About" 
(
	label lblName "" 
	label lblVer "" 
	
	label lblAuthor "" height: 30
	label lblCopy ""  height: 30
	
	on _rAbout open do
	(		
		i = getScriptInfo (getThisScriptFilename())
			
		lblName.caption = i[1]
		lblAuthor.caption = i[2]
		lblVer.caption = i[3]
		lblCopy.caption = i[6]
	)
)

try(closeRolloutFloater rTexturesConverter) catch()
global rTexturesConverter = newRolloutFloater "Detach Element" 250 320

addRollout _rTexturesConverter rTexturesConverter rolledUp:false 
addRollout _rAbout rTexturesConverter rolledUp:true 