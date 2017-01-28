local Checks = {}

-----------------------------------------------------------------
--
-----------------------------------------------------------------
function OnApplicationBegin()
	UIMain.AddPluginButton("ImageMagick","ImageMagickShow",GetAndShow)
end
---------------------------------------------------------------------------
UI = nil
function Get()
	if not (UI) then 
		UI = cImageMagick("1")
		UI.parent = UIMain.Get()
	end 
	return UI
end

function GetAndShow()
	Get():Show(true)
end
-----------------------------------------------------------------
-- UI Class Definition
-----------------------------------------------------------------
local inherited = UIBase.cUIBase
cImageMagick = Class("cImageMagick",inherited)
function cImageMagick:initialize(id)
	inherited.initialize(self,id)
end

function cImageMagick:Reinit()
	inherited.Reinit(self)
	
	local tabs = {"Mogrify"}
	Checks["1"] = {"CopyTHM"}
	
	-- below will be automated based on above tab definition and checks
	self:Gui("Add|Tab2|x0 y0 w1024 h720 AltSubmit vImageMagickTab|%s",table.concat(tabs,"^"))
	
	for i=1,#tabs do
		local i_s = tostring(i)
		
		self:Gui("Tab|%s",tabs[i])
			self:Gui("Add|Text|x590 y60 w300 h40 cBlue vImageMagickLink%s gOnScriptControlAction|Click here for Mogrify command options",i)
			self:Gui("Add|Text|x270 y365 w300 h40 cBlue vImageMagickLink2%s gOnScriptControlAction|Click for tutorial",i)
			self:Gui("Add|Text|x590 y160 w300 h40|Mogrify is a very useful texture command line tool. Here is an example if you want re-mip textures using the Kaiser filter: -filter Kaiser",i)
			-- GroupBox
			self:Gui("Add|GroupBox|x10 y50 w510 h75|Input Path (Recursive)")
			self:Gui("Add|GroupBox|x10 y150 w510 h75|Output Path")
			self:Gui("Add|GroupBox|x10 y250 w510 h75|Command-line options")
			self:Gui("Add|GroupBox|x10 y350 w510 h75|Pattern Matching")
			
			if (Checks[i_s]) then
				local y = 445
				--table.sort(Checks[i_s])
				for n=1,#Checks[i_s] do
					self:Gui("Add|CheckBox|x50 y%s w150 h22 %s vImageMagickCheck%s%s|%s",y,gSettings:GetValue("ImageMagick","check_"..Checks[i_s][n]..i_s,"") == "1" and "Checked" or "",Checks[i_s][n],i_s,Checks[i_s][n])
					y = y + 20
				end
			end
			
			-- Buttons 
			self:Gui("Add|Button|gOnScriptControlAction x485 y80 w30 h20 vImageMagickBrowseInputPath%s|...",i)
			self:Gui("Add|Button|gOnScriptControlAction x485 y180 w30 h20 vImageMagickBrowseOutputPath%s|...",i)
			self:Gui("Add|Button|gOnScriptControlAction x485 y655 w90 h20 vImageMagickSaveSettings%s|Save Settings",i)	
			self:Gui("Add|Button|gOnScriptControlAction x485 y680 w90 h20 vImageMagickExecute%s|Execute",i)		
			
			-- Editbox 
			self:Gui("Add|Edit|gOnScriptControlAction x25 y80 w450 h20 vImageMagickInputPath%s|",i)
			self:Gui("Add|Edit|gOnScriptControlAction x25 y180 w450 h20 vImageMagickOutputPath%s|",i)
			self:Gui("Add|Edit|gOnScriptControlAction x25 y280 w450 h20 vImageMagickMogrify%s|",i)
			self:Gui("Add|Edit|gOnScriptControlAction x25 y380 w450 h20 vImageMagickSearch%s|",i)
			
		GuiControl(self.ID,"","ImageMagickInputPath"..i, gSettings:GetValue("ImageMagick","input_path"..i) or "")
		GuiControl(self.ID,"","ImageMagickOutputPath"..i, gSettings:GetValue("ImageMagick","output_path"..i) or "")
		GuiControl(self.ID,"","ImageMagickMogrify"..i, gSettings:GetValue("ImageMagick","command_line"..i) or "")
		GuiControl(self.ID,"","ImageMagickSearch"..i, gSettings:GetValue("ImageMagick","search_pattern"..i) or "")
	end
	self:Gui("Show|w1024 h720|ImageMagick")
end

function cImageMagick:OnGuiClose(idx) -- needed because it's registered to callback
	inherited.OnGuiClose(self,idx)
end 

