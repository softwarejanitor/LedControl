/*
 *    LedControl.nut - A library for controling Leds with a MAX7219/MAX7221
 *    Copyright (c) 2007 Eberhard Fahle
 *
 *    Ported to Esquilo 20161226 Leeland Heins
 *
 *    Permission is hereby granted, free of charge, to any person
 *    obtaining a copy of this software and associated documentation
 *    files (the "Software"), to deal in the Software without
 *    restriction, including without limitation the rights to use,
 *    copy, modify, merge, publish, distribute, sublicense, and/or sell
 *    copies of the Software, and to permit persons to whom the
 *    Software is furnished to do so, subject to the following
 *    conditions:
 *
 *    This permission notice shall be included in all copies or
 *    substantial portions of the Software.
 *
 *    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 *    OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 *    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 *    HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 *    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 *    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 *    OTHER DEALINGS IN THE SOFTWARE.
 */

class LedControl
{
    /* The array for shifting the data to the devices */
    spidata = blob(16);

    spi = 0;

    /* We keep track of the led-status for all 8 devices in this array */
    status = blob(64);
    /* The maximum number of devices we use */
    maxDevices = 1;

    charTable = null;

    // the opcodes for the MAX7221 and MAX7219
    const OP_NOOP        =  0;
    const OP_DIGIT0      =  1;
    const OP_DIGIT1      =  2;
    const OP_DIGIT2      =  3;
    const OP_DIGIT3      =  4;
    const OP_DIGIT4      =  5;
    const OP_DIGIT5      =  6;
    const OP_DIGIT6      =  7;
    const OP_DIGIT7      =  8;
    const OP_DECODEMODE  =  9;
    const OP_INTENSITY   = 10;
    const OP_SCANLIMIT   = 11;
    const OP_SHUTDOWN    = 12;
    const OP_DISPLAYTEST = 15;

