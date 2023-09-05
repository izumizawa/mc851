# Módulo UART

Esta é a implementação de um módulo UART seguindo o tutorial [Debugging da LushayLabs](https://learn.lushaylabs.com/tang-nano-9k-debugging/).

## O que é UART?

UART significa "universal asynchronous receiver/transmitter", ou seja, transmissor/receptor assíncrono universal. Define um protocolo para a troca de dados seriais entre dois dispositivos.

Como é assíncrono, não tem um sinal de clock para sincronia dos dois lados, eles precisam escolher com antecedência qual a frequência ou "baud rate" (quantidade de bits por segundo) e então cada lado gerencia o próprio clock para a frequência desejada.


## Como testar

### Executando o Test Bench

Rodar os comandos:
```
iverilog -o uart_test.o -s test uart.v uart_tb.v
vvp uart_test.o
```

A saída esperada:
```
Starting UART RX
VCD info: dumpfile uart.vcd opened for output.
LED Value xxxxxx
LED Value 011110
```

### Abrindo o Serial Console

Com o plugin instalado no seu VScode, clique no botão `"FPGA Toolchain"` e então em `"Open Serial Console"` e vai mostrar todos os devices conectados. A porta de número maior é para UART e a menor para JTAG.

Abra o Serial Console após fazer a build (`"FPGA Toolchain"` > `"Build and Program"`). Toda vez que apertar o botão, vai imprimir a string `"Mauricio!! "`.

### Serialport lib

Para executar os arquivos da pasta scripts será necessária a instalação da biblioteca `serialport`:

```
npm i serialport
```
