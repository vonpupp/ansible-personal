
#git submodule init
#git submodule update
#sudo pacman -Sy --noconfirm ansible

#ansible-galaxy -p roles install Stouts.users Stouts.sudo Stouts.locale Stouts.hostname

#ansible-playbook setup.yml -i "local," --extra-vars "makepkg_user=afu" $@
#ansible-playbook setup.yml -i "local," --extra-vars "makepkg_user=afu, user_email=asf@mail.com" --ask-become-pass $@
ansible-playbook setup-user.yml -i "local," --extra-vars "username=av user_email=vonpupp@gmail.com" --ask-become-pass $@