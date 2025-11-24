# PlayerVisual.gd
extends Node2D

@onready var carro_sprite: Sprite2D = $CarroSprite
@onready var personagem_sprite: Sprite2D = $PersonagemSprite

# Constantes para caminhos base (AJUSTE CONFORME SEUS ARQUIVOS)
const CAMINHO_CARROS: String = "res://Assets/Cars/"
const CAMINHO_PERSONAGENS: String = "res://Assets/Character/"

# Função chamada quando a cena é instanciada
func _ready():
	_carregar_visuais()
	# Aqui é o local ideal para definir a escala/tamanho do conjunto, se necessário

# Função principal para carregar os recursos dinamicamente
func _carregar_visuais():
	# 1. Obter informações do Singleton
	var carro_nome_interno: String = PlayerData.selected_car.to_lower()
	var personagem_nome_interno: String = PlayerData.selected_character.to_lower()
	var cor_selecionada: Color = PlayerData.car_color
	
	# Se o nome do personagem estiver vazio (ex: tela de seleção não foi usada), use um padrão
	if personagem_nome_interno.is_empty():
		personagem_nome_interno = "mika" # Personagem padrão, se nada foi escolhido

	# 2. Carregar e configurar o Carro
	var caminho_carro = CAMINHO_CARROS + carro_nome_interno + ".png" 
	if ResourceLoader.exists(caminho_carro):
		carro_sprite.texture = load(caminho_carro)
		carro_sprite.modulate = cor_selecionada # Aplica a cor do jogador
		carro_sprite.scale = Vector2(0.145, 0.145) #reduz o tamanho do carro
	else:
		printerr("AVISO: Imagem do carro não encontrada: " + caminho_carro)

	# 3. Carregar e configurar o Personagem
	var caminho_personagem = CAMINHO_PERSONAGENS + personagem_nome_interno + ".png" 
	if ResourceLoader.exists(caminho_personagem):
		personagem_sprite.texture = load(caminho_personagem)
		personagem_sprite.scale = Vector2(0.4, 0.4)
	else:
		printerr("AVISO: Imagem do personagem não encontrada: " + caminho_personagem)
		
		print("Visual do Jogador carregado: Carro " + carro_nome_interno + ", Personagem " + personagem_nome_interno)


# -------------------------------------------------------------------
# Documentação do PlayerVisual.gd:
# 1. _carregar_visuais(): Função dedicada a obter dados globais e carregar texturas.
# 2. Checagem de Personagem Vazio: Garante que um visual padrão seja carregado caso a seleção tenha sido pulada ou o valor inicial do Singleton não tenha sido alterado.
# 3. load() e ResourceLoader.exists(): Uso padrão da Godot para manipulação de arquivos de recursos.
# -------------------------------------------------------------------
