extends Control

# --- REFERÊNCIAS DOS BOTÕES ---
@onready var garagem_image_button: TextureButton = $GaragemButton
@onready var configuracao_button: TextureButton = $ConfigButton
@onready var correr_image_button: TextureButton = $CorrerButton
@onready var dinheiro_label: Label = $DinheiroLabel

# --- REFERÊNCIAS VISUAIS ---
@onready var personagem_sprite: TextureRect = $PersonagemSprite
@onready var car_container: Control = $CarContainer
@onready var chassis: TextureRect = $CarContainer/Chassis
@onready var roda_frente: TextureRect = $CarContainer/RodaFrente
@onready var roda_tras: TextureRect = $CarContainer/RodaTras

# --- REFERÊNCIAS DO POPUP DE CONFIGURAÇÕES ---
@onready var config_popup_layer: CanvasLayer = $ConfigPopupLayer
@onready var fechar_config_button: TextureButton = $ConfigPopupLayer/Panel/FecharButton
@onready var salvar_config_button: TextureButton = $ConfigPopupLayer/SalvarButton
@onready var sair_conta_button: TextureButton = $ConfigPopupLayer/SairContaButton

### NOVO: REFERÊNCIAS DOS BOTÕES DE ÁUDIO ###
# (ASSUMINDO que eles estão dentro do 'Panel' e se chamam assim)
@onready var musica_button: TextureButton = $ConfigPopupLayer/Panel/MusicaButton
@onready var som_button: TextureButton = $ConfigPopupLayer/Panel/SomButton
@onready var vibra_button: TextureButton = $ConfigPopupLayer/Panel/VibraButton

# --- VARIÁVEIS DE ANIMAÇÃO ---
var correr_button_pos_original: Vector2
var is_car_moving: bool = false
var rotation_speed: float = 360.0

### NOVO: VARIÁVEIS DE ESTADO DAS CONFIGURAÇÕES ###
var is_music_on: bool = true
var is_sfx_on: bool = true
var is_vibration_on: bool = true

#Referencias da Profile Info
@onready var personagem_icone: TextureRect = $ProfileInfo/PersonagemIcone
@onready var nome_label: Label = $ProfileInfo/NomeJogador

const CAMINHO_ICONES_PERSONAGENS: String = "res://Assets/Screen/buttons/"

# -------------------------------------------------------------------
# A Função _ready() COMEÇA AQUI
# -------------------------------------------------------------------
func _ready():
	# Conecta os botões do menu
	garagem_image_button.pressed.connect(func(): _ir_para("Garagem"))
	correr_image_button.pressed.connect(func(): _ir_para("Correr"))
	configuracao_button.pressed.connect(_on_abrir_configuracoes)
	
	# Conexões dos botões do popup
	fechar_config_button.pressed.connect(_on_fechar_configuracoes)
	salvar_config_button.pressed.connect(_on_fechar_configuracoes)
	sair_conta_button.pressed.connect(_on_sair_da_conta)
	
	### NOVO: Conexões dos botões de áudio ###
	musica_button.pressed.connect(_on_musica_button_pressed)
	som_button.pressed.connect(_on_som_button_pressed)
	vibra_button.pressed.connect(_on_vibra_button_pressed)
	
	# Garantir que o popup começa escondido
	config_popup_layer.hide()
	
	# Configura a tela
	_carregar_visual_personagem()
	_animar_botao_correr()
	_atualizar_dinheiro_label()
	_animar_carro_entrada()
	_exibir_info_jogador()
	
	### NOVO: Define o visual inicial dos botões de áudio ###
	_update_audio_visuals()
# 
# A Função _ready() TERMINA AQUI
# -------------------------------------------------------------------


### FUNÇÕES DO POPUP DE CONFIGURAÇÕES ###

func _on_abrir_configuracoes():
	config_popup_layer.show()
	print("Popup de Configurações aberto.")

func _on_fechar_configuracoes():
	config_popup_layer.hide()
	print("Popup de Configurações fechado.")

func _on_sair_da_conta():
	config_popup_layer.hide()
	PlayerData.player_name = ""
	PlayerData.selected_character = ""
	PlayerData.player_money = 0
	get_tree().change_scene_to_file("res://Scenes/TelaCadastroNome.tscn")
	print("Saindo da conta e voltando para TelaCadastroNome.")

### NOVO: FUNÇÕES DE TOGGLE DOS BOTÕES DE ÁUDIO ###

func _on_musica_button_pressed():
	# Inverte o valor (se era 'true', vira 'false', e vice-versa)
	is_music_on = !is_music_on
	print("Música On: ", is_music_on)
	_update_audio_visuals()

func _on_som_button_pressed():
	is_sfx_on = !is_sfx_on
	print("SFX On: ", is_sfx_on)
	_update_audio_visuals()

