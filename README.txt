H是备选信道；

Hr是在MBER规则下选出的信道；

Chan_MMI_e4和Chan_MMI_e5是在规则MMI规则下选出的信道（e4、e5表示数据长度为1e4、1e5）；

MMI_selection_2.m是MMI天线选择的代码，可产生Chan_MMI_e4或Chan_MMI_e5；

MIMO_MBERorMMI_SIC.m是应用选择出的信道进行干扰取消的代码，对MBER和MMI进行了对比；

sic是实现干扰取消的函数；

注：H、Hr是陈老师给的，这里直接用了，没有再实现。