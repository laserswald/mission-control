
(define mpd-setup
  (property-group "MPD service set up."
   (apt:packages-installed
    "mopidy"
    "mopidy-mpd"
    "mpc"
    "ncmpcpp"
    "gstreamer1.0-tools")
   (pip:packages-installed "Mopidy-Spotify" "Mopidy-Iris")
   (services-enabled "mopidy")))
