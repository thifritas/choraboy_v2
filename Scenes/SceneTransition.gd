# SceneTransition.gd
extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var fade_rect: ColorRect = $FadeRect

# Variável de instância para armazenar o caminho da nova cena
var next_scene_path: String = "" 

# Sinal para indicar que o fade-out terminou (opcional, para lógica avançada)
signal fade_out_concluido


func _ready():
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Garante que o retângulo comece totalmente transparente
	var cor = fade_rect.color
	cor.a = 0.0
	fade_rect.color = cor
	
	# Conecta o sinal de término da animação ao nosso gerenciador principal
	animation_player.animation_finished.connect(_on_animation_finished)
	
	# O AnimationPlayer precisa estar na posição final (transparente)
	animation_player.play("fade_in_out") 
	animation_player.advance(animation_player.get_current_animation_length())
	animation_player.stop()

# -------------------------------------------------------------------
# Método principal para iniciar a transição (Chamado de outros scripts)
# -------------------------------------------------------------------
func iniciar_transicao(scene_path: String):
	fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	# 1. Salvar o caminho da cena na variável de instância
	next_scene_path = scene_path
	
	# 2. Conectar o sinal de término do Fade-in (se ainda não estiver conectado)
	# Usamos CONNECT_ONE_SHOT no Godot 3/4 para garantir que a função seja chamada 
	# apenas uma vez após o término da animação
	if not animation_player.is_connected("animation_finished", Callable(self, "_on_mid_transition")):
		animation_player.connect("animation_finished", Callable(self, "_on_mid_transition"), CONNECT_ONE_SHOT)
		
	# 3. Faz o Fade-in (Escurece a tela: 0.0 Alpha -> 1.0 Alpha)
	animation_player.play("fade_in_out") 


# -------------------------------------------------------------------
# Chamado APÓS o Fade-in (tela totalmente preta)
# -------------------------------------------------------------------
func _on_mid_transition(anim_name: String):
	if anim_name == "fade_in_out":
		
		# 1. Troca a cena (o jogador não vê, pois a tela está preta)
		var cena_atual = get_tree().current_scene.name
		
		# Usa a variável de instância salva
		get_tree().change_scene_to_file(next_scene_path) 
		
		print("Cena trocada de " + cena_atual + " para " + next_scene_path.get_file().get_basename())
		
		# 2. Inverte a animação para o Fade-out (Clarear: 1.0 Alpha -> 0.0 Alpha)
		animation_player.play_backwards("fade_in_out")


# -------------------------------------------------------------------
# Chamado APÓS o Fade-out (tela transparente)
# -------------------------------------------------------------------
func _on_animation_finished(anim_name: String):
	if anim_name == "fade_in_out":
		# Se a animação terminou de rodar para trás (fade-out concluído)
		if animation_player.speed_scale < 0 or animation_player.current_animation_position == 0: 
			emit_signal("fade_out_concluido")
			fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			
			print("Transição concluída!")
			# Retorna o speed_scale para o padrão para a próxima transição
			animation_player.speed_scale = 1.0
