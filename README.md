# Cloudia
Personal home cloud eco-system

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

- [ ] Encrypted automated backup system (Duplicati)
- [ ] Password platform (Bitwarden)
- [ ] Activate metrics on Traefik Dashboard (tracing?)

## Note - Must appear in doc

- Dependencies
	- Docker compose
	```bash
		sudo apt-get install -y python3 python3-pip
		sudo pip3 -v install docker-compose
	```
  - Docker Compose volumes problem
  ```bash
    # in /etc/fstab Option to mount your disk
    UUID=uuid /mnt/dir ntfs defaults,auto,users,rw,nofail,umask=000 0 0
  ```
