Clear-Host
Write-Host "=======================================" -ForegroundColor Red
Write-Host " AVEC CELA TU PEUX REGARDER LE FUCKING " -ForegroundColor Red
Write-Host "        YOUTUBE DANS TON TERMINAL      " -ForegroundColor White
Write-Host "=======================================" -ForegroundColor Red

# --- RECHERCHE AUTOMATIQUE DU LECTEUR VIDEO ---
$mpvPath = $null
if (Get-Command "mpvnet" -ErrorAction SilentlyContinue) { $mpvPath = "mpvnet" }
elseif (Get-Command "mpv" -ErrorAction SilentlyContinue) { $mpvPath = "mpv" }
elseif (Test-Path "$env:LOCALAPPDATA\Programs\mpv.net\mpvnet.exe") { $mpvPath = "$env:LOCALAPPDATA\Programs\mpv.net\mpvnet.exe" }
elseif (Test-Path "C:\Program Files\mpv.net\mpvnet.exe") { $mpvPath = "C:\Program Files\mpv.net\mpvnet.exe" }
elseif (Test-Path "C:\Program Files (x86)\mpv.net\mpvnet.exe") { $mpvPath = "C:\Program Files (x86)\mpv.net\mpvnet.exe" }

if (-not $mpvPath) {
    Write-Host "Erreur critique : Impossible de trouver mpvnet sur l'ordinateur." -ForegroundColor Red
    exit
}
# ----------------------------------------------

$query = Read-Host "`nQue voulez-vous regarder (mots-cles ou URL YouTube) ?"

if ([string]::IsNullOrWhiteSpace($query)) {
    Write-Host "La recherche est vide." -ForegroundColor Red
    exit
}

$targetUrl = ""

# Etape 1 : Recuperer l'URL (Lien direct ou via la recherche optimisee)
if ($query -match "^https?://") {
    $targetUrl = $query
    Write-Host "`nLien direct detecte !" -ForegroundColor Yellow
} else {
    Write-Host "`nRecherche de '$query' en cours (cela peut prendre quelques secondes)..." -ForegroundColor Yellow
    
    # Commande de recherche ultra-optimisee sa mère (vitesse max)
    $results = yt-dlp --print "%(title)s ::: %(id)s" --flat-playlist --force-ipv4 --no-warnings "ytsearch10:$query" 2>$null

    if (-not $results) {
        Write-Host "Aucun resultat trouve ou erreur de connexion." -ForegroundColor Red
        exit
    }

    $selected = $results | fzf --prompt="Selectionnez une video (Entree = Valider, Echap = Quitter) : " --delimiter=" ::: " --with-nth=1

    if ($selected) {
        $videoId = ($selected -split " ::: ")[1]
        $targetUrl = "https://www.youtube.com/watch?v=$videoId"
    } else {
        Write-Host "Recherche annulee." -ForegroundColor DarkGray
        exit
    }
}

# Etape 2 : Demander le mode d'affichage et lancer la video
if ($targetUrl) {
    Write-Host "`nComment voulez-vous regarder la video ?" -ForegroundColor Cyan
    Write-Host "1. Normale (Fenetre classique - Haute qualite)"
    Write-Host "2. ASCII (Dans le terminal en texte - Chargement instantane)"
    $mode = Read-Host "Votre choix (1 ou 2)"

    Clear-Host
    Write-Host "Lancement de la video..." -ForegroundColor Green
    Write-Host "Controles : Espace (Pause), Fleches (Avancer/Reculer), Q (Quitter), F (Plein ecran)" -ForegroundColor Cyan
    
    if ($mode -eq "2") {
        # Qualite basse forcée pour que le mode ASCII charge instantane-ment
        & $mpvPath --vo=tct "--ytdl-format=worst" $targetUrl | Out-Null
    } else {
        # Lancement normal haute qualite
        & $mpvPath $targetUrl | Out-Null
    }
}