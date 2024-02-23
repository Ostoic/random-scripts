#!/bin/bash

disable-service() {
	powershell Stop-Service $@
	powershell Set-Service -Status stopped -StartupType disabled -Name $@
}

disable-service XboxNetApiSvc
disable-service XblGameSave
disable-service XblAuthManager
disable-service XboxGipSvc
