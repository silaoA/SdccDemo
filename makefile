#--------------------------------------------------------------------------#
#File      : portable makefile template for simple MCS51 project
#             this menas it can run on linux、msys so far,but with some bugs
#             on wincmd cdm.exe
#Coding: GBK(you can use iconv to generate a UTF8 version)
#Create : 2012-11-16 13:26:00 by 雷梦飞<stsilaoa@gmail.com>
#ProjectHome:
#Bugs   :  On   
#--------------------------------------------------------------------------#

#makefile的细节：
#1.每行命令后面不要带多余的空格
#2.wincmd和linux下的shell命令、目录表示不同
#3.CINCS = -I.\includes 中I和.之间不能有空格

#几个特殊变量的含义
 #$@  用在生成规则中，表示当前目标 
 #$<  用在生成规则中，表示当前目标的第一个依赖目标
 #$^  用在生成规则中，表示当前目标的所有依赖目标
 
################### SDCC编译的特点 #######################
#1. 不支持多个文件参数，最好每次只编译一个c文件，每个c文件生成5个文件：
#   .asm、.lst 、.rel 、.rst、.sym；连接时用的是.rel

#2. -c选项只编译不连接，-o选项可以指定输出文件或目录，若为目录则必须在
#    末尾以目录分隔符指定(否则无法区分文件还是目录)，生成的文件全会放在这
#    个目录下
#   file.c -->  file.asm file.lst file.rel file.rst file.sym in ./objs
#3.  项目由多个文件组成，则含main函数的文件(main.c)必须放在最前面
#    main.rel f1.rel f2.rel ....  --> main.cdb main.ihx main.lk main.map main.mem 
#    main.omf in ./links
#4.  将ihx文件转成hex文件或者bin文件
#     packihx  xxx.ihx  >  yyy.hex
#     makebin -Z xxx.ihx  yyy.bin
 ########################################################
 
 #########################################################
 #本makefile对应的工程目录组织(project hierarchy)
 # ./ ------- project root
 #   +sources/
 #   +includes/
 #   +objs/
 #   +links
 #    TARGET
 #    makefile
 #修改时，根据实际改变响应的目录名，另外重填./sources下源文件列表
 #########################################################
 
TARGET = LED3.hex 

#ENVIRONMENT = wincmd
ENVIRONMENT = linux

##########目录设置 ##########
####工程根目录
PROJECT_ROOT = .
###源代码根目录####

ifeq ($(ENVIRONMENT),wincmd)
#C源程序
SRC_DIR = $(PROJECT_ROOT)\sources

#中间目标文件目录objs
OBJS_DIR := $(PROJECT_ROOT)\objs

#连接中间文件目录links
LINK_DIR := $(PROJECT_ROOT)\links
#从运行结果来看，这里最好不要在末尾加\，斜线留到addprefix
else
SRC_DIR = $(PROJECT_ROOT)/sources

OBJS_DIR := $(PROJECT_ROOT)/objs

LINK_DIR := $(PROJECT_ROOT)/links
endif

#源文件列表，注意顺序(main.c should be the FIRST and filename should contain NO SPACE)
APP_CSRCS = main.c common.c isr.c

############## 添加路径 #############
ifeq ($(ENVIRONMENT),wincmd)
ifdef APP_CSRCS
CSRCS := $(addprefix $(SRC_DIR)\,$(APP_CSRCS))
endif
#CSRCS = $(APP_CSRCS)
#貌似是括号左右不能留空格

#目标文件定义，把路径添加进来
COBJS := $(addprefix $(OBJS_DIR)\, $(patsubst %.c,%.rel,$(notdir $(CSRCS))))

else
ifdef APP_CSRCS
CSRCS := $(addprefix $(SRC_DIR)/,$(APP_CSRCS))
endif
#目标文件定义，把路径添加进来
COBJS := $(addprefix $(OBJS_DIR)/, $(patsubst %.c,%.rel,$(notdir $(CSRCS))))

endif


###########编译器命令相关#########
CC = sdcc 
#注意 等于号相当于C语言中的宏定义
MAKEHEX = packihx
MAKEBIN = makebin -Z

ifeq ($(ENVIRONMENT),wincmd)
RM = del  
#注意 wincmd下将等于号后面的rm改为del，linux下RM = rm

#头文件目录
INC_DIR := .\includes 
#如有其他头文件目录可以直接后面添加目录的名 注意前面加-I

else
RM = rm
#注意 wincmd下将等于号后面的rm改为del，linux下RM = rm

