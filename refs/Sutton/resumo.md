# Resumo dos capítulos 2 e 3
Este documento é um sumário das fórmulas, relações e bizus úteis para o trabalho, extraídos dos capítulos introdutórios aplicaveis.

## Definições

### Impulso total

$$
I_t = \int_0^TFdt,
$$

onde:
* F: força de empuxo instantânea
* T: tempo total de queima

### Impulso específico

Impulso por peso de propelente médio:

$$
I_s = \frac{I_t}{g_0 \int \dot{m} dt},
$$

onde:
* g_0: gravidade padrão ao nível do mar (9.81m/s²)
* $\dot{m}$: fluxo mássico de propelente pelo motor 

Impulso específico instantâneo ou para fluxo de massa e empuxo constantes: 
$$
I_s = \frac{F}{g_0\dot{m}}
$$

Velocidade de exaustão efetiva:
$$
c = I_s g_0 = \frac{F}{\dot{m}}
$$

Medida da ??? 

## Empuxo
$$
F = \frac{dm}{dt}v_2 + (p_2 - p_3)A_2,
$$

onde:
* $\frac{dm}{dt}$: vazão mássica de propelente
* $v_2$: velocidade de exaustão do propelente relativa ao veículo
* $p_2$: pressão local na saída da tubeira
* $p_3$: pressão ambiente
* $A_2$: área da saída da tubeira

__Bizu de projeto__: $p_2 = p_3$

## Velocidade de exaustão
Das relações anteriores:

$$
c = v_2 + \frac{(p_2 - p_3)A_2}{\dot{m}}
$$

### Velocidade característica
$$
c^* = \frac{p_1A_t}{\dot{m}}
$$

* Independe da tubeira
* mede eficiência da combustão $\rightarrow$ não usada para gás frio?

## Energia e eficiências

### Potência do jato
$$
P_{jet} = \frac{1}{2}\dot{m}v² = \frac{1}{2}Fv_2
$$

## Relações termodinâmicas do foguete ideal
Hipóteses:
* fluido _homogêneo_
* fluido é um _gás_
* o gás é _perfeito_
* fluxo _adiabático_
* camada limite _desprezível_
* fluxo _sem_ descontinuidades
* fluxo _estacionário_
* a velocidade dos gases de exaustão é _axial_
* propriedades em toda a seção transversal _constantes_
* _frozen flow_: composição não muda na tubeira (para gás frio isso é garantido)
* propelente armazenado à $T_{amb}$

### Relações do fluxo quasi-unidimensional isentrópico

$$
T_0 = T \left(1 + \frac{\gamma - 1}{2}M²\right)
$$

$$
p_0 = p \left(1 + \frac{\gamma - 1}{2}M² \right) ^ {\frac{\gamma}{\gamma-1}}
$$

$$
\rho_0 = \rho \left(1 + \frac{\gamma - 1}{2}M² \right) ^ {\frac{1}{\gamma-1}}
$$

$$
\frac{A_y}{A_x} = \frac{M_x}{M_y} \sqrt{\frac{1 + \frac{\gamma - 1}{2}M_y²}{1 + \frac{\gamma - 1}{2}M_x²}} ^ {\frac{\gamma+1}{\gamma-1}}
$$

$$
v_y = \sqrt{\frac{2\gamma}{\gamma-1}RT_x \left[1 - \left(\frac{p_y}{p_x}\right)^{\frac{\gamma-1}{\gamma}}\right] + v_x²}
$$

$$
\dot{m} = \rho v A
$$

* Para câmara larga: $v \approx 0$
* $A_t$: deve ter $M = 1$
* Para altitudes de até 10km: $\frac{A_2}{A_t}$ tipicamente entre 3 e 25

### Coeficiente de empuxo
$$
C_F = \frac{F}{p_1A_t}
$$

* Independe da T de câmara $T_1$
* Para $\frac{p_1}{p_3}$ fixo, $C_F$ ótimo quando $p_2=p_3$
* Mede a amplificação de empuxo obtida pela expansão do fluxo supersônico em relação ao empuxo que seria exercido pela pressão de câmara agindo sobre a área da garganta ($\therefore$ mede a qualidade da expansão)

### Velocidade característica
$$
c^* = \frac{p_1A_t}{\dot{m}} = \frac{c}{C_F}
$$

* função das características do propelente e câmara, independe da tubeira
* $F = \dot{m}c^*C_F \rightarrow \dot{m} \times \text{f(câmara, propelente)}\text{f(tubeira)}$

### Geometria da câmara
$\frac{A_1}{A_t} > 4 \rightarrow v_1 \approx 0$ 

## Configuração de tubeira
* Seção convergente: não é crítica para o desempenho
* Contorno da seção transversal: também não é crítico $\rightarrow$ estudar fazer uma tubeira de seção retangular de comprimento constante e largura variável (a aleta ficaria melhor imersa no escoamento + o escoamento real fica mais bidimensional)
* Usar tubeira cônica de $15^o$ de meio ângulo

## Tubeira cônica
Fator de correção:

$$
\lambda = \frac{1}{2} (1 + cos \alpha),
$$

onde:
* $\alpha$: meio ângulo da tubeira
* $\lambda = \frac{\text{QDM real}}{\text{QDM ideal}} \rightarrow$ reduz o empuxo de QDM (primeiro termo de F) (VERIFICAR SE É CALCULADO PARA CONE CILÍNDRICO)

## Tubeiras reais
* Perda de divergência do fluxo de saída: contabilizada por $\lambda$
* Perda de câmara estreita: reduzem empuxo ligeiramente
* Perda por razão de expansão não-ótima: ~15% de perda de empuxo

### Fatores de correção de desempenho
* Fator de correção de velocidade:
    
    $\zeta_v = \frac{v_{2,real}}{v_{2,ideal}}$
    
    * 0.85 - 0.99
* Fator de correção de descarga:
    
    $\zeta_d = \frac{\dot{m}_{real}}{\dot{m}_ideal}$

    * 1.0 - 1.15 (para motores com combustão - ocorre tendência inversa com motores de gás frio?)

## Quatro parâmetros de desempenho
Definir condições:
* Pressão de câmara
* Pressão ambiente
* Razão de expansão (e se é ótima)
* Forma da tubeira e ângulo de saída
* Propelente
* Correções utilizadas
* Temperatura inicial dos propelentes

## Alinhamento da tubeira
* Normalmente, erro de até $\pm 0,25\degree$
* Eixo de empuxo: eixo da seção de saída da tubeira
* Irregularidades na geometria de câmara

