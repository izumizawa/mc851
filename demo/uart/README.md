# Módulo UART

Esta é a implementação de um módulo UART seguindo o tutorial [Debugging da LushayLabs](https://learn.lushaylabs.com/tang-nano-9k-debugging/).

## O que é UART?

UART significa "universal asynchronous receiver/transmitter", ou seja, transmissor/receptor assíncrono universal. Define um protocolo para a troca de dados seriais entre dois dispositivos.

![Protocolo UART](/demo/uart/UART.drawio.png)

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

### Executando os scripts de serialport

O primeiro arquivo para ser executado é o `list-devices.js`, que é responsável por listar todas as Serial Ports. Para isso, basta executar dentro da pasta `scripts` o seguinte comando:

```
node list-devices.js
```

Para prosseguir é necessário copiar o valor do path: `/dev/tty.usbserial-...1`, como na seguinte imagem:

<img width="278" alt="Screenshot 2023-09-05 at 20 10 31" src="https://github.com/izumizawa/mc851/assets/25368628/1627518a-953a-4839-bf7c-d24636d682ad">

Em sequência, o path copiado deve ser colocado no arquivo `serial-program.js`, no seguinte trecho de código:

<img width="288" alt="Screenshot 2023-09-05 at 20 15 56" src="https://github.com/izumizawa/mc851/assets/25368628/136743e7-3846-4c81-8b6b-daf976432e6c">


Por fim, com o path configurado, basta executar o seguinte comando:

```
node serial-program.js
```

Com a execução desse programa, toda vez que o computador receber informações da placa, a informação é exibida no terminal. Além disso, para cada informação recebida, o script envia para a placa um valor de "contador" para ser exibido nos LEDs. Logo, para a placa enviar dados para o computador, basta pressionar o botão na placa.
