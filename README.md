## my1942Game移植到安路的开发板上，创建了my1942GameAn的分支

### 2023.05.01
1. 完成了将当前同期Xilinx版本的工作移植到安路PH1A60板卡上（修改了一些文件）

### 2023.05.03
1. 添加了用于产生敌机单位的中断

### 2023.05.08
1. 完成了除开橙色敌机外的所有敌机阵列编排（不再是随机产生飞机），产生敌机的时机也随地图的滚动进行了编排

### 2023.05.10
1. 将调色板从之前的4个增加到了8个：对于背景来讲开始界面使用后4个，游戏进行中使用前4个；对于精灵来讲，我方飞机增加了皮肤选择选项

### 2023.05.14
1. 将NES文件中的背景图案库进行了修改，增加了我们用到的相关元素，完善了开始界面和结算界面的显示
