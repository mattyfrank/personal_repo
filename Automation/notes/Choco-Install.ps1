net use \\gt-repo.ad.gatech.edu\configs$
# use ad\matthew

#Traditional RDSH
Set-ExecutionPolicy Bypass -Scope Process -Force; & '\\gt-repo.ad.gatech.edu\configs$\vlab-covid-rdsh.ps1'

#WVD Specific Installer
Set-ExecutionPolicy Bypass -Scope Process -Force; & '\\gt-repo.ad.gatech.edu\configs$\vlab-covid-wvd

