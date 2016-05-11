FROM ubuntu:14.04

# Install apache, mysql, php and other needed apps
RUN mkdir -p /tmp/smw && echo "mysql-server mysql-server/root_password select CHANGE_THIS" | debconf-set-selections && \
  echo "mysql-server mysql-server/root_password_again select CHANGE_THIS" | debconf-set-selections && \
  apt-get update && apt-get upgrade -y && apt-get install -y \
  vim \
  wget \
  curl \
  git \
  apache2 \
  mysql-server \
  php5 \
  libapache2-mod-php5 \
  php5-mysql \
  php5-cli \
  php5-gd \
  php5-xdebug \
  php5-json \
  php5-xsl


# install mediawiki
RUN  cd /var/www/html \
  && wget https://releases.wikimedia.org/mediawiki/1.26/mediawiki-1.26.2.tar.gz \
  && tar -zxvf mediawiki-1.26.2.tar.gz \
  && rm mediawiki-1.26.2.tar.gz \
  && mv mediawiki-1.26.2/ mw126

COPY backup.sql /tmp/smw/backup.sql

# start apache and mysql
# create database and  restore initial database for mediawiki
RUN service mysql restart \
  && mysql -uroot -pUMSL1234! -e "CREATE DATABASE mw126;" \
  && mysql -uroot -pUMSL1234! -e "CREATE USER mw126@localhost IDENTIFIED by 'CHANGE_THIS';" \
  && mysql -uroot -pUMSL1234! -e "GRANT ALL ON mw126.* TO mw126@localhost;" \
  && mysql -u root -pUMSL1234! mw126 < /tmp/smw/backup.sql

COPY UMSL_Tritons_Logo.png /var/www/html/mw126/resources/assets/UMSL_Tritons_Logo.png

COPY LocalSettings.php /var/www/html/mw126/LocalSettings.php

COPY Pages/* /tmp/smw/

# install composer
RUN cd /var/www/html/mw126 \
  && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php -r "if (hash_file('SHA384', 'composer-setup.php') === '92102166af5abdb03f49ce52a40591073a7b859a86e8ff13338cf7db58a19f7844fbc0bb79b2773bf30791e935dbd938') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
  && php composer-setup.php \
  && php -r "unlink('composer-setup.php');"

# install SMW, # create sysops users and regular users, # add pages
RUN service mysql restart \
  && cd /var/www/html/mw126 \
  && php composer.phar require mediawiki/semantic-media-wiki "~2.3" --update-no-dev \
  && php maintenance/update.php \
  && php maintenance/createAndPromote.php --bureaucrat --sysop --custom-groups=administrator gig CHANGE_THIS \
  && php maintenance/createAndPromote.php --bureaucrat --sysop --custom-groups=administrator geoff CHANGE_THIS \
  && php maintenance/createAndPromote.php kerrine CHANGE_THIS \
  && php maintenance/createAndPromote.php ankit CHANGE_THIS \
  && php maintenance/edit.php -m "Main_Page" < /tmp/smw/main_page \
  && php maintenance/edit.php -m "Project Summary" < /tmp/smw/initial \
  && php maintenance/edit.php -m "Calendar" < /tmp/smw/calendar \
  && php maintenance/edit.php -m "Course Syllabus and Tools" < /tmp/smw/initial \
  && php maintenance/edit.php -m "Ontologies and Vocabs" < /tmp/smw/initial \
  && php maintenance/edit.php -m "Data Model" < /tmp/smw/initial \
  && php maintenance/edit.php -m "Discovery Processes" < /tmp/smw/initial \
  && php maintenance/edit.php -m "Presentation Processes" < /tmp/smw/initial \
  && php maintenance/edit.php -m "Visualization Processes" < /tmp/smw/initial \
  && php maintenance/edit.php -m "Sharing Processes" < /tmp/smw/initial \
  && php maintenance/edit.php -m "Analysis of Results" < /tmp/smw/initial \
  && php maintenance/edit.php -m "Sample Queries" < /tmp/smw/initial \
  && php maintenance/edit.php -m "Lessons Learned" < /tmp/smw/initial \
  && php maintenance/edit.php -m "Next Steps" < /tmp/smw/initial \
  && php maintenance/edit.php -m "Team Members and Blogs" < /tmp/smw/initial \
  && php maintenance/edit.php -m "User_talk:Ankit" < /tmp/smw/initial \
  && php maintenance/edit.php -m "User_talk:Kerrine" < /tmp/smw/initial \
  && php maintenance/edit.php -m "User_talk:Geoff" < /tmp/smw/initial \
  && php maintenance/edit.php -m "User_talk:Gig" < /tmp/smw/initial \
  && php maintenance/edit.php -m "Article" < /tmp/smw/initial

COPY startup.sh /tmp/smw/

EXPOSE 80 443

CMD ["/bin/bash", "/tmp/smw/startup.sh"]
