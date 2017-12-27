#!/bin/bash
if [[ $EUID -ne 0 ]]; then
	echo "Script run as root user" 
	exit 1
fi

if [ $# -eq 0 ]
then
	echo "Application SQLite blog.sh "
elif [ $1 == "install" ]
then
	echo "Setup Pre- requirement"
	touch /tmp/tasks 
	apt-get update >> /tmp/tasks
	apt-get -yy install sqlite3 libsqlite3-dev >> /tmp/tasks

	#Temp dump  db
	sqlite3 testdb.db  "create table category (cat_id INTEGER PRIMARY KEY AUTOINCREMENT,category TEXT UNIQUE);"   >> /tmp/tasks
	sqlite3 testdb.db  "create table post (postid INTEGER PRIMARY KEY AUTOINCREMENT,title TEXT UNIQUE,content TEXT,cat_id INTEGER NULL, FOREIGN KEY(cat_id) REFERENCES category(cat_id));"   >> /tmp/tasks
	sqlite3 testdb.db  "insert into category (category) values ('category1');"   >> /tmp/tasks
	sqlite3 testdb.db  "insert into post (title,content) values ('title1','content1');"   >> /tmp/tasks
	sqlite3 testdb.db  "select * from post";   >> /tmp/tasks
	sqlite3 testdb.db  "select * from category";   >> /tmp/tasks
	sqlite3 testdb.db "UPDATE post SET cat_id = 1 WHERE postid = 1;"   >> /tmp/tasks
	sqlite3 testdb.db "SELECT * FROM post INNER JOIN category ON post.cat_id = category.cat_id;"   >> /tmp/tasks
	sqlite3 testdb.db "SELECT * FROM post WHERE content LIKE '%con%';"   >> /tmp/tasks

elif [ $1 == "--help" ]
then
	echo "App SQLite blog.sh Help command"
	echo "Usage: blog.sh [OPTION/post/category]...[Sub-OPTION/Add/List]"
	echo "blog.sh --help :List help text and commands available"
	echo "blog.sh post add title content :Add a new blog with post"
	echo "blog.sh post list :List all blog posts"
	echo "blog.sh post search keyword :List all blog posts where keyword: is found in content"
	echo "blog.sh category add category-name :Create a new category"
	echo "blog.sh category list :List all categories"
	echo "blog.sh category assign <post-id> <cat-id> :Assign category to a post"
	echo "blog.sh post add title content --category cat-name :Add a new blog with post,category options"
elif [[ $1 == 'post' && $2 == 'add' && $5 == '--category' ]]
then
	sqlite3 testdb.db  "insert into category (category) values (\"$6\");" 
	sqlite3 testdb.db  "insert into post (title,content,cat_id) values (\"$3\",\"$4\", (SELECT cat_id FROM category WHERE category = \"$6\") );"
elif [[ $1 == "post" && $2 == "add" ]]
then
	sqlite3 testdb.db  "insert into post (title,content) values (\"$3\",\"$4\");"
elif [[ $1 == "post" && $2 == "list" ]]
then
	sqlite3 testdb.db  "select * from post";
elif [[ $1 == "post" && $2 == "search" ]]
then
	sqlite3 testdb.db "SELECT * FROM post WHERE content LIKE \"$3\" ;"
elif [[ $1 == "category" && $2 == "add" ]]
then
	sqlite3 testdb.db  "insert into category (category) values (\"$3\");"
elif [[ $1 == "category" && $2 == "list" ]]
then
	sqlite3 testdb.db  "select * from category";
elif [[ $1 == "category" && $2 == "assign" ]]
then
	sqlite3 testdb.db "UPDATE post SET cat_id = $3 WHERE postid = $4 ;"
	sqlite3 testdb.db "SELECT * FROM post INNER JOIN category ON post.cat_id = category.cat_id;"
else
	echo "Someting Wrong to Paramter."
fi
