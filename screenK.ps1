# screenK.ps1 - Outil de mirroring et contrôle Android inspiré de scrcpy

param (
    [string]$serial,      # Serial de l'appareil (ou IP:port pour TCP/IP)
    [switch]$usb,         # Sélectionner USB
    [switch]$tcpip,       # Sélectionner TCP/IP
    [string]$ipAddress    # Adresse IP pour connexion manuelle
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
    # Ajouter ici du code pour mirroring (ex. : lancer scrcpy si intégré)
}

# Fonction pour connecter via TCP/IP (inspiré de connection.md)
function Connect-TCPIP {
    if ($ipAddress) {
        adb connect $ipAddress:5555
        Write-Host "Connexion TCP/IP à $ipAddress:5555."
    } else {
        # Méthode automatique : trouver IP via ADB
        $deviceIp = adb shell ip route | ForEach-Object { if ($_ -match '\d+\.\d+\.\d+\.\d+') { $matches[0] } }
        adb tcpip 5555
        adb connect $deviceIp:5555
        Write-Host "Connexion TCP/IP automatique à $deviceIp:5555."
    }
}

# Contrôle basique (ex. : envoyer une touche)
function Control-Device {
    param ([string]$key)
    adb shell input keyevent $key
    Write-Host "Touche envoyée : $key"
}

# Logique principale
if ($usb) { Connect-USB }
elseif ($tcpip) { Connect-TCPIP }
else { Write-Host "Utilisation : screenK.ps1 -usb ou -tcpip [-ipAddress IP]" }

# Exemple de contrôle
Control-Device -key "KEYCODE_HOME"

# TODO : Intégrer mirroring vidéo/audio (ex. : appeler scrcpy.exe ou implémenter avec FFmpeg)
