# Cloudia
Personal home cloud eco-system

![Cloudia](https://static.wikia.nocookie.net/dark-netflix/images/1/18/Claudia_2019.png/revision/latest?cb=20200629193350)

## Todo

- [x] :gear: Self Hosted Cloud system (Nextcloud)
  - [x] Fix PostgresDB file in Hard Disk
- [x] Add basic auth for services
  - Example cred : `user password`
- [x] Torrent searcher and downloader (Autorrent & Transmission)
- [x] Media platform (Jellyfin)
- [x] Auth plateform (Authelia)
  - Example cred : `authelia password`
  - [ ] Add config example to repo

## Not yet w/ Docker Compose

- [ ] Encrypted automated backup system (RClone + script)
- [ ] Dashboard using SUI
- [ ] Evolution of Autorrent
	- [ ] Current research in input
	- [ ] Loading animation
	- [ ] TVShows and Films choice
	- [ ] Not more link in Nav expect its adapting to user host
- [ ] Activate metrics on Traefik Dashboard (tracing?)
- [ ] Script to input env var and secrets

## Note - Must appear in doc

- Dependencies
	- Docker compose installation
	```bash
		sudo apt-get install -y python3 python3-pip
		sudo pip3 -v install docker-compose
	```
	- Rclone TODO

	- Mouting HDD
	```bash
	# in /etc/fstab Option to mount your disk
	UUID=uuid /mnt/dir ext4 defaults 0 0
	```

## Backup - Todo

- Logs in checks
- Rclone install instruction
	```
	curl https://rclone.org/install.sh | sudo bash
	rclone config
	```
- No sudo since key would not be in root folder
	```
	gpg --homedir="/home/pi"
	```
- Remove file after 5 days
	```
	IF rclone --max-age 5d ls Backup_B2:cloud-backup-nelands | wc -l > 3
	THEN rclone --min-age 5d delete Backup_B2:cloud-backup-nelands
	```
- Choice of which folder with names
