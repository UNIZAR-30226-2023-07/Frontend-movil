import 'package:flutter/material.dart';

class RulesPage extends StatelessWidget {
  const RulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    const double leftPadding = 17;
    const double topPadding = 0;
    const double rightPadding = 17;
    const double bottomPadding = 17;
    const double spaceBetweenParagraphs = 20;
    const double spaceBetweenPart = 10;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reglas del juego'),
      ),
      body: ListView(
        children: const [
          ExpansionTile(
            title: Text('Resumen'),
            childrenPadding: EdgeInsets.fromLTRB(leftPadding, topPadding, rightPadding, bottomPadding),
            children: [
              Text('Es un juego de cartas para dos o más jugadores. El juego es siempre individual. El objetivo es deshacerse del máximo número de cartas posible, de las 14 que inicialmente se reparten a cada jugador, ganando la partida quien primero se queda sin ninguna. Para ello los jugadores construyen secuencias de al menos 3 cartas consecutivas del mismo palo (conocidas como escaleras), o conjuntos de cartas del mismo valor y distinto palo (conocidas como tríos). Una vez construidas, las escaleras y tríos se exponen en la mesa, pudiendo los jugadores colocar cartas adicionales en las combinaciones propias o en las de los otros jugadores, para, de esta forma, ir descartándose.'),
              SizedBox(height: spaceBetweenParagraphs),
              Text('Cuando un jugador se queda sin cartas termina la partida y obtiene 0 puntos. El resto de los jugadores suman los puntos de todas las cartas que tienen en la mano (tanto si están combinadas en escaleras o tríos, como si no), acumulándose con los de partidas anteriores. El juego termina cuando todos los jugadores menos uno, que es el ganador, superan un número de puntos establecido de antemano, normalmente 100. Si un jugador rebasa esta puntuación pero queda más de uno por debajo del límite máximo, el jugador que se ha excedido se repesca (se dice que se reengancha) con el número de puntos que tiene el jugador que más puntos tiene.')
            ],
          ),
          ExpansionTile(
            title: Text('Reparto y secuencia de juego'),
            childrenPadding: EdgeInsets.fromLTRB(leftPadding, topPadding, rightPadding, bottomPadding),
            children: [
              Text('Se sortea inicialmente quien dará las cartas por primera vez. El encargado de darlas reparte catorce a cada jugador, de dos en dos, deja el resto boca abajo en el centro de la mesa (mazo) y coloca una adicional descubierta al lado del mazo (descartes). Comienza el juego el jugador siguiente por la derecha. El turno para repartir las cartas es rotatorio, independientemente del desarrollo del juego.'),
              SizedBox(height: spaceBetweenParagraphs),
              Text('Cada turno de juego se compone de una secuencia fija de acciones que realizada el jugador que tiene el turno de juego. Mientras un jugador tiene el turno los demás deben esperar. Las acciones que componen la secuencia de un turno de juego, son, de forma resumida, las siguientes:'),
              SizedBox(height: spaceBetweenParagraphs),
              Padding(padding: EdgeInsets.only(left: leftPadding), child: Text('Encarte: El jugador que juega debe tomar una carta, o bien del mazo o bien de la pila de descartes, a su elección. Sin embargo sólo se puede tomar la carta de la pila de descartes si se cumplen ciertas condiciones. Tomar la carta del mazo se puede hacer siempre.'),),
              SizedBox(height: spaceBetweenPart),
              Padding(padding: EdgeInsets.only(left: leftPadding), child: Text('Despliegue: Una vez que ha tomado carta, el jugador, si lo desea, puede extender en la mesa una o más combinaciones. tríos o escaleras.  A la acción de exponer combinaciones por primera vez se denomina despliegue inicial. Para este despliegue inicial se deben cumplir ciertas condiciones. Una vez que se ha hecho el despliegue inicial el jugador puede colocar cartas adicionales en otras combinaciones ya extendidas en la mesa, sean propias o no. También se puede colocar cartas que sustituyen a comodines y recoger éstos.'),),
              SizedBox(height: spaceBetweenPart),
              Padding(padding: EdgeInsets.only(left: leftPadding), child: Text('Descarte: Una vez que el jugador ha terminado el Despliegue echa una carta en la pila de descartes. Esta acción es obligatoria si el jugador tiene cartas en la mano. Si no le quedan (debido a que las haya colocado todas) se termina la partida. Si al jugador le quedan cartas en la mano, el turno pasa al siguiente jugador. Si no le quedan, termina la partida y se procede al recuento de puntos.'),),
            ],
          ),
          ExpansionTile(
            title: Text('Despliegue inicial o \'Abrir\' el juego'),
            childrenPadding: EdgeInsets.fromLTRB(leftPadding, topPadding, rightPadding, bottomPadding),
            children: [
              Text('Cuando un jugador tiene todas las cartas en la mano (14) y extiende combinaciones por primera vez se dice que \'Abre\' o \'Baja\' su juego. Para que un jugador pueda \'Abrir\' es necesario que la suma de todas las cartas que extiende sea al menos de 51 puntos. Si no alcanza esta cantidad no puede extender ninguna carta. Una vez que ha abierto, en posteriores turnos de juego, puede extender otras combinaciones sin limitaciones de puntos.'),
              SizedBox(height: spaceBetweenParagraphs),
              Text('El hecho de que un jugador haya abierto tiene implicaciones en dos aspectos del juego muy importantes, que son:'),
              SizedBox(height: spaceBetweenParagraphs),
              Padding(padding: EdgeInsets.only(left: leftPadding), child: Text('Si un jugador no ha abierto no puede tomar carta de la pila de descartes. Obligatoriamente tiene que \'robar\' carta, es decir tomar una carta del mazo. Una excepción parcial a esta norma es que, sin haber abierto,  puede tomar la carta de la pila de descartes, para a continuación, en el mismo turno de juego, Abrir su juego.')),
              SizedBox(height: spaceBetweenPart),
              Padding(padding: EdgeInsets.only(left: leftPadding), child: Text('Si un jugador no ha abierto no puede colocar cartas en las combinaciones extendidas de otros jugadores, ni cambiar cartas por comodines. Esta acción si puede llevarla a cabo en el mismo turno de juego en el que abre.')),
              SizedBox(height: spaceBetweenParagraphs),
              Padding(padding: EdgeInsets.only(left: leftPadding), child: Text('Si un jugador inicia el proceso de \'Abrir\', pero se da cuenta de que no tiene los puntos necesarios (al menos 51), debe recoger las cartas, devolver a la pila de descartes si ha tomado carta de ahí y \'robar\' carta.')),
              SizedBox(height: spaceBetweenParagraphs),
              Text('El Despliegue debe realizarse solo con las cartas que el jugador tiene en la mano. No puede colocar una carta en una combinación ya extendida y cambiarla por un comodín, y utilizar el comodín para extender una combinación con la que lograr los 51 puntos. Primero debe extender los 51 puntos con sus cartas y después, añadir otras cartas en otras combinaciones y cambiar por comodines si ello es posible.'),
            ],
          ),
          ExpansionTile(
            title: Text('Combinaciones válidas'),
            childrenPadding: EdgeInsets.fromLTRB(leftPadding, topPadding, rightPadding, bottomPadding),
            children: [
              Text('Escaleras: Al menos tres cartas del mismo palo en secuencia. Por ejemplo Cinco-Seis-Siete de Bastos. Se admite que después del Rey pueda colocarse un As. (Pero detrás ya no puede colocarse el dos). Si la escalera tiene tres cartas, solo puede haber un comodín. El número máximo de comodines que puede haber en una escalera es el número de cartas que contiene menos dos.'),
              SizedBox(height: spaceBetweenParagraphs),
              Text('Tríos: Al menos tres cartas del mismo valor, pero distinto palo. Por ejemplo Cinco de Oros, Cinco de Copas, Cinco de Bastos. En un trío no puede haber dos cartas del mismo palo, por lo que como máximo sólo puede haber cuatro cartas en una combinación de este tipo. Cuando la combinación tiene tres cartas sólo puede haber un comodín.'),
            ],
          ),
          ExpansionTile(
            title: Text('Puntuación'),
            childrenPadding: EdgeInsets.fromLTRB(leftPadding, topPadding, rightPadding, bottomPadding),
            children: [
              Text('Un juego consta de varias partidas o manos en donde van sumándose los puntos de cada una de ellas. Cuando un jugador \'Cierra\' (se queda sin cartas) consigue 0 puntos, y los demás deben sumar el valor de las cartas que tienen en la mano, según el criterio de valoración dado anteriormente. Hay que notar que se suman los puntos de todas las cartas que se tienen en la mano tanto si forman parte de una combinación completa como si no. A este efecto los comodines valen siempre 25 puntos.'),
              SizedBox(height: spaceBetweenParagraphs),
              Text('Antes de comenzar el juego se determina el límite de puntos, que normalmente es 100. Cuando un jugador supera esta barrera al finalizar una partida se repesca (se \'reengancha\') asumiendo los mismos puntos que el jugador que más puntos tiene. Cuando todos los jugadores, menos uno superar el límite se termina el juego siendo el ganador el único que no supera este límite y que además es el que ha ganado la última partida.'),
            ],
          ),
          ExpansionTile(
            title: Text('Pagos o puntos por Reenganche'),
            childrenPadding: EdgeInsets.fromLTRB(leftPadding, topPadding, rightPadding, bottomPadding),
            children: [
              Text('Para dar un interés adicional a los juegos parciales se puede establecer algún tipo de pago, en dinero o en puntos, que deben satisfacer los jugadores que se reenganchan al jugador que ha ganado la mano que provoca el reenganche. De forma similar el jugador que gana finalmente la partida puede recibir un pago previamente acordado por parte de los demás jugadores. Por ejemplo se puede establecer un pago de 1 moneda o punto por reenganche y 3 monedas o puntos por el triunfo final. Puede establecerse la clasificación final de pagos, que no siempre coincidirá con la clasificación de la partida.'),
            ],
          ),
        ],
      ),
    );
  }
}