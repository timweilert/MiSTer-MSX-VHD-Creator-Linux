#!bin/bash
read -p "Desired Output Filename (*.vhd):" outputfile

wget https://github.com/MiSTer-devel/MSX_MiSTer/raw/master/Utils/sdcreate.zip
unzip -j sdcreate.zip sdbios/OCM-BIOS.DAT
# Size get divided by 512, then minus 1 to give the number of sectors
# Sectors then get divided by 16065 to give the number of head cylinders
# Assuming a single sector is used
sizeminimum=$(( ((1 + 1)*512) * 16065 ))
size=0
until [ "$size" -ge "$sizeminimum" ]
do
  read -p "Enter the total disk size in bytes (minimum is $sizeminimum): " size
done
nsectors=$((($size/512)-1))
cylinders=$(($nsectors/16065))
echo "Truncating"
truncate --size=$size $outputfile
echo "Creating Partition Table"
echo 1 $nsectors 6 | /sbin/sfdisk --force $outputfile
echo "Formatting"
mformat -i $outputfile@@512 -t $cylinders -h 255 -n 63 -H 1 -m 248 ::
echo "Copying OCM-BIOS.DAT"
mcopy -i $outputfile@@512 OCM-BIOS.DAT ::
echo "Hiding OCM-BIOS.DAT"
mattrib -i $outputfile@@512 +h ::OCM-BIOS.DAT

