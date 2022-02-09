直接fork了这个半成品：https://github.com/2b45/HaboMalHunter

这个作者大概是没有搞完的，python3的分支一大堆报错没得用，master分支的docker搭建也是没法用的

所以我这里根据他里面有参考价值的操作，定制了一个Ubuntu1604下可用的版本

（理论上Ubuntu其他高版本也能用，不过你需要具体看看./build.sh里的命令，可能需要改改）

下载项目时务必把该HaboMalHunter文件夹放到/opt目录下面，才能进行安装搭建

原因是conf.ini文件硬编码写死了这个路径

git clone https://github.com/w1th1c3/HaboMalHunter /opt/HaboMalHunter

cd /opt/HaboMalHunter

bash ./build.sh

没有报错的话就说明成功安装好了

项目介绍懒得写了

直接看源项目readme吧

https://github.com/Tencent/HaboMalHunter

