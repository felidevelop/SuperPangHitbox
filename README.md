# Super Pang Hitbox
Proyecto enfocado en la búsqueda del sistema de colisiones del juego Super Pang Arcade 1990

[falta colocar imagenes ilustrativas]

Este proyecto se ha desarrollado bajo el propósito de explorar el funcionamiento interno del juego Super Pang Arcade 1990 desarollado por Mitchell Corp. Especialmente descubrir los mecanismos de los hitbox o cuadros de colisión de los diferentes elementos del juego. A continuación se dará un detalle técnico con lenguaje natural para explicar su funcionamiento. RECUERDE: es un proyecto en progreso que aun esta puliendo detalles.

<img width="768" height="480" alt="spang-08-30-225745" src="https://github.com/user-attachments/assets/14fed68d-fef2-41ce-a160-44d1e305288d" />

Para explorar el funcionamiento del juego se ha usado las herramientas MAME para la depuracion y examinar el codigo fuente, tambien se uso el emulador FBA-RR v0.0.5 para la búsqueda de las RAM Values del juego y el uso de script lua para una mejor exploración y comprobación de los valores encontrados.

*El código fuente lua actual es posible cargarlo, usarlo y disfrutarlo. Pero debe recordar que aun esta imcompleto.*

Para el uso de mame se ejecuta en cmd:

```
mame spang -window -debug
```

Para ejecutar la rom en mame en modo ventana y con la depuración activa. Es necesario contar con la ROM y el archivo de sonidos de la placa del juego ym2413.

Esto ejecuta el juego y permite crear puntos de quiebre (breakpoint) y puntos de observación (watchpoint) para detener la ejecución en un punto especifico del codigo o cuando un valor de la RAM esta siendo consultado o modificado.

Para la ejecución en FBA-RR solo es necesario abrir el ejecutable .exe abrir la ROM y abrir las opciones para la ejecución del .lua desarrollado. Un lua fue usado para explorar los diferentes elementos y mostrar sus valores en pantalla de forma que es mas fácil buscarlo en la depuración del mame.

Para ejecutar el lua es necesario descargar en emulador FBA-RR v0.0.5 o posterior. Tener a mano su copia de la ROM de Super Pang. Abrir el emulador y cargar la ROM. Ir a Game > Lua Scripting > New Lua Script Window > Browse y cargar el lua del proyecto. Y presionar en Run.

# Valores
Para la búsqueda de valores, fue de gran ayuda el uso de IA adjuntando archivos, dump de la RAM y fotos que mostraban detalles exactos para el trabajo de análisis y búsqueda de los posibles valores.

En esta búsqueda se encontró que la tabla puntero de los objetos comenzaba en la dirección E080 de la RAM, y cada bloque de objeto se organizaba cada 0x20 (32 decimal). Aunque búsquedas posteriores sugieren que no todos los objetos tienen el mismo tamaño, algunos posiblemente 0x10 (16 en base10). Principalmente los objetos se recorrer con la formula.

```
objeto[i] = 0xE080 + i * 0x20
```
Buscando 128 elementos, aunque esto solo es una aproximación.

## Estructuras de los objetos
La clasificación de los objetos se distribuye así:
| Offset | Descripción |
| :--- | :--- |
| +0x00 | 1=activo/0=inactivo |
| +0x09/0x0A/0x0B | Posición X |
| +0x0D | Posición Y |
| +0x16 | Numero usado para diferenciar el tamaño del globo 1/2/4/8/16 |
| +0x1B | Posición X utilizada por las rutinas de colisión |
| +0x1C | Selector de perfil utilizado por el dispatcher de las rutinas 8Axx |

## Funcionamiento de rutinas/funciones
Primero hay que mencionar que todos los detalles del funcionamiento de las rutinas que determinan la colisión fueron rastreadas usando el debug del código fuente del juego con MAME. Durante el rastreo se pudo concluir una serie de cosas.

Cada interacción parece tener su propio apartado para elegir como interactúan entre si, es decir la colisión entre Globo y Arpón, Globo y Jugador, Jugador e Item, son independientes a excepción de algunos casos que comparten el mismo procedimiento.