func _on_vibra_button_pressed():
	is_vibration_on = !is_vibration_on
	print("Vibração On: ", is_vibration_on)
	_update_audio_visuals()

# -------------------------------------------------------------------
# A FUNÇÃO AJUSTADA ESTÁ AQUI
# -------------------------------------------------------------------
### NOVO: FUNÇÃO PARA ATUALIZAR O VISUAL DOS BOTÕES ###

func _update_audio_visuals():
	
	# Define a cor "desativada". 
	# (0.3, 0.3, 0.3) é um cinza escuro. 
	# Pode ajustar (ex: 0.5, 0.5, 0.5 para cinza médio)
	var cor_desativada = Color(0.3, 0.3, 0.3, 1.0)
	var cor_ativada = Color.WHITE # Cor normal
	
	# --- Música ---
	if is_music_on:
		musica_button.modulate = cor_ativada
	else:
		musica_button.modulate = cor_desativada
		
	# --- Som (SFX) ---
	if is_sfx_on:
		som_button.modulate = cor_ativada
	else:
		som_button.modulate = cor_desativada

	# --- Vibração ---
	if is_vibration_on:
		vibra_button.modulate = cor_ativada
	else:
		vibra_button.modulate = cor_desativada

# -------------------------------------------------------------------
# Funções existentes
# -------------------------------------------------------------------

func _process(delta):
	if is_car_moving:
		roda_frente.rotation_degrees += rotation_speed * delta
		roda_tras.rotation_degrees += rotation_speed * delta

func _ir_para(destino: String):
	var caminho_cena: String = ""
	match destino:
		"Garagem":
			caminho_cena = "res://Scenes/TelaGaragem.tscn"
		"Correr":
			caminho_cena = "res://Scenes/TelaSelecaoMapa.tscn"
		"Configuracao":
			print("Botão de Configuração agora abre um popup.")
			return
		_:
			print("Erro de navegação: Destino desconhecido: " + destino)
			return
	if caminho_cena != "":
		Transition.iniciar_transicao(caminho_cena)

func _carregar_visual_personagem():
	var personagem_escolhido: String = PlayerData.selected_character
	if personagem_escolhido == "Mika":
		personagem_sprite.texture = load("res://Objects/Personagens/Personagem_Mika.png")
	elif personagem_escolhido == "Allan":
		personagem_sprite.texture = load("res://Objects/Personagens/Personagem_Allan.png")
	else:
		print("AVISO: Nenhum personagem selecionado. Escondendo o sprite.")
		personagem_sprite.visible = false

func _animar_botao_correr():
	correr_button_pos_original = correr_image_button.position
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(
		correr_image_button, "position:x", correr_button_pos_original.x + 10, 0.5
	).set_trans(Tween.TRANS_SINE)
	tween.tween_property(
		correr_image_button, "position:x", correr_button_pos_original.x, 0.5
	).set_trans(Tween.TRANS_SINE)
	tween.tween_interval(0.3)

func _atualizar_dinheiro_label():
	var dinheiro_atual: int = PlayerData.player_money
	dinheiro_label.text = "$ " + str(dinheiro_atual) + ",00"

func _animar_carro_entrada():
	var pos_final_x = car_container.position.x
	if car_container.size.x == 0:
		print("AVISO: O 'Size' do CarContainer é 0. A animação pode falhar.")
		print("Ajusta o 'Size' do CarContainer no Inspetor (Layout -> Transform)")
	
	var start_pos_x = -car_container.size.x - 400 
	
	car_container.position.x = start_pos_x
	is_car_moving = true
	
	var tween = create_tween()
	
	tween.tween_property(car_container, "position:x", pos_final_x, 2.0)\
		 .set_trans(Tween.TRANS_CUBIC)\
		 .set_ease(Tween.EASE_OUT)
		 
	tween.finished.connect(_on_carro_animacao_terminada)

func _on_carro_animacao_terminada():
	is_car_moving = false
	print("Animação do carro principal concluída.")
	
	
func _exibir_info_jogador():
	var nome: String = PlayerData.player_name
	var personagem_nome: String = PlayerData.selected_character.to_lower()
	
	# 1. Exibir o Nome do Jogador
	nome_label.text = nome
	
	# 2. Carregar o Ícone do Personagem
	# Assumimos que o nome do arquivo do ícone é o nome do personagem + "_icon.png"
	var caminho_icone = CAMINHO_ICONES_PERSONAGENS + personagem_nome + "_icon.png" 
	
	if ResourceLoader.exists(caminho_icone):
		personagem_icone.texture = load(caminho_icone)
	else:
		# Se o ícone não for encontrado, usa uma cor ou um placeholder
		print("AVISO: Ícone do personagem não encontrado em: " + caminho_icone)
		# Opcional: Você pode definir uma cor de fundo para o TextureRect para debug
		# personagem_icone.modulate = Color.RED
