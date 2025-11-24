extends Node2D

# ==============================================================================
# 1. REFERÊNCIAS
# ==============================================================================
@onready var camada_pista: ParallaxLayer = $Cenario/CamadaPista
@onready var jogador_carro: Node2D = $JogadorCarro
@onready var camera: Camera2D = $Camera2D
@onready var roda_frente_visual: Node2D = $JogadorCarro/RodaFrente
@onready var roda_tras_visual: Node2D = $JogadorCarro/RodaTras

# --- HUD ---
@onready var acelerador_btn: TextureButton = $CanvasLayer/AceleradorButton
@onready var freio_btn: TextureButton = $CanvasLayer/FrearButton
@onready var seta_cima_btn: TextureButton = $CanvasLayer/SetaCimaButton
@onready var seta_baixo_btn: TextureButton = $CanvasLayer/SetaBaixoButton
@onready var ponteiro_rpm: TextureRect = $CanvasLayer/PainelVelocimetro/Ponteiro1
@onready var ponteiro_km: TextureRect = $CanvasLayer/PainelVelocimetro/Ponteiro2
@onready var label_tempo: Label = $CanvasLayer/PainelTempo/LabelTempo

# --- CONTAGEM REGRESSIVA (NOVO) ---
# Certifique-se de criar este Label na cena!
@onready var label_contagem: Label = $CanvasLayer/LabelContagem

# --- POPUPS ---
@onready var popups_container: Control = $CanvasLayer/PopupsContainer
@onready var popup_vitoria: TextureRect = $CanvasLayer/PopupsContainer/PopupVitoria
@onready var popup_derrota: TextureRect = $CanvasLayer/PopupsContainer/PopupDerrota
@onready var btn_resgatar: BaseButton = $CanvasLayer/PopupsContainer/PopupVitoria/BotaoResgatar
@onready var btn_inicio: BaseButton = $CanvasLayer/PopupsContainer/PopupDerrota/BotaoInicio

# ==============================================================================
# 2. CONFIGURAÇÕES
# ==============================================================================
var velocidade_atual: float = 0.0
var velocidade_maxima: float = 1200.0
var aceleracao: float = 600.0
var desaceleracao: float = 300.0
var forca_freio: float = 1000.0

var faixas_y = [334.0, 394.0, 454.0] 
var faixa_atual: int = 1
var velocidade_troca_faixa: float = 10.0

var angulo_minimo: float = -180.0
var angulo_maximo: float = 0

# Ajuste da Chegada
var tamanho_total_pista: float = 0.0
var cruzou_linha_chegada: bool = false 
var distancia_do_final_para_chegada: float = 1500.0 
var desaceleracao_final: float = 2000.0 

# Tempo
var tempo_restante: float = 60.0
var jogo_acabou_por_tempo: bool = false

# --- CONTROLE DE ESTADO (NOVO) ---
var corrida_iniciada: bool = false # Começa travado

var config_dificuldade = { "Fácil": 60.0, "Médio": 45.0, "Difícil": 30.0 }
var config_mapas = {
	"Rio de Janeiro": { "pasta": "res://Assets/Screen/FundoRJ/", "quantidade": 22 },
	"São Paulo": { "pasta": "res://Assets/Screen/FundoRJ/", "quantidade": 22 }
}

# ==============================================================================
# 3. FUNÇÕES PRINCIPAIS
# ==============================================================================

func _ready():
	print("--- Iniciando Tela da Pista ---")
	jogador_carro.z_index = 100 
	
	# Esconde popups e reseta estados
	popups_container.hide()
	popup_vitoria.hide()
	popup_derrota.hide()
	label_contagem.text = "" # Começa vazio
	corrida_iniciada = false # Trava o jogo
	
	btn_resgatar.pressed.connect(_on_botao_resgatar_pressed)
	btn_inicio.pressed.connect(_on_botao_inicio_pressed)
	
	# Carrega Mapa
	var mapa_escolhido = PlayerData.selected_map
	if config_mapas.has(mapa_escolhido):
		_gerar_pista_automatica(config_mapas[mapa_escolhido])
	else:
		_gerar_pista_automatica(config_mapas["Rio de Janeiro"])
	
	# Configura Tempo
	var dif = PlayerData.selected_difficulty
	if config_dificuldade.has(dif):
		tempo_restante = config_dificuldade[dif]
	else:
		tempo_restante = 45.0
	_atualizar_interface_tempo()
	
	# Posiciona Carro
	if faixas_y.size() > faixa_atual:
		jogador_carro.position.y = faixas_y[faixa_atual]
		jogador_carro.position.x = 200.0
		
		# Força a câmera a ir para a posição do carro IMEDIATAMENTE
		camera.position.x = jogador_carro.position.x + 400
		camera.position.y = 540
	
	seta_cima_btn.pressed.connect(_mudar_faixa_cima)
	seta_baixo_btn.pressed.connect(_mudar_faixa_baixo)
	
	# --- NOVO: Inicia a contagem regressiva ---
	_iniciar_contagem_regressiva()

func _process(delta):
	# --- TRAVA O JOGO SE A CONTAGEM NÃO ACABOU ---
	if not corrida_iniciada:
		return # Sai da função, nada abaixo acontece
		
	# --- LÓGICA DE TEMPO ---
	if not cruzou_linha_chegada and not jogo_acabou_por_tempo:
		tempo_restante -= delta
		if tempo_restante <= 0:
			tempo_restante = 0
			_game_over_por_tempo()
		_atualizar_interface_tempo()

	# Controles físicos
	_controlar_velocidade(delta)
	_controlar_ponteiros()
	_mover_carro_e_camera(delta)
	_suavizar_movimento_faixa(delta)
	_animar_rodas(delta)