### Por ejemplo interacción entre globo y arpon:
El objeto atacado proporciona su perfil geométrico.
El arpón se comporta como una línea de un píxel de ancho, desde la base donde fue disparado hasta su altura actual.
Este comportamiento también aplica para los globos hexagonales.

Según el perfil del globo o 0x1C
Rutinas:
8AAD -> perfil 1
8A98 -> perfil 2
8A7A -> perfil 3
8A5C -> perfil 4
8A3E -> perfil 5

Para los casos 3/4/5 la colisión usa una tabla que se encuentra en la RAM para crear una colisión mas compleja orientada a formar un circulo.
RAM 912F → perfil 3 / 17 columnas
RAM 90FB → perfil 4 / 25 columnas
RAM 90B7 → perfil 5 / 33 columnas

Cada entrada de esas tablas tiene dos valores verticales que, combinados con cada desplazamiento X, reconstruyen la forma de la hitbox del globo.

Una conclusión importante aquí es que no son los valores RAM las que controlan los limites de colisión, es el propio código fuente del juego, es decir que las hitbox no pueden ser controladas durante el juego. Y esto ocurre para todas las interacciones.

Durante el rastreo de los valores de los perfiles 3/4/5 se encontraron estos valores:

Perfil 3
Base: 0x912F
17 entradas / 34 bytes
| dx | v1 | v2 |
| :- | :- | :- |
| 0  | 02 | 04 |
| 1  | 02 | 04 |
| 2  | 07 | 0E |
| 3  | 09 | 12 |
| 4  | 0B | 16 |
| 5  | 0C | 18 |
| 6  | 0D | 1A |
| 7  | 0E | 1C |
| 8  | 0E | 1C |
| 9  | 0E | 1C |
| 10 | 0E | 1C |
| 11 | 0E | 1C |
| 12 | 0D | 1A |
| 13 | 0C | 18 |
| 14 | 09 | 12 |
| 15 | 07 | 0E |
| 16 | 02 | 04 |

Perfil 4
Base: 0x90FB
25 entradas / 50 bytes
| dx | v1 | v2 |
| :- | :- | :- |
| 0  | 04 | 08 |
| 1  | 04 | 08 |
| 2  | 09 | 12 |
| 3  | 0C | 18 |
| 4  | 0E | 1C |
| 5  | 10 | 20 |
| 6  | 11 | 22 |
| 7  | 13 | 26 |
| 8  | 13 | 26 |
| 9  | 14 | 28 |
| 10 | 16 | 2C |
| 11 | 16 | 2C |
| 12 | 16 | 2C |
| 13 | 16 | 2C |
| 14 | 16 | 2C |
| 15 | 16 | 2C |
| 16 | 16 | 2C |
| 17 | 16 | 2C |
| 18 | 14 | 28 |
| 19 | 13 | 26 |
| 20 | 13 | 26 |
| 21 | 11 | 22 |
| 22 | 10 | 20 |
| 23 | 0E | 1C |
| 24 | 0C | 18 |

Perfil 5
Base: 0x90B7
33 entradas / 66 bytes
| dx | v1 | v2 |
| :- | :- | :- |
| 0  | 04 | 08 |
| 1  | 04 | 08 |
| 2  | 0A | 14 |
| 3  | 0D | 1A |
| 4  | 10 | 20 |
| 5  | 12 | 24 |
| 6  | 14 | 28 |
| 7  | 15 | 2A |
| 8  | 16 | 2C |
| 9  | 18 | 30 |
| 10 | 19 | 32 |
| 11 | 1A | 34 |
| 12 | 1B | 36 |
| 13 | 1B | 36 |
| 14 | 1C | 38 |
| 15 | 1C | 38 |
| 16 | 1C | 38 |
| 17 | 1C | 38 |
| 18 | 1C | 38 |
| 19 | 1C | 38 |
| 20 | 1B | 36 |
| 21 | 1B | 36 |
| 22 | 1A | 34 |
| 23 | 19 | 32 |
| 24 | 18 | 30 |
| 25 | 16 | 2C |
| 26 | 15 | 2A |
| 27 | 14 | 28 |
| 28 | 12 | 24 |
| 29 | 10 | 20 |
| 30 | 0D | 1A |
| 31 | 0A | 14 |
| 32 | 04 | 08 |

