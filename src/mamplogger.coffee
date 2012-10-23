# dependencies
fs   = require "fs"
path = require "path"

# paths
MAMP_PATH       = "/Applications/MAMP/"
paths =
    php:    path.resolve MAMP_PATH, "logs/php_error.log"
    mysql:  path.resolve MAMP_PATH, "logs/mysql_error_log.err"
    apache: path.resolve MAMP_PATH, "logs/apache_error.log"

# statics
watchOptions =
    persistent: yes

# buffers
buffer =
    php:    0
    mysql:  0
    apache: 0

# titles
title =
    php: "PHP"
    mysql: "MySQL"
    apache: "Apache"

# definitions
getBufferSize = (filepath) -> (fs.statSync filepath).size
rtrim = (string) -> string.replace /\s$/gi, ""
watch = (id) ->
    fs.watchFile paths[id], watchOptions, (event) ->
        size = getBufferSize paths[id]
        readStream = fs.createReadStream paths[id],
            start: buffer[id]
            end: size
        readStream.addListener "data", (lines) ->
            echo "[#{title[id]}] " + do lines.toString
            buffer[id] = size

echo = (string) ->
    console.log rtrim string
# program

# get current buffer sizes
buffer.php    = getBufferSize paths.php
buffer.mysql  = getBufferSize paths.mysql
buffer.apache = getBufferSize paths.apache

watch "php"
watch "mysql"
watch "apache"