# ==============================================================================
# 4. LÓGICA DA CONTAGEM REGRESSIVA (NOVO)
# ==============================================================================

func _iniciar_contagem_regressiva():
	# Garante que o label está visível
	label_contagem.show()
	
	# 3
	label_contagem.text = "3"
	print("Contagem: 3")
	await get_tree().create_timer(1.0).timeout
	
	# 2
	label_contagem.text = "2"
	print("Contagem: 2")
	await get_tree().create_timer(1.0).timeout
	
	# 1
	label_contagem.text = "1"
	print("Contagem: 1")
	await get_tree().create_timer(1.0).timeout
	
	# VAI!
	label_contagem.text = "VAI!"
	print("VAI!")
	
	# Libera o jogo!
	corrida_iniciada = true
	
	# Espera um pouquinho só para o jogador ler "VAI!" e depois esconde
	await get_tree().create_timer(0.5).timeout
	label_contagem.hide()

# ==============================================================================
# 5. MOVIMENTO E FIM DE JOGO
# ==============================================================================

func _mover_carro_e_camera(delta):
	jogador_carro.position.x += velocidade_atual * delta
	
	var ponto_chegada = tamanho_total_pista - distancia_do_final_para_chegada
	if not cruzou_linha_chegada and not jogo_acabou_por_tempo and jogador_carro.position.x >= ponto_chegada:
		_ao_cruzar_linha()
	
	camera.position.x = jogador_carro.position.x + 400
	camera.position.y = 540 

func _ao_cruzar_linha():
	print("CHEGADA DETECTADA!")
	cruzou_linha_chegada = true

func _game_over_por_tempo():
	print("TEMPO ESGOTADO!")
	jogo_acabou_por_tempo = true

func _mostrar_vitoria():
	if popups_container.visible: return
	popups_container.show()
	popup_vitoria.show()

func _mostrar_derrota():
	if popups_container.visible: return
	popups_container.show()
	popup_derrota.show()

func _atualizar_interface_tempo():
	var segundos = int(tempo_restante)
	label_tempo.text = str(segundos)

func _on_botao_resgatar_pressed():
	PlayerData.player_money += 200
	get_tree().change_scene_to_file("res://Scenes/TelaPrincipal.tscn")

func _on_botao_inicio_pressed():
	get_tree().change_scene_to_file("res://Scenes/TelaPrincipal.tscn")

# ==============================================================================
# 6. CONTROLES
# ==============================================================================

func _controlar_velocidade(delta):
	if cruzou_linha_chegada or jogo_acabou_por_tempo:
		velocidade_atual -= desaceleracao_final * delta
		if velocidade_atual <= 0:
			velocidade_atual = 0.0
			if cruzou_linha_chegada: _mostrar_vitoria()
			elif jogo_acabou_por_tempo: _mostrar_derrota()
		return 

	if acelerador_btn.button_pressed:
		velocidade_atual += aceleracao * delta
	elif freio_btn.button_pressed:
		velocidade_atual -= forca_freio * delta
	else:
		velocidade_atual -= desaceleracao * delta
	velocidade_atual = clamp(velocidade_atual, 0.0, velocidade_maxima)

func _controlar_ponteiros():
	var porcentagem = velocidade_atual / velocidade_maxima
	ponteiro_km.rotation_degrees = lerp(angulo_minimo, angulo_maximo, porcentagem)
	var porcentagem_rpm = clamp(porcentagem * 1.3, 0.0, 1.0)
	ponteiro_rpm.rotation_degrees = lerp(angulo_minimo, angulo_maximo, porcentagem_rpm)

func _animar_rodas(delta):
	if velocidade_atual <= 0: return
	var giro = velocidade_atual * delta * 0.5
	if roda_frente_visual: roda_frente_visual.rotation_degrees += giro
	if roda_tras_visual: roda_tras_visual.rotation_degrees += giro

func _mudar_faixa_cima():
	if not corrida_iniciada or cruzou_linha_chegada or jogo_acabou_por_tempo: return
	if faixa_atual > 0: faixa_atual -= 1

func _mudar_faixa_baixo():
	if not corrida_iniciada or cruzou_linha_chegada or jogo_acabou_por_tempo: return
	if faixa_atual < faixas_y.size() - 1: faixa_atual += 1

func _suavizar_movimento_faixa(delta):
	var destino_y = faixas_y[faixa_atual]
	jogador_carro.position.y = lerp(jogador_carro.position.y, destino_y, velocidade_troca_faixa * delta)

func _gerar_pista_automatica(config: Dictionary):
	var proxima_posicao_x = 0.0
	var escala_personalizada = Vector2(0.6, 0.6) 
	for i in range(1, config["quantidade"] + 1):
		var caminho = config["pasta"] + str(i) + ".png"
		var textura = load(caminho)
		if textura:
			var s = Sprite2D.new()
			s.texture = textura
			s.centered = false
			s.scale = escala_personalizada
			s.position.x = proxima_posicao_x
			s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			camada_pista.add_child(s)
			proxima_posicao_x += textura.get_width() * escala_personalizada.x
	tamanho_total_pista = proxima_posicao_x
	print("Pista gerada! Tamanho total: " + str(tamanho_total_pista))