Estos valores fueron extraídos mientras el debug del emulador MAME entraba en las rutinas de los perfiles. Porque si uno rastrea esas direcciones en la RAM values de FBA-RR no encontrara esos valores. Eso es porque los valores únicamente existen cuando la ejecución entra a esas rutinas. Es decir hay valores RAM que solo existen por un momento antes de desaparecer, y el avance de frame a frame es muy rápido para detectarlos.

La rutina encontrada en 0x8A2A utiliza el valor de +0x1C para seleccionar que rutina determina los limites de colisión.

```
8A2A  CP $01
8A2C  JP Z,$8AAD

8A2F  CP $02
8A31  JP Z,$8A98

8A34  CP $03
8A36  JP Z,$8A7A

8A39  CP $04
8A3B  JP Z,$8A5C
```

El código continúa directamente en 8A3E para el siguiente perfil:
+1C = 5 -> rutina en 8A3E

PERFIL 1 — RUTINA 8AAD
```
8AAD  LD A,C
8AAE  ADD A,$02
8AB0  SUB B
8AB1  CP $05
8AB3  RET NC

8AB4  LD A,(IY+$0D)
8AB7  ADD A,$03
8AB9  CP E
8ABA  RET C

8ABB  SUB $07
8ABD  CP D
8ABE  RET NC

8ABF  JP $8FE9
```

PERFIL 2 — RUTINA 8A98
```
8A98  LD A,C
8A99  ADD A,$04
8A9B  SUB B
8A9C  CP $09
8A9E  RET NC

8A9F  LD A,(IY+$0D)
8AA2  ADD A,$07
8AA4  CP E
8AA5  RET C

8AA6  SUB $0F
8AA8  CP D
8AAA  RET NC

8AAB  JP $8FE9
```

PERFIL 3 — RUTINA 8A7A
```
8A7A  LD A,C
8A7B  ADD A,$08
8A7D  SUB B
8A7E  CP $11
8A80  RET NC

8A81  ADD A,A
8A82  LD HL,$912F
8A85  ADD A,L
8A86  LD L,A
8A87  JP NC,$8A8B
8A89  INC H

8A8B  LD A,(IY+$0D)
8A8E  ADD A,(HL)
8A8F  CP E
8A90  RET C

8A91  INC HL
8A92  SUB (HL)
8A93  CP D
8A94  RET NC

8A95  JP $8FE9
```

PERFIL 4 — RUTINA 8A5C
```
8A5C  LD A,C
8A5D  ADD A,$0C
8A60  SUB B
8A61  CP $19
8A63  RET NC

8A64  ADD A,A
8A65  LD HL,$90FB
8A68  ADD A,L
8A69  LD L,A
8A6A  JP NC,$8A6D
8A6C  INC H

8A6D  LD A,(IY+$0D)
8A70  ADD A,(HL)
8A71  CP E
8A72  RET C

8A73  INC HL
8A74  SUB (HL)
8A75  CP D
8A76  RET NC

8A77  JP $8FE9
```

PERFIL 5 — RUTINA 8A3E
```
8A3E  LD A,C
8A3F  ADD A,$10
8A41  SUB B
8A42  CP $21
8A44  RET NC

8A45  ADD A,A
8A46  LD HL,$90B7
8A49  ADD A,L
8A4A  LD L,A

8A4B  LD A,(IY+$0D)
8A4E  ADD A,(HL)
8A4F  CP E
8A51  RET C

8A52  INC HL
8A53  SUB (HL)
8A54  CP D
8A55  RET NC

8A56  JP $8FE9
```

El arpón se identifico como E380 dentro de la memoria RAM y siempre tiene este valor de puntero en cualquier nivel, lo que sugiere que los elementos pueden entrar organizados en bloques específicos de la tabla de objetos.

+0D = Posición Y actual del arpón
+0E = Origen vertical del arpón
+1B = X del arpón

Las rutinas demostraban que los elementos solo se comparaban con la posición X del arpón, algo que indica que el arpón solo tiene 1px de ancho en su colisión, valor que fue comprobado al disparar el arpón muy cerca de paredes y comprobar que solo cuando la fina línea toca algo hay interacción.

