#sync rom
repo init --depth=1 --no-repo-verify -u https://github.com/AICP/platform_manifest.git -b r11.1 -g default,-mips,-darwin,-notdefault
#git clone https://github.com/NFS-projects/local_manifest --depth 1 -b PB-11 .repo/local_manifests
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j10

# build rom
source build/envsetup.sh
lunch aosp_rosy-userdebug
export TZ=Asia/Jakarta
export BUILD_USERNAME=rosy
export BUILD_HOSTNAME=userdebug
export TARGET_BUILD_PIXELBLASTER=true
export BLASTER_BUILD_VARIANT=GAPPS
export TARGET_FACE_UNLOCK_SUPPORTED=true
curl -s https://api.telegram.org/bot$TG_TOKEN/sendMessage -d chat_id=$TG_CHAT_ID -d text="$(echo "${var_cache_report_config}")"
mka bacon -j10 #&
#sleep 100m
#kill %1

# upload rom
rclone copy out/target/product/$(grep unch $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d ' ' -f 2 | cut -d _ -f 2 | cut -d - -f 1)/*.zip cirrus:$(grep unch $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d ' ' -f 2 | cut -d _ -f 2 | cut -d - -f 1) -P
