if [ ! -d "kakadu" ]; then
  mkdir ~/downloads
  wget http://kakadusoftware.com/wp-content/uploads/KDU805_Demo_Apps_for_Linux-x86-64_200602.zip -O ~/downloads/kakadu.zip
  unzip ~/downloads/kakadu.zip
  mv KDU805_Demo_Apps_for_Linux-x86-64_200602 kakadu
fi
sudo cp kakadu/*.so /usr/lib
sudo cp kakadu/* /usr/bin
