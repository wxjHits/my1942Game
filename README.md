# my1942Game

create 2023.02.09
FPGA：A7
基于M0软核实现经典FC游戏《1942》的模仿

2023.02.09
	1）完成通过CPU写精灵RAM
	2）硬件上完成碰撞检测
	3）硬件上完成tile的显示
	4）完成基本的SoC搭建与C语言测试

2023.02.13
	1）将画图模块tileDraw复制64份，生成bit流后，烧录后未成功，暂时搁置，不用这种显示方法

2023.02.14
	1）一共有64个精灵，将显示tiledraw复制8个，在扫描每一行之前对64个精灵ram进行扫描，需要在下一行进行显示的精灵会存到8个tiledraw中；也就是说游戏画面的每一行仅仅支持8个精灵。目前已经完成测试，并且很大程度上减少了资源的消耗。

2023.02.15
	1）采用C语言实现了碰撞检测：我方飞机、子弹与敌方飞机的碰撞检测（采用bitmask，掩码的碰撞检测）

2023.02.21
	1）实现了爆炸的效果（一共4帧动画）
	2）敌机简单的两段路径运动
	3）将FC游戏1942的256个精灵都存储在了精灵素材ROM里面，测试完成

2023.02.22
	1）优化了一下时序，在文件tileDraw.v中，使得显示比之前稳定了许多
	2）增加了buff单元（测试了使得子弹增加的buff，tile为"Pow"字样）

2023.02.24
	1）增加了我方飞机的闪避动画，期间不受攻击
	2）增加了敌方飞机发射子弹的功能，发射子弹方向基本上指向我方飞机
	3）当前的代码量似乎已经超过了ROM的空间（初步观察是绘图函数占用过多的代码，比较我方飞机无敌状态可考虑更换颜色来实现，虽然展示效果稍差）

2023.02.26
	1）测试了PS2手柄（目前采用的是IO软件模拟PS2协议），按键有效
	2）在Doc文件夹中添加了使用PS2手柄的pdf说明书

2023.03.03
	1）完成了通过名称表绘制背景的功能，目前只是从硬件上完成了数据通路，进行了测试（测试无误），但是可能后面资源不够用。rtl代码在C:\Users\hp\Desktop\my1942Game\RTL\src\game\PPU\backGround文件夹下面

2023.03.04
	1）重新整理了PPU模块，分为精灵绘制部分和背景绘制部分，CPU通过对精灵数据RAM和背景名称表nameTable（两个AHB外设）
	2）通过C语言对背景名称表进行了写操作，功能基本完成，但是32bit数据硬件大小端和习惯不符合

2023.03.07
	1）更新了Doc文件夹下的visio框图文件，绘制了一些框图
	2）将绘制精灵和绘制背景的调色板分开了，单独使用不同的调色板
	3）解决了2023.03.04第2）提到的问题