    constructor (_spi, _nd)
    {
        spi = SPI(_spi);
        maxDevices = _nd;

        if (maxDevices < 1) {
            maxDevices = 1;
        }
        if (maxDevices > 8) {
            maxDevices = 8;
        }

        local i;
        for (i = 0; i < 64; i++) {
            status[i] = 0x00;
        }
        for (i = 0; i < maxDevices; i++) {
            spiTransfer(i, OP_DISPLAYTEST, 0);
            // scanlimit is set to max on startup
            setScanLimit(i, 7);
            // decode is done in source
            spiTransfer(i, OP_DECODEMODE, 0);
            clearDisplay(i);
            // we go into shutdown-mode on startup
            shutdown(i, true);
        }

        /*
         * Segments to be switched on for characters and digits on
         * 7-Segment Displays
         */

        charTable = blob(128);

        charTable[0]   = 0x7e;  //   B01111110
        charTable[1]   = 0x30;  //   B00110000
        charTable[2]   = 0x6d;  //   B01101101
        charTable[3]   = 0x00;  //   B01111001
        charTable[4]   = 0x33;  //   B00110011
        charTable[5]   = 0x5d;  //   B01011011
        charTable[6]   = 0x5f;  //   B01011111
        charTable[7]   = 0x70;  //   B01110000

        charTable[8]   = 0x7f;  //   B01111111
        charTable[9]   = 0x7b;  //   B01111011
        charTable[10]  = 0x77;  //   B01110111
        charTable[11]  = 0x1f;  //   B00011111
        charTable[12]  = 0x0d;  //   B00001101
        charTable[13]  = 0x3d;  //   B00111101
        charTable[14]  = 0x4f;  //   B01001111
        charTable[15]  = 0x47;  //   B01000111

        charTable[16]  = 0x00;  //   B00000000
        charTable[17]  = 0x00;  //   B00000000
        charTable[18]  = 0x00;  //   B00000000
        charTable[19]  = 0x00;  //   B00000000
        charTable[20]  = 0x00;  //   B00000000
        charTable[21]  = 0x00;  //   B00000000
        charTable[22]  = 0x00;  //   B00000000
        charTable[23]  = 0x00;  //   B00000000

        charTable[24]  = 0x00;  //   B00000000
        charTable[25]  = 0x00;  //   B00000000
        charTable[26]  = 0x00;  //   B00000000
        charTable[27]  = 0x00;  //   B00000000
        charTable[28]  = 0x00;  //   B00000000
        charTable[29]  = 0x00;  //   B00000000
        charTable[30]  = 0x00;  //   B00000000
        charTable[31]  = 0x00;  //   B00000000

        charTable[32]  = 0x00;  //   B00000000
        charTable[33]  = 0x00;  //   B00000000
        charTable[34]  = 0x00;  //   B00000000
        charTable[35]  = 0x00;  //   B00000000
        charTable[36]  = 0x00;  //   B00000000
        charTable[37]  = 0x00;  //   B00000000
        charTable[38]  = 0x00;  //   B00000000
        charTable[39]  = 0x00;  //   B00000000

        charTable[40]  = 0x00;  //   B00000000
        charTable[41]  = 0x00;  //   B00000000
        charTable[42]  = 0x00;  //   B00000000
        charTable[43]  = 0x00;  //   B00000000
        charTable[44]  = 0x80;  //   B10000000
        charTable[45]  = 0x01;  //   B00000001
        charTable[46]  = 0x80;  //   B10000000
        charTable[47]  = 0x00;  //   B00000000

        charTable[48]  = 0x7e;  //   B01111110
        charTable[49]  = 0x30;  //   B00110000
        charTable[50]  = 0x6d;  //   B01101101
        charTable[51]  = 0x79;  //   B01111001
        charTable[52]  = 0x33;  //   B00110011
        charTable[53]  = 0x5b;  //   B01011011
        charTable[54]  = 0xbf;  //   B01011111
        charTable[55]  = 0x70;  //   B01110000

        charTable[56]  = 0x7f;  //   B01111111
        charTable[57]  = 0x7b;  //   B01111011
        charTable[58]  = 0x00;  //   B00000000
        charTable[59]  = 0x00;  //   B00000000
        charTable[60]  = 0x00;  //   B00000000
        charTable[61]  = 0x00;  //   B00000000
        charTable[62]  = 0x00;  //   B00000000
        charTable[63]  = 0x00;  //   B00000000

        charTable[64]  = 0x00;  //   B00000000
        charTable[65]  = 0x77;  //   B01110111
        charTable[66]  = 0x1f;  //   B00011111
        charTable[67]  = 0x0d;  //   B00001101
        charTable[68]  = 0x3b;  //   B00111101
        charTable[69]  = 0x4f;  //   B01001111
        charTable[70]  = 0x47;  //   B01000111
        charTable[71]  = 0x00;  //   B00000000

        charTable[72]  = 0x37;  //   B00110111
        charTable[73]  = 0x00;  //   B00000000
        charTable[74]  = 0x00;  //   B00000000
        charTable[75]  = 0x00;  //   B00000000
        charTable[76]  = 0x0e;  //   B00001110
        charTable[77]  = 0x00;  //   B00000000
        charTable[78]  = 0x00;  //   B00000000
        charTable[79]  = 0x00;  //   B00000000

        charTable[80]  = 0xc7;  //   B01100111
        charTable[81]  = 0x00;  //   B00000000
        charTable[82]  = 0x00;  //   B00000000
        charTable[83]  = 0x00;  //   B00000000
        charTable[84]  = 0x00;  //   B00000000
        charTable[85]  = 0x00;  //   B00000000
        charTable[86]  = 0x00;  //   B00000000
        charTable[87]  = 0x00;  //   B00000000

        charTable[88]  = 0x00;  //   B00000000
        charTable[89]  = 0x00;  //   B00000000
        charTable[90]  = 0x00;  //   B00000000
        charTable[91]  = 0x00;  //   B00000000
        charTable[92]  = 0x00;  //   B00000000
        charTable[93]  = 0x00;  //   B00000000
        charTable[94]  = 0x00;  //   B00000000
        charTable[95]  = 0x08;  //   B00001000

        charTable[96]  = 0x00;  //   B00000000
        charTable[97]  = 0x77;  //   B01110111
        charTable[98]  = 0x1f;  //   B00011111
        charTable[99]  = 0x0d;  //   B00001101
        charTable[100] = 0x3d;  //   B00111101
        charTable[101] = 0x4f;  //   B01001111
        charTable[102] = 0x47;  //   B01000111
        charTable[103] = 0x00;  //   B00000000

        charTable[104] = 0x37;  //   B00110111
        charTable[105] = 0x00;  //   B00000000
        charTable[106] = 0x00;  //   B00000000
        charTable[107] = 0x00;  //   B00000000
        charTable[108] = 0x0e;  //   B00001110
        charTable[109] = 0x00;  //   B00000000
        charTable[110] = 0x15;  //   B00010101
        charTable[111] = 0x1d;  //   B00011101

        charTable[112] = 0x67;  //   B01100111
        charTable[113] = 0x00;  //   B00000000
        charTable[114] = 0x00;  //   B00000000
        charTable[115] = 0x00;  //   B00000000
        charTable[116] = 0x00;  //   B00000000
        charTable[117] = 0x00;  //   B00000000
        charTable[118] = 0x00;  //   B00000000
        charTable[119] = 0x00;  //   B00000000

        charTable[120] = 0x00;  //   B00000000
        charTable[121] = 0x00;  //   B00000000
        charTable[122] = 0x00;  //   B00000000
        charTable[123] = 0x00;  //   B00000000
        charTable[124] = 0x00;  //   B00000000
        charTable[125] = 0x00;  //   B00000000
        charTable[126] = 0x00;  //   B00000000
        charTable[127] = 0x00;  //   B00000000
    }
};

