# SuperPangHitbox
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
| Offset | Descripcion | Largo | Contenido |
| +0x00 | 1=activo/0=inactivo |
| +0x09/0x0A/0x0B | Posicion x |
| +0x0D | Posicion y |


| Variable | Posicion | Largo | Contenido |
| :--- | :--- | :--- | :--- |
| Largo JSON | 0 | 4 bytes | Numero en formato Big endian del largo del JSON |
| JSON | 4 | Largo indicado por "Largo JSON" | Contenido del JSON |
| Archivo Binario | 4 + Largo JSON | - | Comienza el contenido binario del primer archivo |




