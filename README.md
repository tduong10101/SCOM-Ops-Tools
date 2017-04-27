# SCOM-Ops-Tools
UI provide option to pause/resume servers in bulk
SCOM Operations Tools

### Pause Monitoring:

![alt text](https://github.com/tduong10101/SCOM-Ops-Tools/blob/master/img/PauseTabCapt.png)

This tab is similar to what we have with SCOM Operations Console – Maintenance mode function. However it will allow user to pause monitoring on multiple servers at one run base on the .txt servers list path input (each server has to be on separate line – please see below file for a sample)
  
This form will detect any invalid inputs and prompt user to correct them.
Please allow some time for the app to perform the task. Once task is completed a windows will pop up to confirm task completion.
User can check error log if there is any issues by select the “View Log” button.


### Resume Monitoring:

![alt text](https://github.com/tduong10101/SCOM-Ops-Tools/blob/master/img/ResumeTabCapt.png)
 
This tab will allow user to unpause/resume monitoring on multiple servers.
User input server list and it will resume monitoring on those servers. Please use same format as Pause Monitoring - servers list .txt format. 
Once task is completed a windows will pop up to confirm task completion.
User can check error log if there is any issues by select the “View Log” button. 

### Alert Check:

![alt text](https://github.com/tduong10101/SCOM-Ops-Tools/blob/master/img/AlertCheckTabCapt-1.png)
 
This tab will let user to check alert resolution status base on Alert ID.
Once input alert ID and hit Check button, output field will display the below information. Base on this user will be able to identify if alert has been cleared or not.
 
![alt text](https://github.com/tduong10101/SCOM-Ops-Tools/blob/master/img/AlertCheckTabCapt-2.png)
