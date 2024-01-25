//--------------------------------------------------------------------------------------------------------------
PImage logo;

int[][] grid;                    //2D Grid Array for the current condition of the cells
int[][] next;                    //2D Grid Array for the new condition of the cells

//Festlegen der Farben--------------------------//

color alive = (#00ff00);         //green
color dead = (0);                //black

//color alive = (#ffffff);       //green
//color dead = (#387f91);        //Sherpa Logo Color

//color alive = 0;               //black
//color dead = 255;              //white

int gridSize = 30;               //Daniel Shiffman: "resolution"
int strokeW = 2;

//Festlegen der Parameter--------------------------//
int lineCount = 4;               //Line Count inside an alive cell to fill = alive
int schwellwertGrid = 50;        //Processing only draws a grid if grid size exceeds this value

//Festlegen der Animation--------------------------//
int framerate;
int endFrame = 189;              //Sets the last frame to plot the image using a plotter. Alternative: SaveFrame stop or exit

//--------------------------------------------------------------------------------------------------------------

void setup() {
  size(1080, 1080);
  noLoop();

  //logo = loadImage("MITmediaLab_Logo800x800.png");        //Laden des gewünschten Ausgangsbildes
  //logo = loadImage("Adidas_Logo800x800.png");
  logo = loadImage("BU_Logo800x800.png");
  //logo = loadImage("Sherpa_Logo800x800.png");

  grid = new int[gridSize][gridSize];                     //Initialisieren des Arrays für das Grid
  
//Aufrastern des Input-Logobildes für den Ausgangszustand--------------------------//

  for (int i = 0; i < gridSize; i = i + 1) {              //Hochzählen des Reaster in x/y bzw i/j Richtung
    for (int j = 0; j < gridSize; j = j + 1) {
      float xScale = (float) logo.width / gridSize;       //Berechnen der Größe eines Feldes für Bestimmung des Ausgangszustandes auf Grundlage der Bildgröße Input-Logobilde
      float yScale = (float) logo.height / gridSize;
      int x = floor(i * xScale);
      int y = floor(j * yScale);
      
      color input = logo.get(x, y);                       //Input entspricht dem Brightness Level des Pixels auf dem Input-Logobildes
      
 //Speichern des Zustandes in dem neu initialisierten Grid Array, Liste der dead / alive Cells --------------------------//

      if (brightness(input) < 128) {                      //Wenn Weiß oder Hellgrau (< 128 Brightness) -> Feld ist dead im Ausgangsstatus (Weiße Füllung)
        grid[i][j] = 1;                                   //Wenn Schwarz oder Dunkelgrau (> 128 Brightness) -> Feld ist alive im Ausgangsstatus (Schwarze Füllung)
      } else {
        grid[i][j] = 0;
      }
    }
  }
}

//--------------------------------------------------------------------------------------------------------------

void draw() {
  background(dead);
  stroke(alive);
  strokeWeight(strokeW);
  noFill();

//Steuerrung der Framerate --------------------------//
  println(frameCount);
  if (frameCount < 5) {
    frameRate(1);
  } else if (frameCount < 20) {
    frameRate(5);
  } else {
    frameRate(10);
  }
//Zeichnen des ersten Frames --------------------------//
  for (int i = 0; i < gridSize; i++) {
    for (int j = 0; j < gridSize; j++) {
      float cellSize = (float) width / gridSize;
      float cellX = cellSize * i;
      float cellY = cellSize * j;
      if (grid[i][j] == 1) {                                          //Falls die Zelle lebt (alive), entspricht gespeichertem Wert "1" im Array, wird rectPlot() ausgeführt
        rectPlot(cellX, cellY, cellSize, cellSize, lineCount);        //Hier werden die eigentlichen Kästchen gezeichnet mit rectPLot()-Funktion statt rect()
      }
    }
  }

  int[][] next = new int[gridSize][gridSize];                         //Initialisierung des zweiten Arrays für die Zwischenspeicherung der Werte für folgende Frames

//Codeteile von Processing Examples Website! --------------------------//
  // Compute next based on grid 
  for (int i = 0; i < gridSize; i++) {
    for (int j = 0; j < gridSize; j++) {
      int state = grid[i][j];

      // Count live neighbors!
      //int sum = 0;
      int neighbors = countNeighbors(grid, i, j);
      
//Zuweisung des neuen Status zu den Zellen, basierend auf gezählten alive Nachbarn --------------------------//

      if (state == 0 && neighbors == 3) {
        next[i][j] = 1;
      } else if (state == 1 && (neighbors < 2 || neighbors > 3)) {
        next[i][j] = 0;
      } else {
        next[i][j] = state;
      }
    }
  }

  grid = next;                                    //Überschreiben des Arrays, der Array "next" wird jetzt zum neuen Ausgangszustand
  
//Draw Grid --------------------------//
  if (gridSize <= schwellwertGrid) {              //Entscheidung, ob ein Grundraster gezeichnet werden soll ist abhängig
       drawGrid();                                //von der gridSize, bei hoher gridSize wird kein Raster gezeichnet
  }
  
//Stoppen des Loops bei beliebigem Endframe zum Plotten --------------------------//
     if (frameCount == endFrame) {
   noLoop();
   saveFrame("Instagram/Export_Für_Instagram_Matrix.png");
   }
}


//--------------------------------------------------------------------------------------------------------------

int countNeighbors(int [][]grid, int x, int y) {
  int sum = 0;
  for (int i = -1; i < 2; i++) {
    for (int j = -1; j < 2; j++) {
      int col = (x + i + gridSize) % gridSize;              //Modulo Operator sorgt dafür, dass am Grid-Rand je die Zelle am anderen Ende des Grid gezählt wird
      int row = (y + j + gridSize) % gridSize;
      sum += grid[col][row];
    }
  }
  sum -= grid[x][y];
  return sum;
}


//--------------------------------------------------------------------------------------------------------------
//Grid Size 100x100
void drawGrid() {
  noFill();
  stroke(alive);
  strokeWeight(strokeW);

  for (int i = 1; i < gridSize; i++) {

    beginShape();                                //Horizontal Grid
    vertex(0, (float) i * height / gridSize);
    vertex(width, (float) i * height / gridSize);
    endShape();
  }

  for (int i = 1; i < gridSize; i++) {
    beginShape();                                //Vertical Grid
    vertex((float) i * width / gridSize, 0);
    vertex((float) i * width / gridSize, height);
    endShape();
  }
}

//--------------------------------------------------------------------------------------------------------------
//Enable / disable Loop
void keyReleased() {

  if (keyCode == LEFT) {
    loop();                          //Enable Loop, GameOfLife Start
  }

  if (keyCode == RIGHT) {
    noLoop();                        //Disable Loop, GameOfLife Freeze
  }
}

//--------------------------------------------------------------------------------------------------------------
//Draw plottable rect()
void rectPlot(float x, float y, float b, float h, int lineCount) {
  strokeWeight(strokeW);
  noFill();
  stroke(alive);

  int s = 0;                                     //Variable s speichert entscheidung, ob kein Grid (0) oder Grid (1) gezeichnet wird
  if (gridSize <= schwellwertGrid) {             //Entscheidung, ob ein Grundraster gezeichnet werden soll ist abhängig
    s = 1;                                       //von der gridSize, bei hoher gridSize wird kein Raster gezeichnet
  }

  for (int i = s; i < lineCount; i++) {          //Falls Grid gezeichnet wird (x=1), bildes das Grid den Äußeren Rand der
                                                 //Alive Cell und der Plotter zeichnet die Linie nicht doppelt, da nur innere Linien der Schraffur gezählt werden
    //linecount = 3, Notiz
    //breite, höhe (b, h) = cellSize

    int versatz = floor(b / 2 / lineCount);         //Ausrechnen des Versatzes nach Innen
                                                    //gridsize durch Line Count (3) // Dritteln des Kästchens
                                                    //daraufhin halbieren des Drittels, da mittige Ausrichtung gewünscht ist und so Links und Rechts 1/6 PLatz sein muss

    beginShape();                                   //Schraffur in Alive Cell
    vertex(x + versatz * i, y + i * versatz);       //Draw Rect mit VErtext Punkten ObenLinks; ObenRechts; UntenRechts; UntenLinks; Close
    vertex(x - versatz * i + b, y + i * versatz);   //Versatz des Rechecks einberechnen
    vertex(x - versatz * i + b, y - i * versatz + h);
    vertex(x + versatz * i, y - i * versatz + h);
    endShape(CLOSE);

  }
    beginShape();                                   //Diagonale Linie 1 in Alive Cell
    vertex(x, y);  vertex(x + b, y + h);
    endShape();
    beginShape();                                   //Diagonale Linie 2 in Alive Cell
    vertex(x, y + h); vertex(x + b, y);
    endShape();
}
//--------------------------------------------------------------------------------------------------------------
