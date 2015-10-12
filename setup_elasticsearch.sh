#!/usr/bin/env sh


# Setup elasticsearch
wget https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.7.2.deb
dpkg -i elasticsearch-1.7.2.deb
bin/plugin -i elasticsearch/marvel/latest
bin/plugin -i mobz/elasticsearch-head


echo "Settings for JishoPi:" >> /etc/elasticsearch/elasticsearch.yml
echo "  index.number_of_shards: 1" >> /etc/elasticsearch/elasticsearch.yml
echo "  index.number_of_replicas: 0" >> /etc/elasticsearch/elasticsearch.yml
# This is only necessary if you're going to host the HTML file somewhere else
# echo "  http.cors.enabled: true" >> /etc/elasticsearch/elasticsearch.yml

update-rc.d elasticsearch defaults
/etc/init.d/elasticsearch start

wget -O - http://ftp.monash.edu.au/pub/nihongo/edict2u.gz | gunzip -c > edict2u
chown pi:pi edict2u

echo
echo "You're all done! Now run `ruby reindex_edict.rb` to index it."
