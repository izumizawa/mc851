# MC851 - Projeto em Computação I
Implementação de uma CPU reduzida com arquitetura em RISC-V em Verilog 2005.

## Integrantes

- RA 182783 | Lucca Costa Piccolotto Jordão
- RA 185447 | Paulo Barreira Pacitti
- RA 216116 | Gabriel Braga Proença
- RA 221859 | Mariana Megumi Izumizawa
- RA 169374 | Daniel Paulo Garcia
- RA 198435 | Guilherme Tavares Shimamoto

## Instruções para macOS
Após seguir as [instruções de instalação](https://www.ic.unicamp.br/~rodolfo/Cursos/mc851/2023s2/instalacao/), é necessário ativar as permissões de execução para `oss-cad-suite`. Para isso, basta executar os comando abaixos:
```bash
$ cd ~/eda/oss-cad-suite
$ ./activate
```
## Testes
Para implementar testes, utilize o `iverilog` para compilar seus módulos junto com seu _testbench_ e depois o execute-o. O exemplo abaixo mostra um teste da ALU:
```
$ iverilog -o ex_tb.vvp ex.v ex_tb.v
$ vvp ex_tb.vvp
```
A saída deve ser:
```
alu_1_tb: starting tests
  test_add: passed!
```
