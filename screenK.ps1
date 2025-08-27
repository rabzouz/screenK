# screenK.ps1 – Affichage & contrôle Android (wrapper scrcpy)

param(
    [string]$serial,                 # Série ou IP:PORT déjà connue
    [switch]$usb,                    # Forcer la connexion USB
    [switch]$tcpip,                  # Activer/établir TCP/IP
    [string]$ipAddress,              # IP manuelle (ex. 192.168.1.100)
    [switch]$mirror,                 # Lancer scrcpy (miroir)
    [string]$scrcpyArgs = ''         # Options scrcpy : "--bit-rate 8M --audio" …
)

# ── 1. Vérification ADB ─────────────────────────────────────────────
if (-not (Get-Command adb -ErrorAction SilentlyContinue)) {
    Write-Error 'ADB introuvable ; ajoutez platform-tools au PATH.'
    exit 1
}

# ── 2. Connexion USB ────────────────────────────────────────────────
function Connect-USB {
    adb devices
    Write-Host 'Connexion USB établie.'
}

# ── 3. Connexion TCP/IP ─────────────────────────────────────────────
function Connect-TCPIP {
    if ($ipAddress) {
        if ($ipAddress -notmatch '^\d+\.\d+\.\d+\.\d+$') {
            Write-Error 'IP invalide (ex. 192.168.1.100).'
            return
        }
        adb connect "$ipAddress:5555"
        Write-Host "Connexion TCP/IP à $ipAddress:5555."
    } else {
        $route   = adb shell ip route
        $deviceIp = ($route | Select-String 'src (\d+\.\d+\.\d+\.\d+)') `
                    -replace '.*src (\d+\.\d+\.\d+\.\d+).*', '$1'
        if (-not $deviceIp) {
            Write-Error 'IP introuvable ; utilisez -ipAddress.'
            return
        }
        adb tcpip 5555
        adb connect "$deviceIp:5555"
        Write-Host "Connexion TCP/IP automatique à $deviceIp:5555."
    }
}

# ── 4. Contrôle simple (HOME par défaut) ────────────────────────────
function Control-Device {
    param([string]$key = 'KEYCODE_HOME')
    adb shell input keyevent $key
}

# ── 5. Lancement scrcpy ─────────────────────────────────────────────
function Start-Mirroring {
    $scrcpyPath = Join-Path $PSScriptRoot 'scrcpy\scrcpy.exe'
    if (-not (Test-Path $scrcpyPath)) {
        Write-Error "scrcpy.exe manquant dans $($scrcpyPath | Split-Path -Parent)."
        return
    }

    # Construction propre de la liste d’arguments
    $args = @()
    if     ($serial)    { $args += "--serial=$serial" }
    elseif ($ipAddress) { $args += "--serial=$ipAddress:5555" }

    if (-not [string]::IsNullOrWhiteSpace($scrcpyArgs)) {
        $args += ($scrcpyArgs -split '\s+')
    }

    & $scrcpyPath @args
    Write-Host 'Mirroring lancé ; fermez la fenêtre scrcpy pour quitter.'
}

# ── 6. Logique principale ───────────────────────────────────────────
if     ($usb)   { Connect-USB }
elseif ($tcpip) { Connect-TCPIP }
else  { Write-Host "Usage : -usb | -tcpip [-ipAddress] [-mirror] [-scrcpyArgs '...']" }

if ($mirror) { Start-Mirroring } else { Control-Device }