El valor +0xE aparece cuando el arpón recién es creado al disparar, y nace con la posición Y con la que fue creado y no cambia durante el trayecto, es decir una referencia Y de su creación. Este valor es el usado para lo colisión vertical del arpón. Tiene todo el sentido porque el arpón ataca incluso a globos desde su base.

## Interacción globo con jugador
Para la interacción entre globo y jugador es diferente en cuanto a globo y arpón. La rutina responsable de esto se encuentra en BBE6.

```
BBE6  CP $01
BBE8  JP Z,$BC72

BBEB  CP $02
BBED  JP Z,$BC54

BBF0  CP $03
BBF2  JP Z,$BC36

BBF5  CP $04
BBF7  JP Z,$BC18
```

Después de CP $04, el código continúa directamente al perfil 5 en BBFA

Esto indica que para colisionar con el jugador el globo no usa la misma hitbox que usa para rebotar o chocar con las paredes.

CASO 1 — BC72
```
BC72  LD BC,$0008
BC75  ADD HL,BC
BC76  SBC HL,DE
BC78  LD BC,$FFEF
BC7B  ADD HL,BC
BC7C  RET C

BC7D  EXX
BC7E  LD A,(IY+$0D)
BC81  ADD A,$0C
BC83  SUB E
BC84  CP $1C
BC86  JP NC,$BC90
```

CASO 2 — BC54
```
BC54  LD BC,$000A
BC57  ADD HL,BC
BC58  SBC HL,DE
BC5A  LD BC,$FFEB
BC5D  ADD HL,BC
BC5E  RET C

BC5F  EXX
BC60  LD A,(IY+$0D)
BC63  ADD A,$0E
BC65  SUB E
BC66  CP $20
BC68  JP NC,$BC90
```

CASO 3 — BC36
```
BC36  LD BC,$000F
BC39  ADD HL,BC
BC3A  SBC HL,DE
BC3C  LD BC,$FFE1
BC3F  ADD HL,BC
BC40  RET C

BC41  EXX
BC42  LD A,(IY+$0D)
BC45  ADD A,$12
BC47  SUB E
BC48  CP $28
BC4A  JP NC,$BC90
```

CASO 4 — BC18
```
BC18  LD BC,$0016
BC1B  ADD HL,BC
BC1C  SBC HL,BC
BC1E  LD BC,$FFD3
BC21  ADD HL,BC
BC22  RET C

BC23  EXX
BC24  LD A,(IY+$0D)
BC27  ADD A,$1A
BC29  SUB E
BC2A  CP $38
BC2C  JP NC,$BC90
```

CASO 5 — BBFA
```
BBFA  LD BC,$001C
BBFD  ADD HL,BC
BBFE  SBC HL,DE
BC00  LD BC,$FFC7
BC03  ADD HL,BC
BC04  RET C

BC05  EXX
BC06  LD A,(IY+$0D)
BC09  ADD A,$1E
BC0B  SUB E
BC0C  CP $40
BC0E  JP NC,$BC90
```

Para la colisión con el jugador se observo que la hitbox del globo no se compara con una hitbox del jugador, mas bien solo se usa la posición X e Y del jugador para la comparación. Es decir, la hitbox del globo tiene que alcanzar el punto central del jugador para que se accione una colisión.

*La hitbox del globo de perfil 1 tiene las mismas dimensiones que usa el hitbox del jugador para interactuar con el terreno*

## Interacción escalera con jugador
Una escalera se identifica siempre desde E800 sin importar cual sea el nivel, una escalera siempre tiene su posición X e Y fijas, son elementos que no cambian de posición pero su altura si es variable entre niveles.

+0x0A/+0x0B = X de la escalera
+0x0C = límite vertical de la escalera
+0x0D = segundo valor vertical de la escalera

En una de las rutinas aparece:
```
LD A,(IX+$0D)
ADD A,$10
CP (IY+$0D)
JR Z,$B103
JR C,$B118
CP (IY+$0C)
JR NC,$B118
```
Indica que la referencia al jugador es:
Y jugador + 0x10
mientras rango de la escalera es mediante:
Puntero Escalera +0C
Puntero Escalera +0D

Otra rutina usa:
```
LD A,(IX+$0D)
DEC A
CP (IY+$0C)
JR NC,$B0AC
INC A
CP (IY+$0D)
JR C,$B0AC
```
Esto hace que la colisión/trigger vertical de la escalera es variable y depende de su extensión vertical que va acorde a su dibujo grafico.
Este es el rango que se compara con X/Y del jugador para definir si el jugador esta cerca para escalar.

