#!/bin/bash

msg() {
    echo -e "\e[1;32m$*\e[0m"
}

telegram_message() {
         curl -s -X POST "https://api.telegram.org/bot$TG_TOKEN/sendMessage" \
         -d chat_id="$TG_CHAT_ID" \
         -d parse_mode="HTML" \
         -d text="$1"
}

function enviroment() {
   device=$(grep unch $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d ' ' -f 2 | cut -d _ -f 2 | cut -d - -f 1)
   name_rom=$(grep init $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d / -f 4)
   branch_name=$(grep init $CIRRUS_WORKING_DIR/build.sh | awk -F "-b " '{print $2}' | awk '{print $1}')
   JOS=$WORKDIR/rom/$name_rom/out/target/product/$device/*.zip
   file_name=$(cd $WORKDIR/rom/$name_rom/out/target/product/$device && ls *.zip)
   SHASUM=$WORKDIR/rom/$name_rom/out/target/product/$device/*.zip*sha*
   OTA=$WORKDIR/rom/$name_rom/out/target/product/$device/*ota*.zip
   rel_date=$(date "+%Y%m%d")
   DATE_L=$(date +%d\ %B\ %Y)
   DATE_S=$(date +"%T")

}

function upload_rom() {
   msg Upload rom..
   rm -rf $SHASUM
   rm -rf $OTA
   rclone copy --drive-chunk-size 256M --stats 1s $JOS NFS:$name_rom/$device -P
   DL_LINK=https://nfsproject.projek.workers.dev/0:/$name_rom/$device/$file_name"
   echo -e \
   "
   ✅Build Completed Successfully!
   
   🚀 Info Rom: $(cd $WORKDIR/rom/$name_rom/out/target/product/$device && ls *.zip -m1 | cut -d . -f 1-2)
   📚 Timer Build: $(grep "####" Build-rom.log -m 1 | cut -d '(' -f 2)
   📱 Device: $device
   🖥 Branch Build: $branch_name
   🔗 Download Link: <a href=\"$DL_LINK\">Here</a>
   📅 Date: $(date +%d\ %B\ %Y)
   🕔 Time Zone: $(date +%T) WIB
   
   🧑‍💻 By : @NiatIngsungLakenMalemJumat
   " > tg.html
   TG_TEXT=$(< tg.html)
   telegram_message $TG_TEXT
   msg Upload rom succes..
}

function upload_ccache() {
   cd $WORKDIR
   com ()
   {
     tar --use-compress-program="pigz -k -$2 " -cf $1.tar.gz $1
   }
   time com ccache 1
   rclone copy --drive-chunk-size 256M --stats 1s ccache.tar.gz NFS:ccache/$name_rom -P
   rm -rf ccache.tar.gz
   msg Upload ccache succes..
}

function upload() {
   enviroment
   if ! [ -a "$JOS" ]; then
     msg Upload ccache..
     upload_ccache
   fi
   upload_rom
}

upload
