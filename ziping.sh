#!/bin/bash

msg() {
    echo -e "\e[1;32m$*\e[0m"
}

function enviroment() {
   device=$(grep unch $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d ' ' -f 2 | cut -d _ -f 2 | cut -d - -f 1)
   name_rom=$(grep init $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d / -f 4)
   JOS=$WORKDIR/rom/$name_rom/out/target/product/$device/*.zip
   SHASUM=$WORKDIR/rom/$name_rom/out/target/product/$device/*.zip*sha*
   OTA=$WORKDIR/rom/$name_rom/out/target/product/$device/*ota*.zip

}

function upload_rom() {
   msg Upload rom..
   rm -rf $SHASUM
   rm -rf $OTA
   curl -s -X POST https://api.telegram.org/bot$TG_TOKEN/sendMessage -d chat_id=$TG_CHAT_ID -d disable_web_page_preview=true -d parse_mode=html -d text="<b>Build status:</b>%0A@NiatIngsungLakenMalemJumat <code>Building Rom $name_rom succes [✔️]</code>"
   rclone copy --drive-chunk-size 256M --stats 1s $JOS NFS:rom/$name_rom -P
   curl -s -X POST https://api.telegram.org/bot$TG_TOKEN/sendMessage -d chat_id=$TG_CHAT_ID -d disable_web_page_preview=true -d parse_mode=html -d text="Link : https://nfsproject.projek.workers.dev/0/$name_rom/$(cd $WORKDIR/rom/$name_rom/out/target/product/$device && ls $name_rom*.zip)"
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

