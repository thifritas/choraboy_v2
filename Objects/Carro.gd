# Carro.gd
extends CharacterBody2D

# --- PROPRIEDADES DO CARRO ---
const VELOCIDADE_LATERAL: int = 500  # Rapidez para mudar de faixa (em pixels/segundo)
const FAIXA_ALTURA: float = 100.0    # Distância entre as faixas

var velocidade_aceleracao: float = 0.0
var aceleracao_base: float = 300.0    # Aumento da velocidade (taxa de aceleração)
var velocidade_maxima: float = 800.0  # Limite de velocidade

var faixa_atual: int = 1 # 0 = Faixa de Cima, 1 = Faixa do Meio (se houver 3), 2 = Faixa de Baixo
var alvo_y: float = 0.0  # Posição Y (vertical) para onde o carro está se movendo

# --- VARIÁVEIS DE CONTROLE DE ENTRADA ---
var is_acelerando: bool = false
var is_freando: bool = false

# Chama quando a cena Carro é criada
func _ready():
	# Define a posição inicial na faixa do meio
	alvo_y = global_position.y
	# Opcional: Aqui você pode usar PlayerData.selected_car para carregar o sprite correto
	# Ex: $Sprite2D.texture = load("res://Assets/Carros/" + PlayerData.selected_car + ".png")


# Função de processamento de física (para movimento)
func _physics_process(delta):
	# 1. Lógica de Velocidade (Acelerar/Frear)
	if is_acelerando:
		velocidade_aceleracao += aceleracao_base * delta
	elif is_freando:
		velocidade_aceleracao -= aceleracao_base * delta * 2.0 # Frear mais rápido que acelerar
	else:
		# Se não estiver acelerando ou freando, ele desacelera lentamente
		velocidade_aceleracao = lerp(velocidade_aceleracao, 0.0, 0.05) 

	# Limita a velocidade (não pode ser mais que a máxima, nem menos que 0)
	velocidade_aceleracao = clamp(velocidade_aceleracao, 0.0, velocidade_maxima)
	
	# Define a componente horizontal do vetor de movimento
	velocity.x = velocidade_aceleracao
	
	# 2. Lógica de Movimento de Faixa (Movimento Lateral)
	# Move o carro suavemente em direção ao 'alvo_y' (a posição da faixa)
	global_position.y = lerp(global_position.y, alvo_y, delta * 10.0) 
	
	# Aplica o movimento e a colisão
	move_and_slide()


# --- FUNÇÕES CHAMADAS PELOS BOTÕES DA INTERFACE ---

# 1. Controle de Velocidade
func set_acelerar(acelerar: bool):
	is_acelerando = acelerar
	is_freando = false # Não pode acelerar e frear ao mesmo tempo

func set_frear(frear: bool):
	is_freando = frear
	is_acelerando = false # Não pode acelerar e frear ao mesmo tempo

# 2. Controle de Faixa
func ir_para_cima():
	# Se houver 2 faixas (0 e 1), ou 3 faixas (0, 1, 2)
	# Vamos assumir 2 faixas (0=Cima, 1=Baixo) para simplificar a lógica:
	# `faixa_atual` deve ser 0 para Cima, 1 para Baixo.
	
	var nova_faixa = max(0, faixa_atual - 1) # Garante que não vá para -1
	
	if nova_faixa != faixa_atual:
		faixa_atual = nova_faixa
		# Assume que Faixa 0 está 100px acima de Faixa 1.
		alvo_y = global_position.y - FAIXA_ALTURA
		print("Mudando para faixa de Cima (Faixa: " + str(faixa_atual) + ")")


func ir_para_baixo():
	# Vamos assumir 2 faixas: 0 (Cima) e 1 (Baixo).
	var nova_faixa = min(1, faixa_atual + 1) # Garante que não vá para 2
	
	if nova_faixa != faixa_atual:
		faixa_atual = nova_faixa
		# Assume que Faixa 1 está 100px abaixo de Faixa 0.
		alvo_y = global_position.y + FAIXA_ALTURA
		print("Mudando para faixa de Baixo (Faixa: " + str(faixa_atual) + ")")


# -------------------------------------------------------------------
# Documentação do Carro.gd:
# 1. extends CharacterBody2D: O nó ideal para mover um corpo 2D com física.
# 2. velocity: Vetor interno do CharacterBody2D. move_and_slide() usa este vetor.
# 3. alvo_y: A posição Y da faixa que o carro está tentando alcançar.
# 4. _physics_process: Onde a lógica de aceleração/freio e o movimento de faixa são aplicados.
# 5. lerp(...): Função de interpolação que move a posição 'y' suavemente até 'alvo_y' (efeito de mudança de faixa suave).
# 6. set_acelerar/set_frear: Funções que controlam o estado de aceleração/freio do carro.
# 7. ir_para_cima/ir_para_baixo: Funções que calculam a nova faixa, ajustam `alvo_y` e controlam os limites (0 e 1).
# -------------------------------------------------------------------
