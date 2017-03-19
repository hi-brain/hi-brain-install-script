#! /bin/bash
#
# @file install_hibrain.sh
# @brief Hi-brain dependent packages install and setup script for Ubuntu 16.04 LTS (x86_64)

# OpenRTM-aist-C++(1.1.0)
# OpenRTM-aist-Java(1.1.0)
# OpenRTP(1.1.0)
# OpenCv(3.0.0)
#------------------------
# Configurations
#------------------------
openrtm_cpp_url="http://www.openrtm.org/pub/OpenRTM-aist/cxx/1.1.0/OpenRTM-aist-1.1.0-RELEASE.tar.gz"
openrtm_aist_ver="1.1"
openrtm_java_url="http://openrtm.org/pub/OpenRTM-aist/java/1.1.0/OpenRTM-aist-Java-1.1.0-RELEASE-jar.zip"
openrtm_java_ver="1.1"
openrtp_url="http://openrtm.org/pub/openrtp/packages/1.1.0.rc5v20151111/eclipse381-openrtp110rc5v20151111-linux-gtk-x86_64.tar.gz"
opencv_url="https://github.com/opencv/opencv/archive/3.0.0.zip"
opencv_ver="3.0.0"
opencv_contrib_zip="https://github.com/opencv/opencv_contrib/archive/3.0.0.zip"
bodhibuilder_url="https://sourceforge.net/projects/bodhibuilder/files/bodhibuilder_2.2.4_all.deb/download"
bodhibuilder_name="bodhibuilder_2.2.4_all.deb"

set_package_list(){
  git_tools="git git-core git-gui gitk"
  misc_tools="build-essential cmake pkg-config openssh-server libboost-all-dev openjdk-8-jdk"
  autotools="autoconf libtool libtool-bin"
  build_tools="gcc g++ make"
  dep_pkg="uuid-dev doxygen"
  source_tools="subversion texlive texlive-lang-cjk xdvik-ja"
  omni_devel="libomniorb4-dev omniidl omniorb-nameserver libomniorb4-1"
  python_tools="python python-yaml python-omniorb python-omniorb-omg omniidl-python python-pip python-lxml"
  openrtm_tools="openrtm-aist openrtm-aist-example openrtm-aist-doc openrtm-aist-dev"
  openrtm_python_tools="python-pyorbit-omg omniidl-python openrtm-aist-python openrtm-aist-python-example openrtm-aist-python-doc"
  cv_tools1="libjpeg-dev libjasper-dev libpng12-dev libav-tools libavcodec-dev libavformat-dev libswscale-dev libdc1394-utils"
  cv_tools2="libdc1394-22 libdc1394-22-dev libxine2-dev x264 libxvidcore-dev libvpx-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev "
  cv_tools3="libv4l-dev v4l-utils v4l-conf libfaac-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libtiff5-dev"
  cv_tools4="python-dev python-numpy python-tk python-opencv sphinx-common libtbb-dev libeigen3-dev"
  cv_tools5="libqt4-dev libgtk-3-dev patch ruby librtmp1 librtmp-dev yasm libtheora-dev libvorbis-dev qt5-default qt5-qmake"
  #libace-6.0.1 libace-dev
  misc_packages="$git_tools $misc_tools"
  required_packages="$autotools $source_tools $omni_devel $dep_pkg $build_tools $python_tools"
  opencv_required_packages="$cv_tools1 $cv_tools2 $cv_tools3 $cv_tools4 $cv_tools5"
  openrtm_packages="$openrtm_tools"
}

#----------------------------------------
# language check
#----------------------------------------
check_lang()
{
lang="en"
locale | grep ja_JP > /dev/null && lang="jp"
if test "$lang" = "jp" ;then
  msg1="ディストリビューションを確認してください。\nDebianかUbuntu以外のOSの可能性があります。"
  msg2="コードネーム :"
  msg3="このOSはサポートしておりません。"
  msg4="OpenRTM-aist のリポジトリが登録されていません。"
  msg5="Source.list に OpenRTM-aist のリポジトリ: "
  msg6="を追加します。よろしいですか？(y/n)[y] "
  msg7="中断します。"
  msg8="ルートユーザーで実行してください。"
  msg9="インストール中です..."
  msg10="完了"
  msg11="アンインストール中です."
else
  msg1="This distribution may not be debian/ubuntu."
  msg2="The code name is : "
  msg3="This OS is not supported."
  msg4="No repository entry for OpenRTM-aist is configured in your system."
  msg5="repository entry for OpenRTM-aist: "
  msg6="Do you want to add new repository entry for OpenRTM-aist in source.list? (y/n) [y] "
  msg7="Abort."
  msg8="This script should be run as root."
  msg9="Now installing: "
  msg10="done."
  msg11="Now uninstalling: "
fi
}

