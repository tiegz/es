### 辞書Pi /　じしょPi / jishoPi

This is a small library that demonstrates how to:

  * install Elasticsearch on a Raspberry Pi
  * index a Japanese/English dictionary (ie EDICT2)
  * host a simple ajax search page to query the dictionary

### STEPS

#### 1) Setup Raspbian on your Raspberry Pi, and connect it to your local wifi network

There are numerous tutorials on the net for downloading, flashing, and setting up the Pi.

#### 2) Ensure git and apache installed:

``` shell
sudo apt-get update
sudo apt-get install git apache2 -y
```

#### 3) Clone this repo:

``` shell
cd ~
git clone https://github.com/tiegz/jisho_pi.git
cd jisho_pi
```

#### 4) Run the setup script:

``` shell
./setup_elasticsearch.sh
```



### TODO

* Add the other dictionaries?
* Tokenize the 'meanings' field
* Fix grouped codes not being parsed (eg "(adj,n)")
* Better analyzers
* Better queries
* Boosting?
* Try the kuromoji plugin
* ...

### AUTHOR

This was a hacky Sunday experiment by @tiegz.

### ACKNOWLEDGEMENTS

Thanks to Jim Breen and all the contributors for creating the EDICT2 database
and releasing it under a [CC license](http://www.edrdg.org/jmdict/edict.html).