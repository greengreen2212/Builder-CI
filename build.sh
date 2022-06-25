#sync rom
repo init --depth=1 --no-repo-verify -u https://github.com/crdroidandroid/android.git -b 11.0 -g default,-mips,-darwin,-notdefault
git clone https://github.com/NFS-projects/local_manifest --depth 1 -b 11.1 .repo/local_manifests
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j10

# build rom
source build/envsetup.sh
