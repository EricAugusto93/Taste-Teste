1. Tela Inicial / MVP Híbrido com IA interpretativa + Base própria
1. Busca inteligente com IA + Banco de Dados + Geolocalização
Descrição completa:
O usuário digita livremente o que deseja comer (ex: “jantar romântico no Moinhos de Vento”
ou “um lugar com gyoza e bons drinks”), e o app:
1. Usa uma IA embarcada ou integrada via API para interpretar o texto —
entendendo intenção, tipo de comida, ocasião, clima do lugar, localização
mencionada etc.
2. Transforma isso em filtros e tags, como:
○ tipo: jantar
○ ocasião: romântico
○ localização: Moinhos de Vento
especialidade: gyoza
3. Faz a busca na base própria de restaurantes cadastrados, que contém tags e
dados compatíveis
4. Aplica filtro de geolocalização, priorizando os mais próximos (ou dentro do bairro
especificado, se for o caso)
5. Exibe os resultados em dois modos:
○ Lista com cards
○ Mapa com pins geográficos
Extras possíveis:
● Se o usuário não mencionar localização no texto, o app usa a localização atual
como referência
● A IA pode continuar aprendendo com os inputs e gerar insights para novas tags e
categorias
2. Geolocalização
Descrição:
Sugestões são sempre priorizadas com base na localização atual do usuário.
Funcionalidade:
● Permissão de localização no app
● Cálculo de distância dos locais sugeridos
● Pode haver opção de alterar manualmente o bairro ou cidade
4. Visualização dos Resultados (Lista e Mapa)
Descrição:
Tela com os lugares sugeridos após a busca ou ao explorar categorias.
Funcionalidade:
● Visualização em formato lista (cards empilhados)
Alternância para modo mapa, com pins dos lugares (cada pin será um emoji)
● Cada card exibe:
○ Nome do local
○ Descrição resumida
○ Tags (ex: "para dates", "delivery", "pet friendly")
○ Distância aproximada - endereço
○ Horário de funcionamento
○ Botão de salvar/favoritar
○ Acesso ao Google Maps / Waze
Que tenha essa carinha aqui, com os emojis:
5. Favoritos / Experiências Salvas
Descrição:
Após visitar um lugar salvo, o usuário pode dar uma nota rápida à experiência diretamente
na área de favoritos, sem precisar acessar o perfil do restaurante.
Funcionalidade:
● O usuário marca um local como “visitado” ou “experiência concluída”
● O app exibe uma mini interface de avaliação (ex: 1 a 5 estrelas ou emojis)
● A nota é vinculada diretamente ao perfil do restaurante, somado à média geral
● Comentário é opcional ou inexistente no MVP (foco só na nota)
● Cada usuário pode avaliar um local apenas uma vez
● A média das avaliações é exibida no card do restaurante
6. Explorar por Temas (Curadoria fixa)
Descrição:
Sugestões prontas com base em categorias temáticas (não dependem de IA).
Funcionalidade:
● Carrossel ou seções na home com sugestões como:
○ “Para ir sozinho”
○ “Para sair com a galera”
○ “Restaurantes baratos e bons”
“Melhor date da cidade”
● Curadoria feita manualmente (você controla o conteúdo)
● Pode ser atualizável via banco de dados ou painel (no futuro)
Aqui cabe parceria com influenciadoras para criarem a curadoria própria.
7. Login / Cadastro (Opcional no MVP)
Descrição:
Permite que o usuário tenha perfil e possa salvar favoritos, manter histórico etc.
Tecnologia Utilizada - Flutter para o desenvolvimento do app mobile - Supabase para back-
end, banco de dados e autenticação - Integração com API de IA para interpretação das
buscas