function LedControl::getDeviceCount()
{
    return maxDevices;
}

function LedControl::shutdown(addr, b)
{
    if (addr < 0 || addr >= maxDevices) {
        return;
    }
    if (b) {
        spiTransfer(addr, OP_SHUTDOWN, 0);
    } else {
        spiTransfer(addr, OP_SHUTDOWN, 1);
    }
}

function LedControl::setScanLimit(addr, limit)
{
    if (addr < 0 || addr >= maxDevices) {
        return;
    }
    if (limit >= 0 && limit < 8) {
        spiTransfer(addr, OP_SCANLIMIT, limit);
    }
}

function LedControl::setIntensity(addr, intensity)
{
    if (addr < 0 || addr >= maxDevices) {
        return;
    }
    if (intensity >= 0 && intensity < 16) {
        spiTransfer(addr, OP_INTENSITY, intensity);
    }
}

function LedControl::clearDisplay(addr)
{
    local offset;

    if (addr < 0 || addr >= maxDevices) {
        return;
    }
    offset = addr * 8;
    local i;
    for(i = 0; i < 8; i++) {
        status[offset + i] = 0;
        spiTransfer(addr, i + 1, status[offset + i]);
    }
}

function LedControl::setLed(addr, row, column, state)
{
    local offset;
    local val = 0x00;

    if (addr < 0 || addr >= maxDevices) {
        return;
    }
    if (row < 0 || row > 7 || column < 0 || column > 7) {
        return;
    }
    offset = addr * 8;
    // 0x80 = B10000000
    val = 0x80 >> column;
    if (state) {
        status[offset + row] = status[offset + row]|val;
    } else {
        val =~ val;
        status[offset + row] = status[offset + row] & val;
    }
    spiTransfer(addr, row + 1, status[offset + row]);
}

function LedControl::setRow(addr, row, value)
{
    local offset;
    if (addr < 0 || addr >= maxDevices) {
        return;
    }
    if (row < 0 || row > 7) {
        return;
    }
    offset = addr * 8;
    status[offset + row] = value;
    spiTransfer(addr, row + 1, status[offset + row]);
}

function LedControl::setColumn(addr, col, value)
{
    local val;

    if (addr < 0 || addr >= maxDevices) {
        return;
    }
    if (col < 0 || col > 7) {
        return;
    }
    local row;
    for (row = 0; row < 8; row++) {
        val = value >> (7 - row);
        val = val & 0x01;
        setLed(addr, row, col, val);
    }
}

function LedControl::setDigit(addr, digit, value, dp)
{
    local offset;
    local v;

    if (addr < 0 || addr >= maxDevices) {
        return;
    }
    if (digit < 0 || digit > 7 || value > 15) {
        return;
    }
    offset = addr * 8;
    v = charTable[value];
    if (dp) {
        // 0x80 = B10000000
        v = v | 0x80;
    }
    status[offset + digit] = v;
    spiTransfer(addr, digit + 1, v);
}

function LedControl::setChar(addr, digit, value, dp)
{
    local offset;
    local index;
    local v;

    if (addr < 0 || addr >= maxDevices) {
        return;
    }
    if (digit < 0 || digit > 7) {
        return;
    }
    offset = addr * 8;
    index = value;
    if (index > 127) {
        // no defined beyond index 127, so we use the space char
        index = 32;
    }
    v = charTable[index];
    if (dp) {
        // 0x80 = B10000000
        v = v | 0x80;
    }
    status[offset + digit] = v;
    spiTransfer(addr, digit + 1, v);
}

function LedControl::spiTransfer(addr, opcode, data) {
    // Create an array with the data to shift out
    local offset = addr * 2;
    local maxbytes = maxDevices * 2;

    local i;
    for (i = 0; i < maxbytes; i++) {
        spidata[i] = 0;
    }
    // put our device data into the array
    spidata[offset + 1] = opcode;
    spidata[offset] = data;
    spi.write(spidata);
}

