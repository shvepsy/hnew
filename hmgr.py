#!/usr/bin/python
# req python-mysql.connector
import os, sys, mysql.connector, random

PWLEN = 12

def pwgen():
    wmap = "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    return "".join(random.sample(wmap,PWLEN))

class loadconf:
    config = {
        'user':'root',
        'password': 'rootpassword',
        'host': 'localhost',
        'database': 'hosting',
    }
    def __init__(self):
        self.cnx = mysql.connector.connect(**self.config)
        self.cursor = self.cnx.cursor()
    def test(self):
        query = ("SELECT id, name, php_version, ip FROM domains")
        self.cursor.execute(query)
        return self.cursor

mysqld = loadconf()
lists = mysqld.test()
for (id, name, php_version, ip) in lists:
    print "{}:{}:{}:{}".format(id, name, php_version, ip)

mysqld.cursor.close()
mysqld.cnx.close()

print pwgen()
