# TelaPreload.gd
extends Control

# Referências
@onready var tempo_preload: Timer = $TempoPreload

# O caminho para a próxima cena (a tela de Cadastro de Nome)
const PROXIMA_CENA: String = "res://Scenes/TelaCadastroNome.tscn"

func _ready():
	# O Timer já está configurado para iniciar automaticamente (Autostart)
	
	# Conecta o sinal 'timeout' do Timer à função de navegação.
	# Quando o tempo (3.0s, por exemplo) terminar, esta função será chamada.
	tempo_preload.timeout.connect(_on_tempo_preload_timeout)
	
	print("Preload iniciado. Esperando " + str(tempo_preload.wait_time) + " segundos.")

# Função chamada quando o cronômetro termina
func _on_tempo_preload_timeout():
	print("Tempo de preload esgotado. Navegando para a próxima cena.")
	
	# 1. Navegação: Mudar para a tela de Cadastro
	# Isso carrega a próxima cena e libera a memória da TelaPreload
	Transition.iniciar_transicao(PROXIMA_CENA)


# -------------------------------------------------------------------
# Documentação:
# 1. Timer: O coração do preload. Seu sinal 'timeout' dispara a ação.
# 2. _ready(): Conecta o sinal do Timer (tempo_preload.timeout) à função que avança o jogo.
# 3. _on_tempo_preload_timeout(): Executa a navegação via get_tree().change_scene_to_file().
# -------------------------------------------------------------------
