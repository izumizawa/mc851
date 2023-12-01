# MC851 - Projeto em Computação I
Implementação de uma CPU reduzida com arquitetura em RISC-V em Verilog 2005. Foram implementados dois chips: o RISC-6™ A-500, com a RV32I (apenas com load/store de words), memória integrada e periféricos, demonstrado na demo presencialmente, e, o RISC-6™ A-1000, chip incompleto com a implementação com um novo design de unidade de memória  com caches L1.  A  branch `plan-b` contém o código relativo ao chip RISC-6™ A-500 completo, e a branch `memory-control` contém o código ao chip incompleto RISC-6™ A-1000.

Para execução da demo demonstrada em sala de aula, deve ser aberto o projeto contido na pasta `mc851_gowin_project/`, na branch `plan-b`,  no Gowin IDE.

## Integrantes

- RA 169374 | Daniel Paulo Garcia
- RA 182783 | Lucca Costa Piccolotto Jordão
- RA 185447 | Paulo Barreira Pacitti
- RA 198435 | Guilherme Tavares Shimamoto
- RA 216116 | Gabriel Braga Proença
- RA 221859 | Mariana Megumi Izumizawa

## Entregas
As entregas requeridas pelo programa da disciplina estão na pasta `docs`, os relatórios e slides.

## Testes
Para implementar testes, utilize o `iverilog` para compilar seus módulos junto com seu _testbench_ e depois o execute-o. Adicione seu script de teste no arquivo `rtl/tests/test.sh` para que seja adicionado a suite de testes do sistema.

Para rodar os testes, deve se estar nas pasta `rtl/tests`, estar com o `iverilog` instalado, e rodar o comando `bash test.sh`.

## Assembly/RISC-V
Programas para arquitetura RISC-V ficam armazenados na pasta `src/`. Para fazer o assemble/disassemble de um programa em RISC-V, utilize os scripts `.sh` da pasta `src`. Por exemplo:
```bash
# assemble
./assembler.sh addi.s

# disassemble
./disassembler.sh addi.o
```

## Instruções para macOS
Após seguir as [instruções de instalação](https://www.ic.unicamp.br/~rodolfo/Cursos/mc851/2023s2/instalacao/), é necessário ativar as permissões de execução para `oss-cad-suite`. Para isso, basta executar os comando abaixos:
```bash
$ cd ~/eda/oss-cad-suite
$ ./activate
```
