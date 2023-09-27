/*
Автор: Бочков Андрей.
Программа симуляции волн
Управление:
  Пробел: Пауза/Симуляция. Изначально пауза.
  Символ звёздочки (*): Проигрыш одного кадра симуляции. Только если симуляция на паузе.
  Цифры (1 - 5), клавиши "▲" и "▼": влияние на динамику симуляции (убывание волн).
  Клавиши "◄" и "►": Изменение частоты генераторов (не влияет на уже выставленные на поле).
  Клавиша Q/Й: Переключение режимов:
    1. Визуализация волн
    2. Накопление значения
    Изначально режим 1.
  Клавиша W/Ц: "Заблокировать" клетку.
  Клавиша E/У: Создать подушку. Подушки пропускают волны, частично гася их.
  Клавиша A/Ф: Создать генератор.
  Клавиша S/Ы: Создать отрицательный генератор. Отрицательный генератор работает в противофазе с обычным.
  Клавиша R/К: Очистить поле
  
  ЛКМ (левая кнопка мыши): Увеличить значение нажатой клетки.
  ПКМ (правая кнопка мыши): Уменьшить значение нажатой клетки.
*/

class Spring {
  private float pos, vel, freq = 2;
  private int state;
  public Spring(){pos = 0;vel = 0;}
  void run() {
    if (state == 1) {
      pos=0;
      vel=0;
    } else if (state == 2) {
      pos += vel*0.2;
    } else if (state == 3) {
      pos = sin(fC/fR*freq*TWO_PI)*100;
    } else if (state == 4) {
      pos = -sin(fC/fR*freq*TWO_PI)*100;
    } else {
      pos += vel;
    }
    
    if (pos > 10000) {
      pos = 10000;
    } else if (pos < -10000) {
      pos = -10000;
    }
  }
}

public Spring[][] Matrix;
public float[][] Prev, Heat;
public float temp = 0.0, plus, minus, heat, newFreq = 2.0, fR;
public int wcel, hcel, counterText = 0, fC = 0;
private byte cellSize = 10, mode = 0, modify_temp = -1;
public String[] modes = {"Стандарт", "Накопление"};
public boolean pause = true, keyPress = false, modifying = false, showText = false, oneframe = false;
public String textValue;

public float decline = 0.05;

void setup() {
  stroke(0);
  noStroke();
  size(500, 500);
  background(0);
  cursor(CROSS);
  wcel = width/cellSize;
  hcel = height/cellSize;
  Matrix = new Spring[wcel][hcel];
  for (int i = 0; i < wcel; i ++) {
    for (int j = 0; j < hcel; j ++) {
      Matrix[i][j] = new Spring();
      if (i == 0 || j == 0 || i == wcel-1 || j == hcel-1) {
        Matrix[i][j].state = 1;
      }
    }
  }
  Prev = new float[wcel][hcel];
  Heat = new float[wcel][hcel];
  fR = frameRate;
}

