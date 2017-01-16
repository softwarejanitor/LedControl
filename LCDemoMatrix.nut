require("SPI");

dofile("sd:/LedControl.nut");

local lc = LedControl(0, 1);

/* we always wait a bit between updates of the display */
local delaytime=100;

/*
 The MAX72XX is in power-saving mode on startup,
 we have to do a wakeup call
 */
lc.shutdown(0,false);
/* Set the brightness to a medium values */
lc.setIntensity(0,8);
/* and clear the display */
lc.clearDisplay(0);

/*
 This method will display the characters for the
 word "Arduino" one after the other on the matrix. 
 (you need at least 5x7 leds to see the whole chars)
 */
function writeArduinoOnMatrix()
{
    /* here is the data for the characters */
    a = blob(5);
    a[0] = 0x7e;  // B01111110
    a[1] = 0x88;  // B10001000
    a[2] = 0x88;  // B10001000
    a[3] = 0x88;  // B10001000
    a[4] = 0x7e;  // B01111110
    r = blob(5);
    r[0] = 0x3e;  // B00111110
    r[1] = 0x10;  // B00010000
    r[2] = 0x20;  // B00100000
    r[3] = 0x20;  // B00100000
    r[4] = 0x10;  // B00010000
    d = blob(5);
    d[0] = 0x1c;  // B00011100
    d[1] = 0x22;  // B00100010
    d[2] = 0x22;  // B00100010
    d[3] = 0x12;  // B00010010
    d[4] = 0xfe;  // B11111110
    u = blob(5);
    u[0] = 0x3c;  // B00111100
    u[1] = 0x02;  // B00000010
    u[2] = 0x02;  // B00000010
    u[3] = 0x04;  // B00000100
    u[4] = 0x3e;  // B00111110
    i = blob(5);
    i[0] = 0x00;  // B00000000
    i[1] = 0x22;  // B00100010
    i[2] = 0xbe;  // B10111110
    i[3] = 0x02;  // B00000010
    i[4] = 0x00;  // B00000000
    n = blob(5);
    n[0] = 0x3e;  // B00111110
    n[1] = 0x10;  // B00010000
    n[2] = 0x20;  // B00100000
    n[3] = 0x20;  // B00100000
    n[4] = 0x1e;  // B00011110
    o = blob(5);
    o[0] = 0x1c;  // B00011100
    o[1] = 0x22;  // B00100010
    o[2] = 0x22;  // B00100010
    o[3] = 0x22;  // B00100010
    o[4] = 0x1c;  // B00011100

    /* now display them one by one with a small delay */
    lc.setRow(0, 0, a[0]);
    lc.setRow(0, 1, a[1]);
    lc.setRow(0, 2, a[2]);
    lc.setRow(0, 3, a[3]);
    lc.setRow(0, 4, a[4]);
    delay(delaytime);
    lc.setRow(0, 0, r[0]);
    lc.setRow(0, 1, r[1]);
    lc.setRow(0, 2, r[2]);
    lc.setRow(0, 3, r[3]);
    lc.setRow(0, 4, r[4]);
    delay(delaytime);
    lc.setRow(0, 0, d[0]);
    lc.setRow(0, 1, d[1]);
    lc.setRow(0, 2, d[2]);
    lc.setRow(0, 3, d[3]);
    lc.setRow(0, 4, d[4]);
    delay(delaytime);
    lc.setRow(0, 0, u[0]);
    lc.setRow(0, 1, u[1]);
    lc.setRow(0, 2, u[2]);
    lc.setRow(0, 3, u[3]);
    lc.setRow(0, 4, u[4]);
    delay(delaytime);
    lc.setRow(0, 0, i[0]);
    lc.setRow(0, 1, i[1]);
    lc.setRow(0, 2, i[2]);
    lc.setRow(0, 3, i[3]);
    lc.setRow(0, 4, i[4]);
    delay(delaytime);
    lc.setRow(0, 0, n[0]);
    lc.setRow(0, 1, n[1]);
    lc.setRow(0, 2, n[2]);
    lc.setRow(0, 3, n[3]);
    lc.setRow(0, 4, n[4]);
    delay(delaytime);
    lc.setRow(0, 0, o[0]);
    lc.setRow(0, 1, o[1]);
    lc.setRow(0, 2, o[2]);
    lc.setRow(0, 3, o[3]);
    lc.setRow(0, 4, o[4]);
    delay(delaytime);
    lc.setRow(0, 0, 0);
    lc.setRow(0, 1, 0);
    lc.setRow(0, 2, 0);
    lc.setRow(0, 3, 0);
    lc.setRow(0, 4, 0);
    delay(delaytime);
}

/*
  This function lights up a some Leds in a row.
  The pattern will be repeated on every row.
  The pattern will blink along with the row-number.
  row number 4 (index==3) will blink 4 times etc.
  */
function rows()
{
    local row;
    local i;
    for (row = 0; row < 8; row++) {
        delay(delaytime);
        lc.setRow(0, row, 0xa0);  // B10100000 
        delay(delaytime);
        lc.setRow(0, row, 0x00);
        for (i = 0; i < row; i++) {
            delay(delaytime);
            lc.setRow(0, row, 0xa0);  // B10100000;
            delay(delaytime);
            lc.setRow(0, row, 0x00);
        }
    }
}

/*
  This function lights up a some Leds in a column.
 The pattern will be repeated on every column.
 The pattern will blink along with the column-number.
 column number 4 (index==3) will blink 4 times etc.
 */
function columns()
{
    local col;
    local i;
    for (col = 0; col < 8; col++) {
        delay(delaytime);
        lc.setColumn(0, col, 0xa0);  // B10100000;
        delay(delaytime);
        lc.setColumn(0, col, 0x00);
        for (i = 0; i < col; i++) {
            delay(delaytime);
            lc.setColumn(0, col, 0xa0);  // B10100000;
            delay(delaytime);
            lc.setColumn(0, col, 0x00);
        }
    }
}

/* 
 This function will light up every Led on the matrix.
 The led will blink along with the row-number.
 row number 4 (index==3) will blink 4 times etc.
 */
function single()
{
    local row;
    local col;
    local i;
    for (row = 0; row < 8; row++) {
        for (col = 0; col < 8; col++) {
            delay(delaytime);
            lc.setLed(0, row, col, true);
            delay(delaytime);
            for (i = 0; i < col; i++) {
                lc.setLed(0, row, col, false);
                delay(delaytime);
                lc.setLed(0, row, col, true);
                delay(delaytime);
            }
        }
    }
}

while (1) { 
    writeArduinoOnMatrix();
    rows();
    columns();
    single();
}

