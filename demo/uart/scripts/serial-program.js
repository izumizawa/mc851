const {SerialPort} = require('serialport');

const tangnano = new SerialPort({
    path: '/dev/tty.usbserial-14401',
    baudRate: 115200,
});

tangnano.on('data', function (data) {
    const hexValue = data.toString('hex')
    const decValue = parseInt(hexValue, 16)

    console.log('Dado em decimal:', decValue)
    console.log('Dado em hexadecimal:', hexValue)

    const binary = (decValue.toString(2)).padStart(32, '0').match(/.{1,8}/g).join(' ')
    console.log('Dado em binário:', binary)
    console.log()
});
