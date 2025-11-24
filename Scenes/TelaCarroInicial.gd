extends Control

@onready var voltar_button: Button = $VoltarButton
@onready var confirmar_button: Button = $ConfirmarButton

func _ready():
	
	voltar_button.pressed.connect(_on_voltar_button_pressed)
	confirmar_button.pressed.connect(_on_confirmar_button_pressed)
	

func _on_voltar_button_pressed():
	# Caminho para a cena da tela de Cadastro de Nome.
	# Lembre-se de verificar se este é o caminho correto que você usou no Passo 2.
	var caminho_cena_selecao: String = "res://Scenes/TelaSelecaoPersonagem.tscn"
	
	print("Voltando para a tela de Tela Selecao Personagem.")
	get_tree().change_scene_to_file(caminho_cena_selecao)

func _on_confirmar_button_pressed():
	Transition.iniciar_transicao("res://Scenes/TelaPrincipal.tscn")
