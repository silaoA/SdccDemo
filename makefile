#--------------------------------------------------------------------------#
#File      : portable makefile template for simple MCS51 project
#             this menas it can run on linux��msys so far,but with some bugs
#             on wincmd cdm.exe
#Coding: GBK(you can use iconv to generate a UTF8 version)
#Create : 2012-11-16 13:26:00 by ���η�<stsilaoa@gmail.com>
#ProjectHome:
#Bugs   :  On   
#--------------------------------------------------------------------------#

#makefile��ϸ�ڣ�
#1.ÿ��������治Ҫ������Ŀո�
#2.wincmd��linux�µ�shell���Ŀ¼��ʾ��ͬ
#3.CINCS = -I.\includes ��I��.֮�䲻���пո�

#������������ĺ���
 #$@  �������ɹ����У���ʾ��ǰĿ�� 
 #$<  �������ɹ����У���ʾ��ǰĿ��ĵ�һ������Ŀ��
 #$^  �������ɹ����У���ʾ��ǰĿ�����������Ŀ��
 
################### SDCC������ص� #######################
#1. ��֧�ֶ���ļ����������ÿ��ֻ����һ��c�ļ���ÿ��c�ļ�����5���ļ���
#   .asm��.lst ��.rel ��.rst��.sym������ʱ�õ���.rel

#2. -cѡ��ֻ���벻���ӣ�-oѡ�����ָ������ļ���Ŀ¼����ΪĿ¼�������
#    ĩβ��Ŀ¼�ָ���ָ��(�����޷������ļ�����Ŀ¼)�����ɵ��ļ�ȫ�������
#    ��Ŀ¼��
#   file.c -->  file.asm file.lst file.rel file.rst file.sym in ./objs
#3.  ��Ŀ�ɶ���ļ���ɣ���main�������ļ�(main.c)���������ǰ��
#    main.rel f1.rel f2.rel ....  --> main.cdb main.ihx main.lk main.map main.mem 
#    main.omf in ./links
#4.  ��ihx�ļ�ת��hex�ļ�����bin�ļ�
#     packihx  xxx.ihx  >  yyy.hex
#     makebin -Z xxx.ihx  yyy.bin
 ########################################################
 
 #########################################################
 #��makefile��Ӧ�Ĺ���Ŀ¼��֯(project hierarchy)
 # ./ ------- project root
 #   +sources/
 #   +includes/
 #   +objs/
 #   +links
 #    TARGET
 #    makefile
 #�޸�ʱ������ʵ�ʸı���Ӧ��Ŀ¼������������./sources��Դ�ļ��б�
 #########################################################
 
TARGET = LED3.hex 

#ENVIRONMENT = wincmd
ENVIRONMENT = linux

##########Ŀ¼���� ##########
####���̸�Ŀ¼
PROJECT_ROOT = .
###Դ�����Ŀ¼####

ifeq ($(ENVIRONMENT),wincmd)
#CԴ����
SRC_DIR = $(PROJECT_ROOT)\sources

#�м�Ŀ���ļ�Ŀ¼objs
OBJS_DIR := $(PROJECT_ROOT)\objs

#�����м��ļ�Ŀ¼links
LINK_DIR := $(PROJECT_ROOT)\links
#�����н��������������ò�Ҫ��ĩβ��\��б������addprefix
else
SRC_DIR = $(PROJECT_ROOT)/sources

OBJS_DIR := $(PROJECT_ROOT)/objs

LINK_DIR := $(PROJECT_ROOT)/links
endif

#Դ�ļ��б�ע��˳��(main.c should be the FIRST and filename should contain NO SPACE)
APP_CSRCS = main.c common.c isr.c

############## ���·�� #############
ifeq ($(ENVIRONMENT),wincmd)
ifdef APP_CSRCS
CSRCS := $(addprefix $(SRC_DIR)\,$(APP_CSRCS))
endif
#CSRCS = $(APP_CSRCS)
#ò�����������Ҳ������ո�

#Ŀ���ļ����壬��·����ӽ���
COBJS := $(addprefix $(OBJS_DIR)\, $(patsubst %.c,%.rel,$(notdir $(CSRCS))))

else
ifdef APP_CSRCS
CSRCS := $(addprefix $(SRC_DIR)/,$(APP_CSRCS))
endif
#Ŀ���ļ����壬��·����ӽ���
COBJS := $(addprefix $(OBJS_DIR)/, $(patsubst %.c,%.rel,$(notdir $(CSRCS))))

endif


###########�������������#########
CC = sdcc 
#ע�� ���ں��൱��C�����еĺ궨��
MAKEHEX = packihx
MAKEBIN = makebin -Z

ifeq ($(ENVIRONMENT),wincmd)
RM = del  
#ע�� wincmd�½����ںź����rm��Ϊdel��linux��RM = rm

#ͷ�ļ�Ŀ¼
INC_DIR := .\includes 
#��������ͷ�ļ�Ŀ¼����ֱ�Ӻ������Ŀ¼���� ע��ǰ���-I

