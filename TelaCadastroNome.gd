# TelaCadastroNome.gd
extends Control

# Variáveis para referenciar os nós (componentes visuais)
# Você deve atribuir esses nós no Inspector da Godot (arrastando-os para cá)
@onready var nome_input: LineEdit = $LineEdit
@onready var proximo_button: Button = $Button
@onready var error_label: Label = $ErrorLabel
# Sinal que será chamado quando o botão "Próximo" for pressionado
func _ready():
	# Conecta a ação de pressionar o botão à função '_on_proximo_button_pressed'
	proximo_button.pressed.connect(_on_proximo_button_pressed)
	
	nome_input.text_changed.connect(_on_nome_input_text_changed)
	
	_on_nome_input_text_changed(nome_input.text)
	
# Função chamada quando o jogador pressiona o botão "Próximo"
func _on_proximo_button_pressed():
	var nome_digitado: String = nome_input.text.strip_edges()
	
	# 1. Verificação (Restrição): O nome não pode estar vazio!
	if nome_digitado.is_empty():
		print("Atenção: Por favor, digite um nome para continuar.")
		print("Erro de segurança: O botão deveria estar desativado.")
		error_label.text = "Atenção: Por favor, digite um nome para continuar."
		# Opcional: Adicionar um pop-up de erro visual aqui.
		return
		
	# 2. Armazenar no Singleton: Salvar o nome globalmente
	PlayerData.player_name = nome_digitado
	print("Nome do jogador salvo: " + PlayerData.player_name)
	
	# 3. Navegação: Mudar para a próxima tela (Seleção de Personagem)
	# OBS: Substitua "res://Scenes/TelaSelecaoPersonagem.tscn" pelo caminho real 
	# da cena que criaremos a seguir.
	
	# Exemplo simples de navegação:
	get_tree().change_scene_to_file("res://Scenes/TelaSelecaoPersonagem.tscn")

func _on_nome_input_text_changed(novo_texto: String):
	# Remove espaços em branco do início/fim para a verificação
	var nome_limpo: String = novo_texto.strip_edges()
	
	var texto_valido: bool = !nome_limpo.is_empty()
	
	# 1. Altera o estado do botão (Disabled = true desativa e escurece)
	proximo_button.disabled = !texto_valido
	
	# 2. Opcional: Feedback visual extra (como um ícone de alerta) poderia ir aqui.
	
	if proximo_button.disabled:
		print("Botão Próximo desativado: O nome está vazio.")
	else:
		print("Botão Próximo ativado: Nome OK.")
# -------------------------------------------------------------------
# Documentação:
# 1. @onready var nome_input: Acessa o nó LineEdit para ler o texto.
# 2. _ready(): Conecta o sinal 'pressed' do botão a uma função.
# 3. _on_proximo_button_pressed(): Lógica principal.
# 4. nome_input.text.strip_edges(): Pega o texto e remove espaços extras.
# 5. PlayerData.player_name = nome_digitado: A chave! Salva a informação globalmente.
# 6. get_tree().change_scene_to_file: É o método da Godot para mudar de tela.
# -------------------------------------------------------------------
