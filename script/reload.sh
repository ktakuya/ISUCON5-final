set -ex
cd ~/webapp/perl;
git pull;
/home/isucon/env.sh carton install;
sudo supervisorctl reload perl;
