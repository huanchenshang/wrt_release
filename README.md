开启内核eBPF，支持dae，daed内核级透明代理
v2ray-geodata使用MetaCubeX的geosite和geoip，分流更精细
https://github.com/MetaCubeX/meta-rules-dat
使用nginx代替uhttpd

首先安装 Linux 系统，推荐 Ubuntu LTS  

安装编译依赖  
sudo apt -y update  
sudo apt -y full-upgrade  
sudo apt install -y dos2unix libfuse-dev  
sudo bash -c 'bash <(curl -sL https://build-scripts.immortalwrt.org/init_build_environment.sh)'  

使用步骤：  
git clone https://github.com/huanchenshang/wrt_release
cd wrt_release  
  
编译京东云亚瑟(01):  
./build.sh jdcloud_ipq60xx_immwrt  
./build.sh jdcloud_ipq60xx_libwrt  
  
三方插件源自：https://github.com/kenzok8/small-package.git  
  
使用OAF（应用过滤）功能前，需先完成以下操作：  
1. 打开系统设置 → 启动项 → 定位到「appfilter」  
2. 将「appfilter」当前状态**从已禁用更改为已启用**  
3. 完成配置后，点击**启动**按钮激活服务  
