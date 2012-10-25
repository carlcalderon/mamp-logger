# dependencies
os   = require "os"
fs   = require "fs"
path = require "path"

# paths
MAMP_PATH = "/Applications/MAMP/"
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
    php:    "PHP"
    mysql:  "MySQL"
    apache: "Apache"

# definitions
getBufferSize = (filepath) -> (fs.statSync filepath).size
rtrim  = (string) -> string.replace /\s+$/gi, ""
ltrim  = (string) -> string.replace /^\s+/gi, ""
trim   = (string) -> ltrim rtrim string
echo   = (string) -> console.log trim string
red    = (string) -> `"\033[41m\033[30m" + string + "\033[0m"`
yellow = (string) -> `"\033[43m\033[30m" + string + "\033[0m"`
cyan   = (string) -> `"\033[46m\033[30m" + string + "\033[0m"`
watch  = (id) ->
    fs.watchFile paths[id], watchOptions, (event) ->
        size = getBufferSize paths[id]
        readStream = fs.createReadStream paths[id],
            start: buffer[id]
            end: size
        readStream.addListener "data", (lines) ->
            for line in lines.toString().split os.EOL
                if line isnt "" then echo "[#{title[id]}] " + highlight id, line
            buffer[id] = size
highlight = (id, string) ->
    switch id
        when "php"    then [all, pre, type, content] = /(\[[\s\S]*?\]\sPHP[\s\S]+?(error|notice|warning):)([\s\S]*)/gi.exec string
        when "mysql"  then [all, pre, type, content] = /([\s\S]+?\[(error|note|warning)\])([\s\S]+)/gi.exec string
        when "apache" then [all, pre, type, content] = /(\[[\s\S]*?\]\s\[(error|notice|warn|emerg)\])([\s\S]*)/gi.exec string
        else all = string
    switch String(type).toLowerCase()
        when "error", "emerg"
            all = all.replace pre, red(pre)
        when "warning"
            all = all.replace pre, yellow(pre)
        when "notice"
            all = all.replace pre, cyan(pre)
        else return string
    all.replace content, trim content

# get current buffer sizes
buffer.php    = getBufferSize paths.php
buffer.mysql  = getBufferSize paths.mysql
buffer.apache = getBufferSize paths.apache

# start watching
watch "php"
watch "mysql"
watch "apache"