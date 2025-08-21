
(import (scheme base))
(import (ultrawave base))
(import (ultrawave command))
(import (ultrawave filesystem))

(define minecraft-servers-dir
  "/srv/minecraft")

(define minecraft-setup
  (property-group
   "Preferred minecraft directories and install scripts installed."
   (system-user-exists "minecraft")
   (directory-exists minecraft-servers-dir)
   (apt:packages-installed "default-jre-headless")
   (file-copied-to "units/minecraft/minecraft@.service" "/etc/systemd/system/minecraft@.service")

   (file-copied-to "units/minecraft/start.sh"
                   (string-append minecraft-servers-dir "/start.sh"))
   (file-copied-to "units/minecraft/upgrade.sh"
                   (string-append minecraft-servers-dir "/upgrade.sh"))

   (file-copied-to "units/minecraft/global-banned-ips.json"
                   (string-append minecraft-servers-dir "/global-banned-ips.json"))
   (file-copied-to "units/minecraft/global-banned-players.json"
                   (string-append minecraft-servers-dir "/global-banned-players.json"))
   (file-copied-to "units/minecraft/global-ops.json"
                   (string-append minecraft-servers-dir "/global-ops.json"))
   (file-copied-to "units/minecraft/global-whitelist.json"
                   (string-append minecraft-servers-dir "/global-whitelist.json"))

   (directory-owned-by/rec minecraft-servers-dir "minecraft" "minecraft")))

(define (minecraft-instance-enabled name)

  (define install-dir
    (string-append minecraft-servers-dir "/" name))

  (define (local-config filename)
    (string-append "units/minecraft/" name "/" filename))

  (define (merge-json-files destination . files)
    (shell-command-property
     `(jq -s "'flatten | unique'" ,@files > ,destination)
     (show #f "JSON files merged:" files " into " destination)))

  (define (minecraft-json-config-installed name)

    (define instance-only-conf
      (string-append install-dir "/local-" name))

    (define global-conf
      (string-append minecraft-servers-dir "/global-" name))

    (define target-conf (string-append install-dir "/" name))

    (property-group
     (show #f "Installed minecraft JSON configuration: " name)
     (apt:packages-installed "jq")
     (file-copied-to (local-config name) instance-only-conf)
     (merge-json-files target-conf instance-only-conf global-conf)))

  (property-group
   (show #f "Minecraft '" name "' enabled.")

   minecraft-setup

   (directory-exists install-dir)

   (minecraft-json-config-installed "banned-ips.json")
   (minecraft-json-config-installed "banned-players.json")
   (minecraft-json-config-installed "ops.json")
   (minecraft-json-config-installed "whitelist.json")
                     
   (file-copied-to (local-config "bukkit.yml")
                   (string-append install-dir "/bukkit.yml"))
   (file-copied-to (local-config "commands.yml")
                   (string-append install-dir "/commands.yml"))
   (file-copied-to (local-config "help.yml")
                   (string-append install-dir "/help.yml"))
   (file-copied-to (local-config "permissions.yml")
                   (string-append install-dir "/permissions.yml"))
   (file-copied-to (local-config "spigot.yml")
                   (string-append install-dir "/spigot.yml"))

   (file-copied-to (local-config "eula.txt")
                   (string-append install-dir "/eula.txt"))
   (file-copied-to (local-config "server.properties")
                   (string-append install-dir "/server.properties"))

   (directory-owned-by/rec install-dir "minecraft" "minecraft")

   (services-enabled (string-append "minecraft@" name))
   (services-restarted (string-append "minecraft@" name))))

;;; TODO: Install openjdk automagically
