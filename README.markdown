# Web Server Backup Script

This script makes a local backup of all website files and MySQL databases. I use this in addition to WordPress backups stored remotely with Amazon S3. Three copies of a site is always a good thing (the live site, one local backup, and one remote backup).

Configured for this setup:

* Ubuntu 14.04 x64
* Security managed by [ServerPilot](https://serverpilot.io/)
* Hosted by [DigitalOcean](https://www.digitalocean.com/)