else
RM = rm
#ע�� wincmd�½����ںź����rm��Ϊdel��linux��RM = rm

#ͷ�ļ�Ŀ¼
INC_DIR := ./includes 
endif

#����ѡ��(ֻ���벻���ӣ�ѡ����ϵ�ṹ)
CFLAGS = -mmcs51 --model-small
CFLAGS += -I$(INC_DIR)

#����ѡ��(����Ŀ�ꡢģʽ)
LDFLAGS = 

#all : version $(target)	
all : hex

ifeq ($(ENVIRONMENT),wincmd)
hex:$(LINK_DIR)\main.ihx
	@echo "pack ihx --> hex"
	$(MAKEHEX) $(LINK_DIR)\main.ihx > $(TARGET)
	
$(LINK_DIR)\main.ihx:$(COBJS)
	@echo "����Ŀ���ļ�������ihx�ļ�"
	$(CC)  $(LDFLAGS) $(COBJS) -o$(LINK_DIR)\
	
bin:$(LINK_DIR)\main.ihx
	@echo "pack ihx --> binary(GameBoy format binary)"
	$(MAKEBIN) $(LINK_DIR)\main.ihx $(patsubst %.hex,%.bin,$(TARGET))
	
else
hex:$(LINK_DIR)/main.ihx
	@echo "pack ihx --> hex"
	$(MAKEHEX) $(LINK_DIR)/main.ihx > $(TARGET)
	
$(LINK_DIR)/main.ihx:$(COBJS)
	@echo "����Ŀ���ļ�������ihx�ļ�"
	$(CC)  $(LDFLAGS) $(COBJS) -o$(LINK_DIR)/

bin:$(LINK_DIR)/main.ihx
	@echo "pack ihx --> binary(GameBoy format binary)"
	$(MAKEBIN) $(LINK_DIR)/main.ihx $(patsubst %.hex,%.bin,$(TARGET))
endif

version :
	@echo "Show CC Version"
	$(CC) --version

# ����C���򣬴˹����д������Ҫ������
##################################  ������c��o�ļ��� ##############################
#��1��ֱ����Ŀ¼�����%��������κ�'\'����������ȷ��$(OBJS_DIR)\%.rel : $(SRC_DIR)\%.c��д��
#����\%��ת������������(��������win�µ�Ŀ¼�ָ���)������$(OBJS_DIR)\\%.rel : $(SRC_DIR)\%.c��ȷ
#��2��ͬʱ��������\\��ȴ���� .\sources\\printA.c --> .\objs\printA.rel(�����)��
#��3�б����ǰ�Ŀ���ļ���Դ�ļ���ֱ���г������������make��������
#��4��5�д���ͬ��3�У�makeҲ������
ifeq ($(ENVIRONMENT),wincmd)
$(OBJS_DIR)%.rel : $(SRC_DIR)%.c
#$(OBJS_DIR)\\%.rel : $(SRC_DIR)\\%.c
#$(COBJS)%.rel:$(CSRCS)%.c
#$(COBJS)\\%.rel:$(CSRCS)\%.c
	@echo ���ڱ���c�ļ��� $<
	$(CC) -c $(CFLAGS) $< -o$(OBJS_DIR)/
else
#linux��Ҫ��·�����ϣ���д %o %c
$(OBJS_DIR)/%.rel : $(SRC_DIR)/%.c
	@echo ���ڱ���c�ļ��� $<
	$(CC) -c $(CFLAGS) $< -o$(OBJS_DIR)/
endif
	
.PHONY:msg clean cleanobj cleanlink cleantar cleanbin
msg:
	@echo ENVIRONMENT��$(ENVIRONMENT)
	@echo TARGET��$(TARGET)
	@echo CSRCS��$(CSRCS)
	@echo COBJS��$(COBJS)
	@echo CFLAGS��$(CFLAGS)
	@echo RM������$(RM)
	
clean:cleanobjs cleanlinks cleantar cleanbin
	@echo "objsĿ¼�µ��ļ���linksĿ¼���ļ���hex�ļ���ɾ��" 
	
ifeq ($(ENVIRONMENT),wincmd)
cleanobjs:
	@echo ���objsĿ¼
	-$(RM) $(OBJS_DIR)\*.*
cleanlinks:
	@echo ���linksĿ¼
	-$(RM) $(LINK_DIR)\*.*
	
else
cleanobjs:
	@echo ���objsĿ¼
	-$(RM) $(OBJS_DIR)/*.*
cleanlinks:
	@echo ���linksĿ¼
	-$(RM) $(LINK_DIR)/*.*
endif

cleantar:
	@echo ɾ������Ŀ��hex�ļ�
	-$(RM) $(TARGET)

cleanbin:
	@echo ɾ��bin�ļ�
	-$(RM) $(patsubst %.hex,%.bin,$(TARGET))