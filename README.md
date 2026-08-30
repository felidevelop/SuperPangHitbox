# Super Pang Hitbox
Proyecto enfocado en la busqueda del sistema de colisiones del juego Super Pang Arcade 1990

Este proyecto se ha desarollado bajo el proposito de explorar el funcionamiento interno del juego Super Pang Arcade 1990 desarollado por Mitchel Corp. Especialmente descubrir los mecanismos de los hitbox o cuadros de colision de los diferentes elementos del juego. A continuacion se dara un detalle tecnico con lenguaje natural para explicar su funcionamiento. RECUERDE: es un proyecto en progreso qu aun esta puliendo detalles.

Para explorar el funcionamiento del juego se ha usado las herramientas MAME para la depuracion y examinar el codigo fuente, tambien se uso el emulador FBA-RR v0.0.5 para la busqueda de las RAM Values del juego y el uso de script lua para una mejor exploracion y comprobacion de los valores encontrados.

Para el uso de mame se ejecuta en cmd:

```
mame spang -window -debug
```

Para ejecutar la rom en mame en modo ventana y con la depuracion activa. Es necesario contar con la ROM y el archivo de sonidos de la placa del juego ym2413.

Esto ejecuta el juego y permite crear puntos de quiebre (breakpoint) y puntos de observacion (watpoint) para detener la ejecucion en un punto especifico del codigo o cuando un valor de la RAM esta siendo consultada o modificado.

Para la ejecucion en FBA-RR solo es necesario abrir el ejecutable .exe abrir la rom y abrir las opciones para la ejecucion del .lua desarollado. Un lua fue usado para explorar los diferentes elementos y mostrar sus valores en pantalla de forma mas facil que buscarlo en la depuracion de mame.


# Valores
Para la busqueda de valores, fue de gran ayuda el uso de IA adjuntando archivos, dump de la RAM y fotos que mostraban detalles exactos para el trabajo de analisis y busqueda de los posibles valores.

En esta busqueda se encontro que la tabla puntero de los objetos comenzaba en la direccion E080 de la RAM, y cada bloque de objeto se organizaba cada 0x20 (32 en base10). Aunque busquedas posteriores sugieren que no todos los objetos tienen el mismo tamaño, algunos posiblemente 0x10 (16 en base10). Principalmente los objetos se recorrer con la formula.

```
objeto[i] = 0xE080 + i * 0x20
```
Buscando 128 elementos, aunque esto solo es una aproximacion.

##Estructuras de los objetos
La clasificacion de los objetos se disfrubuye asi:
| Offset | Descripcion |
| :--- | :--- |
| +0x00 | 1=activo/0=inactivo |
| +0x09/0x0A/0x0B | Posicion X |
| +0x0D | Posicion Y |
| +0x16 | Numero usado para diferenciar el tamaño del globo 1/2/4/8/16 |
| +0x1B | Posicion X utilizada por las rutinas de colisión |
| +0x1C | Selector de perfil utilizado por el dispatcher de las rutinas 8Axx |

##Funcionamiento de rutinas/funciones
Primero hay que mencionar que todos los detalles del funcionamiento de las rutinas que determinan la colision fueron rastreadas usando el debug del codigo fuente del juego con MAME. Durante el rastreo se pudo concluir una serie de cosas.

Cada interaccion parece tener su propio apartado para elegir como interacturar entre si, es decir la colision entre Globo y Arpon, Globo y Jugador, Jugador e item, son independientes a excepcion de algunos casos que comparten el mismo procedimiento.

Por ejemplo interaccion entre globo y arpon:
El objeto atacado proporciona su perfil geométrico.
El arpón se comporta como una línea de un píxel de ancho, desde la base donde fue disparado hasta su altura actual.
Este comportamiento tambien aplica para los globos hexagonales.

Segun el perfil del globo o 0x1C
Rutinas:
8AAD -> perfil 1
8A98 -> perfil 2
8A7A -> perfil 3
8A5C -> perfil 4
8A3E -> perfil 5

Para los casos 3/4/5 la colision usa una tabla que se encuentra en la RAM para crear una colision mas compleja orientada a formar un circulo.
RAM 912F → perfil 3 / 17 columnas
RAM 90FB → perfil 4 / 25 columnas
RAM 90B7 → perfil 5 / 33 columnas

Cada entrada de esas tablas tiene dos valores verticales que, combinados con cada desplazamiento X, reconstruyen la forma de la hitbox del globo.

Una conclusion importante aqui es que no son los valores RAM las que controlan los limites de colision, es el propio codigo fuente del juego, es decir que las hitbox no pueden ser controladas durante el juego. Y esto ocurre para todas las interacciones.

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

Estos valores fueron extraidos mientras el debug del emulador MAME entraba en las rutinas de los perfiles. Porque si uno rastrea esas direcciones en la RAM values de FBA-RR no encontrara esos valores. Eso es porque los valores unicamente existen cuando la ejecucion entra a esas rutinas. Es decir hay valores RAM que solo existen por un momento antes de desaparecer, y el avance de frame a frame es muy rapido para detectarlos.


La rutina encontrada en 0x8A2A utiliza el valor de +0x1C para seleccionar que rutina determina los limites de colision.

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

