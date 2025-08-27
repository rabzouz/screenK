# screenK.ps1 - Outil de mirroring et contrôle Android inspiré de scrcpy

param (
    [string]$serial,      # Serial de l'appareil (ou IP:port pour TCP/IP)
    [switch]$usb,         # Sélectionner USB
    [switch]$tcpip,       # Sélectionner TCP/IP
    [string]$ipAddress,   # Adresse IP pour connexion manuelle
    [switch]$mirror,      # Activer le mirroring avec scrcpy
    [string]$scrcpyArgs = ''  # Arguments optionnels pour scrcpy (ex. : "--bit-rate 8M --audio")
)

# Vérifier si ADB est disponible
if (!(Get-Command adb -ErrorAction SilentlyContinue)) {
    Write-Error "ADB n'est pas installé ou non dans le PATH. Téléchargez-le depuis developer.android.com."
    exit 1
}

# Fonction pour connecter via USB
function Connect-USB {
    adb devices
    Write-Host "Connexion USB établie."
}

# Fonction pour connecter via TCP/IP (améliorée pour extraire correctement l'IP)
function Connect-TCPIP {
    if ($ipAddress) {
        if ($ipAddress -notmatch '\d+\.\d+\.\d+\.\d+') {
            Write-Error "IP invalide : utilisez un format comme 192.168.1.100"
            return
        }
        adb connect "$ipAddress:5555"
        Write-Host "Connexion TCP/IP à $ipAddress:5555."
    } else {
        # Méthode automatique : extraire l'IP correcte (après 'src') via ADB
        $routeOutput = adb shell ip route
        $deviceIp = ($routeOutput | Select-String -Pattern 'src (\d+\.\d+\.\d+\.\d+)') -replace '.*src (\d+\.\d+\.\d+\.\d+).*', '$1'
        if (-not $deviceIp) {
            Write-Error "Impossible d'extraire l'IP. Vérifiez la connexion USB et le réseau Wi-Fi. Utilisez -ipAddress manuellement."
            return
        }
        adb tcpip 5555
        adb connect "$deviceIp:5555"
        Write-Host "Connexion TCP/IP automatique à $deviceIp:5555."
    }
}

# Contrôle basique (ex. : envoyer une touche)
function Control-Device {
    param ([string]$key)
    adb shell input keyevent $key
    Write-Host "Touche envoyée : $key"
}

# Fonction pour démarrer le mirroring avec scrcpy
function Start-Mirroring {
    $scrcpyPath = Join-Path $PSScriptRoot 'scrcpy\scrcpy.exe'
    if (-Not (Test-Path $scrcpyPath)) {
        Write-Error "scrcpy.exe non trouvé dans $PSScriptRoot\scrcpy. Téléchargez-le depuis github.com/Genymobile/scrcpy."
        return
    }
    $serialOpt = if ($serial) { "--serial=$serial" } elseif ($ipAddress) { "--serial=$ipAddress:5555" } else { '' }
    & $scrcpyPath $serialOpt $scrcpyArgs
    Write-Host "Mirroring lancé. Fermez la fenêtre pour arrêter."
}

# Logique principale
if ($usb) { Connect-USB }
elseif ($tcpip) { Connect-TCPIP }
else { Write-Host "Utilisation : screenK.ps1 -usb ou -tcpip [-ipAddress IP] [-mirror] [-scrcpyArgs 'args']" }

if ($mirror) { Start-Mirroring }
else { Control-Device -key "KEYCODE_HOME" }