void draw() {
  background(0);
  if (!pause || oneframe) {
    for (int i = 1; i < wcel-1; i ++) {
      for (int j = 1; j < hcel-1; j ++) {
        if (Matrix[i][j].state != 1 && Matrix[i][j].state != 3 && Matrix[i][j].state != 4) {
          Prev[i][j] = Matrix[i][j].vel;
        } else {
          Prev[i][j] = 0;
        }
      }
    }
    
    for (int i = 1; i < wcel-1; i ++) {
      for (int j = 1; j < hcel-1; j ++) {
        temp = Matrix[i-1][j].pos + Matrix[i+1][j].pos + Matrix[i][j-1].pos + Matrix[i][j+1].pos;
        if (!(temp == 0)) {
          Prev[i][j] += temp/4 - Matrix[i][j].pos;
        }
      }
    }
    
    for (int i = 0; i < wcel; i ++) {
      for (int j = 0; j < hcel; j ++) {
        Matrix[i][j].vel = Prev[i][j] * (1-decline);
        Matrix[i][j].run();
        if (mode == 1) {
          Heat[i][j] += abs(Matrix[i][j].pos);
          Heat[i][j] *= 0.95;
        }
      }
    }
    if (oneframe) {
      oneframe = false;
    }
    
    fC ++;
  }
  
  if (mode == 0) {
    for (int i = 0; i < wcel; i ++) {
      for (int j = 0; j < hcel; j ++) {
        if (Matrix[i][j].state == 1) {
          fill(255);
        } else if (Matrix[i][j].state == 2) {
          plus = map(max(Matrix[i][j].pos, 0), 100, 0, 255, 0);
          minus = map(min(Matrix[i][j].pos, 0), -100, 0, 255, 0);
          fill(plus*0.2+50, 50, minus*0.2+50);
        } else if (Matrix[i][j].state == 3) {
          fill(200);
        } else if (Matrix[i][j].state == 4) {
          fill(150);
        } else {
          plus = map(max(Matrix[i][j].pos, 0), 100, 0, 255, 0);
          minus = map(min(Matrix[i][j].pos, 0), -100, 0, 255, 0);
          fill(plus, plus*0.1 + minus*0.1, minus);
        }
        rect(i*cellSize, j*cellSize, cellSize, cellSize);
      }
    }
  } else if (mode == 1) {
    for (int i = 0; i < wcel; i ++) {
      for (int j = 0; j < hcel; j ++) {
        if (Matrix[i][j].state == 1) {
          fill(50, 50, 200);
        } else if (Matrix[i][j].state == 2) {
          plus = map(max(Matrix[i][j].pos, 0), 100, 0, 255, 0);
          minus = map(min(Matrix[i][j].pos, 0), -100, 0, 255, 0);
          fill(plus*0.2+50, 50, minus*0.2+50);
        } else if (Matrix[i][j].state == 3) {
          fill(200);
        } else if (Matrix[i][j].state == 4) {
          fill(150);
        } else {
          plus = map(max(Matrix[i][j].pos, 0), 100, 0, 255, 0);
          minus = map(min(Matrix[i][j].pos, 0), -100, 0, 255, 0);
          heat = map(Heat[i][j], 0, 200, 0, 255);
          fill(plus*0.5+heat*0.1, heat+plus*0.1+minus*0.1, minus*0.5+heat*0.1);
        }
        rect(i*cellSize, j*cellSize, cellSize, cellSize);
      }
    }
  }
  
  if (mousePressed) {
    if (mouseX > cellSize && mouseX < width-cellSize && mouseY > cellSize && mouseY < height-cellSize) {
      Spring mtemp = Matrix[floor(mouseX / cellSize)][floor(mouseY / cellSize)];
      if (pause) {
        if (mouseButton == LEFT) { 
          if (mtemp.state != 1) {
            mtemp.pos += 50;
          }
        } else if (mouseButton == RIGHT) {
          if (mtemp.state != 1) {
            mtemp.pos -= 50;
          }
        }
      } else {
        if (mouseButton == LEFT) {
          if (mtemp.state != 1) {
            mtemp.pos += 100;
            mtemp.vel = 0;
          }
        } else if (mouseButton == RIGHT) {
          if (mtemp.state != 1) {
            mtemp.pos -= 100;
            mtemp.vel = 0;
          }
        }
      }
    }
  }
  
  if (showText) {
    counterText ++;
    if (counterText <= round(frameRate)) {
      text(textValue, 50, 50);
    }
  }
}

