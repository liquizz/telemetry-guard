param (
    [Parameter(Mandatory=$false)]
    [ValidateSet("major", "minor", "patch")]
    [string]$BumpType,
    
    [Parameter(Mandatory=$false)]
    [switch]$Display
)

function Get-ProjectVersion {
    $csprojPath = Join-Path $PSScriptRoot '..\TelemetryGuardService\TelemetryGuardService\TelemetryGuardService.csproj'
    [xml]$csproj = Get-Content $csprojPath
    
    $versionNode = $csproj.Project.PropertyGroup.Version
    
    if (-not $versionNode) {
        $propertyGroup = $csproj.Project.PropertyGroup
        $version = "1.0.0"
        
        $versionElement = $csproj.CreateElement("Version")
        $versionElement.InnerText = $version
        $propertyGroup[0].AppendChild($versionElement) | Out-Null
        
        $csproj.Save($csprojPath)
        return $version
    }
    
    return $versionNode
}

function Set-ProjectVersion {
    param (
        [string]$NewVersion
    )
    
    $csprojPath = Join-Path $PSScriptRoot '..\TelemetryGuardService\TelemetryGuardService\TelemetryGuardService.csproj'
    [xml]$csproj = Get-Content $csprojPath
    
    $versionNode = $csproj.Project.PropertyGroup.Version
    
    if (-not $versionNode) {
        $propertyGroup = $csproj.Project.PropertyGroup
        $versionElement = $csproj.CreateElement("Version")
        $versionElement.InnerText = $NewVersion
        $propertyGroup[0].AppendChild($versionElement) | Out-Null
    } else {
        $csproj.Project.PropertyGroup.Version = $NewVersion
    }
    
    $csproj.Save($csprojPath)
    Write-Host "Project version updated to $NewVersion"
}

function Bump-Version {
    param (
        [string]$CurrentVersion,
        [string]$BumpType
    )
    
    $parts = $CurrentVersion.Split('.')
    $major = [int]$parts[0]
    $minor = [int]$parts[1]
    $patch = [int]$parts[2]
    
    switch ($BumpType) {
        "major" { 
            $major++
            $minor = 0
            $patch = 0
        }
        "minor" { 
            $minor++
            $patch = 0
        }
        "patch" { 
            $patch++
        }
    }
    
    return "$major.$minor.$patch"
}

# Main script logic
$currentVersion = Get-ProjectVersion

if ($Display) {
    Write-Host "Current version: $currentVersion"
    return
}

if ($BumpType) {
    $newVersion = Bump-Version -CurrentVersion $currentVersion -BumpType $BumpType
    Set-ProjectVersion -NewVersion $newVersion
    
    Write-Host "`nNext steps:"
    Write-Host "1. Commit your changes:"
    Write-Host "   git add ."
    Write-Host "   git commit -m ""Bump version to $newVersion"""
    Write-Host "2. Create a version tag:"
    Write-Host "   git tag -a v$newVersion -m ""Version $newVersion"""
    Write-Host "3. Push changes and tags:"
    Write-Host "   git push"
    Write-Host "   git push --tags"
} else {
    Write-Host "Current version: $currentVersion"
    Write-Host "`nTo bump version, use one of these commands:"
    Write-Host "   .\Scripts\version.ps1 -BumpType major  # For breaking changes (x.0.0)"
    Write-Host "   .\Scripts\version.ps1 -BumpType minor  # For new features (0.x.0)"
    Write-Host "   .\Scripts\version.ps1 -BumpType patch  # For bug fixes (0.0.x)"
} 