function cImageMagick:OnScriptControlAction(hwnd,event,info) -- needed because it's registered to callback
	self:Gui("Submit|NoHide")
	local tab = ahkGetVar("ImageMagickTab") or "1"
	
	if (hwnd == GuiControlGet(self.ID,"hwnd","ImageMagickBrowseInputPath"..tab)) then
		local dir = FileSelectFolder("*"..(gSettings:GetValue("ImageMagick","input_path"..tab) or ""))
		if (dir and dir ~= "") then
			GuiControl(self.ID,"","ImageMagickInputPath"..tab,dir)
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","ImageMagickBrowseOutputPath"..tab)) then 
		local dir = FileSelectFolder("*"..(gSettings:GetValue("ImageMagick","output_path"..tab) or ""))
		if (dir and dir ~= "") then
			GuiControl(self.ID,"","ImageMagickOutputPath"..tab,dir)
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","ImageMagickExecute"..tab)) then
		self:Gui("Submit|NoHide")
		self:ActionExecute(tab)
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","ImageMagickSaveSettings"..tab)) then
		local input_path = ahkGetVar("ImageMagickInputPath"..tab)
		local output_path = ahkGetVar("ImageMagickOutputPath"..tab)
	
		gSettings:SetValue("ImageMagick","input_path"..tab,input_path)
		gSettings:SetValue("ImageMagick","output_path"..tab,output_path)
		gSettings:SetValue("ImageMagick","command_line"..tab,trim(ahkGetVar("ImageMagickMogrify"..tab)))
		gSettings:SetValue("ImageMagick","command_line"..tab, trim(ahkGetVar("ImageMagickSearch"..tab)))
		
		gSettings:Save()
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","ImageMagickLink"..tab)) then 
		Run("http://www.imagemagick.org/script/mogrify.php")
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","ImageMagickLink2"..tab)) then 
		Run("http://wowwiki.wikia.com/wiki/Pattern_matching")
	end
end

_INACTION = nil
function cImageMagick:ActionExecute(tab)
	if (_INACTION) then 
		MsgBox("Already performing an action")
		return 
	end
	
	local input_path = ahkGetVar("ImageMagickInputPath"..tab)
	if (input_path == nil or input_path == "") then 
		MsgBox("Incorrect Path!")
		return 
	end 
	
	local output_path = ahkGetVar("ImageMagickOutputPath"..tab)
	if (output_path == nil or output_path == "") then 
		MsgBox("Incorrect Output Path!")
		return 
	end

	if (Checks[tab]) then
		for i=1,#Checks[tab] do 
			local bool = ahkGetVar("ImageMagickCheck"..Checks[tab][i]..tab)
			gSettings:SetValue("ImageMagick","check_"..Checks[tab][i]..tab,bool)
		end
	end
	
	gSettings:SetValue("ImageMagick","input_path"..tab,input_path)
	gSettings:SetValue("ImageMagick","output_path"..tab,output_path)
	gSettings:Save()
	
	_INACTION = true
	
	self:ActionExecuteMain(tab,input_path,output_path)
	
	_INACTION = false
end

function cImageMagick:ActionExecuteMain(tab,input_path,output_path)
	
	Msg("ImageMagick:= Working...")
	
	local skip_xcopy = input_path == output_path

	lfs.mkdir(output_path)

	local search_pattern = trim(ahkGetVar("ImageMagickSearch"..tab))
	gSettings:SetValue("ImageMagick","search_pattern"..tab,search_pattern)
	
	local command_line_options = trim(ahkGetVar("ImageMagickMogrify"..tab))
	gSettings:SetValue("ImageMagick","command_line"..tab,command_line_options)
	gSettings:Save()
	
	local working_directory = ahkGetVar("A_WorkingDir")..[[\bin\ImageMagick\]]
	local cp = working_directory .. "mogrify.exe"
	
	local copy_thm = ahkGetVar("ImageMagickCheck"..Checks[tab][1]..tab) == "1"
	local function on_execute(path,fname)
		local full_path = path.."\\"..fname
		if (search_pattern == nil or search_pattern == "" or string.match(full_path,search_pattern)) then
			local local_path = trim_final_backslash(output_path..string.gsub(full_path,escape_lua_pattern(input_path),""))
			if not (skip_xcopy) then
				lfs.mkdir(get_path(local_path))
				RunWait( strformat([[xcopy "%s" "%s" /y /i]],full_path,get_path(local_path)) , working_directory )
			end
			RunWait( strformat([["%s" %s "%s"]],cp,command_line_options,local_path) , working_directory )
			
			if (copy_thm) then 
				RunWait( strformat([[xcopy "%s" "%s" /y /i /q /c]],trim_ext(full_path)..".thm",get_path(local_path)) , working_directory )
			end
		end
	end
	
	recurse_subdirectories_and_execute(input_path,{"dds"},on_execute)
	
	Msg("ImageMagick:= Finished!")
end