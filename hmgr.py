#!/usr/bin/python
# req python-mysql.connector python-paramiko
# sudo apt-get install software-properties-common ?
import os, sys, mysql.connector, random, paramiko

PWLEN = 12

def pwgen():
    wmap = "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    return "".join(random.sample(wmap,PWLEN))

class servers:
    storageip = 'localhost'
    mysqldip  = 'localhost'
    webip = ['localhost']

    def __init__(self):
        self.key = paramiko.RSAKey.from_private_key_file('../.ssh/id_rsa')
        self.ssh = paramiko.SSHClient()
        self.ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    def install(self,host,packets):
        self.ssh.connect(host, username='root', pkey=self.key)
        stdin, stdout, stderr = self.ssh.exec_command('apt-get install ' + packets + ' -qq')
        err = stderr.read()
        out = stdout.read()
        if not out and err:
            print "ERR " + err
            return 1
            quit()
        elif out and err:
            print "Packets installed"
        else:
            print "Packets already installed"
        return 0
        self.ssh.close

    def install_storage(self):
        pkgs = 'nfs-kernel-server nfs-common vsftpd'
        if self.install(self.storageip,pkgs):
            quit()
        print 'Storage server installation [ \033[32mOK\033[0m ]'

    def install_mysql(self):
        pkgs = 'mysql-server mysql-client'
        if self.install(self.mysqldip,pkgs):
            quit()
        print "Mysql server installation [ \033[32mOK\033[0m ]"

    def install_web(self):
        pkgs = 'apache2'
        f = False
        for ip in self.webip:
            if self.install(ip,pkgs):
                quit()
        print "Web servers installation [ \033[32mOK\033[0m ]"

def installsrv():
    packets = ""

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
        query = ("SELECT id, name, php_version, ip, `ssl`, cert, rsa_key FROM domains")
        self.cursor.execute(query)
        return self.cursor
    def close(self):
        self.cursor.close()
        self.cnx.close()

s = servers()
s.install_storage()
s.install_mysql()
s.install_web()

mysqlh = loadconf()
# lists = mysqlh.test()
# for (id, name, php_version, ip, ssl, cert, key) in lists:
#     print "{}:{}:{}:{}".format(id, name, php_version, ip)
mysqlh.close()
# mysqld.cursor.close()
# mysqld.cnx.close()

print pwgen()