## Interacción item con el entorno
Los items se manejan desde otra tabla que apunta a F900.
La interacción ocurre en la rutina B870

```
B887  LD A,(IX+$0D)
B88A  ADD A,$11
B88C  SUB (IY+$0D)
B88F  CP $23
B891  RET NC
```
El item hace una comprobación vertical y horizontal con X/Y del jugador, una vez mas es un hitbox que se compara con el punto central del jugador.

La interacción con el terreno es diferente.
```
B0A0  LD L,(IX+$0C)
B0A3  LD H,(IX+$0D)
B0A6  LD DE,$0140
B0A9  ADD HL,DE
B0AA  LD (IX+$0C),L
B0AD  LD (IX+$0D),H
B0B0  CALL $B367
```
Un item tiene una colisión vertical de 16px y solo de 1px de ancho, según observaciones graficas. Esto hace una colisión perfectamente vertical, pero en cuanto horizontalmente, solo tocara una superficie si del lado de la superficie al menos toca la mitad, es decir si la línea central toca una parte de la superficie.

## Colisión de los terrenos
Para encontrar el mapa de las colisiones del terreno, se uso un método de análisis de volcado de RAM, en esta situación el intenso análisis de la IA para encontrar patrones fue de mucha utilidad.

La representación que resultó útil fue una rejilla de:
64 columnas x 32 filas
con celdas de 8 x 8 píxeles

Esto produce:
64 x 32 = 2048 celdas

La misma coordenada (row,col) puede ser usada para consultar dos estructuras relacionadas.

A) ATTRIBUTE RAM
Base: 0xC800
Rango: 0xC800 - 0xCFFF
Tamaño: 0x800 bytes
Organización: 64 x 32, un byte por celda

B) VIDEO / TILE RAM
Base: 0xD000
Rango: 0xD000 - 0xDFFF
Tamaño: 0x1000 bytes
Organización: 64 x 32 tiles, dos bytes por tile

La visualización del mapa utiliza:
ORIGIN_X = -64
ORIGIN_Y = -8
CELL     = 8

*Por alguna razón toda coordenada X/Y de cualquier elemento se le debe restar -64/-8 respectivamente para que su dibujo coincida con las coordenadas en pantalla. Se desconoce porque es asi.*

Se encontró que la mejor forma de dibujar las colisiones de plataformas y paredes, así como de plataformas destruibles era:
0x1F = Limite del escenario colisionable
0x0D = Estructura fija / Colisionables
0x20 = Espacio vacío / No dibujar

Aunque funciona muy bien, este método no permite dibujar estructuras destruibles invisibles y escondidas, sus valores no se diferencian en el mapa de tiles del nivel. Y su existencia parece mas bien estar representado como un objeto en la tabla de objetos en 0xE080, aunque aun no se conoce bien este detalle.

*Cuidado, los valores de los objetos reconocibles en un nivel no se borran durante una transición al pasar a otro nivel o al estar en una escena de créditos finales, como gameover o pantalla de titulo. Para evitar eso es necesario tener un valor que determine bien en que situación del juego estas.*

# Futuras investigaciones y mejoras
Este proyecto aun no completa muchas características que podrían ser de provecho para un script de hitbox, por ejemplo:
- Completar mapa de hitbox del nivel, identificar estructuras destruibles ocultas.
- Los animales como los cocodrile, o pajaros, o pez globo volador tambien se debe buscar su hitbox correspondiente.
- Identificar que item esta dentro de un destruible, si acaso se puede identificar.
- Reconocer cuando estamos dentro de un nivel, y desactiva el dibujo grafico de elementos cuando no estamos dentro de un nivel.
- La hitbox de los elementos busca tocar el punto central del jugador, pero el jugador tiene una hitbox para el terreno que es igual que la hitbox que tiene con el globo de perfil 1. Entonces es posible crear un lua corregido para que todos tengan una hitbox rectangular y no depender de un punto, aunque no sea tecnicamente correcto.

**Hasta entonces el proyecto esta abierto para cualquier colaboracion.**

