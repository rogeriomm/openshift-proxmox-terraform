#!//usr/bin/env zsh

read -q "REPLY?Destroy Openshift cluster? "
echo "\n"

if [ "$REPLY" = "y" ]; then
   for vmid in 801 802 803 804 805 806 810; do
      sudo qm stop $vmid
      sudo qm destroy $vmid
   done
   rm terraform.tfstate*
else
   echo "Canceled."
fi