#----------------------------------------
# get codename
#----------------------------------------
create_srclist(){
  cnames=`sed -n /DISTRIB_CODENAME=/p /etc/lsb-release | sed 's/DISTRIB_CODENAME=//'`
  for c in $cnames; do
    if test -f "/etc/apt/sources.list"; then
      res=`grep $c /etc/apt/sources.list`
    else
      echo $msg1
      exit
  	fi
    if test ! "x$res" = "x" ; then
      code_name=$c
  	fi
  done
  if test ! "x$code_name" = "x"; then
    echo $msg2 $code_name
  else
    echo $msg3
    exit
  fi
  openrtm_repo="deb http://openrtm.org/pub/Linux/ubuntu/ $code_name main"
}

#----------------------------------------
# Update /etc/apt/sources.list
#----------------------------------------
update_source_list(){
  rtmsite=`grep "$openrtm_repo" /etc/apt/sources.list`
  if test "x$rtmsite" = "x" ; then
    echo $msg4
    echo $msg5
    echo "  " $openrtm_repo
    read -p "$msg6" kick_shell
    if test "x$kick_shell" = "xn" ; then
      echo $msg7
      exit 0
    else
      echo $openrtm_repo >> /etc/apt/sources.list
    fi
  fi
}

#----------------------------------------
# root check
#----------------------------------------
check_root () {
    if test ! `id -u` = 0 ; then
	echo ""
	echo $msg8
	echo $msg7
	echo ""
	exit 1
    fi
}

#------------------------
# Install function
#------------------------
apt_install() {
	for p in $*; do
		echo $msg9 $p
		apt install --force-yes -y $p
		echo $msg10
		echo ""
	done
}

