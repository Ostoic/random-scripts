# Usage
## Install package scripts to a "bin' directory
To install the scripts associated with a specific package, $PACKAGE_NAME, run the following stow command.
```
stow -t ~/.local/bin/ -R $PACKAGE_NAME
```

## Using the 
### yt-dlp-playlist
This script will first download all the video URLs and put them into the file 
`playlist.txt` in the current working directory. Then it will distribute all of the 
URLs to download to $NJOBS number of parallel download jobs. All of the downloaded 
media is saved in the current working directory.
```
yt-dlp-playlist https://www.youtube.com/list=0123456789
```

