/* 
# Problema Giapetto's

Encontre a solução ideal para maximizar o lucro do Giapetto
*/

# Variáveis de Decisão
var x1 >=0 integer;  # soldado
var x2 >=0 integer;  # trem

# Função objetivo
maximize lucro: 3*x1 + 2*x2;

# Restrições
s.t. acabamento: 2*x1 + x2 <= 100;
s.t. carpintaria: x1 + x2 <= 80;
s.t. demanda: x1 <= 40;

solve;

display x1, x2, lucro;
display acabamento, carpintaria, demanda;

end;


