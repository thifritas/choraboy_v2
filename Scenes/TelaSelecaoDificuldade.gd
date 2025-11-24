extends Control

# --- Referências aos botões ---
# (Tipo corrigido de 'Button' para 'TextureButton' nos botões de dificuldade)
@onready var facil_button: TextureButton = $Fundo_Mapas/FacilButton
@onready var medio_button: TextureButton = $Fundo_Mapas/MedioButton
@onready var dificil_button: TextureButton = $Fundo_Mapas/DificilButton

# !!! CORREÇÃO AQUI !!!
# O nó 'VoltarButton' na tua cena é um 'Button' normal, e não um 'TextureButton'.
# Mudámos o tipo da variável para 'Button' para corresponder ao nó.
@onready var voltar_button: Button = $Fundo_Mapas/VoltarButton

func _ready():
	# Conecta os botões de dificuldade
	facil_button.pressed.connect(func(): _selecionar_dificuldade("Fácil"))
	medio_button.pressed.connect(func(): _selecionar_dificuldade("Médio"))
	dificil_button.pressed.connect(func(): _selecionar_dificuldade("Difícil"))
	
	# Conecta o botão de Voltar
	voltar_button.pressed.connect(_on_voltar_button_pressed)

# -------------------------------------------------------------------
# Funções de Seleção
# -------------------------------------------------------------------

# Função 'async' para poder usar 'await' (a pausa)
func _selecionar_dificuldade(nivel: String) -> void:
	
	# 1. Desativa os botões para evitar cliques duplos
	facil_button.disabled = true
	medio_button.disabled = true
	dificil_button.disabled = true
	voltar_button.disabled = true
	
	# 2. Aplica o destaque visual (o efeito verde)
	_atualizar_destaque_visual(nivel)
	
	# 3. A PAUSA MÁGICA
	await get_tree().create_timer(0.5).timeout
	
	# 4. Armazenar no Singleton
	PlayerData.selected_difficulty = nivel
	print("Dificuldade selecionada: " + nivel)
	
	# 5. Navegação: Mudar para a tela da Pista
	get_tree().change_scene_to_file("res://Scenes/TelaPista.tscn")

# Função para aplicar o efeito verde
func _atualizar_destaque_visual(nivel_selecionado: String):
	
	# Reseta todos para a cor normal
	facil_button.modulate = Color.WHITE
	medio_button.modulate = Color.WHITE
	dificil_button.modulate = Color.WHITE
	
	# Pinta o botão selecionado de verde
	if nivel_selecionado == "Fácil":
		facil_button.modulate = Color.LIME_GREEN
	elif nivel_selecionado == "Médio":
		medio_button.modulate = Color.LIME_GREEN
	elif nivel_selecionado == "Difícil":
		dificil_button.modulate = Color.LIME_GREEN

# -------------------------------------------------------------------
# Funções de Navegação
# -------------------------------------------------------------------

func _on_voltar_button_pressed():
	# Volta para a tela anterior (Seleção de Mapa)
	get_tree().change_scene_to_file("res://Scenes/TelaSelecaoMapa.tscn")
	print("Voltando para a Seleção de Mapa.")