#------------------------
# wget & make install openrtm_cpp
#------------------------
wget_rtmcpp() {
  wget $openrtm_cpp_url
	openrtm_cpp_tar=${openrtm_cpp_url##*/}
	tar xvzf ${openrtm_cpp_tar} &&
	cd ./${openrtm_cpp_tar%-*.*.*}/ && ./configure --prefix=/usr && make -j $(nproc) &&
	make install &&
	cd .. &&
	rm -rf ${openrtm_cpp_tar} ${openrtm_cpp_tar%.*.*}
}

#------------------------
# apt install openrtm(c++)
#------------------------
rtmcpp_install() {
  create_srclist
  update_source_list
  apt autoclean
  apt-get --allow-unauthenticated update
  #if [ $? -gt 0 ]; then
    wget_rtmcpp
  #else
    #apt_install $openrtm_packages
  #fi
}

#------------------------
# pip install rtshells
#------------------------
rtshell_install(){
  pip install rtshell
  if [ $? -gt 0 ]; then
    echo "proxy input(http://example.co.jp:8080)"
    read -p ":" proxy
    echo $proxy
    pip --proxy=$proxy install rtshell
  fi
  rtshell_post_install
}

#------------------------
# wget & install openrtm(java)
#------------------------
wget_rtmjava() {
  wget ${openrtm_java_url} &&
	mkdir /usr/share/openrtm-${openrtm_aist_ver}/java &&
	unzip ${openrtm_java_url##*/} &&
	mv ./OpenRTM-aist/${openrtm_java_ver}/ /usr/share/openrtm-${openrtm_aist_ver}/java/ &&
	rm -rf OpenRTM-aist ${openrtm_java_url##*/}
}

#------------------------
# wget & install openrtp
#------------------------
wget_openrtp(){
  cur=`pwd`
  wget $openrtp_url &&
	mv ${openrtp_url##*/} /usr/share/openrtm-${openrtm_aist_ver}/ &&
	cd /usr/share/openrtm-${openrtm_aist_ver}/ &&
	tar xvzf ${openrtp_url##*/} &&
	rm ${openrtp_url##*/} &&
	cd /usr/bin/ &&
	ln -s /usr/share/openrtm-${openrtm_aist_ver}/eclipse/openrtp . &&
	cd $cur
}

#----------------------------------------
# misc install
#----------------------------------------
misc_install(){
	echo "misc_install"
  apt -y update
  apt -y upgrade
  apt -y autoremove
  apt -y remove --purge libreoffice*
  apt_install $misc_packages
  echo "misc installed"
}

#----------------------------------------
# OpenRTM install
#----------------------------------------
openrtm_install(){
	echo "openrtm install"
  apt_install $required_packages
  rtmcpp_install
  wget_rtmjava
  #apt_install $openrtm_python_tools
  rtshell_install
  wget_openrtp
  echo "openrtm installed"
}

#----------------------------------------
# OpenCV install
#----------------------------------------
opencv_install(){
  apt_install $opencv_required_packages
  wget $opencv_url
	unzip ${opencv_url##*/}
	  wget $opencv_contrib_zip -O opencv_contrib.zip
  unzip opencv_contrib.zip
	cd opencv-${opencv_ver}
	mkdir opencv_build
	cd opencv_build
  cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local/opencv${opencv_ver} -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-${opencv_ver}/modules -D EIGEN_INCLUDE_PATH=/usr/include/eigen3 -D WITH_TBB=OFF -D INSTALL_C_EXAMPLES=OFF -D BUILD_EXAMPLES=ON -D WITH_QT=ON -D BUILD_TIFF=ON -D BUILD_TBB=OFF ..
  make -j $(nproc)
  make install
	cd ../..
	rm ${opencv_url##*/}
}

#----------------------------------------
# MATLAB Compiler install
#----------------------------------------
compiler_install(){
  arch=$(uname -m)
	matlib=""
	if [ ! $arch = "x86_64" ]; then
    echo "os is not x86_64"
    exit 1
  fi
  PS3="What MATLAB version do you use?"
  ans1="R2016b"
  ans2="R2016a"
  ans3="R2015b"
  ans4="R2015a"
  ans5="R2014b"
  ans6="R2014a"
  ans7="R2013b"
  select ANS in "$ans1" "$ans2" "$ans3" "$ans4" "$ans5" "$ans6" "$ans7"
  do
    if [ -z "$ANS" ]; then

      continue
    else
      break
    fi
  done
  case $ANS in
    "R2016b") mcr_ver="v91" ;;
    "R2016a") mcr_ver="v901" ;;
    "R2015b") mcr_ver="v90" ;;
    "R2015a") mcr_ver="v85" ;;
    "R2014b") mcr_ver="v84" ;;
    "R2014a") mcr_ver="v83" ;;
    "R2013b") mcr_ver="v82" ;;
  esac
  mcr_url="https://jp.mathworks.com/supportfiles/downloads/$ANS/deployment_files/$ANS/installers/glnxa64/MCR_${ANS}_glnxa64_installer.zip"
  wget $mcr_url
  unzip ${mcr_url##*/} -d matlab
	./matlab/install
	rm -rf matlab ${mcr_url##*/}
  matlib="/usr/local/MATLAB/MATLAB_Runtime/${mcr_ver}"
  echo $mcr_ver
}

#----------------------------------------
# Bodhi Builder install
#----------------------------------------
bodhibuilder_install(){
  wget ${bodhibuilder_url} -O ${bodhibuilder_name}
  dpkg -i ${bodhibuilder_name}
  if [ $? -gt 0 ]; then
    apt -f install
    dpkg -i ${bodhibuilder_name}
  fi
}

etc_func(){
  git clone https://github.com/hi-brain/hibrain_library.git
  cd hibrain_library
  cmake .
  make -j $(nproc)
  make install
  cp -r vmc_builder /usr/local/
  sudo ln -s /usr/local/vmc_builder/vmc_builder /usr/local/bin/vmc_builder
  cd ../
}

var_set(){
  echo -e "options uvcvideo nodrop=1 timeout=50000" | tee -a /etc/modprobe.d/hi-brain.conf
  echo -e "source /usr/local/lib/python2.7/dist-packages/rtshell/data/shell_support" | tee -a /etc/bash.bashrc
  echo -e "RTM_JAVA_ROOT=/usr/share/openrtm-${openrtm_aist_ver}/java/${openrtm_java_ver}" | tee -a /etc/environment
  echo -e "LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/opencv${opencv_ver}/lib:${matlib}/extern/lib/glnxa64:/usr/local/hi-brain/lib" | tee -a /etc/environment
  echo -e "MATLAB_RUNTIME_PATH=${matlib}" | tee -a /etc/environment
	echo -e "PKG_CONFIG_PATH=${PKG_CONFIG_PATH}:/usr/local/opencv${opencv_ver}/lib/pkgconfig" | tee -a /etc/environment
  echo -e "OpenCV_DIR=/usr/local/opencv${opencv_ver}/" | tee -a /etc/environment

	/bin/bash -c 'source ~/.bashrc'
	/bin/bash -c 'source /etc/environment'
	ldconfig -v

	## ランチャーに登録
	touch openrtp.desktop
	echo '[Desktop Entry]' >> openrtp.desktop
	echo 'Type=Application' >> openrtp.desktop
	echo 'Name=OpenRTP' >> openrtp.desktop
	echo "Icon=/usr/share/openrtm-${openrtm_aist_ver}/eclipse/icon.xpm" >> openrtp.desktop
	echo 'Exec=openrtp' >> openrtp.desktop
	echo 'Terminal=false' >> openrtp.desktop
	chmod +x openrtp.desktop
	mv openrtp.desktop /usr/share/applications/

	## pkg-config 登録
	touch hibrain.pc
	echo 'prefix=/usr/local/hi-brain' >> hibrain.pc
	echo 'Name: hibrain' >> hibrain.pc
	echo 'Description: HI-brain Library' >> hibrain.pc
	echo 'Version: 1.0.0' >> hibrain.pc
	echo 'Libs:  -L${prefix}/lib -lhi_convert -lhi_sharedmemory -lhi_viewer' >> hibrain.pc
	echo 'Cflags: -I${prefix}/include' >> hibrain.pc
	mv hibrain.pc /usr/lib/pkgconfig/
}

#---------------------------------------
# USAGE
#---------------------------------------
howto_usage(){
    cat << EOF
Usage: sudo $0 []

EOF
}

#----------------------------------------
# main
#----------------------------------------
if test "x$1" = "x-h" ; then
    howto_usage
    exit 1
fi

check_lang
check_root
set_package_list
misc_install
openrtm_install
#opencv_install
#compiler_install
#bodhibuilder_install
var_set
#etc_func