void keyPressed() {
  if (!keyPress) {
    if (key == ' ') {
      pause = !pause;
      keyPress = true;
      if (pause) {textValue = "Пауза";}
      else {textValue = "Симуляция";}
      showText = true;
      counterText = 0;
    } else if (key == '+') {
      if (decline < 0.5) {
        decline += 0.01;
        decline = round(decline*1000.0)/1000.0;
      }
      showText("Убывание: " + str(decline));
    } else if (key == '-') {
      if (decline > 0.01) {
        decline -= 0.01;
        decline = round(decline*1000.0)/1000.0;
      }
      showText("Убывание: " + str(decline));
    } else if (key == '*') {
      oneframe = true;
      keyPress = true;
    } else if (key == '0') {
      decline = 0.01;
      showText("Убывание: " + str(decline));
      keyPress = true;
    } else if (key == '1') {
      decline = 0.1;
      showText("Убывание: " + str(decline));
      keyPress = true;
    } else if (key == '2') {
      decline = 0.2;
      showText("Убывание: " + str(decline));
      keyPress = true;
    } else if (key == '3') {
      decline = 0.3;
      showText("Убывание: " + str(decline));
      keyPress = true;
    } else if (key == '4') {
      decline = 0.4;
      showText("Убывание: " + str(decline));
      keyPress = true;
    } else if (key == '5') {
      decline = 0.5;
      showText("Убывание: " + str(decline));
      keyPress = true;
    } else if (key == 'q' || key == 'й') {
      mode ++;
      if (mode == modes.length) {
        mode = 0;
      }
      showText("Режим: " + modes[mode]);
      keyPress = true;
    } else if (key == 'w' || key == 'ц') {
      if (!modifying) {
        modifying = true;
        if (Matrix[floor(mouseX / cellSize)][floor(mouseY / cellSize)].state == 0) {
          modify_temp = 1;
        } else {
           modify_temp = 0;
        }
      } else {
        Matrix[floor(mouseX / cellSize)][floor(mouseY / cellSize)].state = modify_temp;
      }
    } else if (key == 'e' || key == 'у') {
      if (!modifying) {
        modifying = true;
        if (Matrix[floor(mouseX / cellSize)][floor(mouseY / cellSize)].state == 0) {
          modify_temp = 2;
        } else {
           modify_temp = 0;
        }
      } else {
        Matrix[floor(mouseX / cellSize)][floor(mouseY / cellSize)].state = modify_temp;
      }
    } else if (key == 'a' || key == 'ф') {
      if (!modifying) {
        modifying = true;
        if (Matrix[floor(mouseX / cellSize)][floor(mouseY / cellSize)].state == 0) {
          modify_temp = 3;
        } else {
           modify_temp = 0;
        }
      } else {
        Matrix[floor(mouseX / cellSize)][floor(mouseY / cellSize)].state = modify_temp;
        Matrix[floor(mouseX / cellSize)][floor(mouseY / cellSize)].freq = newFreq;
      }
    } else if (key == 's' || key == 'ы') {
      if (!modifying) {
        modifying = true;
        if (Matrix[floor(mouseX / cellSize)][floor(mouseY / cellSize)].state == 0) {
          modify_temp = 4;
        } else {
           modify_temp = 0;
        }
      } else {
        Matrix[floor(mouseX / cellSize)][floor(mouseY / cellSize)].state = modify_temp;
        Matrix[floor(mouseX / cellSize)][floor(mouseY / cellSize)].freq = newFreq;
      }
    } else if (key == 'r' || key == 'к') {
      for (int i = 0; i < wcel; i ++) {
        for (int j = 1; j < hcel-1; j ++) {
          Matrix[i][j] = new Spring();
          Heat[i][j] = 0;
          if (i == 0 || j == 0 || i == wcel-1 || j == hcel-1) {
            Matrix[i][j].state = 1;
          }
        }
      }
      keyPress = true;
    } else if (keyCode == RIGHT) {
      if (newFreq < 5) {
        newFreq += 0.5;
      }
      newFreq = round(newFreq*10.0)/10.0;
      showText("Частота новых генераторов: " + str(newFreq) + " Hz");
    } else if (keyCode == LEFT) {
      if (newFreq > 0) {
        newFreq -= 0.5;
      }
      newFreq = round(newFreq*10.0)/10.0;
      showText("Частота новых генераторов: " + str(newFreq) + " Hz");
    } else {
      showText("Команда не существует");
    }
  }
}

void keyReleased() {
  keyPress = false;
  modifying = false;
  modify_temp = -1;
}

void showText(String str) {
  textValue = str;
  showText = true;
  counterText = 0;
}
