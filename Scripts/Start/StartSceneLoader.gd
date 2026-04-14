extends Node

const baseScenePath:String = "res://Scenes/"

func ShiftScene(sceneName:String,isFullPath:bool = false):
	var realScenePath = ""
	if isFullPath:
		realScenePath = sceneName
	else:
		realScenePath = baseScenePath + sceneName
	if realScenePath != "":
		var scene = load(realScenePath)
		if scene:
			get_tree().change_scene_to_packed(scene)
	pass
	
