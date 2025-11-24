# TelaLoja.gd
extends Control

# --- DADOS INTERNOS ---
const CARROS: Array[String] = ["gol quadrado", "fusca"] # Nomes internos dos carros
var indice_carro_atual: int = 0

@onready var visual_carro: TextureRect = $Carro

@onready var dinheiro_label: Label = $DinheiroLabel

# --- REFERÊNCIAS ---
# Carrossel
@onready var nome_carro_label: Label = $NomeCarroLabel
@onready var seta_esquerda_button: Button = $SetaEsquerdaButton
@onready var seta_direita_button: Button = $SetaDireitaButton

# Status e Compra
@onready var status_compra_label: Label = $StatusCompraLabel
@onready var comprar_button: Button = $ComprarButton
@onready var voltar_button: Button = $VoltarButton

# Barras de Atributos (ProgressBar)
@onready var velocidade_bar: ProgressBar = $VelocidadeBar
@onready var frenagem_bar: ProgressBar = $FrenagemBar
@onready var peso_bar: ProgressBar = $PesoBar
@onready var resistencia_bar: ProgressBar = $ResistenciaBar

#POPUP erro
@onready var warning_popup_layer: CanvasLayer = $ConfigPopupLayer
@onready var fechar_config_button: TextureButton = $ConfigPopupLayer/Panel/FecharButton

@onready var warning: Label = $ConfigPopupLayer/Panel/ErrorMessage

func _ready():
	# 1. Configurar Carrossel e Voltar
	seta_esquerda_button.pressed.connect(func(): _mudar_carro(-1))
	seta_direita_button.pressed.connect(func(): _mudar_carro(1))
	voltar_button.pressed.connect(_on_voltar_button_pressed)
	
	# 2. Conexão do Botão de Compra
	comprar_button.pressed.connect(_on_comprar_button_pressed)
	
	#garantir que o popup esteja escondido
	fechar_config_button.pressed.connect(_on_fechar_aviso)
	warning_popup_layer.hide()
	
	# 3. Inicialização
	_atualizar_carrossel()
	_atualizar_dinheiro_label()


#Lógica popup

func _on_abrir_aviso():
	warning_popup_layer.show()
	print("Popup de aviso aberto.")

func _on_fechar_aviso():
	warning_popup_layer.hide()
	print("Popup de aviso fechado.")

	# 3. Inicialização
	_atualizar_carrossel()

# --- LÓGICA DO CARROSSEL ---

func _mudar_carro(direcao: int):
	# Lógica de loop (similar à Garagem)
	indice_carro_atual = (indice_carro_atual + direcao) % CARROS.size()
	if indice_carro_atual < 0:
		indice_carro_atual += CARROS.size()
		
	_atualizar_carrossel()


func _atualizar_carrossel():
	var carro_atual_nome_interno: String = CARROS[indice_carro_atual]

	# Retorna o valor de posse ou 'false' se não existir a chave
	var is_comprado: bool = PlayerData.car_ownership.get(carro_atual_nome_interno, false) 
	
	# 1. Atualiza Nome do Carro
	nome_carro_label.text = carro_atual_nome_interno.capitalize()
	
	if carro_atual_nome_interno == "gol quadrado":
		visual_carro.texture = load("res://Objects/Carro_Gol.png")
	elif carro_atual_nome_interno == "fusca":
		visual_carro.texture = load("res://Assets/Cars/Fusca.png")
	else:
		print("AVISO: Nenhum carro selecionado. Escondendo o sprite.")
		visual_carro.visible = false
	
	# 2. Atualiza Status de Compra e Botão
	_atualizar_status_compra(carro_atual_nome_interno, is_comprado)
	
	# 3. Atualiza Barras de Atributos
	_atualizar_barras_atributos(carro_atual_nome_interno)

# --- LÓGICA DE ATRIBUTOS E STATUS ---

func _atualizar_barras_atributos(carro_nome: String):
	var atributos: Dictionary = PlayerData.CAR_ATTRIBUTES.get(carro_nome, {})
	
	if atributos.is_empty():
		printerr("Erro: Atributos não definidos para o carro: " + carro_nome)
		return
	
	# Configura o range do ProgressBar para 0.0 a 1.0 (ajuste de Stack Overflow)
	# Se já configurado no editor, estas linhas são opcionais, mas seguras.
	velocidade_bar.min_value = 0.0
	velocidade_bar.max_value = 1.0
	frenagem_bar.min_value = 0.0
	frenagem_bar.max_value = 1.0
	peso_bar.min_value = 0.0
	peso_bar.max_value = 1.0
	resistencia_bar.min_value = 0.0
	resistencia_bar.max_value = 1.0
		
	# Define o valor do progresso
	velocidade_bar.value = atributos.velocidade
	frenagem_bar.value = atributos.frenagem
	peso_bar.value = atributos.peso
	resistencia_bar.value = atributos.resistencia

