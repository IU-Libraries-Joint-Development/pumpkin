if [ ! -d "kakadu" ]; then
  mkdir ~/downloads
  wget http://kakadusoftware.com/wp-content/uploads/KDU841_Demo_Apps_for_Linux-x86-64_231117.zip -O ~/downloads/kakadu.zip
  unzip ~/downloads/kakadu.zip
  mv KDU841_Demo_Apps_for_Linux-x86-64_231117 kakadu
fi
sudo cp kakadu/*.so /usr/lib
sudo cp kakadu/* /usr/bin
