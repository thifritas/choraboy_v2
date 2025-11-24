# PlayerData.gd (Singleton/Autoload)
extends Node

# Variáveis globais para armazenar as informações do jogador
var player_name: String = ""
var selected_character: String = "" # Pode ser "Mika" ou "Allan"
var car_color: Color = Color.WHITE # Cor inicial, vamos usar depois
var selected_map: String = "" # Mapa selecionado (São Paulo ou Rio de Janeiro)
var selected_car: String = "gol quadrado" # Carro inicial padrão
var selected_difficulty: String = ""

# Começa o jogador com 1200
var player_money: int = 1200

var car_ownership: Dictionary = {
	"gol quadrado": true,  # O carro inicial é sempre comprado
	"fusca": false # O Fusca começa bloqueado/não comprado
}

const CAR_ATTRIBUTES: Dictionary = {
	"gol quadrado": {
		"velocidade": 0.5,
		"frenagem": 0.7,
		"peso": 0.6,
		"resistencia": 0.5,
		"valor": 0 # Carro inicial, valor 0
	},
	"fusca": {
		"velocidade": 0.3,
		"frenagem": 0.9, # Freio melhor que o Gol
		"peso": 0.8,    # Mais pesado que o Gol
		"resistencia": 0.9,
		"valor": 1100  # Valor de compra
	}
}

# -------------------------------------------------------------------
# Documentação:
# 1. extends Node: Singleton não precisa de uma representação visual.
# 2. player_name: Variável para guardar o nome digitado.
# 3. selected_character: Variável para guardar qual dos dois foi escolhido.
# 4. car_color: Guardará a cor personalizada do carro (para o menu "Garagem").
# 5. selected_map: Guardará a escolha de pista (para o menu "Correr").
# -------------------------------------------------------------------
