# LPI 010-160 practice exam

LPI 010-160 practice exam using questions from dumps

# Installation

## OS X & Linux:
### wget
```sh
# Install via wget
wget -O lpi_linux.py https://github.com/Noam-Alum/lpi_010_160_exam/blob/main/lpi_linux.py
```
### git clone
```sh
# Install via git clone
git clone --single-branch --branch main --depth 1 https://github.com/Noam-Alum/lpi_010_160_exam.git && mv lpi_010_160_exam/lpi_linux.py . && rm -rf lpi_010_160_exam
```

## Windows:
### wget
```sh
# Install via wget
wget -O lpi_linux.py https://github.com/Noam-Alum/lpi_010_160_exam/blob/main/lpi_win.exe
```
### git clone
```sh
# Install via git clone
git clone --single-branch --branch main --depth 1 https://github.com/Noam-Alum/lpi_010_160_exam.git && move lpi_010_160_exam\lpi_linux.py . && rmdir /s /q lpi_010_160_exam
```

<br>
<hr>
<br>

# Usage example
> This section is reffering to the */etc/make_backup/Make_Backup.conf* file.
## set count
Firstly you need to select a file to count block device entries
```sh
count_location=[/var/test.txt];
```
**This needs to be the full path to a file !** (/path/to/file.txt)

Then you should set count of how many times a block device entries cause a backup:
```sh
bd_count=[5];
```
**This settings cannot be 0 and lower!**

## set backup directory
By default make backup backups to the /tmp directory as a fallback to the main backups directory, to choose the backup directory we need to edit the /etc/make_backup/Make_Backup.conf configuration file.

```sh
parent_directory=[/change/this/to/backkups_dir];
```
Swap /change/this/to/backkups_dir to the actual path to your backups directory *with out the / at the end!*

## choose items to backup
We can add the files and direcotories we want to backup in between this lines:
```sh
> start items to backup <
/backup/this/file.txt
/backup/this/direcotory/
> end items to backup <
```
make sure that direcotories **ends with /** and files **dont!**

## control amount of backups
To control how many backups remain in the choosen backups directory we first need to check if its enables.
```sh
## remove old backups
# yes | no
rm_old_backups=[yes];
```
and make sure its set as ```yes```.

We can change this settings to control how many backups remain in the choosen backups directory like so:
```sh
backup_in_c_month=[14];
backup_in_month=[1];
month_in_c_year=[12];
month_in_year=[1];
```
* backup_in_c_month = the amount of backups in the current month directory.
* backup_in_month = the amount of backups in past months.
* month_in_c_year = the amount of months to leave in past year.
* month_in_year = the amount of months to leave in past year.

## Contact

Noam Alum – [Website](https://ncode.codes) – nnoam.alum@gamil.com
