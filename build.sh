#sync rom
repo init --depth=1 --no-repo-verify -u https://github.com/AICP/platform_manifest.git -b r11.1 -g default,-mips,-darwin,-notdefault
git clone https://github.com/NFS-projects/local_manifest --depth 1 -b 11.1 .repo/local_manifests
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j4

# build rom
source build/envsetup.sh
lunch aicp_rosy-userdebug
export TZ=Asia/Jakarta
export BUILD_USERNAME=rosy
export BUILD_HOSTNAME=userdebug
curl -s https://api.telegram.org/bot$TG_TOKEN/sendMessage -d chat_id=$TG_CHAT_ID -d text="$(echo "${var_cache_report_config}")"
brunch rosy &
sleep 70m
kill %1

# upload rom
rclone copy out/target/product/$(grep unch $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d ' ' -f 2 | cut -d _ -f 2 | cut -d - -f 1)/*.zip cirrus:$(grep unch $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d ' ' -f 2 | cut -d _ -f 2 | cut -d - -f 1) -P
