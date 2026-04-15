extends Node

#两边玩家的进球数
var leftGoal:int = 0
var rightGoal:int = 0

#游玩时间设置
var matchTime:float = 180 #游玩时间一共多少秒
var choiceSide:bool = false #创建房间时选择的阵营,默认为左侧
