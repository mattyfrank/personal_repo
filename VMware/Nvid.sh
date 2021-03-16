#.sh to update ESX Nvidia VIB. 

 ##Improvements - Look to structure Nvid VIBs in Directory to avoid calling full path
 #ForEach (Server in Servers) Do  - ssh $Server './vmfs/volume/isilon-esxisos/nvidia/nvidia.sh'
 #SecureCRT can connect to SSH and 'RunCommand:' without having to interact with system

#!/bin/sh

#Set Host to MaintenanceMode
esxcli system maintenanceMode set --enable true

#Grep existing Nvid VIB and format as variable
current=`esxcli software vib list | grep NVIDIA | cut -f1 -d " "`

#Remove current Nvidia VIB
esxcli software vib remove -n $current

#set path as variable
pwd='/vmfs/volumes/isilon-esxisos/nvidia'

#Case/Switch to determine ESXi Version and install appropriate VIB/Package
#Find VMware Version <vmware -v | cut -f3 -d " ">
case $(vmware -v | cut -f3 -d " ") in
  6.5.0)
    esxcli software vib install -d $pwd/Nvidia_4_Series/NVIDIA-VMware_ESXi_6.5_Host_Driver_367.134-1OEM.650.0.0.4598673-offline_bundle.zip
  ;;
  6.7.0)
    esxcli software vib install -d $pwd/Nvidia_8_Series/8.6/NVD.NVIDIA_bootbank_NVIDIA-VMware_418.181-1OEM.670.0.0.8169922-offline_bundle-17270334.zip
  ;;
  7.0.0)
    esxcli software vib install -d $pwd/Nvidia_11_Series/11.2/NVD.NVIDIA_bootbank_NVIDIA-VMware_450.89-1OEM.670.0.0.8169922-offline_bundle-17133261.zip
  ;;
esac

#run Nvidia-smi to verify install
 nvidia-smi 


#Set Host to MaintenanceMode
esxcli system maintenanceMode set --enable false



