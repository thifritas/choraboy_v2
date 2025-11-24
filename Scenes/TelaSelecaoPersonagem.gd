# TelaSelecaoPersonagem.gd
extends Control

# Referências aos botões
@onready var mika_button: Button = $Button
@onready var allan_button: Button = $Button2 # Renomeie o segundo botão para Button2 no editor ou use o nome que ele tiver.
@onready var saudacao_label: Label = $SaudacaoLabel
@onready var voltar_button: Button = $VoltarButton
@onready var confirmar_button: Button = $ConfirmarButton

var escolha_temporaria: String = ""

func _ready():
	# Conecta os sinais 'pressed' dos botões às suas respectivas funções
	mika_button.pressed.connect(func(): _selecionar_personagem_visual("Mika"))
	allan_button.pressed.connect(func(): _selecionar_personagem_visual("Allan"))
	
	voltar_button.pressed.connect(_on_voltar_button_pressed)
	
	confirmar_button.pressed.connect(_on_confirmar_button_pressed)
	# Opcional: Mostra o nome do jogador salvo na tela anterior
	print("Bem-vindo(a), " + PlayerData.player_name + "! Selecione um personagem.")
	_mostrar_saudacao()
	
	confirmar_button.disabled = true

func _on_voltar_button_pressed():
	# Caminho para a cena da tela de Cadastro de Nome.
	# Lembre-se de verificar se este é o caminho correto que você usou no Passo 2.
	var caminho_cena_cadastro: String = "res://Scenes/TelaCadastroNome.tscn"
	
	print("Voltando para a tela de Cadastro de Nome.")
	get_tree().change_scene_to_file(caminho_cena_cadastro)

# Função principal para selecionar o personagem e avançar
func _selecionar_personagem_visual(nome_personagem: String):
	# 1. Armazenar no Singleton: Salvar a escolha globalmente
	escolha_temporaria = nome_personagem
	print("Personagem selecionado visualmente: " + nome_personagem)
	
	_atualizar_destaque_visual(nome_personagem)
	
	confirmar_button.disabled = false
	
	# 2. Navegação: Mudar para a próxima tela (Menu Principal)
	# OBS: Você precisará criar a cena "TelaPrincipal.tscn" em seguida.

func _on_confirmar_button_pressed():
	
	# Verificação de segurança (deve ser sempre TRUE aqui, pois o botão está ativo)
	if escolha_temporaria.is_empty():
		print("ERRO: Nenhuma escolha feita antes de confirmar!")
		return
		
	# 1. Armazenar no Singleton (só agora salvamos de forma definitiva no PlayerData)
	PlayerData.selected_character = escolha_temporaria
	
	# 2. Navegação: Mudar para o Menu Principal
	print("Personagem " + PlayerData.selected_character + " confirmado. Navegando para a Tela do Carro inicial")
	get_tree().change_scene_to_file("res://Scenes/TelaCarroInicial.tscn")

func _atualizar_destaque_visual(nome_personagem_selecionado: String):
	# Desliga o destaque de todos
	# Exemplo: Se você usar um StyleBox personalizado para destacar, remova-o aqui.
	mika_button.modulate = Color.WHITE # 'modulate' é uma forma simples de escurecer/clarear
	allan_button.modulate = Color.WHITE
	
	# Aplica destaque no selecionado
	if nome_personagem_selecionado == "Mika":
		mika_button.modulate = Color.LIME_GREEN # Destaque visual
	elif nome_personagem_selecionado == "Allan":
		allan_button.modulate = Color.LIME_GREEN # Destaque visual
	
	# Nota: Em um projeto real, você usaria 'Theme Overrides/Styles/Normal'
	# para aplicar um estilo diferente (ex: uma borda colorida) ao botão selecionado.

func _mostrar_saudacao():
	var nome_jogador = PlayerData.player_name
	saudacao_label.text = "Bem-vindo(a), " + nome_jogador + "!"
	
# -------------------------------------------------------------------
# Documentação:
# 1. @onready var ...: Garante que os nós sejam acessados após o carregamento da cena.
# 2. _ready(): Conecta a ação dos botões. Usamos 'func(): _selecionar_personagem("Mika")'
#    para passar o nome como argumento para a função, tornando-a mais limpa.
# 3. _selecionar_personagem(nome_personagem): Função que recebe o nome.
# 4. PlayerData.selected_character = nome_personagem: Salva a informação no nosso script global.
# 5. get_tree().change_scene_to_file("..."): Navega para o próximo menu.
# -------------------------------------------------------------------
