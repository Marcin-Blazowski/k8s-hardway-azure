sudo mkdir /mnt/k8s-test-file-share
if [ ! -d "/etc/smbcredentials" ]; then
sudo mkdir /etc/smbcredentials
fi
if [ ! -f "/etc/smbcredentials/k8steststorage.cred" ]; then
    sudo bash -c 'echo "username=k8steststorage" >> /etc/smbcredentials/k8steststorage.cred'
    sudo bash -c 'echo "password=eg0J13A4Ifoa4e8p+S7CsiiZlwQsElOzKZor7Tpksh/j729D0N4fDMNGhAzM8XpjCGID8H3r3LQpNrludLb/dg==" >> /etc/smbcredentials/k8steststorage.cred'
fi
sudo chmod 600 /etc/smbcredentials/k8steststorage.cred

sudo bash -c 'echo "//k8steststorage.file.core.windows.net/k8s-test-file-share /mnt/k8s-test-file-share cifs nofail,vers=3.0,credentials=/etc/smbcredentials/k8steststorage.cred,dir_mode=0777,file_mode=0777,serverino" >> /etc/fstab'
sudo mount -t cifs //k8steststorage.file.core.windows.net/k8s-test-file-share /mnt/k8s-test-file-share -o vers=3.0,credentials=/etc/smbcredentials/k8steststorage.cred,dir_mode=0777,file_mode=0777,serverino