#头文件目录
INC_DIR := ./includes 
endif

#编译选项(只编译不连接，选择体系结构)
CFLAGS = -mmcs51 --model-small
CFLAGS += -I$(INC_DIR)

#链接选项(定义目标、模式)
LDFLAGS = 

#all : version $(target)	
all : hex

ifeq ($(ENVIRONMENT),wincmd)
hex:$(LINK_DIR)\main.ihx
	@echo "pack ihx --> hex"
	$(MAKEHEX) $(LINK_DIR)\main.ihx > $(TARGET)
	
$(LINK_DIR)\main.ihx:$(COBJS)
	@echo "连接目标文件，生成ihx文件"
	$(CC)  $(LDFLAGS) $(COBJS) -o$(LINK_DIR)\
	
bin:$(LINK_DIR)\main.ihx
	@echo "pack ihx --> binary(GameBoy format binary)"
	$(MAKEBIN) $(LINK_DIR)\main.ihx $(patsubst %.hex,%.bin,$(TARGET))
	
else
hex:$(LINK_DIR)/main.ihx
	@echo "pack ihx --> hex"
	$(MAKEHEX) $(LINK_DIR)/main.ihx > $(TARGET)
	
$(LINK_DIR)/main.ihx:$(COBJS)
	@echo "连接目标文件，生成ihx文件"
	$(CC)  $(LDFLAGS) $(COBJS) -o$(LINK_DIR)/

bin:$(LINK_DIR)/main.ihx
	@echo "pack ihx --> binary(GameBoy format binary)"
	$(MAKEBIN) $(LINK_DIR)/main.ihx $(patsubst %.hex,%.bin,$(TARGET))
endif

version :
	@echo "Show CC Version"
	$(CC) --version

# 编译C程序，此规则的写法很重要！！！
##################################  以下由c到o的几行 ##############################
#第1行直接在目录后紧跟%，不添加任何'\'，经试验正确；$(OBJS_DIR)\%.rel : $(SRC_DIR)\%.c的写法
#由于\%的转义起作用作用(本意是在win下的目录分隔符)；但是$(OBJS_DIR)\\%.rel : $(SRC_DIR)\%.c正确
#第2行同时都加两个\\，却导致 .\sources\\printA.c --> .\objs\printA.rel(不理解)；
#第3行本意是把目标文件和源文件都直接列出来，规则错误，make不工作；
#第4、5行错误同第3行，make也不工作
ifeq ($(ENVIRONMENT),wincmd)
$(OBJS_DIR)%.rel : $(SRC_DIR)%.c
#$(OBJS_DIR)\\%.rel : $(SRC_DIR)\\%.c
#$(COBJS)%.rel:$(CSRCS)%.c
#$(COBJS)\\%.rel:$(CSRCS)\%.c
	@echo 正在编译c文件： $<
	$(CC) -c $(CFLAGS) $< -o$(OBJS_DIR)/
else
#linux下要把路径加上，再写 %o %c
$(OBJS_DIR)/%.rel : $(SRC_DIR)/%.c
	@echo 正在编译c文件： $<
	$(CC) -c $(CFLAGS) $< -o$(OBJS_DIR)/
endif
	
.PHONY:msg clean cleanobj cleanlink cleantar cleanbin
msg:
	@echo ENVIRONMENT是$(ENVIRONMENT)
	@echo TARGET是$(TARGET)
	@echo CSRCS是$(CSRCS)
	@echo COBJS是$(COBJS)
	@echo CFLAGS是$(CFLAGS)
	@echo RM命令是$(RM)
	
clean:cleanobjs cleanlinks cleantar cleanbin
	@echo "objs目录下的文件、links目录下文件和hex文件已删除" 
	
ifeq ($(ENVIRONMENT),wincmd)
cleanobjs:
	@echo 清空objs目录
	-$(RM) $(OBJS_DIR)\*.*
cleanlinks:
	@echo 清空links目录
	-$(RM) $(LINK_DIR)\*.*
	
else
cleanobjs:
	@echo 清空objs目录
	-$(RM) $(OBJS_DIR)/*.*
cleanlinks:
	@echo 清空links目录
	-$(RM) $(LINK_DIR)/*.*
endif

cleantar:
	@echo 删除最终目标hex文件
	-$(RM) $(TARGET)

cleanbin:
	@echo 删除bin文件
	-$(RM) $(patsubst %.hex,%.bin,$(TARGET))