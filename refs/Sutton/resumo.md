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

TODO: energia e eficiências
reorganizar coisas para tornar referência mais fácil