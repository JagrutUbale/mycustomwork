# Mycustomwork
-Narayan Ubale

**Run Script as Root user**

* **Web Server Setup for WordPress
Command-line script (Ubuntu 14.04.5 LTS)

*How run
Download wplemp.sh
chmod +x wplemp.sh
./wplemp.sh domainname
Try Below Example
./wplemp.sh domain.example
bash wplemp.sh domain.example

*Benefit: To create multiple WordPress LAMP setup on single with multiple domain/hostname name
bash wplemp.sh domain.example1
bash wplemp.sh domain.example2
bash wplemp.sh domain.example3

* **Blogging Command-Line App
Command-line blogging application using sqlite (Ubuntu 14.04.5 LTS)

**How Use

*Download blog.sh
chmod +x blog.sh
mv blog.sh /usr/local/bin/blog.sh
blog.sh install

*Try Below Example
blog.sh
blog.sh --help 
blog.sh post add title21 content21
blog.sh post list
blog.sh post search content21
blog.sh category add category21
blog.sh category list
blog.sh category assign 2 2
blog.sh post add title22 content22 --category category22
