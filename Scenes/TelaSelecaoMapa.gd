extends Control

# --- Referências aos botões (os pais) ---
@onready var sao_paulo_button: Button = $SaoPauloButton
@onready var rio_de_janeiro_button: Button = $RioJaneiro
@onready var voltar_button: Button = $VoltarButton

func _ready():
	# Conecta os botões à função 'async'
	sao_paulo_button.pressed.connect(func(): _selecionar_e_avancar("São Paulo"))
	rio_de_janeiro_button.pressed.connect(func(): _selecionar_e_avancar("Rio de Janeiro"))
	
	# Conecta o botão de Voltar
	voltar_button.pressed.connect(_on_voltar_button_pressed)

# -------------------------------------------------------------------
# Funções de Seleção
# -------------------------------------------------------------------

# Função 'async' para poder usar 'await' (a pausa)
func _selecionar_e_avancar(nome_mapa: String) -> void:
	
	### AJUSTADO AQUI ###
	# 1. Desativa os botões de mapa para evitar cliques duplos.
	#    (Não vamos desativar o 'voltar_button' aqui)
	sao_paulo_button.disabled = true
	rio_de_janeiro_button.disabled = true
	
	# 2. Aplica o destaque visual (o efeito verde)
	_atualizar_destaque_visual(nome_mapa)
	
	# 3. A PAUSA MÁGICA
	#    Espera 0.5 segundos para o jogador ver o efeito verde.
	await get_tree().create_timer(0.5).timeout
	
	# 4. Armazenar no Singleton (Salva permanentemente)
	PlayerData.selected_map = nome_mapa
	print("Mapa selecionado: " + nome_mapa)
	
	# 5. Navegação: Mudar para a próxima tela
	get_tree().change_scene_to_file("res://Scenes/TelaSelecaoDificuldade.tscn")

### A LÓGICA DA TELA DE PERSONAGEM, SÓ COM 'MODULATE' ###
func _atualizar_destaque_visual(nome_mapa_selecionado: String):
	
	# Reseta todos para a cor normal (Branco = sem tinta)
	sao_paulo_button.modulate = Color.WHITE
	rio_de_janeiro_button.modulate = Color.WHITE
	
	# Pinta o botão selecionado de verde (o botão PAI e seus filhos)
	if nome_mapa_selecionado == "São Paulo":
		sao_paulo_button.modulate = Color.LIME_GREEN # Destaque visual
	elif nome_mapa_selecionado == "Rio de Janeiro":
		rio_de_janeiro_button.modulate = Color.LIME_GREEN # Destaque visual

# -------------------------------------------------------------------
# Funções de Navegação
# -------------------------------------------------------------------

# Esta função só é chamada se o botão 'voltar_button' for clicado.
# Ela não precisa de alterações.
func _on_voltar_button_pressed():
	Transition.iniciar_transicao("res://Scenes/TelaPrincipal.tscn")
	print("Voltando para o Menu Principal.")
