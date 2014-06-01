IF EXIST "D:\SteamLibrary\SteamApps\common\dota 2 beta\dota\addons\pudgewars" (
    rmdir "D:\SteamLibrary\SteamApps\common\dota 2 beta\dota\addons\pudgewars" /s /q
)
mkdir "D:\SteamLibrary\SteamApps\common\dota 2 beta\dota\addons\pudgewars"
xcopy /e "Z:\Backup\projects\Dota 2 SDK\mods\pudgewars" "D:\SteamLibrary\SteamApps\common\dota 2 beta\dota\addons\pudgewars"
del "D:\SteamLibrary\SteamApps\common\dota 2 beta\dota\addons\pudgewars\del_and_copy.bat"
del "D:\SteamLibrary\SteamApps\common\dota 2 beta\dota\addons\pudgewars\README.md"