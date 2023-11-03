const {SerialPort} = require('serialport');

const tangnano = new SerialPort({
    path: '/dev/tty.usbserial-14401',
    baudRate: 115200,
});

tangnano.on('data', function (data) {
    console.log('Dado em hexadecimal:', data.toString('hex'))

    const binary = (parseInt(data.toString('hex'), 16).toString(2)).padStart(8, '0').match(/.{1,8}/g).join(' ')

    console.log('Dado em binário:', binary)
});
