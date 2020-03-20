Set-Variable winDeploy "C:\Windows\Sun\Java\Deployment\deployment.properties"
Set-Variable cDeploy "C:\deployment.properties"

# validate global config exists
if (Test-Path $winDeploy) {

    # validate security exception line exists
    if (Select-String -Path $winDeploy -Pattern 'sites=') {

        # modify the thing
        Get-Content $winDeploy | ForEach-Object { $_ -Replace '^.*sites=.*$', 'deployment.user.security.exception.sites=C\:\\deployment.properties' } | Set-Content $winDeploy
    }
}

Read-Host "Enter exception address" | Add-Content -Path $cDeploy