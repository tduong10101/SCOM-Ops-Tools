#####################################################################################
#
# Script: SCOMOpsTools.ps1
#
# Author: Tery Duong
#
# Date: 07/10/2015
#
# This script provide an UI to allow Operators to pause/resume monitoring in bulk in 
# SCOM. It also display alert status base on alert ID.  
#
######################################################################################

#Connect to SCOM server
New-SCOMManagementGroupConnection -ComputerName SCOMServer
$invocation = (Get-Variable MyInvocation).Value
#Set current directory path
$directorypath = [System.AppDomain]::CurrentDomain.BaseDirectory.TrimEnd('\')
#If directorypath equal to powershell.exe location then change it to script file location
if ($directorypath -eq $PSHOME.TrimEnd('\'))
{
    $directorypath = $PSScriptRoot
}
$log = $directorypath +'\log.txt'

#####################################################################################
# User interface
#####################################################################################

################################################################
Add-Type -AssemblyName system.windows.forms
$form = New-Object System.Windows.Forms.Form
$form.Size = New-Object System.Drawing.Size(680,400)
$form.FormBorderStyle = "Fixed3D"
$form.MaximizeBox = $false
$form.StartPosition = "CenterScreen"
$formIcon = New-Object system.drawing.icon ("$directorypath\img\scom.ico") 
$form.Icon = $formicon
$form.Text = "SCOM Operations Tools"


$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.DataBindings.DefaultDataSourceUpdateMode = 0
$tabControl.size = New-Object System.Drawing.Size(670,650)

$global:count = 0

################################################################
#Pause Page
$PauseTab = New-Object System.Windows.Forms.TabPage
$PauseTab.Text = "Pause Monitoring"
$tabControl.Controls.Add($PauseTab)

#Pause Path Textbox
$PPathText = New-Object System.Windows.Forms.TextBox
$PPathText.Location = New-Object System.Drawing.Point(150,15)
$PPathText.Size = New-Object System.Drawing.Size(400,5)
$PauseTab.Controls.Add($PPathText)
$PPathLabel = New-Object System.Windows.Forms.Label
$PPathLabel.Text = "Servers List Path:"
$PPathLabel.Location = New-Object System.Drawing.Point(5,17)
$PauseTab.Controls.Add($PPathLabel)

#Pause Browse Button
$PBrowse = New-Object System.Windows.Forms.OpenFileDialog
$PBrowse.Title = "Select server list txt file"
$PBrowse.InitialDirectory = $directorypath
$PBrowseButton = New-Object System.Windows.Forms.Button
$PBrowseButton.Text = "Browse"
$PBrowseButton.Location = New-Object System.Drawing.Point(570,13)
$PBrowseButton.Add_Click({
    $PBrowse.ShowDialog()
    $PPathText.Text=$PBrowse.FileName})
$PauseTab.Controls.Add($PBrowseButton)

#Pause Comment Text
$PComment = New-Object System.Windows.Forms.TextBox
$PComment.Multiline = $true
$Pcomment.Size = New-Object System.Drawing.Size(400,150)
$PComment.Location = New-Object System.Drawing.Point(150,45)

$PauseTab.Controls.Add($PComment)
$PCommentLabel = New-Object System.Windows.Forms.Label
$PCommentLabel.Text = "Comment:"
$PCommentLabel.Location = New-Object System.Drawing.Point(5,47)
$PauseTab.Controls.Add($PCommentLabel)

#Radio button group
$PPanel = New-Object System.Windows.Forms.Panel
$PPanel.Location = New-Object System.Drawing.Point(5,200) 
$PPanel.size = New-Object System.Drawing.Size(120,200) 
$PPanel.text = "Duration:"
$PauseTab.Controls.Add($PPanel)

#Duration by Minute Radio
$PMinuteRadio = New-Object System.Windows.Forms.RadioButton
$PMinuteRadio.Text = "Duration (Minutes):"
$PMinuteRadio.size = New-Object System.Drawing.Size(120,50)
$PMinuteRadio.Location = New-Object System.Drawing.Point(0,0)
$PMinuteRadio.Checked = $true
$PMinuteRadio.Add_Click({
    $PDateText.Enabled = $false
    $PMinuteText.Enabled = $true
}) 
$PPanel.Controls.Add($PMinuteRadio)

#Duration by Minute Text
$PMinuteText = New-Object System.Windows.Forms.TextBox
$PMinuteText.Location = New-Object System.Drawing.Point(150,215)
$PMinuteText.Size = New-Object System.Drawing.Size(400,5)
$PauseTab.Controls.Add($PMinuteText)

#Duration by Date Radio
$PDateRadio = New-Object System.Windows.Forms.RadioButton
$PDateRadio.Text = "Duration (Date):"
$PDateRadio.size = New-Object System.Drawing.Size(120,50) 
$PDateRadio.Location = New-Object System.Drawing.Point(0,40)
$PDateRadio.Add_Click({
    $PDateText.Enabled = $true
    $PMinuteText.Enabled = $false
}) 
$PPanel.Controls.Add($PDateRadio)

#Duration by Date Text
$PDateText = New-Object System.Windows.Forms.TextBox
$PDateText.Location = New-Object System.Drawing.Point(150,255)
$PDateText.Size = New-Object System.Drawing.Size(400,5)
$PDateText.Text = Get-Date -Format "dd/MM/yyyy %h:mm:ss tt"
$PDateText.Enabled = $false
$PauseTab.Controls.Add($PDateText)

#Set Button
$PSetButton = New-Object System.Windows.Forms.Button
$PSetButton.Text = "Set"
$PSetButton.Location = New-Object System.Drawing.Point(570,300)
$PSetButton.Add_Click({ClickSet})
$PauseTab.Controls.Add($PSetButton)

#View Logs button
$PViewLog = New-Object System.Windows.Forms.Button
$PViewLog.Text = "View Log"
$PViewLog.Location = New-Object System.Drawing.Point(475,300)
$PViewLog.Add_Click({ViewLog})
$PauseTab.Controls.Add($PViewLog)

################################################################
#Resume Page
$ResumeTab = New-Object System.Windows.Forms.TabPage
$ResumeTab.Text = "Resume Monitoring"
$tabControl.Controls.Add($ResumeTab)

$form.Controls.Add($tabControl)

#Resume Path Textbox
$RPathText = New-Object System.Windows.Forms.TextBox
$RPathText.Location = New-Object System.Drawing.Point(150,15)
$RPathText.Size = New-Object System.Drawing.Size(400,5)
$ResumeTab.Controls.Add($RPathText)
$RPathLabel = New-Object System.Windows.Forms.Label
$RPathLabel.Text = "Servers List Path:"
$RPathLabel.Location = New-Object System.Drawing.Point(5,17)
$ResumeTab.Controls.Add($RPathLabel)

#Resume Browse Button
$RBrowse = New-Object System.Windows.Forms.OpenFileDialog
$RBrowse.Title = "Select server list txt file"
$RBrowse.InitialDirectory = $directorypath
$RBrowseButton = New-Object System.Windows.Forms.Button
$RBrowseButton.Text = "Browse"
$RBrowseButton.Location = New-Object System.Drawing.Point(570,13)
$RBrowseButton.Add_Click({
    $RBrowse.ShowDialog()
    $RPathText.Text=$RBrowse.FileName})
$ResumeTab.Controls.Add($RBrowseButton)

#Resume Button
$RButton = New-Object System.Windows.Forms.Button
$RButton.Text = "Resume"
$RButton.Location = New-Object System.Drawing.Point(570,300)
$RButton.Add_Click({ClickResume})
$ResumeTab.Controls.Add($RButton)

#View Log Button
$RViewLog = New-Object System.Windows.Forms.Button
$RViewLog.Text = "View Log"
$RViewLog.Location = New-Object System.Drawing.Point(475,300)
$RViewLog.Add_Click({ViewLog})
$ResumeTab.Controls.Add($RViewLog)

################################################################
#Alert Check Page
$AlertCTab = New-Object System.Windows.Forms.TabPage
$AlertCTab.Text = "Alert Check"
$tabControl.Controls.Add($AlertCTab)

$form.Controls.Add($tabControl)

#Alert ID Textbox
$AAlertID = New-Object System.Windows.Forms.TextBox
$AAlertID.Location = New-Object System.Drawing.Point(150,15)
$AAlertID.Size = New-Object System.Drawing.Size(400,5)
$AlertCTab.Controls.Add($AAlertID)
$AAlertIDLabel = New-Object System.Windows.Forms.Label
$AAlertIDLabel.Text = "Alert ID:"
$AAlertIDLabel.Location = New-Object System.Drawing.Point(5,17)
$AlertCTab.Controls.Add($AAlertIDLabel)

#Output Textbox
$AOutput = New-Object System.Windows.Forms.TextBox
$AOutput.Multiline = $true
$AOutput.Size = New-Object System.Drawing.Size(640,260)
$AOutput.Location = New-Object System.Drawing.Point(10,70)
$AOutput.ReadOnly = $true
$AlertCTab.Controls.Add($AOutput)

$AOutputLabel = New-Object System.Windows.Forms.Label
$AOutputLabel.Text = "Output:"
$AOutputLabel.Location = New-Object System.Drawing.Point(5,47)
$AlertCTab.Controls.Add($AOutputLabel)

#Check Button
$ACheckButton = New-Object System.Windows.Forms.Button
$ACheckButton.Text = "Check"
$ACheckButton.Location = New-Object System.Drawing.Point(570,13)
$ACheckButton.Add_Click({ClickCheck})
$AlertCTab.Controls.Add($ACheckButton)
<#
#Resethealth Button
$AResetH = New-Object System.Windows.Forms.Button
$AResetH.Text = "Reset Health"
$AResetH.Location = New-Object System.Drawing.Point(570,40)
$AResetH.Size = New-Object System.Drawing.Size (100,16)
$AResetH.Add_Click({})
$AlertCTab.Controls.Add($AResetH)
#>
#####################################################################################
# functions
#####################################################################################

#####################################################################################
#function ClickCheck: Validate alert ID, get-scomalert and spit out resolve status
function ClickCheck {
    try{
        $Alert = Get-SCOMAlert -id (($AAlertID.Text).Trim())
        $ResolvedBy = $Alert.ResolvedBy
        $TimeRaised = $Alert.TimeRaised.tolocaltime()
        $TimeAdded = $Alert.TimeAdded.tolocaltime()
        $LastModified = $Alert.LastModified.tolocaltime()
        $LastModifiedBy = $Alert.LastModifiedBy
        if ($Alert.TimeResolved -ne $null){
            $TimeResolved = $Alert.TimeResolved.tolocaltime()
        } else {
			$TimeResolved = ""
		}
        $TimeResolutionStateLastModified = $Alert.TimeResolutionStateLastModified.tolocaltime()
        
        $AOutput.Text = 
        "ResolvedBy`t`t`t: $ResolvedBy `r`n"+
        "TimeRaised`t`t`t: $TimeRaised `r`n"+
        "TimeAdded`t`t`t: $TimeAdded `r`n"+
        "LastModified`t`t`t: $LastModified `r`n"+
        "LastModifiedBy`t`t`t: $LastModifiedBy `r`n"+
        "TimeResolved`t`t`t: $TimeResolved `r`n"+
        "TimeResolutionStateLastModified`t: $TimeResolutionStateLastModified"
    }catch{
        [System.Windows.Forms.MessageBox]::Show("Please input an valid ID!","Invalid Input",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

#####################################################################################
#function ClickResume: Validate input (text file) then run resume the alert from servers

function ClickResume {
    $run = $true
    try{
        #throw error if file is not .txt
        if ($RPathText.Text.Substring($RPathText.Text.get_Length()-3) -ne "txt"){
            throw ""
        }
        $servers = Get-Content $RPathText.Text -ErrorAction Stop
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Please input an valid server list text file!","Invalid Input",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error)
        $run = $false
    }
    if ($run -eq $true) {
        $result = Resume $servers
    [System.Windows.Forms.MessageBox]::Show("Completed! `r`n$result","Maintenance Mode",[System.Windows.Forms.MessageBoxButtons]::OK)
    }
}

#####################################################################################
#function ClickSet : Validate inputs (text file, date/minutes) then run function Pause
function ClickSet {
    $run = $true
    try{
        #throw error if file is not .txt
        if ($PPathText.Text.Substring($PPathText.Text.get_Length()-3) -ne "txt"){
            throw ""
        }
        $servers = Get-Content $PPathText.Text -ErrorAction Stop
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Please input an valid server list text file!","Invalid Input",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error)
        $run = $false
    }
    if ($PMinuteRadio.Checked -eq $true){
        #try/catch if input is not integer
        try{
            [int]$Minutes = $PMinuteText.Text
            $Date = (Get-Date).AddMinutes($Minutes)
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Please input an integer for minutes!","Invalid Input",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error)
            $run = $false
        }
    } else{
        #try/catch if input is not in correct format
        try{   
            $Date = [datetime]::ParseExact($PDateText.Text, "dd/MM/yyyy h:mm:ss tt", [Globalization.CultureInfo]::InvariantCulture)
            Write-Host $Date
            $today = Get-date
            #if date is in the past throw an error
            if ($today -gt $Date){
                Write-Host "test"
                throw "Date/time can not be in the past"
            }
        } 
        catch {
            [System.Windows.Forms.MessageBox]::Show("Invaliad date! `n"+$Error[0],"Invalid Input",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error)
            $run = $false
        }
    }

    # run Pause function if there is no error
    if ($run -eq $true){
        $result = Pause $servers $PComment.Text $Date
        [System.Windows.Forms.MessageBox]::Show("Completed!`r`n$result","Maintenance Mode",[System.Windows.Forms.MessageBoxButtons]::OK)
    }
}

#####################################################################################
#function Pause: loop through servers array and put servers to maintenance mode
function Pause ($servers,$Comment,$Date) {
    $ecount = 0
    
    foreach ($server in $servers){
        try {
            $server = $server.Trim()
            $Instance = Get-SCOMClassInstance -Name "$server*"
            
            if ($Instance.inmaintenancemode -eq $true){ 
            #edit maintenancemod if server is already browned out
                Set-SCOMMaintenanceMode -MaintenanceModeEntry (Get-SCOMMaintenanceMode -Instance $Instance) -EndTime $Date.ToUniversalTime() -Comment $Comment
            }else{
            #else start maintnenancemod
                Start-SCOMMaintenanceMode -Instance $Instance -EndTime $Date.ToUniversalTime() -Comment $Comment -Reason "PlannedOther"
            }
            
        }
        catch{
            $seperator = "##########################################"
            $seperator | out-file $log -Append 
            $date = get-date
            write-host "test"
            "Server: $server Date: $date" | out-file $log -Append 
            $error[0] | out-file $log -Append
            $ecount++
        }
    }
    return "There are $ecount error(s), please check log file for details."
}

#####################################################################################
#function Resume: loop through servers array and put servers out of maintenance mode
function Resume ($servers) {
    $ecount = 0
    
    foreach ($server in $servers){
        try {
            $server = $server.Trim()
            $Instance = Get-SCOMClassInstance -Name "$server*"
            
            if ($Instance.inmaintenancemode -eq $true){ 
            #Stop maintenancemod if server is already browned out
                $Instance.StopMaintenanceMode([DateTime]::Now.ToUniversalTime(),[Microsoft.EnterpriseManagement.Common.TraversalDepth]::Recursive);
            }
            
        }
        catch{
            $seperator = "##########################################"
            $seperator | out-file $log -Append
            $date = get-date
            write-host "test"
            "Server: $server Date: $date" | out-file $log -Append
            $error[0] | out-file $log -Append
            $ecount++
        }
    }
    return "There are $ecount error(s), please check log file for details."
}

#####################################################################################
#function ViewLog: Open log text file at $directorypath +'\log.txt'

function ViewLog {
    Invoke-Item $log
}

$form.Add_Shown({$form.Activate()})
$form.ShowDialog()