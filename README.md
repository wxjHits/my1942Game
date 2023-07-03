## my1942Game移植到安路的开发板上，创建了my1942GameAnM3的分支（从M0软核换成了M3软核）

### 2023.06.01（初赛版本）
1. 该版本为初赛提交的版本（从另外一个仓库中直接复制过来的）

### 2023.06.11
1. 增加了游戏操作方式的选项（只是实现了显示的功能，“手柄”or“手势”的字样）

### 2023.06.21
1. 硬件上实现读取JY61P三个角度的数据，挂载到了APB2的位置

### 2023.06.26
1. 将spriteTileRom.v中存储精灵图案库的采用ERAM实现（之前是DRAM），减少了LUT的使用（便于布局布线）
2. 整合了魏泷给的手势识别的部分，挂在到了APB上读取识别结果（将其中的FIFO IP核都采用ERAM实现，便于布局布线）

### 2023.06.27
1. 将串口陀螺仪JY61P和CNN手势识别网络二者的结果作为飞机操作的指令，取代原先的手柄（数据通路没问题，只是体验感不太行）

### 2023.07.02
1. 将CNN部分有APB总线换成了AHB总线（BASE_ADDR=0x60000000），符合报告里面的SoC总体框图
2. 将采用手势操作模式下生成的敌方飞机的难度进行了降低（手势操作不是特别方便）
### 2023.07.02 add
3. 增加了按键中断控制背景音乐，或者添加后续的其他功能
4. 解决了敌机生成数组不归0的问题（应该将uint32_t create_enmeyPlane_num在main.c函数里面声明，不应该在中断handler.c文件中声明）

### 2023.07.03
1. 给摄像头增加了三个调节阈值的控制字，在cnn.h/cnn.c文件中实现
### 2023.07.03 add
2. 增加了“最高分数”的纪录，保存在flash中（注释掉了函数SPI_Flash_Erase_Block的这一行//Dst_BlockNum_Addr*=65536才使得Block擦除成功）