func _atualizar_status_compra(carro_nome: String, is_comprado: bool):
	# O valor é pego do dicionário estático (CAR_ATTRIBUTES)
	var valor: int = PlayerData.CAR_ATTRIBUTES.get(carro_nome, {}).get("valor", 0)
	
	var is_currently_selected: bool = (carro_nome == PlayerData.selected_car)
	
	if is_comprado:
		status_compra_label.text = ""
		if is_currently_selected:
			# Se já está selecionado, desativa o botão e muda o texto
			comprar_button.disabled = true
			comprar_button.text = "SELECIONADO"
			comprar_button.modulate = Color(0.7, 1.0, 0.7) # Feedback visual (verde claro)
		else:
			# Se está comprado, mas não selecionado, permite a seleção
			comprar_button.disabled = false
			comprar_button.text = "SELECIONAR"
			comprar_button.modulate = Color.WHITE # Cor padrão
	else:
		status_compra_label.text = ""
		comprar_button.disabled = false
		comprar_button.text = "COMPRAR - $" + str(valor)
		comprar_button.modulate = Color.WHITE #padrão

	# Trata o carro inicial
	if carro_nome == "gol quadrado":
		if is_currently_selected:
			comprar_button.disabled = true
			comprar_button.text = "SELECIONADO"
			comprar_button.modulate = Color(0.7, 1.0, 0.7)
		else:
			comprar_button.disabled = false
			comprar_button.text = "SELECIONAR"
			comprar_button.modulate = Color.WHITE
# --- LÓGICA DE COMPRA ---

func _on_comprar_button_pressed():
	var carro_atual: String = CARROS[indice_carro_atual]
	var is_comprado: bool = PlayerData.car_ownership.get(carro_atual, false)
	
	if is_comprado:
		# LÓGICA DE SELEÇÃO: Se o carro já é seu
		PlayerData.selected_car = carro_atual
		print("Carro selecionado: " + carro_atual)
	else:
		# LÓGICA DE COMPRA: Se o carro ainda não é seu
		var valor_carro: int = PlayerData.CAR_ATTRIBUTES.get(carro_atual, {}).get("valor", 0)
	
		if PlayerData.player_money >= valor_carro:
		# A. TRANSAÇÃO: Subtrair o dinheiro
			PlayerData.player_money -= valor_carro
		# B. ATUALIZAR POSSE: Marcar carro como comprado
			PlayerData.car_ownership[carro_atual] = true
			print("✅ Compra bem-sucedida!")
			print("Carro comprado: " + carro_atual.capitalize())
			print("Novo Saldo: $" + str(PlayerData.player_money))
			warning.text = "Compra realizada com sucesso"
			
			PlayerData.selected_car = carro_atual
			
			_on_abrir_aviso()
			_atualizar_dinheiro_label()
		
		else:
		# C. FALHA NA COMPRA: Saldo Insuficiente
			print("❌ FALHA: Saldo insuficiente!")
			print("Seu Saldo: $" + str(PlayerData.player_money) + ", Preço do Carro: $" + str(valor_carro))
			warning.text = "Saldo insuficiente"
			_on_abrir_aviso()
		
		return # Sai da função
		
	# 2. Atualiza o status de posse global
	PlayerData.car_ownership[carro_atual] = true
	print("Carro comprado com sucesso: " + carro_atual)
	
	# 3. Atualiza a interface, usando call_deferred para EVITAR STACK OVERFLOW
	# Isso garante que a atualização ocorra após o processamento do clique.
	call_deferred("_atualizar_carrossel")

# --- NAVEGAÇÃO ---

func _on_voltar_button_pressed():
	Transition.iniciar_transicao("res://Scenes/TelaPrincipal.tscn")
	print("Voltando para o Menu Principal.")
	
func _atualizar_dinheiro_label():
	var dinheiro_atual: int = PlayerData.player_money
	dinheiro_label.text = "$ " + str(dinheiro_atual) + ",00"

# -------------------------------------------------------------------
# Documentação do TelaLoja.gd:
# 1. CARROS: Lista dos carros para controlar o carrossel.
# 2. _atualizar_carrossel(): Função principal que coordena as atualizações.
# 3. _atualizar_barras_atributos(): Obtém os valores de 0.0 a 1.0 do PlayerData.CAR_ATTRIBUTES e define o 'value' das ProgressBars.
# 4. _atualizar_status_compra(): Verifica 'PlayerData.car_ownership' e ajusta o texto e o estado 'disabled' do botão de compra.
# 5. _on_comprar_button_pressed(): Lógica onde o carro é marcado como 'true' no dicionário 'car_ownership' e a tela é atualizada.
# -------------------------------------------------------------------
