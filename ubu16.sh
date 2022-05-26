IPADDR=$(echo "${SSH_CONNECTION}" | awk '{print $3}')
SAVE='/root/hosting.txt'
install_hosting()
{
apt-get update
apt-get install -y apt-utils dialog sudo pwgen
MYPASS=$(pwgen -cns -1 12)
apt-get install -y software-properties-common python-software-properties
sudo add-apt-repository ppa:ondrej/php
apt-get update
apt-get install -y apache2 php5.6 php5.6-mbstring php5.6-mysql php5.6-gd php5.6-xml cron unzip memcached libapache2-mod-php5.6 
apt-get install -y php-ssh2 lib32stdc++6 openssh-server python3 screen
echo mysql-server mysql-server/root_password select "$MYPASS" | debconf-set-selections
echo mysql-server mysql-server/root_password_again select "$MYPASS" | debconf-set-selections
apt-get install -y mysql-server
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-user string root" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $MYPASS" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $MYPASS" |debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $MYPASS" | debconf-set-selections
echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2' | debconf-set-selections
apt-get install -y phpmyadmin
mv /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/.000-default.conf
FILE='/etc/apache2/sites-available/000-default.conf'
	echo "<VirtualHost *:80>">$FILE
	echo "	ServerName $IPADDR">>$FILE
	echo "	DocumentRoot /var/www">>$FILE
	echo "	<Directory /var/www/>">>$FILE
	echo "	Options Indexes FollowSymLinks MultiViews">>$FILE
	echo "	AllowOverride All">>$FILE
	echo "	Order allow,deny">>$FILE
	echo "	allow from all">>$FILE
	echo "	</Directory>">>$FILE
	echo "	ErrorLog \${APACHE_LOG_DIR}/error.log">>$FILE
	echo "	LogLevel warn">>$FILE
	echo "	CustomLog \${APACHE_LOG_DIR}/access.log combined">>$FILE
	echo "</VirtualHost>">>$FILE
a2enmod rewrite
a2enmod php5.6
wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.zip
unzip ioncube_loaders_lin_x86-64.zip
cp ioncube/ioncube_loader_lin_5.5.so /usr/lib/php5/20121212/ioncube_loader_lin_5.5.so
rm -R ioncube*
echo "zend_extension=ioncube_loader_lin_5.5.so">>"/etc/php5/apache2/php.ini"
echo "zend_extension=ioncube_loader_lin_5.5.so">>"/etc/php5/cli/php.ini"
apt-get update
service cron restart
service apache2 restart
cd ~
mysql -uroot -p$MYPASS -e "CREATE DATABASE game CHARACTER SET utf8 COLLATE utf8_general_ci;"
chown -R www-data:www-data /var/www/
chmod -R 775 /var/www/
cd /var/www/
rm -R html
rm index.html
ln -s /usr/share/phpmyadmin /var/www/phpmyadmin
cd /root
touch hosting.txt
groupadd gameservers
clear 
service apache2 restart
service mysql restart
echo "Данные для входа:">>$SAVE
echo "Адрес: http://$IPADDR/">>$SAVE
echo "phpMyAdmin: http://$IPADDR/phpmyadmin">>$SAVE
echo "Логин: root">>$SAVE
echo "Пароль: $MYPASS">>$SAVE
echo "">>$SAVE
echo "================ Установка успешно завершена ================"
echo "Данные для входа:"
echo "Адрес: http://$IPADDR/"
echo "phpMyAdmin: http://$IPADDR/phpmyadmin"
echo "Логин: root"
echo "Пароль: $MYPASS"
echo "Так-же данные были сохранены в файле: /root/hosting.txt"
echo "======================================================================="
}
install_servers()
{
	dpkg --add-architecture i386 
	apt-get update -y
	apt-get install -y screen
	apt-get install -y python3
	apt-get install -y openssh-server
	apt-get install -y lib32stdc++6
	apt-get install -y unzip
	apt-get install -y wget
	groupadd gameservers
	apt-get install -y pure-ftpd
	echo "yes" > /etc/pure-ftpd/conf/ChrootEveryone
	echo "yes" > /etc/pure-ftpd/conf/CreateHomeDir
	echo "yes" > /etc/pure-ftpd/conf/DontResolve
	echo "DenyGroups gameservers" >> /etc/ssh/sshd_config
	service ssh restart
	service pure-ftpd restart
	cd /home/
	wget $GAMES/cp.zip
	unzip cp.zip
	rm cp.zip
	chmod 700 /home/cp/
	chmod 700 /home/cp/gameservers.py
	chmod 700 /home/cp/backup.sh
	clear
	menu
}
add_locations()
{
	echo "Таблица для добавления локаций обязательно должна иметь название 'locations'"
	read -p "Введите пароль от phpMyAdmin: " PMA_PASS
	read -p "Введите название базы(game,hostin): " BD_NAME
	read -p "Введите номер локации: " LOCATION_ID
	read -p "Введите название локации(Москва,Киев): " LOCATION_NAME
	read -p "Введите IP-адрес локации(1.1.1.1): " LOCATION_IP
	read -p "Введите имя пользователя(root): " LOCATION_USER
	read -p "Введите пароль пользователя: " LOCATION_PASSWORD
	read -p "Введите статус локации(1-вкл;0-выкл): " LOCATION_STATUS
	mysql -uroot -p$PMA_PASS -D $BD_NAME -e "INSERT INTO locations (location_id, location_name, location_ip, location_ip2, location_user, location_password, location_status) VALUES ('$LOCATION_ID', '$LOCATION_NAME', '$LOCATION_IP', '$LOCATION_IP', '$LOCATION_USER', '$LOCATION_PASSWORD', '$LOCATION_STATUS');"
	clear
	menu
}
install_games()
{
	clear
	echo "Список доступных игр"
	echo "• 1 ♦ Multi Theft Auto [Версия: 1.5.5]"
	echo "• 2 ♦ San Andreas Multiplayer [Версия: 0.3.7-R2]"
	echo "• 3 ♦ Crminal Russia Multiplayer [Версия: 0.3e]"
	echo "• 4 ♦ Counter-Strike 1.6 [Версия: ReHLHDS]"
	echo "• 5 ♦ Counter-Strike Source v34 [Версия: Last]"
	echo "• 0 ♦ В главное меню"
	read -p "Пожалуйста, введите пункт меню: " case
	case $case in
		1)
			mkdir -p /home/cp/gameservers/files/
			cd /home/cp/gameservers/files/
			wget $GAMES/mta.tar
			mkdir -p /home/cp/gameservers/configs/
			cd /home/cp/gameservers/configs/
			wget $GAMES/mta.cfg
			install_games
		;;
		2)
			mkdir -p /home/cp/gameservers/files/
			cd /home/cp/gameservers/files/
			wget $GAMES/samp.tar
			mkdir -p /home/cp/gameservers/configs/
			cd /home/cp/gameservers/configs/
			wget $GAMES/samp.cfg
			install_games
		;;
		3)
			mkdir -p /home/cp/gameservers/files/
			cd /home/cp/gameservers/files/
			wget $GAMES/crmp.tar
			mkdir -p /home/cp/gameservers/configs/
			cd /home/cp/gameservers/configs/
			wget $GAMES/crmp.cfg
			install_games
		;;
		4)
			mkdir -p /home/cp/gameservers/files/
			cd /home/cp/gameservers/files/
			wget $GAMES/cs.tar
			mkdir -p /home/cp/gameservers/configs/
			cd /home/cp/gameservers/configs/
			wget $GAMES/cs.cfg
			install_games
		;;
		5)
			mkdir -p /home/cp/gameservers/files/
			cd /home/cp/gameservers/files/
			wget $GAMES/css.tar
			mkdir -p /home/cp/gameservers/configs/
			cd /home/cp/gameservers/configs/
			wget $GAMES/css.cfg
			install_games
		;;
		0) menu;;
	esac
}
add_games()
{
	echo "Таблица для добавления игр обязательно должна иметь название 'games'"
	read -p "Введите пароль от phpMyAdmin: " PMA_PASS
	read -p "Введите название базы(game,hostin): " BD_NAME
	read -p "Введите номер игры: " GAME_ID
	read -p "Введите название игры(example: SA-MP 0.3.7-R2): " GAME_NAME
	read -p "Введите код игры(example: samp,crmp): " GAME_CODE
	read -p "Введите query-драйвер игры(example: samp,valve): " GAME_QUERY
	read -p "Введите минимальные слоты для покупки(example: 50): " GAME_MIN_SLOTS
	read -p "Введите максимальные слоты для покупки(example: 1000): " GAME_MAX_SLOTS
	read -p "Введите минимальный порт игры(example: 7777): " GAME_MIN_PORT
	read -p "Введите максимальный порт игры(example: 9999): " GAME_MAX_PORT
	read -p "Введите цену за слот сервера игры(example: 1): " GAME_PRICE
	read -p "Введите статус игры(1-вкл;0-выкл): " GAME_STATUS
	mysql -uroot -p$PMA_PASS -D $BD_NAME -e "INSERT INTO games (game_id, game_name, game_code, game_query, game_min_slots, game_max_slots, game_min_port, game_max_port, game_price, game_status) VALUES ('$GAME_ID', '$GAME_NAME', '$GAME_CODE', '$GAME_QUERY', '$GAME_MIN_SLOTS', '$GAME_MAX_SLOTS', '$GAME_MIN_PORT', '$GAME_MAX_PORT', '$GAME_PRICE', '$GAME_STATUS');"
	clear
	menu
}
menu()
{
	clear
	echo "Настройка VDS под хостинг игровых серверов для Ubuntu 16.04 (amd64)"
	echo "- 1 - Настроить VDS для веб-части хостинга"
	echo "- 2 - Настроить VDS под игры"
	echo "- 3 - Добавление локаций"
	echo "- 4 - Установка игр"
	echo "- 5 - Добавление игр в панель"
	echo "- 0 - Выход"
	echo
	read -p "Пожалуйста, введите пункт меню: " case
	case $case in
		1) install_hosting;; 
		2) install_servers;;
		3) add_locations;;
		4) install_games;;
		5) add_games;;
		0) exit;;
	esac
}
menu